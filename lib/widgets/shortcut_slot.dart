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
    final isEmpty = widget.seccion == null;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _scale = 1.03),
      onExit: (_) => setState(() => _scale = 1.0),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.97),
        onTapUp: (_) => setState(() => _scale = 1.03),
        onTapCancel: () => setState(() => _scale = 1.0),
        onTap: widget.isEditable && !isEmpty ? null : widget.onTap,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: Container(
            decoration: BoxDecoration(
              color: isEmpty
                  ? (colors.isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02))
                  : colors.getMenuColor(widget.seccion!.colorIndex).withOpacity(colors.isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isEmpty
                    ? colors.bordeSuave.withOpacity(0.3)
                    : colors.getMenuColor(widget.seccion!.colorIndex).withOpacity(0.4),
                width: isEmpty ? 1.5 : 1,
                style: isEmpty ? BorderStyle.solid : BorderStyle.solid,
              ),
              boxShadow: isEmpty
                  ? []
                  : [
                      BoxShadow(
                        color: colors.getMenuColor(widget.seccion!.colorIndex).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Content of the Slot
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  color: colors.grisSecundario.withOpacity(0.8),
                                  size: 28,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Slot ${widget.slotIndex + 1}\n(Vacío)",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: colors.grisSecundario,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.seccion!.emoji,
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.seccion!.titulo,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.azulOscuro,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    height: 1.15,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                // Delete Button (if in editable mode and not empty)
                if (widget.isEditable && !isEmpty && widget.onDelete != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: widget.onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colors.rojo,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
