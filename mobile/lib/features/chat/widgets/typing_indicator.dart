import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

/// "Buscando en fuentes oficiales…" con tres puntos que laten (DESIGN.md §6.3).
///
/// Usa `tertiary` (Maíz tostado en claro: 5,0:1 sobre el fondo). Si la persona
/// activó "reducir animaciones" en su celular, los puntos quedan fijos.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: AppDurations.typingPulse);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.tertiary;

    return Semantics(
      liveRegion: true, // el lector de pantalla lo anuncia al aparecer
      label: 'Buscando en fuentes oficiales',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: 5),
            // Cada punto empieza un poco después que el anterior.
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _controller,
                curve: Interval(i * 0.2, 0.6 + i * 0.2, curve: Curves.easeInOut),
              ).drive(Tween(begin: 0.3, end: 1)),
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          ],
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Buscando en fuentes oficiales…',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
