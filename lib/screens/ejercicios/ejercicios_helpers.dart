import 'package:flutter/material.dart';
import 'package:aprender_a_controlar/utils/app_colors.dart';
import 'package:aprender_a_controlar/widgets/collapsible_latex_text.dart';

Widget retroWidget(AppColors colors, String retro) {
  final lines = retro.split('\n');
  String? latexLine;
  final rest = <String>[];
  for (final line in lines) {
    if (latexLine == null && line.trim().startsWith('LATEX:')) {
      latexLine = line.trim().substring('LATEX:'.length).trim();
    } else {
      rest.add(line);
    }
  }

  latexLine ??= _inferLatex(rest.join('\n').trim());

  final combined = StringBuffer();
  if (latexLine != null && latexLine.isNotEmpty) {
    combined.writeln('LATEX: $latexLine');
  }
  combined.write(rest.join('\n').trim());

  return CollapsibleLatexText(
    text: combined.toString(),
    textStyle: TextStyle(
      color: colors.azulOscuro.withOpacity(0.9),
      fontSize: 13,
      height: 1.4,
    ),
    latexFontSize: 16,
    latexColor: colors.azulOscuro.withOpacity(0.9),
  );
}

String? _inferLatex(String text) {
  if (text.isEmpty) return null;
  final candidates = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
  final line = candidates.firstWhere(
    (l) => l.contains('=') || l.contains('×') || l.contains('÷') || l.contains('/'),
    orElse: () => '',
  );
  if (line.isEmpty) return null;

  var expr = line;
  expr = expr.replaceFirst(RegExp(r'^[^:]{0,40}:\s*'), '');
  expr = expr.replaceAll(RegExp(r'[.;]\s*$'), '');

  if (!(expr.contains('=') || expr.contains('×') || expr.contains('÷') || expr.contains('/'))) {
    return null;
  }

  expr = expr
      .replaceAll('×', r'\times ')
      .replaceAll('÷', r'\div ')
      .replaceAll('%', r'\%')
      .replaceAll('·', r'\cdot ');

  expr = expr.replaceAllMapped(
    RegExp(r'(\d),(\d)'),
    (m) => '${m[1]}.${m[2]}',
  );

  expr = expr.replaceAll('/', r' \,/\, ');

  return expr.trim();
}

Widget textWithLatex(
  AppColors colors,
  String text, {
  TextStyle? style,
  double latexFontSize = 16,
  bool showToggleButton = true,
  bool? expanded,
}) {
  final baseStyle = style ??
      TextStyle(
        color: colors.azulOscuro,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  return CollapsibleLatexText(
    text: text,
    textStyle: baseStyle,
    latexFontSize: latexFontSize,
    latexColor: baseStyle.color ?? colors.azulOscuro,
    showToggleButton: showToggleButton,
    isExpanded: expanded,
  );
}

bool hasFormulaContent(String text) {
  if (text.contains('LATEX:')) return true;
  return text.toLowerCase().contains('\ndonde:') || text.toLowerCase().startsWith('donde:');
}
