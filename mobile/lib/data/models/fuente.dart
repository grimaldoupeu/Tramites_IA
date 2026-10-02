/// Fuente oficial de una respuesta, tal como la devuelve el backend:
/// `{"tramite": "...", "url": "...", "fecha_extraccion": "2026-10-02"}`.
class Fuente {
  const Fuente({required this.tramite, required this.url, this.fechaExtraccion});

  factory Fuente.fromJson(Map<String, dynamic> json) {
    final fecha = json['fecha_extraccion'] as String?;
    return Fuente(
      tramite: json['tramite'] as String,
      url: json['url'] as String,
      fechaExtraccion: fecha == null ? null : DateTime.tryParse(fecha),
    );
  }

  final String tramite;
  final String url;

  /// Día en que se copió el texto de la página oficial. Es `null` si el backend
  /// no la envía (versiones anteriores): entonces la app simplemente no la muestra.
  final DateTime? fechaExtraccion;

  /// Dominio de la URL (p. ej. "gob.pe"), para mostrar a dónde lleva el enlace.
  String get dominio {
    final host = Uri.tryParse(url)?.host ?? '';
    return host.startsWith('www.') ? host.substring(4) : host;
  }
}
