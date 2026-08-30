import 'package:flutter/material.dart';

class CustomCard extends StatefulWidget {
  final String titulo;
  final String descripcion;
  final Color colorAccent;
  final Color colorFondo;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.colorAccent,
    required this.colorFondo,
    this.onTap,
  });

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final hasAction = widget.onTap != null;

    return MouseRegion(
      cursor: hasAction ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (hasAction) setState(() => _scale = 1.02);
      },
      onExit: (_) {
        if (hasAction) setState(() => _scale = 1.0);
      },
      child: GestureDetector(
        onTapDown: (_) {
          if (hasAction) setState(() => _scale = 0.98);
        },
        onTapUp: (_) {
          if (hasAction) setState(() => _scale = 1.02);
        },
        onTapCancel: () {
          if (hasAction) setState(() => _scale = 1.0);
        },
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: widget.colorFondo,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(widget.colorFondo == Colors.white ? 0.04 : 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 6,
                      color: widget.colorAccent,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.titulo,
                              style: TextStyle(
                                color: widget.colorFondo == Colors.white
                                    ? const Color(0xFF0F172A)
                                    : Theme.of(context).textTheme.bodyLarge?.color,
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.descripcion,
                              style: TextStyle(
                                color: widget.colorFondo == Colors.white
                                    ? const Color(0xFF475569)
                                    : Theme.of(context).textTheme.bodyMedium?.color,
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
