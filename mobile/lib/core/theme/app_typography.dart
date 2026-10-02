import 'package:flutter/material.dart';

/// Tipografía de DESIGN.md (§3): una sola familia, la jerarquía se marca con
/// tamaño y peso.
///
/// Los tamaños son la base: Flutter los multiplica por la escala de texto que
/// el usuario eligió en su celular, y la app nunca la bloquea.
abstract final class AppTypography {
  /// Nombre declarado en pubspec.yaml (la fuente va incluida como asset).
  static const fontFamily = 'AtkinsonHyperlegible';

  static const _regular = FontWeight.w400;
  static const _bold = FontWeight.w700;

  /// `height` es interlineado / tamaño (p. ej. 27 / 18 = 1,5).
  static const textTheme = TextTheme(
    headlineMedium: TextStyle(fontSize: 30, height: 36 / 30, fontWeight: _bold),
    titleLarge: TextStyle(fontSize: 22, height: 28 / 22, fontWeight: _bold),
    titleMedium: TextStyle(fontSize: 18, height: 24 / 18, fontWeight: _bold),
    bodyLarge: TextStyle(fontSize: 18, height: 27 / 18, fontWeight: _regular),
    bodyMedium: TextStyle(fontSize: 16, height: 24 / 16, fontWeight: _regular),
    bodySmall: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: _regular),
    labelLarge: TextStyle(fontSize: 16, height: 20 / 16, fontWeight: _bold),
    // labelMedium / labelSmall de Material bajan de 14 sp: se suben al mínimo.
    labelMedium: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: _bold),
    labelSmall: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: _regular),
  );
}
