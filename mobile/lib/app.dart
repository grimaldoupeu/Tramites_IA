import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'data/services/tramites_api.dart';
import 'features/chat/chat_controller.dart';
import 'features/home/home_screen.dart';

/// Raíz de la app: el tema elegido (automático, claro u oscuro) y el estado del chat.
///
/// No se fija `textScaler`: la app respeta el tamaño de letra que la persona
/// eligió en su celular (DESIGN.md §3).
class TramitesIaApp extends StatefulWidget {
  /// [api] se puede reemplazar en los tests por una con servidor simulado.
  const TramitesIaApp({super.key, required this.tema, this.api});

  final ThemeController tema;
  final TramitesApi? api;

  @override
  State<TramitesIaApp> createState() => _TramitesIaAppState();
}

class _TramitesIaAppState extends State<TramitesIaApp> {
  // Un solo controlador para toda la app: Inicio y Chat comparten la conversación.
  late final _chat = ChatController(widget.api ?? TramitesApi());

  @override
  void dispose() {
    _chat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Al cambiar el tema, solo se reconstruye MaterialApp con el nuevo themeMode;
    // los colores siguen siendo los de AppTheme (DESIGN.md).
    return ListenableBuilder(
      listenable: widget.tema,
      builder: (context, _) => MaterialApp(
        title: 'TramitesIA',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: widget.tema.modo,
        home: HomeScreen(controller: _chat, tema: widget.tema),
      ),
    );
  }
}
