"""Cliente de Supabase compartido por la API y el script de ingesta."""

from functools import lru_cache

from supabase import Client, create_client

from app.config import get_settings


@lru_cache
def get_supabase() -> Client:
    """Crea el cliente con la clave service_role (omite RLS: solo para el backend)."""
    settings = get_settings()
    return create_client(settings.supabase_url, settings.supabase_service_key)
