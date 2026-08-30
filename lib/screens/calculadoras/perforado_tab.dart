import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/utils/calculos_sondajes.dart';
import 'package:aprender_a_controlar/screens/calculadoras/calculadora_helpers.dart';
import 'package:aprender_a_controlar/screens/calculadoras/calculadora_practica_widget.dart';

class PerforadoTab extends StatefulWidget {
  const PerforadoTab({super.key});

  @override
  State<PerforadoTab> createState() => _PerforadoTabState();
}

class _PerforadoTabState extends State<PerforadoTab> {
  final _perfContraAntCtrl = TextEditingController(text: "2.80");
  final _perfContraActCtrl = TextEditingController(text: "0.60");
  final _perfBarraCtrl = TextEditingController(text: "3.00");
  final _perfFondoAntCtrl = TextEditingController(text: "120.00");
  final _perfFondoActCtrl = TextEditingController(text: "122.20");
  double _perfPorContras = 2.20;
  double _perfPorFondos = 2.20;
  bool _perfContrasIncompleto = false;
  bool _perfFondosIncompleto = false;

  @override
  void initState() {
    super.initState();
    _perfContraAntCtrl.addListener(_calcularPerforadoRealTime);
    _perfContraActCtrl.addListener(_calcularPerforadoRealTime);
    _perfBarraCtrl.addListener(_calcularPerforadoRealTime);
    _perfFondoAntCtrl.addListener(_calcularPerforadoRealTime);
    _perfFondoActCtrl.addListener(_calcularPerforadoRealTime);
    _calcularPerforadoRealTime();
  }

  @override
  void dispose() {
    _perfContraAntCtrl.dispose();
    _perfContraActCtrl.dispose();
    _perfBarraCtrl.dispose();
    _perfFondoAntCtrl.dispose();
    _perfFondoActCtrl.dispose();
    super.dispose();
  }

  void _calcularPerforadoRealTime() {
    final cAnt = double.tryParse(_perfContraAntCtrl.text.replaceAll(',', '.'));
    final cAct = double.tryParse(_perfContraActCtrl.text.replaceAll(',', '.'));
    final fAnt = double.tryParse(_perfFondoAntCtrl.text.replaceAll(',', '.'));
    final fAct = double.tryParse(_perfFondoActCtrl.text.replaceAll(',', '.'));
    final barra = double.tryParse(_perfBarraCtrl.text.replaceAll(',', '.')) ?? 3.00;

    setState(() {
      if (cAnt == null || cAct == null) {
        _perfContrasIncompleto = true;
      } else {
        _perfContrasIncompleto = false;
        if (cAct > cAnt) {
          final cAntAjustada = cAnt + barra;
          _perfPorContras = CalculosSondajes.redondear2(cAntAjustada - cAct);
        } else {
          _perfPorContras = CalculosSondajes.redondear2(cAnt - cAct);
        }
      }

      if (fAnt == null || fAct == null) {
        _perfFondosIncompleto = true;
      } else {
        _perfFondosIncompleto = false;
        _perfPorFondos = CalculosSondajes.redondear2(fAct - fAnt);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final cAnt = double.tryParse(_perfContraAntCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final cAct = double.tryParse(_perfContraActCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final barra = double.tryParse(_perfBarraCtrl.text.replaceAll(',', '.')) ?? 3.00;
    final cActMayor = cAct > cAnt;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Cálculo de Metros Perforados",
            style: TextStyle(
              color: colors.azulOscuro,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Permite calcular los metros perforados en la corrida por dos vías distintas para contrastar y validar la consistencia en el turno.",
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
                    "Vía 1: Por Contras",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  buildTextField("Contra Anterior (m)", _perfContraAntCtrl, colors),
                  buildTextField("Contra Actual (m)", _perfContraActCtrl, colors),
                  buildBarraSelector(
                    "Largo de Barra (m) (para ajuste si Contra Actual > Contra Anterior)",
                    _perfBarraCtrl.text,
                    (val) {
                      setState(() {
                        _perfBarraCtrl.text = val;
                        _calcularPerforadoRealTime();
                      });
                    },
                    colors,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Vía 2: Por Fondos",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  buildTextField("Fondo Anterior (m)", _perfFondoAntCtrl, colors),
                  buildTextField("Fondo Actual (m)", _perfFondoActCtrl, colors),
                  const SizedBox(height: 16),
                  buildResultadoCard(
                    colors,
                    titulo: "Perforado por Contras",
                    valor: "${_perfPorContras.toStringAsFixed(2)} m",
                    colorFondo: cActMayor ? colors.naranjoClaro : colors.azulClaro,
                    colorTexto: cActMayor ? colors.naranjo : colors.azul,
                    explicacion: cActMayor
                        ? "💡 Nota operacional: Como la contra actual (${cAct.toStringAsFixed(2)} m) es mayor a la anterior (${cAnt.toStringAsFixed(2)} m), se asume que se agregó una barra de ${barra.toStringAsFixed(2)} m.\nFórmula: (Contra Anterior + Largo barra) - Contra Actual\nCálculo: (${cAnt.toStringAsFixed(2)} m + ${barra.toStringAsFixed(2)} m) - ${cAct.toStringAsFixed(2)} m = ${_perfPorContras.toStringAsFixed(2)} m"
                        : "Fórmula: Contra Anterior - Contra Actual\nCálculo: ${_perfContraAntCtrl.text} m - ${_perfContraActCtrl.text} m = ${_perfPorContras.toStringAsFixed(2)} m",
                    incompleto: _perfContrasIncompleto,
                  ),
                  const SizedBox(height: 12),
                  buildResultadoCard(
                    colors,
                    titulo: "Perforado por Fondos",
                    valor: "${_perfPorFondos.toStringAsFixed(2)} m",
                    colorFondo: colors.verdeClaro,
                    colorTexto: colors.verde,
                    explicacion:
                        "Fórmula: Fondo Actual - Fondo Anterior\nCálculo: ${_perfFondoActCtrl.text} m - ${_perfFondoAntCtrl.text} m = ${_perfPorFondos.toStringAsFixed(2)} m",
                    incompleto: _perfFondosIncompleto,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          CalculadoraPracticaWidget(tipoIndex: 4, colors: colors),
        ],
      ),
    );
  }
}
