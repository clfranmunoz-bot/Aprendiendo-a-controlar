import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/models/mapa_punto.dart';
import 'package:aprender_a_controlar/models/faena_mapa.dart';
import 'package:aprender_a_controlar/services/utm_converter.dart';

class MapaCanvasPainter extends CustomPainter {
  final ui.Image? imagenSatelital;
  final FaenaMapa faena;
  final List<MapaPunto> puntos;
  final MapaPunto? puntoSeleccionado;
  final LatLngPoint? posicionUsuario;
  final double? precisionMetros;
  final double? rumboUsuario; // Grados 0-360
  final bool mostrarGrillaUtm;
  final bool mostrarMarcadores;
  final double escalaZoom;
  final double pulsoAnimacion;

  MapaCanvasPainter({
    required this.imagenSatelital,
    required this.faena,
    required this.puntos,
    this.puntoSeleccionado,
    this.posicionUsuario,
    this.precisionMetros,
    this.rumboUsuario,
    this.mostrarGrillaUtm = true,
    this.mostrarMarcadores = true,
    this.escalaZoom = 1.0,
    this.pulsoAnimacion = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect canvasRect = Offset.zero & size;

    // 1. Dibujar fondo o imagen satelital
    if (imagenSatelital != null) {
      final Rect srcRect = Rect.fromLTWH(
        0,
        0,
        imagenSatelital!.width.toDouble(),
        imagenSatelital!.height.toDouble(),
      );
      canvas.drawImageRect(imagenSatelital!, srcRect, canvasRect, Paint());
    } else {
      // Fondo oscuro en degradé técnico
      final fondoPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2634), Color(0xFF0F1722)],
        ).createShader(canvasRect);
      canvas.drawRect(canvasRect, fondoPaint);
    }

    // 2. Dibujar Cuadrícula UTM métrica si está activa
    if (mostrarGrillaUtm) {
      _dibujarCuadriculaUtm(canvas, size);
    }

    // 3. Dibujar línea guía de navegación hacia el punto seleccionado
    if (posicionUsuario != null && puntoSeleccionado != null) {
      _dibujarLineaNavegacion(canvas, size);
    }

    // 4. Dibujar Marcadores de Pozos y Puntos de Interés
    if (mostrarMarcadores) {
      for (final punto in puntos) {
        final bool isSelected = puntoSeleccionado?.id == punto.id;
        _dibujarMarcador(canvas, size, punto, isSelected);
      }
    }

    // 5. Dibujar Posición GPS del Usuario
    if (posicionUsuario != null) {
      _dibujarPosicionUsuario(canvas, size);
    }
  }

  void _dibujarCuadriculaUtm(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0x334FC3F7)
      ..strokeWidth = 1.0;

    final borderPaint = Paint()
      ..color = const Color(0x664FC3F7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Offset.zero & size, borderPaint);

    const int divisionesX = 8;
    const int divisionesY = 8;

    for (int i = 1; i < divisionesX; i++) {
      final double x = size.width * (i / divisionesX);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (int j = 1; j < divisionesY; j++) {
      final double y = size.height * (j / divisionesY);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _dibujarLineaNavegacion(Canvas canvas, Size size) {
    final normUser = faena.latLngToNormalized(posicionUsuario!.latitude, posicionUsuario!.longitude);
    final normTarget = faena.latLngToNormalized(puntoSeleccionado!.latitud, puntoSeleccionado!.longitud);

    final p1 = Offset(normUser.dx * size.width, normUser.dy * size.height);
    final p2 = Offset(normTarget.dx * size.width, normTarget.dy * size.height);

    // Línea guía brillante
    final linePaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(p1, p2, linePaint);

    // Glow suave
    final glowPaint = Paint()
      ..color = const Color(0x40FFD54F)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(p1, p2, glowPaint);
  }

  void _dibujarMarcador(Canvas canvas, Size size, MapaPunto punto, bool isSelected) {
    final norm = faena.latLngToNormalized(punto.latitud, punto.longitud);
    final pos = Offset(norm.dx * size.width, norm.dy * size.height);

    final double baseRadius = isSelected ? 16.0 : 12.0;
    final color = Color(punto.categoria.colorHex);

    // Anillo de selección
    if (isSelected) {
      final selectRing = Paint()
        ..color = Colors.amberAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(pos, baseRadius + 6, selectRing);
    }

    // Sombra del marcador
    final shadowPaint = Paint()
      ..color = Colors.black45
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawCircle(pos + const Offset(0, 2), baseRadius, shadowPaint);

    // Círculo principal del marcador
    final fillPaint = Paint()..color = color;
    canvas.drawCircle(pos, baseRadius, fillPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.5 : 1.8;
    canvas.drawCircle(pos, baseRadius, borderPaint);

    // Punto central
    final corePaint = Paint()..color = Colors.white;
    canvas.drawCircle(pos, baseRadius * 0.35, corePaint);

    // Etiqueta del nombre (solo si hay suficiente zoom o está seleccionado)
    if (escalaZoom > 1.4 || isSelected) {
      final textSpan = TextSpan(
        text: punto.nombre,
        style: TextStyle(
          color: isSelected ? Colors.amberAccent : Colors.white,
          fontSize: isSelected ? 12.0 : 10.0,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
          ],
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final labelOffset = Offset(
        pos.dx - (textPainter.width / 2),
        pos.dy + baseRadius + 4,
      );

      // Fondo de la etiqueta
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          labelOffset.dx - 4,
          labelOffset.dy - 2,
          textPainter.width + 8,
          textPainter.height + 4,
        ),
        const Radius.circular(4),
      );
      final bgPaint = Paint()..color = Colors.black.withOpacity(0.75);
      canvas.drawRRect(bgRect, bgPaint);

      textPainter.paint(canvas, labelOffset);
    }
  }

  void _dibujarPosicionUsuario(Canvas canvas, Size size) {
    final norm = faena.latLngToNormalized(posicionUsuario!.latitude, posicionUsuario!.longitude);
    final pos = Offset(norm.dx * size.width, norm.dy * size.height);

    // 1. Círculo de pulso radar
    final double pulseRadius = 14.0 + (pulsoAnimacion * 24.0);
    final double pulseOpacity = (1.0 - pulsoAnimacion).clamp(0.0, 1.0) * 0.5;
    final pulsePaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(pulseOpacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, pulseRadius, pulsePaint);

    // 2. Halo exterior
    final haloPaint = Paint()
      ..color = const Color(0xFF2979FF).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 16.0, haloPaint);

    // 3. Cono de rumbo/dirección
    if (rumboUsuario != null) {
      final double rumboRad = (rumboUsuario! - 90.0) * (math.pi / 180.0);
      final conePath = Path()
        ..moveTo(pos.dx, pos.dy)
        ..lineTo(
          pos.dx + 36 * math.cos(rumboRad - 0.4),
          pos.dy + 36 * math.sin(rumboRad - 0.4),
        )
        ..lineTo(
          pos.dx + 44 * math.cos(rumboRad),
          pos.dy + 44 * math.sin(rumboRad),
        )
        ..lineTo(
          pos.dx + 36 * math.cos(rumboRad + 0.4),
          pos.dy + 36 * math.sin(rumboRad + 0.4),
        )
        ..close();

      final conePaint = Paint()
        ..shader = ui.Gradient.radial(
          pos,
          44.0,
          [const Color(0xFF00E5FF).withOpacity(0.6), const Color(0xFF00E5FF).withOpacity(0.0)],
        );
      canvas.drawPath(conePath, conePaint);
    }

    // 4. Punto azul de ubicación GPS central
    final dotPaint = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawCircle(pos, 8.0, dotPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(pos, 8.0, borderPaint);
  }

  @override
  bool shouldRepaint(covariant MapaCanvasPainter oldDelegate) {
    return oldDelegate.posicionUsuario != posicionUsuario ||
        oldDelegate.puntoSeleccionado != puntoSeleccionado ||
        oldDelegate.puntos != puntos ||
        oldDelegate.pulsoAnimacion != pulsoAnimacion ||
        oldDelegate.escalaZoom != escalaZoom ||
        oldDelegate.rumboUsuario != rumboUsuario ||
        oldDelegate.mostrarGrillaUtm != mostrarGrillaUtm ||
        oldDelegate.mostrarMarcadores != mostrarMarcadores ||
        oldDelegate.imagenSatelital != imagenSatelital;
  }
}
