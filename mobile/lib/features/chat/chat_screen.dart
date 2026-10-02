import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/widgets/bottom_bar_layout.dart';
import '../../core/widgets/fade_in.dart';
import '../../data/models/fuente.dart';
import 'chat_controller.dart';
import 'turno.dart';
import 'widgets/answer_card.dart';
import 'widgets/question_input_bar.dart';
import 'widgets/turn_status_card.dart';
import 'widgets/typing_indicator.dart';
import 'widgets/user_bubble.dart';

/// Pantalla de conversación: preguntas, respuestas con sus fuentes y estados.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.controller});

  final ChatController controller;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scroll = ScrollController();

  /// Clave de cada turno, para poder desplazarse hasta él.
  final _claves = <int, GlobalKey>{};

  /// Estado anterior de cada turno, para detectar cuándo llega una respuesta.
  final _estadosPrevios = <int, Type>{};

  ChatController get _chat => widget.controller;

  @override
  void initState() {
    super.initState();
    _recordarEstados();
    _chat.addListener(_alCambiarConversacion);
    // Al abrir la pantalla, mostrar lo último de la conversación.
    WidgetsBinding.instance.addPostFrameCallback((_) => _irAlFinal(animado: false));
  }

  @override
  void dispose() {
    _chat.removeListener(_alCambiarConversacion);
    _scroll.dispose();
    super.dispose();
  }

  void _recordarEstados() {
    for (final t in _chat.turnos) {
      _estadosPrevios[t.id] = t.estado.runtimeType;
    }
  }

  /// Decide a dónde desplazarse después de cada cambio:
  /// - pregunta nueva, reintento o error: al final, para ver "Buscando…" o el
  ///   botón "Reintentar";
  /// - llegó la respuesta: al inicio de ese turno, para leerla desde el principio.
  void _alCambiarConversacion() {
    Turno? recienRespondido;
    var irAlFinal = false;

    for (final t in _chat.turnos) {
      final antes = _estadosPrevios[t.id];
      final empezoACargar = antes != Cargando && t.estado is Cargando;
      final terminoDeCargar = antes == Cargando && t.estado is! Cargando;

      if (antes == null || empezoACargar || (terminoDeCargar && t.estado is Fallido)) {
        irAlFinal = true;
      } else if (terminoDeCargar) {
        recienRespondido = t;
      }
    }
    _recordarEstados();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (irAlFinal) {
        _irAlFinal(animado: true);
      } else if (recienRespondido != null) {
        final contexto = _claves[recienRespondido.id]?.currentContext;
        if (contexto != null) {
          Scrollable.ensureVisible(
            contexto,
            duration: _duracion(AppDurations.message),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  void _irAlFinal({required bool animado}) {
    if (!_scroll.hasClients) return;
    final destino = _scroll.position.maxScrollExtent;
    if (animado) {
      _scroll.animateTo(destino, duration: _duracion(AppDurations.message), curve: Curves.easeOut);
    } else {
      _scroll.jumpTo(destino);
    }
  }

  /// Sin animación si la persona activó "reducir animaciones".
  Duration _duracion(Duration normal) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : normal;

  Future<void> _abrirFuente(Fuente fuente) async {
    var abierta = false;
    try {
      abierta = await launchUrl(Uri.parse(fuente.url), mode: LaunchMode.externalApplication);
    } on Exception {
      abierta = false;
    }
    if (!abierta && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir la página. Dirección: ${fuente.url}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tu consulta')),
      body: BottomBarLayout(
        content: ListenableBuilder(
          listenable: _chat,
          builder: (context, _) => _buildConversacion(),
        ),
        bottomBar: ListenableBuilder(
          listenable: _chat,
          builder: (context, _) => QuestionInputBar(
            enabled: !_chat.esperandoRespuesta,
            onSend: _chat.enviar,
          ),
        ),
      ),
    );
  }

  Widget _buildConversacion() {
    final turnos = _chat.turnos;

    return LayoutBuilder(
      builder: (context, constraints) {
        // En tablets el contenido se centra con un ancho máximo legible.
        final margen = math.max(
          AppSpacing.screen,
          (constraints.maxWidth - AppSizes.maxContentWidth) / 2,
        );

        return ListView.separated(
          controller: _scroll,
          padding: EdgeInsets.symmetric(horizontal: margen, vertical: AppSpacing.xl),
          itemCount: turnos.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xxl),
          itemBuilder: (context, i) {
            final turno = turnos[i];
            return KeyedSubtree(
              key: _claves.putIfAbsent(turno.id, GlobalKey.new),
              child: _TurnoView(
                turno: turno,
                onRetry: () => _chat.reintentar(turno.id),
                onOpenFuente: _abrirFuente,
              ),
            );
          },
        );
      },
    );
  }
}

/// Un turno: la pregunta y, debajo, lo que corresponda a su estado.
class _TurnoView extends StatelessWidget {
  const _TurnoView({required this.turno, required this.onRetry, required this.onOpenFuente});

  final Turno turno;
  final VoidCallback onRetry;
  final ValueChanged<Fuente> onOpenFuente;

  @override
  Widget build(BuildContext context) {
    final debajo = switch (turno.estado) {
      Cargando() => const TypingIndicator(),
      Respondido(:final respuesta) => AnswerCard(respuesta: respuesta, onOpenFuente: onOpenFuente),
      Fallido(:final error) => TurnStatusCard(error: error, onRetry: onRetry),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UserBubble(texto: turno.pregunta),
        const SizedBox(height: AppSpacing.lg),
        // La clave cambia con el estado: el nuevo contenido aparece con fundido.
        FadeIn(key: ValueKey(turno.estado.runtimeType), child: debajo),
      ],
    );
  }
}
