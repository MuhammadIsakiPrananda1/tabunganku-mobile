import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';

class KPRCalculatorPage extends ConsumerStatefulWidget {
  const KPRCalculatorPage({super.key});

  @override
  ConsumerState<KPRCalculatorPage> createState() => _KPRCalculatorPageState();
}

class _KPRCalculatorPageState extends ConsumerState<KPRCalculatorPage> {
  final TextEditingController _propertyPriceCtrl = TextEditingController();
  final TextEditingController _dpCtrl = TextEditingController();
  final TextEditingController _interestCtrl = TextEditingController();
  final TextEditingController _tenorCtrl = TextEditingController();

  double _loanAmount = 0;
  double _monthlyInstallment = 0;
  double _totalInterest = 0;
  double _totalPayment = 0;
  double _recommendedSalary = 0;
  final List<Map<String, dynamic>> _projections = [];

  @override
  void initState() {
    super.initState();

    _calculate();
  }

  void _calculate() {
    final double price = double.tryParse(_propertyPriceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final double dp = double.tryParse(_dpCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final double annualInterest = double.tryParse(_interestCtrl.text) ?? 0;
    final int tenorYears = int.tryParse(_tenorCtrl.text) ?? 0;

    _projections.clear();

    if (price <= 0 || tenorYears <= 0) {
      setState(() {
        _loanAmount = 0;
        _monthlyInstallment = 0;
        _totalInterest = 0;
        _totalPayment = 0;
        _recommendedSalary = 0;
      });
      return;
    }

    final double loan = max(0.0, price - dp);
    _loanAmount = loan;

    final double monthlyInterest = (annualInterest / 100) / 12;
    final int totalMonths = tenorYears * 12;

    double monthlyPayment = 0;
    if (loan > 0) {
      if (monthlyInterest > 0) {
        monthlyPayment = loan * (monthlyInterest * pow(1 + monthlyInterest, totalMonths)) / (pow(1 + monthlyInterest, totalMonths) - 1);
      } else {
        monthlyPayment = loan / totalMonths;
      }
    }

    _monthlyInstallment = monthlyPayment;
    _totalPayment = monthlyPayment * totalMonths;
    _totalInterest = max(0.0, _totalPayment - loan);
    _recommendedSalary = monthlyPayment / 0.3;

for (int year = 1; year <= min(tenorYears, 5); year++) {
      int monthsElapsed = year * 12;
      double remainingBalance = loan;
      if (loan > 0) {
        if (monthlyInterest > 0) {
          remainingBalance = loan * pow(1 + monthlyInterest, monthsElapsed) - monthlyPayment * ((pow(1 + monthlyInterest, monthsElapsed) - 1) / monthlyInterest);
        } else {
          remainingBalance = loan - (monthlyPayment * monthsElapsed);
        }
      }
      if (remainingBalance < 0) remainingBalance = 0;

      _projections.add({
        'year': year,
        'remainingBalance': remainingBalance,
      });
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
    _propertyPriceCtrl.dispose();
    _dpCtrl.dispose();
    _interestCtrl.dispose();
    _tenorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9);

const accentColor = Colors.deepOrange;

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
          'Simulasi KPR & Cicilan',
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

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: accentColor, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Hitung estimasi angsuran bulanan KPR/kredit Anda berdasarkan harga properti, DP, bunga efektif annuity, serta jangka waktu tenor.',
                      style: GoogleFonts.quicksand(fontSize: 11, color: accentColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

_buildInput('Harga Properti', _propertyPriceCtrl, Icons.home_rounded, isDarkMode, accentColor, isCurrency: true, hintText: 'Masukkan Harga Properti'),
            const SizedBox(height: 18),
            _buildInput('Uang Muka / DP', _dpCtrl, Icons.payments_rounded, isDarkMode, accentColor, isCurrency: true, hintText: 'Masukkan Uang Muka'),
            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _buildInput('Suku Bunga (%/Tahun)', _interestCtrl, Icons.percent_rounded, isDarkMode, accentColor, hintText: 'Masukkan Bunga'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInput('Tenor (Tahun)', _tenorCtrl, Icons.calendar_today_rounded, isDarkMode, accentColor, hintText: 'Masukkan Tenor'),
                ),
              ],
            ),
            const SizedBox(height: 28),

if (_loanAmount > 0) ...[
              _buildResultCard(isDarkMode, accentColor),
              const SizedBox(height: 28),

if (_projections.isNotEmpty) ...[
                Text(
                  'Proyeksi Sisa Pinjaman (5 Tahun Pertama)',
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
                      color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _projections.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                    ),
                    itemBuilder: (context, index) {
                      final item = _projections[index];
                      final remaining = item['remainingBalance'] as double;
                      final progress = _loanAmount > 0 ? (remaining / _loanAmount).clamp(0.0, 1.0) : 0.0;

                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  _formatRupiah(remaining),
                                  style: GoogleFonts.quicksand(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: contentColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: isDarkMode ? Colors.white10 : Colors.grey.shade100,
                                valueColor: const AlwaysStoppedAnimation<Color>(accentColor),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInput(
    String label, 
    TextEditingController controller, 
    IconData icon, 
    bool isDarkMode,
    Color accentColor,
    {bool isCurrency = false, String? hintText}
  ) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
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
          keyboardType: isCurrency ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          inputFormatters: isCurrency 
              ? [_RibuanFormatter()] 
              : [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
          onChanged: (_) => _calculate(),
          decoration: InputDecoration(
            hintText: hintText ?? 'Masukkan Nominal',
            hintStyle: GoogleFonts.quicksand(
              fontSize: 13,
              color: isDarkMode ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.25),
              fontWeight: FontWeight.bold,
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 12, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: accentColor, size: 18),
                  if (isCurrency) ...[
                    const SizedBox(width: 4),
                    Text(
                      'Rp', 
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: accentColor, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.only(left: 0, right: 16, top: 12, bottom: 12),
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
            'Estimasi Angsuran Bulanan', 
            style: GoogleFonts.quicksand(
              color: contentColor.withOpacity(0.4), 
              fontSize: 11, 
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatRupiah(_monthlyInstallment), 
              style: GoogleFonts.quicksand(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: accentColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          Divider(
            height: 1,
            color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
          ),
          const SizedBox(height: 20),

_buildDetailRow('Pokok Pinjaman (Plafon KPR)', _formatRupiah(_loanAmount), contentColor),
          const SizedBox(height: 12),
          _buildDetailRow('Total Bunga Selama Tenor', _formatRupiah(_totalInterest), contentColor),
          const SizedBox(height: 12),
          _buildDetailRow('Total Pengembalian', _formatRupiah(_totalPayment), contentColor),
          
          const SizedBox(height: 20),
          Divider(
            height: 1,
            color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
          ),
          const SizedBox(height: 20),

Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.wallet_rounded, color: Colors.green, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rekomendasi Gaji Bulanan Minimum',
                        style: GoogleFonts.quicksand(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white54 : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _formatRupiah(_recommendedSalary),
                          style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color contentColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: contentColor.withOpacity(0.5),
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: contentColor,
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
