import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class LatexFormula extends StatelessWidget {
  final String latex;
  final Color? color;
  final double fontSize;
  final TextAlign textAlign;

  const LatexFormula({
    super.key,
    required this.latex,
    this.color,
    this.fontSize = 16,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.onSurface;
    final alignment = switch (textAlign) {
      TextAlign.left => Alignment.centerLeft,
      TextAlign.right => Alignment.centerRight,
      _ => Alignment.center,
    };

    var clean = latex.trim();
    while (clean.startsWith(r'$$') && clean.endsWith(r'$$') && clean.length >= 4) {
      clean = clean.substring(2, clean.length - 2).trim();
    }
    while (clean.startsWith(r'$') && clean.endsWith(r'$') && clean.length >= 2) {
      clean = clean.substring(1, clean.length - 1).trim();
    }

    return Align(
      alignment: alignment,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Math.tex(
          clean,
          textStyle: TextStyle(color: effectiveColor, fontSize: fontSize),
          mathStyle: MathStyle.display,
          onErrorFallback: (FlutterMathException e) {
            return Text(
              clean,
              textAlign: textAlign,
              style: TextStyle(
                color: effectiveColor,
                fontSize: fontSize,
                fontFamily: 'monospace',
              ),
            );
          },
        ),
      ),
    );
  }
}
