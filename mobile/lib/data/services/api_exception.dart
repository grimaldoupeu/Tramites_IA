/// Errores al hablar con el backend. Son `sealed` para que la interfaz trate
/// todos los casos con un `switch` (DESIGN.md §6.6 define un mensaje para cada uno).
sealed class ApiException implements Exception {
  const ApiException();
}

/// No se pudo llegar al servidor: sin internet, IP equivocada o backend apagado.
class SinConexionException extends ApiException {
  const SinConexionException();
}

/// El modelo de IA está saturado (el backend respondió 503 o tardó más que el
/// tiempo de espera). Es temporal.
class ServicioOcupadoException extends ApiException {
  const ServicioOcupadoException({this.reintentarEn});

  /// Segundos sugeridos por el servidor (cabecera `Retry-After`), si los envió.
  final Duration? reintentarEn;
}

/// Cualquier otra respuesta inesperada (502, 422, JSON inválido...).
class ErrorServidorException extends ApiException {
  const ErrorServidorException(this.detalle);

  /// Detalle técnico para los logs; no se muestra a la persona.
  final String detalle;
}
