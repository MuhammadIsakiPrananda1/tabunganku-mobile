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
  DateTime? _targetDate;
  double _targetAmount = 0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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
      lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
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

        daily = remaining;
      }
    }

    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9);

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
            _buildHeadingSection(isDarkMode),
            const SizedBox(height: 32),

_buildInputField(
              label: 'Target Dana Impian',
              controller: _amountController,
              icon: Icons.account_balance_wallet_rounded,
              isDarkMode: isDarkMode,
              isCurrency: true,
              iconColor: isDarkMode ? Colors.amberAccent : const Color(0xFFD4AF37),
              onChanged: (_) => _calculate(),
            ),

            const SizedBox(height: 20),

            _buildDatePickerField(isDarkMode),

            const SizedBox(height: 32),

if (_targetAmount > 0 && _targetDate != null) ...[
              _buildProgressCard(progress, currentBalance, remaining, isDarkMode),
              const SizedBox(height: 24),
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
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: contentColor,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Rencanakan masa depan finansialmu dengan tepat.',
          style: GoogleFonts.quicksand(
            fontSize: 12,
            color: contentColor.withOpacity(0.5),
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
    Color? iconColor,
  }) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final resolvedIconColor = iconColor ?? (isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF2E3D49));
    final rpColor = iconColor ?? (isDarkMode ? Colors.white.withOpacity(0.8) : const Color(0xFF2E3D49));
    final inputBgColor = isDarkMode ? Colors.white.withOpacity(0.05) : AppColors.background;

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
              color: contentColor.withOpacity(0.5),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: isCurrency ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          inputFormatters: [isCurrency ? _RibuanSeparatorInputFormatter() : FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Masukkan Nominal',
            hintStyle: GoogleFonts.quicksand(fontSize: 13, color: isDarkMode ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.25)),
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 12, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: resolvedIconColor, size: 18),
                  const SizedBox(width: 4),
                  if (isCurrency)
                    Text('Rp', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: rpColor, fontSize: 13)),
                ],
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: inputBgColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.only(left: 0, right: 16, top: 14, bottom: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField(bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final iconColor = isDarkMode ? Colors.blueAccent : const Color(0xFF2980B9);
    final inputBgColor = isDarkMode ? Colors.white.withOpacity(0.05) : AppColors.background;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            'Target Tanggal Tercapai',
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: contentColor.withOpacity(0.5),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: inputBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded, color: iconColor, size: 18),
                const SizedBox(width: 12),
                Text(
                  _targetDate == null 
                      ? 'Pilih tanggal target...' 
                      : DateFormat('d MMMM yyyy', 'id_ID').format(_targetDate!),
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold, 
                    fontSize: 13, 
                    color: _targetDate == null ? (isDarkMode ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.25)) : contentColor
                  ),
                ),
                const Spacer(),
                Icon(Icons.expand_more_rounded, color: iconColor.withOpacity(0.5), size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(double progress, double currentBalance, double remaining, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final cardBgColor = isDarkMode ? AppColors.surfaceDark : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
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
                  color: contentColor.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold, 
                  color: isDarkMode ? Colors.tealAccent : AppColors.primary, 
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(isDarkMode ? Colors.tealAccent : AppColors.primary),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _InfoPiece(
                label: 'Saldo Saat Ini',
                value: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(currentBalance),
                color: contentColor,
              ),
              Container(
                width: 1,
                height: 30,
                color: contentColor.withOpacity(0.1),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              _InfoPiece(
                label: 'Kekurangan',
                value: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(remaining),
                color: remaining > 0 ? Colors.redAccent : Colors.greenAccent,
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
        Text(
          'Rencana Setoran',
          style: GoogleFonts.quicksand(
            color: contentColor.withOpacity(0.5),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _StatCard(label: 'Setiap Hari', amount: daily, color: const Color(0xFF3498DB), isDarkMode: isDarkMode),
            if (totalDays >= 7) ...[
              const SizedBox(width: 12),
              _StatCard(label: 'Setiap Minggu', amount: weekly, color: const Color(0xFFF39C12), isDarkMode: isDarkMode),
            ],
          ],
        ),
        if (totalDays >= 30) ...[
          const SizedBox(height: 12),
          _StatCard(label: 'Setiap Bulan', amount: monthly, color: const Color(0xFF27AE60), isDarkMode: isDarkMode, isWide: true),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    final cardBgColor = isDarkMode ? AppColors.surfaceDark : Colors.white;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
      ),
      child: Column(
        children: [
          Icon(Icons.insights_rounded, size: 48, color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05)),
          const SizedBox(height: 16),
          Text(
            'Masukkan target dana dan tanggal\nuntuk melihat perhitungan.',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(fontSize: 11, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white30 : Colors.grey),
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

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isDarkMode;
  final bool isWide;

  const _StatCard({required this.label, required this.amount, required this.color, required this.isDarkMode, this.isWide = false});

  @override
  Widget build(BuildContext context) {
    final cardBgColor = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(label, style: GoogleFonts.quicksand(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount),
              style: GoogleFonts.quicksand(fontSize: 13, fontWeight: FontWeight.bold, color: color),
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
