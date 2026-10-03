"""Interfaz del proveedor de LLM.

El resto del backend solo conoce esta interfaz: le pasa instrucciones y un mensaje
y recibe el texto de la respuesta más los números de los fragmentos que usó.
Cada proveedor decide CÓMO obtener esa estructura (Gemini usa salida JSON con
esquema; otro podría usar function calling o un formato de texto), así cambiar de
proveedor no toca la búsqueda, las fuentes ni la API.
"""

from dataclasses import dataclass, field
from typing import Protocol


@dataclass(frozen=True)
class RespuestaLLM:
    texto: str

    # Números de fragmento citados por el modelo (1 = el primero del mensaje).
    # Vienen SIN validar: los revisa rag/fuentes.py.
    fuentes_usadas: list[int] = field(default_factory=list)


class LLMNoDisponibleError(Exception):
    """El proveedor no respondió por saturación, incluso tras reintentar."""


class RespuestaInvalidaError(Exception):
    """El proveedor respondió, pero no con la estructura pedida."""


class ProveedorLLM(Protocol):
    def generar(self, instrucciones: str, mensaje: str) -> RespuestaLLM:
        """Devuelve la respuesta y los fragmentos usados.

        Lanza LLMNoDisponibleError si está saturado (la API responde 503) o
        RespuestaInvalidaError si no se pudo leer la estructura.
        """
        ...
