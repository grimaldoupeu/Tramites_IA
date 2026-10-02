import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  // Necesario para usar plugins (shared_preferences) antes de runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Se lee el tema guardado ANTES de mostrar la app, para que el primer cuadro
  // ya salga con el tema elegido (sin un destello del tema equivocado).
  final prefs = await SharedPreferences.getInstance();

  runApp(TramitesIaApp(tema: ThemeController(prefs)));
}
