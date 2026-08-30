import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/utils/calculos_sondajes.dart';
import 'package:aprender_a_controlar/screens/calculadoras/calculadora_helpers.dart';
import 'package:aprender_a_controlar/screens/calculadoras/calculadora_practica_widget.dart';

class ContraTab extends StatefulWidget {
  const ContraTab({super.key});

  @override
  State<ContraTab> createState() => _ContraTabState();
}

class _ContraTabState extends State<ContraTab> {
  final _contraAntCtrl = TextEditingController(text: "2.50");
  final _contraPerfCtrl = TextEditingController(text: "1.20");
  final _contraBarraCtrl = TextEditingController(text: "3.00");
  double _contraCalculada = 1.30;
  String _contraNota = "";
  bool _contraIncompleto = false;

  @override
  void initState() {
    super.initState();
    _contraAntCtrl.addListener(_calcularContraRealTime);
    _contraPerfCtrl.addListener(_calcularContraRealTime);
    _contraBarraCtrl.addListener(_calcularContraRealTime);
    _calcularContraRealTime();
  }

  @override
  void dispose() {
    _contraAntCtrl.dispose();
    _contraPerfCtrl.dispose();
    _contraBarraCtrl.dispose();
    super.dispose();
  }

  void _calcularContraRealTime() {
    final contraAnt = double.tryParse(_contraAntCtrl.text.replaceAll(',', '.'));
    final perf = double.tryParse(_contraPerfCtrl.text.replaceAll(',', '.'));
    final barra = double.tryParse(_contraBarraCtrl.text.replaceAll(',', '.')) ?? 3.00;

    setState(() {
      if (contraAnt == null || perf == null) {
        _contraIncompleto = true;
      } else {
        _contraIncompleto = false;
        double contraAntAjustada = contraAnt;
        bool barraAgregada = false;

        if (contraAnt < perf) {
          contraAntAjustada = contraAnt + barra;
          barraAgregada = true;
        }

        _contraCalculada = CalculosSondajes.redondear2(
          contraAntAjustada - perf,
        );
        if (barraAgregada) {
          _contraNota =
              "💡 Nota operacional: Como la contra anterior (${contraAnt.toStringAsFixed(2)} m) es menor al perforado (${perf.toStringAsFixed(2)} m), se asume que se agregó una nueva barra de ${barra.toStringAsFixed(2)} m. Contra anterior ajustada a ${contraAntAjustada.toStringAsFixed(2)} m.";
        } else {
          _contraNota =
              "La contra anterior es mayor o igual al perforado. Se resta directamente.";
        }
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
            "Cálculo de Contra / Sobrante",
            style: TextStyle(
              color: colors.azulOscuro,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Estima la contra o sarta sobrante respecto al cabezal. Útil para verificar si se añadió una barra operacional adicional cuando la contra anterior es menor al perforado.",
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
                  buildTextField("Contra Anterior (m)", _contraAntCtrl, colors),
                  buildTextField("Metros Perforados (m)", _contraPerfCtrl, colors),
                  buildBarraSelector("Largo de Barra (m)", _contraBarraCtrl.text, (val) {
                    setState(() {
                      _contraBarraCtrl.text = val;
                      _calcularContraRealTime();
                    });
                  }, colors),
                  const SizedBox(height: 16),
                  buildResultadoCard(
                    colors,
                    titulo: "Contra Estimada",
                    valor: "${_contraCalculada.toStringAsFixed(2)} m",
                    colorFondo: _contraCalculada < 0 || _contraCalculada > 3.2
                        ? colors.rojoClaro
                        : colors.purpuraClaro,
                    colorTexto: _contraCalculada < 0 || _contraCalculada > 3.2
                        ? colors.rojo
                        : colors.purpura,
                    explicacion: _contraCalculada < 0
                        ? "⚠️ Error: Contra negativa. Verifique los datos de perforación y barras."
                        : _contraCalculada > 3.2
                            ? "⚠️ Advertencia: La contra calculada supera el largo de una barra de terreno."
                            : _contraNota,
                    incompleto: _contraIncompleto,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          CalculadoraPracticaWidget(tipoIndex: 1, colors: colors),
        ],
      ),
    );
  }
}
