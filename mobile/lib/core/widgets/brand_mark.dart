import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Rombo granate que acompaña al nombre "TramitesIA" (barra superior y firma
/// de las respuestas). Es decorativo: el lector de pantalla lo ignora.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 12});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Transform.rotate(
        angle: math.pi / 4,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
