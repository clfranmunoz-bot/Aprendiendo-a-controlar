import 'dart:math';
import '../models/problema.dart';
import '../models/ejercicio.dart';

class CalculosSondajes {
  static final _random = Random();

  static double redondear2(double valor) {
    return (valor * 100).round() / 100.0;
  }

  static String formato(double valor) {
    return valor.toStringAsFixed(2);
  }

  static int _randRange(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }

  static T _randomChoice<T>(List<T> list) {
    return list[_random.nextInt(list.length)];
  }

  static double _generarLargoBarril() {
    final barrilBase = _randomChoice([2.60, 4.15]);
    final extensionReflex = _randomChoice([0.00, 0.40]);
    return redondear2(barrilBase + extensionReflex);
  }

  // 1. GENERAR PROBLEMA CONTRA
  static ProblemaContra generarProblemaContra(NivelContra nivel) {
    final usarMetodoNuevo = _random.nextBool();
    if (usarMetodoNuevo) {
      return _generarProblemaContraNuevoMetodo(nivel);
    }
    return switch (nivel) {
      NivelContra.basico => _generarProblemaContraBasico(),
      NivelContra.medio => _generarProblemaContraMedio(),
      NivelContra.avanzado => _generarProblemaContraAvanzado(),
    };
  }

  static ProblemaContra _generarProblemaContraNuevoMetodo(NivelContra nivel) {
    final largoBarra = _randomChoice([2.90, 3.00]);
    final requiereBarraAdicional = _random.nextBool();

    double contraAnterior = 0.0;
    double perforado = 0.0;

    if (requiereBarraAdicional) {
      contraAnterior = switch (nivel) {
        NivelContra.basico => _randomChoice([0.50, 0.80, 1.00, 1.20]),
        NivelContra.medio => redondear2(_randRange(50, 150) / 100.0),
        NivelContra.avanzado => redondear2(_randRange(40, 140) / 100.0),
      };
      perforado = switch (nivel) {
        NivelContra.basico => _randomChoice([1.50, 1.80, 2.00]),
        NivelContra.medio => redondear2(_randRange(160, 250) / 100.0),
        NivelContra.avanzado => redondear2(_randRange(150, 280) / 100.0),
      };
    } else {
      contraAnterior = switch (nivel) {
        NivelContra.basico => _randomChoice([1.80, 2.00, 2.50]),
        NivelContra.medio => redondear2(_randRange(200, 450) / 100.0),
        NivelContra.avanzado => redondear2(_randRange(250, 550) / 100.0),
      };
      perforado = switch (nivel) {
        NivelContra.basico => _randomChoice([0.50, 0.80, 1.00, 1.20]),
        NivelContra.medio => redondear2(_randRange(50, 180) / 100.0),
        NivelContra.avanzado => redondear2(_randRange(80, 240) / 100.0),
      };
      if (contraAnterior < perforado) {
        final temp = contraAnterior;
        contraAnterior = perforado;
        perforado = temp;
      }
    }

    final contraAnteriorAjustada = contraAnterior < perforado
        ? contraAnterior + largoBarra
        : contraAnterior;
    final contraCorrecta = redondear2(contraAnteriorAjustada - perforado);

    final distractores = <double>{};
    while (distractores.length < 2) {
      final diferencia = switch (nivel) {
        NivelContra.basico => _randomChoice([-0.50, -0.30, 0.30, 0.50]),
        NivelContra.medio => _randomChoice([-0.25, -0.15, 0.15, 0.25]),
        NivelContra.avanzado => _randomChoice([-0.35, -0.08, 0.08, 0.35]),
      };
      final posible = redondear2(contraCorrecta + diferencia);
      if (posible != contraCorrecta && posible > 0) {
        distractores.add(posible);
      }
    }
    final opciones = (distractores.toList() + [contraCorrecta])..shuffle();
    final respuestaCorrecta = opciones.indexOf(contraCorrecta);

    final interpretacion = contraAnterior < perforado
        ? "Interpretación: Como la contra anterior (${formato(contraAnterior)} m) es menor al metraje perforado (${formato(perforado)} m), significa operacionalmente que se agregó una nueva barra de ${formato(largoBarra)} m. Por lo tanto, se ajusta la contra anterior: ${formato(contraAnterior)} m + ${formato(largoBarra)} m = ${formato(contraAnteriorAjustada)} m, y luego se resta el perforado: ${formato(contraAnteriorAjustada)} m - ${formato(perforado)} m = ${formato(contraCorrecta)} m."
        : "Interpretación: Como la contra anterior (${formato(contraAnterior)} m) es mayor o igual al metraje perforado (${formato(perforado)} m), se resta directamente: ${formato(contraAnterior)} m - ${formato(perforado)} m = ${formato(contraCorrecta)} m.";

    return ProblemaContra(
      nivel: nivel,
      cantidadBarras: null,
      largoBarra: largoBarra,
      largoHerramienta: null,
      puntoMuerto: null,
      fondoPozo: null,
      contraCorrecta: contraCorrecta,
      opciones: opciones,
      respuestaCorrecta: respuestaCorrecta,
      interpretacion: interpretacion,
      contraAnterior: contraAnterior,
      perforado: perforado,
      metodoUsado: "anterior_perforado",
    );
  }

  static ProblemaContra _generarProblemaContraBasico() {
    final cantidadBarras = _randRange(40, 100).toDouble();
    const largoBarra = 3.00;
    final largoHerramienta = _generarLargoBarril();
    final puntoMuerto = _randomChoice([0.50, 0.60, 0.70, 0.80, 0.90]);
    final contraCorrecta = _randomChoice([
      0.30,
      0.50,
      0.60,
      0.70,
      1.00,
      1.20,
      1.50,
    ]);

    final profundidadCalculada =
        cantidadBarras * largoBarra + largoHerramienta - puntoMuerto;
    final fondoPozo = redondear2(profundidadCalculada - contraCorrecta);

    return _crearProblemaConOpciones(
      nivel: NivelContra.basico,
      cantidadBarras: cantidadBarras,
      largoBarra: largoBarra,
      largoHerramienta: largoHerramienta,
      puntoMuerto: puntoMuerto,
      fondoPozo: fondoPozo,
      contraCorrecta: contraCorrecta,
    );
  }

  static ProblemaContra _generarProblemaContraMedio() {
    final cantidadBarras = _randRange(35, 120).toDouble();
    final largoBarra = _randomChoice([1.50, 3.00, 3.05]);
    final largoHerramienta = _generarLargoBarril();
    final puntoMuerto = redondear2(_randRange(40, 110) / 100.0);

    final maxCentimos = ((largoBarra - 0.05) * 100).toInt();
    final randomCentimos = _randRange(10, maxCentimos);
    final contraCorrecta = redondear2(randomCentimos / 100.0);

    final profundidadCalculada =
        cantidadBarras * largoBarra + largoHerramienta - puntoMuerto;
    final fondoPozo = redondear2(profundidadCalculada - contraCorrecta);

    return _crearProblemaConOpciones(
      nivel: NivelContra.medio,
      cantidadBarras: cantidadBarras,
      largoBarra: largoBarra,
      largoHerramienta: largoHerramienta,
      puntoMuerto: puntoMuerto,
      fondoPozo: fondoPozo,
      contraCorrecta: contraCorrecta,
    );
  }

  static ProblemaContra _generarProblemaContraAvanzado() {
    final cantidadBarras = _randRange(30, 130).toDouble();
    final largoBarra = _randomChoice([1.50, 3.00, 3.05]);
    final largoHerramienta = _generarLargoBarril();
    final puntoMuerto = redondear2(_randRange(40, 120) / 100.0);

    final tipoCaso = _randRange(1, 3);
    double contraCorrecta;
    if (tipoCaso == 1) {
      final maxCentimos = ((largoBarra - 0.05) * 100).toInt();
      final randomCentimos = _randRange(10, maxCentimos);
      contraCorrecta = redondear2(randomCentimos / 100.0);
    } else if (tipoCaso == 2) {
      // Caso anomalía: contra muy pequeña (cercana a cero) pero positiva
      contraCorrecta = redondear2(_randRange(1, 29) / 100.0);
    } else {
      final minCentimos = ((largoBarra + 0.10) * 100).toInt();
      final maxCentimos = ((largoBarra + 1.50) * 100).toInt();
      contraCorrecta = redondear2(_randRange(minCentimos, maxCentimos) / 100.0);
    }

    final profundidadCalculada =
        cantidadBarras * largoBarra + largoHerramienta - puntoMuerto;
    final fondoPozo = redondear2(profundidadCalculada - contraCorrecta);

    return _crearProblemaConOpciones(
      nivel: NivelContra.avanzado,
      cantidadBarras: cantidadBarras,
      largoBarra: largoBarra,
      largoHerramienta: largoHerramienta,
      puntoMuerto: puntoMuerto,
      fondoPozo: fondoPozo,
      contraCorrecta: contraCorrecta,
    );
  }

  static ProblemaContra _crearProblemaConOpciones({
    required NivelContra nivel,
    required double cantidadBarras,
    required double largoBarra,
    required double largoHerramienta,
    required double puntoMuerto,
    required double fondoPozo,
    required double contraCorrecta,
  }) {
    final opciones = _generarOpcionesContra(contraCorrecta, largoBarra, nivel);
    final respuestaCorrecta = opciones.indexOf(contraCorrecta);
    final interpretacion = _interpretarContra(contraCorrecta, largoBarra);

    return ProblemaContra(
      nivel: nivel,
      cantidadBarras: cantidadBarras,
      largoBarra: largoBarra,
      largoHerramienta: largoHerramienta,
      puntoMuerto: puntoMuerto,
      fondoPozo: fondoPozo,
      contraCorrecta: contraCorrecta,
      opciones: opciones,
      respuestaCorrecta: respuestaCorrecta,
      interpretacion: interpretacion,
      metodoUsado: "fisico",
    );
  }

  static List<double> _generarOpcionesContra(
    double correcta,
    double largoBarra,
    NivelContra nivel,
  ) {
    final distractores = <double>{};
    while (distractores.length < 2) {
      final diferencia = switch (nivel) {
        NivelContra.basico => _randomChoice([-1.00, -0.50, 0.50, 1.00]),
        NivelContra.medio => _randomChoice([
          -0.40,
          -0.30,
          -0.20,
          0.20,
          0.30,
          0.40,
        ]),
        NivelContra.avanzado => _randomChoice([
          -1.20,
          -0.75,
          -0.35,
          0.35,
          0.75,
          1.20,
        ]),
      };
      final posible = redondear2(correcta + diferencia);
      if (posible != correcta && posible >= 0.0) {
        distractores.add(posible);
      }
    }
    return (distractores.toList() + [correcta])..shuffle();
  }

  static String _interpretarContra(double contra, double largoBarra) {
    if (contra < 0) {
      return "Interpretación: la contra es negativa. Se deben revisar cantidad de barras, largo de barra, largo de barril, punto muerto o fondo del pozo.";
    } else if (contra == 0.0) {
      return "Interpretación: no se obtiene contra estimada. Verificar con el perforista si corresponde registrar contra cero.";
    } else if (contra > largoBarra) {
      return "Interpretación: la contra supera el largo de una barra. Se deben revisar los datos ingresados.";
    } else {
      return "Interpretación: contra dentro de rango esperable. Confirmar con el perforista antes de registrar.";
    }
  }

  // 2. GENERAR PROBLEMA FONDO
  static ProblemaFondo generarProblemaFondo(NivelCalculo nivel) {
    final cantidadBarras = switch (nivel) {
      NivelCalculo.basico => _randRange(40, 100).toDouble(),
      NivelCalculo.medio => _randRange(35, 120).toDouble(),
      NivelCalculo.avanzado => _randRange(30, 130).toDouble(),
    };

    final largoBarra = switch (nivel) {
      NivelCalculo.basico => 3.00,
      NivelCalculo.medio => _randomChoice([1.50, 3.00, 3.05]),
      NivelCalculo.avanzado => _randomChoice([1.50, 3.00, 3.05]),
    };

    final largoHerramienta = _generarLargoBarril();

    final puntoMuerto = switch (nivel) {
      NivelCalculo.basico => _randomChoice([0.50, 0.60, 0.70, 0.80, 0.90]),
      NivelCalculo.medio => redondear2(_randRange(40, 110) / 100.0),
      NivelCalculo.avanzado => redondear2(_randRange(40, 120) / 100.0),
    };

    final contra = switch (nivel) {
      NivelCalculo.basico => _randomChoice([
        0.30,
        0.50,
        0.60,
        0.70,
        1.00,
        1.20,
      ]),
      NivelCalculo.medio => redondear2(
        _randRange(10, ((largoBarra - 0.05) * 100).toInt()) / 100.0,
      ),
      NivelCalculo.avanzado => () {
        final tipoCaso = _randRange(1, 3);
        return switch (tipoCaso) {
          1 => redondear2(
            _randRange(10, ((largoBarra - 0.05) * 100).toInt()) / 100.0,
          ),
          2 => redondear2(
            _randRange(
                  ((largoBarra + 0.10) * 100).toInt(),
                  ((largoBarra + 1.50) * 100).toInt(),
                ) /
                100.0,
          ),
          _ => redondear2(_randRange(0, (largoBarra * 100).toInt()) / 100.0),
        };
      }(),
    };

    final fondoCorrecto = redondear2(
      (cantidadBarras * largoBarra) + largoHerramienta - puntoMuerto - contra,
    );

    final opciones = _generarOpcionesNumericas(
      fondoCorrecto,
      nivel,
      permitirNegativos: false,
    );
    final respuestaCorrecta = opciones.indexOf(fondoCorrecto);

    return ProblemaFondo(
      nivel: nivel,
      cantidadBarras: cantidadBarras,
      largoBarra: largoBarra,
      largoHerramienta: largoHerramienta,
      puntoMuerto: puntoMuerto,
      contra: contra,
      fondoCorrecto: fondoCorrecto,
      opciones: opciones,
      respuestaCorrecta: respuestaCorrecta,
      interpretacion: _interpretarFondo(fondoCorrecto, contra, largoBarra),
    );
  }

  static String _interpretarFondo(
    double fondo,
    double contra,
    double largoBarra,
  ) {
    if (fondo < 0) {
      return "Interpretación: resultado no válido. Revisa cantidad de barras, largo de barra, largo de barril, punto muerto o contra.";
    } else if (contra > largoBarra) {
      return "Interpretación: la contra ingresada supera el largo de una barra. Verifica el dato con el perforista.";
    } else {
      return "Interpretación: fondo estimado calculado. Confirmar con los datos operacionales antes de registrar.";
    }
  }

  static List<double> _generarOpcionesNumericas(
    double correcta,
    NivelCalculo nivel, {
    required bool permitirNegativos,
  }) {
    final distractores = <double>{};
    while (distractores.length < 2) {
      final diferencia = switch (nivel) {
        NivelCalculo.basico => _randomChoice([-1.00, -0.50, 0.50, 1.00]),
        NivelCalculo.medio => _randomChoice([
          -0.40,
          -0.30,
          -0.20,
          0.20,
          0.30,
          0.40,
        ]),
        NivelCalculo.avanzado => _randomChoice([
          -1.20,
          -0.75,
          -0.35,
          0.35,
          0.75,
          1.20,
        ]),
      };
      final posible = redondear2(correcta + diferencia);
      if (posible != correcta && (permitirNegativos || posible >= 0.0)) {
        distractores.add(posible);
      }
    }
    return (distractores.toList() + [correcta])..shuffle();
  }

  // 3. GENERAR PROBLEMA RECUPERACION
  static ProblemaRecuperacion generarProblemaRecuperacion(NivelCalculo nivel) {
    final perforado = switch (nivel) {
      NivelCalculo.basico => _randomChoice([1.00, 1.50, 2.00, 2.50, 3.00]),
      NivelCalculo.medio => redondear2(_randRange(80, 310) / 100.0),
      NivelCalculo.avanzado => redondear2(_randRange(50, 320) / 100.0),
    };

    final recuperado = switch (nivel) {
      NivelCalculo.basico => () {
        final porcentaje = _randomChoice([50.0, 60.0, 70.0, 80.0, 90.0, 100.0]);
        return redondear2(perforado * porcentaje / 100.0);
      }(),
      NivelCalculo.medio => () {
        final porcentaje = _randRange(450, 1000) / 10.0;
        return redondear2(perforado * porcentaje / 100.0);
      }(),
      NivelCalculo.avanzado => () {
        final tipoCaso = _randRange(1, 3);
        final porcentaje = switch (tipoCaso) {
          1 => _randRange(200, 500) / 10.0,
          2 => _randRange(500, 750) / 10.0,
          _ => _randRange(750, 1000) / 10.0,
        };
        return redondear2(perforado * porcentaje / 100.0);
      }(),
    };

    final porcentajeCorrecto = redondear2((recuperado / perforado) * 100);
    final opciones = _generarOpcionesPorcentaje(porcentajeCorrecto, nivel);
    final respuestaCorrecta = opciones.indexOf(porcentajeCorrecto);

    return ProblemaRecuperacion(
      nivel: nivel,
      perforado: perforado,
      recuperado: recuperado,
      porcentajeCorrecto: porcentajeCorrecto,
      opciones: opciones,
      respuestaCorrecta: respuestaCorrecta,
      interpretacion: _interpretarRecuperacion(porcentajeCorrecto),
    );
  }

  static String _interpretarRecuperacion(double porcentaje) {
    if (porcentaje > 100) {
      return "Interpretación: ¡Cálculo Inválido! La recuperación supera el 100%. No se puede recuperar más de lo que se perfora.";
    } else if (porcentaje >= 90) {
      return "Interpretación: muy buena recuperación. Mantener registro claro del tramo.";
    } else if (porcentaje >= 70) {
      return "Interpretación: recuperación aceptable. Revisar estado del testigo y compactación.";
    } else if (porcentaje >= 50) {
      return "Interpretación: recuperación baja. Registrar observación y condición de muestra.";
    } else {
      return "Interpretación: recuperación crítica. Comunicar al supervisor y dejar registro.";
    }
  }

  static List<double> _generarOpcionesPorcentaje(
    double correcta,
    NivelCalculo nivel,
  ) {
    final distractores = <double>{};
    while (distractores.length < 2) {
      final diferencia = switch (nivel) {
        NivelCalculo.basico => _randomChoice([-20.0, -10.0, 10.0, 20.0]),
        NivelCalculo.medio => _randomChoice([
          -15.0,
          -7.5,
          -5.0,
          5.0,
          7.5,
          15.0,
        ]),
        NivelCalculo.avanzado => _randomChoice([
          -25.0,
          -12.0,
          -6.0,
          6.0,
          12.0,
          25.0,
        ]),
      };
      final posible = redondear2(correcta + diferencia);
      if (posible >= 0 && posible != correcta) {
        distractores.add(posible);
      }
    }
    return (distractores.toList() + [correcta])..shuffle();
  }

  // 4. GENERAR PROBLEMA REGULARIZACION
  static ProblemaRegularizacion generarProblemaRegularizacion(
    NivelCalculo nivel,
  ) {
    final metrajeRegularizar = switch (nivel) {
      NivelCalculo.basico => (_randRange(51, 150) * 2).toDouble(),
      NivelCalculo.medio => (_randRange(151, 750) * 2).toDouble(),
      NivelCalculo.avanzado => (_randRange(151, 750) * 2).toDouble(),
    };

    final distanciaTeorica = switch (nivel) {
      NivelCalculo.basico => _randomChoice([0.50, 1.00, 1.50, 2.00]),
      NivelCalculo.medio => redondear2(_randRange(20, 200) / 100.0),
      NivelCalculo.avanzado => redondear2(_randRange(10, 300) / 100.0),
    };

    final tacoInicial = redondear2(metrajeRegularizar - distanciaTeorica);

    final perforado = switch (nivel) {
      NivelCalculo.basico => () {
        final opcionesValidas = [
          1.50,
          2.00,
          2.50,
          3.00,
        ].where((x) => x > distanciaTeorica).toList();
        return opcionesValidas.isNotEmpty
            ? _randomChoice(opcionesValidas)
            : 3.00;
      }(),
      NivelCalculo.medio => redondear2(
        distanciaTeorica + _randRange(20, 150) / 100.0,
      ),
      NivelCalculo.avanzado => redondear2(
        distanciaTeorica + _randRange(10, 180) / 100.0,
      ),
    };

    final tacoFinal = redondear2(tacoInicial + perforado);

    final recuperacionObjetivo = switch (nivel) {
      NivelCalculo.basico => _randomChoice([70.0, 80.0, 90.0, 100.0]),
      NivelCalculo.medio => _randRange(550, 1000) / 10.0,
      NivelCalculo.avanzado => () {
        final tipoCaso = _randRange(1, 3);
        return switch (tipoCaso) {
          1 => _randRange(300, 550) / 10.0,
          2 => _randRange(550, 900) / 10.0,
          _ => _randRange(900, 1000) / 10.0,
        };
      }(),
    };

    final recuperado = redondear2(perforado * recuperacionObjetivo / 100.0);
    final distanciaCorrecta = redondear2(
      distanciaTeorica * recuperado / perforado,
    );
    final recuperacionPorcentaje = redondear2(recuperado / perforado * 100.0);

    final opciones = _generarOpcionesRegularizacion(distanciaCorrecta, nivel);
    final respuestaCorrecta = opciones.indexOf(distanciaCorrecta);

    return ProblemaRegularizacion(
      nivel: nivel,
      tacoInicial: tacoInicial,
      tacoFinal: tacoFinal,
      recuperado: recuperado,
      metrajeRegularizar: metrajeRegularizar,
      distanciaCorrecta: distanciaCorrecta,
      recuperacionPorcentaje: recuperacionPorcentaje,
      opciones: opciones,
      respuestaCorrecta: respuestaCorrecta,
      interpretacion: _interpretarRegularizacion(recuperacionPorcentaje),
    );
  }

  static String _interpretarRegularizacion(double recuperacion) {
    if (recuperacion > 100) {
      return "Interpretación: ¡Cálculo Inválido! La recuperación supera el 100%. No se puede regularizar con más del 100%.";
    } else if (recuperacion >= 90) {
      return "Interpretación: muy buena recuperación. La ubicación del regularizado debería ser más directa.";
    } else if (recuperacion >= 70) {
      return "Interpretación: recuperación aceptable. Aplicar cálculo y criterio geológico.";
    } else if (recuperacion >= 50) {
      return "Interpretación: recuperación baja. Revisar condición de testigo antes de marcar.";
    } else {
      return "Interpretación: recuperación crítica. Requiere criterio geológico y registro claro del ajuste.";
    }
  }

  static List<double> _generarOpcionesRegularizacion(
    double correcta,
    NivelCalculo nivel,
  ) {
    final distractores = <double>{};
    while (distractores.length < 2) {
      final diferencia = switch (nivel) {
        NivelCalculo.basico => _randomChoice([-0.50, -0.30, 0.30, 0.50]),
        NivelCalculo.medio => _randomChoice([
          -0.25,
          -0.15,
          -0.10,
          0.10,
          0.15,
          0.25,
        ]),
        NivelCalculo.avanzado => _randomChoice([
          -0.40,
          -0.20,
          -0.08,
          0.08,
          0.20,
          0.40,
        ]),
      };
      final posible = redondear2(correcta + diferencia);
      if (posible >= 0 && posible != correcta) {
        distractores.add(posible);
      }
    }
    return (distractores.toList() + [correcta])..shuffle();
  }

  // 5. GENERAR PROBLEMA PERFORADO
  static ProblemaPerforado generarProblemaPerforado(NivelCalculo nivel) {
    final metodo = switch (nivel) {
      NivelCalculo.basico => _randomChoice(["contras", "fondos"]),
      NivelCalculo.medio => _randomChoice(["contras", "fondos"]),
      NivelCalculo.avanzado => "ambos",
    };

    double? contraAnterior;
    double? contraActual;
    double? fondoAnterior;
    double? fondoActual;
    double? largoBarra;
    double perforadoCorrecto = 0.0;
    final sbInterpretacion = StringBuffer();

    if (metodo == "contras") {
      final seAgregoBarra = _random.nextBool();
      if (seAgregoBarra) {
        largoBarra = _randomChoice([2.90, 3.00]);
        contraAnterior = switch (nivel) {
          NivelCalculo.basico => _randomChoice([0.40, 0.60, 0.80, 1.00]),
          _ => redondear2(_randRange(30, 120) / 100.0),
        };
        perforadoCorrecto = switch (nivel) {
          NivelCalculo.basico => _randomChoice([1.50, 1.80, 2.00]),
          _ => redondear2(_randRange(150, 240) / 100.0),
        };
        contraActual = redondear2(
          (contraAnterior! + largoBarra!) - perforadoCorrecto,
        );

        sbInterpretacion.writeln(
          "• Método por Contras (Con Adición de Barra):",
        );
        sbInterpretacion.writeln(r"  LATEX: p=(c_{ant}+l_b)-c_{act}");
        sbInterpretacion.writeln(
          "  Cálculo: (${formato(contraAnterior)} m + ${formato(largoBarra)} m) - ${formato(contraActual)} m",
        );
        sbInterpretacion.writeln(
          "  Resultado: ${formato(perforadoCorrecto)} m\n",
        );
        sbInterpretacion.write(
          "💡 Tip de Terreno: Como la contra actual (${formato(contraActual)} m) es mayor a la contra anterior (${formato(contraAnterior)} m), significa que se adicionó una barra de ${formato(largoBarra)} m.",
        );
      } else {
        final baseContra = switch (nivel) {
          NivelCalculo.basico => _randomChoice([3.00, 4.00, 5.00]),
          _ => redondear2(_randRange(150, 450) / 100.0),
        };
        final perforadoVal = switch (nivel) {
          NivelCalculo.basico => _randomChoice([1.50, 2.00, 3.00]),
          _ => redondear2(_randRange(100, 300) / 100.0),
        };
        contraAnterior = redondear2(baseContra);
        contraActual = redondear2(baseContra - perforadoVal);
        perforadoCorrecto = perforadoVal;

        sbInterpretacion.writeln("• Método por Contras:");
        sbInterpretacion.writeln(r"  LATEX: p=c_{ant}-c_{act}");
        sbInterpretacion.writeln(
          "  Cálculo: ${formato(contraAnterior)} m - ${formato(contraActual)} m",
        );
        sbInterpretacion.writeln(
          "  Resultado: ${formato(perforadoCorrecto)} m\n",
        );
        sbInterpretacion.write(
          "💡 Tip de Terreno: Este método es infalible si el largo de la sarta de barras no cambió durante la corrida.",
        );
      }
    } else if (metodo == "fondos") {
      final baseFondo = switch (nivel) {
        NivelCalculo.basico => _randomChoice([30.00, 45.00, 60.00]),
        _ => redondear2(_randRange(3000, 7500) / 100.0),
      };
      final perforadoVal = switch (nivel) {
        NivelCalculo.basico => _randomChoice([1.50, 2.00, 3.00]),
        _ => redondear2(_randRange(100, 300) / 100.0),
      };
      fondoAnterior = redondear2(baseFondo);
      fondoActual = redondear2(baseFondo + perforadoVal);
      perforadoCorrecto = perforadoVal;

      sbInterpretacion.writeln("• Método por Fondos:");
      sbInterpretacion.writeln(r"  LATEX: p=f_{act}-f_{ant}");
      sbInterpretacion.writeln(
        "  Cálculo: ${formato(fondoActual)} m - ${formato(fondoAnterior)} m",
      );
      sbInterpretacion.writeln(
        "  Resultado: ${formato(perforadoCorrecto)} m\n",
      );
      sbInterpretacion.write(
        "💡 Tip de Terreno: Este método mide el avance real de la perforación en el fondo del pozo.",
      );
    } else {
      // ambos (Avanzado)
      final baseFondo = redondear2(_randRange(5000, 12000) / 100.0);
      final perforadoVal = redondear2(_randRange(120, 290) / 100.0);

      fondoAnterior = redondear2(baseFondo);
      fondoActual = redondear2(baseFondo + perforadoVal);
      perforadoCorrecto = perforadoVal;

      final seAgregoBarra = _random.nextBool();
      if (seAgregoBarra) {
        largoBarra = _randomChoice([2.90, 3.00]);
        final minContra = 20;
        final maxContra = ((perforadoVal - 0.20) * 100).toInt().clamp(30, 200);
        contraAnterior = redondear2(_randRange(minContra, maxContra) / 100.0);
        contraActual = redondear2(
          (contraAnterior + largoBarra!) - perforadoVal,
        );

        sbInterpretacion.writeln(
          "• Al contar con ambos datos, puedes validar la consistencia:",
        );
        sbInterpretacion.writeln(
          "  1. Por Contras (Barra Adicionada): (${formato(contraAnterior)} m + ${formato(largoBarra)} m) - ${formato(contraActual)} m = ${formato(perforadoCorrecto)} m",
        );
        sbInterpretacion.writeln(
          "  2. Por Fondos: ${formato(fondoActual)} m - ${formato(fondoAnterior)} m = ${formato(perforadoCorrecto)} m\n",
        );
        sbInterpretacion.write(
          "✅ Ambos métodos coinciden perfectamente en ${formato(perforadoCorrecto)} m.",
        );
      } else {
        final baseContra = redondear2(_randRange(200, 500) / 100.0);
        contraAnterior = redondear2(baseContra);
        contraActual = redondear2(baseContra - perforadoVal);

        sbInterpretacion.writeln(
          "• Al contar con ambos datos, puedes validar la consistencia:",
        );
        sbInterpretacion.writeln(
          "  1. Por Contras: ${formato(contraAnterior)} m - ${formato(contraActual)} m = ${formato(perforadoCorrecto)} m",
        );
        sbInterpretacion.writeln(
          "  2. Por Fondos: ${formato(fondoActual)} m - ${formato(fondoAnterior)} m = ${formato(perforadoCorrecto)} m\n",
        );
        sbInterpretacion.write(
          "✅ Ambos métodos coinciden perfectamente en ${formato(perforadoCorrecto)} m.",
        );
      }
    }

    final opciones = _generarOpcionesNumericas(
      perforadoCorrecto,
      nivel,
      permitirNegativos: false,
    );
    final respuestaCorrecta = opciones.indexOf(perforadoCorrecto);

    return ProblemaPerforado(
      nivel: nivel,
      contraAnterior: contraAnterior,
      contraActual: contraActual,
      fondoAnterior: fondoAnterior,
      fondoActual: fondoActual,
      largoBarra: largoBarra,
      perforadoCorrecto: perforadoCorrecto,
      opciones: opciones,
      respuestaCorrecta: respuestaCorrecta,
      interpretacion: sbInterpretacion.toString(),
      metodoUsado: metodo,
    );
  }

  static EjercicioPractico convertirContraAEjercicio(ProblemaContra problema) {
    final String enunciado;
    if (problema.metodoUsado == "anterior_perforado") {
      enunciado =
          "Calcula la contra actual con los siguientes datos operacionales:\n\n"
          "• Contra anterior: ${formato(problema.contraAnterior!)} m\n"
          "• Metraje perforado: ${formato(problema.perforado!)} m\n"
          "• Largo de barra del pozo: ${formato(problema.largoBarra)} m\n\n"
          r"LATEX: c_{act} = c_{ant} - p"
          "\n"
          r"LATEX: c_{act} = (c_{ant}+l_b) - p \quad (si\ se\ agrego\ barra)"
          "\n\n"
          "Donde:\n"
          "• c_act = contra actual\n"
          "• c_ant = contra anterior\n"
          "• p = metraje perforado\n"
          "• l_b = largo de barra\n\n"
          "⚠️ Regla de Terreno: Recuerda aplicar el ajuste de adición de barra si corresponde.";
    } else {
      enunciado =
          "Calcula la contra estimada con los siguientes datos:\n\n"
          "• Cantidad de barras: ${formato(problema.cantidadBarras!)}\n"
          "• Largo de barra: ${formato(problema.largoBarra)} m\n"
          "• Largo de barril: ${formato(problema.largoHerramienta!)} m\n"
          "• Punto muerto: ${formato(problema.puntoMuerto!)} m\n"
          "• Fondo del pozo: ${formato(problema.fondoPozo!)} m\n\n"
          r"LATEX: d=(n_b\times l_b)+l_{br}-p_m"
          "\n"
          r"LATEX: c=d-f"
          "\n\n"
          "Donde:\n"
          "• n_b = numero de barras\n"
          "• l_b = largo de barra\n"
          "• l_{br} = largo de barril\n"
          "• p_m = punto muerto\n"
          "• d = profundidad calculada\n"
          "• f = fondo del pozo\n"
          "• c = contra";
    }

    final String retro;
    if (problema.metodoUsado == "anterior_perforado") {
      final seAgregoBarra = problema.contraAnterior! < problema.perforado!;
      final contraAnteriorAjustada = seAgregoBarra
          ? problema.contraAnterior! + problema.largoBarra
          : problema.contraAnterior!;
      final pasoAjuste = seAgregoBarra
          ? "Como la contra anterior (${formato(problema.contraAnterior!)} m) es menor al metraje perforado (${formato(problema.perforado!)} m), significa operacionalmente que se agregó una barra nueva de ${formato(problema.largoBarra)} m.\n"
                "   • Contra Anterior Ajustada = ${formato(problema.contraAnterior!)} m + ${formato(problema.largoBarra)} m = ${formato(contraAnteriorAjustada)} m\n\n"
          : "";
      final latexFormulaUsada = seAgregoBarra
          ? r"LATEX: c_{act}=(c_{ant}+l_b)-p"
          : r"LATEX: c_{act}=c_{ant}-p";
      final calculoDesarrollado = seAgregoBarra
          ? "Contra actual = (${formato(problema.contraAnterior!)} m + ${formato(problema.largoBarra)} m) - ${formato(problema.perforado!)} m\n"
                "Contra actual = ${formato(contraAnteriorAjustada)} m - ${formato(problema.perforado!)} m = ${formato(problema.contraCorrecta)} m"
          : "Contra actual = ${formato(problema.contraAnterior!)} m - ${formato(problema.perforado!)} m = ${formato(problema.contraCorrecta)} m";

      retro =
          "$pasoAjuste"
          "$latexFormulaUsada\n\n"
          "Desarrollo:\n"
          "   • $calculoDesarrollado\n\n"
          "${problema.interpretacion}";
    } else {
      final profundidadCalculada =
          (problema.cantidadBarras! * problema.largoBarra) +
          problema.largoHerramienta! -
          problema.puntoMuerto!;
      retro =
          r"LATEX: c=d-f"
          "\n\n"
          "Contra = profundidad calculada - fondo del pozo\n"
          "Contra = ${formato(profundidadCalculada)} - ${formato(problema.fondoPozo!)}\n"
          "Contra = ${formato(problema.contraCorrecta)} m\n\n"
          "${problema.interpretacion}";
    }

    return EjercicioPractico(
      titulo: "Cálculo de Contra",
      enunciado: enunciado,
      opciones: problema.opciones.map((it) => "${formato(it)} m").toList(),
      correcta: problema.respuestaCorrecta,
      retroalimentacion: retro,
    );
  }

  static EjercicioPractico convertirFondoAEjercicio(ProblemaFondo problema) {
    final profundidadCalculada =
        (problema.cantidadBarras * problema.largoBarra) +
        problema.largoHerramienta -
        problema.puntoMuerto;
    final enunciado =
        "Calcula el fondo del pozo estimado con los siguientes datos:\n\n"
        "• Cantidad de barras: ${formato(problema.cantidadBarras)}\n"
        "• Largo de barra: ${formato(problema.largoBarra)} m\n"
        "• Largo de barril: ${formato(problema.largoHerramienta)} m\n"
        "• Punto muerto: ${formato(problema.puntoMuerto)} m\n"
        "• Contra: ${formato(problema.contra)} m\n\n"
        r"LATEX: d=(n_b\times l_b)+l_{br}-p_m"
        "\n"
        r"LATEX: f=d-c"
        "\n\n"
        "Donde:\n"
        "• n_b = numero de barras\n"
        "• l_b = largo de barra\n"
        "• l_{br} = largo de barril\n"
        "• p_m = punto muerto\n"
        "• d = profundidad calculada\n"
        "• c = contra\n"
        "• f = fondo del pozo";

    final retro =
        r"LATEX: f=d-c"
        "\n\n"
        "Fondo del Pozo = profundidad calculada - Contra\n"
        "Fondo del Pozo = ${formato(profundidadCalculada)} - ${formato(problema.contra)}\n"
        "Fondo del Pozo = ${formato(problema.fondoCorrecto)} m\n\n"
        "${problema.interpretacion}";

    return EjercicioPractico(
      titulo: "Cálculo de Fondo",
      enunciado: enunciado,
      opciones: problema.opciones.map((it) => "${formato(it)} m").toList(),
      correcta: problema.respuestaCorrecta,
      retroalimentacion: retro,
    );
  }

  static EjercicioPractico convertirRecuperacionAEjercicio(
    ProblemaRecuperacion problema,
  ) {
    final enunciado =
        "Determina el porcentaje de recuperación obtenido con los siguientes datos:\n\n"
        "• Metraje perforado: ${formato(problema.perforado)} m\n"
        "• Muestra recuperada física: ${formato(problema.recuperado)} m\n\n"
        r"LATEX: R=\left(\frac{r}{p}\right)\times 100";

    final retro =
        r"LATEX: R=\left(\frac{r}{p}\right)\times 100"
        "\n\n"
        "Recuperación (%) = (Recuperado / Perforado) × 100\n"
        "Recuperación (%) = (${formato(problema.recuperado)} / ${formato(problema.perforado)}) × 100\n"
        "Recuperación (%) = ${formato(problema.porcentajeCorrecto)}%\n\n"
        "${problema.interpretacion}";

    return EjercicioPractico(
      titulo: "Porcentaje de Recuperación",
      enunciado: enunciado,
      opciones: problema.opciones.map((it) => "${formato(it)}%").toList(),
      correcta: problema.respuestaCorrecta,
      retroalimentacion: retro,
    );
  }

  static EjercicioPractico convertirRegularizacionAEjercicio(
    ProblemaRegularizacion problema,
  ) {
    final distanciaTeorica = redondear2(
      problema.metrajeRegularizar - problema.tacoInicial,
    );
    final perforado = redondear2(problema.tacoFinal - problema.tacoInicial);
    final ratio = perforado == 0
        ? 0.0
        : redondear2(problema.recuperado / perforado);
    final distanciaFisica = redondear2(distanciaTeorica * ratio);

    final enunciado =
        "Determina la ubicación física real a regularizar con los siguientes datos operacionales:\n\n"
        "• Taco Inicial: ${formato(problema.tacoInicial)} m\n"
        "• Taco Final: ${formato(problema.tacoFinal)} m\n"
        "• Metros recuperados físicos: ${formato(problema.recuperado)} m\n"
        "• Metraje teórico a regularizar: ${formato(problema.metrajeRegularizar)} m\n\n"
        "LATEX: d_t = m_r - t_i\n"
        "LATEX: p = t_f - t_i\n"
        "LATEX: u = d_t\\times\\left(\\frac{r}{p}\\right)\n\n"
        "Donde:\n"
        "• d_t = distancia teorica\n"
        "• m_r = metraje a regularizar\n"
        "• t_i = taco inicial\n"
        "• t_f = taco final\n"
        "• r = recuperado\n"
        "• p = perforado\n"
        "• u = ubicacion fisica";

    return EjercicioPractico(
      titulo: "Regularización de Tacos",
      enunciado: enunciado,
      opciones: problema.opciones.map((it) => "${formato(it)} m").toList(),
      correcta: problema.respuestaCorrecta,
      retroalimentacion:
          r"LATEX: u=d_t\times\left(\frac{r}{p}\right)"
          "\n\n"
          "Paso 1) Distancia teórica:\n"
          "Distancia teórica = Metraje a regularizar - Taco inicial\n"
          "Distancia teórica = ${formato(problema.metrajeRegularizar)} - ${formato(problema.tacoInicial)} = ${formato(distanciaTeorica)} m\n\n"
          "Paso 2) Metraje perforado:\n"
          "Perforado = Taco final - Taco inicial\n"
          "Perforado = ${formato(problema.tacoFinal)} - ${formato(problema.tacoInicial)} = ${formato(perforado)} m\n\n"
          "Paso 3) Proporción física:\n"
          "Recuperado/Perforado = ${formato(problema.recuperado)} / ${formato(perforado)} = ${formato(ratio)}\n\n"
          "Paso 4) Ubicación física:\n"
          "Ubicación física = Distancia teórica × (Recuperado/Perforado)\n"
          "Ubicación física = ${formato(distanciaTeorica)} × ${formato(ratio)} = ${formato(distanciaFisica)} m\n\n"
          "${problema.interpretacion}",
    );
  }

  static EjercicioPractico convertirPerforadoAEjercicio(
    ProblemaPerforado problema,
  ) {
    final sbDatos = StringBuffer();
    sbDatos.writeln(
      "Determina el metraje perforado en terreno con los siguientes datos operacionales:\n",
    );
    if (problema.contraAnterior != null) {
      sbDatos.writeln(
        "• Contra Anterior: ${formato(problema.contraAnterior!)} m",
      );
    }
    if (problema.contraActual != null) {
      sbDatos.writeln("• Contra Actual: ${formato(problema.contraActual!)} m");
    }
    if (problema.contraAnterior != null &&
        problema.contraActual != null &&
        problema.contraActual! > problema.contraAnterior! &&
        problema.largoBarra != null) {
      sbDatos.writeln("• Largo de barra: ${formato(problema.largoBarra!)} m");
    }
    if (problema.fondoAnterior != null) {
      sbDatos.writeln(
        "• Fondo Anterior: ${formato(problema.fondoAnterior!)} m",
      );
    }
    if (problema.fondoActual != null) {
      sbDatos.writeln("• Fondo Actual: ${formato(problema.fondoActual!)} m");
    }

    if (problema.contraAnterior != null &&
        problema.contraActual != null &&
        problema.contraActual! > problema.contraAnterior!) {
      sbDatos.writeln(
        "\n⚠️ Regla de Terreno: Como la contra actual es mayor a la contra anterior, significa que se agregó una barra en sarta.",
      );
    }

    sbDatos.writeln("\nMétodos disponibles:");
    sbDatos.writeln("1. Contras:");
    sbDatos.writeln(r"LATEX: p=c_{ant}-c_{act}");
    sbDatos.writeln(r"LATEX: p=(c_{ant}+l_b)-c_{act} \quad (si\ se\ agrego\ barra)");
    sbDatos.writeln("2. Fondos:");
    sbDatos.writeln(r"LATEX: p=f_{act}-f_{ant}");

    return EjercicioPractico(
      titulo: "Metraje Perforado",
      enunciado: sbDatos.toString().trim(),
      opciones: problema.opciones.map((it) => "${formato(it)} m").toList(),
      correcta: problema.respuestaCorrecta,
      retroalimentacion:
          r"LATEX: p=c_{ant}-c_{act}"
          "\n"
          r"LATEX: p=(c_{ant}+l_b)-c_{act}"
          "\n"
          r"LATEX: p=f_{act}-f_{ant}"
          "\n\n"
          "${problema.interpretacion}",
    );
  }

  static List<EjercicioPractico> generarRonda15Ejercicios(
    NivelCalculo dificultad,
  ) {
    final pool = <EjercicioPractico>[];
    final nivelContra = switch (dificultad) {
      NivelCalculo.basico => NivelContra.basico,
      NivelCalculo.medio => NivelContra.medio,
      NivelCalculo.avanzado => NivelContra.avanzado,
    };

    // 1. Contra (al menos 2)
    for (var i = 0; i < 2; i++) {
      pool.add(convertirContraAEjercicio(generarProblemaContra(nivelContra)));
    }
    // 2. Fondo (al menos 2)
    for (var i = 0; i < 2; i++) {
      pool.add(convertirFondoAEjercicio(generarProblemaFondo(dificultad)));
    }
    // 3. Recuperación (al menos 2)
    for (var i = 0; i < 2; i++) {
      pool.add(
        convertirRecuperacionAEjercicio(
          generarProblemaRecuperacion(dificultad),
        ),
      );
    }
    // 4. Regularización (al menos 2)
    for (var i = 0; i < 2; i++) {
      pool.add(
        convertirRegularizacionAEjercicio(
          generarProblemaRegularizacion(dificultad),
        ),
      );
    }
    // 5. Perforado (al menos 2)
    for (var i = 0; i < 2; i++) {
      pool.add(
        convertirPerforadoAEjercicio(generarProblemaPerforado(dificultad)),
      );
    }

    // 6. Los otros 5 elegidos completamente al azar de cualquiera de los tipos
    for (var i = 0; i < 5; i++) {
      final tipo = _randRange(1, 5);
      final ejercicio = switch (tipo) {
        1 => convertirContraAEjercicio(generarProblemaContra(nivelContra)),
        2 => convertirFondoAEjercicio(generarProblemaFondo(dificultad)),
        3 => convertirRecuperacionAEjercicio(
          generarProblemaRecuperacion(dificultad),
        ),
        4 => convertirRegularizacionAEjercicio(
          generarProblemaRegularizacion(dificultad),
        ),
        _ => convertirPerforadoAEjercicio(generarProblemaPerforado(dificultad)),
      };
      pool.add(ejercicio);
    }

    return pool..shuffle();
  }
}
