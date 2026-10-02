import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import '../theme/theme_controller.dart';

/// Botón de la barra superior que abre el selector de tema.
///
/// Su icono muestra el tema elegido. El lector de pantalla lo anuncia como
/// "Cambiar tema, botón"; mide 48 dp por `iconButtonTheme` (ver AppTheme).
class ThemeButton extends StatelessWidget {
  const ThemeButton({super.key, required this.controller});

  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      // La etiqueta para el lector de pantalla va en el icono (`semanticLabel`).
      // El tooltip (texto al mantener presionado) se excluye de la semántica para
      // que TalkBack no lea "Cambiar tema" dos veces.
      builder: (context, _) => Tooltip(
        message: 'Cambiar tema',
        excludeFromSemantics: true,
        child: IconButton(
          icon: Icon(_opcionDe(controller.modo).icono, semanticLabel: 'Cambiar tema'),
          onPressed: () => _mostrarSelector(context),
        ),
      ),
    );
  }

  void _mostrarSelector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      // Con letra grande la hoja puede crecer y desplazarse por dentro.
      isScrollControlled: true,
      builder: (_) => ThemeSheet(controller: controller),
    );
  }
}

/// Hoja inferior con las tres opciones de tema.
class ThemeSheet extends StatelessWidget {
  const ThemeSheet({super.key, required this.controller});

  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.sm),
            child: Semantics(
              header: true,
              child: Text('Tema de la app', style: text.titleLarge),
            ),
          ),
          RadioGroup<ThemeMode>(
            groupValue: controller.modo,
            onChanged: (modo) {
              if (modo == null) return;
              controller.cambiar(modo);
              Navigator.of(context).pop(); // el cambio ya se ve detrás de la hoja
            },
            child: Column(
              children: [
                for (final opcion in _opciones)
                  RadioListTile<ThemeMode>(
                    value: opcion.modo,
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
                    title: Text(opcion.titulo, style: text.titleMedium),
                    subtitle: Text(
                      opcion.descripcion,
                      style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    secondary: ExcludeSemantics(child: Icon(opcion.icono, color: scheme.primary)),
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OpcionTema {
  const _OpcionTema(this.modo, this.titulo, this.descripcion, this.icono);

  final ThemeMode modo;
  final String titulo;
  final String descripcion;
  final IconData icono;
}

const _opciones = [
  _OpcionTema(
    ThemeMode.system,
    'Automático (según el celular)',
    'Usa el mismo modo que tu celular',
    Icons.brightness_auto_rounded,
  ),
  _OpcionTema(ThemeMode.light, 'Claro', 'Fondo claro, ideal de día', Icons.light_mode_rounded),
  _OpcionTema(ThemeMode.dark, 'Oscuro', 'Fondo oscuro, cansa menos la vista de noche', Icons.dark_mode_rounded),
];

_OpcionTema _opcionDe(ThemeMode modo) => _opciones.firstWhere((o) => o.modo == modo);
