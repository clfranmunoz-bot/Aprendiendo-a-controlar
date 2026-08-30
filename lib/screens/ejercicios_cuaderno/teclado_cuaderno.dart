import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';

class TecladoCuaderno extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback onDonePressed;
  final AppColors colors;

  const TecladoCuaderno({
    super.key,
    required this.onKeyPressed,
    required this.onBackspacePressed,
    required this.onDonePressed,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final buttonBgColor = colors.isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final buttonTextColor = colors.isDark ? Colors.white : const Color(0xFF1E293B);

    Widget buildKey(String label, VoidCallback onTap, {Color? bg, Color? textCol}) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.all(2.5),
          height: 38,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: bg ?? buttonBgColor,
              foregroundColor: textCol ?? buttonTextColor,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(color: colors.isDark ? Colors.white10 : Colors.black12, width: 0.5),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: colors.isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.bordeSuave, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              buildKey("1", () => onKeyPressed("1")),
              buildKey("2", () => onKeyPressed("2")),
              buildKey("3", () => onKeyPressed("3")),
              buildKey("⌫", onBackspacePressed, bg: colors.isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
            ],
          ),
          Row(
            children: [
              buildKey("4", () => onKeyPressed("4")),
              buildKey("5", () => onKeyPressed("5")),
              buildKey("6", () => onKeyPressed("6")),
              buildKey("-", () => onKeyPressed("-"), bg: colors.isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
            ],
          ),
          Row(
            children: [
              buildKey("7", () => onKeyPressed("7")),
              buildKey("8", () => onKeyPressed("8")),
              buildKey("9", () => onKeyPressed("9")),
              buildKey(".", () => onKeyPressed("."), bg: colors.isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
            ],
          ),
          Row(
            children: [
              buildKey("0", () => onKeyPressed("0")),
              buildKey(",", () => onKeyPressed(",")),
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.all(2.5),
                  height: 38,
                  child: ElevatedButton(
                    onPressed: onDonePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.azul,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      "Listo ✓",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
