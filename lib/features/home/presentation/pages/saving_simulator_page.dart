/// Page: SavingSimulatorPage
///
/// Simulasi target dan proyeksi hasil tabungan.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/models/transaction_model.dart';

class SavingSimulatorPage extends ConsumerStatefulWidget {
  const SavingSimulatorPage({super.key});

  @override
  ConsumerState<SavingSimulatorPage> createState() => _SavingSimulatorPageState();
}

class _SavingSimulatorPageState extends ConsumerState<SavingSimulatorPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _initialAmountController = TextEditingController();
  
  bool _useCurrentBalance = true;
  DateTime? _targetDate;
  double _targetAmount = 0;
  double _customInitialAmount = 0;

  @override
  void dispose() {
    _amountController.dispose();
    _initialAmountController.dispose();
    super.dispose();
  }

  void _calculate() {
    final targetText = _amountController.text.replaceAll('.', '');
    final target = double.tryParse(targetText) ?? 0;
    
    final initialText = _initialAmountController.text.replaceAll('.', '');
    final initial = double.tryParse(initialText) ?? 0;

    setState(() {
      _targetAmount = target;
      _customInitialAmount = initial;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: isDark ? AppColors.surfaceDark : Colors.white,
                onSurface: isDark ? Colors.white : Colors.black87,
                brightness: isDark ? Brightness.dark : Brightness.light,
              ),
              dialogBackgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            child: child!,
          ),
        );
      },
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
      _calculate();
    }
  }

  String _formatDuration(int days) {
    if (days <= 0) return 'Hari ini';

    final months = days ~/ 30;
    final remainingDaysAfterMonths = days % 30;
    final weeks = days ~/ 7;
    final remainingDaysAfterWeeks = days % 7;

    List<String> parts = [];
    if (months > 0) {
      parts.add('$months Bulan');
      if (remainingDaysAfterMonths > 0) {
        parts.add('$remainingDaysAfterMonths Hari');
      }
    } else if (weeks > 0) {
      parts.add('$weeks Minggu');
      if (remainingDaysAfterWeeks > 0) {
        parts.add('$remainingDaysAfterWeeks Hari');
      }
    } else {
      parts.add('$days Hari');
    }

    return parts.join(' ');
  }

  Widget _buildTipCard(double dailySaving, bool isDarkMode) {
    String tipText = "";
    IconData tipIcon = Icons.lightbulb_rounded;
    Color tipColor = Colors.amber;

    if (dailySaving <= 0) {
      tipText = "Selamat! Saldo Anda sudah mencukupi target dana impian ini. 🎉";
      tipIcon = Icons.emoji_events_rounded;
      tipColor = Colors.green;
    } else if (dailySaving <= 10000) {
      tipText = "Target yang sangat realistis! Cukup kurangi jajan kecil harian, target impianmu akan tercapai tepat waktu. Semangat! ✨";
      tipIcon = Icons.star_rounded;
      tipColor = Colors.teal;
    } else if (dailySaving <= 50000) {
      tipText = "Target yang bagus! Nominal ini setara dengan menyisihkan uang kopi atau makan siang harian. Yuk, lebih hemat lagi! ☕";
      tipIcon = Icons.coffee_rounded;
      tipColor = Colors.amber;
    } else if (dailySaving <= 150000) {
      tipText = "Target membutuhkan kedisiplinan finansial ekstra. Cobalah untuk mengurangi pengeluaran konsumtif atau mencari penghasilan tambahan. 💪";
      tipIcon = Icons.trending_up_rounded;
      tipColor = Colors.orange;
    } else {
      tipText = "Target setoran harian cukup menantang. Pertimbangkan untuk memperpanjang jangka waktu pencapaian agar menabung terasa lebih ringan dan santai. 📈";
      tipIcon = Icons.info_outline_rounded;
      tipColor = Colors.redAccent;
    }

    final cardBg = isDarkMode ? AppColors.surfaceDark : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(tipIcon, color: tipColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tipText,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white70 : Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final transactions = ref.watch(transactionsByGroupProvider(null));

    // Calculate actual active wallet balance (Incomes - Expenses)
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (s, a) => s + a.amount);
    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (s, a) => s + a.amount);
    final currentAppBalance = (totalIncome - totalExpense).clamp(0.0, double.infinity);

    // Determine initial balance
    final initialBalance = _useCurrentBalance ? currentAppBalance : _customInitialAmount;

    // Remaining money to save
    final remaining = (_targetAmount - initialBalance).clamp(0.0, double.infinity);
    final progress = _targetAmount > 0 ? (initialBalance / _targetAmount).clamp(0.0, 1.0) : 0.0;

    double daily = 0, weekly = 0, monthly = 0;
    int totalDays = 0;
    double totalWeeks = 0;
    double totalMonths = 0;

    if (_targetDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final target = DateTime(_targetDate!.year, _targetDate!.month, _targetDate!.day);
      totalDays = target.difference(today).inDays;

      if (totalDays > 0) {
        totalWeeks = totalDays / 7.0;
        totalMonths = totalDays / 30.4375; // average monthly days

        daily = remaining / totalDays;
        weekly = remaining / totalWeeks;
        monthly = remaining / totalMonths;
      } else {
        daily = remaining;
        weekly = remaining;
        monthly = remaining;
      }
    }

    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : Colors.white;
    final cardBgColor = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final borderCol = isDarkMode ? Colors.white10 : Colors.black26;

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
          'Simulasi Tabungan',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: contentColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Target Dana Input (Same style as Tambah Pemasukan) ──
            Text(
              'Target Dana Impian *',
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _RibuanSeparatorInputFormatter(),
              ],
              onChanged: (_) => _calculate(),
              decoration: InputDecoration(
                hintText: 'Masukkan Nominal',
                hintStyle: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white10 : Colors.black38,
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.payments_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rp',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                filled: true,
                fillColor: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade50,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderCol, width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderCol, width: 1.2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            // ── Saldo Awal Selector ──
            Text(
              'Saldo Awal untuk Target',
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderCol, width: 1.2),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _useCurrentBalance = true;
                        });
                        _calculate();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _useCurrentBalance
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Saldo Dompet',
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _useCurrentBalance
                                ? Colors.white
                                : (isDarkMode ? Colors.white60 : Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _useCurrentBalance = false;
                        });
                        _calculate();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_useCurrentBalance
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Saldo Kustom',
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: !_useCurrentBalance
                                ? Colors.white
                                : (isDarkMode ? Colors.white60 : Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_useCurrentBalance) ...[
              // Info current wallet balance
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol, width: 1.2),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saldo Dompet Saat Ini',
                          style: GoogleFonts.quicksand(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(currentAppBalance),
                          style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.bold, color: contentColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              // ── Saldo Awal Kustom (Same style as Tambah Pemasukan) ──
              Text(
                'Saldo Awal Kustom *',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _initialAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _RibuanSeparatorInputFormatter(),
                ],
                onChanged: (_) => _calculate(),
                decoration: InputDecoration(
                  hintText: 'Masukkan Nominal',
                  hintStyle: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white10 : Colors.black38,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.savings_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Rp',
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  filled: true,
                  fillColor: isDarkMode
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade50,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderCol, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderCol, width: 1.2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // ── Target Tanggal Tercapai (Same style as Date Picker in Tambah Pemasukan) ──
            Text(
              'Target Tanggal Tercapai *',
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderCol,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _targetDate == null 
                            ? 'Pilih tanggal target...' 
                            : DateFormat('dd/MM/yyyy', 'id_ID').format(_targetDate!),
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: _targetDate == null
                              ? (isDarkMode ? Colors.white10 : Colors.black38)
                              : (isDarkMode ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            if (_targetAmount > 0 && _targetDate != null) ...[
              // ── Hasil Simulasi Section ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progres Tabungan',
                          style: GoogleFonts.quicksand(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold, 
                            color: AppColors.primary, 
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _InfoPiece(
                          label: 'Saldo Awal',
                          value: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(initialBalance),
                          color: contentColor,
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        _InfoPiece(
                          label: 'Kekurangan',
                          value: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(remaining),
                          color: remaining > 0 ? Colors.redAccent : Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Rencana Setoran ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rencana Setoran',
                    style: GoogleFonts.quicksand(
                      color: contentColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.blue.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Durasi: ${_formatDuration(totalDays)}',
                      style: GoogleFonts.quicksand(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.blueAccent : const Color(0xFF2980B9),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Column(
                children: [
                  _buildSetoranRow('Setiap Hari (Harian)', daily, isDarkMode),
                  _buildSetoranRow('Setiap Minggu (Mingguan)', weekly, isDarkMode),
                  _buildSetoranRow('Setiap Bulan (Bulanan)', monthly, isDarkMode),
                ],
              ),
              const SizedBox(height: 24),

              _buildTipCard(daily, isDarkMode),
            ] else ...[
              // Empty State
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Icon(Icons.calculate_rounded, size: 40, color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                      const SizedBox(height: 12),
                      Text(
                        'Masukkan target dana impian dan tanggal tercapai\nuntuk melihat rencana simulasi tabungan.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white30 : Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSetoranRow(String label, double amount, bool isDarkMode) {
    final cardBgColor = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final borderCol = isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          Text(
            NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount),
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: amount > 0 ? (isDarkMode ? Colors.tealAccent : AppColors.primary) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPiece extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoPiece({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.quicksand(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: GoogleFonts.quicksand(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }
}

class _RibuanSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');
    final formatted = digitsOnly.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

