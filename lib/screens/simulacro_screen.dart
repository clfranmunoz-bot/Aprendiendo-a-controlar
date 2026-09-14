import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/widgets/drawer_menu.dart';
import 'package:aprender_a_controlar/models/simulacro_turno_model.dart';
import 'package:aprender_a_controlar/widgets/latex_formula.dart';
import 'package:aprender_a_controlar/widgets/calculadora_bolsillo.dart';

class SimulacroScreen extends StatefulWidget {
  final Function(String) onNavigate;
  final bool modoOscuro;
  final VoidCallback onToggleModoOscuro;
  final String perfilActivo;

  const SimulacroScreen({
    super.key,
    required this.onNavigate,
    required this.modoOscuro,
    required this.onToggleModoOscuro,
    required this.perfilActivo,
  });

  @override
  State<SimulacroScreen> createState() => _SimulacroScreenState();
}

class _SimulacroScreenState extends State<SimulacroScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Estado del simulacro
  String _dificultad = 'Básico';
  int _etapa = 0; // 0=Config, 1=Corridas, 2=Evaluación
  late TurnoConfiguracion _config;
  late List<CorridaSimulada> _corridas;
  int _corridaActual = 0;

  // Controladores de texto para la planilla de la corrida
  final _ctrlAvance = TextEditingController();
  final _ctrlFondoHasta = TextEditingController();
  final _ctrlRecuperacion = TextEditingController();
  final _ctrlPerdida = TextEditingController();

  bool _corridaEnviada = false;
  bool _showCalculator = false;
  Offset _calcPosition = const Offset(80, 220);

  @override
  void initState() {
    super.initState();
    _config = GeneradorSimulacion.generarConfiguracion(_dificultad);
    _corridas = GeneradorSimulacion.generarCorridas(_config);
  }

  void _iniciarSimulacro() {
    _config = GeneradorSimulacion.generarConfiguracion(_dificultad);
    _corridas = GeneradorSimulacion.generarCorridas(_config);
    _corridaActual = 0;
    _corridaEnviada = false;
    _limpiarControladores();
    setState(() => _etapa = 1);
  }

  void _limpiarControladores() {
    _ctrlAvance.clear();
    _ctrlFondoHasta.clear();
    _ctrlRecuperacion.clear();
    _ctrlPerdida.clear();
  }

  void _enviarCorrida() {
    final c = _corridas[_corridaActual];
    c.avanceIngresado = double.tryParse(_ctrlAvance.text.replaceAll(',', '.'));
    c.fondoHastaIngresado = double.tryParse(_ctrlFondoHasta.text.replaceAll(',', '.'));
    c.recuperacionIngresada = double.tryParse(_ctrlRecuperacion.text.replaceAll(',', '.'));
    c.perdidaIngresada = double.tryParse(_ctrlPerdida.text.replaceAll(',', '.'));
    setState(() => _corridaEnviada = true);
  }

  void _siguienteCorrida() {
    if (_corridaActual < _corridas.length - 1) {
      setState(() {
        _corridaActual++;
        _corridaEnviada = false;
        _limpiarControladores();
      });
    } else {
      setState(() => _etapa = 2);
    }
  }

  double get _puntajeTotal {
    int totalPreguntas = _corridas.length * 4; // 4 cálculos por corrida
    int correctas = 0;
    for (final c in _corridas) {
      if (c.isAvanceCorrecto) correctas++;
      if (c.isFondoHastaCorrecto) correctas++;
      if (c.isRecuperacionCorrecta) correctas++;
      if (c.isPerdidaCorrecta) correctas++;
    }
    return totalPreguntas > 0 ? (correctas / totalPreguntas) * 100 : 0.0;
  }

  String get _calificacion {
    final p = _puntajeTotal;
    if (p >= 95) return "⭐ Nivel Supervisor Senior";
    if (p >= 85) return "👍 Nivel Controlador Aprobado";
    if (p >= 70) return "📖 En Práctica (Requiere Supervisión)";
    return "🔁 Necesitas Reforzar Conceptos";
  }

  @override
  void dispose() {
    _ctrlAvance.dispose();
    _ctrlFondoHasta.dispose();
    _ctrlRecuperacion.dispose();
    _ctrlPerdida.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.fondo,
      drawer: DrawerMenu(
        onNavigate: widget.onNavigate,
        modoOscuro: widget.modoOscuro,
        onToggleModoOscuro: widget.onToggleModoOscuro,
      ),
      appBar: AppBar(
        backgroundColor: colors.superficie,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: colors.azulOscuro),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          "🎯 Simulacro de Turno",
          style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (_etapa == 1)
            IconButton(
              icon: Icon(Icons.calculate_outlined, color: colors.azulOscuro),
              tooltip: "Calculadora de Bolsillo",
              onPressed: () {
                setState(() {
                  _showCalculator = !_showCalculator;
                });
              },
            ),
          if (_etapa > 0)
            TextButton.icon(
              icon: Icon(Icons.refresh, size: 16, color: colors.azul),
              label: Text("Reiniciar", style: TextStyle(color: colors.azul, fontSize: 12)),
              onPressed: () => setState(() {
                _etapa = 0;
                _corridaActual = 0;
                _corridaEnviada = false;
              }),
            ),
          IconButton(
            icon: Icon(Icons.home_outlined, color: colors.azulOscuro),
            onPressed: () => widget.onNavigate('home'),
          ),
        ],
      ),
      floatingActionButton: _etapa == 1
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              tooltip: "Calculadora de Bolsillo",
              onPressed: () {
                setState(() {
                  _showCalculator = !_showCalculator;
                });
              },
              child: const Icon(Icons.calculate),
            )
          : null,
      body: Stack(
        children: [
          _etapa == 0
              ? _buildConfiguracion(colors)
              : _etapa == 1
                  ? _buildCorridas(colors)
                  : _buildEvaluacion(colors),
          if (_showCalculator)
            Positioned(
              left: _calcPosition.dx,
              top: _calcPosition.dy,
              width: 250,
              child: CalculadoraBolsillo(
                onDrag: (delta) {
                  setState(() {
                    _calcPosition += delta;
                  });
                },
                onClose: () {
                  setState(() {
                    _showCalculator = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  // ─── PANTALLA DE CONFIGURACIÓN ───────────────────────────────────────────
  Widget _buildConfiguracion(AppColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("⛏️", style: TextStyle(fontSize: 40)),
                SizedBox(height: 8),
                Text(
                  "Auditoría Operacional en Terreno",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 6),
                Text(
                  "Enfréntate a un turno real de perforación diamantina. Calcula el Avance, Fondo, % de Recuperación y Pérdidas de testigo de cada corrida a partir de las lecturas físicas del pozo y la bandeja.",
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text("Elige la dificultad del Turno:", style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...['Básico', 'Intermedio', 'Avanzado'].map((d) {
            final icons = ['🟢', '🟡', '🔴'];
            final descs = [
              '3 corridas sin adición de barras. Alta recuperación de testigo (92-100%). Ideal para comenzar.',
              '4 corridas con adición de barras a mitad del turno. Pérdidas moderadas de testigo.',
              '5 corridas con adición de barras, tramos diaclasados de baja recuperación y alta variación litológica.',
            ];
            final idx = ['Básico', 'Intermedio', 'Avanzado'].indexOf(d);
            final isSelected = _dificultad == d;
            return GestureDetector(
              onTap: () => setState(() => _dificultad = d),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6366F1).withOpacity(0.08) : colors.superficie,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF4F46E5) : colors.bordeSuave,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(icons[idx], style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d, style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(descs[idx], style: TextStyle(color: colors.grisTexto, fontSize: 11, height: 1.3)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _iniciarSimulacro,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              child: const Text("Iniciar Turno de Perforación ➡️", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── PANTALLA DE CORRIDAS (EJERCICIOS) ────────────────────────────────────
  Widget _buildCorridas(AppColors colors) {
    final c = _corridas[_corridaActual];

    return Column(
      children: [
        // Línea de progreso superior
        LinearProgressIndicator(
          value: (_corridaActual + (_corridaEnviada ? 1 : 0.5)) / _corridas.length,
          backgroundColor: colors.bordeSuave,
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
          minHeight: 5,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ficha del Pozo Activo (Datos del Turno)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("📋 Configuración del Pozo",
                              style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 13)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Diámetro ${_config.diametro}",
                              style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _datoRow("Punto Muerto (PM)", "${_config.pm.toStringAsFixed(2)} m", colors),
                      _datoRow("Barras en Sarta (Iniciales)", "${_config.nBarrasIniciales} barras de ${_config.largoBarra.toStringAsFixed(2)}m", colors),
                      _datoRow("Largo del Tubo Sacamuestras", "${_config.largoTuboSacamuestras.toStringAsFixed(2)} m", colors),
                      _datoRow("Fondo Inicial del Turno", "${_config.fondoInicial.toStringAsFixed(2)} m", colors),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Corrida Actual y su Contexto
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "CORRIDA ${c.numero} / ${_corridas.length}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Evento: ${c.eventoDescripcion}",
                        style: TextStyle(color: colors.grisTexto, fontSize: 11, fontStyle: FontStyle.italic),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // PANEL 1: OBSERVACIONES DE TERRENO (Lo que lee el operador)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.superficie,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.bordeSuave),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("🔎 Mediciones Físicas Observadas en Terreno",
                          style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 13)),
                      const Divider(height: 14),
                      
                      // Lectura de la Sonda / Contra
                      Row(
                        children: [
                          Icon(Icons.precision_manufacturing_outlined, color: colors.azul, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: colors.azulOscuro, fontSize: 13),
                                children: [
                                  const TextSpan(text: "Contra inicial sobre la mesa: "),
                                  TextSpan(text: "${c.contraAnterior.toStringAsFixed(2)} m\n", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(
                                    text: c.conAdicionBarra 
                                        ? "⚠️ Se roscó una barra adicional de 3.00 m en la sarta.\n" 
                                        : "No se añadieron barras adicionales en esta corrida.\n",
                                    style: TextStyle(
                                      color: c.conAdicionBarra ? Colors.orange : Colors.grey,
                                      fontSize: 11,
                                      fontWeight: c.conAdicionBarra ? FontWeight.bold : FontWeight.normal
                                    ),
                                  ),
                                  const TextSpan(text: "Contra final leída: "),
                                  TextSpan(text: "${c.contraNueva.toStringAsFixed(2)} m", style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Lectura del Testigo / Bandeja
                      Row(
                        children: [
                          const Icon(Icons.layers, color: Colors.teal, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: colors.azulOscuro, fontSize: 13),
                                children: [
                                  const TextSpan(text: "Testigo físico medido en la bandeja: "),
                                  TextSpan(text: "${c.testigoMedidoBandeja.toStringAsFixed(2)} m", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // PANEL 2: PLANILLA DE REGISTRO
                if (!_corridaEnviada) ...[
                  Text("✏️ Registra tus cálculos en la planilla:",
                      style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  _inputField("1. Avance Perforado (m)", _ctrlAvance, colors),
                  _inputField("2. Fondo Hasta (m)", _ctrlFondoHasta, colors),
                  _inputField("3. % Recuperación (ej: 95.2)", _ctrlRecuperacion, colors),
                  _inputField("4. Pérdida de Testigo (m)", _ctrlPerdida, colors),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _enviarCorrida,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Verificar carrera", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ] else ...[
                  // Retroalimentación detallada y paso a paso
                  _buildResultadoCorrida(c, colors),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _siguienteCorrida,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _corridaActual < _corridas.length - 1 ? const Color(0xFF4F46E5) : Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_corridaActual < _corridas.length - 1 ? "Siguiente Corrida ➡️" : "Ver Evaluación de Turno 📊"),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultadoCorrida(CorridaSimulada c, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.superficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.bordeSuave),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("📊 Evaluación y Desglose de Fórmulas",
                  style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 14)),
              Icon(
                c.todoCorrecto ? Icons.verified : Icons.warning_amber_rounded,
                color: c.todoCorrecto ? Colors.green : Colors.orange,
              )
            ],
          ),
          const Divider(height: 14),

          // 1. Avance Perforado
          _resultItem(
            "1. Avance Perforado (m)",
            c.avanceEsperado,
            c.avanceIngresado,
            c.isAvanceCorrecto,
            colors,
            formula: c.conAdicionBarra
                ? r"\text{Avance} = (C_{\text{ant}} + 3.00) - C_{\text{nueva}}"
                : r"\text{Avance} = C_{\text{ant}} - C_{\text{nueva}}",
            explicacion: c.conAdicionBarra
                ? "Con adición: (${c.contraAnterior.toStringAsFixed(2)} + 3.00) - ${c.contraNueva.toStringAsFixed(2)} = ${c.avanceEsperado.toStringAsFixed(2)} m"
                : "Sin adición: ${c.contraAnterior.toStringAsFixed(2)} - ${c.contraNueva.toStringAsFixed(2)} = ${c.avanceEsperado.toStringAsFixed(2)} m",
          ),

          // 2. Fondo Hasta
          _resultItem(
            "2. Fondo Hasta (m)",
            c.fondoHastaEsperado,
            c.fondoHastaIngresado,
            c.isFondoHastaCorrecto,
            colors,
            formula: r"\text{Fondo Hasta} = \text{Fondo}_{\text{ant}} + \text{Avance}",
            explicacion: "${c.fondoAnterior.toStringAsFixed(2)} + ${c.avanceEsperado.toStringAsFixed(2)} = ${c.fondoHastaEsperado.toStringAsFixed(2)} m",
          ),

          // 3. % Recuperación
          _resultItem(
            "3. Porcentaje de Recuperación",
            c.recuperacionEsperada,
            c.recuperacionIngresada,
            c.isRecuperacionCorrecta,
            colors,
            unit: "%",
            formula: r"\%\text{Rec} = \frac{\text{Testigo Medido}}{\text{Avance}} \times 100",
            explicacion: "(${c.testigoMedidoBandeja.toStringAsFixed(2)} / ${c.avanceEsperado.toStringAsFixed(2)}) * 100 = ${c.recuperacionEsperada.toStringAsFixed(1)}%",
          ),

          // 4. Pérdida
          _resultItem(
            "4. Pérdida de Testigo (m)",
            c.perdidaEsperada,
            c.perdidaIngresada,
            c.isPerdidaCorrecta,
            colors,
            formula: r"\text{Pérdida} = \text{Avance} - \text{Testigo Medido}",
            explicacion: "${c.avanceEsperado.toStringAsFixed(2)} - ${c.testigoMedidoBandeja.toStringAsFixed(2)} = ${c.perdidaEsperada.toStringAsFixed(2)} m (Taco de madera rotulado)",
          ),
        ],
      ),
    );
  }

  Widget _resultItem(
    String titulo,
    double correcto,
    double? ingresado,
    bool esCorrecto,
    AppColors colors, {
    String unit = " m",
    required String formula,
    required String explicacion,
  }) {
    return ExpansionTile(
      title: Row(
        children: [
          Icon(esCorrecto ? Icons.check_circle : Icons.cancel, color: esCorrecto ? Colors.green : Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              titulo,
              style: TextStyle(
                color: colors.azulOscuro,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 26, top: 2),
        child: Text(
          "Correcto: $correcto$unit  |  Respuesta: ${ingresado?.toString() ?? '—'}$unit",
          style: TextStyle(color: esCorrecto ? Colors.green.shade700 : Colors.red.shade700, fontSize: 11),
        ),
      ),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Fórmula aplicada:",
          style: TextStyle(color: colors.grisSecundario, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          width: double.infinity,
          decoration: BoxDecoration(color: colors.fondo, borderRadius: BorderRadius.circular(8)),
          child: LatexFormula(latex: formula, color: colors.azulOscuro, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Text(
          "Cálculo paso a paso:",
          style: TextStyle(color: colors.grisSecundario, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          explicacion,
          style: TextStyle(color: colors.azulOscuro, fontSize: 11, fontFamily: 'monospace'),
        ),
      ],
    );
  }

  // ─── PANTALLA DE EVALUACIÓN FINAL ─────────────────────────────────────────
  Widget _buildEvaluacion(AppColors colors) {
    final puntaje = _puntajeTotal;
    final calif = _calificacion;
    final colorPuntaje = puntaje >= 90 
        ? Colors.green.shade600 
        : puntaje >= 75 
            ? Colors.blue.shade600 
            : puntaje >= 60 
                ? Colors.orange.shade600 
                : Colors.red.shade600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Tarjeta de Puntaje Total
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorPuntaje, colorPuntaje.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.emoji_events_outlined, size: 52, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  "${puntaje.toStringAsFixed(0)}% de precisión",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
                ),
                const SizedBox(height: 4),
                Text(
                  calif,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  "Dificultad: $_dificultad  •  ${_corridas.length} corridas auditadas",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Planilla Resumen del Turno
          Text("Resumen de la Planilla de Turno:",
              style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _corridas.length,
            itemBuilder: (context, index) {
              final c = _corridas[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.superficie,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.todoCorrecto ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Corrida ${c.numero}: ${c.fondoAnterior.toStringAsFixed(2)}m ➡️ ${c.fondoHastaEsperado.toStringAsFixed(2)}m",
                          style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Icon(
                          c.todoCorrecto ? Icons.check_circle : Icons.warning_amber_rounded,
                          color: c.todoCorrecto ? Colors.green : Colors.orange,
                          size: 18,
                        )
                      ],
                    ),
                    const Divider(height: 8),
                    Text(
                      "Avance Perforado: ${c.avanceEsperado}m | Testigo: ${c.testigoMedidoBandeja}m | Rec: ${c.recuperacionEsperada}%",
                      style: TextStyle(color: colors.grisTexto, fontSize: 11),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _etrap(0),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Nuevo Turno"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4F46E5),
                    side: const BorderSide(color: Color(0xFF4F46E5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => widget.onNavigate('calculadoras'),
                  icon: const Icon(Icons.calculate),
                  label: const Text("Calculadoras"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _etrap(int val) {
    setState(() {
      _etapa = val;
      _corridaActual = 0;
      _corridaEnviada = false;
    });
  }

  Widget _datoRow(String label, String value, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colors.grisTexto, fontSize: 11)),
          Text(value, style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(color: colors.azulOscuro),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: colors.grisSecundario, fontSize: 13),
          filled: true,
          fillColor: colors.superficie,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.bordeSuave)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.bordeSuave)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}
