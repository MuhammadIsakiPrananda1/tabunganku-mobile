/// Core: Theme — App Colors
///
/// Palet warna terpusat untuk seluruh aplikasi TabunganKu.
/// Semua warna bersifat `static const` — zero runtime overhead.
///
/// ## Penggunaan
/// ```dart
/// Container(color: AppColors.primary)
/// ```
/// Untuk warna yang bergantung pada tema (light/dark), gunakan
/// `Theme.of(context).colorScheme` sebagai gantinya.
library;

import 'package:flutter/material.dart';


class AppColors {
  // Primary
  static const Color primary = Color(0xFF00BFA5);
  static const Color primaryLight = Color(0xFF64FFDA);
  static const Color primaryDark = Color(0xFF009688);

  // Background & Surface (Light)
  static const Color background = Color(0xFFF1F8F7);
  static const Color surface = Color(0xFFFFFFFF);

  // Background & Surface (Dark)
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text (Light)
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFFBDBDBD);

  // Text (Dark)
  static const Color textPrimaryDark = Color(0xFFE1E1E1);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA500);
  static const Color info = Color(0xFF2196F3);

  // Border & Divider (Light)
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // Border & Divider (Dark)
  static const Color borderDark = Color(0xFF333333);
  static const Color dividerDark = Color(0xFF2C2C2C);

  // Disabled
  static const Color disabled = Color(0xFFE0E0E0);
  static const Color disabledText = Color(0xFFBDBDBD);
}
