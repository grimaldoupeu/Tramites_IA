"""Extracción de texto plano desde archivos TXT, PDF y HTML."""

import re
from pathlib import Path

from bs4 import BeautifulSoup
from pypdf import PdfReader

EXTENSIONES_SOPORTADAS = {".txt", ".pdf", ".html", ".htm"}


def extraer_texto(ruta: Path) -> str:
    """Devuelve el texto limpio del archivo según su extensión."""
    extension = ruta.suffix.lower()

    if extension == ".txt":
        texto = ruta.read_text(encoding="utf-8")
    elif extension == ".pdf":
        lector = PdfReader(ruta)
        texto = "\n\n".join(pagina.extract_text() or "" for pagina in lector.pages)
    elif extension in {".html", ".htm"}:
        sopa = BeautifulSoup(ruta.read_text(encoding="utf-8"), "html.parser")
        # Quitar partes que no son contenido (menús, scripts, estilos, pie de página)
        for etiqueta in sopa(["script", "style", "nav", "header", "footer", "noscript"]):
            etiqueta.decompose()
        texto = sopa.get_text(separator="\n")
    else:
        raise ValueError(f"Extensión no soportada: {extension}")

    return limpiar_texto(texto)


def limpiar_texto(texto: str) -> str:
    """Normaliza espacios y saltos de línea sin perder la separación entre párrafos."""
    texto = texto.replace("\r\n", "\n").replace(" ", " ")
    texto = re.sub(r"[ \t]+", " ", texto)          # espacios repetidos -> uno
    texto = re.sub(r" *\n *", "\n", texto)         # espacios alrededor de saltos
    texto = re.sub(r"\n{3,}", "\n\n", texto)       # máximo una línea en blanco
    return texto.strip()
