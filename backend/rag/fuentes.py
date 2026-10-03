"""Qué fuentes se muestran: los documentos que el modelo dice haber usado.

La recuperación decide qué CONTEXTO recibe el modelo (rag/busqueda.py); este
módulo decide qué FUENTES ve la persona. Se separaron porque la similitud por sí
sola no distingue "relacionado" de "parecido en palabras": el modelo, que leyó
el contexto, sabe qué fragmentos usó de verdad.
"""

from rag.busqueda import Documento, Recuperacion
from rag.generacion import es_sin_informacion
from rag.llm import RespuestaLLM


def seleccionar_fuentes(respuesta: RespuestaLLM, contexto: Recuperacion) -> list[Documento]:
    """Documentos de los fragmentos citados, validados y sin repetir.

    - Sin información en la respuesta -> sin fuentes.
    - Se ignoran los números que no corresponden a un fragmento enviado.
    - Varios fragmentos del mismo documento -> una sola fuente.
    - Si no queda ninguna cita válida -> el documento principal.
    El orden es el de la recuperación: primero el documento principal.
    """
    if es_sin_informacion(respuesta.texto) or not contexto.documentos:
        return []

    citados: set[str] = set()
    for numero in respuesta.fuentes_usadas:
        # bool es subclase de int en Python: True no debe contar como el fragmento 1.
        if isinstance(numero, int) and not isinstance(numero, bool) \
                and 1 <= numero <= len(contexto.fragmentos):
            citados.add(contexto.fragmentos[numero - 1].url_fuente)

    fuentes = [d for d in contexto.documentos if d.url_fuente in citados]
    return fuentes or [contexto.documentos[0]]
