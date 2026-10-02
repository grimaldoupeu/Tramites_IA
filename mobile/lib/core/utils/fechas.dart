/// Formato de fechas en español sin depender de un paquete (`intl`).
library;

const _meses = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

/// "2 de octubre de 2026": más fácil de leer que "02/10/2026", sobre todo para
/// personas mayores, y sin ambigüedad entre día y mes.
String fechaLarga(DateTime fecha) => '${fecha.day} de ${_meses[fecha.month - 1]} de ${fecha.year}';
