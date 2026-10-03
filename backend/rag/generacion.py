"""Generación de la respuesta a partir de los fragmentos recuperados.

No depende de un proveedor concreto: arma el mensaje y se lo pasa al
ProveedorLLM configurado (hoy Gemini, ver rag/proveedores/).
"""

from functools import lru_cache

from app.config import get_settings
from rag.busqueda import Fragmento
from rag.llm import ProveedorLLM, RespuestaLLM
from rag.prompts import PROMPT_SISTEMA, SIN_INFORMACION, construir_mensaje


@lru_cache
def get_proveedor() -> ProveedorLLM:
    """Crea el proveedor una sola vez. Falla si falta su clave en backend/.env."""
    from rag.proveedores.gemini import GeminiProveedor

    settings = get_settings()
    if not settings.gemini_api_key:
        raise RuntimeError("Falta GEMINI_API_KEY en backend/.env")
    return GeminiProveedor(
        api_key=settings.gemini_api_key,
        modelo=settings.gemini_modelo,
        modelo_respaldo=settings.gemini_modelo_respaldo,
    )


def generar_respuesta(pregunta: str, fragmentos: list[Fragmento]) -> RespuestaLLM:
    """Pide la respuesta al proveedor con los fragmentos numerados como contexto."""
    if not fragmentos:
        # Sin contexto no hay nada que responder: ni siquiera se llama al LLM.
        return RespuestaLLM(texto=SIN_INFORMACION)

    respuesta = get_proveedor().generar(PROMPT_SISTEMA, construir_mensaje(pregunta, fragmentos))
    if not respuesta.texto:
        return RespuestaLLM(texto=SIN_INFORMACION)
    return respuesta


def es_sin_informacion(texto: str) -> bool:
    """True si el modelo respondió que no tiene la información."""
    return texto.lower().startswith(SIN_INFORMACION.lower().rstrip("."))
