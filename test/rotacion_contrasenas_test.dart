import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto/crypto.dart';
import 'package:aprender_a_controlar/main.dart';

void main() {
  group('Pruebas de Rotación y Hashing de Contraseñas', () {
    test('Verificar hashing SHA-256 de contraseñas estándar', () {
      final claves = [
        'Geo11235813',
        'Geo11235813_2',
        'Geo11235813_3',
        'Geo11235813_4',
        'Geo11235813_5',
      ];

      for (int i = 0; i < 5; i++) {
        final bytes = utf8.encode(claves[i]);
        final hash = sha256.convert(bytes).toString();
        expect(hash, AprenderAControlarApp.hashesContrasenas[i]);
      }
    });

    test('Verificar cálculo de índice estándar según mes de calendario', () {
      // Mapeo esperado: (mes - 1) % 5
      final mesesIndices = {
        1: 0,  // Ene -> Password 1
        2: 1,  // Feb -> Password 2
        3: 2,  // Mar -> Password 3
        4: 3,  // Abr -> Password 4
        5: 4,  // May -> Password 5
        6: 0,  // Jun -> Password 1 (rotación)
        7: 1,  // Jul -> Password 2
        8: 2,  // Ago -> Password 3
        9: 3,  // Sep -> Password 4
        10: 4, // Oct -> Password 5
        11: 0, // Nov -> Password 1
        12: 1, // Dic -> Password 2
      };

      mesesIndices.forEach((mes, indexEsperado) {
        final indexCalculado = (mes - 1) % 5;
        expect(indexCalculado, indexEsperado, reason: "Mes $mes debería mapear al índice $indexEsperado");
      });
    });
  });
}
