import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/models/problema.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/utils/calculos_sondajes.dart';
import 'package:aprender_a_controlar/widgets/calculadora_bolsillo.dart';
import 'package:aprender_a_controlar/widgets/latex_formula.dart';

class CalculadoraPracticaWidget extends StatefulWidget {
  final int tipoIndex;
  final AppColors colors;

  const CalculadoraPracticaWidget({
    super.key,
    required this.tipoIndex,
    required this.colors,
  });

  @override
  State<CalculadoraPracticaWidget> createState() => _CalculadoraPracticaWidgetState();
}

class _CalculadoraPracticaWidgetState extends State<CalculadoraPracticaWidget> {
  dynamic _problemaActual;
  int? _respuestaSeleccionada;
  bool _problemaRespondido = false;
  bool _showCalculator = false;
  NivelCalculo _nivelSeleccionado = NivelCalculo.basico;
  NivelContra _nivelContraSeleccionado = NivelContra.basico;

  void _generarEjercicio() {
    setState(() {
      _respuestaSeleccionada = null;
      _problemaRespondido = false;
      _showCalculator = false;
      if (widget.tipoIndex == 0) {
        _problemaActual = CalculosSondajes.generarProblemaRecuperacion(_nivelSeleccionado);
      } else if (widget.tipoIndex == 1) {
        _problemaActual = CalculosSondajes.generarProblemaContra(_nivelContraSeleccionado);
      } else if (widget.tipoIndex == 2) {
        _problemaActual = CalculosSondajes.generarProblemaFondo(_nivelSeleccionado);
      } else if (widget.tipoIndex == 3) {
        _problemaActual = CalculosSondajes.generarProblemaRegularizacion(_nivelSeleccionado);
      } else if (widget.tipoIndex == 4) {
        _problemaActual = CalculosSondajes.generarProblemaPerforado(_nivelSeleccionado);
      }
    });
  }

  void _verificarRespuesta(int index) {
    if (_problemaRespondido) return;
    setState(() {
      _respuestaSeleccionada = index;
      _problemaRespondido = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final levels = _buildLevelSelector();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.colors.superficieSuave,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: widget.colors.bordeSuave, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "🏋️ Entrenar Habilidad",
                style: TextStyle(
                  color: widget.colors.azulOscuro,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              levels,
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Genera ejercicios aleatorios por niveles de dificultad para entrenar el cálculo mental y el criterio técnico que te exigirán en terreno.",
            style: TextStyle(
              color: widget.colors.grisTexto,
              fontSize: 13,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.psychology),
              label: const Text("Generar Problema de Terreno"),
              onPressed: _generarEjercicio,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.colors.azul,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (_problemaActual != null) ...[
            const SizedBox(height: 20),
            _buildProblemaWidget(),
          ],
        ],
      ),
    );
  }

  Widget _buildLevelSelector() {
    final colors = AppColors.of(context);
    if (widget.tipoIndex == 1) {
      return DropdownButton<NivelContra>(
        dropdownColor: colors.superficie,
        borderRadius: BorderRadius.circular(16),
        elevation: 8,
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.azul),
        value: _nivelContraSeleccionado,
        underline: const SizedBox(),
        onChanged: (NivelContra? value) {
          if (value != null) {
            setState(() {
              _nivelContraSeleccionado = value;
              _problemaActual = null;
            });
          }
        },
        items: const [
          DropdownMenuItem(value: NivelContra.basico, child: Text("Básico")),
          DropdownMenuItem(value: NivelContra.medio, child: Text("Medio")),
          DropdownMenuItem(value: NivelContra.avanzado, child: Text("Avanzado")),
        ],
      );
    } else {
      return DropdownButton<NivelCalculo>(
        dropdownColor: colors.superficie,
        borderRadius: BorderRadius.circular(16),
        elevation: 8,
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.azul),
        value: _nivelSeleccionado,
        underline: const SizedBox(),
        onChanged: (NivelCalculo? value) {
          if (value != null) {
            setState(() {
              _nivelSeleccionado = value;
              _problemaActual = null;
            });
          }
        },
        items: const [
          DropdownMenuItem(value: NivelCalculo.basico, child: Text("Básico")),
          DropdownMenuItem(value: NivelCalculo.medio, child: Text("Medio")),
          DropdownMenuItem(value: NivelCalculo.avanzado, child: Text("Avanzado")),
        ],
      );
    }
  }

  Widget _buildProblemaWidget() {
    String enunciado = "";
    List<double> opciones = [];
    int respuestaCorrecta = -1;
    String interpretacion = "";

    if (widget.tipoIndex == 0) {
      if (_problemaActual is! ProblemaRecuperacion) return const SizedBox.shrink();
      final p = _problemaActual as ProblemaRecuperacion;
      enunciado =
          "En una corrida diamantina con metros perforados de ${p.perforado.toStringAsFixed(2)} m, se extrae un testigo con recuperación física de ${p.recuperado.toStringAsFixed(2)} m. ¿Cuál es el porcentaje de recuperación a registrar?";
      opciones = p.opciones;
      respuestaCorrecta = p.respuestaCorrecta;
      interpretacion = p.interpretacion;
    } else if (widget.tipoIndex == 1) {
      if (_problemaActual is! ProblemaContra) return const SizedBox.shrink();
      final p = _problemaActual as ProblemaContra;
      if (p.metodoUsado == "anterior_perforado") {
        enunciado =
            "Contra Anterior: ${p.contraAnterior!.toStringAsFixed(2)} m. Metros Perforados en corrida: ${p.perforado!.toStringAsFixed(2)} m. Largo de Barra: ${p.largoBarra.toStringAsFixed(2)} m. ¿Cuál es la contra estimada a reportar?";
      } else {
        enunciado =
            "Barras: ${p.cantidadBarras!.toInt()}. Largo Barra: ${p.largoBarra.toStringAsFixed(2)} m. Herramienta: ${p.largoHerramienta!.toStringAsFixed(2)} m. Punto Muerto: ${p.puntoMuerto!.toStringAsFixed(2)} m. Fondo Pozo: ${p.fondoPozo!.toStringAsFixed(2)} m. ¿Cuál es la contra estimada?";
      }
      opciones = p.opciones;
      respuestaCorrecta = p.respuestaCorrecta;
      interpretacion = p.interpretacion;
    } else if (widget.tipoIndex == 2) {
      if (_problemaActual is! ProblemaFondo) return const SizedBox.shrink();
      final p = _problemaActual as ProblemaFondo;
      enunciado =
          "Sarta de Barras: ${p.cantidadBarras.toInt()} de ${p.largoBarra.toStringAsFixed(2)} m. Herramienta: ${p.largoHerramienta.toStringAsFixed(2)} m. Punto Muerto: ${p.puntoMuerto.toStringAsFixed(2)} m. Contra registrada: ${p.contra.toStringAsFixed(2)} m. ¿Cuál es el fondo de pozo estimado?";
      opciones = p.opciones;
      respuestaCorrecta = p.respuestaCorrecta;
      interpretacion = p.interpretacion;
    } else if (widget.tipoIndex == 3) {
      if (_problemaActual is! ProblemaRegularizacion) return const SizedBox.shrink();
      final p = _problemaActual as ProblemaRegularizacion;
      enunciado =
          "Taco Inicial: ${p.tacoInicial.toStringAsFixed(2)} m. Taco Final (Corrida): ${p.tacoFinal.toStringAsFixed(2)} m. Testigo Recuperado: ${p.recuperado.toStringAsFixed(2)} m. Metraje Teórico a Regularizar: ${p.metrajeRegularizar.toStringAsFixed(2)} m. ¿A qué distancia física desde el taco inicial se debe colocar el taco de regularización?";
      opciones = p.opciones;
      respuestaCorrecta = p.respuestaCorrecta;
      interpretacion = p.interpretacion;
    } else if (widget.tipoIndex == 4) {
      if (_problemaActual is! ProblemaPerforado) return const SizedBox.shrink();
      final p = _problemaActual as ProblemaPerforado;
      if (p.metodoUsado == "contras") {
        if (p.largoBarra != null && p.contraActual! > p.contraAnterior!) {
          enunciado =
              "Contra Anterior: ${p.contraAnterior!.toStringAsFixed(2)} m. Contra Actual: ${p.contraActual!.toStringAsFixed(2)} m. Largo de Barra: ${p.largoBarra!.toStringAsFixed(2)} m. ¿Cuántos metros se perforaron en la corrida?";
        } else {
          enunciado =
              "Contra Anterior: ${p.contraAnterior!.toStringAsFixed(2)} m. Contra Actual: ${p.contraActual!.toStringAsFixed(2)} m. ¿Cuántos metros se perforaron en la corrida?";
        }
      } else if (p.metodoUsado == "fondos") {
        enunciado =
            "Fondo Anterior: ${p.fondoAnterior!.toStringAsFixed(2)} m. Fondo Actual: ${p.fondoActual!.toStringAsFixed(2)} m. ¿Cuántos metros se perforaron?";
      } else {
        if (p.largoBarra != null && p.contraActual! > p.contraAnterior!) {
          enunciado =
              "Contra: ${p.contraAnterior!.toStringAsFixed(2)} m a ${p.contraActual!.toStringAsFixed(2)} m (Largo Barra: ${p.largoBarra!.toStringAsFixed(2)} m). Fondo: ${p.fondoAnterior!.toStringAsFixed(2)} m a ${p.fondoActual!.toStringAsFixed(2)} m. ¿Cuántos metros se perforaron?";
        } else {
          enunciado =
              "Contra: ${p.contraAnterior!.toStringAsFixed(2)} m a ${p.contraActual!.toStringAsFixed(2)} m. Fondo: ${p.fondoAnterior!.toStringAsFixed(2)} m a ${p.fondoActual!.toStringAsFixed(2)} m. ¿Cuántos metros se perforaron?";
        }
      }
      opciones = p.opciones;
      respuestaCorrecta = p.respuestaCorrecta;
      interpretacion = p.interpretacion;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        Text(
          "ENUNCIADO DEL CASO:",
          style: TextStyle(
            color: widget.colors.grisSecundario,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          enunciado,
          style: TextStyle(
            color: widget.colors.azulOscuro,
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () => setState(() => _showCalculator = !_showCalculator),
              icon: Icon(
                _showCalculator ? Icons.calculate : Icons.calculate_outlined,
                color: widget.colors.azul,
                size: 16,
              ),
              label: Text(
                _showCalculator ? "Ocultar Calculadora" : "Usar Calculadora",
                style: TextStyle(
                  color: widget.colors.azul,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: widget.colors.azulClaro,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        if (_showCalculator) ...[
          const SizedBox(height: 10),
          const CalculadoraBolsillo(),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 16),
        Text(
          "OPCIONES DE RESPUESTA:",
          style: TextStyle(
            color: widget.colors.grisSecundario,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: List.generate(opciones.length, (idx) {
            final opcion = opciones[idx];
            final esCorrecta = idx == respuestaCorrecta;
            final esSeleccionada = idx == _respuestaSeleccionada;

            Color itemColor = widget.colors.superficie;
            Color textColor = widget.colors.azulOscuro;
            BorderSide border = BorderSide(color: widget.colors.bordeSuave, width: 1);

            if (_problemaRespondido) {
              if (esCorrecta) {
                itemColor = widget.colors.verdeClaro;
                textColor = widget.colors.verde;
                border = BorderSide(color: widget.colors.verde, width: 1.5);
              } else if (esSeleccionada) {
                itemColor = widget.colors.rojoClaro;
                textColor = widget.colors.rojo;
                border = BorderSide(color: widget.colors.rojo, width: 1.5);
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => _verificarRespuesta(idx),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: itemColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.fromBorderSide(border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _problemaRespondido && esCorrecta
                              ? widget.colors.verde
                              : _problemaRespondido && esSeleccionada
                                  ? widget.colors.rojo
                                  : Colors.transparent,
                          border: Border.all(
                            color: _problemaRespondido && esCorrecta
                                ? widget.colors.verde
                                : _problemaRespondido && esSeleccionada
                                    ? widget.colors.rojo
                                    : widget.colors.grisSecundario,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + idx), // A, B, C
                            style: TextStyle(
                              color: _problemaRespondido && (esCorrecta || esSeleccionada)
                                  ? Colors.white
                                  : widget.colors.grisTexto,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.tipoIndex == 0
                            ? "${opcion.toStringAsFixed(2)} %"
                            : "${opcion.toStringAsFixed(2)} m",
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        if (_problemaRespondido) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _respuestaSeleccionada == respuestaCorrecta
                  ? widget.colors.verdeClaro
                  : widget.colors.naranjoClaro,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _respuestaSeleccionada == respuestaCorrecta
                      ? "🎉 ¡Respuesta Correcta!"
                      : "⚠️ Intenta comprender la fórmula:",
                  style: TextStyle(
                    color: _respuestaSeleccionada == respuestaCorrecta
                        ? widget.colors.verde
                        : widget.colors.naranjo,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                if (_respuestaSeleccionada != respuestaCorrecta) ...[
                  LatexFormula(
                    latex: widget.tipoIndex == 0
                        ? r'\text{Recuperacion (\%)} = \frac{\text{Recuperado}}{\text{Perforado}}\times 100'
                        : widget.tipoIndex == 1
                            ? r'\text{Contra} = \text{Contra anterior ajustada} - \text{Perforado}'
                            : widget.tipoIndex == 2
                                ? r'\text{Fondo} = (\text{Barras}\times\text{Largo barra}) + \text{Herr} - \text{Punto muerto} - \text{Contra}'
                                : widget.tipoIndex == 3
                                    ? r'\text{Distancia fisica} = \frac{\text{Distancia teorica}\times\text{Recuperado}}{\text{Perforado}}'
                                    : r'\text{Perforado} = \text{Fondo actual} - \text{Fondo anterior}',
                    color: widget.colors.azulOscuro.withOpacity(0.9),
                    fontSize: 15,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 10),
                ],
                Text(
                  interpretacion,
                  style: TextStyle(
                    color: widget.colors.azulOscuro.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
