import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/services/api_exception.dart';

/// Tarjeta de error o aviso con botón "Reintentar" (DESIGN.md §6.6).
///
/// Nunca depende solo del color: siempre lleva icono y un título que nombra el
/// problema, y el texto dice qué hacer.
class TurnStatusCard extends StatelessWidget {
  const TurnStatusCard({super.key, required this.error, required this.onRetry});

  final ApiException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final appColors = context.appColors;
    final text = Theme.of(context).textTheme;

    final contenido = _Contenido.de(error);

    // Aviso (temporal, Maíz) o error (Ladrillo con borde izquierdo).
    final Color fondo;
    final Color textoColor;
    final Color iconoColor;
    final Border? borde;
    final ButtonStyle? estiloBoton;
    if (contenido.esAviso) {
      fondo = scheme.secondaryContainer;
      textoColor = scheme.onSecondaryContainer;
      iconoColor = scheme.onSecondaryContainer;
      borde = null;
      estiloBoton = FilledButton.styleFrom(
        backgroundColor: appColors.warningAction,
        foregroundColor: appColors.onWarningAction,
      );
    } else {
      fondo = scheme.errorContainer;
      textoColor = scheme.onErrorContainer;
      iconoColor = scheme.error;
      borde = Border(left: BorderSide(color: scheme.error, width: 4));
      estiloBoton = null; // botón principal normal
    }

    return Semantics(
      liveRegion: true, // el lector de pantalla anuncia el problema al aparecer
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: fondo,
          border: borde,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(contenido.icono, color: iconoColor),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(contenido.titulo, style: text.titleMedium?.copyWith(color: textoColor)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(contenido.explicacion, style: text.bodyMedium?.copyWith(color: textoColor)),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onRetry,
              style: estiloBoton,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Textos de DESIGN.md §6.6 para cada tipo de error.
class _Contenido {
  const _Contenido(this.icono, this.titulo, this.explicacion, {this.esAviso = false});

  factory _Contenido.de(ApiException error) => switch (error) {
        SinConexionException() => const _Contenido(
            Icons.cloud_off_rounded,
            'No se pudo conectar',
            'Revisa tu conexión a internet e inténtalo de nuevo.',
          ),
        ServicioOcupadoException() => const _Contenido(
            Icons.schedule_rounded,
            'El servicio está ocupado',
            'Hay muchas consultas en este momento. Inténtalo en unos segundos.',
            esAviso: true,
          ),
        ErrorServidorException() => const _Contenido(
            Icons.error_outline_rounded,
            'No se pudo responder',
            'Ocurrió un problema al preparar la respuesta. Inténtalo de nuevo.',
          ),
      };

  final IconData icono;
  final String titulo;
  final String explicacion;
  final bool esAviso;
}
