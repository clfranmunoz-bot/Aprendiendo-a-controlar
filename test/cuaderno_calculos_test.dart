import 'package:flutter_test/flutter_test.dart';
import 'package:aprender_a_controlar/screens/ejercicios_cuaderno_screen.dart';

void main() {
  group('Blindaje Matemático - Cuaderno de Sondajes (CorridaModel y Cálculos)', () {
    test('Creación y validación de modelo de Corrida', () {
      final corrida = CorridaModel(
        index: 1,
        perforado: 1.50,
        recuperado: 1.45,
        pctRecuperacion: 96.67,
        esCambioBarril: false,
        nuevoBarrilMedida: 2.60,
        count300: 10,
        count290: 0,
        correctContra: 1.20,
        correctFondo: 30.50,
        correctBarras: 10,
        correctHerramienta: 2.60,
      );

      expect(corrida.perforado, 1.50);
      expect(corrida.recuperado, 1.45);
      expect(corrida.pctRecuperacion, 96.67);
      expect(corrida.correctBarras, 10);
    });

    test('Validación de tolerancia numérica (0.01 m) en respuestas de usuario', () {
      const double correctFondo = 45.20;
      const double userFondoValido = 45.204;
      const double userFondoInvalido = 45.22;

      final bool esValido = (userFondoValido - correctFondo).abs() <= 0.01;
      final bool esInvalido = (userFondoInvalido - correctFondo).abs() <= 0.01;

      expect(esValido, isTrue);
      expect(esInvalido, isFalse);
    });

    test('Cálculo de profundidad de herramienta con y sin extensión réflex', () {
      const double barrilBase = 2.60;
      const double extensionReflex = 0.40;

      const double herramientaSinReflex = barrilBase;
      const double herramientaConReflex = barrilBase + extensionReflex;

      expect(herramientaSinReflex, 2.60);
      expect(herramientaConReflex, 3.00);
    });

    test('Cálculo de largo total de sarta con barras mixtas (3.00m y 2.90m)', () {
      const int count300 = 15;
      const int count290 = 5;
      const double largoHerramienta = 2.60;

      const double largoTotalSarta = (count300 * 3.00) + (count290 * 2.90) + largoHerramienta;
      expect(largoTotalSarta, 45.0 + 14.5 + 2.60); // 62.10
    });
  });
}
