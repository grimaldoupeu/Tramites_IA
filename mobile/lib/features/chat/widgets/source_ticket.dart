import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/fechas.dart';
import '../../../data/models/fuente.dart';
import 'source_ticket_painter.dart';

/// Constancia de fuente (DESIGN.md §6.4): el talón con los enlaces oficiales que
/// va al final de cada respuesta.
///
/// No certifica la respuesta: deja claro que lo oficial es la página enlazada y
/// no el resumen generado por la IA.
///
/// Debe ser el último hijo de una tarjeta con borde y `clipBehavior` (ver
/// [SourceTicketPainter]).
class SourceTicket extends StatelessWidget {
  const SourceTicket({super.key, required this.fuentes, required this.onOpen});

  final List<Fuente> fuentes;

  /// Se llama al tocar una fuente; quien usa el widget decide cómo abrirla.
  final ValueChanged<Fuente> onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final plural = fuentes.length > 1;

    return CustomPaint(
      painter: SourceTicketPainter(
        fillColor: scheme.primaryContainer,
        perforationColor: scheme.outline,
        notchColor: context.appColors.background,
        notchBorderColor: scheme.outlineVariant,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Row(
                children: [
                  Icon(Icons.link_rounded, size: 20, color: scheme.onPrimaryContainer),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      plural ? 'Fuentes oficiales consultadas' : 'Fuente oficial consultada',
                      style: text.labelLarge?.copyWith(color: scheme.onPrimaryContainer),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Resumen hecho con IA. Confírmalo en la página oficial:',
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xs),
            for (final (i, fuente) in fuentes.indexed) ...[
              if (i > 0) const Divider(),
              _SourceLink(fuente: fuente, onTap: () => onOpen(fuente)),
            ],
          ],
        ),
      ),
    );
  }
}

class _SourceLink extends StatelessWidget {
  const _SourceLink({required this.fuente, required this.onTap});

  final Fuente fuente;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final fecha = fuente.fechaExtraccion;
    // Qué tan reciente es la información: la página oficial pudo cambiar después.
    final consultada = fecha == null ? null : 'Fuente consultada el ${fechaLarga(fecha)}';

    return Semantics(
      link: true,
      label: 'Abrir página oficial: ${fuente.tramite}, en ${fuente.dominio}. '
          '${consultada == null ? '' : '$consultada. '}Se abre en el navegador',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.minTouch),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fuente.tramite,
                        style: text.labelLarge?.copyWith(
                          color: scheme.onPrimaryContainer,
                          decoration: TextDecoration.underline,
                          decorationColor: scheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        fuente.dominio,
                        style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      if (consultada != null)
                        Text(
                          consultada,
                          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.open_in_new_rounded, size: 22, color: scheme.onPrimaryContainer),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
