import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/models/ejercicio.dart';
import 'package:aprender_a_controlar/models/problema.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/utils/calculos_sondajes.dart';
import 'package:aprender_a_controlar/widgets/calculadora_bolsillo.dart';
import 'package:aprender_a_controlar/screens/ejercicios/ejercicios_helpers.dart';
import 'package:aprender_a_controlar/services/stats_service.dart';

enum RondaMode {
  chooseDifficulty,
  activeDynamicRound,
  resultsScreen,
}

class EjerciciosRondaView extends StatefulWidget {
  final VoidCallback onBack;
  final Function(String) onTitleChanged;

  const EjerciciosRondaView({
    super.key,
    required this.onBack,
    required this.onTitleChanged,
  });

  @override
  State<EjerciciosRondaView> createState() => _EjerciciosRondaViewState();
}

class _EjerciciosRondaViewState extends State<EjerciciosRondaView> {
  RondaMode _mode = RondaMode.chooseDifficulty;
  bool _showCalculator = false;
  bool _showFormula = false;

  NivelCalculo _selectedDifficulty = NivelCalculo.basico;
  List<EjercicioPractico> _roundExercises = [];
  int _currentExerciseIndex = 0;
  int _roundScore = 0;
  int? _roundSelectedOption;
  bool _roundAnswered = false;
  List<EjercicioPractico> _roundIncorrectExercises = [];
  bool _esContrarreloj = false;
  int _tiempoRestante = 45;
  Timer? _timer;
  DateTime? _roundStartTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onTitleChanged("Dificultad de Ronda");
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (!_esContrarreloj) return;
    setState(() {
      _tiempoRestante = 45;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_roundAnswered) {
        timer.cancel();
        return;
      }
      if (_tiempoRestante > 0) {
        setState(() {
          _tiempoRestante--;
        });
      } else {
        timer.cancel();
        _evaluateTimeExpired();
      }
    });
  }

  void _evaluateTimeExpired() {
    setState(() {
      _roundSelectedOption = -1; // -1 represents time expired
      _roundAnswered = true;
      _roundIncorrectExercises.add(_roundExercises[_currentExerciseIndex]);
    });
  }

  void _generateAndStartRound(NivelCalculo difficulty) {
    final exercises = CalculosSondajes.generarRonda15Ejercicios(difficulty);
    setState(() {
      _selectedDifficulty = difficulty;
      _roundExercises = exercises;
      _currentExerciseIndex = 0;
      _roundScore = 0;
      _roundSelectedOption = null;
      _roundAnswered = false;
      _roundIncorrectExercises.clear();
      _mode = RondaMode.activeDynamicRound;
      _roundStartTime = DateTime.now();
    });
    widget.onTitleChanged("Ronda de Ejercicios");
    _startTimer();
  }

  void _answerRound(int optionIdx) {
    if (_roundAnswered) return;
    _timer?.cancel();
    setState(() {
      _roundSelectedOption = optionIdx;
      _roundAnswered = true;
      final correct = _roundExercises[_currentExerciseIndex].correcta;
      if (optionIdx == correct) {
        _roundScore++;
      } else {
        _roundIncorrectExercises.add(_roundExercises[_currentExerciseIndex]);
      }
    });
  }

  void _nextRoundExercise() {
    if (_currentExerciseIndex < _roundExercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _roundSelectedOption = null;
        _roundAnswered = false;
      });
      _startTimer();
    } else {
      _timer?.cancel();
      final elapsedSeconds = _roundStartTime != null
          ? DateTime.now().difference(_roundStartTime!).inSeconds
          : 0;
      StatsService.registrarResultado(
        aciertos: _roundScore,
        total: _roundExercises.length,
        modo: "Ronda (${_selectedDifficulty == NivelCalculo.basico ? 'Básico' : _selectedDifficulty == NivelCalculo.medio ? 'Medio' : 'Avanzado'}${_esContrarreloj ? ' • Contrarreloj' : ''})",
        tiempoSegundos: elapsedSeconds,
      );
      setState(() {
        _mode = RondaMode.resultsScreen;
      });
      widget.onTitleChanged("Resultados de Ronda");
    }
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text(
          "¿Abandonar Ronda?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Si sales perderás tu progreso actual en esta ronda de 15 ejercicios.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Continuar"),
          ),
          TextButton(
            onPressed: () {
              _timer?.cancel();
              Navigator.pop(ctx);
              widget.onBack();
            },
            child: const Text("Salir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(
    AppColors colors,
    String text,
    String subText,
    Color colorTheme,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: colors.superficie,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.bordeSuave, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: colors.azulOscuro,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subText,
                    style: TextStyle(color: colors.grisTexto, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: colorTheme, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return PopScope(
      canPop: _mode != RondaMode.activeDynamicRound,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _showExitConfirmationDialog();
      },
      child: () {
        switch (_mode) {
          case RondaMode.chooseDifficulty:
            return _buildChooseDifficulty(colors);
          case RondaMode.activeDynamicRound:
            return _buildActiveDynamicRound(colors);
          case RondaMode.resultsScreen:
            return _buildResultsScreen(colors);
        }
      }(),
    );
  }

  Widget _buildChooseDifficulty(AppColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("🎯", style: TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        Text(
          "Elige la Dificultad de la Ronda",
          style: TextStyle(
            color: colors.azulOscuro,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Generaremos dinámicamente una ronda equilibrada de 15 problemas prácticos de terreno adecuados a tu nivel de experiencia.",
          style: TextStyle(color: colors.grisTexto, fontSize: 14, height: 1.4),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildDifficultyButton(
          colors,
          "Nivel Básico 🟢",
          "Números redondos y fórmulas explícitas.",
          colors.verde,
          () => _generateAndStartRound(NivelCalculo.basico),
        ),
        const SizedBox(height: 14),
        _buildDifficultyButton(
          colors,
          "Nivel Medio 🟡",
          "Casos con decimales y condiciones reales.",
          colors.naranjo,
          () => _generateAndStartRound(NivelCalculo.medio),
        ),
        const SizedBox(height: 14),
        _buildDifficultyButton(
          colors,
          "Nivel Avanzado 🔴",
          "Casos complejos, contras negativas e inconsistencias.",
          colors.rojo,
          () => _generateAndStartRound(NivelCalculo.avanzado),
        ),
        const SizedBox(height: 20),
        Card(
          color: colors.superficie,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colors.bordeSuave, width: 1.2),
          ),
          child: SwitchListTile(
            title: Text(
              "⏱️ Activar Modo Contrarreloj",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colors.azulOscuro,
                fontSize: 14.5,
              ),
            ),
            subtitle: Text(
              "Tendrás 45 segundos para contestar cada pregunta.",
              style: TextStyle(color: colors.grisTexto, fontSize: 12),
            ),
            value: _esContrarreloj,
            onChanged: (val) {
              setState(() {
                _esContrarreloj = val;
              });
            },
            activeColor: colors.azul,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: widget.onBack,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colors.bordeSuave, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              "Volver al Panel",
              style: TextStyle(
                color: colors.azulOscuro,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveDynamicRound(AppColors colors) {
    final ex = _roundExercises[_currentExerciseIndex];
    final progress = (_currentExerciseIndex + 1) / _roundExercises.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Ejercicio ${_currentExerciseIndex + 1} de ${_roundExercises.length}",
              style: TextStyle(
                color: colors.grisSecundario,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.azulClaro,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Puntaje: $_roundScore",
                style: TextStyle(
                  color: colors.azul,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: colors.bordeSuave,
            valueColor: AlwaysStoppedAnimation<Color>(colors.azul),
            minHeight: 6,
          ),
        ),
        if (_esContrarreloj) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _tiempoRestante <= 10
                  ? colors.rojo.withValues(alpha: 0.1)
                  : colors.superficieSuave,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _tiempoRestante <= 10 ? colors.rojo : colors.bordeSuave,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: _tiempoRestante <= 10 ? colors.rojo : colors.azul,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Tiempo restante:",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colors.azulOscuro,
                      ),
                    ),
                  ],
                ),
                Text(
                  "$_tiempoRestante s",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _tiempoRestante <= 10 ? colors.rojo : colors.azulOscuro,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
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
                    color: colors.purpuraClaro,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.purpura.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    ex.titulo,
                    style: TextStyle(
                      color: colors.purpura,
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
                      fontSize: 15.5,
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
                  final isSelected = idx == _roundSelectedOption;

                  Color btnColor = colors.superficie;
                  Color textColor = colors.azulOscuro;
                  BorderSide border = BorderSide(
                    color: colors.bordeSuave,
                    width: 1,
                  );

                  if (_roundAnswered) {
                    if (isCorrect) {
                      btnColor = colors.verdeClaro;
                      textColor = colors.verde;
                      border = BorderSide(color: colors.verde, width: 1.5);
                    } else if (isSelected) {
                      btnColor = colors.rojoClaro;
                      textColor = colors.rojo;
                      border = BorderSide(color: colors.rojo, width: 1.5);
                    } else {
                      btnColor = colors.superficie.withValues(alpha: 0.5);
                      textColor = colors.grisSecundario;
                      border = BorderSide(
                        color: colors.bordeSuave.withValues(alpha: 0.5),
                        width: 1,
                      );
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _answerRound(idx),
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
                                  fontSize: 15,
                                  fontWeight: isSelected || (_roundAnswered && isCorrect)
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (_roundAnswered && isCorrect)
                              Icon(
                                Icons.check_circle,
                                color: colors.verde,
                                size: 20,
                              )
                            else if (_roundAnswered && isSelected)
                              Icon(Icons.cancel, color: colors.rojo, size: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                if (_roundAnswered) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _roundSelectedOption == ex.correcta ? colors.verdeClaro : colors.rojoClaro,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _roundSelectedOption == ex.correcta
                            ? colors.verde.withValues(alpha: 0.3)
                            : colors.rojo.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _roundSelectedOption == ex.correcta
                              ? "🏆 ¡Excelente!"
                              : _roundSelectedOption == -1
                                  ? "⏱️ ¡Tiempo agotado!"
                                  : "❌ Revisar procedimiento",
                          style: TextStyle(
                            color: _roundSelectedOption == ex.correcta ? colors.verde : colors.rojo,
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
        if (_roundAnswered) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _nextRoundExercise,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.azul,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                _currentExerciseIndex == _roundExercises.length - 1 ? "Ver Resultados de Ronda" : "Siguiente Ejercicio",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultsScreen(AppColors colors) {
    final pct = (_roundScore / _roundExercises.length) * 100;
    String range = "Necesita Práctica 🛠️";
    String description =
        "Te sugerimos repasar las fórmulas de sondajes, las 4 calculadoras del panel principal y reintentar la ronda.";
    Color accent = colors.rojo;
    Color bgAccent = colors.rojoClaro;

    if (pct >= 90) {
      range = "Experto Operacional 🏆";
      description = "¡Impecable! Tienes una destreza de cálculo y control técnico sobresaliente en terreno.";
      accent = colors.verde;
      bgAccent = colors.verdeClaro;
    } else if (pct >= 70) {
      range = "Competente de Terreno 📈";
      description =
          "Buen trabajo. Dominas los conceptos esenciales, pero te recomendamos repasar los errores para alcanzar el nivel Experto.";
      accent = colors.naranjo;
      bgAccent = colors.naranjoClaro;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        Text(
          "Resultados del Entrenamiento",
          style: TextStyle(
            color: colors.azulOscuro,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgAccent,
            border: Border.all(color: accent, width: 4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$_roundScore",
                style: TextStyle(
                  color: accent,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "de ${_roundExercises.length}",
                style: TextStyle(
                  color: colors.grisTexto,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.superficie,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.bordeSuave, width: 1.5),
          ),
          child: Column(
            children: [
              Text(
                range,
                style: TextStyle(
                  color: accent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  color: colors.grisTexto,
                  fontSize: 14,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_roundIncorrectExercises.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Revisión de Casos Fallidos (${_roundIncorrectExercises.length}):",
              style: TextStyle(
                color: colors.azulOscuro,
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _roundIncorrectExercises.length,
              itemBuilder: (context, idx) {
                final ex = _roundIncorrectExercises[idx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.superficieSuave,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.bordeSuave),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ex.titulo,
                        style: TextStyle(
                          color: colors.azul,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      textWithLatex(
                        colors,
                        ex.enunciado,
                        style: TextStyle(
                          color: colors.azulOscuro,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          height: 1.35,
                        ),
                        latexFontSize: 15,
                      ),
                      const SizedBox(height: 8),
                      retroWidget(
                        colors,
                        "💡 Solución Técnica:\n${ex.retroalimentacion}",
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ] else ...[
          const Spacer(),
          const Icon(Icons.stars, color: Colors.amber, size: 64),
          const SizedBox(height: 12),
          Text(
            "¡Puntaje Perfecto! Impecable.",
            style: TextStyle(
              color: colors.verde,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Spacer(),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => _generateAndStartRound(_selectedDifficulty),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.azul,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Reintentar Otra Ronda",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
