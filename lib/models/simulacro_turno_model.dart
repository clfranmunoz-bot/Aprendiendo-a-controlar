import 'dart:math';

class TurnoConfiguracion {
  final String dificultad;
  final double fondoInicial;
  final double pm; // Punto Muerto / stick-up reference
  final double largoBarra;
  final double largoTuboSacamuestras;
  final int nBarrasIniciales;
  final String diametro;

  const TurnoConfiguracion({
    required this.dificultad,
    required this.fondoInicial,
    required this.pm,
    required this.largoBarra,
    required this.largoTuboSacamuestras,
    required this.nBarrasIniciales,
    required this.diametro,
  });
}

class CorridaSimulada {
  final int numero;
  final double fondoAnterior;
  final double contraAnterior;
  final bool conAdicionBarra;
  final double testigoMedidoBandeja;
  final double contraNueva;
  final String eventoDescripcion;

  // Respuestas del usuario
  double? avanceIngresado;
  double? fondoHastaIngresado;
  double? recuperacionIngresada;
  double? perdidaIngresada;

  CorridaSimulada({
    required this.numero,
    required this.fondoAnterior,
    required this.contraAnterior,
    required this.conAdicionBarra,
    required this.testigoMedidoBandeja,
    required this.contraNueva,
    required this.eventoDescripcion,
  });

  // Avance = (Contra Anterior + [3.00 si hay adición]) - Contra Nueva
  double get avanceEsperado => conAdicionBarra
      ? double.parse(((contraAnterior + 3.0) - contraNueva).toStringAsFixed(2))
      : double.parse((contraAnterior - contraNueva).toStringAsFixed(2));

  // Fondo Nuevo = Fondo Anterior + Avance
  double get fondoHastaEsperado => double.parse((fondoAnterior + avanceEsperado).toStringAsFixed(2));

  // % Recuperación = (Testigo Medido / Avance) * 100
  double get recuperacionEsperada => double.parse(((testigoMedidoBandeja / avanceEsperado) * 100).toStringAsFixed(1));

  // Pérdida = Avance - Testigo Medido
  double get perdidaEsperada => double.parse((avanceEsperado - testigoMedidoBandeja).toStringAsFixed(2));

  // Validaciones con tolerancias geológicas de faena
  bool get isAvanceCorrecto => avanceIngresado != null && (avanceIngresado! - avanceEsperado).abs() <= 0.02;
  bool get isFondoHastaCorrecto => fondoHastaIngresado != null && (fondoHastaIngresado! - fondoHastaEsperado).abs() <= 0.02;
  bool get isRecuperacionCorrecta => recuperacionIngresada != null && (recuperacionIngresada! - recuperacionEsperada).abs() <= 0.5;
  bool get isPerdidaCorrecta => perdidaIngresada != null && (perdidaIngresada! - perdidaEsperada).abs() <= 0.02;

  bool get todoCorrecto => isAvanceCorrecto && isFondoHastaCorrecto && isRecuperacionCorrecta && isPerdidaCorrecta;
}

class GeneradorSimulacion {
  static final Random _rng = Random();

  static TurnoConfiguracion generarConfiguracion(String dificultad) {
    // Fondo inicial realista de perforación diamantina
    final double fondoInicial = 40.0 + _rng.nextInt(120); // 40 a 160 m
    const double pm = 0.50; // Punto Muerto estándar
    const double largoBarra = 3.0; // Barras de 3 metros estándar en minería chilena
    const double largoTuboSacamuestras = 3.0;

    // Número de barras iniciales coherente físicamente con la profundidad del pozo
    // Profundidad = (nBarras * largoBarra) + tuboSacamuestras - contraAnterior - PM
    // Por lo tanto, nBarras es aproximadamente (Fondo - 3) / 3
    final int nBarrasIniciales = ((fondoInicial - largoTuboSacamuestras) / largoBarra).floor();

    return TurnoConfiguracion(
      dificultad: dificultad,
      fondoInicial: double.parse(fondoInicial.toStringAsFixed(2)),
      pm: pm,
      largoBarra: largoBarra,
      largoTuboSacamuestras: largoTuboSacamuestras,
      nBarrasIniciales: nBarrasIniciales,
      diametro: 'HQ',
    );
  }

  static List<CorridaSimulada> generarCorridas(TurnoConfiguracion config) {
    final int nCorridas = config.dificultad == 'Básico' ? 3 : config.dificultad == 'Intermedio' ? 4 : 5;
    final List<CorridaSimulada> lista = [];
    double currentFondo = config.fondoInicial;
    double currentContra = 2.80 - (_rng.nextInt(8) * 0.20); // 1.40 a 2.80 m

    final eventListBasic = [
      'Tramo de roca continua competente (Granodiorita).',
      'Paso por zona competente. Perforación estable.',
      'Testigo continuo y sano. Avance uniforme.',
    ];

    final eventListIntermediate = [
      'Inicio de maniobra estable. Testigo continuo.',
      'Contacto litológico. Cambio leve de dureza.',
      'Paso por tramo con diaclasas leves. Pérdida parcial.',
      'Avance estable. Testigo con fracturas de enfriamiento.',
    ];

    final eventListAdvanced = [
      'Zona fracturada. Controlar vibración.',
      'Presencia de tramos de alteración arcillosa. Cuidado con pérdida.',
      'Maniobra rápida. Testigo sano competente.',
      'Tramo altamente diaclasado. Pérdida importante.',
      'Contacto con zona de falla. Arcillas de falla y roca molida.',
    ];

    final descs = config.dificultad == 'Básico'
        ? eventListBasic
        : config.dificultad == 'Intermedio'
            ? eventListIntermediate
            : eventListAdvanced;

    for (int i = 0; i < nCorridas; i++) {
      // Determinar si hay adición de barra en esta corrida
      // En nivel básico no hay adición. En intermedio/avanzado sí.
      bool adicion = false;
      if (config.dificultad == 'Intermedio' && i == 2) {
        adicion = true;
      } else if (config.dificultad == 'Avanzado' && (i == 1 || i == 3)) {
        adicion = true;
      }

      // Contra nueva debe ser menor que contra anterior, a menos que haya adición.
      double contraNueva;
      if (adicion) {
        // Se rosca barra de 3m. El avance suele ser de 1.50 a 2.80 m.
        // Avance = (contraAnterior + 3) - contraNueva
        final double avance = 1.60 + (_rng.nextInt(12) * 0.10);
        contraNueva = double.parse(((currentContra + 3.0) - avance).toStringAsFixed(2));
      } else {
        // Avance = contraAnterior - contraNueva
        // Si contraAnterior es baja, obligar a adición o avance pequeño
        final double maxAvance = currentContra - 0.20;
        final double avance = maxAvance <= 0.8
            ? 0.50 + (_rng.nextInt(4) * 0.10)
            : 1.00 + (_rng.nextInt((maxAvance * 10 - 10).floor().clamp(1, 20)) * 0.10);
        
        contraNueva = double.parse((currentContra - avance).toStringAsFixed(2));
        if (contraNueva < 0.10) {
          contraNueva = 0.20;
        }
      }

      // Calcular avance exacto
      final double avanceReal = adicion
          ? double.parse(((currentContra + 3.0) - contraNueva).toStringAsFixed(2))
          : double.parse((currentContra - contraNueva).toStringAsFixed(2));

      // Determinar porcentaje de recuperación
      double recPct = 1.0;
      if (config.dificultad == 'Básico') {
        recPct = 0.92 + (_rng.nextDouble() * 0.08); // 92% a 100%
      } else if (config.dificultad == 'Intermedio') {
        recPct = 0.82 + (_rng.nextDouble() * 0.15); // 82% a 97%
      } else {
        recPct = 0.60 + (_rng.nextDouble() * 0.35); // 60% a 95%
      }

      final double testigoMedido = double.parse((avanceReal * recPct).toStringAsFixed(2));
      
      lista.add(CorridaSimulada(
        numero: i + 1,
        fondoAnterior: double.parse(currentFondo.toStringAsFixed(2)),
        contraAnterior: double.parse(currentContra.toStringAsFixed(2)),
        conAdicionBarra: adicion,
        testigoMedidoBandeja: testigoMedido,
        contraNueva: contraNueva,
        eventoDescripcion: descs[i % descs.length],
      ));

      // Avanzar el fondo del pozo
      currentFondo += avanceReal;
      currentContra = contraNueva;
    }

    return lista;
  }
}
