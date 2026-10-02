/// Fuente oficial de una respuesta, tal como la devuelve el backend:
/// `{"tramite": "...", "url": "..."}`.
class Fuente {
  const Fuente({required this.tramite, required this.url});

  factory Fuente.fromJson(Map<String, dynamic> json) {
    return Fuente(
      tramite: json['tramite'] as String,
      url: json['url'] as String,
    );
  }

  final String tramite;
  final String url;

  /// Dominio de la URL (p. ej. "gob.pe"), para mostrar a dónde lleva el enlace.
  String get dominio {
    final host = Uri.tryParse(url)?.host ?? '';
    return host.startsWith('www.') ? host.substring(4) : host;
  }
}
