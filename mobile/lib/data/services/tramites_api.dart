import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../../core/config/api_config.dart';
import '../models/respuesta.dart';
import 'api_exception.dart';

/// Cliente del backend de TramitesIA.
///
/// Convierte cualquier fallo de red o del servidor en una [ApiException], así la
/// interfaz nunca recibe errores técnicos de `http` o de `dart:io`.
class TramitesApi {
  /// [client] se puede reemplazar en los tests por un `MockClient`.
  TramitesApi({
    http.Client? client,
    String baseUrl = ApiConfig.baseUrl,
    this.timeout = ApiConfig.timeout,
  })  : _client = client ?? _clienteConTimeoutDeConexion(),
        _baseUri = Uri.parse(baseUrl);

  /// Separa dos esperas distintas:
  /// - conectar (10 s): si falla, el servidor no es alcanzable (IP equivocada,
  ///   backend apagado) y se informa "sin conexión" sin hacer esperar 90 s;
  /// - responder ([timeout]): el servidor existe pero la IA tarda.
  static http.Client _clienteConTimeoutDeConexion() {
    return IOClient(HttpClient()..connectionTimeout = ApiConfig.connectionTimeout);
  }

  final http.Client _client;
  final Uri _baseUri;
  final Duration timeout;

  /// Envía la pregunta a `POST /preguntar` y devuelve la respuesta con sus fuentes.
  ///
  /// Lanza [SinConexionException], [ServicioOcupadoException] o
  /// [ErrorServidorException].
  Future<Respuesta> preguntar(String pregunta) async {
    final http.Response response;
    try {
      response = await _client
          .post(
            _baseUri.resolve('/preguntar'),
            headers: const {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode({'pregunta': pregunta}),
          )
          .timeout(timeout);
    } on TimeoutException {
      // El servidor sí respondió a la conexión pero tardó demasiado (Gemini
      // saturado): decir "revisa tu internet" sería falso.
      throw const ServicioOcupadoException();
    } on SocketException {
      throw const SinConexionException();
    } on http.ClientException {
      throw const SinConexionException();
    }

    switch (response.statusCode) {
      case 200:
        return _leerRespuesta(response);
      case 503:
        throw ServicioOcupadoException(reintentarEn: _retryAfter(response));
      default:
        throw ErrorServidorException('HTTP ${response.statusCode}: ${_texto(response)}');
    }
  }

  Respuesta _leerRespuesta(http.Response response) {
    try {
      return Respuesta.fromJson(jsonDecode(_texto(response)) as Map<String, dynamic>);
    } on Object catch (error) {
      // FormatException (no es JSON) o TypeError (faltan campos o tipos distintos)
      throw ErrorServidorException('Respuesta con formato inesperado: $error');
    }
  }

  /// Decodifica siempre como UTF-8. `response.body` usaría latin1 si el servidor
  /// no declara el charset, y las tildes y la ñ llegarían rotas.
  String _texto(http.Response response) => utf8.decode(response.bodyBytes);

  Duration? _retryAfter(http.Response response) {
    final segundos = int.tryParse(response.headers['retry-after'] ?? '');
    return segundos == null ? null : Duration(seconds: segundos);
  }

  /// Libera las conexiones abiertas. Llamar cuando la app ya no use el cliente.
  void close() => _client.close();
}
