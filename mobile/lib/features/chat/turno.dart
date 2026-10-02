import '../../data/models/respuesta.dart';
import '../../data/services/api_exception.dart';

/// Un turno de la conversación: la pregunta de la persona y lo que pasó con ella.
class Turno {
  const Turno({required this.id, required this.pregunta, required this.estado});

  final int id;
  final String pregunta;
  final EstadoTurno estado;

  Turno conEstado(EstadoTurno nuevo) => Turno(id: id, pregunta: pregunta, estado: nuevo);
}

/// Estados posibles de un turno. Al ser `sealed`, la interfaz los dibuja con un
/// `switch` y el compilador avisa si falta alguno.
sealed class EstadoTurno {
  const EstadoTurno();
}

/// Esperando al backend: se muestra "Buscando en fuentes oficiales…".
class Cargando extends EstadoTurno {
  const Cargando();
}

class Respondido extends EstadoTurno {
  const Respondido(this.respuesta);
  final Respuesta respuesta;
}

/// Falló: se muestra el mensaje del error con el botón "Reintentar".
class Fallido extends EstadoTurno {
  const Fallido(this.error);
  final ApiException error;
}
