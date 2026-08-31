import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/screens/ejercicios_screen.dart'; // For TrainerTopic enum

class EjerciciosDashboard extends StatelessWidget {
  final VoidCallback onStartRound;
  final Function(TrainerTopic) onStartTopicTrainer;
  final VoidCallback onStartStaticBank;

  const EjerciciosDashboard({
    super.key,
    required this.onStartRound,
    required this.onStartTopicTrainer,
    required this.onStartStaticBank,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.purpura, colors.purpura.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "🏋️ Entrenamiento de Campo",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Elige una de las modalidades de entrenamiento interactivo para perfeccionar tus habilidades operativas de cálculo y control de sondaje.",
                  style: TextStyle(
                    color: Color(0xE6FFFFFF),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            "Modalidad Evaluativa",
            style: TextStyle(
              color: colors.azulOscuro,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          _buildDashboardWidget(
            colors,
            "1. Ronda Evaluativa de 15 Casos",
            "Prueba tus habilidades de terreno con una ronda de 15 ejercicios dinámicos al azar con dificultad regulable y retroalimentación completa.",
            colors.azul,
            true,
            onStartRound,
          ),
          const SizedBox(height: 20),

          Text(
            "Entrenadores Específicos por Competencia",
            style: TextStyle(
              color: colors.azulOscuro,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 550) {
                return Column(
                  children: [
                    _buildDashboardWidget(
                      colors,
                      "2. Cálculo de Contra",
                      "Cálculo de contra estimada con barras y fondo",
                      colors.purpura,
                      true,
                      () => onStartTopicTrainer(TrainerTopic.contra),
                    ),
                    const SizedBox(height: 12),
                    _buildDashboardWidget(
                      colors,
                      "3. Fondo de Pozo",
                      "Cálculo de fondo de pozo con problemas al azar",
                      const Color(0xFF006064),
                      true,
                      () => onStartTopicTrainer(TrainerTopic.fondo),
                    ),
                    const SizedBox(height: 12),
                    _buildDashboardWidget(
                      colors,
                      "4. Recuperación",
                      "Cálculo de recuperación con decimales y casos reales",
                      const Color(0xFF7C4DFF),
                      true,
                      () => onStartTopicTrainer(TrainerTopic.recuperacion),
                    ),
                    const SizedBox(height: 12),
                    _buildDashboardWidget(
                      colors,
                      "5. Regularización",
                      "Simulación de ubicación física de regularización",
                      const Color(0xFFD84315),
                      true,
                      () => onStartTopicTrainer(TrainerTopic.regularizacion),
                    ),
                  ],
                );
              } else {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildDashboardWidget(
                            colors,
                            "2. Cálculo de Contra",
                            "Cálculo de contra estimada con barras y fondo",
                            colors.purpura,
                            false,
                            () => onStartTopicTrainer(TrainerTopic.contra),
                          ),
                          const SizedBox(height: 12),
                          _buildDashboardWidget(
                            colors,
                            "4. Recuperación",
                            "Cálculo de recuperación con decimales y casos reales",
                            const Color(0xFF7C4DFF),
                            false,
                            () => onStartTopicTrainer(TrainerTopic.recuperacion),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          _buildDashboardWidget(
                            colors,
                            "3. Fondo de Pozo",
                            "Cálculo de fondo de pozo con problemas al azar",
                            const Color(0xFF006064),
                            false,
                            () => onStartTopicTrainer(TrainerTopic.fondo),
                          ),
                          const SizedBox(height: 12),
                          _buildDashboardWidget(
                            colors,
                            "5. Regularización",
                            "Simulación de ubicación física de regularización",
                            const Color(0xFFD84315),
                            false,
                            () => onStartTopicTrainer(TrainerTopic.regularizacion),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 12),

          _buildDashboardWidget(
            colors,
            "6. Metraje Perforado",
            "Cálculo de metraje perforado a partir de contras o fondos de pozo al azar en nivel básico, medio o avanzado.",
            colors.verde,
            true,
            () => onStartTopicTrainer(TrainerTopic.perforado),
          ),
          const SizedBox(height: 20),

          Text(
            "Banco Oficial de Terreno",
            style: TextStyle(
              color: colors.azulOscuro,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          _buildDashboardWidget(
            colors,
            "7. Banco de 60 Casos Prácticos",
            "Estudia y resuelve el listado oficial completo de 60 casos prácticos recopilados en operaciones reales de control de sondaje.",
            Colors.blueGrey,
            true,
            onStartStaticBank,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDashboardWidget(
    AppColors colors,
    String titulo,
    String detalle,
    Color colorAcento,
    bool esAnchoCompleto,
    VoidCallback accion,
  ) {
    return GestureDetector(
      onTap: accion,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.superficie,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.bordeSuave, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colorAcento,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titulo,
                    style: TextStyle(
                      color: colors.azulOscuro,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              detalle,
              style: TextStyle(
                color: colors.grisTexto,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
