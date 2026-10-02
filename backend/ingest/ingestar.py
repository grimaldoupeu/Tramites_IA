"""Ingesta de documentos: data/raw/ -> fragmentos con embeddings -> tabla "fragmentos".

Cada documento (nombre.txt / .pdf / .html) debe tener al lado un nombre.json con:
    {"entidad": "...", "tramite": "...", "url_fuente": "...", "fecha_extraccion": "AAAA-MM-DD"}

fecha_extraccion es el día en que se copió el texto de la página oficial; la app
la muestra como "Fuente consultada el ..." para que se sepa qué tan reciente es.

Uso (desde la carpeta backend/, con el entorno virtual activado):
    python -m ingest.ingestar            # procesa e inserta en Supabase
    python -m ingest.ingestar --dry-run  # solo muestra qué haría, sin tocar la BD

Es idempotente: antes de insertar un documento borra los fragmentos que ya
existían con la misma url_fuente, así volver a ejecutarlo no duplica datos.
"""

import argparse
import json
import sys
from dataclasses import dataclass
from datetime import date
from pathlib import Path

from app.config import BACKEND_DIR
from ingest.extraccion import EXTENSIONES_SOPORTADAS, extraer_texto
from ingest.fragmentacion import fragmentar_documento
from rag.embeddings import embed_pasajes

CARPETA_RAW = BACKEND_DIR / "data" / "raw"
TABLA = "fragmentos"
CAMPOS_METADATOS = ("entidad", "tramite", "url_fuente", "fecha_extraccion")


@dataclass
class Metadatos:
    entidad: str
    tramite: str
    url_fuente: str
    fecha_extraccion: str  # ISO 8601, p. ej. "2026-10-02"


def leer_metadatos(documento: Path) -> Metadatos:
    """Lee y valida el JSON que acompaña al documento."""
    ruta_json = documento.with_suffix(".json")
    if not ruta_json.exists():
        raise ValueError(f"falta el archivo de metadatos {ruta_json.name}")

    try:
        datos = json.loads(ruta_json.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        raise ValueError(f"{ruta_json.name} no es un JSON válido ({error})") from error

    faltantes = [c for c in CAMPOS_METADATOS if not str(datos.get(c, "")).strip()]
    if faltantes:
        raise ValueError(f"{ruta_json.name} no tiene: {', '.join(faltantes)}")

    metadatos = Metadatos(**{c: str(datos[c]).strip() for c in CAMPOS_METADATOS})
    try:
        date.fromisoformat(metadatos.fecha_extraccion)
    except ValueError:
        raise ValueError(
            f"{ruta_json.name}: fecha_extraccion debe tener el formato AAAA-MM-DD"
        ) from None
    return metadatos


def buscar_documentos(carpeta: Path) -> list[Path]:
    """Lista los documentos soportados de la carpeta, ordenados por nombre."""
    return sorted(
        ruta for ruta in carpeta.iterdir()
        if ruta.is_file() and ruta.suffix.lower() in EXTENSIONES_SOPORTADAS
    )


def procesar_documento(documento: Path, dry_run: bool) -> int:
    """Extrae, fragmenta, genera embeddings e inserta un documento. Devuelve nº de fragmentos."""
    metadatos = leer_metadatos(documento)
    texto = extraer_texto(documento)
    if not texto:
        raise ValueError("el documento no tiene texto (¿PDF escaneado como imagen?)")

    # Cada fragmento lleva al inicio el trámite y su sección (ver fragmentacion.py)
    fragmentos = fragmentar_documento(texto, metadatos.tramite)
    embeddings = embed_pasajes(fragmentos)

    if dry_run:
        return len(fragmentos)

    filas = [
        {
            "entidad": metadatos.entidad,
            "tramite": metadatos.tramite,
            "contenido": contenido,
            "url_fuente": metadatos.url_fuente,
            "fecha_extraccion": metadatos.fecha_extraccion,
            "embedding": embedding,
        }
        for contenido, embedding in zip(fragmentos, embeddings)
    ]

    # Import diferido: --dry-run funciona sin .env ni conexión a Supabase
    from app.db import get_supabase

    supabase = get_supabase()
    supabase.table(TABLA).delete().eq("url_fuente", metadatos.url_fuente).execute()
    supabase.table(TABLA).insert(filas).execute()
    return len(filas)


def main() -> int:
    parser = argparse.ArgumentParser(description="Ingesta de documentos a Supabase.")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="procesa los documentos pero no escribe en la base de datos",
    )
    args = parser.parse_args()

    documentos = buscar_documentos(CARPETA_RAW)
    if not documentos:
        print(f"No hay documentos en {CARPETA_RAW}")
        return 1

    if not args.dry_run:
        # Validar la configuración una sola vez, antes de procesar nada
        from pydantic import ValidationError

        from app.config import get_settings

        try:
            get_settings()
        except ValidationError as error:
            faltantes = ", ".join(str(e["loc"][0]).upper() for e in error.errors())
            print(f"Configuración incompleta en backend/.env: falta {faltantes}")
            return 1

    modo = " (dry-run: no se escribe en la BD)" if args.dry_run else ""
    print(f"Procesando {len(documentos)} documento(s){modo}...\n")

    total, errores = 0, 0
    for documento in documentos:
        try:
            cantidad = procesar_documento(documento, args.dry_run)
            total += cantidad
            print(f"  OK     {documento.name}: {cantidad} fragmento(s)")
        except Exception as error:  # un documento con problemas no detiene al resto
            errores += 1
            print(f"  ERROR  {documento.name}: {error}")

    print(f"\nListo: {total} fragmento(s) de {len(documentos) - errores} documento(s), "
          f"{errores} con error.")
    return 1 if errores else 0


if __name__ == "__main__":
    sys.exit(main())
