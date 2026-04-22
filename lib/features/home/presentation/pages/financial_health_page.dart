import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';

class FinancialHealthPage extends ConsumerStatefulWidget {
  const FinancialHealthPage({super.key});

  @override
  ConsumerState<FinancialHealthPage> createState() => _FinancialHealthPageState();
}

class _FinancialHealthPageState extends ConsumerState<FinancialHealthPage> {
  final _incomeController = TextEditingController();
  final _expenseController = TextEditingController();
  final _debtController = TextEditingController();
  final _emergencyFundController = TextEditingController();

  bool _showResult = false;
  double _score = 0;
  String _status = '';
  Color _statusColor = Colors.green;
  
  // Results details
  double _savingsRatio = 0;
  double _debtRatio = 0;
  double _bufferMonths = 0;

  @override
  void dispose() {
    _incomeController.dispose();
    _expenseController.dispose();
    _debtController.dispose();
    _emergencyFundController.dispose();
    super.dispose();
  }

  void _calculateHealth() {
    final income = double.tryParse(_incomeController.text.replaceAll('.', '')) ?? 0;
    final expense = double.tryParse(_expenseController.text.replaceAll('.', '')) ?? 0;
    final debt = double.tryParse(_debtController.text.replaceAll('.', '')) ?? 0;
    final emergency = double.tryParse(_emergencyFundController.text.replaceAll('.', '')) ?? 0;

    if (income <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mohon masukkan penghasilan yang valid'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      // 1. Savings Ratio (Ideal > 10%)
      _savingsRatio = (income - expense) / income;
      double savingsScore = 0;
      if (_savingsRatio >= 0.20) savingsScore = 100;
      else if (_savingsRatio >= 0.10) savingsScore = 80;
      else if (_savingsRatio > 0) savingsScore = 40;
      else savingsScore = 0;

      // 2. Debt Service Ratio (Ideal < 35%)
      _debtRatio = debt / income;
      double debtScore = 0;
      if (_debtRatio <= 0.10) debtScore = 100;
      else if (_debtRatio <= 0.35) debtScore = 80;
      else if (_debtRatio <= 0.50) debtScore = 40;
      else debtScore = 0;

      // 3. Emergency Fund (Buffer) (Ideal 3-6 months)
      _bufferMonths = expense > 0 ? emergency / expense : 0;
      double bufferScore = 0;
      if (_bufferMonths >= 6) bufferScore = 100;
      else if (_bufferMonths >= 3) bufferScore = 80;
      else if (_bufferMonths >= 1) bufferScore = 40;
      else bufferScore = 10;

      // Final Score
      _score = (savingsScore + debtScore + bufferScore) / 3;

      if (_score >= 80) {
        _status = 'SANGAT SEHAT';
        _statusColor = Colors.green;
      } else if (_score >= 60) {
        _status = 'CUKUP SEHAT';
        _statusColor = Colors.blue;
      } else if (_score >= 40) {
        _status = 'PERLU PERHATIAN';
        _statusColor = Colors.orange;
      } else {
        _status = 'BAHAYA';
        _statusColor = Colors.red;
      }

      _showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: contentColor, size: 20),
        ),
        title: Text(
          'Checkup Finansial',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: contentColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            if (!_showResult) ...[
              const SizedBox(height: 12),
              _buildSimpleInfoCard(
                'Assessment Finansial', 
                'Dapatkan diagnosis kesehatan keuanganmu secara instan berdasarkan rasio keuangan standar.', 
                isDarkMode
              ),
              const SizedBox(height: 32),
              _buildAlignedInput('Penghasilan Bulanan', _incomeController, Icons.payments_rounded, Colors.green, isDarkMode),
              const SizedBox(height: 16),
              _buildAlignedInput('Pengeluaran Bulanan', _expenseController, Icons.shopping_bag_rounded, Colors.orange, isDarkMode),
              const SizedBox(height: 16),
              _buildAlignedInput('Cicilan Utang', _debtController, Icons.credit_card_rounded, Colors.redAccent, isDarkMode),
              const SizedBox(height: 16),
              _buildAlignedInput('Total Dana Darurat', _emergencyFundController, Icons.health_and_safety_rounded, Colors.teal, isDarkMode),
              const SizedBox(height: 40),
              _buildMainAction('Analisis Sekarang', _calculateHealth),
            ] else ...[
              const SizedBox(height: 24),
              _buildScoreCard(isDarkMode),
              const SizedBox(height: 32),
              _buildRatioDetails(isDarkMode),
              const SizedBox(height: 32),
              _buildTipsSection(isDarkMode),
              const SizedBox(height: 48),
              _buildResetButton(),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleInfoCard(String title, String desc, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white60 : Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildAlignedInput(String label, TextEditingController controller, IconData icon, Color iconColor, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: contentColor.withValues(alpha: 0.5))),
        ),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [_RibuanFormatter()],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: contentColor),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(color: isDarkMode ? Colors.white10 : Colors.grey.shade300),
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 20, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: iconColor, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Rp', 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: AppColors.primary, 
                      fontSize: 16
                    )
                  ),
                ],
              ),
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildMainAction(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildScoreCard(bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'STATUS KESEHATAN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: contentColor.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: _score / 100,
                  strokeWidth: 12,
                  backgroundColor: _statusColor.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                children: [
                  Text(
                    _score.toInt().toString(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: contentColor,
                    ),
                  ),
                  Text(
                    'dari 100',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: contentColor.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: _statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _status,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatioDetails(bool isDarkMode) {
    return Column(
      children: [
        _buildRatioItem(
          label: 'Rasio Tabungan',
          value: '${(_savingsRatio * 100).toStringAsFixed(0)}%',
          target: 'Ideal: >10%',
          description: 'Sisa penghasilan yang ditabung',
          isGood: _savingsRatio >= 0.1,
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 16),
        _buildRatioItem(
          label: 'Rasio Utang',
          value: '${(_debtRatio * 100).toStringAsFixed(0)}%',
          target: 'Ideal: <35%',
          description: 'Beban cicilan terhadap gaji',
          isGood: _debtRatio <= 0.35,
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 16),
        _buildRatioItem(
          label: 'Dana Darurat',
          value: '${_bufferMonths.toStringAsFixed(1)} Bln',
          target: 'Ideal: 3-6 Bln',
          description: 'Ketahanan dana cadangan',
          isGood: _bufferMonths >= 3,
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }

  Widget _buildRatioItem({
    required String label,
    required String value,
    required String target,
    required String description,
    required bool isGood,
    required bool isDarkMode,
  }) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: contentColor.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: contentColor.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isGood ? Colors.green : Colors.orange,
                ),
              ),
              Text(
                target,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: contentColor.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(bool isDarkMode) {
    String tipTitle = 'Rekomendasi Cerdas';
    String tipDesc = 'Pertahankan kebiasaan menabungmu dan pastikan asetmu terus berkembang.';
    IconData tipIcon = Icons.auto_awesome_rounded;

    if (_debtRatio > 0.35) {
      tipTitle = 'Kurangi Beban Utang';
      tipDesc = 'Cicilanmu tinggi. Fokus lunasi utang bunga tinggi terlebih dahulu.';
      tipIcon = Icons.warning_amber_rounded;
    } else if (_bufferMonths < 3) {
      tipTitle = 'Prioritas Dana Darurat';
      tipDesc = 'Dana cadanganmu belum aman. Sisihkan minimal 3-6 bulan pengeluaran.';
      tipIcon = Icons.shield_rounded;
    } else if (_savingsRatio < 0.1) {
      tipTitle = 'Tingkatkan Tabungan';
      tipDesc = 'Cobalah metode 50/30/20. Pastikan minimal 10-20% masuk tabungan.';
      tipIcon = Icons.trending_up_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(tipIcon, color: AppColors.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tipTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tipDesc,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return Center(
      child: TextButton(
        onPressed: () => setState(() => _showResult = false),
        child: const Text(
          'Mulai Ulang Analisis',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
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
