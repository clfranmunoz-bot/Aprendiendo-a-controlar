import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:aprender_a_controlar/utils/app_colors.dart';

class CalculadoraBolsillo extends StatefulWidget {
  final Function(Offset)? onDrag;
  final VoidCallback? onClose;
  const CalculadoraBolsillo({super.key, this.onDrag, this.onClose});

  @override
  State<CalculadoraBolsillo> createState() => _CalculadoraBolsilloState();
}

class _CalculadoraBolsilloState extends State<CalculadoraBolsillo> {
  String _input = "";
  String _result = "=";
  bool _scientificActive = false;
  bool _hasError = false;

  void _onKeyPress(String value) {
    setState(() {
      if (value == "C") {
        _input = "";
        _result = "=";
        _hasError = false;
      } else if (value == "DEL") {
        if (_input.isNotEmpty) {
          _input = _input.substring(0, _input.length - 1);
          _evaluate();
        }
      } else if (value == "=") {
        _evaluate(force: true);
      } else {
        // Safe appends for function helpers
        if (value == "sin" || value == "cos" || value == "tan" || value == "log" || value == "ln") {
          _input += "$value(";
        } else if (value == "√") {
          _input += "√(";
        } else {
          _input += value;
        }
        _evaluate();
      }
    });
  }

  void _evaluate({bool force = false}) {
    if (_input.trim().isEmpty) {
      _result = "=";
      _hasError = false;
      return;
    }

    try {
      double res = _evaluarMatematicas(_input);
      if (res.isNaN || res.isInfinite) {
        _result = "Valor indefinido";
        _hasError = true;
      } else {
        // Format decimals nicely
        _result = "= ${_formatDouble(res)}";
        _hasError = false;
      }
    } catch (e) {
      if (force) {
        _result = "Error de sintaxis";
        _hasError = true;
      } else {
        // Real-time syntax errors are subtle and green-ish/gray unless forced
        _result = "=";
        _hasError = false;
      }
    }
  }

  String _formatDouble(double val) {
    if (val == val.toInt()) {
      return val.toInt().toString();
    }
    // Limit to 4 decimal places for field readability
    String s = val.toStringAsFixed(4);
    while (s.endsWith('0')) {
      s = s.substring(0, s.length - 1);
    }
    if (s.endsWith('.')) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }

  double _evaluarMatematicas(String str) {
    // Standardize input
    str = str.toLowerCase()
        .replaceAll('x', '*')
        .replaceAll('÷', '/')
        .replaceAll(',', '.')
        .replaceAll('√', 'sqrt')
        .replaceAll('π', 'pi');

    int pos = -1;
    int ch = 0;

    void nextChar() {
      pos++;
      ch = pos < str.length ? str.codeUnitAt(pos) : -1;
    }

    bool eat(int charToEat) {
      while (ch == 32) { // ' ' space
        nextChar();
      }
      if (ch == charToEat) {
        nextChar();
        return true;
      }
      return false;
    }

    late double Function() parseExpression;
    late double Function() parseTerm;
    late double Function() parseFactor;

    parseExpression = () {
      double x = parseTerm();
      while (true) {
        if (eat(43)) { // '+'
          x += parseTerm();
        } else if (eat(45)) { // '-'
          x -= parseTerm();
        } else {
          return x;
        }
      }
    };

    parseTerm = () {
      double x = parseFactor();
      while (true) {
        if (eat(42)) { // '*'
          x *= parseFactor();
        } else if (eat(47)) { // '/'
          x /= parseFactor();
        } else {
          return x;
        }
      }
    };

    parseFactor = () {
      if (eat(43)) return parseFactor(); // unary '+'
      if (eat(45)) return -parseFactor(); // unary '-'

      double x;
      int startPos = pos;
      if (eat(40)) { // '('
        x = parseExpression();
        eat(41); // ')'
      } else if ((ch >= 48 && ch <= 57) || ch == 46) { // '0'..'9' or '.'
        while ((ch >= 48 && ch <= 57) || ch == 46) {
          nextChar();
        }
        x = double.parse(str.substring(startPos, pos));
      } else if ((ch >= 97 && ch <= 122) || ch == 960) { // 'a'..'z' or 'π' (code unit 960)
        while ((ch >= 97 && ch <= 122) || ch == 960) {
          nextChar();
        }
        String name = str.substring(startPos, pos);
        if (name == 'pi') {
          x = math.pi;
        } else if (name == 'e') {
          x = math.e;
        } else {
          eat(40); // '('
          double arg = parseExpression();
          eat(41); // ')'
          switch (name) {
            case 'sin':
              // Perform in DEGREES as operational users expect degree inclinations
              x = math.sin(arg * math.pi / 180.0);
              break;
            case 'cos':
              x = math.cos(arg * math.pi / 180.0);
              break;
            case 'tan':
              x = math.tan(arg * math.pi / 180.0);
              break;
            case 'sqrt':
              x = math.sqrt(arg);
              break;
            case 'log':
              x = math.log(arg) / math.ln10;
              break;
            case 'ln':
              x = math.log(arg);
              break;
            default:
              throw Exception("Función desconocida: $name");
          }
        }
      } else {
        throw Exception("Esperado número, función o paréntesis");
      }

      if (eat(94)) { // '^'
        x = math.pow(x, parseFactor()).toDouble();
      }

      return x;
    };

    nextChar();
    double val = parseExpression();
    if (pos < str.length) {
      throw Exception("Carácter inesperado: ${String.fromCharCode(ch)}");
    }
    return val;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    final standardButtons = [
      ["C", "(", ")", "÷"],
      ["7", "8", "9", "x"],
      ["4", "5", "6", "-"],
      ["1", "2", "3", "+"],
      ["0", ".", "DEL", "="]
    ];

    final scientificButtons = [
      ["sin", "cos", "tan", "^"],
      ["√", "π", "e", "log"]
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.superficieSuave,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.bordeSuave, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          GestureDetector(
            onPanUpdate: widget.onDrag == null
                ? null
                : (details) => widget.onDrag!(details.delta),
            behavior: HitTestBehavior.translucent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.drag_indicator,
                      size: 16,
                      color: colors.azul.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Mover",
                      style: TextStyle(
                        color: colors.azulOscuro,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _scientificActive = !_scientificActive;
                        });
                      },
                      icon: Icon(
                        _scientificActive ? Icons.grid_view : Icons.science,
                        size: 14,
                        color: colors.azul,
                      ),
                      label: Text(
                        _scientificActive ? "Estándar" : "Científica",
                        style: TextStyle(
                          color: colors.azul,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: colors.superficie,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    if (widget.onClose != null) ...[
                      const SizedBox(width: 6),
                      IconButton(
                        icon: Icon(Icons.close, color: colors.rojo, size: 18),
                        onPressed: widget.onClose,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Display panel
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A), // Premium deep dark display in both modes
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Text(
                    _input.isEmpty ? "0" : _input,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Text(
                    _result,
                    style: TextStyle(
                      color: _hasError ? colors.rojo : colors.verde,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Scientific Panel
          if (_scientificActive) ...[
            Column(
              children: scientificButtons.map((row) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: row.map((btnText) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: _buildButton(
                            btnText: btnText,
                            backgroundColor: colors.purpura,
                            textColor: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
            const Divider(height: 12, thickness: 1),
          ],

          // Standard Panel
          Column(
            children: standardButtons.map((row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: row.map((btnText) {
                    // Styles based on character
                    Color btnBg = colors.superficie;
                    Color txtColor = colors.azulOscuro;

                    if (btnText == "C" || btnText == "DEL") {
                      btnBg = colors.isDark ? const Color(0xFF2C3E50) : const Color(0xFFE2E8F0);
                      txtColor = colors.rojo;
                    } else if (btnText == "=") {
                      btnBg = colors.azul;
                      txtColor = Colors.white;
                    } else if (["+", "-", "x", "÷"].contains(btnText)) {
                      btnBg = colors.azulClaro;
                      txtColor = colors.azul;
                    }

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _buildButton(
                          btnText: btnText,
                          backgroundColor: btnBg,
                          textColor: txtColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String btnText,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return SizedBox(
      height: 38,
      child: ElevatedButton(
        onPressed: () => _onKeyPress(btnText),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          btnText,
          style: TextStyle(
            color: textColor,
            fontSize: btnText.length > 2 ? 11 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
