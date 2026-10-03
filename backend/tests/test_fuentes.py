"""Pruebas de seleccionar_fuentes (sin red: no llaman a Gemini ni a Supabase).

Desde backend/, con el entorno virtual activado:
    python -m unittest tests.test_fuentes -v
"""

import unittest
from datetime import date

from rag.busqueda import Documento, Fragmento, Recuperacion
from rag.fuentes import seleccionar_fuentes
from rag.llm import RespuestaLLM
from rag.prompts import SIN_INFORMACION

FECHA = date(2026, 10, 2)
DUPLICADO = Documento("Solicitar duplicado de DNI", "https://www.gob.pe/224", FECHA)
RENOVAR = Documento("Renovar DNI para mayores de 17 años", "https://www.gob.pe/250", FECHA)


def fragmento(doc: Documento) -> Fragmento:
    return Fragmento("RENIEC", doc.tramite, "…", doc.url_fuente, doc.fecha_extraccion, None)


# Contexto como el que arma recuperar(): 3 fragmentos del principal + 1 secundario.
CONTEXTO = Recuperacion(
    fragmentos=[fragmento(DUPLICADO), fragmento(DUPLICADO), fragmento(DUPLICADO), fragmento(RENOVAR)],
    documentos=[DUPLICADO, RENOVAR],
)


def fuentes(texto: str, citas: list) -> list[str]:
    elegidas = seleccionar_fuentes(RespuestaLLM(texto=texto, fuentes_usadas=citas), CONTEXTO)
    return [d.tramite for d in elegidas]


class SeleccionarFuentesTest(unittest.TestCase):
    def test_solo_los_documentos_citados(self):
        self.assertEqual(fuentes("Cuesta S/ 35.00.", [1, 3]), [DUPLICADO.tramite])

    def test_varios_documentos_citados_principal_primero(self):
        self.assertEqual(fuentes("…", [4, 2]), [DUPLICADO.tramite, RENOVAR.tramite])

    def test_documentos_repetidos_aparecen_una_vez(self):
        self.assertEqual(fuentes("…", [1, 2, 3, 1]), [DUPLICADO.tramite])

    def test_ignora_numeros_fuera_de_rango(self):
        self.assertEqual(fuentes("…", [0, 4, 5, 99, -1]), [RENOVAR.tramite])

    def test_ignora_valores_que_no_son_enteros(self):
        # True es int en Python; no debe contarse como el fragmento 1.
        self.assertEqual(fuentes("…", [True, "2", 2.0, None, 4]), [RENOVAR.tramite])

    def test_lista_vacia_muestra_el_principal(self):
        self.assertEqual(fuentes("Cuesta S/ 35.00.", []), [DUPLICADO.tramite])

    def test_solo_citas_invalidas_muestra_el_principal(self):
        self.assertEqual(fuentes("Cuesta S/ 35.00.", [0, 99]), [DUPLICADO.tramite])

    def test_sin_informacion_no_devuelve_fuentes(self):
        self.assertEqual(fuentes(SIN_INFORMACION, []), [])
        self.assertEqual(fuentes(SIN_INFORMACION, [1, 4]), [])  # aunque cite algo

    def test_sin_documentos_no_devuelve_fuentes(self):
        vacio = Recuperacion(fragmentos=[], documentos=[])
        self.assertEqual(seleccionar_fuentes(RespuestaLLM("…", [1]), vacio), [])


if __name__ == "__main__":
    unittest.main()
