import 'dart:math';
import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/widgets/drawer_menu.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Modelo interno de una corrida de perforación
// ─────────────────────────────────────────────────────────────────────────────
class _Corrida {
  final int numero;
  final double fondoAnterior;     // Desde (m)
  final double metrosPerforados;  // Lo que debe calcular el usuario
  final double testigoReal;       // Testigo real para comparar
  final bool conAdicion;          // ¿Se agregó una barra?

  // Entrada del usuario
  double? perforadoIngresado;
  double? testigoIngresado;
  double? contraIngresada;

  _Corrida({
    required this.numero,
    required this.fondoAnterior,
    required this.metrosPerforados,
    required this.testigoReal,
    this.conAdicion = false,
  });

  double get fondoNuevo => fondoAnterior + metrosPerforados;
  double get recuperacionReal => metrosPerforados > 0 ? (testigoReal / metrosPerforados) * 100 : 0;
  double? get recuperacionIngresada => (testigoIngresado != null && perforadoIngresado != null && perforadoIngresado! > 0)
      ? (testigoIngresado! / perforadoIngresado!) * 100 : null;

  bool get perforadoCorrecto => perforadoIngresado != null && (perforadoIngresado! - metrosPerforados).abs() <= 0.05;
  bool get testiguoCorrecto => testigoIngresado != null && (testigoIngresado! - testigoReal).abs() <= 0.05;
}

// ─────────────────────────────────────────────────────────────────────────────
// Generador de turno aleatorio
// ─────────────────────────────────────────────────────────────────────────────
class _GeneradorTurno {
  static const double _largoBarra = 3.00;
  static const double _largoBarril = 4.15;
  static const double _largoExtension = 0.40;

  final String dificultad; // 'Básico', 'Intermedio', 'Avanzado'
  final Random _rng = Random();

  _GeneradorTurno(this.dificultad);

  double get pm => 0.40 + _rng.nextDouble() * 0.20; // 0.40 – 0.60

  int get cantidadBarras {
    final base = 5 + _rng.nextInt(6); // 5–10 barras
    return base;
  }

  List<_Corrida> generarCorridas(double fondoInicial) {
    final int n = dificultad == 'Básico' ? 3 : dificultad == 'Intermedio' ? 4 : 5;
    final corridas = <_Corrida>[];
    double fondo = fondoInicial;
    for (int i = 0; i < n; i++) {
      final avance = 1.5 + _rng.nextDouble() * 1.5; // 1.50–3.00 m
      final avanceR = double.parse(avance.toStringAsFixed(2));
      final recPct = dificultad == 'Básico'
          ? 0.85 + _rng.nextDouble() * 0.15 // 85–100%
          : dificultad == 'Intermedio'
              ? 0.70 + _rng.nextDouble() * 0.25 // 70–95%
              : 0.50 + _rng.nextDouble() * 0.40; // 50–90%
      final testigo = double.parse((avanceR * recPct).toStringAsFixed(2));
      final adicion = dificultad != 'Básico' && i == n ~/ 2;
      corridas.add(_Corrida(
        numero: i + 1,
        fondoAnterior: double.parse(fondo.toStringAsFixed(2)),
        metrosPerforados: avanceR,
        testigoReal: testigo,
        conAdicion: adicion,
      ));
      fondo += avanceR;
    }
    return corridas;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget Principal del Simulacro
// ─────────────────────────────────────────────────────────────────────────────
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
  late double _pm;
  late int _nBarras;
  late double _fondoInicial;
  late List<_Corrida> _corridas;
  int _corridaActual = 0;

  // Controladores de texto para la corrida actual
  final _ctrlPerforado = TextEditingController();
  final _ctrlTestigo = TextEditingController();
  final _ctrlContra = TextEditingController();

  bool _corridaEnviada = false;

  final Random _rng = Random();

  void _iniciarSimulacro() {
    final gen = _GeneradorTurno(_dificultad);
    _pm = double.parse(gen.pm.toStringAsFixed(2));
    _nBarras = gen.cantidadBarras;
    _fondoInicial = 20.0 + _rng.nextInt(80).toDouble(); // Entre 20 y 99 m
    _fondoInicial = double.parse(_fondoInicial.toStringAsFixed(2));
    _corridas = gen.generarCorridas(_fondoInicial);
    _corridaActual = 0;
    _corridaEnviada = false;
    _ctrlPerforado.clear();
    _ctrlTestigo.clear();
    _ctrlContra.clear();
    setState(() => _etapa = 1);
  }

  void _enviarCorrida() {
    final c = _corridas[_corridaActual];
    c.perforadoIngresado = double.tryParse(_ctrlPerforado.text.replaceAll(',', '.'));
    c.testigoIngresado = double.tryParse(_ctrlTestigo.text.replaceAll(',', '.'));
    c.contraIngresada = double.tryParse(_ctrlContra.text.replaceAll(',', '.'));
    setState(() => _corridaEnviada = true);
  }

  void _siguienteCorrida() {
    if (_corridaActual < _corridas.length - 1) {
      setState(() {
        _corridaActual++;
        _corridaEnviada = false;
        _ctrlPerforado.clear();
        _ctrlTestigo.clear();
        _ctrlContra.clear();
      });
    } else {
      setState(() => _etapa = 2);
    }
  }

  double get _puntajeTotal {
    int correctas = 0;
    int total = 0;
    for (final c in _corridas) {
      if (c.perforadoCorrecto) correctas++;
      if (c.testiguoCorrecto) correctas++;
      total += 2;
    }
    return total > 0 ? (correctas / total) * 100 : 0;
  }

  String get _calificacion {
    final p = _puntajeTotal;
    if (p >= 90) return "⭐ Excelente";
    if (p >= 75) return "👍 Bueno";
    if (p >= 60) return "📖 Regular";
    return "🔁 Necesitas practicar más";
  }

  @override
  void dispose() {
    _ctrlPerforado.dispose();
    _ctrlTestigo.dispose();
    _ctrlContra.dispose();
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
      body: _etapa == 0
          ? _buildConfiguracion(colors)
          : _etapa == 1
              ? _buildCorridas(colors)
              : _buildEvaluacion(colors),
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
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("🎯", style: TextStyle(fontSize: 40)),
                SizedBox(height: 8),
                Text(
                  "Simulacro de Turno Completo",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 6),
                Text(
                  "Practica las corridas reales: ingresa los metros perforados, el testigo recuperado y la contra. Al finalizar recibirás una evaluación de tu precisión.",
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Selector de dificultad
          Text("Elige la dificultad:", style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...['Básico', 'Intermedio', 'Avanzado'].map((d) {
            final icons = ['🟢', '🟡', '🔴'];
            final descs = [
              'Sin adición de barras. Recuperación siempre alta (85–100%). Ideal para empezar.',
              'Con 1 adición de barra a mitad del turno. Recuperación variable (70–95%).',
              'Múltiples eventos. Recuperación baja posible (50–90%). Para controladores avanzados.',
            ];
            final idx = ['Básico', 'Intermedio', 'Avanzado'].indexOf(d);
            final isSelected = _dificultad == d;
            return GestureDetector(
              onTap: () => setState(() => _dificultad = d),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.deepPurple.withOpacity(0.08) : colors.superficie,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? Colors.deepPurple : colors.bordeSuave,
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
                          Text(descs[idx], style: TextStyle(color: colors.grisTexto, fontSize: 12, height: 1.3)),
                        ],
                      ),
                    ),
                    if (isSelected) const Icon(Icons.check_circle, color: Colors.deepPurple, size: 22),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _iniciarSimulacro,
              icon: const Icon(Icons.play_arrow, size: 22),
              label: const Text("Comenzar Simulacro", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── PANTALLA DE CORRIDAS ─────────────────────────────────────────────────
  Widget _buildCorridas(AppColors colors) {
    final c = _corridas[_corridaActual];

    return Column(
      children: [
        // Progreso
        LinearProgressIndicator(
          value: (_corridaActual + (_corridaEnviada ? 1 : 0)) / _corridas.length,
          backgroundColor: colors.bordeSuave,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Datos del turno (contexto)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📋 Datos del Turno",
                          style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      _datoRow("PM (Punto Muerto)", "${_pm.toStringAsFixed(2)} m", colors),
                      _datoRow("Barras en sarta", "$_nBarras barras × 3.00 m", colors),
                      _datoRow("Fondo inicial del turno", "${_fondoInicial.toStringAsFixed(2)} m", colors),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Corrida actual
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Corrida ${c.numero} / ${_corridas.length}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    if (c.conAdicion) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.5)),
                        ),
                        child: const Text("⚠️ Se agregó una barra en esta corrida",
                            style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 10),

                // Datos que el controlador ve (de terreno)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.superficie,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.bordeSuave),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("🔎 Información disponible en terreno",
                          style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 13)),
                      const Divider(height: 14),
                      _datoRow("Fondo anterior (Desde)", "${c.fondoAnterior.toStringAsFixed(2)} m", colors),
                      if (c.conAdicion)
                        _datoRow("Barra agregada", "3.00 m adicionales", colors),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Inputs del usuario
                if (!_corridaEnviada) ...[
                  Text("✏️ Registra la corrida:",
                      style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  _inputField("Metros perforados (Perforado)", _ctrlPerforado, colors),
                  _inputField("Testigo recuperado (m)", _ctrlTestigo, colors),
                  _inputField("Contra nueva (m)", _ctrlContra, colors),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _enviarCorrida,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Verificar Corrida", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ] else ...[
                  // Resultado de la corrida
                  _buildResultadoCorrida(c, colors),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _siguienteCorrida,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _corridaActual < _corridas.length - 1 ? Colors.deepPurple : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_corridaActual < _corridas.length - 1 ? "Siguiente Corrida ➡️" : "Ver Evaluación Final"),
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

  Widget _buildResultadoCorrida(_Corrida c, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.superficieSuave,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.bordeSuave),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("📊 Resultado de la Corrida ${c.numero}",
              style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 14)),
          const Divider(height: 14),
          _resultRow("Metros perforados", "${c.metrosPerforados} m",
              "${c.perforadoIngresado?.toStringAsFixed(2) ?? '—'} m", c.perforadoCorrecto, colors),
          _resultRow("Testigo recuperado", "${c.testigoReal} m",
              "${c.testigoIngresado?.toStringAsFixed(2) ?? '—'} m", c.testiguoCorrecto, colors),
          _resultRow("% Recuperación", "${c.recuperacionReal.toStringAsFixed(1)}%",
              "${c.recuperacionIngresada?.toStringAsFixed(1) ?? '—'}%",
              c.recuperacionIngresada != null && (c.recuperacionIngresada! - c.recuperacionReal).abs() <= 1.0, colors),
          _resultRow("Fondo nuevo", "${c.fondoNuevo.toStringAsFixed(2)} m", "—", true, colors),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String correcto, String ingresado, bool ok, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle : Icons.cancel, color: ok ? Colors.green : Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: colors.grisTexto, fontSize: 11)),
                Row(
                  children: [
                    Text("Correcto: ", style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(correcto, style: TextStyle(color: colors.azulOscuro, fontSize: 12)),
                    if (ingresado != "—") ...[
                      Text("  |  Tu respuesta: ", style: TextStyle(color: colors.grisSecundario, fontSize: 12)),
                      Text(ingresado, style: TextStyle(color: ok ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── PANTALLA DE EVALUACIÓN FINAL ─────────────────────────────────────────
  Widget _buildEvaluacion(AppColors colors) {
    final puntaje = _puntajeTotal;
    final calif = _calificacion;
    final colorPuntaje = puntaje >= 90 ? Colors.green : puntaje >= 75 ? Colors.blue : puntaje >= 60 ? Colors.orange : Colors.red;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Puntaje grande
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorPuntaje.withOpacity(0.8), colorPuntaje.withOpacity(0.5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(calif.split(' ').first, style: const TextStyle(fontSize: 52)),
                const SizedBox(height: 8),
                Text(
                  "${puntaje.toStringAsFixed(0)}% de precisión",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
                ),
                Text(
                  calif.substring(calif.indexOf(' ') + 1),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  "Dificultad: $_dificultad  •  ${_corridas.length} corridas",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Detalle por corrida
          Text("Detalle por corrida:",
              style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          ..._corridas.map((c) {
            final ok = c.perforadoCorrecto && c.testiguoCorrecto;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.superficie,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ok ? Colors.green.withOpacity(0.4) : Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(ok ? Icons.check_circle : Icons.cancel, color: ok ? Colors.green : Colors.red),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Corrida ${c.numero} — ${c.fondoAnterior.toStringAsFixed(2)} m → ${c.fondoNuevo.toStringAsFixed(2)} m",
                            style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(
                          "Perforado: ${c.metrosPerforados} m  |  Testigo: ${c.testigoReal} m  |  Rec: ${c.recuperacionReal.toStringAsFixed(1)}%",
                          style: TextStyle(color: colors.grisTexto, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() {
                    _etapa = 0;
                    _corridaActual = 0;
                    _corridaEnviada = false;
                  }),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Nuevo Simulacro"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    side: const BorderSide(color: Colors.deepPurple),
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
                  label: const Text("Practicar Más"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
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

  Widget _datoRow(String label, String value, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colors.grisTexto, fontSize: 12)),
          Text(value, style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 12)),
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
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.deepPurple, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}
