/// Page: InflationCalculatorPage
///
/// Simulasi dampak inflasi terhadap nilai uang masa depan.
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

class InflationCalculatorPage extends ConsumerStatefulWidget {
  const InflationCalculatorPage({super.key});

  @override
  ConsumerState<InflationCalculatorPage> createState() =>
      _InflationCalculatorPageState();
}

class _InflationCalculatorPageState
    extends ConsumerState<InflationCalculatorPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  int _startYear = 2016;
  int _targetYear = 2026;
  double _customInflationRate =
      4.3; // Rata-rata inflasi tahunan historis Indonesia (~4.3%)

  double _equivalentValue = 0;
  double _purchasingPower = 0;
  double _totalInflationPercent = 0;

  final List<int> _yearsRange =
      List.generate(61, (index) => 1990 + index); // 1990 to 2050

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final double amount = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final String cleanedRateText = _rateController.text.replaceAll(',', '.');
    
    if (amount <= 0 || cleanedRateText.isEmpty) {
      setState(() {
        _equivalentValue = 0;
        _purchasingPower = 0;
        _totalInflationPercent = 0;
      });
      return;
    }

    final int yearsDiff = _targetYear - _startYear;
    final double rate = double.tryParse(cleanedRateText) ?? 0.0;
    _customInflationRate = rate;
    final double rateDecimal = rate / 100;

    if (yearsDiff > 0) {
      // equivalent value in future
      _equivalentValue = amount * pow(1 + rateDecimal, yearsDiff);
      // purchasing power of the same nominal in future (stored under bed)
      _purchasingPower = amount / pow(1 + rateDecimal, yearsDiff);
      // total cumulative inflation
      _totalInflationPercent = (pow(1 + rateDecimal, yearsDiff) - 1) * 100;
    } else if (yearsDiff < 0) {
      // past equivalent value
      final int absDiff = yearsDiff.abs();
      _equivalentValue = amount / pow(1 + rateDecimal, absDiff);
      _purchasingPower = amount * pow(1 + rateDecimal, absDiff);
      _totalInflationPercent =
          -((1 - (1 / pow(1 + rateDecimal, absDiff))) * 100);
    } else {
      _equivalentValue = amount;
      _purchasingPower = amount;
      _totalInflationPercent = 0;
    }

    setState(() {});
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor =
        isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAFC);
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final accentColor =
        isDarkMode ? const Color(0xFFFF7043) : const Color(0xFFE64A19);

    final double amount = double.tryParse(
            _amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: contentColor, size: 20),
        ),
        title: Text(
          'Kalkulator Inflasi Rupiah',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: contentColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Header Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_down_rounded,
                      color: accentColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Inflasi adalah musuh tersembunyi yang menurunkan nilai riil uang Anda. Cari tahu seberapa besar daya beli uang Anda menyusut seiring berjalannya waktu.',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        color:
                            isDarkMode ? Colors.orange.shade200 : accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form Inputs
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                'Jumlah Uang Utama',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: contentColor.withValues(alpha: 0.4),
                ),
              ),
            ),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              textAlignVertical: TextAlignVertical.center,
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: contentColor,
              ),
              decoration: InputDecoration(
                hintText: 'Masukkan Nominal',
                hintStyle: GoogleFonts.quicksand(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.25),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.only(left: 12, right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.payments_rounded,
                          color: accentColor, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Rp',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
                filled: true,
                fillColor: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.only(
                    left: 0, right: 12, top: 12, bottom: 12),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (val) {
                if (val.isEmpty) {
                  _calculate();
                  return;
                }
                String digits = val.replaceAll(RegExp(r'[^0-9]'), '');
                if (digits.isEmpty) {
                  _amountController.value = const TextEditingValue(text: '');
                  _calculate();
                  return;
                }
                final parsed = double.tryParse(digits) ?? 0;
                final formatted = NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: '',
                  decimalDigits: 0,
                ).format(parsed).trim();
                _amountController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
                _calculate();
              },
            ),
            const SizedBox(height: 18),

            // Years Selection
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          'Tahun Awal',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: contentColor.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.05)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _startYear,
                            isExpanded: true,
                            dropdownColor: isDarkMode
                                ? AppColors.surfaceDark
                                : Colors.white,
                            style: GoogleFonts.quicksand(
                              color: contentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            items: _yearsRange.map((int year) {
                              return DropdownMenuItem<int>(
                                value: year,
                                child: Text(year.toString()),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _startYear = val);
                                _calculate();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          'Tahun Target',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: contentColor.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.05)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _targetYear,
                            isExpanded: true,
                            dropdownColor: isDarkMode
                                ? AppColors.surfaceDark
                                : Colors.white,
                            style: GoogleFonts.quicksand(
                              color: contentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            items: _yearsRange.map((int year) {
                              return DropdownMenuItem<int>(
                                value: year,
                                child: Text(year.toString()),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _targetYear = val);
                                _calculate();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Inflation Rate Form Field
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                'Rata-rata Inflasi Tahunan',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: contentColor.withValues(alpha: 0.4),
                ),
              ),
            ),
            TextFormField(
              controller: _rateController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlignVertical: TextAlignVertical.center,
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: contentColor,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              onChanged: (val) {
                _calculate();
              },
              decoration: InputDecoration(
                hintText: 'Masukkan Inflasi',
                hintStyle: GoogleFonts.quicksand(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.25),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.trending_down_rounded,
                      color: accentColor, size: 18),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
                suffixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '%',
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      fontSize: 13,
                    ),
                  ),
                ),
                suffixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
                filled: true,
                fillColor: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.only(
                    left: 0, right: 0, top: 12, bottom: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Calculation Results
            if (amount > 0 && _rateController.text.isNotEmpty) ...[
              Text(
                'HASIL PERHITUNGAN',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDarkMode ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 12),

              // Cumulative Inflation Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                    Text(
                      _startYear <= _targetYear
                          ? 'Total Akumulasi Inflasi'
                          : 'Deflasi / Penyesuaian Mundur',
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            isDarkMode ? Colors.orange.shade200 : accentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_totalInflationPercent >= 0 ? "+" : ""}${_totalInflationPercent.toStringAsFixed(1)}%',
                      style: GoogleFonts.quicksand(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: _totalInflationPercent >= 0
                            ? Colors.redAccent
                            : Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _startYear <= _targetYear
                          ? 'Selama periode ${(_targetYear - _startYear)} tahun, harga barang secara umum naik sebesar ${_totalInflationPercent.toStringAsFixed(1)}%.'
                          : 'Menghitung mundur sebesar ${(_startYear - _targetYear)} tahun ke belakang.',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Two Scenario Comparison
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Scenario 1: Equivalent future value needed to maintain power
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode ? AppColors.surfaceDark : Colors.white,
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
                            const Icon(Icons.savings_rounded,
                                color: Colors.green, size: 24),
                            const SizedBox(height: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nilai Setara di $_targetYear',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                FittedBox(
                                  child: Text(
                                    _formatRupiah(_equivalentValue),
                                    style: GoogleFonts.quicksand(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: contentColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: Text(
                                'Uang yang dibutuhkan di tahun $_targetYear agar memiliki daya beli yang sama dengan ${_formatRupiah(amount)} di tahun $_startYear.',
                                style: GoogleFonts.quicksand(
                                  fontSize: 10,
                                  color: isDarkMode
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Scenario 2: Stored under mattress (decay of value)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode ? AppColors.surfaceDark : Colors.white,
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
                            const Icon(Icons.trending_down_rounded,
                                color: Colors.redAccent, size: 24),
                            const SizedBox(height: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Daya Beli Riil di $_targetYear',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                FittedBox(
                                  child: Text(
                                    _formatRupiah(_purchasingPower),
                                    style: GoogleFonts.quicksand(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: contentColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: Text(
                                'Jika ${_formatRupiah(amount)} hanya didiamkan (misal di bawah kasur), daya belinya di tahun $_targetYear menyusut menjadi setara ${_formatRupiah(_purchasingPower)}.',
                                style: GoogleFonts.quicksand(
                                  fontSize: 10,
                                  color: isDarkMode
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Localized WOW factor: The Meatball (Bakso) Analogy
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.black.withValues(alpha: 0.03),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🍜', style: TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Analogi Mangkok Bakso',
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: contentColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Jika harga 1 porsi bakso di tahun $_startYear adalah Rp 15.000 (dapat ${(amount / 15000).toStringAsFixed(0)} porsi), maka di tahun $_targetYear dengan tingkat inflasi ini, Anda hanya bisa membeli sebanyak ${(_purchasingPower / 15000).toStringAsFixed(0)} porsi dengan jumlah uang nominal yang sama.',
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Actionable tips & suggestions
              Text(
                'TIPS CARA MELAWAN INFLASI',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDarkMode ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 12),

              _buildTipItem(
                Icons.monetization_on_rounded,
                'Investasi Emas/Logam Mulia',
                'Emas terkenal sebagai pelindung nilai (hedging) alami terhadap inflasi. Nilainya cenderung stabil naik mengikuti inflasi.',
                'Nabung Emas',
                () => context.push('/gold'),
                Colors.amber,
                isDarkMode,
              ),
              const SizedBox(height: 12),

              _buildTipItem(
                Icons.trending_up_rounded,
                'Portofolio Reksa Dana & Saham',
                'Untuk mengalahkan inflasi jangka panjang, taruh dana di aset produktif seperti reksa dana saham atau saham langsung yang memiliki potensi return > inflasi.',
                'Mulai Investasi',
                () => context.push('/investment'),
                Colors.indigo,
                isDarkMode,
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(
    IconData icon,
    String title,
    String desc,
    String actionBtnLabel,
    VoidCallback onTap,
    Color themeColor,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              Icon(icon, color: themeColor, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDarkMode ? Colors.white : AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: themeColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                actionBtnLabel,
                style: GoogleFonts.quicksand(
                  color: themeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



