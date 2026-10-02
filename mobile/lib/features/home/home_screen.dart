import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/bottom_bar_layout.dart';
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/theme_picker.dart';
import '../chat/chat_controller.dart';
import '../chat/chat_screen.dart';
import '../chat/widgets/question_input_bar.dart';
import 'tramites_rapidos.dart';
import 'widgets/tramites_list.dart';

/// Pantalla de inicio: saludo, lista de trámites y campo para preguntar.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller, required this.tema});

  final ChatController controller;
  final ThemeController tema;

  /// Envía la pregunta y abre la conversación.
  ///
  /// Si ya hay una pregunta en curso, solo abre la conversación para que la
  /// persona vea que se está buscando (no se envían dos a la vez).
  void _preguntar(BuildContext context, String pregunta) {
    if (!controller.esperandoRespuesta) {
      controller.enviar(pregunta);
    }
    _abrirConversacion(context);
  }

  void _abrirConversacion(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ChatScreen(controller: controller)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            BrandMark(),
            SizedBox(width: AppSpacing.md),
            // La barra tiene alto fijo: con letra muy grande, solo el nombre de la
            // app se reduce para caber (el resto del texto respeta la escala).
            Flexible(
              child: FittedBox(fit: BoxFit.scaleDown, child: Text('TramitesIA')),
            ),
          ],
        ),
        actions: [
          ThemeButton(controller: tema),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: BottomBarLayout(
        content: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.sm,
            AppSpacing.screen,
            AppSpacing.xxl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text('Hola, ¿qué trámite quieres hacer?', style: text.headlineMedium),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Pregúntame con tus palabras o elige uno de la lista.',
                    style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  // Si ya hubo preguntas, un acceso para volver a ellas.
                  ListenableBuilder(
                    listenable: controller,
                    builder: (context, _) => controller.turnos.isEmpty
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.lg),
                            child: OutlinedButton.icon(
                              onPressed: () => _abrirConversacion(context),
                              icon: const Icon(Icons.forum_outlined),
                              label: const Text('Ver tu consulta'),
                            ),
                          ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Semantics(
                    header: true,
                    child: Text('Trámites disponibles', style: text.titleLarge),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TramitesList(
                    tramites: tramitesRapidos,
                    onSelect: (tramite) => _preguntar(context, tramite.pregunta),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomBar: ListenableBuilder(
          listenable: controller,
          builder: (context, _) => QuestionInputBar(
            enabled: !controller.esperandoRespuesta,
            onSend: (pregunta) => _preguntar(context, pregunta),
          ),
        ),
      ),
    );
  }
}
