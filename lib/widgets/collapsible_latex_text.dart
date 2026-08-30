import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:aprender_a_controlar/widgets/latex_formula.dart';

class CollapsibleLatexText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final double latexFontSize;
  final Color latexColor;
  final bool showToggleButton;
  final bool? isExpanded;
  final VoidCallback? onToggle;

  const CollapsibleLatexText({
    super.key,
    required this.text,
    required this.textStyle,
    required this.latexFontSize,
    required this.latexColor,
    this.showToggleButton = true,
    this.isExpanded,
    this.onToggle,
  });

  @override
  State<CollapsibleLatexText> createState() => _CollapsibleLatexTextState();
}

class _CollapsibleLatexTextState extends State<CollapsibleLatexText> {
  bool _showFormulas = false;

  @override
  Widget build(BuildContext context) {
    final lines = widget.text.split('\n');
    final formulas = <String>[];
    final alwaysVisibleLines = <String>[];
    final formulaInfoLines = <String>[];
    var inFormulaInfo = false;

    for (final raw in lines) {
      final line = raw.trimRight();
      if (line.trim().startsWith('LATEX:')) {
        final latex = line.trim().substring('LATEX:'.length).trim();
        if (latex.isNotEmpty) formulas.add(latex);
        continue;
      }

      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        if (!inFormulaInfo) alwaysVisibleLines.add('');
        continue;
      }

      if (trimmed.toLowerCase().startsWith('donde:')) {
        inFormulaInfo = true;
      }

      if (inFormulaInfo) {
        formulaInfoLines.add(line);
        final isBullet = trimmed.startsWith('•') || trimmed.startsWith('-');
        if (!isBullet && !trimmed.toLowerCase().startsWith('donde:')) {
          formulaInfoLines.removeLast();
          alwaysVisibleLines.add(line);
          inFormulaInfo = false;
        }
      } else {
        alwaysVisibleLines.add(line);
      }
    }

    final children = <Widget>[];
    for (final t in alwaysVisibleLines) {
      children.add(_buildRichTextLine(t));
    }

    final hasFormulaSection = formulas.isNotEmpty || formulaInfoLines.isNotEmpty;
    final expanded = widget.isExpanded ?? _showFormulas;

    if (hasFormulaSection && widget.showToggleButton) {
      children.add(const SizedBox(height: 8));
      children.add(
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              if (widget.onToggle != null) {
                widget.onToggle!.call();
                return;
              }
              setState(() => _showFormulas = !_showFormulas);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(expanded ? "Ocultar Fórmula" : "Fórmula"),
          ),
        ),
      );
    }

    if (expanded) {
      for (final f in formulas) {
        children.add(const SizedBox(height: 8));
        children.add(
          LatexFormula(
            latex: f,
            color: widget.latexColor,
            fontSize: widget.latexFontSize,
            textAlign: TextAlign.center,
          ),
        );
      }

      if (formulaInfoLines.isNotEmpty) {
        children.add(const SizedBox(height: 10));
        for (final line in formulaInfoLines) {
          children.add(_buildRichTextLine(line));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildRichTextLine(String t) {
    final trimmed = t.trim();
    if (trimmed.isEmpty) return const SizedBox(height: 6);

    // Block formula (starts with $$ and ends with $$)
    if (trimmed.startsWith(r'$$') && trimmed.endsWith(r'$$') && trimmed.length >= 4) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: LatexFormula(
          latex: trimmed,
          color: widget.latexColor,
          fontSize: widget.latexFontSize,
          textAlign: TextAlign.center,
        ),
      );
    }

    // Check for inline LaTeX $...$ or $$...$$
    final pattern = RegExp(r'\$\$(.*?)\$\$|\$(.*?)\$');
    if (!pattern.hasMatch(t)) {
      return Text(t, style: widget.textStyle);
    }

    final spans = <InlineSpan>[];
    int start = 0;

    for (final match in pattern.allMatches(t)) {
      if (match.start > start) {
        spans.add(TextSpan(text: t.substring(start, match.start)));
      }

      final latexContent = (match.group(1) ?? match.group(2) ?? '').trim();
      if (latexContent.isNotEmpty) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Math.tex(
                latexContent,
                textStyle: widget.textStyle.copyWith(
                  color: widget.latexColor,
                  fontSize: widget.latexFontSize * 0.9,
                ),
                mathStyle: MathStyle.text,
                onErrorFallback: (FlutterMathException e) {
                  return Text(
                    latexContent,
                    style: widget.textStyle.copyWith(
                      color: widget.latexColor,
                      fontFamily: 'monospace',
                    ),
                  );
                },
              ),
            ),
          ),
        );
      }
      start = match.end;
    }

    if (start < t.length) {
      spans.add(TextSpan(text: t.substring(start)));
    }

    return Text.rich(
      TextSpan(children: spans, style: widget.textStyle),
    );
  }
}
