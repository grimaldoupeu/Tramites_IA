"""Configuración de la aplicación leída desde variables de entorno o backend/.env."""

from functools import lru_cache
from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict

# Carpeta backend/ (este archivo está en backend/app/config.py)
BACKEND_DIR = Path(__file__).resolve().parent.parent


class Settings(BaseSettings):
    """Variables de configuración. Si falta alguna obligatoria, falla al arrancar."""

    model_config = SettingsConfigDict(
        env_file=BACKEND_DIR / ".env",
        env_file_encoding="utf-8",
        extra="ignore",
        hide_input_in_errors=True,  # no imprimir las claves en los mensajes de error
    )

    supabase_url: str
    supabase_service_key: str
    # Opcional aquí porque la ingesta no usa el LLM; la API la exige al arrancar.
    gemini_api_key: str | None = None
    gemini_modelo: str = "gemini-3.8-flash"
    gemini_modelo_respaldo: str = "gemini-3.5-flash-lite"  # si el principal está saturado


@lru_cache
def get_settings() -> Settings:
    """Devuelve la configuración (se lee una sola vez y se reutiliza)."""
    return Settings()
