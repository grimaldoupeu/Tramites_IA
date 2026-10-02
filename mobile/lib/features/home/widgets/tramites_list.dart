import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../tramites_rapidos.dart';

/// Lista de trámites (DESIGN.md §6.2): un solo contenedor con divisores, no
/// tarjetas sueltas. Es una lista y no una cuadrícula para que los nombres
/// largos no se corten con letra grande.
class TramitesList extends StatelessWidget {
  const TramitesList({super.key, required this.tramites, required this.onSelect});

  final List<TramiteRapido> tramites;
  final ValueChanged<TramiteRapido> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      clipBehavior: Clip.antiAlias, // el efecto al tocar respeta las esquinas
      shape: RoundedRectangleBorder(
        side: BorderSide(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          for (final (i, tramite) in tramites.indexed) ...[
            if (i > 0) const Divider(),
            _TramiteRow(tramite: tramite, onTap: () => onSelect(tramite)),
          ],
        ],
      ),
    );
  }
}

class _TramiteRow extends StatelessWidget {
  const _TramiteRow({required this.tramite, required this.onTap});

  final TramiteRapido tramite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: '${tramite.nombre}. ${tramite.descripcion}',
      hint: 'Pregunta sobre este trámite',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(tramite.icono, color: scheme.primary),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tramite.nombre, style: text.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        tramite.descripcion,
                        style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
