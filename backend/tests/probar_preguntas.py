"""Ejecuta las preguntas de prueba (preguntas_prueba.json) y muestra cuáles pasan.

Úsalo después de cambiar la ingesta, la búsqueda o el prompt, para comprobar que
nada se rompió. Desde la carpeta backend/, con el entorno virtual activado:

    python -m tests.probar_preguntas                  # sin servidor: llama a /preguntar en el proceso
    python -m tests.probar_preguntas --url http://127.0.0.1:8000   # contra un servidor levantado
    python -m tests.probar_preguntas --solo sunarp-tive            # una sola pregunta

Cada pregunta pasa si:
  1. la respuesta contiene todos los términos de "debe_contener" (sin distinguir
     mayúsculas ni tildes), y
  2. las fuentes son exactamente las de "fuentes_esperadas".

Termina con código 1 si alguna falla (útil para automatizarlo más adelante).
Ojo: llama a Gemini de verdad (unas 12 llamadas) y tarda unos minutos.
"""

import argparse
import json
import sys
import time
import unicodedata
import urllib.request
from dataclasses import dataclass, field
from pathlib import Path

ARCHIVO_PREGUNTAS = Path(__file__).with_name("preguntas_prueba.json")


@dataclass
class Resultado:
    caso: dict
    respuesta: str = ""
    fuentes: list[str] = field(default_factory=list)
    faltan: list[str] = field(default_factory=list)  # términos que no aparecieron
    error: str | None = None  # la pregunta no se pudo hacer (red, 503...)

    @property
    def esperadas(self) -> list[str]:
        return self.caso["fuentes_esperadas"]

    @property
    def fuentes_ok(self) -> bool:
        return sorted(self.fuentes) == sorted(self.esperadas)

    @property
    def paso(self) -> bool:
        return self.error is None and not self.faltan and self.fuentes_ok


def normalizar(texto: str) -> str:
    """Minúsculas y sin tildes: 'Módulo' y 'modulo' cuentan como iguales."""
    sin_tildes = unicodedata.normalize("NFD", texto)
    return "".join(c for c in sin_tildes if unicodedata.category(c) != "Mn").lower()


def terminos_faltantes(respuesta: str, debe_contener: list) -> list[str]:
    """Cada elemento es un término o una lista de alternativas (basta una)."""
    texto = normalizar(respuesta)
    faltan = []
    for termino in debe_contener:
        alternativas = termino if isinstance(termino, list) else [termino]
        if not any(normalizar(a) in texto for a in alternativas):
            faltan.append(" o ".join(alternativas))
    return faltan


# ---------------------------------------------------------------------------
# Dos formas de preguntar: en el proceso (por defecto) o por HTTP (--url)
# ---------------------------------------------------------------------------

def preguntar_en_proceso(pregunta: str) -> dict:
    # Import diferido: con --url no hace falta cargar el modelo de embeddings.
    from fastapi import HTTPException

    from app.routes import preguntar
    from app.schemas import PreguntaRequest

    try:
        return preguntar(PreguntaRequest(pregunta=pregunta)).model_dump(mode="json")
    except HTTPException as error:
        raise RuntimeError(f"HTTP {error.status_code}: {error.detail}") from None


def preguntar_por_http(url_base: str, pregunta: str) -> dict:
    solicitud = urllib.request.Request(
        url_base.rstrip("/") + "/preguntar",
        data=json.dumps({"pregunta": pregunta}).encode("utf-8"),
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(solicitud, timeout=180) as respuesta:
        return json.loads(respuesta.read().decode("utf-8"))


# ---------------------------------------------------------------------------

def ejecutar(caso: dict, url: str | None) -> Resultado:
    resultado = Resultado(caso=caso)
    try:
        datos = preguntar_por_http(url, caso["pregunta"]) if url else preguntar_en_proceso(caso["pregunta"])
    except Exception as error:  # una pregunta con problemas no detiene al resto
        resultado.error = str(error)
        return resultado

    resultado.respuesta = datos["respuesta"]
    resultado.fuentes = [f["tramite"] for f in datos["fuentes"]]
    resultado.faltan = terminos_faltantes(resultado.respuesta, caso["debe_contener"])
    return resultado


def mostrar_detalle(r: Resultado) -> None:
    print(f"\n  ✗ {r.caso['id']}  ({r.caso['entidad']})")
    print(f"    Pregunta: {r.caso['pregunta']}")
    print(f"    Caso:     {r.caso['caso']}")
    if r.error:
        print(f"    ERROR:    {r.error}")
        return
    if r.faltan:
        print(f"    Faltan en la respuesta: {', '.join(r.faltan)}")
    if not r.fuentes_ok:
        sobran = [f for f in r.fuentes if f not in r.esperadas]
        faltan = [f for f in r.esperadas if f not in r.fuentes]
        print(f"    Fuentes esperadas: {r.esperadas or '(ninguna)'}")
        print(f"    Fuentes obtenidas: {r.fuentes or '(ninguna)'}")
        if sobran:
            print(f"      sobran: {sobran}")
        if faltan:
            print(f"      faltan: {faltan}")
    resumen = " ".join(r.respuesta.split())
    print(f"    Respuesta: {resumen[:300]}{'…' if len(resumen) > 300 else ''}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Preguntas de prueba del RAG.")
    parser.add_argument("--url", help="probar contra un servidor levantado (p. ej. http://127.0.0.1:8000)")
    parser.add_argument("--solo", help="ejecutar solo la pregunta con este id")
    parser.add_argument("--pausa", type=float, default=0, help="segundos entre preguntas (si Gemini limita)")
    args = parser.parse_args()

    casos = json.loads(ARCHIVO_PREGUNTAS.read_text(encoding="utf-8"))["preguntas"]
    if args.solo:
        casos = [c for c in casos if c["id"] == args.solo]
        if not casos:
            print(f"No existe una pregunta con id '{args.solo}'")
            return 1

    destino = args.url or "en el proceso (sin servidor)"
    print(f"Ejecutando {len(casos)} pregunta(s) {destino}...\n")

    resultados = []
    for i, caso in enumerate(casos):
        if i and args.pausa:
            time.sleep(args.pausa)
        inicio = time.perf_counter()
        r = ejecutar(caso, args.url)
        resultados.append(r)
        marca = "✓" if r.paso else "✗"
        print(f"  {marca} {caso['id']:<32} {time.perf_counter() - inicio:5.1f} s")

    fallidas = [r for r in resultados if not r.paso]
    nuevas = [r for r in resultados if not r.caso["calibracion"]]

    print("\n" + "=" * 70)
    print(f"{len(resultados) - len(fallidas)}/{len(resultados)} pasaron")
    print(f"  Preguntas nuevas (no usadas para calibrar el margen): "
          f"{sum(r.paso for r in nuevas)}/{len(nuevas)} pasaron")

    if fallidas:
        print("\nDetalle de las que fallaron:")
        for r in fallidas:
            mostrar_detalle(r)
    return 1 if fallidas else 0


if __name__ == "__main__":
    # La consola de Windows puede no usar UTF-8 por defecto (✓, ✗, tildes).
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    sys.exit(main())
