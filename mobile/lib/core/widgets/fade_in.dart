import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Aparición con fundido para un mensaje nuevo (DESIGN.md §8).
/// Si la persona activó "reducir animaciones", aparece de inmediato.
class FadeIn extends StatelessWidget {
  const FadeIn({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sinAnimacion = MediaQuery.disableAnimationsOf(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: sinAnimacion ? 1 : 0, end: 1),
      duration: sinAnimacion ? Duration.zero : AppDurations.message,
      curve: Curves.easeOut,
      builder: (context, opacity, child) => Opacity(opacity: opacity, child: child),
      child: child,
    );
  }
}
