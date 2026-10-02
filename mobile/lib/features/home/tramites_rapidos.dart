import 'package:flutter/material.dart';

/// Acceso rápido a un trámite: al tocarlo se envía [pregunta] al chat.
class TramiteRapido {
  const TramiteRapido({
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.pregunta,
  });

  final String nombre;

  /// Para qué sirve, en una línea y en palabras sencillas.
  final String descripcion;
  final IconData icono;
  final String pregunta;
}

/// Trámites con documentos cargados en el backend (backend/data/raw/).
const tramitesRapidos = [
  TramiteRapido(
    nombre: 'Inscripción en el RUC',
    descripcion: 'Obtén tu número de contribuyente',
    icono: Icons.badge_rounded,
    pregunta: '¿Qué necesito para inscribirme en el RUC como persona natural?',
  ),
  TramiteRapido(
    nombre: 'Obtener Clave SOL',
    descripcion: 'Tu acceso a SUNAT en línea',
    icono: Icons.key_rounded,
    pregunta: '¿Cómo obtengo mi Clave SOL?',
  ),
  TramiteRapido(
    nombre: 'Recibo por honorarios electrónico',
    descripcion: 'Cómo emitirlo por tus servicios',
    icono: Icons.receipt_long_rounded,
    pregunta: '¿Cómo emito un recibo por honorarios electrónico?',
  ),
  TramiteRapido(
    nombre: 'Suspensión de retenciones de 4ta categoría',
    descripcion: 'Deja de pagar retenciones si no te corresponden',
    icono: Icons.pause_circle_outline_rounded,
    pregunta: '¿Cómo solicito la suspensión de retenciones de cuarta categoría?',
  ),
  TramiteRapido(
    nombre: 'Gastos deducibles de hasta 3 UIT',
    descripcion: 'Qué gastos puedes descontar de tus impuestos',
    icono: Icons.calculate_rounded,
    pregunta: '¿Qué gastos puedo deducir hasta 3 UIT y cómo lo hago?',
  ),
  TramiteRapido(
    nombre: 'Devolución de impuestos',
    descripcion: 'Recupera lo que pagaste de más',
    icono: Icons.currency_exchange_rounded,
    pregunta: '¿Cómo solicito la devolución de impuestos por rentas de trabajo?',
  ),
];
