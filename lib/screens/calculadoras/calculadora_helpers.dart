import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';

Widget buildTextField(
  String label,
  TextEditingController controller,
  AppColors colors,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
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
  );
}

Widget buildBarraSelector(
  String label,
  String currentValue,
  Function(String) onChanged,
  AppColors colors,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: colors.azulOscuro,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.bordeSuave, width: 1),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: _buildSelectorOption(
                  "3.0 m",
                  currentValue == "3.00" || currentValue == "3.0" || currentValue == "3",
                  () => onChanged("3.00"),
                  colors,
                ),
              ),
              Expanded(
                child: _buildSelectorOption(
                  "2.9 m",
                  currentValue == "2.90" || currentValue == "2.9",
                  () => onChanged("2.90"),
                  colors,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildSelectorOption(
  String label,
  bool isSelected,
  VoidCallback onTap,
  AppColors colors,
) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? colors.azul : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colors.azul.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : colors.grisTexto,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    ),
  );
}

Widget buildResultadoCard(
  AppColors colors, {
  required String titulo,
  required String valor,
  required Color colorFondo,
  required Color colorTexto,
  required String explicacion,
  bool incompleto = false,
}) {
  final displayFondo = incompleto
      ? (colors.isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))
      : colorFondo;
  final displayTexto = incompleto
      ? (colors.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))
      : colorTexto;
  final displayValor = incompleto ? "Incompleto" : valor;
  final displayExplicacion = incompleto
      ? "Por favor ingresa datos numéricos válidos en los campos de arriba."
      : explicacion;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: displayFondo,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            color: displayTexto,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          displayValor,
          style: TextStyle(
            color: displayTexto,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          displayExplicacion,
          style: TextStyle(
            color: displayTexto.withValues(alpha: 0.95),
            fontSize: 12.5,
            height: 1.35,
          ),
        ),
      ],
    ),
  );
}
