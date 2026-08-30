import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/utils/ejercicios_data.dart';
import 'package:aprender_a_controlar/screens/ejercicios/ejercicios_helpers.dart';

class EjerciciosBancoEstatico extends StatefulWidget {
  final VoidCallback onBack;

  const EjerciciosBancoEstatico({
    super.key,
    required this.onBack,
  });

  @override
  State<EjerciciosBancoEstatico> createState() => _EjerciciosBancoEstaticoState();
}

class _EjerciciosBancoEstaticoState extends State<EjerciciosBancoEstatico> {
  String _staticSearchQuery = "";
  final Map<int, int?> _staticAnswers = {};
  final Map<int, bool> _staticRevealed = {};

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    final filteredIndices = <int>[];
    for (int i = 0; i < bancoEjercicios.length; i++) {
      final ex = bancoEjercicios[i];
      if (_staticSearchQuery.isEmpty ||
          ex.enunciado.toLowerCase().contains(_staticSearchQuery.toLowerCase()) ||
          ex.titulo.toLowerCase().contains(_staticSearchQuery.toLowerCase())) {
        filteredIndices.add(i);
      }
    }

    return Column(
      children: [
        TextField(
          style: TextStyle(color: colors.azulOscuro),
          decoration: InputDecoration(
            hintText: "Buscar ejercicios por palabra clave...",
            hintStyle: TextStyle(color: colors.grisTexto),
            prefixIcon: Icon(Icons.search, color: colors.grisSecundario),
            filled: true,
            fillColor: colors.superficie,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.bordeSuave, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.bordeSuave, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.azul, width: 1.5),
            ),
          ),
          onChanged: (val) {
            setState(() {
              _staticSearchQuery = val;
            });
          },
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Se encontraron ${filteredIndices.length} de ${bancoEjercicios.length} casos prácticos:",
            style: TextStyle(
              color: colors.grisSecundario,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: filteredIndices.isEmpty
              ? Center(
                  child: Text(
                    "No se encontraron ejercicios con esa búsqueda.",
                    style: TextStyle(color: colors.grisTexto),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredIndices.length,
                  itemBuilder: (context, listIdx) {
                    final originalIdx = filteredIndices[listIdx];
                    final ex = bancoEjercicios[originalIdx];

                    final selectedOpt = _staticAnswers[originalIdx];
                    final revealed = _staticRevealed[originalIdx] ?? false;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.superficie,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: colors.bordeSuave,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ex.titulo,
                                style: TextStyle(
                                  color: colors.azul,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (revealed)
                                Icon(
                                  selectedOpt == ex.correcta ? Icons.check_circle : Icons.cancel,
                                  color: selectedOpt == ex.correcta ? colors.verde : colors.rojo,
                                  size: 18,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          textWithLatex(
                            colors,
                            ex.enunciado,
                            style: TextStyle(
                              color: colors.azulOscuro,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                            latexFontSize: 16,
                          ),
                          const SizedBox(height: 14),
                          ...List.generate(ex.opciones.length, (optIdx) {
                            final optionText = ex.opciones[optIdx];
                            final isCorrect = optIdx == ex.correcta;
                            final isSelected = optIdx == selectedOpt;

                            Color btnColor = colors.superficieSuave;
                            Color textColor = colors.azulOscuro;
                            BorderSide border = BorderSide(
                              color: colors.bordeSuave,
                            );

                            if (revealed) {
                              if (isCorrect) {
                                btnColor = colors.verdeClaro;
                                textColor = colors.verde;
                                border = BorderSide(
                                  color: colors.verde,
                                  width: 1.2,
                                );
                              } else if (isSelected) {
                                btnColor = colors.rojoClaro;
                                textColor = colors.rojo;
                                border = BorderSide(
                                  color: colors.rojo,
                                  width: 1.2,
                                );
                              } else {
                                btnColor = colors.superficieSuave.withOpacity(0.4);
                                textColor = colors.grisSecundario;
                                border = BorderSide(
                                  color: colors.bordeSuave.withOpacity(0.4),
                                );
                              }
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () {
                                  if (revealed) return;
                                  setState(() {
                                    _staticAnswers[originalIdx] = optIdx;
                                    _staticRevealed[originalIdx] = true;
                                  });
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: btnColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.fromBorderSide(border),
                                  ),
                                  child: Text(
                                    optionText,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 13.5,
                                      fontWeight: isSelected || (revealed && isCorrect) ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          if (revealed) ...[
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: selectedOpt == ex.correcta
                                    ? colors.verdeClaro.withOpacity(0.7)
                                    : colors.rojoClaro.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: selectedOpt == ex.correcta
                                      ? colors.verde.withOpacity(0.2)
                                      : colors.rojo.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedOpt == ex.correcta ? "✅ Correcto" : "❌ Incorrecto",
                                    style: TextStyle(
                                      color: selectedOpt == ex.correcta ? colors.verde : colors.rojo,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  retroWidget(
                                    colors,
                                    selectedOpt == ex.correcta
                                        ? ex.retroalimentacion
                                        : "La respuesta correcta era: ${ex.opciones[ex.correcta]}\n\n${ex.retroalimentacion}",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
