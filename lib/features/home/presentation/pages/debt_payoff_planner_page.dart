import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';

class DebtPayoffPlannerPage extends ConsumerStatefulWidget {
  const DebtPayoffPlannerPage({super.key});

  @override
  ConsumerState<DebtPayoffPlannerPage> createState() => _DebtPayoffPlannerPageState();
}

class _DebtPayoffPlannerPageState extends ConsumerState<DebtPayoffPlannerPage> {
  final TextEditingController _debtController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _paymentController = TextEditingController();

  int _monthsToPay = 0;
  double _totalInterestPaid = 0;
  double _totalAmountPaid = 0;
  String? _errorMessage;
  final List<Map<String, dynamic>> _schedule = [];

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final double principal = double.tryParse(_debtController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final double annualRate = double.tryParse(_rateController.text) ?? 0;
    final double monthlyPmt = double.tryParse(_paymentController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    _schedule.clear();
    setState(() {
      _errorMessage = null;
    });

    if (principal <= 0) {
      setState(() {
        _monthsToPay = 0;
        _totalInterestPaid = 0;
        _totalAmountPaid = 0;
      });
      return;
    }

    final double r = (annualRate / 100) / 12;

    // Check if the payment can cover at least the monthly interest
    if (r > 0 && monthlyPmt <= principal * r) {
      setState(() {
        _errorMessage = 'Pembayaran bulanan terlalu kecil! Harus lebih besar dari bunga bulanan (${_formatRupiah(principal * r)}).';
        _monthsToPay = 0;
        _totalInterestPaid = 0;
        _totalAmountPaid = 0;
      });
      return;
    }

    double balance = principal;
    double interestSum = 0;
    int months = 0;

    while (balance > 0 && months < 360) {
      months++;
      final double interestForMonth = balance * r;
      double principalPaid = monthlyPmt - interestForMonth;
      
      double pmt = monthlyPmt;
      if (balance + interestForMonth < monthlyPmt) {
        pmt = balance + interestForMonth;
        principalPaid = balance;
        balance = 0;
      } else {
        balance = balance + interestForMonth - pmt;
      }

      interestSum += interestForMonth;
      _schedule.add({
        'month': months,
        'payment': pmt,
        'interest': interestForMonth,
        'principal': principalPaid,
        'balance': balance,
      });
    }

    setState(() {
      _monthsToPay = months;
      _totalInterestPaid = interestSum;
      _totalAmountPaid = principal + interestSum;
      if (months >= 360 && balance > 0) {
        _errorMessage = 'Pelunasan membutuhkan waktu lebih dari 30 tahun. Harap naikkan pembayaran bulanan.';
      }
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
    _debtController.dispose();
    _rateController.dispose();
    _paymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9);
    
    // Accent Color: Coral Red (representing debt / payment attention)
    final accentColor = isDarkMode ? const Color(0xFFE74C3C) : const Color(0xFFC0392B);

    final double principal = double.tryParse(_debtController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

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
          'Kalkulator Pelunas Hutang',
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
            // Info Header Card
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
                      'Rencanakan percepatan pelunasan hutang untuk menghemat bunga dan membebaskan dana bulanan Anda.',
                      style: GoogleFonts.quicksand(fontSize: 11, color: accentColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Total Hutang Input
            _buildInput(
              'Jumlah Hutang / Pinjaman', 
              _debtController, 
              Icons.money_off_rounded, 
              isDarkMode, 
              accentColor, 
              isCurrency: true
            ),
            const SizedBox(height: 20),

            // Suku Bunga & Cicilan Bulanan Inputs
            Row(
              children: [
                Expanded(
                  child: _buildInput(
                    'Suku Bunga (%/Tahun)', 
                    _rateController, 
                    Icons.percent_rounded, 
                    isDarkMode, 
                    accentColor
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInput(
                    'Bayar Bulanan', 
                    _paymentController, 
                    Icons.payment_rounded, 
                    isDarkMode, 
                    accentColor, 
                    isCurrency: true
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Error Message
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.quicksand(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 28),
            ],

            // Results Card
            if (_monthsToPay > 0 && _errorMessage == null) ...[
              _buildResultCard(isDarkMode, accentColor, principal),
              const SizedBox(height: 28),

              // Payment Schedule
              Text(
                'Jadwal Pembayaran Bulanan',
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
                  itemCount: min(_schedule.length, 12), // Display first 12 months for brevity
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                  ),
                  itemBuilder: (context, index) {
                    final item = _schedule[index];
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bulan ${item['month']}',
                            style: GoogleFonts.quicksand(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: contentColor,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Pokok: ${_formatRupiah(item['principal'])}',
                                style: GoogleFonts.quicksand(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: contentColor.withOpacity(0.6),
                                ),
                              ),
                              Text(
                                'Bunga: ${_formatRupiah(item['interest'])}',
                                style: GoogleFonts.quicksand(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor.withOpacity(0.8),
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
              if (_schedule.length > 12) ...[
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    '... dan ${_schedule.length - 12} bulan berikutnya.',
                    style: GoogleFonts.quicksand(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: contentColor.withOpacity(0.4),
                    ),
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
          keyboardType: TextInputType.number,
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

  Widget _buildResultCard(bool isDarkMode, Color accentColor, double principal) {
    final hexBg = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    final years = _monthsToPay ~/ 12;
    final remainingMonths = _monthsToPay % 12;
    final durationStr = years > 0 
        ? '$years Tahun $remainingMonths Bulan' 
        : '$remainingMonths Bulan';

    // Calculate percentages for Pokok vs Bunga
    final double total = _totalAmountPaid;
    final double principalPct = total > 0 ? (principal / total) * 100 : 100;
    final double interestPct = total > 0 ? (_totalInterestPaid / total) * 100 : 0;

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
            'Lama Waktu Pelunasan', 
            style: GoogleFonts.quicksand(
              color: contentColor.withOpacity(0.4), 
              fontSize: 11, 
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            durationStr, 
            style: GoogleFonts.quicksand(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: contentColor,
            ),
          ),
          const SizedBox(height: 24),

          // Stacked Pokok vs Bunga Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pokok (${principalPct.toStringAsFixed(0)}%)',
                    style: GoogleFonts.quicksand(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  Text(
                    'Bunga (${interestPct.toStringAsFixed(0)}%)',
                    style: GoogleFonts.quicksand(fontSize: 10, fontWeight: FontWeight.bold, color: accentColor),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: SizedBox(
                  height: 10,
                  child: Row(
                    children: [
                      Expanded(
                        flex: principalPct.round(),
                        child: Container(color: Colors.blue),
                      ),
                      if (interestPct > 0)
                        Expanded(
                          flex: interestPct.round(),
                          child: Container(color: accentColor),
                        ),
                    ],
                  ),
                ),
              ),
            ],
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
              Column(
                children: [
                  Text(
                    'Total Pengembalian', 
                    style: GoogleFonts.quicksand(
                      color: contentColor.withOpacity(0.4), 
                      fontSize: 10, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatRupiah(_totalAmountPaid), 
                    style: GoogleFonts.quicksand(
                      color: contentColor, 
                      fontSize: 12, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Total Beban Bunga', 
                    style: GoogleFonts.quicksand(
                      color: contentColor.withOpacity(0.4), 
                      fontSize: 10, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatRupiah(_totalInterestPaid), 
                    style: GoogleFonts.quicksand(
                      color: accentColor, 
                      fontSize: 12, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
