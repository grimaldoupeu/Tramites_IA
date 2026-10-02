import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../../data/services/api_exception.dart';
import '../../data/services/tramites_api.dart';
import 'turno.dart';

/// Estado de la conversación, compartido por Inicio y Chat.
///
/// Usa `ChangeNotifier` (incluido en Flutter): las pantallas lo escuchan con
/// `ListenableBuilder` y se redibujan cuando llama a `notifyListeners()`.
class ChatController extends ChangeNotifier {
  ChatController(this._api);

  /// Límites que acepta el backend (`PreguntaRequest` en backend/app/schemas.py).
  static const longitudMinima = 3;
  static const longitudMaxima = 1000;

  final TramitesApi _api;
  final List<Turno> _turnos = [];
  int _siguienteId = 0;
  bool _cerrado = false;

  List<Turno> get turnos => List.unmodifiable(_turnos);

  /// Mientras hay una pregunta en curso no se puede enviar otra.
  bool get esperandoRespuesta => _turnos.any((t) => t.estado is Cargando);

  static bool esPreguntaValida(String texto) {
    final limpio = texto.trim();
    return limpio.length >= longitudMinima && limpio.length <= longitudMaxima;
  }

  /// Agrega la pregunta a la conversación y consulta al backend.
  Future<void> enviar(String pregunta) async {
    if (!esPreguntaValida(pregunta) || esperandoRespuesta) return;

    final turno = Turno(id: _siguienteId++, pregunta: pregunta.trim(), estado: const Cargando());
    _turnos.add(turno);
    notifyListeners();
    await _consultar(turno);
  }

  /// Vuelve a enviar la pregunta de un turno que falló.
  Future<void> reintentar(int id) async {
    final i = _turnos.indexWhere((t) => t.id == id);
    if (i == -1 || _turnos[i].estado is! Fallido || esperandoRespuesta) return;

    _turnos[i] = _turnos[i].conEstado(const Cargando());
    notifyListeners();
    await _consultar(_turnos[i]);
  }

  Future<void> _consultar(Turno turno) async {
    EstadoTurno resultado;
    try {
      resultado = Respondido(await _api.preguntar(turno.pregunta));
    } on ApiException catch (error) {
      if (error is ErrorServidorException) {
        developer.log(error.detalle, name: 'TramitesApi'); // solo para depurar
      }
      resultado = Fallido(error);
    }

    if (_cerrado) return; // la app se cerró mientras esperaba
    final i = _turnos.indexWhere((t) => t.id == turno.id);
    if (i == -1) return;
    _turnos[i] = _turnos[i].conEstado(resultado);
    notifyListeners();
  }

  @override
  void dispose() {
    _cerrado = true;
    _api.close();
    super.dispose();
  }
}
