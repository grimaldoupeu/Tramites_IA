import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tramites_ia/app.dart';
import 'package:tramites_ia/core/theme/theme_controller.dart';
import 'package:tramites_ia/data/services/tramites_api.dart';

// ---------------------------------------------------------------------------
// Utilidades
// ---------------------------------------------------------------------------

const respuestaLarga = '''**Si lo haces por internet:**

1. Ingresa a SUNAT Virtual con tu DNI y crea tu Clave SOL siguiendo las indicaciones de la pantalla.
2. Registra tu número de celular y tu correo electrónico para recibir la confirmación.
3. Guarda tu usuario y tu clave en un lugar seguro.

**Si lo haces de modo presencial:**

- Acércate a un Centro de Servicios al Contribuyente con tu DNI original.''';

http.Response jsonResponse(Object cuerpo, int status) => http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      status,
      headers: {'content-type': 'application/json'},
    );

http.Response respuestaOk({String texto = respuestaLarga, bool conFuentes = true}) => jsonResponse({
      'respuesta': texto,
      'fuentes': [
        if (conFuentes) {'tramite': 'Obtener clave SOL', 'url': 'https://www.gob.pe/393-obtener-clave-sol'},
      ],
    }, 200);

/// Servidor simulado: cada llamada espera a que el test complete su respuesta,
/// así se puede revisar el estado "Buscando…" antes de que llegue.
class ServidorSimulado {
  final pendientes = <Completer<http.Response>>[];

  TramitesApi get api => TramitesApi(
        client: MockClient((_) {
          final c = Completer<http.Response>();
          pendientes.add(c);
          return c.future;
        }),
        baseUrl: 'http://servidor-de-prueba:8000',
      );

  void responder(http.Response r) => pendientes.removeAt(0).complete(r);
  void fallar(Object error) => pendientes.removeAt(0).completeError(error);
}

/// Crea la app con el servidor simulado y preferencias en memoria (sin tema guardado).
Future<Widget> app(TramitesApi api) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return TramitesIaApp(api: api, tema: ThemeController(prefs));
}

/// Configura un celular de 320 × 640 con la escala de letra y el modo indicados.
void celular(
  WidgetTester tester, {
  double escala = 1,
  Brightness brillo = Brightness.light,
  double teclado = 0,
}) {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  tester.view.viewInsets = FakeViewPadding(bottom: teclado);
  tester.platformDispatcher.textScaleFactorTestValue = escala;
  tester.platformDispatcher.platformBrightnessTestValue = brillo;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
}

/// Avanza el tiempo sin esperar a que terminen las animaciones (el indicador
/// "Buscando…" se repite sin fin, así que `pumpAndSettle` no terminaría).
Future<void> avanzar(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> tocarTramite(WidgetTester tester, String nombre) async {
  await tester.ensureVisible(find.text(nombre));
  await tester.pump();
  await tester.tap(find.text(nombre));
  await avanzar(tester); // transición a la pantalla de chat
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('Inicio sin desbordes', () {
    for (final brillo in Brightness.values) {
      for (final escala in [1.0, 2.0]) {
        testWidgets('${brillo.name}, letra al ${(escala * 100).round()} %', (tester) async {
          celular(tester, escala: escala, brillo: brillo);
          await tester.pumpWidget(await app(ServidorSimulado().api));
          expect(tester.takeException(), isNull);
          expect(find.text('Trámites disponibles'), findsOneWidget);
          expect(
            find.text('Información referencial. Verifica siempre en la fuente oficial.'),
            findsOneWidget,
          );
        });
      }
    }

    testWidgets('letra al 200 % con el teclado abierto', (tester) async {
      celular(tester, escala: 2, teclado: 300);
      await tester.pumpWidget(await app(ServidorSimulado().api));
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('el botón de enviar se activa solo con 3 caracteres o más', (tester) async {
    celular(tester);
    await tester.pumpWidget(await app(ServidorSimulado().api));
    IconButton enviar() => tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.send_rounded));

    expect(enviar().onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'ru');
    await tester.pump();
    expect(enviar().onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'ruc?');
    await tester.pump();
    expect(enviar().onPressed, isNotNull);
  });

  testWidgets('tocar un trámite: Buscando… y luego respuesta con fuente', (tester) async {
    celular(tester);
    final servidor = ServidorSimulado();
    await tester.pumpWidget(await app(servidor.api));

    await tocarTramite(tester, 'Obtener Clave SOL');
    expect(find.text('¿Cómo obtengo mi Clave SOL?'), findsOneWidget);
    expect(find.text('Buscando en fuentes oficiales…'), findsOneWidget);

    servidor.responder(respuestaOk());
    await avanzar(tester);

    expect(find.text('Buscando en fuentes oficiales…'), findsNothing);
    expect(find.text('Respuesta de TramitesIA'), findsOneWidget);
    expect(find.text('Fuente oficial consultada', skipOffstage: false), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('respuesta larga sin desbordes: oscuro y letra al 200 %', (tester) async {
    celular(tester, escala: 2, brillo: Brightness.dark);
    final servidor = ServidorSimulado();
    await tester.pumpWidget(await app(servidor.api));

    await tocarTramite(tester, 'Inscripción en el RUC');
    servidor.responder(respuestaOk());
    await avanzar(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sin información: no se muestra la constancia', (tester) async {
    celular(tester);
    final servidor = ServidorSimulado();
    await tester.pumpWidget(await app(servidor.api));

    await tocarTramite(tester, 'Devolución de impuestos');
    servidor.responder(respuestaOk(texto: 'No tengo información sobre eso.', conFuentes: false));
    await avanzar(tester);

    expect(find.text('No tengo información sobre eso.'), findsOneWidget);
    expect(find.textContaining('Fuente', skipOffstage: false), findsNothing);
  });

  testWidgets('sin conexión: mensaje claro y Reintentar funciona', (tester) async {
    celular(tester);
    final servidor = ServidorSimulado();
    await tester.pumpWidget(await app(servidor.api));

    await tocarTramite(tester, 'Obtener Clave SOL');
    servidor.fallar(http.ClientException('Connection refused'));
    await avanzar(tester);

    expect(find.text('No se pudo conectar'), findsOneWidget);
    expect(find.text('Revisa tu conexión a internet e inténtalo de nuevo.'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await avanzar(tester);
    expect(find.text('Buscando en fuentes oficiales…'), findsOneWidget);

    servidor.responder(respuestaOk());
    await avanzar(tester);
    expect(find.text('No se pudo conectar'), findsNothing);
    expect(find.text('Respuesta de TramitesIA'), findsOneWidget);
  });

  testWidgets('servidor saturado (503): aviso de servicio ocupado', (tester) async {
    celular(tester);
    final servidor = ServidorSimulado();
    await tester.pumpWidget(await app(servidor.api));

    await tocarTramite(tester, 'Obtener Clave SOL');
    servidor.responder(jsonResponse({'detail': 'ocupado'}, 503));
    await avanzar(tester);

    expect(find.text('El servicio está ocupado'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });
}
