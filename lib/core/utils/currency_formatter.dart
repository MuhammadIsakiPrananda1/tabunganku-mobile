import 'package:flutter/services.dart';

/// Formatter untuk menambahkan titik (.) sebagai pemisah ribuan secara dinamis
/// saat pengguna mengetik nominal uang.
class RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    // Bersihkan teks dari karakter non-digit
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');

    final formatted = formatNumber(digitsOnly);

    // Hitung posisi kursor agar tetap di belakang angka yang baru diketik
    int numDigitsBefore = newValue.selection.end -
        newValue.text
            .substring(0, newValue.selection.end)
            .replaceAll(RegExp(r'[0-9]'), '')
            .length;

    int newSelectionIndex = 0;
    int digitsCount = 0;
    while (
        digitsCount < numDigitsBefore && newSelectionIndex < formatted.length) {
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

  /// Memformat angka (String atau int) menjadi pemisah ribuan
  static String formatNumber(dynamic value) {
    if (value == null) return '0';
    String digitsOnly = value.toString().replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return '0';
    return digitsOnly.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }
}
