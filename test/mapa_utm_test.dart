import 'package:flutter_test/flutter_test.dart';
import 'package:aprender_a_controlar/services/utm_converter.dart';
import 'package:aprender_a_controlar/services/mapa_service.dart';

void main() {
  group('Pruebas de UtmConverter y Geodesia Minera', () {
    test('Conversión de Lat/Lon a UTM 19S en Minera Los Pelambres', () {
      // Coordenadas centrales de Minera Los Pelambres
      const double lat = -31.7304815;
      const double lon = -70.5198359;

      final utm = UtmConverter.latLonToUtm(lat, lon);

      expect(utm.zone, equals(19));
      expect(utm.hemisphere, equals('S'));
      // Rango esperado en metros UTM Huso 19S
      expect(utm.easting, closeTo(356015, 100));
      expect(utm.northing, closeTo(6488435, 100));
    });

    test('Conversión inversa UTM a Lat/Lon (Round-trip)', () {
      const double originalLat = -31.7304815;
      const double originalLon = -70.5198359;

      final utm = UtmConverter.latLonToUtm(originalLat, originalLon);
      final latLon = UtmConverter.utmToLatLon(utm.zone, utm.hemisphere, utm.easting, utm.northing);

      expect(latLon.latitude, closeTo(originalLat, 0.0001));
      expect(latLon.longitude, closeTo(originalLon, 0.0001));
    });

    test('Cálculo de Distancia y Azimut entre Campamento y Pozo', () {
      // Campamento Chacay: -31.748, -70.542
      // Pozo DDH-PEL-101: -31.7285, -70.5220
      final result = UtmConverter.calculateDistanceAndAzimuth(
        -31.74800,
        -70.54200,
        -31.72850,
        -70.52200,
      );

      expect(result.distanceMeters, greaterThan(2500));
      expect(result.distanceMeters, lessThan(4000));
      expect(result.azimuthDegrees, greaterThan(30));
      expect(result.azimuthDegrees, lessThan(60));
      expect(result.cardinalDirection, contains('NE'));
    });

    test('Faena Mapa Los Pelambres contiene coordenadas y normaliza correctamente', () {
      final faena = MapaService.faenasCatalogo.first;
      expect(faena.id, equals('los_pelambres'));
      expect(faena.contains(faena.centerLat, faena.centerLng), isTrue);

      final normCenter = faena.latLngToNormalized(faena.centerLat, faena.centerLng);
      expect(normCenter.dx, inInclusiveRange(0.0, 1.0));
      expect(normCenter.dy, inInclusiveRange(0.0, 1.0));
    });
  });
}
