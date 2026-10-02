import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tramites_ia/app.dart';
import 'package:tramites_ia/core/theme/theme_controller.dart';
import 'package:tramites_ia/data/services/tramites_api.dart';
import 'package:tramites_ia/features/home/tramites_rapidos.dart';

/// Monta la app en un celular de 360 × 740 (sin backend real).
Future<void> montarInicio(WidgetTester tester, {double escala = 1}) async {
  tester.view.physicalSize = const Size(360, 740);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = escala;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);

  SharedPreferences.setMockInitialValues({});
  final tema = ThemeController(await SharedPreferences.getInstance());
  // El servidor simulado nunca responde: estos tests solo revisan Inicio.
  final api = TramitesApi(
    client: MockClient((_) => Completer<http.Response>().future),
    timeout: const Duration(seconds: 2), // corto, para no dejar temporizadores pendientes
  );
  await tester.pumpWidget(TramitesIaApp(tema: tema, api: api));
}

/// Posición vertical del encabezado de una entidad (su descripción es única).
double alturaDeSeccion(WidgetTester tester, EntidadTramites entidad) =>
    tester.getTopLeft(find.text(entidad.descripcion)).dy;

void main() {
  testWidgets('muestra las tres entidades con todos sus trámites', (tester) async {
    await montarInicio(tester);

    for (final entidad in entidades) {
      expect(find.text(entidad.descripcion, skipOffstage: false), findsOneWidget);
      for (final tramite in entidad.tramites) {
        expect(find.text(tramite.nombre, skipOffstage: false), findsOneWidget);
      }
    }
    expect(entidades.expand((e) => e.tramites), hasLength(17));
  });

  testWidgets('las secciones aparecen en orden: SUNAT, RENIEC, SUNARP', (tester) async {
    await montarInicio(tester);
    final alturas = [
      for (final e in entidades)
        tester.getTopLeft(find.text(e.descripcion, skipOffstage: false)).dy,
    ];
    expect(alturas, orderedEquals([...alturas]..sort()));
    expect(entidades.map((e) => e.sigla), ['SUNAT', 'RENIEC', 'SUNARP']);
  });

  testWidgets('los chips miden al menos 48 dp de alto para tocarlos', (tester) async {
    await montarInicio(tester);
    for (final chip in tester.widgetList(find.byType(ActionChip))) {
      expect(tester.getSize(find.byWidget(chip)).height, greaterThanOrEqualTo(48));
    }
  });

  for (final entidad in entidades) {
    testWidgets('el chip ${entidad.sigla} lleva a su sección', (tester) async {
      await montarInicio(tester);

      await tester.tap(find.widgetWithText(ActionChip, entidad.sigla));
      await tester.pumpAndSettle();

      // El encabezado queda visible, cerca de la parte superior del contenido.
      final y = alturaDeSeccion(tester, entidad);
      expect(y, greaterThan(0));
      expect(y, lessThan(250));
    });
  }

  testWidgets('tocar un trámite de RENIEC envía su pregunta al chat', (tester) async {
    await montarInicio(tester);
    final duplicado = entidades[1].tramites.first;

    await tester.tap(find.widgetWithText(ActionChip, 'RENIEC'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(duplicado.nombre));
    await tester.pumpAndSettle();
    await tester.tap(find.text(duplicado.nombre));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100)); // "Buscando…" no termina
    }

    expect(find.text(duplicado.pregunta), findsOneWidget);
    expect(find.text('Buscando en fuentes oficiales…'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3)); // deja vencer la espera simulada
  });

  testWidgets('con la letra al 200 % no hay desbordes y los chips siguen funcionando',
      (tester) async {
    await montarInicio(tester, escala: 2);
    expect(tester.takeException(), isNull);

    await tester.tap(find.widgetWithText(ActionChip, 'SUNARP'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text(entidades[2].descripcion), findsOneWidget);
  });
}
