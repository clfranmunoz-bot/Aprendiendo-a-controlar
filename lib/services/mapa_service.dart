import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:aprender_a_controlar/models/mapa_punto.dart';
import 'package:aprender_a_controlar/models/faena_mapa.dart';

class MapaService {
  static const String _prefPuntosKey = 'mapa_puntos_personalizados_';

  /// Catálogo de faenas predeterminadas con sus mapas satelitales calibrados.
  static final List<FaenaMapa> faenasCatalogo = [
    const FaenaMapa(
      id: 'los_pelambres',
      nombre: 'Minera Los Pelambres',
      sector: 'Sector Rajo, Botaderos y Sondajes Cordillera (Salamanca, IV Región)',
      imageAssetPath: 'assets/maps/los_pelambres_satelital.jpg',
      minLat: -31.7515253,
      maxLat: -31.7048031,
      minLng: -70.5541992,
      maxLng: -70.4882812,
      centerLat: -31.7281642,
      centerLng: -70.5212402,
      husoUtm: 19,
      hemisferio: 'S',
      puntosPredeterminados: [],
    ),
  ];

  /// Obtiene la lista completa de puntos (predeterminados + personalizados del usuario).
  static Future<List<MapaPunto>> obtenerPuntos(String faenaId) async {
    final faena = faenasCatalogo.firstWhere(
      (f) => f.id == faenaId,
      orElse: () => faenasCatalogo.first,
    );

    final lista = List<MapaPunto>.from(faena.puntosPredeterminados);

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_prefPuntosKey$faenaId';
      final jsonStr = prefs.getString(key);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        final customPoints = decoded.map((item) => MapaPunto.fromJson(item as Map<String, dynamic>)).toList();
        lista.addAll(customPoints);
      }
    } catch (_) {}

    return lista;
  }

  /// Guarda un nuevo punto creado por el usuario en terreno.
  static Future<void> guardarPuntoPersonalizado(String faenaId, MapaPunto punto) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefPuntosKey$faenaId';
    final jsonStr = prefs.getString(key);

    List<MapaPunto> customPoints = [];
    if (jsonStr != null && jsonStr.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      customPoints = decoded.map((item) => MapaPunto.fromJson(item as Map<String, dynamic>)).toList();
    }

    final index = customPoints.indexWhere((p) => p.id == punto.id);
    if (index >= 0) {
      customPoints[index] = punto;
    } else {
      customPoints.add(punto);
    }

    final encoded = jsonEncode(customPoints.map((p) => p.toJson()).toList());
    await prefs.setString(key, encoded);
  }

  /// Elimina un punto personalizado.
  static Future<void> eliminarPuntoPersonalizado(String faenaId, String puntoId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefPuntosKey$faenaId';
    final jsonStr = prefs.getString(key);
    if (jsonStr == null || jsonStr.isEmpty) return;

    final List<dynamic> decoded = jsonDecode(jsonStr);
    final customPoints = decoded
        .map((item) => MapaPunto.fromJson(item as Map<String, dynamic>))
        .where((p) => p.id != puntoId)
        .toList();

    final encoded = jsonEncode(customPoints.map((p) => p.toJson()).toList());
    await prefs.setString(key, encoded);
  }

  /// Exporta todos los puntos a formato CSV compatible con Excel y software minero (Vulcan, Leapfrog, Datamine).
  static Future<String> exportarPuntosCsv(String faenaId) async {
    final puntos = await obtenerPuntos(faenaId);
    final buffer = StringBuffer();
    buffer.writeln('ID,Nombre,Categoria,Latitud,Longitud,UTM_Huso,UTM_Este,UTM_Norte,Cota_msnm,Azimut,Inclinacion,Profundidad_m,Estado,Observaciones');

    for (final p in puntos) {
      buffer.writeln(
        '${p.id},"${p.nombre}","${p.categoria.titulo}",${p.latitud.toStringAsFixed(6)},${p.longitud.toStringAsFixed(6)},${p.husoUtm}${p.hemisferio},${p.esteUtm.toStringAsFixed(1)},${p.norteUtm.toStringAsFixed(1)},${p.cota ?? ''},${p.azimutPozo ?? ''},${p.inclinacionPozo ?? ''},${p.profundidadObjetivo ?? ''},"${p.estado}","${p.observaciones ?? ''}"',
      );
    }
    return buffer.toString();
  }

  /// Solicita y obtiene la posición GPS real del hardware del dispositivo.
  static Future<Position?> obtenerPosicionGpsActual() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (_) {
      return await Geolocator.getLastKnownPosition();
    }
  }
}
