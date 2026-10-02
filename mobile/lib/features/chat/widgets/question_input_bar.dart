import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_tokens.dart';
import '../chat_controller.dart';

/// Barra inferior de Inicio y Chat: el aviso permanente (DESIGN.md §6.7) y el
/// campo de pregunta con su botón de enviar (§6.5).
class QuestionInputBar extends StatefulWidget {
  const QuestionInputBar({super.key, required this.onSend, this.enabled = true});

  /// Recibe la pregunta ya validada (entre 3 y 1000 caracteres).
  final ValueChanged<String> onSend;

  /// `false` mientras se espera una respuesta: se puede escribir, pero no enviar.
  final bool enabled;

  @override
  State<QuestionInputBar> createState() => _QuestionInputBarState();
}

class _QuestionInputBarState extends State<QuestionInputBar> {
  final _texto = TextEditingController();

  bool get _puedeEnviar => widget.enabled && ChatController.esPreguntaValida(_texto.text);

  @override
  void initState() {
    super.initState();
    _texto.addListener(() => setState(() {})); // activa o desactiva el botón
  }

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  void _enviar() {
    if (!_puedeEnviar) return;
    widget.onSend(_texto.text.trim());
    _texto.clear();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      // Está "encima" del chat: es lo único con sombra (DESIGN.md §5).
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
        boxShadow: [
          BoxShadow(color: scheme.shadow.withValues(alpha: 0.08), blurRadius: 14, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DisclaimerNotice(),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _texto,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _enviar(),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(ChatController.longitudMaxima),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Escribe tu pregunta',
                      hintText: 'Ej.: ¿Cómo saco mi Clave SOL?',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _SendButton(onPressed: _puedeEnviar ? _enviar : null),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed,
      tooltip: 'Enviar pregunta', // también es la etiqueta para el lector de pantalla
      iconSize: 24,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(AppSizes.primaryAction),
        shape: const CircleBorder(),
      ),
      icon: const Icon(Icons.send_rounded),
    );
  }
}

/// "Información referencial. Verifica siempre en la fuente oficial."
/// Discreto pero siempre visible; no se puede cerrar.
class DisclaimerNotice extends StatelessWidget {
  const DisclaimerNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(child: Icon(Icons.info_outline_rounded, size: 20, color: color)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Información referencial. Verifica siempre en la fuente oficial.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
