/// Configuración de la conexión con el backend.
///
/// La URL se define al compilar, sin tocar el código:
///
///     flutter run --dart-define=API_URL=http://192.168.1.50:8000
///
/// Si no se indica, se usa `http://10.0.2.2:8000`: la dirección con la que el
/// emulador de Android llega al `localhost` de la PC. En un celular físico hay
/// que pasar la IP de la PC en la red Wi-Fi.
abstract final class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  /// Tiempo máximo de espera de una respuesta. Es amplio porque el backend
  /// reintenta con Gemini (y su modelo de respaldo) antes de rendirse: en las
  /// pruebas, una pregunta tardó 30 s y otra superó los 60 s.
  static const timeout = Duration(seconds: 90);

  /// Tiempo máximo para establecer la conexión. Si se supera, el servidor no es
  /// alcanzable (IP equivocada, otra red Wi-Fi o backend apagado).
  static const connectionTimeout = Duration(seconds: 10);
}
