import 'package:flutter_test/flutter_test.dart';
import 'package:aprender_a_controlar/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    test('Hashing SHA-256 produce resultados deterministas', () {
      const clave = 'Geo11235813';
      final hash = AuthService.hashSha256(clave);
      expect(hash, AuthService.hashesContrasenas[0]);
    });

    test('Validación mensual por fecha asigna el índice correcto', () {
      final fechaMarzo = DateTime(2026, 3, 15);
      expect(AuthService.verificarContrasenaMensual('Geo11235813_3', fechaMarzo), isTrue);
      expect(AuthService.verificarContrasenaMensual('Geo11235813', fechaMarzo), isFalse);
    });

    test('Validación de ciclo de 28 días', () {
      expect(AuthService.verificarContrasena28Dias('Geo11235813'), isTrue);
      expect(AuthService.verificarContrasena28Dias('incorrecta'), isFalse);
    });

    test('haCaducadoAccesoMensual detecta cambio de mes o año', () {
      expect(
        AuthService.haCaducadoAccesoMensual(
          mesUltimaValidacion: 3,
          anioUltimaValidacion: 2026,
          fechaActual: DateTime(2026, 4, 1),
        ),
        isTrue,
      );
      expect(
        AuthService.haCaducadoAccesoMensual(
          mesUltimaValidacion: 4,
          anioUltimaValidacion: 2026,
          fechaActual: DateTime(2026, 4, 15),
        ),
        isFalse,
      );
    });

    test('necesitaRenovacion28Dias detecta transcurso de 28 días', () {
      const millis28Dias = 28 * 24 * 60 * 60 * 1000;
      final inicio = DateTime(2026, 1, 1).millisecondsSinceEpoch;
      
      expect(
        AuthService.necesitaRenovacion28Dias(
          last28DayUnlockTimestamp: inicio,
          timestampActual: inicio + millis28Dias + 1000,
        ),
        isTrue,
      );
      expect(
        AuthService.necesitaRenovacion28Dias(
          last28DayUnlockTimestamp: inicio,
          timestampActual: inicio + millis28Dias - 1000,
        ),
        isFalse,
      );
    });
  });
}
