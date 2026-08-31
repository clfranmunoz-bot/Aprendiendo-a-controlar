import 'dart:ui';
import 'package:aprender_a_controlar/models/mapa_punto.dart';
import 'package:aprender_a_controlar/services/utm_converter.dart';

class FaenaMapa {
  final String id;
  final String nombre;
  final String sector;
  final String imageAssetPath;
  final String? customImagePath;
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;
  final double centerLat;
  final double centerLng;
  final int husoUtm;
  final String hemisferio;
  final List<MapaPunto> puntosPredeterminados;

  const FaenaMapa({
    required this.id,
    required this.nombre,
    required this.sector,
    required this.imageAssetPath,
    this.customImagePath,
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
    required this.centerLat,
    required this.centerLng,
    this.husoUtm = 19,
    this.hemisferio = 'S',
    this.puntosPredeterminados = const [],
  });

  /// Convierte coordenadas geográficas a posición normalizada [0.0 - 1.0] sobre la imagen satelital.
  Offset latLngToNormalized(double lat, double lng) {
    final double x = (lng - minLng) / (maxLng - minLng);
    // Latitud disminuye hacia el sur (abajo en la imagen)
    final double y = (maxLat - lat) / (maxLat - minLat);
    return Offset(x.clamp(0.0, 1.0), y.clamp(0.0, 1.0));
  }

  /// Convierte una posición normalizada [0.0 - 1.0] a coordenadas geográficas (Lat/Lon).
  LatLngPoint normalizedToLatLng(Offset normalized) {
    final double lng = minLng + normalized.dx.clamp(0.0, 1.0) * (maxLng - minLng);
    final double lat = maxLat - normalized.dy.clamp(0.0, 1.0) * (maxLat - minLat);
    return LatLngPoint(latitude: lat, longitude: lng);
  }

  /// Verifica si una coordenada se encuentra dentro del área de cobertura del mapa actual.
  bool contains(double lat, double lng) {
    return lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
  }
}
