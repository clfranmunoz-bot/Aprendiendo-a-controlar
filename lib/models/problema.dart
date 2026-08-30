enum NivelCalculo { basico, medio, avanzado }

enum NivelContra { basico, medio, avanzado }

class ProblemaContra {
  final NivelContra nivel;
  final double? cantidadBarras;
  final double largoBarra;
  final double? largoHerramienta;
  final double? puntoMuerto;
  final double? fondoPozo;
  final double contraCorrecta;
  final List<double> opciones;
  final int respuestaCorrecta;
  final String interpretacion;
  final double? contraAnterior;
  final double? perforado;
  final String metodoUsado; // "anterior_perforado" o "fisico"

  ProblemaContra({
    required this.nivel,
    this.cantidadBarras,
    required this.largoBarra,
    this.largoHerramienta,
    this.puntoMuerto,
    this.fondoPozo,
    required this.contraCorrecta,
    required this.opciones,
    required this.respuestaCorrecta,
    required this.interpretacion,
    this.contraAnterior,
    this.perforado,
    required this.metodoUsado,
  });
}

class ProblemaFondo {
  final NivelCalculo nivel;
  final double cantidadBarras;
  final double largoBarra;
  final double largoHerramienta;
  final double puntoMuerto;
  final double contra;
  final double fondoCorrecto;
  final List<double> opciones;
  final int respuestaCorrecta;
  final String interpretacion;

  ProblemaFondo({
    required this.nivel,
    required this.cantidadBarras,
    required this.largoBarra,
    required this.largoHerramienta,
    required this.puntoMuerto,
    required this.contra,
    required this.fondoCorrecto,
    required this.opciones,
    required this.respuestaCorrecta,
    required this.interpretacion,
  });
}

class ProblemaRecuperacion {
  final NivelCalculo nivel;
  final double perforado;
  final double recuperado;
  final double porcentajeCorrecto;
  final List<double> opciones;
  final int respuestaCorrecta;
  final String interpretacion;

  ProblemaRecuperacion({
    required this.nivel,
    required this.perforado,
    required this.recuperado,
    required this.porcentajeCorrecto,
    required this.opciones,
    required this.respuestaCorrecta,
    required this.interpretacion,
  });
}

class ProblemaRegularizacion {
  final NivelCalculo nivel;
  final double tacoInicial;
  final double tacoFinal;
  final double recuperado;
  final double metrajeRegularizar;
  final double distanciaCorrecta;
  final double recuperacionPorcentaje;
  final List<double> opciones;
  final int respuestaCorrecta;
  final String interpretacion;

  ProblemaRegularizacion({
    required this.nivel,
    required this.tacoInicial,
    required this.tacoFinal,
    required this.recuperado,
    required this.metrajeRegularizar,
    required this.distanciaCorrecta,
    required this.recuperacionPorcentaje,
    required this.opciones,
    required this.respuestaCorrecta,
    required this.interpretacion,
  });
}

class ProblemaPerforado {
  final NivelCalculo nivel;
  final double? contraAnterior;
  final double? contraActual;
  final double? fondoAnterior;
  final double? fondoActual;
  final double? largoBarra;
  final double perforadoCorrecto;
  final List<double> opciones;
  final int respuestaCorrecta;
  final String interpretacion;
  final String metodoUsado; // "contras", "fondos", "ambos"

  ProblemaPerforado({
    required this.nivel,
    this.contraAnterior,
    this.contraActual,
    this.fondoAnterior,
    this.fondoActual,
    this.largoBarra,
    required this.perforadoCorrecto,
    required this.opciones,
    required this.respuestaCorrecta,
    required this.interpretacion,
    required this.metodoUsado,
  });
}
