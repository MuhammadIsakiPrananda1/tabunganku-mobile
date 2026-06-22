import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';

class FIRECalculatorPage extends ConsumerStatefulWidget {
  const FIRECalculatorPage({super.key});

  @override
  ConsumerState<FIRECalculatorPage> createState() => _FIRECalculatorPageState();
}

class _FIRECalculatorPageState extends ConsumerState<FIRECalculatorPage> {
  final TextEditingController _expensesController = TextEditingController();
  final TextEditingController _savingsController = TextEditingController();
  final TextEditingController _netWorthController = TextEditingController();
  final TextEditingController _returnController = TextEditingController();
  final TextEditingController _swrController = TextEditingController();

  double _targetFIRENumber = 0;
  double _yearsToFIRE = 0;
  bool _isReachable = true;
  final List<Map<String, dynamic>> _projections = [];

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final double monthlyExpenses = double.tryParse(_expensesController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final double monthlySavings = double.tryParse(_savingsController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final double currentNetWorth = double.tryParse(_netWorthController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final double annualReturn = double.tryParse(_returnController.text) ?? 0;
    final double swr = double.tryParse(_swrController.text) ?? 4;

    _projections.clear();

    if (monthlyExpenses <= 0) {
      setState(() {
        _targetFIRENumber = 0;
        _yearsToFIRE = 0;
        _isReachable = true;
      });
      return;
    }

final double targetFIRE = (monthlyExpenses * 12) / (swr / 100);
    _targetFIRENumber = targetFIRE;

    if (currentNetWorth >= targetFIRE) {
      setState(() {
        _yearsToFIRE = 0;
        _isReachable = true;
      });
      return;
    }

    final double r = (annualReturn / 100) / 12;
    final double pmt = monthlySavings;

if (r <= 0 && pmt <= 0) {
      setState(() {
        _yearsToFIRE = 0;
        _isReachable = false;
      });
      return;
    }

    double balance = currentNetWorth;
    int months = 0;

while (balance < targetFIRE && months < 600) {
      months++;
      balance = balance * (1 + r) + pmt;

if (months % 12 == 0) {
        final year = months ~/ 12;
        final passiveIncome = (balance * (swr / 100)) / 12;
        _projections.add({
          'year': year,
          'balance': balance,
          'passiveIncome': passiveIncome,
        });
      }
    }

    setState(() {
      _yearsToFIRE = months / 12;
      _isReachable = balance >= targetFIRE;
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
  void dispose() {
    _expensesController.dispose();
    _savingsController.dispose();
    _netWorthController.dispose();
    _returnController.dispose();
    _swrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9);

final accentColor = isDarkMode ? const Color(0xFF9B59B6) : const Color(0xFF8E44AD);

    final double currentNetWorth = double.tryParse(_netWorthController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    double progress = _targetFIRENumber > 0 ? (currentNetWorth / _targetFIRENumber) : 0;
    if (progress > 1.0) progress = 1.0;

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
          'Kalkulator Kebebasan Finansial',
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
                  Icon(Icons.info_outline_rounded, color: accentColor, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Hitung target kekayaan bersih (FIRE Number) agar bunga/investasi Anda bisa mencukupi semua pengeluaran tanpa perlu bekerja.',
                      style: GoogleFonts.quicksand(fontSize: 11, color: accentColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

_buildInput('Pengeluaran Bulanan Saat Ini', _expensesController, Icons.shopping_bag_rounded, isDarkMode, accentColor, isCurrency: true),
            const SizedBox(height: 18),
            _buildInput('Tabungan Bulanan Baru', _savingsController, Icons.add_circle_rounded, isDarkMode, accentColor, isCurrency: true),
            const SizedBox(height: 18),
            _buildInput('Kekayaan Bersih Saat Ini (Aset - Hutang)', _netWorthController, Icons.account_balance_wallet_rounded, isDarkMode, accentColor, isCurrency: true),
            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _buildInput('Return Investasi (%/Tahun)', _returnController, Icons.trending_up_rounded, isDarkMode, accentColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInput('Tingkat Penarikan/SWR (%)', _swrController, Icons.call_made_rounded, isDarkMode, accentColor),
                ),
              ],
            ),
            const SizedBox(height: 28),

if (_targetFIRENumber > 0) ...[
              _buildResultCard(isDarkMode, accentColor, currentNetWorth, progress),
              const SizedBox(height: 28),

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
                      color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: min(_projections.length, 5),
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                    ),
                    itemBuilder: (context, index) {
                      final item = _projections[index];
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Tahun ${item['year']}',
                                style: GoogleFonts.quicksand(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: contentColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Aset: ${_formatRupiah(item['balance'])}',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: contentColor,
                                      ),
                                    ),
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Gaji Pasif Bulanan: ${_formatRupiah(item['passiveIncome'])}',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 9.5,
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
    {bool isCurrency = false}
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
          inputFormatters: isCurrency ? [_RibuanFormatter()] : [],
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
          onChanged: (_) => _calculate(),
          decoration: InputDecoration(
            hintText: 'Masukkan Nominal',
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

  Widget _buildResultCard(bool isDarkMode, Color accentColor, double currentNetWorth, double progress) {
    final hexBg = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    String targetStr = _formatRupiah(_targetFIRENumber);
    String durationStr = '';
    
    if (currentNetWorth >= _targetFIRENumber) {
      durationStr = 'Selamat! Anda sudah mencapai FIRE!';
    } else if (!_isReachable) {
      durationStr = 'Tabungan bulanan saat ini tidak cukup untuk melampaui inflasi / target.';
    } else if (_yearsToFIRE >= 50) {
      durationStr = 'Lebih dari 50 Tahun';
    } else {
      final years = _yearsToFIRE.floor();
      final months = ((_yearsToFIRE - years) * 12).round();
      durationStr = years > 0 
          ? '$years Tahun $months Bulan' 
          : '$months Bulan';
    }

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
            'Target Kekayaan Bersih (FIRE Number)', 
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
              targetStr, 
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
            color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
          ),
          const SizedBox(height: 20),

Text(
            'Estimasi Waktu Pencapaian', 
            style: GoogleFonts.quicksand(
              color: contentColor.withOpacity(0.4), 
              fontSize: 11, 
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            durationStr, 
            style: GoogleFonts.quicksand(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: contentColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kekayaan Saat Ini',
                    style: GoogleFonts.quicksand(fontSize: 10, fontWeight: FontWeight.bold, color: contentColor.withOpacity(0.4)),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: GoogleFonts.quicksand(fontSize: 10, fontWeight: FontWeight.bold, color: accentColor),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: isDarkMode ? Colors.white10 : Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
            ],
          ),
        ],
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
