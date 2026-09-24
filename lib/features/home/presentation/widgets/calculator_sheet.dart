/// Widget: CalculatorSheet
///
/// Modal bottom sheet kalkulator sederhana untuk perhitungan cepat
/// tanpa harus keluar dari aplikasi TabunganKu.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';

/// Modal bottom sheet yang menampilkan kalkulator numerik.
class CalculatorSheetContent extends ConsumerStatefulWidget {
  const CalculatorSheetContent({super.key});

  /// Helper statis untuk menampilkan bottom sheet kalkulator.
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CalculatorSheetContent(),
    );
  }

  @override
  ConsumerState<CalculatorSheetContent> createState() =>
      _CalculatorSheetContentState();
}

class _CalculatorSheetContentState
    extends ConsumerState<CalculatorSheetContent> {
  String _output = "0";
  String _expression = "";
  double? _num1;
  double? _num2;
  String? _operand;

  void _calculate() {
    if (_num1 == null || _operand == null) return;
    _num2 = double.tryParse(_output.replaceAll('.', '').replaceAll(',', '.'));
    if (_num2 == null) return;

    double result = 0;
    switch (_operand) {
      case "+":
        result = _num1! + _num2!;
        break;
      case "-":
        result = _num1! - _num2!;
        break;
      case "×":
        result = _num1! * _num2!;
        break;
      case "÷":
        result = _num2 == 0 ? 0 : _num1! / _num2!;
        break;
    }

    _output = result % 1 == 0
        ? result.toInt().toString()
        : result.toStringAsFixed(2).replaceAll('.', ',');
    _num1 = result;
    _num2 = null;
    _operand = null;
  }

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "AC") {
        _output = "0";
        _expression = "";
        _num1 = null;
        _num2 = null;
        _operand = null;
      } else if (buttonText == "C") {
        if (_output != "0") {
          _output = _output.length > 1
              ? _output.substring(0, _output.length - 1)
              : "0";
        }
      } else if (buttonText == "+" ||
          buttonText == "-" ||
          buttonText == "×" ||
          buttonText == "÷") {
        double currentVal =
            double.tryParse(_output.replaceAll('.', '').replaceAll(',', '.')) ??
                0;

        if (_num1 == null) {
          _num1 = currentVal;
          _operand = buttonText;
          _expression = "$_output $buttonText";
          _output = "0";
        } else if (_operand != null) {
          if (_output == "0") {
            _operand = buttonText;
            _expression =
                _expression.substring(0, _expression.length - 1) + buttonText;
          } else {
            _calculate();
            _operand = buttonText;
            _expression = "$_output $buttonText";
            _output = "0";
          }
        } else {
          _num1 = currentVal;
          _operand = buttonText;
          _expression = "$_output $buttonText";
          _output = "0";
        }
      } else if (buttonText == "%") {
        double val =
            double.tryParse(_output.replaceAll('.', '').replaceAll(',', '.')) ??
                0;
        _output = (val / 100).toString().replaceAll('.', ',');
      } else if (buttonText == "+/-") {
        if (_output.startsWith("-")) {
          _output = _output.substring(1);
        } else if (_output != "0") {
          _output = "-$_output";
        }
      } else if (buttonText == "=") {
        if (_num1 != null && _operand != null) {
          _expression = "";
          _calculate();

          _num1 = null;
          _operand = null;
        }
      } else {
        if (_output == "0") {
          _output = buttonText;
        } else {
          _output = _output + buttonText;
        }
      }
    });
  }

  String _formatDisplay(String val) {
    if (val == "0") return "0";
    if (val.contains(',')) return val;
    final clean = val.replaceAll('.', '');
    final parts = clean.split(',');
    final whole = parts[0];
    final formattedWhole = whole.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return parts.length > 1 ? '$formattedWhole,${parts[1]}' : formattedWhole;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 12, 24, 24 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: isDarkMode
            ? [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 40,
                    offset: const Offset(0, -10))
              ]
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 40,
                    offset: const Offset(0, -10))
              ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.03)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_expression,
                      style: GoogleFonts.quicksand(
                          fontSize: 11,
                          color: isDarkMode
                              ? Colors.white24
                              : Colors.teal.shade800.withValues(alpha: 0.4),
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      _formatDisplay(_output),
                      style: GoogleFonts.quicksand(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color:
                              isDarkMode ? Colors.white : Colors.teal.shade900,
                          letterSpacing: -1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _calcButton("AC", isAction: true, isDarkMode: isDarkMode),
                _calcButton("+/-", isAction: true, isDarkMode: isDarkMode),
                _calcButton("%", isAction: true, isDarkMode: isDarkMode),
                _calcButton("÷", isOperator: true, isDarkMode: isDarkMode),
                _calcButton("7", isDarkMode: isDarkMode),
                _calcButton("8", isDarkMode: isDarkMode),
                _calcButton("9", isDarkMode: isDarkMode),
                _calcButton("×", isOperator: true, isDarkMode: isDarkMode),
                _calcButton("4", isDarkMode: isDarkMode),
                _calcButton("5", isDarkMode: isDarkMode),
                _calcButton("6", isDarkMode: isDarkMode),
                _calcButton("-", isOperator: true, isDarkMode: isDarkMode),
                _calcButton("1", isDarkMode: isDarkMode),
                _calcButton("2", isDarkMode: isDarkMode),
                _calcButton("3", isDarkMode: isDarkMode),
                _calcButton("+", isOperator: true, isDarkMode: isDarkMode),
                _calcButton("C", isDarkMode: isDarkMode),
                _calcButton("0", isDarkMode: isDarkMode),
                _calcButton(",", isDarkMode: isDarkMode),
                _calcButton("=",
                    isOperator: true, isPrimary: true, isDarkMode: isDarkMode),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _calcButton(String text,
      {bool isOperator = false,
      bool isAction = false,
      bool isPrimary = false,
      required bool isDarkMode}) {
    Color bgColor =
        isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.teal.shade900;

    if (isOperator) {
      bgColor = isPrimary
          ? AppColors.primary
          : (isDarkMode
              ? Colors.teal.shade900.withValues(alpha: 0.3)
              : Colors.teal.shade50);
      textColor = isPrimary
          ? Colors.white
          : (isDarkMode ? Colors.teal.shade300 : AppColors.primary);
    } else if (isAction) {
      bgColor = isDarkMode
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.grey.shade50;
      textColor = isDarkMode ? Colors.teal.shade200 : Colors.teal.shade700;
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _buttonPressed(text == "," ? "." : text),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.teal.shade50.withValues(alpha: 0.5),
                width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
