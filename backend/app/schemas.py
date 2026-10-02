"""Modelos de entrada y salida de la API (validados automáticamente por FastAPI)."""

from datetime import date

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
    # Día en que se copió el texto de la página oficial (JSON: "2026-10-02").
    fecha_extraccion: date


class RespuestaResponse(BaseModel):
    respuesta: str
    fuentes: list[Fuente]
