import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Colores de DESIGN.md que no tienen un lugar en el `ColorScheme` de Material.
///
/// Se leen con `context.appColors` (ver la extensión al final del archivo).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.userBubble,
    required this.onUserBubble,
    required this.warningAction,
    required this.onWarningAction,
  });

  /// Fondo de las pantallas (Papel en claro, berenjena en oscuro).
  final Color background;

  /// Burbuja de la pregunta del usuario.
  final Color userBubble;
  final Color onUserBubble;

  /// Botón dentro de un aviso (fondo Maíz). Es granate en ambos modos: el
  /// granate aclarado del modo oscuro tendría 1,1:1 sobre el Maíz (invisible);
  /// el granate da 5,3:1 en claro y 6,2:1 en oscuro.
  final Color warningAction;
  final Color onWarningAction;

  static const light = AppColors(
    background: AppPalette.papel,
    userBubble: AppPalette.granate,
    onUserBubble: AppPalette.blanco,
    warningAction: AppPalette.granate,
    onWarningAction: AppPalette.blanco,
  );

  static const dark = AppColors(
    background: AppPalette.fondoOscuro,
    userBubble: AppPalette.granateProfundo,
    onUserBubble: AppPalette.blanco,
    warningAction: AppPalette.granate,
    onWarningAction: AppPalette.blanco,
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? userBubble,
    Color? onUserBubble,
    Color? warningAction,
    Color? onWarningAction,
  }) {
    return AppColors(
      background: background ?? this.background,
      userBubble: userBubble ?? this.userBubble,
      onUserBubble: onUserBubble ?? this.onUserBubble,
      warningAction: warningAction ?? this.warningAction,
      onWarningAction: onWarningAction ?? this.onWarningAction,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      userBubble: Color.lerp(userBubble, other.userBubble, t)!,
      onUserBubble: Color.lerp(onUserBubble, other.onUserBubble, t)!,
      warningAction: Color.lerp(warningAction, other.warningAction, t)!,
      onWarningAction: Color.lerp(onWarningAction, other.onWarningAction, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  /// Atajo: `context.appColors.userBubble`.
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
