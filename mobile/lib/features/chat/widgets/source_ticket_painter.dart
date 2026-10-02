import 'dart:math' as math;

import 'package:flutter/rendering.dart';

/// Dibuja el fondo de la constancia de fuente (DESIGN.md §6.4): una línea
/// perforada en el borde superior y dos muescas semicirculares en los extremos,
/// como un talón que se desprende.
///
/// Las muescas se pintan con el color del fondo de la pantalla y quedan centradas
/// sobre el borde del contenedor padre. Por eso la constancia debe ir dentro de un
/// contenedor con `clipBehavior`: la mitad exterior de cada círculo queda recortada
/// y lo que se ve es un "mordisco" en el borde de la tarjeta.
class SourceTicketPainter extends CustomPainter {
  const SourceTicketPainter({
    required this.fillColor,
    required this.perforationColor,
    required this.notchColor,
    required this.notchBorderColor,
    this.notchRadius = 9,
    this.dashLength = 6,
    this.dashGap = 4,
    this.strokeWidth = 1.5,
  });

  /// Fondo del talón (`primaryContainer`).
  final Color fillColor;

  /// Trazos de la línea perforada (`outline`, 3:1 o más sobre el fondo).
  final Color perforationColor;

  /// Relleno de las muescas: el fondo de la pantalla.
  final Color notchColor;

  /// Contorno de las muescas: el mismo color del borde de la tarjeta.
  final Color notchBorderColor;

  final double notchRadius;
  final double dashLength;
  final double dashGap;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = fillColor);
    _paintPerforation(canvas, size.width);
    _paintNotch(canvas, Offset.zero);
    _paintNotch(canvas, Offset(size.width, 0));
  }

  /// Línea discontinua entre las dos muescas.
  void _paintPerforation(Canvas canvas, double width) {
    final paint = Paint()
      ..color = perforationColor
      ..strokeWidth = strokeWidth;

    final end = width - notchRadius - dashGap;
    for (var x = notchRadius + dashGap; x < end; x += dashLength + dashGap) {
      canvas.drawLine(Offset(x, 0), Offset(math.min(x + dashLength, end), 0), paint);
    }
  }

  void _paintNotch(Canvas canvas, Offset center) {
    canvas.drawCircle(center, notchRadius, Paint()..color = notchColor);
    canvas.drawCircle(
      center,
      notchRadius,
      Paint()
        ..color = notchBorderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(SourceTicketPainter oldDelegate) {
    return fillColor != oldDelegate.fillColor ||
        perforationColor != oldDelegate.perforationColor ||
        notchColor != oldDelegate.notchColor ||
        notchBorderColor != oldDelegate.notchBorderColor ||
        notchRadius != oldDelegate.notchRadius ||
        dashLength != oldDelegate.dashLength ||
        dashGap != oldDelegate.dashGap ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}
