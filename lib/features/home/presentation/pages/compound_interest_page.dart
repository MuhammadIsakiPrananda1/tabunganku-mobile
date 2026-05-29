import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _calculate() {
    final double p = double.tryParse(_initialAmountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final double pmt = double.tryParse(_monthlyContributionController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final double r = (double.tryParse(_interestRateController.text) ?? 0) / 100 / 12;
    final int t = (int.tryParse(_yearsController.text) ?? 0) * 12;

    if (t <= 0) {
      setState(() {
        _finalBalance = p;
        _totalContributions = p;
        _totalInterest = 0;
      });
      return;
    }

    double balance = p;
    double totalContributed = p;
    for (int i = 1; i <= t; i++) {
      balance = balance * (1 + r) + pmt;
      totalContributed += pmt;
    }

    setState(() {
      _finalBalance = balance;
      _totalContributions = totalContributed;
      _totalInterest = max(0, balance - totalContributed);
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
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    
    // Page Theme: Mint Green Accent & Pure Dark/Light backgrounds
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9);
    final accentColor = isDarkMode ? const Color(0xFF2ECC71) : const Color(0xFF27AE60);

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
          'Bunga Majemuk',
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
            _buildInfoCard(accentColor),
            const SizedBox(height: 28),

            _buildAlignedInput(
              'Modal Awal', 
              _initialAmountController, 
              (_) => _calculate(), 
              Icons.account_balance_rounded, 
              isDarkMode,
              accentColor,
              'Modal Awal',
              isCurrency: true
            ),
            const SizedBox(height: 20),
            
            _buildAlignedInput(
              'Tabungan Bulanan', 
              _monthlyContributionController, 
              (_) => _calculate(), 
              Icons.add_circle_outline_rounded, 
              isDarkMode,
              accentColor,
              'Tabungan Bulanan',
              isCurrency: true
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _buildAlignedInput(
                    'Bunga (%)', 
                    _interestRateController, 
                    (_) => _calculate(), 
                    Icons.percent_rounded, 
                    isDarkMode,
                    accentColor,
                    'Bunga (%)',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAlignedInput(
                    'Durasi (Tahun)', 
                    _yearsController, 
                    (_) => _calculate(), 
                    Icons.calendar_today_rounded, 
                    isDarkMode,
                    accentColor,
                    'Durasi (Tahun)',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            _buildResultCard(isDarkMode, accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: accentColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Simulasi ini membantu Anda memproyeksikan pertumbuhan investasi Anda seiring waktu.',
              style: GoogleFonts.quicksand(fontSize: 11, color: accentColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlignedInput(
    String label, 
    TextEditingController controller, 
    Function(String) onChanged, 
    IconData icon, 
    bool isDarkMode,
    Color accentColor,
    String hintText,
    {bool isCurrency = false}
  ) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label, 
            style: GoogleFonts.quicksand(
              fontSize: 11, 
              fontWeight: FontWeight.bold, 
              color: contentColor.withOpacity(0.4),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: isCurrency ? [_RibuanFormatter()] : [],
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.quicksand(
              fontSize: 13,
              color: isDarkMode ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.25),
              fontWeight: FontWeight.bold,
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: accentColor, size: 18),
                  if (isCurrency) ...[
                    const SizedBox(width: 8),
                    Text(
                      'Rp', 
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: accentColor, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(bool isDarkMode, Color accentColor) {
    final hexBg = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: hexBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Estimasi Saldo Akhir', 
            style: GoogleFonts.quicksand(
              color: contentColor.withOpacity(0.4), 
              fontSize: 11, 
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatRupiah(_finalBalance), 
              style: GoogleFonts.quicksand(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: _finalBalance > 0 ? accentColor : contentColor.withOpacity(0.1),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Divider(
            height: 1,
            color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniBreakdown('Total Setoran', _formatRupiah(_totalContributions), isDarkMode),
              _buildMiniBreakdown('Akumulasi Bunga', _formatRupiah(_totalInterest), isDarkMode, isHighlight: true, accentColor: accentColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBreakdown(String label, String value, bool isDarkMode, {bool isHighlight = false, Color? accentColor}) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Column(
      children: [
        Text(
          label, 
          style: GoogleFonts.quicksand(
            color: contentColor.withOpacity(0.4), 
            fontSize: 10, 
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value, 
          style: GoogleFonts.quicksand(
            color: isHighlight && _finalBalance > 0 ? accentColor : contentColor, 
            fontSize: 13, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
