"""Búsqueda vectorial: pregunta -> embedding -> fragmentos más parecidos en Supabase."""

from dataclasses import dataclass
from datetime import date

from app.db import get_supabase
from rag.embeddings import embed_pregunta

CANTIDAD_FRAGMENTOS = 5


@dataclass
class Fragmento:
    entidad: str
    tramite: str
    contenido: str
    url_fuente: str
    fecha_extraccion: date
    similitud: float


def buscar_fragmentos(pregunta: str, cantidad: int = CANTIDAD_FRAGMENTOS) -> list[Fragmento]:
    """Llama a la función SQL buscar_fragmentos (pgvector) con el embedding de la pregunta."""
    respuesta = get_supabase().rpc(
        "buscar_fragmentos",
        {"query_embedding": embed_pregunta(pregunta), "cantidad": cantidad},
    ).execute()

    return [
        Fragmento(
            entidad=fila["entidad"],
            tramite=fila["tramite"],
            contenido=fila["contenido"],
            url_fuente=fila["url_fuente"],
            fecha_extraccion=date.fromisoformat(fila["fecha_extraccion"]),
            similitud=fila["similitud"],
        )
        for fila in respuesta.data
    ]
