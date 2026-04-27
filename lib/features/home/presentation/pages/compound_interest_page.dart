import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';

class CompoundInterestPage extends ConsumerStatefulWidget {
  const CompoundInterestPage({super.key});

  @override
  ConsumerState<CompoundInterestPage> createState() => _CompoundInterestPageState();
}

class _CompoundInterestPageState extends ConsumerState<CompoundInterestPage> {
  final TextEditingController _initialAmountController = TextEditingController();
  final TextEditingController _monthlyContributionController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();

  double _finalBalance = 0;
  double _totalContributions = 0;
  double _totalInterest = 0;

  @override
  void initState() {
    super.initState();
  }

  void _calculate() {
    final double p = double.tryParse(_initialAmountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final double pmt = double.tryParse(_monthlyContributionController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final double r = (double.tryParse(_interestRateController.text) ?? 0) / 100 / 12;
    final int t = (int.tryParse(_yearsController.text) ?? 0) * 12;

    if (t <= 0) return;

    double balance = p;
    double totalContributed = p;
    for (int i = 1; i <= t; i++) {
      balance = balance * (1 + r) + pmt;
      totalContributed += pmt;
    }

    setState(() {
      _finalBalance = balance;
      _totalContributions = totalContributed;
      _totalInterest = balance - totalContributed;
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
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary, size: 18),
        ),
        title: Text(
          'Simulasi Bunga Majemuk',
          style: GoogleFonts.comicNeue(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Result Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'ESTIMASI SALDO AKHIR',
                    style: GoogleFonts.comicNeue(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _formatRupiah(_finalBalance),
                      style: GoogleFonts.comicNeue(
                        color: AppColors.primary,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(height: 1, thickness: 1, color: AppColors.primary.withValues(alpha: 0.1)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _resultMiniItem(
                          'TOTAL MODAL',
                          _formatRupiah(_totalContributions),
                        ),
                      ),
                      Expanded(
                        child: _resultMiniItem(
                          'TOTAL BUNGA',
                          _formatRupiah(_totalInterest),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Inputs
            _buildInputCard(),
          ],
        ),
      ),
    );
  }

  Widget _resultMiniItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.comicNeue(
            color: AppColors.primary.withValues(alpha: 0.4),
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.comicNeue(
            color: AppColors.primaryLight,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _initialAmountController,
            label: 'Modal Awal',
            hint: '0',
            icon: Icons.account_balance_rounded,
            isCurrency: true,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _monthlyContributionController,
            label: 'Tabungan Bulanan',
            hint: '0',
            icon: Icons.add_circle_outline_rounded,
            isCurrency: true,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _interestRateController,
            label: 'Bunga (%)',
            hint: '0',
            icon: Icons.percent_rounded,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _yearsController,
            label: 'Durasi (Tahun)',
            hint: '0',
            icon: Icons.calendar_today_rounded,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                'Hitung Sekarang',
                style: GoogleFonts.comicNeue(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isCurrency = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.comicNeue(
        fontWeight: FontWeight.bold,
        color: AppColors.primaryLight,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.comicNeue(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
        floatingLabelStyle: GoogleFonts.comicNeue(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              if (isCurrency) ...[
                const SizedBox(width: 8),
                Text(
                  'Rp',
                  style: GoogleFonts.comicNeue(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
        hintText: hint,
        hintStyle: GoogleFonts.comicNeue(
          fontSize: 14,
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
        filled: true,
        fillColor: const Color(0xFF121212),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      onChanged: (value) {
        if (isCurrency && value.isNotEmpty) {
          final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
          if (clean.isNotEmpty) {
            final formatted = NumberFormat.currency(
              locale: 'id_ID',
              symbol: '',
              decimalDigits: 0,
            ).format(double.parse(clean)).trim();
            
            controller.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          }
        }
      },
    );
  }
}
