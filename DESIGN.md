# Sistema de diseño · TramitesIA (app móvil)

Guía visual de la app Flutter. Cualquier color, tamaño o radio que use la app debe salir de aquí (a través del `ThemeData`), nunca escrito a mano en un widget.

## 1. Público y principios

**Para quién:** peruanos de todas las edades, incluidos adultos mayores y personas poco familiarizadas con la tecnología, que necesitan entender un trámite (RUC, Clave SOL, recibos por honorarios...) sin ayuda.

**Su objetivo:** hacer una pregunta, entender la respuesta y llegar a la fuente oficial.

| Principio | Qué significa en la práctica |
|-----------|------------------------------|
| **Se lee sin esfuerzo** | Texto base de 18 sp, contraste AA como mínimo (casi todo cumple AAA), la app funciona con el texto del sistema al 200 %. |
| **Una cosa a la vez** | Una sola acción principal por pantalla, sin menús ocultos ni gestos que haya que descubrir. |
| **Confianza institucional, no burocracia** | Un color serio y propio de lo peruano (el granate), sin sellos, escudos ni la estética de un portal estatal antiguo. |
| **Cálido y directo** | Se habla de "tú", en frases cortas. Los errores dicen qué pasó y qué hacer. |
| **La fuente siempre a la vista** | Cada respuesta termina con la constancia de la fuente oficial consultada (ver §6.4). |
| **Honestidad sobre la IA** | La app nunca presenta el texto generado como si fuera oficial: lo oficial es la página enlazada. |

**El elemento memorable** (la audacia se concentra en un solo lugar): **la constancia de fuente**. Las fuentes de cada respuesta se muestran como un talón con borde perforado, parecido al cargo que te dan en mesa de partes. La perforación tiene un significado: **separa** el resumen generado por la IA (arriba) del enlace oficial (abajo). El talón no certifica la respuesta; indica a dónde ir para comprobarla. Todo lo demás es sobrio.

## 2. Color

### 2.1 Paleta base

| Nombre | Hex | Uso |
|--------|-----|-----|
| **Granate** | `#7A1F2B` | Marca: botones principales, burbuja del usuario, enlaces y foco. Es el rojo vino del pasaporte peruano: institucional y cálido a la vez, y distinto del rojo brillante de los portales del Estado. |
| **Tinta** | `#1C1B1F` | Texto principal. |
| **Piedra** | `#5A5560` | Texto secundario y avisos. |
| **Papel** | `#F7F6F7` | Fondo de las pantallas. Es un gris neutro: no se usó crema a propósito. |
| **Blanco** | `#FFFFFF` | Superficies: respuestas, campo de texto y lista de trámites. |
| **Maíz** | `#E8B23A` | **Solo como fondo de avisos**, siempre con texto Tinta encima (8,9 : 1). Sobre Papel tiene apenas 1,8 : 1, así que nunca se usa como texto, icono ni indicador sobre fondo claro. |
| **Maíz tostado** | `#8C6200` | Indicador "buscando" (puntos y texto) en modo claro: 5,0 : 1 sobre Papel y 5,4 : 1 sobre blanco. Cumple el 3 : 1 de WCAG 1.4.11 e incluso el 4,5 : 1 de texto. |
| **Ladrillo** | `#B93A06` | Exclusivo para errores (ver §2.4). |

### 2.2 Tokens · modo claro

| Token (`ColorScheme`) | Hex | Contraste |
|-----------------------|-----|-----------|
| `primary` | `#7A1F2B` | 10,2 : 1 sobre blanco |
| `onPrimary` | `#FFFFFF` | 10,2 : 1 |
| `primaryContainer` (constancia) | `#FBF0F1` | — |
| `onPrimaryContainer` | `#5E1A25` | 11,4 : 1 |
| `secondaryContainer` (Maíz, fondo de avisos) | `#E8B23A` | — |
| `onSecondaryContainer` | `#1C1B1F` | 8,9 : 1 |
| `tertiary` (Maíz tostado, "buscando") | `#8C6200` | 5,0 : 1 sobre Papel |
| `surface` | `#FFFFFF` | — |
| `onSurface` (Tinta) | `#1C1B1F` | 17,1 : 1 |
| `onSurfaceVariant` (Piedra) | `#5A5560` | 7,2 : 1 |
| `surfaceContainerLowest` (fondo) | `#F7F6F7` | — |
| `outline` (bordes con significado) | `#8A8490` | 3,6 : 1 (AA para elementos gráficos) |
| `outlineVariant` (divisores) | `#E3DEE2` | Solo decorativo |
| `error` (Ladrillo) | `#B93A06` | 5,7 : 1 sobre blanco · 5,2 : 1 sobre su contenedor |
| `errorContainer` | `#FFF1EA` | — |
| `onErrorContainer` | `#1C1B1F` | Texto del mensaje |

### 2.3 Tokens · modo oscuro

No es una inversión del modo claro: el fondo tiene un matiz berenjena (no `#111`) y el granate se aclara a rosa para mantener el contraste.

| Token | Hex | Contraste |
|-------|-----|-----------|
| `primary` | `#F2A9B0` | 9,6 : 1 sobre el fondo |
| `onPrimary` | `#3B0A12` | 8,9 : 1 |
| Burbuja del usuario | `#5E1A25` + texto `#FFFFFF` | 12,7 : 1 |
| `primaryContainer` (constancia) | `#2E1C21` | — |
| `onPrimaryContainer` | `#F8D9DC` | 12,2 : 1 |
| `secondaryContainer` (Maíz, avisos) | `#F0C35A` | — |
| `onSecondaryContainer` | `#1C1B1F` | 10,3 : 1 |
| `tertiary` ("buscando") | `#F0C35A` | 9,9 : 1 sobre la superficie |
| `surface` | `#221E25` | — |
| `onSurface` | `#F3EFF4` | 14,4 : 1 |
| `onSurfaceVariant` | `#BDB5C0` | 8,2 : 1 |
| fondo | `#17141A` | — |
| `outline` | `#8F8794` | 4,7 : 1 |
| `outlineVariant` | `#3D3742` | Solo decorativo |
| `error` | `#FFB59A` | 9,6 : 1 sobre la superficie |
| `errorContainer` | `#4A1E0C` | — |
| `onErrorContainer` | `#FFD9CC` | 10,8 : 1 |

**Reglas**
- El color nunca es la única señal: los errores llevan icono y texto, y los enlaces llevan icono y subrayado.
- Por defecto el modo sigue al del celular (`ThemeMode.system`). La persona puede fijar "Claro" u "Oscuro" desde el botón de tema de la barra superior de Inicio, y la elección se guarda en el celular. Los colores de cada modo son los de esta sección.

### 2.4 Error frente a marca

El error **no** es rojo, porque un rojo se confundiría con el granate de la marca: un botón principal y un error se verían iguales. Por eso es **Ladrillo** `#B93A06`, un naranja quemado:

| | Granate (marca) | Ladrillo (error) |
|-|-----------------|------------------|
| Tono | 352° (rojo vino) | 17° (naranja) |
| Luminosidad | Oscuro (L = 0,05) | Medio (L = 0,13) |
| Dónde aparece | Botones, burbuja y enlaces | Solo en la tarjeta de error |

Además, el color nunca va solo. Un error **siempre** combina:
1. el icono `error` (círculo con signo de exclamación) en Ladrillo,
2. un título en texto que nombra el problema ("No se pudo conectar"),
3. el contenedor `errorContainer` con borde izquierdo de 4 dp en Ladrillo.

Así, una persona con daltonismo o una pantalla en escala de grises reconoce el error por el icono y el título.

## 3. Tipografía

**Familia única: [Atkinson Hyperlegible](https://fonts.google.com/specimen/Atkinson+Hyperlegible)** (paquete `google_fonts`), pesos 400 y 700.

Se eligió por el público y por el contenido, no por moda. El Braille Institute la diseñó para personas con baja visión, y distingue con claridad `I l 1`, `0 O` y `5 S`. Eso importa en una app donde aparecen números de RUC, "Formulario 2119" o "3 UIT". Usar una sola familia mantiene la interfaz tranquila: la jerarquía se marca con tamaño y peso.

| Rol (`TextTheme`) | Tamaño / interlineado | Peso | Uso |
|-------------------|-----------------------|------|-----|
| `headlineMedium` | 30 / 36 | 700 | Saludo de inicio |
| `titleLarge` | 22 / 28 | 700 | Título de sección |
| `titleMedium` | 18 / 24 | 700 | Nombre de trámite y botones |
| `bodyLarge` | **18 / 27** | 400 | **Texto base**: respuestas y preguntas |
| `bodyMedium` | 16 / 24 | 400 | Descripciones secundarias |
| `labelLarge` | 16 / 20 | 700 | Etiquetas de botones y chips |
| `bodySmall` | 14 / 20 | 400 | Aviso legal y metadatos (**mínimo absoluto**) |

- Nada por debajo de 14 sp. No se usan MAYÚSCULAS sostenidas en etiquetas.
- Las negritas de las respuestas (`**...**` del backend) se muestran en 700.
- Ancho máximo del texto: 640 dp (en tablet el contenido se centra).
- Nunca se fija `textScaler`: se respeta el tamaño de letra que elija el usuario.

## 4. Espaciado

Escala en múltiplos de 4. Es amplia (densidad baja) porque el público incluye personas con poca precisión táctil.

| Token | dp | Uso típico |
|-------|----|------------|
| `xs` | 4 | Icono ↔ texto pegado |
| `sm` | 8 | Entre elementos de un mismo grupo |
| `md` | 12 | Relleno interno de chips y entre burbujas del mismo turno |
| `lg` | 16 | Relleno interno de tarjetas y burbujas |
| `xl` | 20 | **Margen lateral de pantalla** |
| `xxl` | 32 | Entre secciones y entre turnos de conversación |
| `xxxl` | 48 | Separación superior del saludo |

**Táctil:** toda zona tocable mide **mínimo 48 × 48 dp**. Las acciones principales (enviar, reintentar, trámites) miden 56 dp de alto, con 8 dp como mínimo entre ellas.

## 5. Radios y elevación

El radio depende de la jerarquía; no se usa el mismo en todo.

| Token | dp | Dónde |
|-------|----|-------|
| `radiusSm` | 8 | Chips de fuente y foco |
| `radiusMd` | 14 | Botones, campo de texto, lista de trámites y constancia |
| `radiusLg` | 22 | Burbuja del usuario (esquina inferior derecha en 6, para que "apunte" a quien habla) |
| `radiusFull` | 999 | Botón circular de enviar |

**Elevación:** casi plana. Se usan bordes de 1 dp (`outlineVariant`) en lugar de sombras. Solo la barra de escritura lleva una sombra suave al haber contenido detrás, porque está "encima" del chat.

## 6. Componentes

### 6.1 Botones
- **Principal** (`FilledButton`): fondo `primary`, texto `labelLarge` en `onPrimary`, 56 dp de alto, ancho completo en los estados de error y radio `radiusMd`. El texto dice la acción: "Reintentar", "Enviar pregunta".
- **Secundario** (`OutlinedButton`): borde `outline` de 1,5 dp y texto `primary`.
- **Enviar:** circular de 56 dp, icono de flecha y `Semantics(label: 'Enviar pregunta')`. Está deshabilitado (con opacidad 38 %) si el campo está vacío.
- **Foco visible:** anillo de 3 dp en `primary` con separación de 2 dp.
- **Al presionar:** el efecto *ripple* de Material, sin escalados ni rebotes.

### 6.2 Lista de trámites (Inicio)
Los trámites se agrupan **por entidad**, en este orden: SUNAT, RENIEC, SUNARP. Las secciones siempre están abiertas (no son plegables), para que nada quede escondido.

- **Chips para saltar:** debajo de "Trámites disponibles" hay un chip por entidad (`ActionChip` con flecha hacia abajo, radio `radiusSm`, borde `outline`, texto `primary`). Al tocarlo, la pantalla se desplaza hasta esa sección (sin animación si se activó "reducir animaciones"). La zona tocable mide 48 dp y el lector de pantalla lo anuncia como "Ir a los trámites de RENIEC".
- **Encabezado de sección:** la sigla en `titleLarge` color `primary` y, debajo, de qué se encarga la entidad en `bodyMedium` `onSurfaceVariant` (p. ej. "DNI y actas de nacimiento, matrimonio o defunción"), para quien no reconoce la sigla.
- **Lista de cada entidad:** es **un solo contenedor** blanco con divisores, no tarjetas sueltas. Cada fila tiene icono de Material Symbols (redondeado, 24 dp, `primary`), el nombre en `titleMedium`, una línea que explica para qué sirve en `bodyMedium` y un chevron. Mide 64 dp de alto como mínimo y crece si el texto es grande. Se eligió una lista y no una cuadrícula porque nombres como "Suspensión de retenciones de 4ta categoría" se cortarían en dos columnas con letra grande.

### 6.3 Conversación
```
              ┌──────────────────────────┐
              │ ¿Qué necesito para sacar │   ← Burbuja del usuario
              │ mi RUC?                  │     granate, texto blanco,
              └──────────────────────────╯     alineada a la derecha, máx. 80 %
  ◆ Respuesta de TramitesIA
  ┌──────────────────────────────────────┐
  │ Para inscribirte en el RUC necesitas:│   ← Respuesta: bloque de ANCHO COMPLETO
  │ 1. Tu DNI...                         │     sobre blanco, borde outlineVariant.
  │ 2. ...                               │     No es una burbuja estrecha: son
  ├ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤     textos largos con pasos numerados.
  │ ⊶ Fuente oficial consultada          │   ← Constancia (6.4): la perforación
  │ Resumen hecho con IA. Confírmalo en  │     separa lo generado de lo oficial
  │ la página oficial:                   │
  │   Inscripción en el RUC · gob.pe  ↗  │
  └──────────────────────────────────────┘
```
- **Pregunta (usuario):** fondo `primary` (claro) o `#5E1A25` (oscuro), texto blanco `bodyLarge`, relleno `lg` y radio `radiusLg` con la esquina inferior derecha en 6.
- **Respuesta:** fondo `surface`, borde `outlineVariant`, relleno `lg` y radio `radiusMd`. Encima va la firma "Respuesta de TramitesIA" en `labelLarge` `onSurfaceVariant` con un pequeño rombo granate; dice "respuesta", no "información oficial". Las listas numeradas usan sangría colgante para que los números queden alineados.
- **Escribiendo:** tres puntos en `tertiary` (Maíz tostado `#8C6200` en claro, 5,0 : 1 sobre Papel; Maíz `#F0C35A` en oscuro) que laten (opacidad 0,3 → 1, 900 ms) y el texto "Buscando en fuentes oficiales…". Si el usuario activó "reducir animaciones" (`MediaQuery.disableAnimations`), los puntos quedan fijos.
- **Entrada de mensajes:** aparición con fundido de 200 ms, solo para el mensaje nuevo.

### 6.4 Constancia de fuente (elemento distintivo)
Va dentro del bloque de respuesta, separada del texto por una **línea perforada** (trazo discontinuo de 6/4 dp en `outline`) y con dos semicírculos recortados en los extremos, como un talón que se desprende.

**Qué comunica (y qué no):** la constancia **no certifica la respuesta**. Lo oficial es la página enlazada, no el texto generado. La perforación lo dice visualmente: arriba está lo que escribió la IA y abajo, separado, el documento oficial que se consultó.

- Fondo `primaryContainer` y texto `onPrimaryContainer`.
- **Título:** "Fuente oficial consultada" (o "Fuentes oficiales consultadas") en `labelLarge`, con el icono `link`. No se usa un sello, un escudo ni un check, porque sugerirían que la respuesta está validada.
- **Aclaración** en `bodySmall` (`onSurfaceVariant`, 6,5 : 1 sobre el contenedor): *"Resumen hecho con IA. Confírmalo en la página oficial:"*
- Debajo va una fila por fuente: el nombre del trámite subrayado, el dominio (`gob.pe`) en `bodySmall` para que se vea a dónde lleva y el icono ↗ ("se abre fuera de la app"). Cada fila mide 48 dp de alto como mínimo. Al tocar, se abre en el navegador (`url_launcher`, `LaunchMode.externalApplication`).
- Semántica: "Abrir página oficial: Inscripción en el RUC, en gob.pe. Se abre en el navegador".
- Si la respuesta es "No tengo información sobre eso.", la constancia no se muestra.

### 6.5 Campo de pregunta
Es un `TextField` multilínea (1 a 4 líneas) de fondo `surface`, con borde `outline` de 1,5 dp que pasa a `primary` de 2 dp al enfocarlo. Tiene una etiqueta visible ("Escribe tu pregunta"), no solo un *placeholder*, y una pista de ejemplo: "Ej.: ¿Cómo saco mi Clave SOL?". La tecla de envío del teclado también envía.

### 6.6 Estados de error y avisos
Hay dos niveles, y **ninguno depende solo del color**: siempre llevan icono y título en texto.

- **Error** (algo falló): tarjeta `errorContainer` con borde izquierdo de 4 dp en Ladrillo, icono `error` en Ladrillo, título en `titleMedium`, explicación en `bodyMedium` (Tinta) y el botón principal "Reintentar".
- **Aviso** (algo temporal que no es culpa de nadie): tarjeta `secondaryContainer` (Maíz) con icono `schedule`, texto Tinta (8,9 : 1) y el botón "Reintentar" (granate sobre Maíz, 5,3 : 1).

El texto dice qué pasó y qué hacer, sin disculpas vagas:

| Caso | Nivel | Icono | Título | Explicación |
|------|-------|-------|--------|-------------|
| Sin conexión / servidor caído | Error | `wifi_off` | No se pudo conectar | Revisa tu conexión a internet e inténtalo de nuevo. |
| 503 (IA saturada) | Aviso | `schedule` | El servicio está ocupado | Hay muchas consultas en este momento. Inténtalo en unos segundos. |
| Otro error | Error | `error` | No se pudo responder | Ocurrió un problema al preparar la respuesta. Inténtalo de nuevo. |

### 6.7 Aviso permanente
Es una franja fija **encima del campo de pregunta**, en todas las pantallas. Lleva el icono `info` y el texto en `bodySmall` `onSurfaceVariant`: *"Información referencial. Verifica siempre en la fuente oficial."* No se puede cerrar y no usa color de alerta: es discreta, pero siempre está.

## 7. Iconografía
- Se usan Material Symbols **Rounded** (incluidos en Flutter). Nunca emojis como iconos.
- Tamaños: 24 dp en filas y botones, 20 dp junto a texto `bodySmall`.
- Los iconos decorativos se excluyen del lector de pantalla y los de acción llevan etiqueta.

## 8. Movimiento
Hay poco movimiento y siempre responde a una acción del usuario:

| Qué | Duración | Curva |
|-----|----------|-------|
| Aparición de un mensaje | 200 ms | `easeOut` |
| Cambio de estado de un botón | 150 ms | `easeOut` |
| Transición entre pantallas | La de la plataforma | — |

No hay animaciones al cargar ni efectos de *scroll*. Si el usuario activa "reducir animaciones", las apariciones son instantáneas.

## 9. Lista de verificación antes de entregar una pantalla
- [ ] Todos los colores vienen de `Theme.of(context)`, sin `Color(0x...)` sueltos en widgets.
- [ ] Contraste AA verificado en modo claro **y** oscuro.
- [ ] Funciona con letra del sistema al 200 % (sin textos cortados ni desbordes).
- [ ] Toda zona tocable mide ≥ 48 dp y las acciones principales 56 dp.
- [ ] Los botones de solo icono tienen `Semantics`/`tooltip`.
- [ ] Se respeta "reducir animaciones".
- [ ] Se respetan las zonas seguras (`SafeArea`) y el teclado no tapa el campo.
- [ ] El aviso de información referencial es visible.
