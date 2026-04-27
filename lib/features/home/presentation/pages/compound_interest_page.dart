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
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF0F9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDarkMode ? Colors.white : AppColors.primaryDark, size: 18),
        ),
        title: Text(
          'Simulasi Bunga Majemuk',
          style: GoogleFonts.comicNeue(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDarkMode ? Colors.white : AppColors.primaryDark,
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [const Color(0xFF0EA5E9), const Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: isDarkMode ? 0.4 : 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Estimasi Saldo Akhir',
                    style: GoogleFonts.comicNeue(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _formatRupiah(_finalBalance),
                      style: GoogleFonts.comicNeue(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _resultMiniItem(
                          'Total Modal',
                          _formatRupiah(_totalContributions),
                          Icons.account_balance_wallet_rounded,
                          isDarkMode,
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.white24),
                      Expanded(
                        child: _resultMiniItem(
                          'Total Bunga',
                          _formatRupiah(_totalInterest),
                          Icons.trending_up_rounded,
                          isDarkMode,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Inputs
            _buildInputCard(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _resultMiniItem(String label, String value, IconData icon, bool isDarkMode) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.comicNeue(color: Colors.white60, fontSize: 10),
        ),
        Text(
          value,
          style: GoogleFonts.comicNeue(
            color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade600,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
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
            height: 56,
            child: ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.comicNeue(
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : AppColors.primaryDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.comicNeue(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
        ),
        floatingLabelStyle: GoogleFonts.comicNeue(
          color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade600,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: Colors.blue.shade600),
              if (isCurrency) ...[
                const SizedBox(width: 8),
                Text(
                  'Rp',
                  style: GoogleFonts.comicNeue(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade700,
                  ),
                ),
              ],
            ],
          ),
        ),
        hintText: hint,
        hintStyle: GoogleFonts.comicNeue(
          fontSize: 14,
          color: isDarkMode ? Colors.white10 : Colors.grey.shade300,
        ),
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF0F9FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
