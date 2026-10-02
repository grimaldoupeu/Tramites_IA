"""Modelos de entrada y salida de la API (validados automáticamente por FastAPI)."""

from pydantic import BaseModel, Field


class PreguntaRequest(BaseModel):
    pregunta: str = Field(
        min_length=3,
        max_length=1000,
        examples=["¿Qué necesito para sacar mi RUC?"],
    )


class Fuente(BaseModel):
    tramite: str
    url: str


class RespuestaResponse(BaseModel):
    respuesta: str
    fuentes: list[Fuente]
