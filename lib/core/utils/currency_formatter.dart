/// Core: Utils — Currency Formatter
///
/// [RibuanFormatter] adalah [TextInputFormatter] yang memformat angka
/// dengan pemisah ribuan menggunakan titik (format Indonesia).
///
/// Contoh: `1000000` → `1.000.000`
library;

import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RibuanFormatter
// ─────────────────────────────────────────────────────────────────────────────

/// Formatter untuk TextField yang secara otomatis menambahkan
/// pemisah ribuan (titik) saat user mengetik angka.
///
/// Posisi kursor dipertahankan dengan benar saat digit ditambahkan atau
/// dihapus di tengah angka.
class RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');

    final formatted = formatNumber(digitsOnly);

    // Hitung berapa digit yang sudah diketik sebelum posisi kursor
    final numDigitsBefore = newValue.selection.end -
        newValue.text
            .substring(0, newValue.selection.end)
            .replaceAll(RegExp(r'[0-9]'), '')
            .length;

    // Temukan posisi kursor di string yang sudah diformat
    var newSelectionIndex = 0;
    var digitsCount = 0;
    while (digitsCount < numDigitsBefore &&
        newSelectionIndex < formatted.length) {
      if (RegExp(r'[0-9]').hasMatch(formatted[newSelectionIndex])) {
        digitsCount++;
      }
      newSelectionIndex++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }

  // ── Static utilities ───────────────────────────────────────────────────────

  /// Format angka (String atau num) ke format ribuan dengan pemisah titik.
  ///
  /// Mengembalikan `'0'` jika value null atau kosong.
  static String formatNumber(dynamic value) {
    if (value == null) return '0';
    final digitsOnly = value.toString().replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return '0';
    return digitsOnly.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }
}
