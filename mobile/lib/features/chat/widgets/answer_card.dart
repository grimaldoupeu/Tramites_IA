import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../data/models/fuente.dart';
import '../../../data/models/respuesta.dart';
import 'answer_text.dart';
import 'source_ticket.dart';

/// Respuesta del asistente (DESIGN.md §6.3): bloque de ancho completo, no una
/// burbuja estrecha, porque suele ser un texto largo con pasos numerados.
class AnswerCard extends StatelessWidget {
  const AnswerCard({super.key, required this.respuesta, required this.onOpenFuente});

  final Respuesta respuesta;
  final ValueChanged<Fuente> onOpenFuente;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Firma: dice "respuesta", no "información oficial".
        Semantics(
          header: true,
          child: Row(
            children: [
              const BrandMark(size: 9),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Respuesta de TramitesIA',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          clipBehavior: Clip.antiAlias, // recorta la mitad exterior de las muescas
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border.all(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                // SelectionArea: permite copiar requisitos o números de formulario.
                child: SelectionArea(child: AnswerText(respuesta.texto)),
              ),
              // Sin fuentes = "No tengo información sobre eso": no hay constancia.
              if (respuesta.fuentes.isNotEmpty)
                SourceTicket(fuentes: respuesta.fuentes, onOpen: onOpenFuente),
            ],
          ),
        ),
      ],
    );
  }
}
