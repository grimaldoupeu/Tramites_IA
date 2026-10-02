import 'package:flutter/painting.dart';

/// Colores base de DESIGN.md (§2).
///
/// Es el único archivo de la app con valores hexadecimales. Los widgets nunca
/// usan esta clase directamente: leen los colores con `Theme.of(context)`.
abstract final class AppPalette {
  // --- Modo claro ---
  static const granate = Color(0xFF7A1F2B);
  static const granateProfundo = Color(0xFF5E1A25);
  static const tinta = Color(0xFF1C1B1F);
  static const piedra = Color(0xFF5A5560);
  static const papel = Color(0xFFF7F6F7);
  static const blanco = Color(0xFFFFFFFF);
  static const constanciaClaro = Color(0xFFFBF0F1);
  static const maiz = Color(0xFFE8B23A); // solo fondo de avisos (1,8:1 sobre Papel)
  static const maizTostado = Color(0xFF8C6200); // indicador "buscando" (5,0:1)
  static const ladrillo = Color(0xFFB93A06); // errores
  static const errorContenedorClaro = Color(0xFFFFF1EA);
  static const contornoClaro = Color(0xFF8A8490);
  static const divisorClaro = Color(0xFFE3DEE2);

  // --- Modo oscuro ---
  static const granateAclarado = Color(0xFFF2A9B0);
  static const sobreGranateAclarado = Color(0xFF3B0A12);
  static const fondoOscuro = Color(0xFF17141A);
  static const superficieOscura = Color(0xFF221E25);
  static const textoOscuro = Color(0xFFF3EFF4);
  static const textoSecundarioOscuro = Color(0xFFBDB5C0);
  static const constanciaOscuro = Color(0xFF2E1C21);
  static const sobreConstanciaOscuro = Color(0xFFF8D9DC);
  static const maizOscuro = Color(0xFFF0C35A);
  static const errorOscuro = Color(0xFFFFB59A);
  static const errorContenedorOscuro = Color(0xFF4A1E0C);
  static const sobreErrorContenedorOscuro = Color(0xFFFFD9CC);
  static const contornoOscuro = Color(0xFF8F8794);
  static const divisorOscuro = Color(0xFF3D3742);
}
