import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
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
  DateTime? _targetDate;
  double _targetAmount = 0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(amount);
  }

  void _calculate() {
    final text = _amountController.text.replaceAll('.', '');
    final amount = double.tryParse(text) ?? 0;
    
    setState(() {
      _targetAmount = amount;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 20)), // Max 20 years
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final transactions = ref.watch(transactionsByGroupProvider(null));
    
    // Calculate current personal balance (non-manual)
    final currentBalance = transactions
        .fold<double>(0, (s, t) => s + (t.type == TransactionType.income ? t.amount : 0));

    final remaining = (_targetAmount - currentBalance).clamp(0.0, double.infinity);
    final progress = _targetAmount > 0 ? (currentBalance / _targetAmount).clamp(0.0, 1.0) : 0.0;
    
    double daily = 0, weekly = 0, monthly = 0;
    int totalDays = 0;
    if (_targetDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final target = DateTime(_targetDate!.year, _targetDate!.month, _targetDate!.day);
      totalDays = target.difference(today).inDays;
      
      if (totalDays > 0) {
        daily = remaining / totalDays;
        weekly = totalDays >= 7 ? remaining / (totalDays / 7) : 0;
        monthly = totalDays >= 30 ? remaining / (totalDays / 30) : 0;
      } else {
        // If target is today
        daily = remaining;
      }
    }

    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9),
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
            fontSize: 11,
            color: contentColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeadingSection(isDarkMode),
            const SizedBox(height: 32),

            // FORM SECTION
            _buildInputField(
              label: 'TARGET DANA IMPIAN',
              controller: _amountController,
              icon: Icons.account_balance_wallet_rounded,
              isDarkMode: isDarkMode,
              isCurrency: true,
              onChanged: (_) => _calculate(),
            ),

            const SizedBox(height: 24),

            _buildDatePickerField(isDarkMode),

            const SizedBox(height: 40),

            // RESULTS DASHBOARD
            if (_targetAmount > 0 && _targetDate != null) ...[
              _buildProgressCard(progress, currentBalance, remaining, isDarkMode),
              const SizedBox(height: 32),
              _buildSavingsPlanSection(daily, weekly, monthly, totalDays, isDarkMode),
            ] else
              _buildEmptyState(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadingSection(bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hitung Tabungan',
          style: GoogleFonts.quicksand(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: contentColor,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Rencanakan masa depan finansialmu dengan tepat.',
          style: GoogleFonts.quicksand(
            fontSize: 11,
            color: contentColor.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isDarkMode,
    bool isCurrency = false,
    Function(String)? onChanged,
  }) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: contentColor.withValues(alpha: 0.5),
              letterSpacing: 1,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [isCurrency ? _RibuanSeparatorInputFormatter() : FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 11, color: contentColor),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: GoogleFonts.quicksand(fontSize: 11, color: isDarkMode ? Colors.white10 : Colors.black38),
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 20, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  if (isCurrency)
                    Text('Rp', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 11)),
                ],
              ),
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField(bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'TARGET TANGGAL TERCAPAI',
            style: GoogleFonts.quicksand(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: contentColor.withValues(alpha: 0.5),
              letterSpacing: 1,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  _targetDate == null 
                      ? 'Pilih Tanggal' 
                      : DateFormat('d MMMM yyyy', 'id_ID').format(_targetDate!),
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold, 
                    fontSize: 11, 
                    color: _targetDate == null ? (isDarkMode ? Colors.white24 : Colors.black38) : contentColor
                  ),
                ),
                const Spacer(),
                const Icon(Icons.expand_more_rounded, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(double progress, double currentBalance, double remaining, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final hexBg = isDarkMode ? AppColors.surfaceDark : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: hexBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PROGRES TABUNGAN',
                  style: GoogleFonts.quicksand(
                      color: contentColor.withValues(alpha: 0.4),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              Text('${(progress * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _InfoPiece(
                label: 'SALDO SAAT INI',
                value: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(currentBalance),
                color: contentColor,
              ),
              Container(
                  width: 1,
                  height: 30,
                  color: contentColor.withValues(alpha: 0.1),
                  margin: const EdgeInsets.symmetric(horizontal: 20)),
              _InfoPiece(
                label: 'KEKURANGAN',
                value: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(remaining),
                color: remaining > 0 ? Colors.red.shade400 : Colors.green.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsPlanSection(double daily, double weekly, double monthly, int totalDays, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RENCANA SETORAN',
            style: GoogleFonts.quicksand(
                color: contentColor.withValues(alpha: 0.4),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2)),
        const SizedBox(height: 16),
        Row(
          children: [
            _StatCard(label: 'SETIAP HARI', amount: daily, color: const Color(0xFF3498DB), isDarkMode: isDarkMode),
            if (totalDays >= 7) ...[
              const SizedBox(width: 12),
              _StatCard(label: 'SETIAP MINGGU', amount: weekly, color: const Color(0xFFF39C12), isDarkMode: isDarkMode),
            ],
          ],
        ),
        if (totalDays >= 30) ...[
          const SizedBox(height: 12),
          _StatCard(label: 'SETIAP BULAN', amount: monthly, color: const Color(0xFF27AE60), isDarkMode: isDarkMode, isWide: true),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.insights_rounded,
                  size: 48, color: isDarkMode ? Colors.white10 : AppColors.primary.withValues(alpha: 0.2)),
            ),
            const SizedBox(height: 24),
            Text(
              'Masukkan target dana dan tanggal\nuntuk melihat perhitungan.',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ],
        ),
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
          Text(label, style: GoogleFonts.quicksand(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: GoogleFonts.quicksand(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isDarkMode;
  final bool isWide;

  const _StatCard({required this.label, required this.amount, required this.color, required this.isDarkMode, this.isWide = false});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(label, style: GoogleFonts.quicksand(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount),
              style: GoogleFonts.quicksand(fontSize: 11, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );

    return isWide ? SizedBox(width: double.infinity, child: card) : Expanded(child: card);
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
