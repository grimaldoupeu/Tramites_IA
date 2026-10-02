import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tema elegido por la persona: automático (según el celular), claro u oscuro.
///
/// Igual que el chat, es un `ChangeNotifier`: `MaterialApp` lo escucha y
/// cambia `themeMode` al instante. La elección se guarda en el celular con
/// shared_preferences, así se mantiene al cerrar la app.
class ThemeController extends ChangeNotifier {
  /// Lee la elección guardada. [prefs] ya está cargado (ver `main.dart`), por
  /// eso la lectura es inmediata y la app no "parpadea" con el tema equivocado.
  ThemeController(this._prefs)
      : _modo = ThemeMode.values.asNameMap()[_prefs.getString(_clave)] ?? ThemeMode.system;

  /// Clave con la que se guarda: "system", "light" o "dark".
  static const _clave = 'tema';

  final SharedPreferences _prefs;
  ThemeMode _modo;

  /// Por defecto, [ThemeMode.system] (automático).
  ThemeMode get modo => _modo;

  Future<void> cambiar(ThemeMode modo) async {
    if (modo == _modo) return;
    _modo = modo;
    notifyListeners(); // se aplica antes de guardar: la persona lo ve al instante
    await _prefs.setString(_clave, modo.name);
  }
}
