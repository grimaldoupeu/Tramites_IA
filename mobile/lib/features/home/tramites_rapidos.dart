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

/// Una entidad del Estado y sus trámites, que en Inicio se muestran como una sección.
class EntidadTramites {
  const EntidadTramites({
    required this.sigla,
    required this.descripcion,
    required this.tramites,
  });

  /// "SUNAT", "RENIEC", "SUNARP": así las conoce la gente.
  final String sigla;

  /// De qué se encarga, para quien no reconoce la sigla.
  final String descripcion;
  final List<TramiteRapido> tramites;
}

/// Trámites con documentos cargados en el backend (backend/data/raw/).
const entidades = [
  EntidadTramites(
    sigla: 'SUNAT',
    descripcion: 'Impuestos, RUC y comprobantes de pago',
    tramites: [
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
    ],
  ),
  EntidadTramites(
    sigla: 'RENIEC',
    descripcion: 'DNI y actas de nacimiento, matrimonio o defunción',
    tramites: [
      TramiteRapido(
        nombre: 'Duplicado de DNI',
        descripcion: 'Si lo perdiste, te lo robaron o está dañado',
        icono: Icons.copy_all_rounded,
        pregunta: '¿Cómo saco un duplicado de mi DNI y cuánto cuesta?',
      ),
      TramiteRapido(
        nombre: 'Renovar DNI',
        descripcion: 'Cuando tu DNI está por vencer o ya venció',
        icono: Icons.autorenew_rounded,
        pregunta: '¿Cómo renuevo mi DNI si soy mayor de 17 años?',
      ),
      TramiteRapido(
        nombre: 'Copia certificada de acta o partida',
        descripcion: 'De nacimiento, matrimonio o defunción',
        icono: Icons.description_rounded,
        pregunta: '¿Cómo pido una copia certificada de un acta o partida en RENIEC?',
      ),
      TramiteRapido(
        nombre: 'Certificado de Inscripción (C4)',
        descripcion: 'Constancia de tus datos registrados en RENIEC',
        icono: Icons.assignment_ind_rounded,
        pregunta: '¿Cómo solicito el Certificado de Inscripción C4?',
      ),
      TramiteRapido(
        nombre: 'Estado del trámite de tu DNI',
        descripcion: 'Revisa si tu DNI ya está listo para recoger',
        icono: Icons.manage_search_rounded,
        pregunta: '¿Cómo consulto si mi DNI ya está listo para recoger?',
      ),
    ],
  ),
  EntidadTramites(
    sigla: 'SUNARP',
    descripcion: 'Propiedades, vehículos y empresas',
    tramites: [
      TramiteRapido(
        nombre: 'Copia literal de partida',
        descripcion: 'Quién es dueño de un inmueble y qué cargas tiene',
        icono: Icons.article_rounded,
        pregunta: '¿Cómo saco una copia literal de una partida en SUNARP?',
      ),
      TramiteRapido(
        nombre: 'Consulta de propiedad',
        descripcion: 'Busca gratis las propiedades a tu nombre',
        icono: Icons.home_work_rounded,
        pregunta: '¿Cómo consulto gratis qué propiedades tengo registradas en SUNARP?',
      ),
      TramiteRapido(
        nombre: 'Consulta vehicular',
        descripcion: 'Datos de un vehículo con solo su placa',
        icono: Icons.directions_car_rounded,
        pregunta: '¿Cómo consulto los datos de un vehículo por su placa?',
      ),
      TramiteRapido(
        nombre: 'Boleta informativa vehicular',
        descripcion: 'Dueño, características y cargas de un vehículo',
        icono: Icons.receipt_rounded,
        pregunta: '¿Qué es la boleta informativa vehicular y cómo la pido?',
      ),
      TramiteRapido(
        nombre: 'Tarjeta de identificación vehicular (TIVe)',
        descripcion: 'La tarjeta de propiedad de tu vehículo, en digital',
        icono: Icons.credit_card_rounded,
        pregunta: '¿Cómo obtengo la Tarjeta de Identificación Vehicular Electrónica?',
      ),
      TramiteRapido(
        nombre: 'Vigencia de poder de una empresa',
        descripcion: 'Acredita que un representante sigue facultado',
        icono: Icons.gavel_rounded,
        pregunta: '¿Cómo solicito un certificado de vigencia de poder de una persona jurídica?',
      ),
    ],
  ),
];
