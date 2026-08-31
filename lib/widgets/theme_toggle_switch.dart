import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';

class ThemeToggleSwitch extends StatelessWidget {
  final bool modoOscuro;
  final VoidCallback onTap;

  const ThemeToggleSwitch({
    super.key,
    required this.modoOscuro,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    const width = 64.0;
    const height = 32.0;
    const padding = 4.0;
    const thumbSize = height - (padding * 2);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: modoOscuro
                ? const Color(0xFF1E293B) // Fondo del track en oscuro
                : const Color(0xFFE2E8F0), // Fondo del track en claro
            border: Border.all(
              color: colors.bordeSuave,
              width: 1.5,
            ),
            boxShadow: modoOscuro
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Stack(
            children: [
              // Íconos decorativos en el fondo del track
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.wb_sunny,
                        size: 13,
                        color: Colors.amber,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.nights_stay,
                        size: 13,
                        color: Colors.indigo.shade300,
                      ),
                    ),
                  ],
                ),
              ),
              // Botón deslizable lateralmente (Thumb)
              AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                alignment: modoOscuro ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: padding),
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: modoOscuro
                          ? Colors.amber // Color cálido en modo oscuro
                          : Colors.white, // Blanco limpio en modo claro
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 3,
                          offset: const Offset(0, 1.5),
                        )
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        modoOscuro ? Icons.nights_stay : Icons.wb_sunny,
                        size: 11,
                        color: modoOscuro ? const Color(0xFF0F172A) : Colors.amber,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
