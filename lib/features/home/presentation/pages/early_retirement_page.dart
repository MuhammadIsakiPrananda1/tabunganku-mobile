/// Page: EarlyRetirementPage
///
/// Kalkulator dan proyeksi pensiun dini.
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';

class EarlyRetirementPage extends ConsumerStatefulWidget {
  const EarlyRetirementPage({super.key});

  @override
  ConsumerState<EarlyRetirementPage> createState() =>
      _EarlyRetirementPageState();
}

class _EarlyRetirementPageState extends ConsumerState<EarlyRetirementPage> {
  final _expensesCtrl = TextEditingController();
  final _savingsCtrl = TextEditingController();
  final _assetsCtrl = TextEditingController();
  final _returnCtrl = TextEditingController();
  final _inflationCtrl = TextEditingController();
  final _withdrawalCtrl = TextEditingController();
  final _currentAgeCtrl = TextEditingController();

  double _fireNumber = 0;
  double _yearsToFire = 0;
  bool _hasResult = false;
  bool _isReachable = true;
  double _currentProgress = 0;
  final List<Map<String, dynamic>> _projections = [];

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _expensesCtrl.dispose();
    _savingsCtrl.dispose();
    _assetsCtrl.dispose();
    _returnCtrl.dispose();
    _inflationCtrl.dispose();
    _withdrawalCtrl.dispose();
    _currentAgeCtrl.dispose();
    super.dispose();
  }

  double _parseAmount(String text) =>
      double.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  void _calculate() {
    final monthlyExpenses = _parseAmount(_expensesCtrl.text);
    final monthlySavings = _parseAmount(_savingsCtrl.text);
    final currentAssets = _parseAmount(_assetsCtrl.text);
    final annualReturn = double.tryParse(_returnCtrl.text) ?? 8;
    final swr = double.tryParse(_withdrawalCtrl.text) ?? 4;

    _projections.clear();

    if (monthlyExpenses <= 0) {
      setState(() {
        _fireNumber = 0;
        _hasResult = false;
      });
      return;
    }

    final fireNumber = (monthlyExpenses * 12) / (swr / 100);
    final r = (annualReturn / 100) / 12;
    final progress = fireNumber > 0
        ? (currentAssets / fireNumber).clamp(0.0, 1.0)
        : 0.0;

    if (currentAssets >= fireNumber) {
      setState(() {
        _fireNumber = fireNumber;
        _yearsToFire = 0;
        _isReachable = true;
        _currentProgress = 1.0;
        _hasResult = true;
      });
      return;
    }

    if (r <= 0 && monthlySavings <= 0) {
      setState(() {
        _fireNumber = fireNumber;
        _isReachable = false;
        _currentProgress = progress.toDouble();
        _hasResult = true;
      });
      return;
    }

    double balance = currentAssets;
    int months = 0;

    while (balance < fireNumber && months < 600) {
      months++;
      balance = balance * (1 + r) + monthlySavings;
      if (months % 12 == 0) {
        final year = months ~/ 12;
        _projections.add({
          'year': year,
          'balance': balance,
          'passiveIncome': (balance * (swr / 100)) / 12,
        });
      }
    }

    setState(() {
      _fireNumber = fireNumber;
      _yearsToFire = months / 12;
      _isReachable = balance >= fireNumber;
      _currentProgress = progress.toDouble();
      _hasResult = true;
    });
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor =
        isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9);
    const accentColor = Color(0xFF6C63FF);

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: contentColor, size: 18),
        ),
        title: Text(
          'Simulasi Pensiun Dini',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: contentColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: accentColor, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Hitung kapan kamu bisa pensiun dini menggunakan strategi FIRE — hidup dari hasil investasi tanpa perlu bekerja lagi.',
                      style: GoogleFonts.quicksand(
                          fontSize: 11,
                          color: accentColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Inputs
            Row(
              children: [
                Expanded(
                  child: _buildInput(
                    label: 'Usia Saat Ini',
                    hint: 'Contoh: 25',
                    controller: _currentAgeCtrl,
                    icon: Icons.person_rounded,
                    isDarkMode: isDarkMode,
                    accentColor: accentColor,
                    suffix: 'th',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInput(
                    label: 'Return Investasi (%)',
                    hint: 'Contoh: 8',
                    controller: _returnCtrl,
                    icon: Icons.trending_up_rounded,
                    isDarkMode: isDarkMode,
                    accentColor: accentColor,
                    suffix: '%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            _buildInput(
              label: 'Pengeluaran Bulanan',
              hint: 'Masukkan Nominal',
              controller: _expensesCtrl,
              icon: Icons.shopping_bag_rounded,
              isDarkMode: isDarkMode,
              accentColor: accentColor,
              isCurrency: true,
            ),
            const SizedBox(height: 18),

            _buildInput(
              label: 'Tabungan / Investasi Bulanan',
              hint: 'Masukkan Nominal',
              controller: _savingsCtrl,
              icon: Icons.add_circle_rounded,
              isDarkMode: isDarkMode,
              accentColor: accentColor,
              isCurrency: true,
            ),
            const SizedBox(height: 18),

            _buildInput(
              label: 'Total Aset Saat Ini (Tabungan + Investasi)',
              hint: 'Masukkan Nominal',
              controller: _assetsCtrl,
              icon: Icons.account_balance_wallet_rounded,
              isDarkMode: isDarkMode,
              accentColor: accentColor,
              isCurrency: true,
            ),
            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _buildInput(
                    label: 'Safe Withdrawal Rate (%)',
                    hint: 'Contoh: 4',
                    controller: _withdrawalCtrl,
                    icon: Icons.call_made_rounded,
                    isDarkMode: isDarkMode,
                    accentColor: accentColor,
                    suffix: '%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInput(
                    label: 'Inflasi Tahunan (%)',
                    hint: 'Contoh: 4',
                    controller: _inflationCtrl,
                    icon: Icons.show_chart_rounded,
                    isDarkMode: isDarkMode,
                    accentColor: accentColor,
                    suffix: '%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Result Card
            if (_hasResult && _fireNumber > 0) ...[
              _buildResultCard(isDarkMode, accentColor, contentColor),
              const SizedBox(height: 20),

              // Proyeksi 5 tahun pertama
              if (_isReachable && _projections.isNotEmpty) ...[
                Text(
                  'Proyeksi 5 Tahun Pertama',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: contentColor,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.03),
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: min(_projections.length, 5),
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.03),
                    ),
                    itemBuilder: (context, index) {
                      final item = _projections[index];
                      final currentAge =
                          int.tryParse(_currentAgeCtrl.text) ?? 25;
                      final ageAtYear = currentAge + (item['year'] as int);
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tahun ${item['year']}',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: contentColor,
                                  ),
                                ),
                                Text(
                                  'Usia $ageAtYear tahun',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode
                                        ? Colors.white38
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatRupiah(
                                      item['balance'] as double),
                                  style: GoogleFonts.quicksand(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: contentColor,
                                  ),
                                ),
                                Text(
                                  'Pasif: ${_formatRupiah(item['passiveIncome'] as double)}/bln',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 20),
              // Tips box
              _buildTipsBox(isDarkMode, accentColor, contentColor),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isDarkMode,
    required Color accentColor,
    bool isCurrency = false,
    String? suffix,
    String hint = 'Masukkan Nominal',
  }) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return TextFormField(
      controller: controller,
      keyboardType: isCurrency
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      inputFormatters: isCurrency
          ? [_RibuanFormatter()]
          : [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      style: GoogleFonts.quicksand(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: contentColor),
      onChanged: (_) => _calculate(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.quicksand(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: contentColor.withValues(alpha: 0.4),
        ),
        floatingLabelStyle: GoogleFonts.quicksand(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: accentColor,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: hint,
        hintStyle: GoogleFonts.quicksand(
          fontSize: 13,
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.25),
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Container(
          padding: const EdgeInsets.only(left: 12, right: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: accentColor, size: 18),
              if (isCurrency) ...[
                const SizedBox(width: 4),
                Text(
                  'Rp',
                  style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      fontSize: 13),
                ),
              ],
            ],
          ),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixText: suffix,
        suffixStyle: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
            fontSize: 13),
        filled: true,
        fillColor: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.background,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor, width: 1.5)),
        contentPadding: const EdgeInsets.fromLTRB(0, 20, 16, 14),
      ),
    );
  }


  Widget _buildResultCard(
      bool isDarkMode, Color accentColor, Color contentColor) {
    final cardBg = isDarkMode ? AppColors.surfaceDark : Colors.white;

    String durationStr;
    String durationSub;
    final currentAge = int.tryParse(_currentAgeCtrl.text) ?? 25;

    if (_currentProgress >= 1.0) {
      durationStr = 'Sudah FIRE! 🎉';
      durationSub = 'Kamu sudah bisa pensiun sekarang';
    } else if (!_isReachable) {
      durationStr = 'Belum Tercapai';
      durationSub =
          'Tabungan bulanan tidak cukup melampaui target';
    } else if (_yearsToFire >= 50) {
      durationStr = '> 50 Tahun';
      durationSub = 'Perlu ditingkatkan tabungannya';
    } else {
      final years = _yearsToFire.floor();
      final months = ((_yearsToFire - years) * 12).round();
      final retirementAge = currentAge + years;
      durationStr =
          years > 0 ? '$years Tahun $months Bulan' : '$months Bulan';
      durationSub = 'Pensiun di usia $retirementAge tahun';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.03),
        ),
      ),
      child: Column(
        children: [
          // FIRE Number
          Text(
            'FIRE Number (Target Aset)',
            style: GoogleFonts.quicksand(
              color: contentColor.withValues(alpha: 0.4),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatRupiah(_fireNumber),
              style: GoogleFonts.quicksand(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ),

          const SizedBox(height: 20),
          Divider(
            height: 1,
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.03),
          ),
          const SizedBox(height: 20),

          // Time to FIRE
          Text(
            'Estimasi Waktu Pensiun',
            style: GoogleFonts.quicksand(
              color: contentColor.withValues(alpha: 0.4),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            durationStr,
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: contentColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            durationSub,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDarkMode
                  ? Colors.white38
                  : Colors.grey.shade500,
            ),
          ),

          const SizedBox(height: 24),

          // Progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress Aset Saat Ini',
                style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: contentColor.withValues(alpha: 0.4)),
              ),
              Text(
                '${(_currentProgress * 100).toStringAsFixed(1)}%',
                style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: _currentProgress,
              minHeight: 8,
              backgroundColor:
                  isDarkMode ? Colors.white10 : Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF6C63FF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsBox(
      bool isDarkMode, Color accentColor, Color contentColor) {
    final tips = [
      'Naikkan % tabungan setiap kali dapat kenaikan gaji',
      'Investasi konsisten di reksa dana indeks atau saham LQ45',
      'Kurangi pengeluaran lifestyle untuk mempercepat FIRE',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.03),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded,
                  color: Color(0xFF6C63FF), size: 16),
              const SizedBox(width: 8),
              Text(
                'Tips Percepat FIRE',
                style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: contentColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? Colors.white54
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ── Formatter ribuan ──────────────────────────────────────────────────────────
class _RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final formatted = digits.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

