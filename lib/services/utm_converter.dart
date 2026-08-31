import 'dart:math' as math;

enum UtmDatum {
  wgs84,
  psad56,
  sad69,
  sirgas2000,
}

class UtmCoordinate {
  final int zone;
  final String hemisphere; // 'N' o 'S'
  final double easting;
  final double northing;
  final double? altitude;
  final UtmDatum datum;

  const UtmCoordinate({
    required this.zone,
    required this.hemisphere,
    required this.easting,
    required this.northing,
    this.altitude,
    this.datum = UtmDatum.wgs84,
  });

  String get formatted {
    final eStr = easting.toStringAsFixed(1);
    final nStr = northing.toStringAsFixed(1);
    final altStr = altitude != null ? ' | Alt: ${altitude!.toStringAsFixed(0)} msnm' : '';
    return '$zone$hemisphere  E: $eStr m  N: $nStr m$altStr';
  }

  String get shortFormatted {
    final eStr = easting.toStringAsFixed(0);
    final nStr = northing.toStringAsFixed(0);
    return '$zone$hemisphere  E $eStr  N $nStr';
  }
}

class LatLngPoint {
  final double latitude;
  final double longitude;
  final double? altitude;

  const LatLngPoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
  });

  String get formatted {
    final latStr = latitude.toStringAsFixed(5);
    final lngStr = longitude.toStringAsFixed(5);
    return '$latStr°, $lngStr°';
  }
}

class DistanceAzimuth {
  final double distanceMeters;
  final double azimuthDegrees; // 0 to 360 (North = 0)
  final String cardinalDirection; // N, NE, E, SE, S, SW, W, NW

  const DistanceAzimuth({
    required this.distanceMeters,
    required this.azimuthDegrees,
    required this.cardinalDirection,
  });

  String get distanceFormatted {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toStringAsFixed(1)} m';
    } else {
      return '${(distanceMeters / 1000).toStringAsFixed(2)} km';
    }
  }

  String get azimuthFormatted {
    return '${azimuthDegrees.toStringAsFixed(1)}° ($cardinalDirection)';
  }
}

/// Motor matemático para conversiones geodésicas y cálculos en terreno minero.
class UtmConverter {
  // Parámetros de elipsoides comúnmente utilizados en minería sudamericana
  static const Map<UtmDatum, List<double>> _ellipsoids = {
    // a (semi-major axis), 1/f (inverse flattening)
    UtmDatum.wgs84: [6378137.0, 298.257223563],
    UtmDatum.sirgas2000: [6378137.0, 298.257222101],
    UtmDatum.psad56: [6378388.0, 297.0], // Hayford International 1924
    UtmDatum.sad69: [6378160.0, 298.25],
  };

  /// Convierte coordenadas geográficas WGS84 (Latitud / Longitud) a UTM.
  static UtmCoordinate latLonToUtm(
    double lat,
    double lon, {
    double? altitude,
    UtmDatum datum = UtmDatum.wgs84,
  }) {
    final params = _ellipsoids[datum] ?? _ellipsoids[UtmDatum.wgs84]!;
    final double a = params[0];
    final double f = 1.0 / params[1];
    final double e2 = 2 * f - f * f;
    final double ePrime2 = e2 / (1.0 - e2);

    int zone = ((lon + 180.0) / 6.0).floor() + 1;
    if (zone < 1) zone = 1;
    if (zone > 60) zone = 60;

    final String hemisphere = lat >= 0 ? 'N' : 'S';
    final double lon0 = (zone - 1) * 6.0 - 180.0 + 3.0;

    final double latRad = _degToRad(lat);
    final double lonRad = _degToRad(lon);
    final double lon0Rad = _degToRad(lon0);

    const double k0 = 0.9996;
    final double sinLat = math.sin(latRad);
    final double cosLat = math.cos(latRad);
    final double tanLat = math.tan(latRad);

    final double n = a / math.sqrt(1.0 - e2 * sinLat * sinLat);
    final double t = tanLat * tanLat;
    final double c = ePrime2 * cosLat * cosLat;
    final double deltaLon = cosLat * (lonRad - lon0Rad);

    final double m = a *
        ((1.0 - e2 / 4.0 - 3.0 * e2 * e2 / 64.0 - 5.0 * e2 * e2 * e2 / 256.0) * latRad -
            (3.0 * e2 / 8.0 + 3.0 * e2 * e2 / 32.0 + 45.0 * e2 * e2 * e2 / 1024.0) * math.sin(2.0 * latRad) +
            (15.0 * e2 * e2 / 256.0 + 45.0 * e2 * e2 * e2 / 1024.0) * math.sin(4.0 * latRad) -
            (35.0 * e2 * e2 * e2 / 3072.0) * math.sin(6.0 * latRad));

    final double easting = k0 *
            n *
            (deltaLon +
                (1.0 - t + c) * math.pow(deltaLon, 3) / 6.0 +
                (5.0 - 18.0 * t + t * t + 72.0 * c - 58.0 * ePrime2) * math.pow(deltaLon, 5) / 120.0) +
        500000.0;

    double northing = k0 *
        (m +
            n *
                tanLat *
                (math.pow(deltaLon, 2) / 2.0 +
                    (5.0 - t + 9.0 * c + 4.0 * c * c) * math.pow(deltaLon, 4) / 24.0 +
                    (61.0 - 58.0 * t + t * t + 600.0 * c - 330.0 * ePrime2) * math.pow(deltaLon, 6) / 720.0));

    if (lat < 0) {
      northing += 10000000.0; // False Northing para hemisferio sur
    }

    return UtmCoordinate(
      zone: zone,
      hemisphere: hemisphere,
      easting: easting,
      northing: northing,
      altitude: altitude,
      datum: datum,
    );
  }

  /// Convierte coordenadas UTM a coordenadas geográficas (Latitud / Longitud en grados decimales).
  static LatLngPoint utmToLatLon(
    int zone,
    String hemisphere,
    double easting,
    double northing, {
    double? altitude,
    UtmDatum datum = UtmDatum.wgs84,
  }) {
    final params = _ellipsoids[datum] ?? _ellipsoids[UtmDatum.wgs84]!;
    final double a = params[0];
    final double f = 1.0 / params[1];
    final double e2 = 2 * f - f * f;
    final double ePrime2 = e2 / (1.0 - e2);

    const double k0 = 0.9996;
    final double x = easting - 500000.0;
    double y = northing;
    if (hemisphere.toUpperCase() == 'S') {
      y -= 10000000.0;
    }

    final double m = y / k0;
    final double mu = m / (a * (1.0 - e2 / 4.0 - 3.0 * e2 * e2 / 64.0 - 5.0 * e2 * e2 * e2 / 256.0));

    final double e1 = (1.0 - math.sqrt(1.0 - e2)) / (1.0 + math.sqrt(1.0 - e2));

    final double phi1Rad = mu +
        (3.0 * e1 / 2.0 - 27.0 * math.pow(e1, 3) / 32.0) * math.sin(2.0 * mu) +
        (21.0 * e1 * e1 / 16.0 - 55.0 * math.pow(e1, 4) / 32.0) * math.sin(4.0 * mu) +
        (151.0 * math.pow(e1, 3) / 96.0) * math.sin(6.0 * mu) +
        (1097.0 * math.pow(e1, 4) / 512.0) * math.sin(8.0 * mu);

    final double sinPhi1 = math.sin(phi1Rad);
    final double cosPhi1 = math.cos(phi1Rad);
    final double tanPhi1 = math.tan(phi1Rad);

    final double n1 = a / math.sqrt(1.0 - e2 * sinPhi1 * sinPhi1);
    final double t1 = tanPhi1 * tanPhi1;
    final double c1 = ePrime2 * cosPhi1 * cosPhi1;
    final double r1 = a * (1.0 - e2) / math.pow(1.0 - e2 * sinPhi1 * sinPhi1, 1.5);
    final double d = x / (n1 * k0);

    final double latRad = phi1Rad -
        (n1 * tanPhi1 / r1) *
            (d * d / 2.0 -
                (5.0 + 3.0 * t1 + 10.0 * c1 - 4.0 * c1 * c1 - 9.0 * ePrime2) * math.pow(d, 4) / 24.0 +
                (61.0 + 90.0 * t1 + 298.0 * c1 + 45.0 * t1 * t1 - 252.0 * ePrime2 - 3.0 * c1 * c1) *
                    math.pow(d, 6) /
                    720.0);

    final double lon0 = (zone - 1) * 6.0 - 180.0 + 3.0;
    final double lonRad = _degToRad(lon0) +
        (d -
                (1.0 + 2.0 * t1 + c1) * math.pow(d, 3) / 6.0 +
                (5.0 - 2.0 * c1 + 28.0 * t1 - 3.0 * c1 * c1 + 8.0 * ePrime2 + 24.0 * t1 * t1) *
                    math.pow(d, 5) /
                    120.0) /
            cosPhi1;

    return LatLngPoint(
      latitude: _radToDeg(latRad),
      longitude: _radToDeg(lonRad),
      altitude: altitude,
    );
  }

  /// Calcula la distancia geodésica (Haversine) y el azimut/rumbo entre dos puntos geográficos.
  static DistanceAzimuth calculateDistanceAndAzimuth(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double r = 6371000.0; // Radio medio de la Tierra en metros
    final double phi1 = _degToRad(lat1);
    final double phi2 = _degToRad(lat2);
    final double deltaPhi = _degToRad(lat2 - lat1);
    final double deltaLambda = _degToRad(lon2 - lon1);

    // Fórmula de Haversine
    final double a = math.sin(deltaPhi / 2.0) * math.sin(deltaPhi / 2.0) +
        math.cos(phi1) * math.cos(phi2) * math.sin(deltaLambda / 2.0) * math.sin(deltaLambda / 2.0);
    final double c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a));
    final double distance = r * c;

    // Fórmula de Azimut inicial (Bearing)
    final double y = math.sin(deltaLambda) * math.cos(phi2);
    final double x = math.cos(phi1) * math.sin(phi2) - math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);
    double bearingRad = math.atan2(y, x);
    double bearingDeg = (_radToDeg(bearingRad) + 360.0) % 360.0;

    // Determinación de punto cardinal
    final String cardinal = _degreesToCardinal(bearingDeg);

    return DistanceAzimuth(
      distanceMeters: distance,
      azimuthDegrees: bearingDeg,
      cardinalDirection: cardinal,
    );
  }

  static String _degreesToCardinal(double deg) {
    const directions = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
    final int index = ((deg + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  static double _degToRad(double deg) => deg * (math.pi / 180.0);
  static double _radToDeg(double rad) => rad * (180.0 / math.pi);
}
