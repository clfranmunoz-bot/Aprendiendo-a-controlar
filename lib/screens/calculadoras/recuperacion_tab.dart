import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/utils/calculos_sondajes.dart';
import 'package:aprender_a_controlar/screens/calculadoras/calculadora_helpers.dart';
import 'package:aprender_a_controlar/screens/calculadoras/calculadora_practica_widget.dart';

class RecuperacionTab extends StatefulWidget {
  const RecuperacionTab({super.key});

  @override
  State<RecuperacionTab> createState() => _RecuperacionTabState();
}

class _RecuperacionTabState extends State<RecuperacionTab> {
  final _recPerfCtrl = TextEditingController(text: "3.00");
  final _recRecCtrl = TextEditingController(text: "2.85");
  double _recPorcentaje = 95.0;
  bool _recIncompleto = false;

  @override
  void initState() {
    super.initState();
    _recPerfCtrl.addListener(_calcularRecuperacionRealTime);
    _recRecCtrl.addListener(_calcularRecuperacionRealTime);
    _calcularRecuperacionRealTime();
  }

  @override
  void dispose() {
    _recPerfCtrl.dispose();
    _recRecCtrl.dispose();
    super.dispose();
  }

  void _calcularRecuperacionRealTime() {
    final perf = double.tryParse(_recPerfCtrl.text.replaceAll(',', '.'));
    final rec = double.tryParse(_recRecCtrl.text.replaceAll(',', '.'));
    setState(() {
      if (perf == null || rec == null || perf <= 0) {
        _recIncompleto = true;
      } else {
        _recIncompleto = false;
        _recPorcentaje = CalculosSondajes.redondear2((rec / perf) * 100);
      }
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
            "Cálculo de Recuperación",
            style: TextStyle(
              color: colors.azulOscuro,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Calcula el porcentaje de recuperación del testigo de sondaje diamantino a partir de la corrida perforada y los metros recuperados físicamente.",
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
                    "Operación en Terreno (Entradas Rápidas)",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  buildTextField("Metros Perforados (m)", _recPerfCtrl, colors),
                  buildTextField("Metros Recuperados (m)", _recRecCtrl, colors),
                  const SizedBox(height: 16),
                  buildResultadoCard(
                    colors,
                    titulo: "Recuperación Calculada",
                    valor: _recPorcentaje > 100.0 ? "Cálculo Inválido" : "${_recPorcentaje.toStringAsFixed(2)} %",
                    colorFondo: _recPorcentaje > 100.0
                        ? colors.rojoClaro
                        : _recPorcentaje >= 90
                            ? colors.verdeClaro
                            : _recPorcentaje >= 70
                                ? colors.naranjoClaro
                                : colors.rojoClaro,
                    colorTexto: _recPorcentaje > 100.0
                        ? colors.rojo
                        : _recPorcentaje >= 90
                            ? colors.verde
                            : _recPorcentaje >= 70
                                ? colors.naranjo
                                : colors.rojo,
                    explicacion: _recPorcentaje > 100.0
                        ? "⚠️ Error: La recuperación no puede superar el 100% de la corrida perforada (no se puede recuperar más de lo que se perfora)."
                        : _recPorcentaje >= 90
                            ? "Excelente recuperación geológica (>=90%). El testigo conserva la integridad operacional."
                            : _recPorcentaje >= 70
                                ? "Recuperación aceptable (70%-89%). Revise zonas de fracturación natural inducida."
                                : "Recuperación crítica (<70%). Informe al geólogo supervisor de inmediato.",
                    incompleto: _recIncompleto,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          CalculadoraPracticaWidget(tipoIndex: 0, colors: colors),
        ],
      ),
    );
  }
}
