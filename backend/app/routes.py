"""Endpoints de la API."""

import logging

from fastapi import APIRouter, HTTPException

from app.schemas import Fuente, PreguntaRequest, RespuestaResponse
from rag.busqueda import Fragmento, buscar_fragmentos
from rag.generacion import LLMNoDisponibleError, es_sin_informacion, generar_respuesta

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
        502: {"description": "Error inesperado al buscar o generar la respuesta"},
        503: {"description": "El modelo de IA está saturado; reintentar en unos segundos"},
    },
)
def preguntar(datos: PreguntaRequest) -> RespuestaResponse:
    pregunta = datos.pregunta.strip()

    try:
        fragmentos = buscar_fragmentos(pregunta)
        respuesta = generar_respuesta(pregunta, fragmentos)
    except LLMNoDisponibleError:
        logger.warning("Gemini saturado: no se pudo responder la pregunta")
        raise HTTPException(
            status_code=503,
            detail="El servicio está muy ocupado. Intenta de nuevo en unos segundos.",
            headers={"Retry-After": "10"},
        )
    except Exception:
        logger.exception("Error respondiendo la pregunta")
        raise HTTPException(status_code=502, detail="No se pudo generar la respuesta.")

    # Si no hubo respuesta, no mostramos fuentes que no se usaron
    fuentes = [] if es_sin_informacion(respuesta) else fuentes_unicas(fragmentos)
    return RespuestaResponse(respuesta=respuesta, fuentes=fuentes)


def fuentes_unicas(fragmentos: list[Fragmento]) -> list[Fuente]:
    """Una fuente por trámite (varios fragmentos pueden venir del mismo documento)."""
    vistas: dict[str, Fuente] = {}
    for f in fragmentos:
        vistas.setdefault(f.url_fuente, Fuente(tramite=f.tramite, url=f.url_fuente))
    return list(vistas.values())
