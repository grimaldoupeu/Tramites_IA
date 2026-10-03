"""Recuperación de contexto: pregunta -> documento principal + documentos cercanos.

1. Búsqueda vectorial: los fragmentos más parecidos a la pregunta (pgvector).
2. El documento del mejor fragmento es el **principal**: se incluyen TODOS sus
   fragmentos, en el orden del documento. Así el modelo ve el trámite completo
   (p. ej. las tres modalidades del duplicado de DNI con sus precios), no solo
   los trozos que se parecían más a la pregunta.
3. Los documentos cuya similitud está muy cerca de la mejor son **secundarios**:
   se agregan solo sus fragmentos encontrados (p. ej. "RUC" y "Clave SOL" cuando
   la pregunta trata de los dos).
4. Las fuentes que ve la persona son exactamente esos documentos.
"""

from dataclasses import dataclass
from datetime import date

from app.db import get_supabase
from rag.embeddings import embed_pregunta

TABLA = "fragmentos"

# Candidatos de la búsqueda vectorial inicial.
CANTIDAD_INICIAL = 10

# Máximo de fragmentos del documento principal (~8 × 450 tokens ≈ 3600 tokens).
# Hoy el documento más largo tiene 8: se incluye completo.
MAX_FRAGMENTOS_PRINCIPAL = 8

# Máximo de fragmentos que aportan los documentos secundarios.
MAX_FRAGMENTOS_SECUNDARIOS = 4

# Un documento es relevante si su mejor similitud está a esta distancia (o menos)
# de la mejor de todas. Valor medido con preguntas reales (modelo E5, 10/2026):
#   - "duplicado de DNI": Renovar DNI queda a 0,018 -> se excluye (es otro trámite);
#   - "RUC y Clave SOL": Clave SOL queda a 0,010 -> se incluye (se pregunta por ambos);
#   - en los casos claros, el segundo documento queda a 0,035 o más.
# Si se cambia, correr backend/tests/probar_preguntas.py para ver el efecto.
MARGEN_RELEVANCIA = 0.015


@dataclass
class Fragmento:
    entidad: str
    tramite: str
    contenido: str
    url_fuente: str
    fecha_extraccion: date
    similitud: float | None  # None: se agregó por ser del documento principal


@dataclass
class Documento:
    """Un documento usado como contexto; es lo que se muestra como fuente."""

    tramite: str
    url_fuente: str
    fecha_extraccion: date


@dataclass
class Recuperacion:
    fragmentos: list[Fragmento]  # contexto para el modelo, el principal primero
    documentos: list[Documento]  # fuentes relevantes, el principal primero


def recuperar(pregunta: str) -> Recuperacion:
    """Devuelve el contexto (documento principal completo + cercanos) y sus fuentes."""
    candidatos = buscar_fragmentos(pregunta, CANTIDAD_INICIAL)
    if not candidatos:
        return Recuperacion(fragmentos=[], documentos=[])

    mejor = candidatos[0].similitud
    principal = candidatos[0].url_fuente

    # Documentos relevantes, en orden de similitud (el principal es el primero).
    relevantes: dict[str, Fragmento] = {}
    for c in candidatos:
        if c.similitud >= mejor - MARGEN_RELEVANCIA:
            relevantes.setdefault(c.url_fuente, c)

    fragmentos = _fragmentos_del_principal(principal, candidatos)
    secundarios = [c for c in candidatos if c.url_fuente in relevantes and c.url_fuente != principal]
    fragmentos += secundarios[:MAX_FRAGMENTOS_SECUNDARIOS]

    documentos = [
        Documento(tramite=f.tramite, url_fuente=url, fecha_extraccion=f.fecha_extraccion)
        for url, f in relevantes.items()
    ]
    return Recuperacion(fragmentos=fragmentos, documentos=documentos)


def buscar_fragmentos(pregunta: str, cantidad: int) -> list[Fragmento]:
    """Llama a la función SQL buscar_fragmentos (pgvector) con el embedding de la pregunta."""
    respuesta = get_supabase().rpc(
        "buscar_fragmentos",
        {"query_embedding": embed_pregunta(pregunta), "cantidad": cantidad},
    ).execute()
    return [_a_fragmento(fila, fila["similitud"]) for fila in respuesta.data]


def _fragmentos_del_principal(url: str, candidatos: list[Fragmento]) -> list[Fragmento]:
    """Todos los fragmentos del documento principal, en el orden del documento.

    Si superara MAX_FRAGMENTOS_PRINCIPAL, se priorizan los que encontró la
    búsqueda y se completa con el resto, sin perder el orden original.
    """
    filas = (
        get_supabase()
        .table(TABLA)
        .select("id, entidad, tramite, contenido, url_fuente, fecha_extraccion")
        .eq("url_fuente", url)
        .order("id")  # la ingesta inserta en el orden del documento
        .execute()
        .data
    )

    similitud = {c.contenido: c.similitud for c in candidatos if c.url_fuente == url}
    if len(filas) > MAX_FRAGMENTOS_PRINCIPAL:
        encontrados = [f for f in filas if f["contenido"] in similitud]
        resto = [f for f in filas if f["contenido"] not in similitud]
        elegidos = {f["id"] for f in (encontrados + resto)[:MAX_FRAGMENTOS_PRINCIPAL]}
        filas = [f for f in filas if f["id"] in elegidos]

    return [_a_fragmento(f, similitud.get(f["contenido"])) for f in filas]


def _a_fragmento(fila: dict, similitud: float | None) -> Fragmento:
    return Fragmento(
        entidad=fila["entidad"],
        tramite=fila["tramite"],
        contenido=fila["contenido"],
        url_fuente=fila["url_fuente"],
        fecha_extraccion=date.fromisoformat(fila["fecha_extraccion"]),
        similitud=similitud,
    )
