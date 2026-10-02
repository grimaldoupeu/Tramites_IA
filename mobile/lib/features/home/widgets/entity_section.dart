import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../tramites_rapidos.dart';
import 'tramites_list.dart';

/// Sección de una entidad en Inicio: encabezado (sigla y de qué se encarga) y
/// la lista de sus trámites. Siempre está abierta: no hay secciones plegables.
class EntitySection extends StatelessWidget {
  const EntitySection({super.key, required this.entidad, required this.onSelect});

  final EntidadTramites entidad;
  final ValueChanged<TramiteRapido> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Un solo nodo para el lector de pantalla: "SUNAT, Impuestos, RUC y...".
        MergeSemantics(
          child: Semantics(
            header: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entidad.sigla, style: text.titleLarge?.copyWith(color: scheme.primary)),
                const SizedBox(height: 2),
                Text(
                  entidad.descripcion,
                  style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TramitesList(tramites: entidad.tramites, onSelect: onSelect),
      ],
    );
  }
}
