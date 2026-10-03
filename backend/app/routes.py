"""Endpoints de la API."""

import logging

from fastapi import APIRouter, HTTPException

from app.schemas import Fuente, PreguntaRequest, RespuestaResponse
from rag.busqueda import Documento, recuperar
from rag.fuentes import seleccionar_fuentes
from rag.generacion import generar_respuesta
from rag.llm import LLMNoDisponibleError, RespuestaInvalidaError

logger = logging.getLogger(__name__)
router = APIRouter()


@router.get("/salud")
def salud() -> dict:
    """Comprobación simple de que el servidor está vivo."""
    return {"estado": "ok"}


# `def` normal (no `async def`): embeddings, Supabase y Gemini son llamadas bloqueantes,
# así FastAPI ejecuta la función en un hilo aparte y no congela el servidor.
@router.post(
    "/preguntar",
    response_model=RespuestaResponse,
    responses={
        502: {"description": "El modelo respondió con un formato inválido, o hubo un error "
                            "inesperado al buscar o generar la respuesta"},
        503: {"description": "El modelo de IA está saturado; reintentar en unos segundos"},
    },
)
def preguntar(datos: PreguntaRequest) -> RespuestaResponse:
    pregunta = datos.pregunta.strip()

    try:
        # El contexto incluye el documento principal completo (rag/busqueda.py);
        # las fuentes que se muestran son solo las que el modelo citó (rag/fuentes.py).
        contexto = recuperar(pregunta)
        respuesta = generar_respuesta(pregunta, contexto.fragmentos)
        fuentes = [_a_fuente(d) for d in seleccionar_fuentes(respuesta, contexto)]
    except LLMNoDisponibleError:
        logger.warning("LLM saturado: no se pudo responder la pregunta")
        raise HTTPException(
            status_code=503,
            detail="El servicio está muy ocupado. Intenta de nuevo en unos segundos.",
            headers={"Retry-After": "10"},
        )
    except RespuestaInvalidaError:
        # El modelo respondió, pero no con el JSON pedido: reintentar suele funcionar.
        logger.exception("El LLM devolvió una respuesta con formato inválido")
        raise HTTPException(
            status_code=502,
            detail="El asistente devolvió una respuesta con un formato inesperado. "
            "Intenta de nuevo.",
        )
    except Exception:
        logger.exception("Error respondiendo la pregunta")
        raise HTTPException(status_code=502, detail="No se pudo generar la respuesta.")

    return RespuestaResponse(respuesta=respuesta.texto, fuentes=fuentes)


def _a_fuente(documento: Documento) -> Fuente:
    return Fuente(
        tramite=documento.tramite,
        url=documento.url_fuente,
        fecha_extraccion=documento.fecha_extraccion,
    )
