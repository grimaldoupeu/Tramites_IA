import 'package:flutter/material.dart';

/// Contenido desplazable arriba y una barra fija abajo (la de escribir).
///
/// Con la letra del celular al máximo y el teclado abierto, la barra podría no
/// caber. Por eso nunca ocupa más del [maxBarFraction] del alto disponible: si
/// lo supera, la barra se desplaza por dentro y la pantalla no se desborda.
class BottomBarLayout extends StatelessWidget {
  const BottomBarLayout({
    super.key,
    required this.content,
    required this.bottomBar,
    this.maxBarFraction = 0.6,
  });

  final Widget content;
  final Widget bottomBar;
  final double maxBarFraction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          Expanded(child: content),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight * maxBarFraction),
            // reverse: si hay que desplazar, el campo de texto queda a la vista.
            child: SingleChildScrollView(reverse: true, child: bottomBar),
          ),
        ],
      ),
    );
  }
}
