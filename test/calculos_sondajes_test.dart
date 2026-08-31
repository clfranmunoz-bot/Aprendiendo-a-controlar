import 'package:flutter_test/flutter_test.dart';
import 'package:aprender_a_controlar/utils/calculos_sondajes.dart';
import 'package:aprender_a_controlar/models/problema.dart';

void main() {
  group('Blindaje Matemático - Utilidades Básicas de Cálculo', () {
    test('CalculosSondajes.redondear2 redondea correctamente a 2 decimales', () {
      expect(CalculosSondajes.redondear2(1.234), 1.23);
      expect(CalculosSondajes.redondear2(1.236), 1.24);
      expect(CalculosSondajes.redondear2(1.2000000000000002), 1.20);
      expect(CalculosSondajes.redondear2(0.0), 0.0);
      expect(CalculosSondajes.redondear2(100.555), 100.56);
      expect(CalculosSondajes.redondear2(-1.555), -1.56);
    });

    test('CalculosSondajes.formato formatea correctamente con 2 decimales', () {
      expect(CalculosSondajes.formato(1.2), '1.20');
      expect(CalculosSondajes.formato(3.0), '3.00');
      expect(CalculosSondajes.formato(0.0), '0.00');
      expect(CalculosSondajes.formato(123.456), '123.46');
    });
  });

  group('Blindaje Matemático - Fórmulas de Contra / Sobrante', () {
    test('Fórmula de cálculo de contra directa en terreno (sin barra adicional)', () {
      // Caso: Contra anterior >= Perforado
      const double contraAnt = 2.50;
      const double perforado = 1.20;
      const double barra = 3.00;

      double contraAntAjustada = contraAnt;
      if (contraAnt < perforado) {
        contraAntAjustada += barra;
      }
      final contraCalculada = CalculosSondajes.redondear2(contraAntAjustada - perforado);
      expect(contraCalculada, 1.30);
    });

    test('Fórmula de cálculo de contra con adición de barra operacional', () {
      // Caso: Contra anterior < Perforado -> Se asume adición de barra
      const double contraAnt = 0.80;
      const double perforado = 1.90;
      const double barra = 3.00;

      double contraAntAjustada = contraAnt;
      if (contraAnt < perforado) {
        contraAntAjustada += barra; // 0.80 + 3.00 = 3.80
      }
      final contraCalculada = CalculosSondajes.redondear2(contraAntAjustada - perforado);
      expect(contraCalculada, 1.90);
    });

    test('Generador de Problemas de Contra genera opciones y respuesta consistentes', () {
      for (final nivel in NivelContra.values) {
        for (int i = 0; i < 20; i++) {
          final problema = CalculosSondajes.generarProblemaContra(nivel);
          expect(problema.contraCorrecta, greaterThan(0));
          expect(problema.opciones.length, 3);
          expect(problema.opciones.contains(problema.contraCorrecta), isTrue);
          expect(problema.opciones[problema.respuestaCorrecta], problema.contraCorrecta);
          expect(problema.interpretacion.isNotEmpty, isTrue);
        }
      }
    });
  });

  group('Blindaje Matemático - Fórmulas de Fondo de Pozo', () {
    test('Fórmula física de fondo de pozo', () {
      // Fondo = (Barras * LargoBarra) + Herramienta - PuntoMuerto - Contra
      const double cantidadBarras = 20.0;
      const double largoBarra = 3.00;
      const double largoHerramienta = 2.60;
      const double puntoMuerto = 0.50;
      const double contra = 1.30;

      const profundidadSarta = (cantidadBarras * largoBarra) + largoHerramienta - puntoMuerto;
      expect(profundidadSarta, 62.10);

      final fondoPozo = CalculosSondajes.redondear2(profundidadSarta - contra);
      expect(fondoPozo, 60.80);
    });

    test('Generador de Problemas de Fondo genera cálculos válidos', () {
      for (final nivel in NivelCalculo.values) {
        for (int i = 0; i < 20; i++) {
          final problema = CalculosSondajes.generarProblemaFondo(nivel);
          expect(problema.fondoCorrecto, greaterThan(0));
          expect(problema.opciones.length, 3);
          expect(problema.opciones.contains(problema.fondoCorrecto), isTrue);
          expect(problema.opciones[problema.respuestaCorrecta], problema.fondoCorrecto);
        }
      }
    });
  });

  group('Blindaje Matemático - Fórmulas de Recuperación de Testigo', () {
    test('Fórmula de porcentaje de recuperación', () {
      // % Rec = (Recuperado / Perforado) * 100
      const double perforado = 1.50;
      const double recuperado = 1.45;
      final porcentaje = CalculosSondajes.redondear2((recuperado / perforado) * 100);
      expect(porcentaje, 96.67);
    });

    test('Generador de Problemas de Recuperación genera porcentajes consistentes', () {
      for (final nivel in NivelCalculo.values) {
        for (int i = 0; i < 20; i++) {
          final problema = CalculosSondajes.generarProblemaRecuperacion(nivel);
          expect(problema.porcentajeCorrecto, greaterThanOrEqualTo(0));
          expect(problema.porcentajeCorrecto, lessThanOrEqualTo(105.0));
          expect(problema.opciones.length, 3);
          expect(problema.opciones.contains(problema.porcentajeCorrecto), isTrue);
          expect(problema.opciones[problema.respuestaCorrecta], problema.porcentajeCorrecto);
        }
      }
    });
  });

  group('Blindaje Matemático - Fórmulas de Regularización y Perforado', () {
    test('Generador de Problemas de Regularización es consistente', () {
      for (final nivel in NivelCalculo.values) {
        for (int i = 0; i < 15; i++) {
          final problema = CalculosSondajes.generarProblemaRegularizacion(nivel);
          expect(problema.opciones.length, 3);
          expect(problema.opciones.contains(problema.distanciaCorrecta), isTrue);
          expect(problema.opciones[problema.respuestaCorrecta], problema.distanciaCorrecta);
        }
      }
    });

    test('Generador de Problemas de Perforado es consistente', () {
      for (final nivel in NivelCalculo.values) {
        for (int i = 0; i < 15; i++) {
          final problema = CalculosSondajes.generarProblemaPerforado(nivel);
          expect(problema.perforadoCorrecto, greaterThan(0));
          expect(problema.opciones.length, 3);
          expect(problema.opciones.contains(problema.perforadoCorrecto), isTrue);
          expect(problema.opciones[problema.respuestaCorrecta], problema.perforadoCorrecto);
        }
      }
    });

    test('Generador de Ronda de 15 Ejercicios genera exactamente 15 ejercicios válidos', () {
      final ronda = CalculosSondajes.generarRonda15Ejercicios(NivelCalculo.medio);
      expect(ronda.length, 15);
      for (final ejercicio in ronda) {
        expect(ejercicio.enunciado.isNotEmpty, isTrue);
        expect(ejercicio.opciones.length, greaterThanOrEqualTo(2));
        expect(ejercicio.correcta, greaterThanOrEqualTo(0));
        expect(ejercicio.correcta, lessThan(ejercicio.opciones.length));
      }
    });
  });
}
