import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/widgets/custom_card.dart';

class AprenderScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const AprenderScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    // Steps list data
    final steps = [
      _StepItem(
        emoji: "🔧",
        title: "1. Preparación del trabajo",
        description: "Antes de iniciar el control, el controlador debe revisar el entorno, EPP, herramientas, materiales, equipos de apoyo y condiciones de seguridad. También debe conocer la información del pozo: cota, azimut, inclinación y profundidad.",
        colorAccent: colors.azul,
        colorFondo: colors.azulClaro,
      ),
      _StepItem(
        emoji: "🛡️",
        title: "2. Segregación y seguridad",
        description: "El controlador debe mantenerse fuera del área de perforación y trabajar desde una zona segregada. Si necesita ingresar al área de la perforista, debe contar con autorización y charla de ingreso.",
        colorAccent: colors.verde,
        colorFondo: colors.verdeClaro,
      ),
      _StepItem(
        emoji: "📦",
        title: "3. Recepción del testigo",
        description: "Una vez extraído el tubo interior, la muestra debe revisarse y traspasarse a la bandeja procurando alterar lo menos posible el orden original del testigo.",
        colorAccent: colors.naranjo,
        colorFondo: colors.naranjoClaro,
      ),
      _StepItem(
        emoji: "📐",
        title: "4. Traspaso a bandeja",
        description: "El testigo se ordena desde arriba hacia abajo y de izquierda a derecha. Debe mantenerse el orden, dejar espacio para tacos y registrar cualquier situación especial, como fractura inducida o muestra molida.",
        colorAccent: colors.purpura,
        colorFondo: colors.purpuraClaro,
      ),
      _StepItem(
        emoji: "📏",
        title: "5. Medición de recuperación",
        description: "El controlador mide la muestra recuperada y calcula el porcentaje de recuperación respecto al tramo perforado. Cada corrida debe separarse mediante taco de bloqueo.",
        colorAccent: colors.rojo,
        colorFondo: colors.rojoClaro,
      ),
      _StepItem(
        emoji: "📍",
        title: "6. Regularización",
        description: "La regularización marca soportes de distancia definidos por el proyecto, por ejemplo cada 2 metros. El taco de regularizado debe representar lo más fielmente posible el metraje real del testigo.",
        colorAccent: colors.azul,
        colorFondo: colors.azulClaro,
      ),
      _StepItem(
        emoji: "📋",
        title: "7. Reportabilidad",
        description: "Al finalizar el turno, se registran metrajes, recuperación, diámetro, barras, herramientas, casing, aditivos, observaciones, mediciones y cualquier situación que afecte la calidad de la muestra.",
        colorAccent: colors.verde,
        colorFondo: colors.verdeClaro,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Aspectos básicos"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack ?? () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: "Volver al Inicio",
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Módulos Teóricos",
                style: TextStyle(
                  color: colors.grisSecundario,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Pasos fundamentales simplificados",
                style: TextStyle(
                  color: colors.azulOscuro,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Conoce cada una de las fases críticas del control geológico y operacional de sondajes diamantinos en terreno.",
                style: TextStyle(
                  color: colors.grisTexto,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),

              // Animated Steps list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CustomCard(
                      titulo: "${step.emoji} ${step.title}",
                      descripcion: step.description,
                      colorAccent: step.colorAccent,
                      colorFondo: colors.superficie,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepItem {
  final String emoji;
  final String title;
  final String description;
  final Color colorAccent;
  final Color colorFondo;

  const _StepItem({
    required this.emoji,
    required this.title,
    required this.description,
    required this.colorAccent,
    required this.colorFondo,
  });
}
