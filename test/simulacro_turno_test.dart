import 'package:flutter_test/flutter_test.dart';
import 'package:aprender_a_controlar/models/simulacro_turno_model.dart';

void main() {
  group('Pruebas del Simulador de Turno de Perforación Diamantina', () {
    test('Generación de Configuración Física Coherente', () {
      final config = GeneradorSimulacion.generarConfiguracion('Básico');
      
      expect(config.pm, equals(0.50));
      expect(config.largoBarra, equals(3.00));
      expect(config.largoTuboSacamuestras, equals(3.00));
      expect(config.nBarrasIniciales, greaterThan(10));
      expect(config.fondoInicial, greaterThanOrEqualTo(40.0));
      expect(config.fondoInicial, lessThanOrEqualTo(160.0));
    });

    test('Cálculo de Avance y Fondo SIN adición de barra', () {
      final corrida = CorridaSimulada(
        numero: 1,
        fondoAnterior: 100.0,
        contraAnterior: 2.80,
        conAdicionBarra: false,
        testigoMedidoBandeja: 2.16,
        contraNueva: 0.40,
        eventoDescripcion: 'Tramo de roca continua competente',
      );

      // Avance = ContraAnterior - ContraNueva
      // Avance = 2.80 - 0.40 = 2.40 m
      expect(corrida.avanceEsperado, equals(2.40));
      
      // Fondo Hasta = FondoAnterior + Avance
      // Fondo Hasta = 100.0 + 2.40 = 102.40 m
      expect(corrida.fondoHastaEsperado, equals(102.40));

      // % Recuperación = (2.16 / 2.40) * 100 = 90.0%
      expect(corrida.recuperacionEsperada, equals(90.0));

      // Pérdida = 2.40 - 2.16 = 0.24 m
      expect(corrida.perdidaEsperada, equals(0.24));
    });

    test('Cálculo de Avance y Fondo CON adición de barra (3.00m)', () {
      final corrida = CorridaSimulada(
        numero: 2,
        fondoAnterior: 102.40,
        contraAnterior: 0.40,
        conAdicionBarra: true,
        testigoMedidoBandeja: 2.00,
        contraNueva: 1.00,
        eventoDescripcion: 'Maniobra con adición de barra de 3.00m',
      );

      // Avance = (ContraAnterior + 3.00) - ContraNueva
      // Avance = (0.40 + 3.00) - 1.00 = 2.40 m
      expect(corrida.avanceEsperado, equals(2.40));
      
      // Fondo Hasta = 102.40 + 2.40 = 104.80 m
      expect(corrida.fondoHastaEsperado, equals(104.80));

      // % Recuperación = (2.00 / 2.40) * 100 = 83.3%
      expect(corrida.recuperacionEsperada, equals(83.3));

      // Pérdida = 2.40 - 2.00 = 0.40 m
      expect(corrida.perdidaEsperada, equals(0.40));
    });

    test('Validación de respuestas del usuario con tolerancias de terreno', () {
      final corrida = CorridaSimulada(
        numero: 1,
        fondoAnterior: 50.0,
        contraAnterior: 2.50,
        conAdicionBarra: false,
        testigoMedidoBandeja: 1.80,
        contraNueva: 0.50,
        eventoDescripcion: 'Testigo continuo',
      );

      // Avance esperado: 2.00 m
      // Fondo hasta esperado: 52.00 m
      // Recuperación esperada: 90.0%
      // Pérdida esperada: 0.20 m

      // Caso 1: Respuestas exactamente correctas
      corrida.avanceIngresado = 2.00;
      corrida.fondoHastaIngresado = 52.00;
      corrida.recuperacionIngresada = 90.0;
      corrida.perdidaIngresada = 0.20;
      expect(corrida.todoCorrecto, isTrue);

      // Caso 2: Respuestas dentro de tolerancia (±0.02 m / ±0.5%)
      corrida.avanceIngresado = 2.01; // ok
      corrida.fondoHastaIngresado = 51.99; // ok
      corrida.recuperacionIngresada = 90.3; // ok (tolera hasta 0.5%)
      corrida.perdidaIngresada = 0.19; // ok
      expect(corrida.todoCorrecto, isTrue);

      // Caso 3: Respuestas fuera de tolerancia
      corrida.avanceIngresado = 2.05; // incorrecto (> 0.02)
      expect(corrida.isAvanceCorrecto, isFalse);
      expect(corrida.todoCorrecto, isFalse);
    });
  });
}
