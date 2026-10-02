import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

/// Temas claro y oscuro de la app, construidos a partir de DESIGN.md.
///
/// Uso: `MaterialApp(theme: AppTheme.light, darkTheme: AppTheme.dark)`.
abstract final class AppTheme {
  static final ThemeData light = _build(_lightScheme, AppColors.light);
  static final ThemeData dark = _build(_darkScheme, AppColors.dark);

  // Contrastes calculados en DESIGN.md §2.2 y §2.3.
  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppPalette.granate,
    onPrimary: AppPalette.blanco,
    primaryContainer: AppPalette.constanciaClaro,
    onPrimaryContainer: AppPalette.granateProfundo,
    secondary: AppPalette.maizTostado,
    onSecondary: AppPalette.blanco,
    secondaryContainer: AppPalette.maiz, // fondo de avisos
    onSecondaryContainer: AppPalette.tinta,
    tertiary: AppPalette.maizTostado, // indicador "buscando"
    onTertiary: AppPalette.blanco,
    error: AppPalette.ladrillo,
    onError: AppPalette.blanco,
    errorContainer: AppPalette.errorContenedorClaro,
    onErrorContainer: AppPalette.tinta,
    surface: AppPalette.blanco,
    onSurface: AppPalette.tinta,
    onSurfaceVariant: AppPalette.piedra,
    outline: AppPalette.contornoClaro,
    outlineVariant: AppPalette.divisorClaro,
    shadow: AppPalette.tinta,
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppPalette.granateAclarado,
    onPrimary: AppPalette.sobreGranateAclarado,
    primaryContainer: AppPalette.constanciaOscuro,
    onPrimaryContainer: AppPalette.sobreConstanciaOscuro,
    secondary: AppPalette.maizOscuro,
    onSecondary: AppPalette.tinta,
    secondaryContainer: AppPalette.maizOscuro,
    onSecondaryContainer: AppPalette.tinta,
    tertiary: AppPalette.maizOscuro,
    onTertiary: AppPalette.tinta,
    error: AppPalette.errorOscuro,
    onError: AppPalette.errorContenedorOscuro,
    errorContainer: AppPalette.errorContenedorOscuro,
    onErrorContainer: AppPalette.sobreErrorContenedorOscuro,
    surface: AppPalette.superficieOscura,
    onSurface: AppPalette.textoOscuro,
    onSurfaceVariant: AppPalette.textoSecundarioOscuro,
    outline: AppPalette.contornoOscuro,
    outlineVariant: AppPalette.divisorOscuro,
    shadow: Color(0xFF000000),
  );

  static ThemeData _build(ColorScheme scheme, AppColors appColors) {
    final textTheme = AppTypography.textTheme.apply(
      fontFamily: AppTypography.fontFamily,
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    );
    const buttonMinSize = Size(AppSizes.minTouch, AppSizes.primaryAction);
    const buttonPadding = EdgeInsets.symmetric(horizontal: AppSpacing.xl);

    OutlineInputBorder inputBorder(Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: appColors.background,
      extensions: [appColors],

      appBarTheme: AppBarTheme(
        backgroundColor: appColors.background,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(buttonMinSize),
          padding: const WidgetStatePropertyAll(buttonPadding),
          shape: WidgetStatePropertyAll(buttonShape),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          // Foco visible (teclado o switch de accesibilidad): anillo de 3 dp.
          side: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.focused)
                ? BorderSide(color: scheme.onSurface, width: 3)
                : BorderSide.none,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(buttonMinSize),
          padding: const WidgetStatePropertyAll(buttonPadding),
          shape: WidgetStatePropertyAll(buttonShape),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          foregroundColor: WidgetStatePropertyAll(scheme.primary),
          side: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.focused)
                ? BorderSide(color: scheme.primary, width: 3)
                : BorderSide(color: scheme.outline, width: 1.5),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AppSizes.minTouch, AppSizes.minTouch),
          textStyle: textTheme.labelLarge,
          shape: buttonShape,
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(AppSizes.minTouch, AppSizes.minTouch),
        ),
      ),

      // Campo de pregunta: etiqueta siempre visible y borde que se engrosa al enfocar.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(color: scheme.primary),
        hintStyle: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        border: inputBorder(scheme.outline, 1.5),
        enabledBorder: inputBorder(scheme.outline, 1.5),
        focusedBorder: inputBorder(scheme.primary, 2),
        errorBorder: inputBorder(scheme.error, 1.5),
        focusedErrorBorder: inputBorder(scheme.error, 2),
      ),

      // Chips (saltar a una entidad): radio pequeño y borde con significado.
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        side: BorderSide(color: scheme.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        labelStyle: textTheme.labelLarge?.copyWith(color: scheme.primary),
        iconTheme: IconThemeData(color: scheme.primary, size: 18),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      iconTheme: IconThemeData(color: scheme.onSurface, size: 24),
    );
  }
}
