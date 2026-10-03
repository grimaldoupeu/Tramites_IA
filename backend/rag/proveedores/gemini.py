"""Proveedor de LLM con Google Gemini, usando salida estructurada (JSON con esquema)."""

import logging

from google import genai
from google.genai import errors, types
from pydantic import BaseModel, Field, ValidationError

from rag.llm import LLMNoDisponibleError, RespuestaInvalidaError, RespuestaLLM

logger = logging.getLogger(__name__)

# Errores temporales de Google: 429 = demasiadas peticiones, 5xx = servidor saturado/caído
CODIGOS_TEMPORALES = [429, 500, 502, 503, 504]


class SalidaEstructurada(BaseModel):
    """Esquema que Gemini debe respetar (response_schema). Las descripciones
    también le llegan al modelo y le explican qué poner en cada campo."""

    respuesta: str = Field(description="Respuesta para la persona, en español sencillo.")
    fuentes_usadas: list[int] = Field(
        description="Números (atributo numero) de los fragmentos de los que sale la "
        "información de la respuesta. Lista vacía si no hay información."
    )


class GeminiProveedor:
    """Implementa ProveedorLLM con Gemini.

    Reintenta con espera exponencial ante errores temporales y, si el modelo
    principal sigue saturado, prueba con el modelo de respaldo (uno más ligero
    suele tener capacidad libre).
    """

    def __init__(self, api_key: str, modelo: str, modelo_respaldo: str) -> None:
        self._modelo = modelo
        self._modelo_respaldo = modelo_respaldo
        self._cliente = genai.Client(
            api_key=api_key,
            http_options=types.HttpOptions(
                # Reintenta con espera exponencial (1 s, 2 s...) ante errores temporales
                retry_options=types.HttpRetryOptions(
                    attempts=3,
                    initial_delay=1.0,
                    max_delay=8.0,
                    http_status_codes=CODIGOS_TEMPORALES,
                ),
            ),
        )

    def generar(self, instrucciones: str, mensaje: str) -> RespuestaLLM:
        try:
            return self._llamar(self._modelo, instrucciones, mensaje)
        except errors.APIError as error:
            if error.code not in CODIGOS_TEMPORALES:
                raise  # p. ej. 403 (clave bloqueada) o 400: reintentar no lo arregla
            logger.warning("%s no disponible (%s); usando %s",
                           self._modelo, error.code, self._modelo_respaldo)

        try:
            return self._llamar(self._modelo_respaldo, instrucciones, mensaje)
        except errors.APIError as error:
            if error.code in CODIGOS_TEMPORALES:
                raise LLMNoDisponibleError from error
            raise

    def _llamar(self, modelo: str, instrucciones: str, mensaje: str) -> RespuestaLLM:
        respuesta = self._cliente.models.generate_content(
            model=modelo,
            contents=mensaje,
            config=types.GenerateContentConfig(
                system_instruction=instrucciones,
                temperature=0.2,  # baja: queremos respuestas fieles al texto, no creativas
                # Salida estructurada: Gemini devuelve JSON que cumple el esquema,
                # así no hay que interpretar una línea de texto libre.
                response_mime_type="application/json",
                response_schema=SalidaEstructurada,
                # No usamos herramientas (function calling): se desactiva para evitar avisos
                automatic_function_calling=types.AutomaticFunctionCallingConfig(disable=True),
            ),
        )

        salida = respuesta.parsed
        if not isinstance(salida, SalidaEstructurada):
            # El SDK no pudo convertirla: se intenta validar el texto directamente.
            try:
                salida = SalidaEstructurada.model_validate_json(respuesta.text or "")
            except ValidationError as error:
                raise RespuestaInvalidaError(f"{modelo} no devolvió el JSON esperado") from error

        return RespuestaLLM(texto=salida.respuesta.strip(), fuentes_usadas=salida.fuentes_usadas)
