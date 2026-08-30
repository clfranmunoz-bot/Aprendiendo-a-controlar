import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/utils/calculos_sondajes.dart';
import 'package:aprender_a_controlar/screens/calculadoras/calculadora_helpers.dart';
import 'package:aprender_a_controlar/screens/calculadoras/calculadora_practica_widget.dart';

class FondoTab extends StatefulWidget {
  const FondoTab({super.key});

  @override
  State<FondoTab> createState() => _FondoTabState();
}

class _FondoTabState extends State<FondoTab> {
  final _fondoBarrasCtrl = TextEditingController(text: "40");
  final _fondoBarraLCtrl = TextEditingController(text: "3.00");
  final _fondoHerrCtrl = TextEditingController(text: "1.50");
  final _fondoPuntoMCtrl = TextEditingController(text: "0.80");
  final _fondoContraCtrl = TextEditingController(text: "0.50");
  double _fondoCalculado = 120.20;
  bool _fondoIncompleto = false;

  @override
  void initState() {
    super.initState();
    _fondoBarrasCtrl.addListener(_calcularFondoRealTime);
    _fondoBarraLCtrl.addListener(_calcularFondoRealTime);
    _fondoHerrCtrl.addListener(_calcularFondoRealTime);
    _fondoPuntoMCtrl.addListener(_calcularFondoRealTime);
    _fondoContraCtrl.addListener(_calcularFondoRealTime);
    _calcularFondoRealTime();
  }

  @override
  void dispose() {
    _fondoBarrasCtrl.dispose();
    _fondoBarraLCtrl.dispose();
    _fondoHerrCtrl.dispose();
    _fondoPuntoMCtrl.dispose();
    _fondoContraCtrl.dispose();
    super.dispose();
  }

  void _calcularFondoRealTime() {
    final barras = double.tryParse(_fondoBarrasCtrl.text.replaceAll(',', '.'));
    final barraL = double.tryParse(_fondoBarraLCtrl.text.replaceAll(',', '.'));
    final herr = double.tryParse(_fondoHerrCtrl.text.replaceAll(',', '.'));
    final pm = double.tryParse(_fondoPuntoMCtrl.text.replaceAll(',', '.'));
    final contra = double.tryParse(_fondoContraCtrl.text.replaceAll(',', '.'));

    setState(() {
      if (barras == null || barraL == null || herr == null || pm == null || contra == null) {
        _fondoIncompleto = true;
      } else {
        _fondoIncompleto = false;
        _fondoCalculado = CalculosSondajes.redondear2(
          (barras * barraL) + herr - pm - contra,
        );
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
            "Cálculo de Fondo Estimado del Pozo",
            style: TextStyle(
              color: colors.azulOscuro,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Determina la profundidad actual del pozo diamantino usando la cantidad total de barras en sarta, largo de barra, largo de barril, punto muerto y la contra actual.",
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
                  buildTextField("Cantidad de Barras en Sarta", _fondoBarrasCtrl, colors),
                  buildTextField("Largo de Barra (m)", _fondoBarraLCtrl, colors),
                  buildTextField("Largo de Barril (m)", _fondoHerrCtrl, colors),
                  buildTextField("Punto Muerto (m)", _fondoPuntoMCtrl, colors),
                  buildTextField("Contra Actual (m)", _fondoContraCtrl, colors),
                  const SizedBox(height: 16),
                  buildResultadoCard(
                    colors,
                    titulo: "Fondo de Pozo Estimado",
                    valor: "${_fondoCalculado.toStringAsFixed(2)} m",
                    colorFondo: colors.azulClaro,
                    colorTexto: colors.azul,
                    explicacion:
                        "Fórmula de Terreno:\nFondo = (Barras × Largo) + Barril - Punto Muerto - Contra\nCálculo: ((${_fondoBarrasCtrl.text} × ${_fondoBarraLCtrl.text}) + ${_fondoHerrCtrl.text}) - ${_fondoPuntoMCtrl.text} - ${_fondoContraCtrl.text} = ${_fondoCalculado.toStringAsFixed(2)} m",
                    incompleto: _fondoIncompleto,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          CalculadoraPracticaWidget(tipoIndex: 2, colors: colors),
        ],
      ),
    );
  }
}
