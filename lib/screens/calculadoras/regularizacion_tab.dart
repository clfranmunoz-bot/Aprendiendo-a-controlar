import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/screens/calculadoras/calculadora_helpers.dart';
import 'package:aprender_a_controlar/screens/calculadoras/calculadora_practica_widget.dart';

class RegularizacionTab extends StatefulWidget {
  const RegularizacionTab({super.key});

  @override
  State<RegularizacionTab> createState() => _RegularizacionTabState();
}

class _RegularizacionTabState extends State<RegularizacionTab> {
  final _regTacoIniCtrl = TextEditingController(text: "236.30");
  final _regTacoFinCtrl = TextEditingController(text: "239.20");
  final _regRecCtrl = TextEditingController(text: "2.10");
  final _regMetrajesCtrl = TextEditingController(text: "238, 239");

  String _regErrorMsg = "";
  double _regPerforado = 2.90;
  double _regRecPorcentaje = 72.4;
  List<RegularizadoResultado> _regResultados = [];

  @override
  void initState() {
    super.initState();
    _calcularRegularizacion();
  }

  @override
  void dispose() {
    _regTacoIniCtrl.dispose();
    _regTacoFinCtrl.dispose();
    _regRecCtrl.dispose();
    _regMetrajesCtrl.dispose();
    super.dispose();
  }

  void _calcularRegularizacion() {
    setState(() {
      _regErrorMsg = "";
      _regResultados.clear();
    });

    final inicio = double.tryParse(_regTacoIniCtrl.text.replaceAll(',', '.'));
    final fin = double.tryParse(_regTacoFinCtrl.text.replaceAll(',', '.'));
    final rec = double.tryParse(_regRecCtrl.text.replaceAll(',', '.'));
    final rawMetrajes = _regMetrajesCtrl.text.trim();

    if (inicio == null || fin == null || rec == null || rawMetrajes.isEmpty) {
      setState(() => _regErrorMsg = "Por favor ingresa valores numéricos válidos en todos los campos.");
      return;
    }

    if (fin <= inicio) {
      setState(() => _regErrorMsg = "El taco final debe ser mayor que el taco inicial.");
      return;
    }

    if (rec <= 0) {
      setState(() => _regErrorMsg = "La muestra recuperada debe ser mayor a 0.");
      return;
    }

    final perf = fin - inicio;
    if (rec > perf) {
      setState(() => _regErrorMsg = "La recuperación física no puede superar el tramo perforado (${perf.toStringAsFixed(2)} m).");
      return;
    }

    List<String> parts;
    if (rawMetrajes.contains(';')) {
      parts = rawMetrajes.split(';');
    } else if (rawMetrajes.contains(', ')) {
      parts = rawMetrajes.split(', ');
    } else if (rawMetrajes.contains(' ') && !rawMetrajes.contains(',')) {
      parts = rawMetrajes.split(RegExp(r'\s+'));
    } else if (rawMetrajes.contains(' ') && rawMetrajes.contains(',')) {
      parts = rawMetrajes.split(RegExp(r'\s+'));
    } else {
      parts = rawMetrajes.split(',');
    }

    final metrajes = parts
        .map((s) => double.tryParse(s.trim().replaceAll(',', '.')))
        .whereType<double>()
        .toList();

    if (metrajes.isEmpty) {
      setState(() => _regErrorMsg = "Ingresa metrajes válidos separados por comas. Ejemplo: 238, 239");
      return;
    }

    final invalidos = metrajes.where((m) => m < inicio || m > fin).toList();
    if (invalidos.isNotEmpty) {
      setState(() {
        _regErrorMsg =
            "Todos los metrajes teóricos deben estar comprendidos entre el taco inicial (${inicio.toStringAsFixed(2)} m) y el final (${fin.toStringAsFixed(2)} m).";
      });
      return;
    }

    metrajes.sort();

    final listaRes = <RegularizadoResultado>[];
    for (int i = 0; i < metrajes.length; i++) {
      final metraje = metrajes[i];
      final distTeorica = metraje - inicio;
      final distFisica = (distTeorica * rec) / perf;
      final distRedondeada = (distFisica * 100).round() / 100.0;

      double medirDesdeAnterior = distRedondeada;
      if (i > 0) {
        final distFisicaAnterior = listaRes[i - 1].distanciaFisica;
        medirDesdeAnterior = ((distRedondeada - distFisicaAnterior) * 100).round() / 100.0;
      }

      listaRes.add(
        RegularizadoResultado(
          metrajeTeorico: metraje,
          distanciaFisica: distRedondeada,
          medidaDesdePrevio: medirDesdeAnterior,
        ),
      );
    }

    setState(() {
      _regPerforado = perf;
      _regRecPorcentaje = (rec / perf) * 100;
      _regResultados = listaRes;
    });
  }

  void _limpiarRegularizacion() {
    _regTacoIniCtrl.clear();
    _regTacoFinCtrl.clear();
    _regRecCtrl.clear();
    _regMetrajesCtrl.clear();
    setState(() {
      _regErrorMsg = "";
      _regResultados.clear();
      _regPerforado = 0.0;
      _regRecPorcentaje = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Cálculo de Regularización de Testigos",
            style: TextStyle(
              color: colors.azulOscuro,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Calcula la ubicación física exacta de los tacos de regularización teóricos dentro de la corrida física de la bandeja en base al tramo perforado y la recuperación real.",
            style: TextStyle(
              color: colors.grisTexto,
              fontSize: 14.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: colors.superficie,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colors.bordeSuave, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Parámetros de la Corrida",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: buildTextField("Taco Inicial (m)", _regTacoIniCtrl, colors),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: buildTextField("Taco Final (m)", _regTacoFinCtrl, colors),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: buildTextField("Muestra Recuperada (m)", _regRecCtrl, colors),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextField(
                            controller: _regMetrajesCtrl,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: "Metrajes a marcar",
                              hintText: "Ej: 238, 239",
                              filled: true,
                              fillColor: colors.isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.bordeSuave, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.bordeSuave, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.azul, width: 1.5),
                              ),
                              labelStyle: TextStyle(
                                color: colors.grisTexto,
                                fontSize: 14,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.calculate),
                          label: const Text("Simular Distribución"),
                          onPressed: _calcularRegularizacion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.naranjo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _limpiarRegularizacion,
                        tooltip: "Limpiar campos",
                        style: IconButton.styleFrom(
                          backgroundColor: colors.superficieSuave,
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                    ],
                  ),
                  if (_regErrorMsg.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      _regErrorMsg,
                      style: TextStyle(
                        color: colors.rojo,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_regResultados.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              "Representación Visual del Testigo Físico:",
              style: TextStyle(
                color: colors.azulOscuro,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            _buildRegVisualCoreTray(colors),
            const SizedBox(height: 24),
            Text(
              "Instrucciones de Marcado en el Testigo:",
              style: TextStyle(
                color: colors.azulOscuro,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            _buildRegMedicionesCard(colors),
          ],
          const SizedBox(height: 28),
          CalculadoraPracticaWidget(tipoIndex: 3, colors: colors),
        ],
      ),
    );
  }

  Widget _buildRegVisualCoreTray(AppColors colors) {
    final recuperadoVal = double.tryParse(_regRecCtrl.text.replaceAll(',', '.')) ?? 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.bordeSuave),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Perforado: ${_regPerforado.toStringAsFixed(2)} m",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                "Recuperación: ${_regRecPorcentaje.toStringAsFixed(1)}%",
                style: TextStyle(
                  color: _regRecPorcentaje >= 90
                      ? colors.verde
                      : _regRecPorcentaje >= 70
                          ? colors.naranjo
                          : colors.rojo,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final double physicalWidth =
                  _regPerforado > 0 ? width * (recuperadoVal / _regPerforado).clamp(0.0, 1.0) : 0.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: width,
                        height: 28,
                        decoration: BoxDecoration(
                          color: colors.isDark ? const Color(0x3D000000) : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            "Vacío / Pérdida de Muestra",
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ),
                      ),
                      if (physicalWidth > 0)
                        Container(
                          width: physicalWidth,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: colors.isDark
                                  ? [
                                      const Color(0xFF64748B),
                                      const Color(0xFF475569),
                                    ]
                                  : [
                                      const Color(0xFF94A3B8),
                                      const Color(0xFF64748B),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "Testigo Físico (${recuperadoVal.toStringAsFixed(2)} m)",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ..._regResultados.map((res) {
                        final double pos =
                            recuperadoVal > 0 ? (res.distanciaFisica / recuperadoVal) * physicalWidth : 0.0;
                        final double clampedPos = (pos - 1.5).clamp(0.0, width - 3.0);

                        return Positioned(
                          left: clampedPos,
                          top: 0,
                          child: Tooltip(
                            message:
                                "Taco ${res.metrajeTeorico.toStringAsFixed(2)}m (${res.distanciaFisica.toStringAsFixed(2)}m físico)",
                            child: Container(
                              width: 3,
                              height: 28,
                              color: colors.naranjo,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "0.0m (Inicio)",
                        style: TextStyle(fontSize: 11),
                      ),
                      Text(
                        "${recuperadoVal.toStringAsFixed(2)}m (Fin corrida)",
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRegMedicionesCard(AppColors colors) {
    return Card(
      color: colors.superficie,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.bordeSuave, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(_regResultados.length, (index) {
            final res = _regResultados[index];
            final esUltimo = index == _regResultados.length - 1;
            final distStr = index == 0 ? res.distanciaFisica.toStringAsFixed(2) : res.medidaDesdePrevio.toStringAsFixed(2);

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: esUltimo ? Colors.transparent : colors.bordeSuave.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: colors.naranjo.withValues(alpha: 0.15),
                    foregroundColor: colors.naranjo,
                    radius: 18,
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "📍 Taco Regularizado: ${res.metrajeTeorico.toStringAsFixed(2)} m",
                          style: TextStyle(
                            color: colors.azulOscuro,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: colors.grisTexto,
                              fontSize: 13.5,
                              height: 1.3,
                            ),
                            children: [
                              const TextSpan(text: "Medir "),
                              TextSpan(
                                text: "$distStr m",
                                style: TextStyle(
                                  color: colors.naranjo,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.5,
                                ),
                              ),
                              TextSpan(
                                text: index == 0
                                    ? " físicos directos desde el taco inicial."
                                    : " físicos desde el taco anterior (${_regResultados[index - 1].metrajeTeorico.toStringAsFixed(2)} m).",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colors.naranjo.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.naranjo.withValues(alpha: 0.3), width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "MEDIR",
                          style: TextStyle(
                            color: colors.naranjo,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "$distStr m",
                          style: TextStyle(
                            color: colors.naranjo,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class RegularizadoResultado {
  final double metrajeTeorico;
  final double distanciaFisica;
  final double medidaDesdePrevio;

  const RegularizadoResultado({
    required this.metrajeTeorico,
    required this.distanciaFisica,
    required this.medidaDesdePrevio,
  });
}
