import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/core/widgets/high_vis_input.dart';

class RuleOf72Page extends ConsumerStatefulWidget {
  const RuleOf72Page({super.key});

  @override
  ConsumerState<RuleOf72Page> createState() => _RuleOf72PageState();
}

class _RuleOf72PageState extends ConsumerState<RuleOf72Page> {
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  void dispose() {
    _rateController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9);
    final surfaceColor = isDarkMode ? AppColors.surfaceDark : Colors.white;

    final double rate = double.tryParse(_rateController.text.replaceAll(',', '.')) ?? 0;
    final double amount = double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;

    double yearsToDouble = 0;
    double doubledAmount = 0;

    if (rate > 0) {
      yearsToDouble = 72 / rate;
      doubledAmount = amount * 2;
    }

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: contentColor, size: 20),
        ),
        title: Text(
          'Kalkulator Aturan 72',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: contentColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Colors.indigo, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Aturan 72 adalah rumus cepat untuk memperkirakan berapa tahun yang dibutuhkan agar investasi Anda berlipat ganda dengan suku bunga tahunan tertentu.',
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        color: isDarkMode ? Colors.indigo.shade300 : Colors.indigo.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Inputs
            HighVisInput(
              controller: _amountController,
              icon: Icons.payments_rounded,
              label: 'Investasi Awal (Opsional)',
              prefixText: 'Rp',
              isDarkMode: isDarkMode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _RibuanFormatter(),
              ],
              hintText: 'Masukkan Nominal',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 18),

            HighVisInput(
              controller: _rateController,
              icon: Icons.percent_rounded,
              label: 'Asumsi Imbal Hasil / Bunga Tahunan (%)',
              isDarkMode: isDarkMode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              hintText: 'Masukkan Persentase',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 28),

            // Results Card
            if (rate > 0) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Estimasi Waktu Pelipatgandaan',
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: contentColor.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${yearsToDouble.toStringAsFixed(1)} Tahun',
                      style: GoogleFonts.quicksand(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Divider(
                      height: 1,
                      color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Aset Awal:',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: contentColor.withValues(alpha: 0.5),
                          ),
                        ),
                        Text(
                          _formatRupiah(amount),
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: contentColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Menjadi (2x lipat):',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: contentColor.withValues(alpha: 0.5),
                          ),
                        ),
                        Text(
                          _formatRupiah(doubledAmount),
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Visual representation of doubling
              Text(
                'Visualisasi Pertumbuhan Aset:',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: contentColor.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.indigo,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tahun ke-0: ${_formatRupiah(amount)} (100%)',
                            style: GoogleFonts.quicksand(fontSize: 11, fontWeight: FontWeight.bold, color: contentColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 16,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 100, // represent 100%
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.indigo.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tahun ke-${yearsToDouble.toStringAsFixed(1)}: ${_formatRupiah(doubledAmount)} (200%)',
                            style: GoogleFonts.quicksand(fontSize: 11, fontWeight: FontWeight.bold, color: contentColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 16,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 200, // represent 200%
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Text(
                    'Silakan masukkan persentase imbal hasil tahunan.',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final formatted = digits.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}


