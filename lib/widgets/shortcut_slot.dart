import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/models/seccion.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';

class ShortcutSlot extends StatefulWidget {
  final int slotIndex;
  final SeccionApp? seccion;
  final bool isEditable;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ShortcutSlot({
    super.key,
    required this.slotIndex,
    this.seccion,
    required this.isEditable,
    required this.onTap,
    this.onDelete,
  });

  @override
  State<ShortcutSlot> createState() => _ShortcutSlotState();
}

class _ShortcutSlotState extends State<ShortcutSlot> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = colors.isDark;
    final isEmpty = widget.seccion == null;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _scale = 1.01),
      onExit: (_) => setState(() => _scale = 1.0),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.98),
        onTapUp: (_) => setState(() => _scale = 1.01),
        onTapCancel: () => setState(() => _scale = 1.0),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: Container(
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isEmpty
                  ? (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white.withValues(alpha: 0.7))
                  : (isDark ? const Color(0xFF1E293B) : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isEditable
                    ? Colors.amber
                    : (isEmpty
                        ? colors.bordeSuave.withValues(alpha: 0.4)
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                width: widget.isEditable ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icono
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isEmpty
                        ? colors.grisSecundario.withValues(alpha: 0.1)
                        : colors.getMenuColor(widget.seccion!.colorIndex).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isEmpty
                          ? colors.bordeSuave.withValues(alpha: 0.3)
                          : colors.getMenuColor(widget.seccion!.colorIndex).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.seccion?.emoji ?? "➕",
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Textos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.seccion?.titulo ?? "Slot ${widget.slotIndex + 1} (Vacío)",
                        style: TextStyle(
                          color: isDark ? Colors.white : colors.azulOscuro,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.seccion?.descripcion ?? "Toca para asignar un acceso directo",
                        style: TextStyle(
                          color: isDark ? Colors.white60 : colors.grisTexto,
                          fontSize: 11.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.isEditable && !isEmpty && widget.onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 22),
                    onPressed: widget.onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                else
                  Icon(
                    widget.isEditable ? Icons.edit : Icons.arrow_forward_ios,
                    size: 14,
                    color: widget.isEditable ? Colors.amber : (isDark ? Colors.white38 : colors.grisSecundario),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
