import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tramites_ia/app.dart';
import 'package:tramites_ia/core/theme/theme_controller.dart';
import 'package:tramites_ia/data/services/tramites_api.dart';
import 'package:tramites_ia/features/home/home_screen.dart';

/// Preferencias en memoria con los valores iniciales dados.
Future<SharedPreferences> preferencias([Map<String, Object> valores = const {}]) async {
  SharedPreferences.setMockInitialValues(valores);
  return SharedPreferences.getInstance();
}

/// Monta la app (sin backend real) con el celular en el modo indicado.
Future<ThemeController> montarApp(
  WidgetTester tester, {
  Map<String, Object> guardado = const {},
  Brightness celular = Brightness.light,
  double escala = 1,
}) async {
  tester.platformDispatcher.platformBrightnessTestValue = celular;
  tester.platformDispatcher.textScaleFactorTestValue = escala;
  addTearDown(tester.platformDispatcher.clearAllTestValues);

  final tema = ThemeController(await preferencias(guardado));
  final api = TramitesApi(client: MockClient((_) async => http.Response('{}', 500)));
  await tester.pumpWidget(TramitesIaApp(tema: tema, api: api));
  return tema;
}

Brightness brilloActual(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(HomeScreen))).brightness;

void main() {
  group('ThemeController', () {
    test('por defecto es automático', () async {
      expect(ThemeController(await preferencias()).modo, ThemeMode.system);
    });

    test('lee la elección guardada', () async {
      expect(ThemeController(await preferencias({'tema': 'dark'})).modo, ThemeMode.dark);
    });

    test('un valor guardado desconocido vuelve a automático', () async {
      expect(ThemeController(await preferencias({'tema': 'morado'})).modo, ThemeMode.system);
    });

    test('al cambiar, avisa a quien escucha y guarda la elección', () async {
      final prefs = await preferencias();
      final tema = ThemeController(prefs);
      var avisos = 0;
      tema.addListener(() => avisos++);

      await tema.cambiar(ThemeMode.light);

      expect(tema.modo, ThemeMode.light);
      expect(avisos, 1);
      expect(prefs.getString('tema'), 'light');
    });
  });

  group('selector en la pantalla de inicio', () {
    testWidgets('el botón tiene etiqueta "Cambiar tema" y mide al menos 48 dp', (tester) async {
      final semantica = tester.ensureSemantics(); // activa el árbol que lee TalkBack
      await montarApp(tester);

      final boton = find.byTooltip('Cambiar tema');
      expect(boton, findsOneWidget);
      final tamano = tester.getSize(find.descendant(of: boton, matching: find.byType(IconButton)));
      expect(tamano.width, greaterThanOrEqualTo(48));
      expect(tamano.height, greaterThanOrEqualTo(48));
      expect(find.bySemanticsLabel('Cambiar tema'), findsOneWidget);
      semantica.dispose();
    });

    testWidgets('la hoja muestra las tres opciones con Automático marcado', (tester) async {
      await montarApp(tester);
      await tester.tap(find.byTooltip('Cambiar tema'));
      await tester.pumpAndSettle();

      expect(find.text('Tema de la app'), findsOneWidget);
      expect(find.text('Automático (según el celular)'), findsOneWidget);
      expect(find.text('Claro'), findsOneWidget);
      expect(find.text('Oscuro'), findsOneWidget);

      final marcada = tester.widget<RadioGroup<ThemeMode>>(find.byType(RadioGroup<ThemeMode>));
      expect(marcada.groupValue, ThemeMode.system);
    });

    testWidgets('elegir Oscuro aplica el tema, cierra la hoja y lo guarda', (tester) async {
      final tema = await montarApp(tester, celular: Brightness.light);
      expect(brilloActual(tester), Brightness.light);

      await tester.tap(find.byTooltip('Cambiar tema'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Oscuro'));
      await tester.pumpAndSettle();

      expect(find.text('Tema de la app'), findsNothing); // la hoja se cerró
      expect(tema.modo, ThemeMode.dark);
      expect(brilloActual(tester), Brightness.dark);
      expect((await SharedPreferences.getInstance()).getString('tema'), 'dark');
    });

    testWidgets('al reabrir la app se respeta lo guardado aunque el celular esté en otro modo',
        (tester) async {
      await montarApp(tester, guardado: {'tema': 'light'}, celular: Brightness.dark);
      expect(brilloActual(tester), Brightness.light);
    });

    testWidgets('Automático sigue al celular', (tester) async {
      await montarApp(tester, celular: Brightness.dark);
      expect(brilloActual(tester), Brightness.dark);
    });

    testWidgets('la hoja no se desborda con la letra al 200 % en un celular pequeño',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await montarApp(tester, escala: 2);
      await tester.tap(find.byTooltip('Cambiar tema'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Oscuro', skipOffstage: false), findsOneWidget);
    });
  });
}
