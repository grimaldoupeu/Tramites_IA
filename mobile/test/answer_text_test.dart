import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tramites_ia/core/theme/app_theme.dart';
import 'package:tramites_ia/features/chat/widgets/answer_text.dart';

/// Nivel y texto de cada bloque, para comparar resultados de forma legible.
List<(int, String)> niveles(String texto) => [
      for (final b in parsearBloques(texto))
        (b.nivel, switch (b) { Parrafo(:final texto) => texto, ItemLista(:final texto) => texto }),
    ];

const respuestaAnidada = '''
**Si lo haces por internet:**

1. Ingresa a SUNAT Virtual con tu DNI.
   - Si no tienes clave, créala primero.
   - Ten a la mano tu correo:
     - personal o
     - del trabajo.
2. Registra tu actividad económica.
   Puedes buscarla en la lista CIIU.
3. Elige tu régimen tributario.''';

void main() {
  group('formato básico', () {
    test('separa párrafos, listas numeradas y viñetas', () {
      final bloques = parsearBloques('''
**Si lo haces por internet:**

1. Tu DNI.
2) Tu correo.
- Un recibo de luz.
''');

      expect(bloques, hasLength(4));
      expect((bloques[0] as Parrafo).texto, '**Si lo haces por internet:**');
      expect((bloques[1] as ItemLista).marcador, '1.');
      expect((bloques[1] as ItemLista).texto, 'Tu DNI.');
      expect((bloques[2] as ItemLista).marcador, '2.');
      expect((bloques[3] as ItemLista).marcador, '•');
    });

    test('una línea que empieza con negrita no se confunde con viñeta', () {
      expect(parsearBloques('**Importante:** lleva tu DNI.').single, isA<Parrafo>());
    });
  });

  group('listas anidadas', () {
    test('cada sublista toma el nivel de su sangría', () {
      expect(niveles(respuestaAnidada), [
        (0, '**Si lo haces por internet:**'),
        (0, 'Ingresa a SUNAT Virtual con tu DNI.'),
        (1, 'Si no tienes clave, créala primero.'),
        (1, 'Ten a la mano tu correo:'),
        (2, 'personal o'),
        (2, 'del trabajo.'),
        (0, 'Registra tu actividad económica.'), // vuelve al nivel principal
        (1, 'Puedes buscarla en la lista CIIU.'), // aclaración bajo el paso 2
        (0, 'Elige tu régimen tributario.'),
      ]);
    });

    test('funciona igual con 2 espacios, 4 espacios o tabuladores', () {
      const esperado = [(0, 'Paso'), (1, 'Detalle'), (2, 'Más detalle'), (0, 'Otro paso')];
      expect(niveles('1. Paso\n  - Detalle\n    - Más detalle\n2. Otro paso'), esperado);
      expect(niveles('1. Paso\n    - Detalle\n        - Más detalle\n2. Otro paso'), esperado);
      expect(niveles('1. Paso\n\t- Detalle\n\t\t- Más detalle\n2. Otro paso'), esperado);
    });

    test('una línea vacía dentro de la lista no la cierra', () {
      expect(niveles('1. Paso\n\n   - Detalle'), [(0, 'Paso'), (1, 'Detalle')]);
    });

    test('las viñetas de niveles impares usan otro símbolo', () {
      final marcadores = parsearBloques('- Uno\n  - Dos\n    - Tres')
          .map((b) => (b as ItemLista).marcador)
          .toList();
      expect(marcadores, ['•', '◦', '•']);
    });

    test('una lista que empieza sangrada se trata como nivel principal', () {
      expect(niveles('  1. Paso\n  2. Otro'), [(0, 'Paso'), (0, 'Otro')]);
    });
  });

  group('dibujo', () {
    Future<void> montar(WidgetTester tester, {double escala = 1}) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery.withClampedTextScaling(
          minScaleFactor: escala,
          maxScaleFactor: escala,
          child: const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: AnswerText(respuestaAnidada),
            ),
          ),
        ),
      ));
    }

    double izquierda(WidgetTester tester, String texto) =>
        tester.getTopLeft(find.text(texto, findRichText: true)).dx;

    testWidgets('cada nivel queda más a la derecha que el anterior', (tester) async {
      await montar(tester);

      final nivel0 = izquierda(tester, 'Ingresa a SUNAT Virtual con tu DNI.');
      final nivel1 = izquierda(tester, 'Si no tienes clave, créala primero.');
      final nivel2 = izquierda(tester, 'personal o');

      expect(nivel1, greaterThan(nivel0));
      expect(nivel2, greaterThan(nivel1));
      // Los ítems hermanos quedan alineados entre sí.
      expect(izquierda(tester, 'Ten a la mano tu correo:'), nivel1);
      expect(izquierda(tester, 'Registra tu actividad económica.'), nivel0);
      // La aclaración bajo un paso se alinea con el texto de ese paso.
      expect(izquierda(tester, 'Puedes buscarla en la lista CIIU.'), nivel0);
    });

    testWidgets('sin desbordes con la letra al 200 %', (tester) async {
      await montar(tester, escala: 2);
      expect(tester.takeException(), isNull);
    });
  });
}
