import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../tramites_rapidos.dart';

/// Chips para saltar a la sección de cada entidad (SUNAT, RENIEC, SUNARP).
///
/// Con 17 trámites la lista es larga: así quien busca un trámite del DNI no
/// tiene que pasar por todos los de impuestos.
class EntityJumpChips extends StatelessWidget {
  const EntityJumpChips({super.key, required this.entidades, required this.onSelect});

  final List<EntidadTramites> entidades;
  final ValueChanged<EntidadTramites> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final entidad in entidades)
          Semantics(
            button: true,
            label: 'Ir a los trámites de ${entidad.sigla}',
            excludeSemantics: true,
            child: ActionChip(
              avatar: const Icon(Icons.arrow_downward_rounded),
              label: Text(entidad.sigla),
              onPressed: () => onSelect(entidad),
            ),
          ),
      ],
    );
  }
}
