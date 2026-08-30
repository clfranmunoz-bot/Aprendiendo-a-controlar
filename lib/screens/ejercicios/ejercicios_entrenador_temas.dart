import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/models/ejercicio.dart';
import 'package:aprender_a_controlar/models/problema.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/utils/calculos_sondajes.dart';
import 'package:aprender_a_controlar/widgets/calculadora_bolsillo.dart';
import 'package:aprender_a_controlar/screens/ejercicios/ejercicios_helpers.dart';
import 'package:aprender_a_controlar/screens/ejercicios_screen.dart'; // For TrainerTopic enum

class EjerciciosEntrenadorTemas extends StatefulWidget {
  final VoidCallback onBack;
  final TrainerTopic initialTopic;

  const EjerciciosEntrenadorTemas({
    super.key,
    required this.onBack,
    required this.initialTopic,
  });

  @override
  State<EjerciciosEntrenadorTemas> createState() => _EjerciciosEntrenadorTemasState();
}

class _EjerciciosEntrenadorTemasState extends State<EjerciciosEntrenadorTemas> {
  late TrainerTopic _currentTopic;
  NivelCalculo _trainerDifficulty = NivelCalculo.basico;
  EjercicioPractico? _currentTrainerExercise;
  int _trainerTotalCount = 0;
  int _trainerScore = 0;
  int? _trainerSelectedOption;
  bool _trainerAnswered = false;

  bool _showCalculator = false;
  bool _showFormula = false;

  @override
  void initState() {
    super.initState();
    _currentTopic = widget.initialTopic;
    _generateNextTrainerExercise();
  }

  void _generateNextTrainerExercise() {
    EjercicioPractico nextEx;
    switch (_currentTopic) {
      case TrainerTopic.contra:
        final nivelContra = switch (_trainerDifficulty) {
          NivelCalculo.basico => NivelContra.basico,
          NivelCalculo.medio => NivelContra.medio,
          NivelCalculo.avanzado => NivelContra.avanzado,
        };
        final prob = CalculosSondajes.generarProblemaContra(nivelContra);
        nextEx = CalculosSondajes.convertirContraAEjercicio(prob);
        break;
      case TrainerTopic.fondo:
        final prob = CalculosSondajes.generarProblemaFondo(_trainerDifficulty);
        nextEx = CalculosSondajes.convertirFondoAEjercicio(prob);
        break;
      case TrainerTopic.recuperacion:
        final prob = CalculosSondajes.generarProblemaRecuperacion(_trainerDifficulty);
        nextEx = CalculosSondajes.convertirRecuperacionAEjercicio(prob);
        break;
      case TrainerTopic.regularizacion:
        final prob = CalculosSondajes.generarProblemaRegularizacion(_trainerDifficulty);
        nextEx = CalculosSondajes.convertirRegularizacionAEjercicio(prob);
        break;
      case TrainerTopic.perforado:
        final prob = CalculosSondajes.generarProblemaPerforado(_trainerDifficulty);
        nextEx = CalculosSondajes.convertirPerforadoAEjercicio(prob);
        break;
    }

    setState(() {
      _currentTrainerExercise = nextEx;
      _trainerSelectedOption = null;
      _trainerAnswered = false;
    });
  }

  void _answerTrainer(int optionIdx) {
    if (_trainerAnswered) return;
    setState(() {
      _trainerSelectedOption = optionIdx;
      _trainerAnswered = true;
      _trainerTotalCount++;
      if (optionIdx == _currentTrainerExercise!.correcta) {
        _trainerScore++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentTrainerExercise == null) return const SizedBox.shrink();

    final colors = AppColors.of(context);
    final ex = _currentTrainerExercise!;
    final topicName = switch (_currentTopic) {
      TrainerTopic.contra => "Contra",
      TrainerTopic.fondo => "Fondo Pozo",
      TrainerTopic.recuperacion => "Recuperación",
      TrainerTopic.regularizacion => "Regularización",
      TrainerTopic.perforado => "Perforado",
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Entrenador Infinito",
                  style: TextStyle(
                    color: colors.grisSecundario,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Correctas: $_trainerScore / $_trainerTotalCount",
                  style: TextStyle(
                    color: colors.azulOscuro,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: colors.superficieSuave,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.bordeSuave),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<NivelCalculo>(
                  dropdownColor: colors.superficie,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 8,
                  value: _trainerDifficulty,
                  icon: const Icon(Icons.tune, size: 16),
                  style: TextStyle(
                    color: colors.azulOscuro,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (NivelCalculo? newDifficulty) {
                    if (newDifficulty != null) {
                      setState(() {
                        _trainerDifficulty = newDifficulty;
                        _generateNextTrainerExercise();
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: NivelCalculo.basico,
                      child: Text("Básico "),
                    ),
                    DropdownMenuItem(
                      value: NivelCalculo.medio,
                      child: Text("Medio "),
                    ),
                    DropdownMenuItem(
                      value: NivelCalculo.avanzado,
                      child: Text("Avanzado "),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.azulClaro,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.azul.withOpacity(0.3)),
                  ),
                  child: Text(
                    "$topicName - Nivel ${_trainerDifficulty.name.toUpperCase()}",
                    style: TextStyle(
                      color: colors.azul,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.superficie,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colors.bordeSuave, width: 1.5),
                  ),
                  child: textWithLatex(
                    colors,
                    ex.enunciado,
                    style: TextStyle(
                      color: colors.azulOscuro,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.45,
                    ),
                    latexFontSize: 18,
                    showToggleButton: false,
                    expanded: _showFormula,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (hasFormulaContent(ex.enunciado))
                      TextButton(
                        onPressed: () => setState(() => _showFormula = !_showFormula),
                        style: TextButton.styleFrom(
                          backgroundColor: colors.azulClaro,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          _showFormula ? "Ocultar" : "Formula",
                          style: TextStyle(
                            color: colors.azul,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    TextButton.icon(
                      onPressed: () => setState(() => _showCalculator = !_showCalculator),
                      icon: Icon(
                        _showCalculator ? Icons.calculate : Icons.calculate_outlined,
                        color: colors.azul,
                        size: 16,
                      ),
                      label: Text(
                        _showCalculator ? "Ocultar Calculadora" : "Usar Calculadora",
                        style: TextStyle(
                          color: colors.azul,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: colors.azulClaro,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_showCalculator) ...[
                  const SizedBox(height: 10),
                  const CalculadoraBolsillo(),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 20),
                ...List.generate(ex.opciones.length, (idx) {
                  final optionText = ex.opciones[idx];
                  final isCorrect = idx == ex.correcta;
                  final isSelected = idx == _trainerSelectedOption;

                  Color btnColor = colors.superficie;
                  Color textColor = colors.azulOscuro;
                  BorderSide border = BorderSide(
                    color: colors.bordeSuave,
                    width: 1,
                  );

                  if (_trainerAnswered) {
                    if (isCorrect) {
                      btnColor = colors.verdeClaro;
                      textColor = colors.verde;
                      border = BorderSide(color: colors.verde, width: 1.5);
                    } else if (isSelected) {
                      btnColor = colors.rojoClaro;
                      textColor = colors.rojo;
                      border = BorderSide(color: colors.rojo, width: 1.5);
                    } else {
                      btnColor = colors.superficie.withOpacity(0.5);
                      textColor = colors.grisSecundario;
                      border = BorderSide(
                        color: colors.bordeSuave.withOpacity(0.5),
                        width: 1,
                      );
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _answerTrainer(idx),
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: btnColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.fromBorderSide(border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                optionText,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14.5,
                                  fontWeight: isSelected || (_trainerAnswered && isCorrect)
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (_trainerAnswered && isCorrect)
                              Icon(
                                Icons.check_circle,
                                color: colors.verde,
                                size: 20,
                              )
                            else if (_trainerAnswered && isSelected)
                              Icon(Icons.cancel, color: colors.rojo, size: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                if (_trainerAnswered) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _trainerSelectedOption == ex.correcta ? colors.verdeClaro : colors.rojoClaro,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _trainerSelectedOption == ex.correcta
                            ? colors.verde.withOpacity(0.3)
                            : colors.rojo.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _trainerSelectedOption == ex.correcta ? "🏆 ¡Excelente Trabajo!" : "❌ Ejercicio no resuelto",
                          style: TextStyle(
                            color: _trainerSelectedOption == ex.correcta ? colors.verde : colors.rojo,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        retroWidget(colors, ex.retroalimentacion),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_trainerAnswered) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _generateNextTrainerExercise,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.azul,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Siguiente Problema Dinámico",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
