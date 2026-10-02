import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tramites_ia/data/services/api_exception.dart';
import 'package:tramites_ia/data/services/tramites_api.dart';

/// Crea la API con un servidor simulado que responde con [handler].
TramitesApi apiCon(
  MockClientHandler handler, {
  Duration timeout = const Duration(seconds: 5),
}) {
  return TramitesApi(
    client: MockClient(handler),
    baseUrl: 'http://servidor-de-prueba:8000',
    timeout: timeout,
  );
}

/// Respuesta JSON en UTF-8 y SIN charset en la cabecera (el peor caso para las tildes).
http.Response json(Object cuerpo, int status, {Map<String, String> headers = const {}}) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(cuerpo)),
    status,
    headers: {'content-type': 'application/json', ...headers},
  );
}

void main() {
  test('envía la pregunta y lee respuesta y fuentes, con tildes intactas', () async {
    late http.Request enviada;
    final api = apiCon((request) async {
      enviada = request;
      return json({
        'respuesta': 'Necesitas tu DNI y la dirección de tu domicilio.',
        'fuentes': [
          {
            'tramite': 'Inscripción en el RUC',
            'url': 'https://www.gob.pe/284-inscripcion-en-el-ruc',
            'fecha_extraccion': '2026-10-02',
          },
        ],
      }, 200);
    });

    final respuesta = await api.preguntar('¿Qué necesito para el RUC?');

    expect(enviada.method, 'POST');
    expect(enviada.url.toString(), 'http://servidor-de-prueba:8000/preguntar');
    expect(jsonDecode(enviada.body), {'pregunta': '¿Qué necesito para el RUC?'});
    expect(respuesta.texto, 'Necesitas tu DNI y la dirección de tu domicilio.');
    expect(respuesta.fuentes.single.tramite, 'Inscripción en el RUC');
    expect(respuesta.fuentes.single.dominio, 'gob.pe');
    expect(respuesta.fuentes.single.fechaExtraccion, DateTime(2026, 10, 2));
  });

  test('una fuente sin fecha_extraccion se lee igual (la fecha queda vacía)', () async {
    final api = apiCon((_) async => json({
          'respuesta': 'Texto.',
          'fuentes': [
            {'tramite': 'Obtener clave SOL', 'url': 'https://www.gob.pe/393-obtener-clave-sol'},
          ],
        }, 200));
    expect((await api.preguntar('¿Clave SOL?')).fuentes.single.fechaExtraccion, isNull);
  });

  test('sin fuentes cuando no hay información', () async {
    final api = apiCon((_) async => json({'respuesta': 'No tengo información sobre eso.', 'fuentes': []}, 200));
    expect((await api.preguntar('¿Cuánto cuesta el pasaporte?')).fuentes, isEmpty);
  });

  test('503 se convierte en ServicioOcupadoException con Retry-After', () async {
    final api = apiCon((_) async => json({'detail': 'ocupado'}, 503, headers: {'retry-after': '10'}));
    await expectLater(
      api.preguntar('hola'),
      throwsA(isA<ServicioOcupadoException>()
          .having((e) => e.reintentarEn, 'reintentarEn', const Duration(seconds: 10))),
    );
  });

  test('502 se convierte en ErrorServidorException', () async {
    final api = apiCon((_) async => json({'detail': 'error'}, 502));
    await expectLater(api.preguntar('hola'), throwsA(isA<ErrorServidorException>()));
  });

  test('JSON con formato inesperado se convierte en ErrorServidorException', () async {
    final api = apiCon((_) async => http.Response('<html>proxy</html>', 200));
    await expectLater(api.preguntar('hola'), throwsA(isA<ErrorServidorException>()));
  });

  test('servidor inalcanzable se convierte en SinConexionException', () async {
    final api = apiCon((_) async => throw http.ClientException('Connection refused'));
    await expectLater(api.preguntar('hola'), throwsA(isA<SinConexionException>()));
  });

  test('tiempo agotado se convierte en ServicioOcupadoException (el servidor sí existe)', () async {
    final api = apiCon(
      (_) => Future.delayed(const Duration(seconds: 1), () => json({}, 200)),
      timeout: const Duration(milliseconds: 50),
    );
    await expectLater(api.preguntar('hola'), throwsA(isA<ServicioOcupadoException>()));
  });
}
