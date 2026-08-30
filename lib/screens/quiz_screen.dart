import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aprender_a_controlar/models/pregunta.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/utils/app_routes.dart';
import 'package:aprender_a_controlar/utils/quiz_data.dart';

class QuizScreen extends StatefulWidget {
  final Function(String)? onNavigate;

  const QuizScreen({super.key, this.onNavigate});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<Pregunta> _bancoPreguntas = bancoPreguntas;

  List<Pregunta> _preguntasDeRonda = [];
  int _preguntaActualIndex = -1; // -1 means intro screen
  int _score = 0;
  int? _opcionSeleccionada;
  bool _respondida = false;
  List<Pregunta> _preguntasErroneas = [];
  String _selectedQuizType = "Todos";
  List<Map<String, dynamic>> _historial = [];

  @override
  void initState() {
    super.initState();
    _loadHistorial();
  }

  Future<void> _loadHistorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('quiz_historial') ?? [];
      final temp = list.map((item) {
        return jsonDecode(item) as Map<String, dynamic>;
      }).toList();
      temp.sort((a, b) => b['fecha'].toString().compareTo(a['fecha'].toString()));
      setState(() {
        _historial = temp;
      });
    } catch (e) {
      debugPrint("Error loading history: $e");
    }
  }

  Future<void> _clearHistorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('quiz_historial');
      setState(() {
        _historial.clear();
      });
    } catch (e) {
      debugPrint("Error clearing history: $e");
    }
  }

  Future<void> _guardarResultadoQuiz() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final perfilActivo = prefs.getString('perfil_activo') ?? 'Usuario Principal';
      final history = prefs.getStringList('quiz_historial') ?? [];
      
      final record = jsonEncode({
        'perfil': perfilActivo,
        'fecha': DateTime.now().toIso8601String(),
        'categoria': _selectedQuizType,
        'score': _score,
        'total': _preguntasDeRonda.length,
      });
      
      history.add(record);
      await prefs.setStringList('quiz_historial', history);
      _loadHistorial(); // Reload history in memory
    } catch (e) {
      debugPrint("Error saving quiz result: $e");
    }
  }

  String _formatFecha(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      final dia = dt.day.toString().padLeft(2, '0');
      final mes = dt.month.toString().padLeft(2, '0');
      final anio = dt.year;
      final hora = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return "$dia/$mes/$anio $hora:$min";
    } catch (_) {
      return isoString;
    }
  }

  void _iniciarQuiz() {
    final random = Random();
    List<Pregunta> pool = _bancoPreguntas;
    if (_selectedQuizType != "Todos") {
      pool = _bancoPreguntas.where((p) => p.codigoProcedimiento == _selectedQuizType).toList();
    }
    final tempPreguntas = List<Pregunta>.from(pool)..shuffle(random);
    setState(() {
      _preguntasDeRonda = tempPreguntas.take(_selectedQuizType == "Todos" ? 15 : tempPreguntas.length).toList();
      _preguntaActualIndex = 0;
      _score = 0;
      _opcionSeleccionada = null;
      _respondida = false;
      _preguntasErroneas.clear();
    });
  }

  void _responder(int index) {
    if (_respondida) return;
    setState(() {
      _opcionSeleccionada = index;
      _respondida = true;
      final correcta = _preguntasDeRonda[_preguntaActualIndex].correcta;
      if (index == correcta) {
        _score++;
      } else {
        _preguntasErroneas.add(_preguntasDeRonda[_preguntaActualIndex]);
      }
    });
  }

  void _siguiente() {
    setState(() {
      _preguntaActualIndex++;
      _opcionSeleccionada = null;
      _respondida = false;
    });
    if (_preguntaActualIndex == _preguntasDeRonda.length) {
      _guardarResultadoQuiz();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_preguntaActualIndex == -2 ? "Historial de Resultados" : "Quiz con puntaje"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_preguntaActualIndex == -2) {
              setState(() {
                _preguntaActualIndex = -1;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: "Volver al Inicio",
            onPressed: () {
              if (widget.onNavigate != null) {
                widget.onNavigate!(AppRoutes.home);
              } else {
                Navigator.popUntil(context, (r) => r.isFirst);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: _preguntaActualIndex == -1
              ? _buildIntroScreen(colors)
              : _preguntaActualIndex == -2
                  ? _buildHistoryScreen(colors)
                  : _preguntaActualIndex < _preguntasDeRonda.length
                      ? _buildQuizScreen(colors)
                      : _buildResultsScreen(colors),
        ),
      ),
    );
  }

  Widget _buildIntroScreen(AppColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "📝",
          style: TextStyle(fontSize: 64),
        ),
        const SizedBox(height: 16),
        Text(
          "Evaluación de Conocimientos",
          style: TextStyle(
            color: colors.azulOscuro,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Elige el tipo de evaluación para medir tus conocimientos sobre los estándares técnicos.",
          style: TextStyle(
            color: colors.grisTexto,
            fontSize: 15,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Card(
          color: colors.superficie,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colors.bordeSuave, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildIntroBullet(colors, "🎯", "General: 15 preguntas de todos los procedimientos."),
                const SizedBox(height: 8),
                _buildIntroBullet(colors, "⚡", "Específico: 15 preguntas dedicadas al tema seleccionado."),
                const SizedBox(height: 8),
                _buildIntroBullet(colors, "🏆", "Retroalimentación: Explicaciones técnicas inmediatas."),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          value: _selectedQuizType,
          decoration: InputDecoration(
            labelText: "Selecciona el procedimiento a evaluar",
            labelStyle: TextStyle(color: colors.grisTexto, fontSize: 14),
            filled: true,
            fillColor: colors.isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.bordeSuave),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.bordeSuave),
            ),
          ),
          dropdownColor: colors.superficie,
          borderRadius: BorderRadius.circular(16),
          elevation: 8,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.azul),
          style: TextStyle(color: colors.azulOscuro, fontSize: 14.5),
          items: const [
            DropdownMenuItem(value: "Todos", child: Text("Evaluación General (Todos)")),
            DropdownMenuItem(value: "PE-GM-001", child: Text("PE-GM-001: Operación Invierno")),
            DropdownMenuItem(value: "PRO-OP-CSO-MLP-03", child: Text("PRO-OP-CSO-MLP-03: Postura Cadenas")),
            DropdownMenuItem(value: "PRO-OP-MLP-08", child: Text("PRO-OP-MLP-08: Traslado/Uso Caseta")),
            DropdownMenuItem(value: "PRO-OP-MLP-CS-02", child: Text("PRO-OP-MLP-CS-02: Vehículo Liviano")),
            DropdownMenuItem(value: "PRO-OP-MLP-CS-07", child: Text("PRO-OP-MLP-CS-07: Sondaje Diamantino")),
            DropdownMenuItem(value: "RO-GR-OPI-001", child: Text("RO-GR-OPI-001: Climas Adversos")),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedQuizType = val;
              });
            }
          },
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _iniciarQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.azul,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Comenzar Evaluación",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _preguntaActualIndex = -2;
              });
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colors.bordeSuave, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("📈", style: TextStyle(color: colors.azul, fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  "Ver Historial de Puntajes",
                  style: TextStyle(
                    color: colors.azulOscuro,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntroBullet(AppColors colors, String icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: colors.azulOscuro,
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizScreen(AppColors colors) {
    final pregunta = _preguntasDeRonda[_preguntaActualIndex];
    final progress = (_preguntaActualIndex + 1) / _preguntasDeRonda.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Pregunta ${_preguntaActualIndex + 1} de ${_preguntasDeRonda.length}",
              style: TextStyle(
                color: colors.grisSecundario,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Puntaje: $_score",
              style: TextStyle(
                color: colors.azul,
                fontSize: 13,
                fontWeight: FontWeight.bold,
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
        const SizedBox(height: 24),

        // Question Card
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.superficie,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colors.bordeSuave, width: 1.5),
                  ),
                  child: Text(
                    pregunta.enunciado,
                    style: TextStyle(
                      color: colors.azulOscuro,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Options list
                ...List.generate(pregunta.opciones.length, (idx) {
                  final opcion = pregunta.opciones[idx];
                  final esCorrecta = idx == pregunta.correcta;
                  final esSeleccionada = idx == _opcionSeleccionada;

                  Color btnColor = colors.superficie;
                  Color textColor = colors.azulOscuro;
                  BorderSide border = BorderSide(color: colors.bordeSuave, width: 1);

                  if (_respondida) {
                    if (esCorrecta) {
                      btnColor = colors.verdeClaro;
                      textColor = colors.verde;
                      border = BorderSide(color: colors.verde, width: 1.5);
                    } else if (esSeleccionada) {
                      btnColor = colors.rojoClaro;
                      textColor = colors.rojo;
                      border = BorderSide(color: colors.rojo, width: 1.5);
                    } else {
                      btnColor = colors.superficie.withOpacity(0.5);
                      textColor = colors.grisSecundario;
                      border = BorderSide(color: colors.bordeSuave.withOpacity(0.5), width: 1);
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => _responder(idx),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: btnColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.fromBorderSide(border),
                          boxShadow: esSeleccionada
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                opcion,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15.5,
                                  fontWeight: esSeleccionada || (_respondida && esCorrecta)
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (_respondida && esCorrecta)
                              Icon(Icons.check_circle, color: colors.verde, size: 22)
                            else if (_respondida && esSeleccionada)
                              Icon(Icons.cancel, color: colors.rojo, size: 22),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Feedback block
                if (_respondida) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _opcionSeleccionada == pregunta.correcta
                          ? colors.verdeClaro
                          : colors.rojoClaro,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _opcionSeleccionada == pregunta.correcta
                            ? colors.verde.withOpacity(0.3)
                            : colors.rojo.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _opcionSeleccionada == pregunta.correcta
                              ? "🏆 ¡Respuesta Correcta!"
                              : "❌ Respuesta Incorrecta",
                          style: TextStyle(
                            color: _opcionSeleccionada == pregunta.correcta
                                ? colors.verde
                                : colors.rojo,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          pregunta.retroalimentacion,
                          style: TextStyle(
                            color: colors.azulOscuro.withOpacity(0.9),
                            fontSize: 13.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Navigation button
        if (_respondida) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _siguiente,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.azul,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                _preguntaActualIndex == _preguntasDeRonda.length - 1
                    ? "Ver Resultados"
                    : "Siguiente Pregunta",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultsScreen(AppColors colors) {
    final pct = (_score / _preguntasDeRonda.length) * 100;
    String range = "Necesita Práctica 🛠️";
    String description = "Te sugerimos repasar el manual de procedimientos técnicos de terreno y reintentar de nuevo.";
    Color accent = colors.rojo;
    Color bgAccent = colors.rojoClaro;

    if (pct >= 90) {
      range = "Experto Operacional 🏆";
      description = "¡Excelente! Tienes un dominio impecable de los estándares y controles operacionales de sondaje diamantino.";
      accent = colors.verde;
      bgAccent = colors.verdeClaro;
    } else if (pct >= 70) {
      range = "Competente de Terreno 📈";
      description = "Buen trabajo. Conoces los estándares esenciales, pero te sugerimos revisar los errores para lograr la excelencia.";
      accent = colors.naranjo;
      bgAccent = colors.naranjoClaro;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        Text(
          "Resultados de la Evaluación",
          style: TextStyle(
            color: colors.azulOscuro,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),

        // Score circle
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
                "$_score",
                style: TextStyle(
                  color: accent,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "de ${_preguntasDeRonda.length}",
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

        // Grade card
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
        const SizedBox(height: 24),

        // Review erroneous if any
        if (_preguntasErroneas.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Revisión de Puntos a Reforzar (${_preguntasErroneas.length}):",
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
              itemCount: _preguntasErroneas.length,
              itemBuilder: (context, idx) {
                final preg = _preguntasErroneas[idx];
                return Card(
                  color: colors.superficieSuave,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: colors.bordeSuave),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preg.enunciado,
                          style: TextStyle(
                            color: colors.azulOscuro,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "💡 Refuerzo: ${preg.retroalimentacion}",
                          style: TextStyle(
                            color: colors.grisTexto,
                            fontSize: 12.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
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
            onPressed: _iniciarQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.azul,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Reintentar Quiz",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryScreen(AppColors colors) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Historial de Intentos",
              style: TextStyle(
                color: colors.azulOscuro,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_historial.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("¿Borrar historial?"),
                      content: const Text("Esta acción eliminará todos los registros guardados de forma permanente."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Cancelar"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _clearHistorial();
                          },
                          child: const Text("Borrar", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                label: const Text("Limpiar", style: TextStyle(color: Colors.red, fontSize: 13)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _historial.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 48, color: colors.grisTexto.withOpacity(0.5)),
                      const SizedBox(height: 12),
                      Text(
                        "No hay intentos registrados aún.",
                        style: TextStyle(color: colors.grisTexto, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _historial.length,
                  itemBuilder: (context, index) {
                    final item = _historial[index];
                    final String perfil = item['perfil'] ?? 'Usuario Principal';
                    final String fechaIso = item['fecha'] ?? '';
                    final String categoria = item['categoria'] ?? 'Todos';
                    final int score = item['score'] ?? 0;
                    final int total = item['total'] ?? 15;
                    final double pct = total > 0 ? (score / total) * 100 : 0.0;
                    
                    Color scoreColor = colors.rojo;
                    if (pct >= 90) {
                      scoreColor = colors.verde;
                    } else if (pct >= 70) {
                      scoreColor = colors.naranjo;
                    }

                    return Card(
                      color: colors.superficie,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: colors.bordeSuave),
                      ),
                      elevation: 0,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: scoreColor.withOpacity(0.1),
                          child: const Text(
                            "📈",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        title: Text(
                          perfil,
                          style: TextStyle(
                            color: colors.azulOscuro,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          "Cat: $categoria\nFecha: ${_formatFecha(fechaIso)}",
                          style: TextStyle(color: colors.grisTexto, fontSize: 11.5, height: 1.3),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: scoreColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "$score/$total",
                            style: TextStyle(
                              color: scoreColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _preguntaActualIndex = -1;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.azul,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text("Volver a Bienvenida", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ],
    );
  }
}
