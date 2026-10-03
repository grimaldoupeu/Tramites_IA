"""Pruebas de /preguntar con un proveedor falso (sin red: ni Gemini ni Supabase).

Desde backend/, con el entorno virtual activado:
    python -m unittest tests.test_api -v
"""

import unittest
from datetime import date
from types import SimpleNamespace
from unittest import mock

from fastapi.testclient import TestClient

from app.main import app
from rag.busqueda import Documento, Fragmento, Recuperacion
from rag.llm import RespuestaInvalidaError, RespuestaLLM
from rag.proveedores.gemini import GeminiProveedor

DOC = Documento("Solicitar duplicado de DNI", "https://www.gob.pe/224-solicitar-duplicado-de-dni",
                date(2026, 10, 2))
CONTEXTO = Recuperacion(
    fragmentos=[Fragmento("RENIEC", DOC.tramite, "…", DOC.url_fuente, DOC.fecha_extraccion, 0.9)],
    documentos=[DOC],
)

JSON_ROTO = '{"respuesta": "Cuesta S/ 35.00", "fuentes_usadas": [1'  # cortado a la mitad
JSON_SIN_CAMPO = '{"respuesta": "Cuesta S/ 35.00"}'  # JSON válido, pero sin fuentes_usadas
JSON_CORRECTO = '{"respuesta": "Cuesta S/ 35.00.", "fuentes_usadas": [1]}'


def gemini_que_responde(texto: str) -> GeminiProveedor:
    """El GeminiProveedor real, con el cliente de red reemplazado por uno falso.

    `parsed=None` simula que el SDK no pudo convertir la respuesta, así se prueba
    también la validación propia del texto.
    """
    proveedor = GeminiProveedor(api_key="clave-falsa", modelo="falso", modelo_respaldo="falso")
    respuesta = SimpleNamespace(parsed=None, text=texto)
    proveedor._cliente = SimpleNamespace(
        models=SimpleNamespace(generate_content=lambda **_: respuesta)
    )
    return proveedor


class ProveedorFalso:
    """Implementa ProveedorLLM sin Gemini: devuelve siempre la misma respuesta."""

    def __init__(self, respuesta: RespuestaLLM) -> None:
        self._respuesta = respuesta

    def generar(self, instrucciones: str, mensaje: str) -> RespuestaLLM:
        return self._respuesta


class PreguntarTest(unittest.TestCase):
    def setUp(self) -> None:
        # Sin Supabase ni modelo de embeddings: el contexto es fijo.
        parche = mock.patch("app.routes.recuperar", return_value=CONTEXTO)
        parche.start()
        self.addCleanup(parche.stop)
        # Sin `with`: no se ejecuta el arranque (no carga el modelo ni pide claves).
        self.cliente = TestClient(app)

    def preguntar_con(self, proveedor):
        with mock.patch("rag.generacion.get_proveedor", return_value=proveedor):
            return self.cliente.post("/preguntar", json={"pregunta": "¿Cuánto cuesta el duplicado?"})

    def test_json_invalido_responde_502_con_mensaje_claro(self):
        with self.assertLogs("app.routes", level="ERROR"):  # además, queda registrado
            r = self.preguntar_con(gemini_que_responde(JSON_ROTO))

        self.assertEqual(r.status_code, 502)
        self.assertEqual(
            r.json()["detail"],
            "El asistente devolvió una respuesta con un formato inesperado. Intenta de nuevo.",
        )

    def test_json_sin_el_campo_fuentes_usadas_tambien_es_502(self):
        with self.assertLogs("app.routes", level="ERROR"):
            r = self.preguntar_con(gemini_que_responde(JSON_SIN_CAMPO))
        self.assertEqual(r.status_code, 502)
        self.assertIn("formato inesperado", r.json()["detail"])

    def test_json_correcto_responde_200_con_su_fuente(self):
        r = self.preguntar_con(gemini_que_responde(JSON_CORRECTO))

        self.assertEqual(r.status_code, 200)
        self.assertEqual(r.json(), {
            "respuesta": "Cuesta S/ 35.00.",
            "fuentes": [{
                "tramite": DOC.tramite,
                "url": DOC.url_fuente,
                "fecha_extraccion": "2026-10-02",
            }],
        })

    def test_funciona_con_cualquier_proveedor_que_cumpla_la_interfaz(self):
        r = self.preguntar_con(ProveedorFalso(RespuestaLLM("Cuesta S/ 35.00.", [1])))
        self.assertEqual(r.status_code, 200)
        self.assertEqual([f["tramite"] for f in r.json()["fuentes"]], [DOC.tramite])


class GeminiProveedorTest(unittest.TestCase):
    def test_json_invalido_lanza_respuesta_invalida(self):
        with self.assertRaises(RespuestaInvalidaError):
            gemini_que_responde(JSON_ROTO).generar("instrucciones", "mensaje")

    def test_json_correcto_se_convierte_en_respuesta(self):
        r = gemini_que_responde(JSON_CORRECTO).generar("instrucciones", "mensaje")
        self.assertEqual(r, RespuestaLLM("Cuesta S/ 35.00.", [1]))


if __name__ == "__main__":
    unittest.main()
