import 'fuente.dart';

/// Respuesta de `POST /preguntar`: `{"respuesta": "...", "fuentes": [...]}`.
class Respuesta {
  const Respuesta({required this.texto, required this.fuentes});

  factory Respuesta.fromJson(Map<String, dynamic> json) {
    final fuentes = (json['fuentes'] as List<dynamic>? ?? const [])
        .map((f) => Fuente.fromJson(f as Map<String, dynamic>))
        .toList(growable: false);
    return Respuesta(texto: json['respuesta'] as String, fuentes: fuentes);
  }

  final String texto;

  /// Vacía cuando el backend no encontró información (no se muestra la constancia).
  final List<Fuente> fuentes;
}
