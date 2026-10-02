import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

/// Burbuja de la pregunta de la persona (DESIGN.md §6.3): granate, alineada a
/// la derecha y con la esquina inferior derecha casi recta, "apuntando" a quien habla.
class UserBubble extends StatelessWidget {
  const UserBubble({super.key, required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
          child: Semantics(
            label: 'Tu pregunta: $texto',
            excludeSemantics: true,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.userBubble,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  topRight: Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(AppRadius.lg),
                  bottomRight: Radius.circular(AppRadius.bubbleTail),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  texto,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors.onUserBubble),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
