"""Punto de entrada de la API de TramitesIA.

Ejecutar desde backend/ con el entorno virtual activado:
    uvicorn app.main:app --reload
Documentación interactiva: http://127.0.0.1:8000/docs
"""

from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.config import get_settings
from app.routes import router
from rag.embeddings import get_modelo
from rag.generacion import get_proveedor


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Al arrancar: valida la configuración y carga el modelo de embeddings.

    Así un error de configuración aparece al iniciar el servidor (no en la primera
    pregunta) y la primera respuesta no espera a que cargue el modelo.
    """
    get_settings()
    get_proveedor()
    get_modelo()
    yield


app = FastAPI(
    title="TramitesIA",
    description="Asistente RAG sobre trámites peruanos (SUNAT, RENIEC, SUNARP, municipalidades).",
    version="0.1.0",
    lifespan=lifespan,
)
app.include_router(router)
