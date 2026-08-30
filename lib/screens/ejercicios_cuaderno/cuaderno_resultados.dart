import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';

class CuadernoResultados extends StatelessWidget {
  final AppColors colors;
  final int aciertos;
  final int cantidadCorridas;
  final int totalVerificaciones;
  final String rango;
  final String reportText;
  final VoidCallback onRetry;

  const CuadernoResultados({
    super.key,
    required this.colors,
    required this.aciertos,
    required this.cantidadCorridas,
    required this.totalVerificaciones,
    required this.rango,
    required this.reportText,
    required this.onRetry,
  });

  Widget _buildDataRow(String label, String value, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colors.grisTexto, fontSize: 12.5)),
          Text(value, style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "🏆",
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 12),
          Text(
            "¡Simulación Finalizada!",
            style: TextStyle(
              color: colors.azulOscuro,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Has completado todas las corridas con éxito. Este es tu resumen de desempeño:",
            style: TextStyle(color: colors.grisTexto, fontSize: 14),
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
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    "Corridas correctas en el primer intento:",
                    style: TextStyle(color: colors.grisTexto, fontSize: 13.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$aciertos / $cantidadCorridas",
                    style: TextStyle(
                      color: aciertos >= (cantidadCorridas * 0.8)
                          ? colors.verde
                          : aciertos >= (cantidadCorridas * 0.6)
                              ? colors.naranjo
                              : colors.rojo,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 16, thickness: 1.2),
                  _buildDataRow("Total de verificaciones realizadas:", "$totalVerificaciones", colors),
                  const Divider(height: 16, thickness: 1.2),
                  Text(
                    "Tu rango en este pozo:",
                    style: TextStyle(color: colors.grisTexto, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rango,
                    style: TextStyle(
                      color: colors.azulOscuro,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: reportText));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("📋 ¡Reporte de planilla copiado al portapapeles! Listo para pegar en Excel o WhatsApp."),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.azul, width: 1.5),
                foregroundColor: colors.azul,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.copy_all_outlined),
              label: const Text("Copiar Planilla (Reporte de Turno)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.azul,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text("Intentar con Otro Pozo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.bordeSuave, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Volver al Panel de Inicio",
                style: TextStyle(color: colors.azulOscuro, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
