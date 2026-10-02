"""División del texto en fragmentos de ~500 tokens con solapamiento.

Los tokens se cuentan con el tokenizador del propio modelo de embeddings, porque
E5 solo procesa 512 tokens: 500 del fragmento + el prefijo "passage: " + los
tokens especiales de inicio y fin caben sin que el modelo recorte nada.
"""

from rag.embeddings import get_modelo

TOKENS_POR_FRAGMENTO = 500
TOKENS_SOLAPAMIENTO = 50


def fragmentar(
    texto: str,
    tamano: int = TOKENS_POR_FRAGMENTO,
    solapamiento: int = TOKENS_SOLAPAMIENTO,
) -> list[str]:
    """Divide el texto en ventanas de `tamano` tokens que se solapan `solapamiento` tokens.

    El solapamiento evita que una idea que cae en el borde entre dos fragmentos
    se pierda: el final de un fragmento se repite al inicio del siguiente.
    """
    if solapamiento >= tamano:
        raise ValueError("El solapamiento debe ser menor que el tamaño del fragmento")

    tokenizador = get_modelo().tokenizer
    # offsets: posición (inicio, fin) en caracteres de cada token dentro del texto.
    # Así recortamos el texto original en vez de reconstruirlo desde los tokens.
    offsets = tokenizador(
        texto,
        add_special_tokens=False,
        return_offsets_mapping=True,
        verbose=False,  # no avisar de que el texto completo supera 512 tokens
    )["offset_mapping"]

    if not offsets:
        return []

    fragmentos = []
    paso = tamano - solapamiento
    for inicio in range(0, len(offsets), paso):
        ventana = offsets[inicio : inicio + tamano]
        fragmento = texto[ventana[0][0] : ventana[-1][1]].strip()
        if fragmento:
            fragmentos.append(fragmento)
        if inicio + tamano >= len(offsets):
            break  # la última ventana ya llegó al final del texto

    return fragmentos
