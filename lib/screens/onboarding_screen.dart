import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/utils/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const OnboardingScreen({super.key, required this.onNavigate});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      "emoji": "👋",
      "title": "¡Bienvenido a Aprender a Controlar!",
      "description": "Tu entrenador personal para dominar la operación de sondaje diamantino en terreno. Aquí aprenderás a calcular parámetros críticos del pozo de forma rápida y sin errores.",
    },
    {
      "emoji": "🧮",
      "title": "Calculadoras Operacionales",
      "description": "Calcula el porcentaje de recuperación diamantina, la contra (sobrante de sarta), la profundidad del fondo del pozo y la distribución de los tacos de regularización.",
    },
    {
      "emoji": "📓",
      "title": "El Cuaderno de Terreno",
      "description": "Practica el registro en la planilla del pozo tal como lo harías en papel. Escribe las cotas, cuenta las barras, calcula las herramientas y valida tus resultados al instante.",
    },
    {
      "emoji": "🚀",
      "title": "Listo para Empezar",
      "description": "Entrena en modo normal o contrarreloj para poner a prueba tu velocidad de cálculo bajo presión. Sigue tu progreso y estadísticas día a día para convertirte en un experto.",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completarOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_visto', true);
    await prefs.setBool('onboarding_seen', true);
    if (!mounted) return;
    widget.onNavigate(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.fondo,
      body: SafeArea(
        child: Column(
          children: [
            // Top Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextButton(
                  onPressed: _completarOnboarding,
                  child: Text(
                    "Omitir",
                    style: TextStyle(
                      color: colors.grisTexto,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Sliding pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, idx) {
                  final slide = _slides[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          slide["emoji"]!,
                          style: const TextStyle(fontSize: 90),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          slide["title"]!,
                          style: TextStyle(
                            color: colors.azulOscuro,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide["description"]!,
                          style: TextStyle(
                            color: colors.grisTexto,
                            fontSize: 14.5,
                            height: 1.45,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom indicators and buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(
                      _slides.length,
                      (idx) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentPage == idx ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentPage == idx ? colors.azul : colors.bordeSuave,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),

                  // Action Button
                  SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _completarOnboarding();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.azul,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _slides.length - 1 ? "Comenzar" : "Siguiente",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
