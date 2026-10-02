"""División de un documento en fragmentos con contexto, de máximo 500 tokens.

Cada fragmento empieza con el trámite y la sección a la que pertenece:

    Trámite: Solicitar duplicado de DNI
    Sección: Modalidad: Online

    ## Canales de pago:
    - Si ya cuentas con DNIe: S/ 35.00 con el código de tributo 00522.

Así un dato (un precio, un requisito, un plazo) nunca queda separado de su
modalidad, ni en la búsqueda ni en lo que lee el modelo.

Los tokens se cuentan con el tokenizador del propio modelo de embeddings, porque
E5 solo procesa 512 tokens: 500 del fragmento (encabezado incluido) + el prefijo
"passage: " + los tokens especiales de inicio y fin caben sin que se recorte nada.
"""

import re
from dataclasses import dataclass

from rag.embeddings import get_modelo

TOKENS_POR_FRAGMENTO = 500
TOKENS_SOLAPAMIENTO = 50

_ENCABEZADO = re.compile(r"^(#{1,6})\s+(.+?)\s*$")

# En gob.pe, cada forma de hacer el trámite empieza con un título "Modalidad: X"
# y sus subsecciones ("Canales de pago:", "Hazlo en 3 pasos:") van después, al
# mismo nivel de título. Por eso la modalidad se arrastra a las subsecciones.
_MODALIDAD = re.compile(r"^Modalidad\b", re.IGNORECASE)

SECCION_GENERAL = "Información general"


@dataclass
class Seccion:
    grupo: str  # modalidad o sección principal: nunca se mezclan grupos distintos
    titulo: str  # ruta completa, p. ej. "Modalidad: Online > Canales de pago:"
    cuerpo: str  # texto de la sección, con su propio título al inicio


def dividir_en_secciones(texto: str) -> list[Seccion]:
    """Divide el texto según sus títulos markdown (## y ###).

    El título "#" (nivel 1) es el nombre del trámite y se omite: ya va en el
    encabezado de cada fragmento. Un texto sin títulos queda en una sola sección.
    """
    secciones: list[Seccion] = []
    modalidad: str | None = None
    pila: list[tuple[int, str]] = []  # títulos abiertos (nivel, texto) dentro de la modalidad
    lineas: list[str] = []

    def cerrar_seccion() -> None:
        cuerpo = "\n".join(lineas).strip()
        if not cuerpo:
            return
        ruta = ([modalidad] if modalidad else []) + [t for _, t in pila]
        grupo = modalidad or (pila[0][1] if pila else SECCION_GENERAL)
        secciones.append(Seccion(grupo, " > ".join(ruta) or SECCION_GENERAL, cuerpo))

    for linea in texto.splitlines():
        encabezado = _ENCABEZADO.match(linea)
        if not encabezado:
            lineas.append(linea)
            continue

        nivel, titulo = len(encabezado.group(1)), encabezado.group(2)
        if nivel == 1:
            continue  # nombre del trámite

        cerrar_seccion()
        lineas = [linea]  # el título también queda dentro del texto del fragmento
        if _MODALIDAD.match(titulo):
            modalidad, pila = titulo, []
        else:
            pila = [(n, t) for n, t in pila if n < nivel] + [(nivel, titulo)]

    cerrar_seccion()
    return secciones


def fragmentar_documento(texto: str, tramite: str) -> list[str]:
    """Agrupa las secciones en fragmentos de hasta 500 tokens con su encabezado.

    - Secciones seguidas del mismo grupo (misma modalidad) se juntan mientras quepan.
    - Una sección que sola no cabe se corta en ventanas con solapamiento, y cada
      trozo repite el encabezado con la ruta completa de la sección.
    """
    fragmentos: list[str] = []
    pendientes: list[Seccion] = []

    def volcar() -> None:
        if pendientes:
            cuerpo = "\n\n".join(s.cuerpo for s in pendientes)
            fragmentos.append(_encabezado(tramite, pendientes[0].grupo) + cuerpo)
            pendientes.clear()

    for seccion in dividir_en_secciones(texto):
        candidatas = [*pendientes, seccion]
        mismo_grupo = all(s.grupo == seccion.grupo for s in pendientes)
        if mismo_grupo and _cabe(tramite, seccion.grupo, candidatas):
            pendientes.append(seccion)
            continue

        volcar()
        if _cabe(tramite, seccion.grupo, [seccion]):
            pendientes.append(seccion)
        else:
            encabezado = _encabezado(tramite, seccion.titulo)
            espacio = TOKENS_POR_FRAGMENTO - _contar_tokens(encabezado)
            for trozo in fragmentar(seccion.cuerpo, tamano=espacio):
                fragmentos.append(encabezado + trozo)

    volcar()
    return fragmentos


def _encabezado(tramite: str, seccion: str) -> str:
    return f"Trámite: {tramite}\nSección: {seccion}\n\n"


def _cabe(tramite: str, grupo: str, secciones: list[Seccion]) -> bool:
    texto = _encabezado(tramite, grupo) + "\n\n".join(s.cuerpo for s in secciones)
    return _contar_tokens(texto) <= TOKENS_POR_FRAGMENTO


def _contar_tokens(texto: str) -> int:
    return len(get_modelo().tokenizer(texto, add_special_tokens=False, verbose=False)["input_ids"])


def fragmentar(
    texto: str,
    tamano: int = TOKENS_POR_FRAGMENTO,
    solapamiento: int = TOKENS_SOLAPAMIENTO,
) -> list[str]:
    """Divide el texto en ventanas de `tamano` tokens que se solapan `solapamiento` tokens.

    El solapamiento evita que una idea que cae en el borde entre dos fragmentos
    se pierda: el final de un fragmento se repite al inicio del siguiente.
    """
    if solapamiento >= tamano:
        raise ValueError("El solapamiento debe ser menor que el tamaño del fragmento")

    tokenizador = get_modelo().tokenizer
    # offsets: posición (inicio, fin) en caracteres de cada token dentro del texto.
    # Así recortamos el texto original en vez de reconstruirlo desde los tokens.
    offsets = tokenizador(
        texto,
        add_special_tokens=False,
        return_offsets_mapping=True,
        verbose=False,  # no avisar de que el texto completo supera 512 tokens
    )["offset_mapping"]

    if not offsets:
        return []

    fragmentos = []
    paso = tamano - solapamiento
    for inicio in range(0, len(offsets), paso):
        ventana = offsets[inicio : inicio + tamano]
        fragmento = texto[ventana[0][0] : ventana[-1][1]].strip()
        if fragmento:
            fragmentos.append(fragmento)
        if inicio + tamano >= len(offsets):
            break  # la última ventana ya llegó al final del texto

    return fragmentos
