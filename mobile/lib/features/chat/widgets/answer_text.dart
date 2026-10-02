import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

/// Muestra el texto de una respuesta con el formato básico que usa el backend:
/// párrafos, listas numeradas (`1. `), viñetas (`- `), listas anidadas y
/// negritas (`**texto**`).
///
/// Es un intérprete mínimo a propósito: cubre lo que devuelve el modelo sin
/// agregar un paquete de Markdown completo.
class AnswerText extends StatelessWidget {
  const AnswerText(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final bloques = parsearBloques(texto);
    final escala = MediaQuery.textScalerOf(context);

    // Ancho fijo de la columna del número ("1.", "•"); crece con el tamaño de
    // letra del sistema. Al ser fijo, todos los ítems de un nivel quedan alineados.
    final anchoMarcador = escala.scale(32);
    // Sangría por nivel: con letra normal coincide con el ancho del número, así
    // una sublista empieza justo debajo del texto de su ítem padre. Con letra
    // muy grande se limita, para no dejar el texto en una columna estrecha.
    final sangriaPorNivel = math.min(anchoMarcador, 32.0);

    final children = <Widget>[];
    for (final (i, bloque) in bloques.indexed) {
      if (i > 0) {
        // Los ítems de una misma lista van más juntos que los párrafos.
        final mismaLista = bloque is ItemLista && bloques[i - 1] is ItemLista;
        children.add(SizedBox(height: mismaLista ? AppSpacing.sm : AppSpacing.md));
      }
      children.add(Padding(
        padding: EdgeInsets.only(left: _nivelVisible(bloque.nivel) * sangriaPorNivel),
        child: switch (bloque) {
          Parrafo(:final texto) => Text.rich(_conNegritas(texto)),
          ItemLista(:final marcador, :final texto) =>
            _Item(marcador: marcador, texto: texto, anchoMarcador: anchoMarcador),
        },
      ));
    }

    return DefaultTextStyle.merge(
      style: Theme.of(context).textTheme.bodyLarge,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }

  /// A partir del 4.º nivel ya no se agrega sangría: en un celular quitaría
  /// demasiado ancho al texto, y el modelo casi nunca anida tanto.
  static int _nivelVisible(int nivel) => math.min(nivel, 3);
}

/// Ítem de lista con sangría colgante: si el texto ocupa varias líneas, todas
/// quedan alineadas a la derecha del número.
class _Item extends StatelessWidget {
  const _Item({required this.marcador, required this.texto, required this.anchoMarcador});

  final String marcador;
  final String texto;
  final double anchoMarcador;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: anchoMarcador,
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            // Un número que no cabe (p. ej. "100.") se reduce en vez de empujar el texto.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: Text(marcador, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ),
        Expanded(child: Text.rich(_conNegritas(texto))),
      ],
    );
  }
}

/// Convierte `**texto**` en negrita (peso 700).
TextSpan _conNegritas(String texto) {
  final spans = <TextSpan>[];
  var inicio = 0;
  for (final m in RegExp(r'\*\*(.+?)\*\*').allMatches(texto)) {
    if (m.start > inicio) spans.add(TextSpan(text: texto.substring(inicio, m.start)));
    spans.add(TextSpan(text: m.group(1), style: const TextStyle(fontWeight: FontWeight.w700)));
    inicio = m.end;
  }
  if (inicio < texto.length) spans.add(TextSpan(text: texto.substring(inicio)));
  return TextSpan(children: spans);
}

// ---------------------------------------------------------------------------
// Interpretación del texto (separada del dibujo para poder probarla sola)
// ---------------------------------------------------------------------------

sealed class Bloque {
  const Bloque({this.nivel = 0});

  /// Profundidad de anidamiento: 0 = lista principal o texto normal,
  /// 1 = sublista dentro de un ítem, 2 = sublista de la sublista...
  final int nivel;
}

class Parrafo extends Bloque {
  const Parrafo(this.texto, {super.nivel});
  final String texto;
}

class ItemLista extends Bloque {
  const ItemLista({required this.marcador, required this.texto, super.nivel});

  /// "1." para listas numeradas; "•" o "◦" (en niveles impares) para viñetas.
  final String marcador;
  final String texto;
}

final _numerado = RegExp(r'^(\d+)[.)]\s+(.*)$');
final _vineta = RegExp(r'^[-*•]\s+(.*)$');

/// Divide el texto en bloques, una línea por bloque; las líneas vacías se omiten.
///
/// El nivel de cada ítem sale de la sangría de su línea, comparada con la de los
/// ítems anteriores (no con un número fijo de espacios): así funciona tanto si el
/// modelo sangra con 2, 3 o 4 espacios como con tabuladores.
List<Bloque> parsearBloques(String texto) {
  final bloques = <Bloque>[];

  // Sangrías de los niveles de lista abiertos, de afuera hacia adentro.
  // Ejemplo: [0, 3] = estamos dentro de una sublista sangrada 3 espacios.
  final abiertos = <int>[];

  for (final linea in texto.split('\n')) {
    final limpia = linea.trim();
    if (limpia.isEmpty) continue; // una línea vacía no cierra la lista

    final sangria = _anchoSangria(linea);
    // Una línea menos sangrada cierra los niveles más profundos.
    while (abiertos.isNotEmpty && abiertos.last > sangria) {
      abiertos.removeLast();
    }

    final numero = _numerado.firstMatch(limpia);
    final vineta = _vineta.firstMatch(limpia);

    if (numero != null || vineta != null) {
      // Más sangrado que el ítem anterior: empieza una sublista.
      if (abiertos.isEmpty || sangria > abiertos.last) abiertos.add(sangria);
      final nivel = abiertos.length - 1;

      bloques.add(numero != null
          ? ItemLista(marcador: '${numero.group(1)}.', texto: numero.group(2)!, nivel: nivel)
          : ItemLista(marcador: nivel.isOdd ? '◦' : '•', texto: vineta!.group(1)!, nivel: nivel));
    } else if (sangria == 0) {
      // Texto sin sangría: termina cualquier lista abierta.
      abiertos.clear();
      bloques.add(Parrafo(limpia));
    } else {
      // Texto sangrado dentro de un ítem (p. ej. una aclaración bajo un paso):
      // se alinea con el texto del ítem al que pertenece.
      final nivel = abiertos.where((s) => s < sangria).length;
      bloques.add(Parrafo(limpia, nivel: nivel));
    }
  }
  return bloques;
}

/// Ancho de la sangría inicial de una línea; un tabulador cuenta como 4 espacios.
int _anchoSangria(String linea) {
  var ancho = 0;
  for (final caracter in linea.runes) {
    if (caracter == 0x20) {
      ancho += 1;
    } else if (caracter == 0x09) {
      ancho += 4;
    } else {
      break;
    }
  }
  return ancho;
}
