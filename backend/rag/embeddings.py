"""Generación de embeddings con intfloat/multilingual-e5-small (384 dimensiones).

El modelo E5 fue entrenado con prefijos: "query: " para preguntas y
"passage: " para documentos. Si se omiten, la calidad de la búsqueda baja.
"""

from functools import lru_cache

from sentence_transformers import SentenceTransformer

MODELO_EMBEDDINGS = "intfloat/multilingual-e5-small"
DIMENSIONES = 384


@lru_cache
def get_modelo() -> SentenceTransformer:
    """Carga el modelo una sola vez (la primera vez lo descarga de Hugging Face)."""
    return SentenceTransformer(MODELO_EMBEDDINGS)


def embed_pasajes(textos: list[str]) -> list[list[float]]:
    """Embeddings para fragmentos de documentos (prefijo "passage: ")."""
    vectores = get_modelo().encode(
        [f"passage: {t}" for t in textos],
        normalize_embeddings=True,  # vectores de norma 1: coseno = producto punto
        show_progress_bar=False,
    )
    return vectores.tolist()


def embed_pregunta(pregunta: str) -> list[float]:
    """Embedding para la pregunta del usuario (prefijo "query: ")."""
    vector = get_modelo().encode(
        f"query: {pregunta}",
        normalize_embeddings=True,
        show_progress_bar=False,
    )
    return vector.tolist()
