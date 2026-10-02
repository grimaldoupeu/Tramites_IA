"""Generación de la respuesta con Gemini a partir de los fragmentos recuperados."""

import logging
from functools import lru_cache

from google import genai
from google.genai import errors, types

from app.config import get_settings
from rag.busqueda import Fragmento
from rag.prompts import PROMPT_SISTEMA, SIN_INFORMACION, construir_mensaje

logger = logging.getLogger(__name__)

# Errores temporales de Google: 429 = demasiadas peticiones, 5xx = servidor saturado/caído
CODIGOS_TEMPORALES = [429, 500, 502, 503, 504]


class LLMNoDisponibleError(Exception):
    """Gemini no respondió por saturación, incluso tras reintentar y usar el respaldo."""


@lru_cache
def get_cliente_gemini() -> genai.Client:
    """Crea el cliente de Gemini una sola vez. Falla si no hay GEMINI_API_KEY."""
    api_key = get_settings().gemini_api_key
    if not api_key:
        raise RuntimeError("Falta GEMINI_API_KEY en backend/.env")
    return genai.Client(
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


def generar_respuesta(pregunta: str, fragmentos: list[Fragmento]) -> str:
    """Envía los fragmentos y la pregunta a Gemini y devuelve el texto de la respuesta.

    Si el modelo principal sigue saturado después de los reintentos, prueba con el
    modelo de respaldo (un modelo más ligero suele tener capacidad libre).
    """
    if not fragmentos:
        return SIN_INFORMACION  # sin contexto no hay nada que responder: ni llamamos al LLM

    settings = get_settings()
    mensaje = construir_mensaje(pregunta, fragmentos)

    try:
        return _llamar_gemini(settings.gemini_modelo, mensaje)
    except errors.APIError as error:
        if error.code not in CODIGOS_TEMPORALES:
            raise  # p. ej. 403 (clave bloqueada) o 400: reintentar no lo arregla
        logger.warning("%s no disponible (%s); usando %s",
                       settings.gemini_modelo, error.code, settings.gemini_modelo_respaldo)

    try:
        return _llamar_gemini(settings.gemini_modelo_respaldo, mensaje)
    except errors.APIError as error:
        if error.code in CODIGOS_TEMPORALES:
            raise LLMNoDisponibleError from error
        raise


def _llamar_gemini(modelo: str, mensaje: str) -> str:
    respuesta = get_cliente_gemini().models.generate_content(
        model=modelo,
        contents=mensaje,
        config=types.GenerateContentConfig(
            system_instruction=PROMPT_SISTEMA,
            temperature=0.2,  # baja: queremos respuestas fieles al texto, no creativas
            # No usamos herramientas (function calling): se desactiva para evitar avisos
            automatic_function_calling=types.AutomaticFunctionCallingConfig(disable=True),
        ),
    )
    return (respuesta.text or SIN_INFORMACION).strip()


def es_sin_informacion(respuesta: str) -> bool:
    """True si el modelo respondió que no tiene la información."""
    return respuesta.lower().startswith(SIN_INFORMACION.lower().rstrip("."))
