import 'package:flutter_test/flutter_test.dart';
import 'package:tramites_ia/core/utils/fechas.dart';

void main() {
  test('fecha larga en español', () {
    expect(fechaLarga(DateTime(2026, 10, 2)), '2 de octubre de 2026');
    expect(fechaLarga(DateTime(2027, 1, 31)), '31 de enero de 2027');
    expect(fechaLarga(DateTime(2026, 12, 1)), '1 de diciembre de 2026');
  });
}
