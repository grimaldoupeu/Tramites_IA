/// Espaciados, radios, tamaños y duraciones de DESIGN.md (§4, §5 y §8).
library;

/// Escala de espaciado en múltiplos de 4 (densidad baja).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Margen lateral de todas las pantallas.
  static const double screen = xl;
}

/// El radio depende de la jerarquía del elemento, no es uno solo para todo.
abstract final class AppRadius {
  static const double sm = 8; // chips y foco
  static const double md = 14; // botones, campo de texto, lista y constancia
  static const double lg = 22; // burbuja del usuario
  static const double bubbleTail = 6; // esquina que "apunta" a quien habla
  static const double full = 999; // botón circular de enviar
}

abstract final class AppSizes {
  /// Zona tocable mínima.
  static const double minTouch = 48;

  /// Alto de las acciones principales (enviar, reintentar, trámites).
  static const double primaryAction = 56;

  /// Ancho máximo del contenido en pantallas grandes (tablets).
  static const double maxContentWidth = 640;
}

abstract final class AppDurations {
  static const message = Duration(milliseconds: 200);
  static const state = Duration(milliseconds: 150);
  static const typingPulse = Duration(milliseconds: 900);
}
