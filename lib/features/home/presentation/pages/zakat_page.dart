import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/core/utils/currency_formatter.dart';

class ZakatPage extends ConsumerStatefulWidget {
  const ZakatPage({super.key});

  @override
  ConsumerState<ZakatPage> createState() => _ZakatPageState();
}

class _ZakatPageState extends ConsumerState<ZakatPage> with TickerProviderStateMixin {
  int _activeTabIndex = 0;
  late PageController _pageController;
  
  final TextEditingController _profesiController = TextEditingController();
  final TextEditingController _maalController = TextEditingController();
  final TextEditingController _fitrahController = TextEditingController();
  final TextEditingController _infaqController = TextEditingController();
  
  double _profesiAmount = 0;
  double _maalAmount = 0;
  double _fitrahAmount = 0;
  double _infaqAmount = 0;

  final double _hargaEmasPerGram = 1200000; 
  double get _nishabMaal => 85 * _hargaEmasPerGram;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _profesiController.dispose();
    _maalController.dispose();
    _fitrahController.dispose();
    _infaqController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    HapticFeedback.selectionClick();
    setState(() => _activeTabIndex = index);
    _pageController.jumpToPage(index);
  }

  void _calculateProfesi() {
    final text = _profesiController.text.replaceAll('.', '');
    final amount = double.tryParse(text) ?? 0;
    setState(() {
      _profesiAmount = amount * 0.025;
    });
  }

  void _calculateMaal() {
    final text = _maalController.text.replaceAll('.', '');
    final amount = double.tryParse(text) ?? 0;
    setState(() {
      _maalAmount = (amount >= _nishabMaal) ? amount * 0.025 : 0;
    });
  }

  void _recordTransaction(String title, double amount, String category) async {
    if (amount <= 0) return;
    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: 'Pembayaran $title melaui Zakat Calculator',
      amount: amount,
      type: TransactionType.expense,
      date: DateTime.now(),
      category: category,
    );
    await ref.read(transactionServiceProvider).addTransaction(transaction);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title berhasil dicatat!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Colors.black;
    const accentColor = AppColors.primary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: accentColor, size: 20),
        ),
        title: Text(
          'Zakat & Infaq', 
          style: GoogleFonts.comicNeue(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: accentColor,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Navigation Chips ────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildNavChip(0, 'Profesi', Icons.payments_outlined),
                  const SizedBox(width: 8),
                  _buildNavChip(1, 'Harta/Maal', Icons.account_balance_outlined),
                  const SizedBox(width: 8),
                  _buildNavChip(2, 'Fitrah & Infaq', Icons.auto_awesome_outlined),
                ],
              ),
            ),
          ),

          // ── Main Page Content View ──────────────────────────────────────
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _activeTabIndex = index),
              physics: const NeverScrollableScrollPhysics(), // Disable swipe to avoid sequential visual
              children: [
                _buildProfesiTab(),
                _buildMaalTab(),
                _buildFitrahTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavChip(int index, String label, IconData icon) {
    final isSelected = _activeTabIndex == index;
    return InkWell(
      onTap: () => _onTabChanged(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              size: 16, 
              color: isSelected ? Colors.black : AppColors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.comicNeue(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.black : AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfesiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildSimpleInfoCard('Zakat Profesi', 'Wajib 2.5% dari penghasilan rutin bulanan jika mencapai Nishab.'),
          const SizedBox(height: 24),
          _buildAlignedInput('Penghasilan Bulanan', _profesiController, (_) => _calculateProfesi(), Icons.wallet_rounded),
          const SizedBox(height: 24),
          _buildSimpleResultCard('Zakat Profesi', _profesiAmount, () => _recordTransaction('Zakat Profesi', _profesiAmount, 'Zakat')),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMaalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildSimpleInfoCard('Zakat Maal', 'Zakat harta simpanan yang dimiliki selama 1 tahun (Haul). Nishab 85g Emas.'),
          const SizedBox(height: 24),
          _buildAlignedInput('Total Harta Simpanan', _maalController, (_) => _calculateMaal(), Icons.savings_rounded),
          const SizedBox(height: 24),
          _buildSimpleResultCard(
            'Zakat Maal', 
            _maalAmount, 
            () => _recordTransaction('Zakat Maal', _maalAmount, 'Zakat'),
            warningText: (_maalAmount == 0 && _maalController.text.isNotEmpty) ? 'Saldo masih di bawah ambang nishab.' : null,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFitrahTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildSimpleInfoCard('Fitrah & Sedekah', 'Berbagi merupakan wujud syukur atas rezeki yang kita miliki.'),
          const SizedBox(height: 24),
          _buildAlignedInput('Zakat Fitrah', _fitrahController, (v) => setState(() => _fitrahAmount = double.tryParse(v.replaceAll('.', '')) ?? 0), Icons.face_rounded),
          const SizedBox(height: 16),
          _buildAlignedInput('Infaq / Sedekah', _infaqController, (v) => setState(() => _infaqAmount = double.tryParse(v.replaceAll('.', '')) ?? 0), Icons.favorite_rounded),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;
              final results = [
                Expanded(
                  flex: isNarrow ? 0 : 1,
                  child: _buildSimpleResultCard('Fitrah', _fitrahAmount, () => _recordTransaction('Zakat Fitrah', _fitrahAmount, 'Zakat'), compact: true),
                ),
                SizedBox(width: isNarrow ? 0 : 12, height: isNarrow ? 12 : 0),
                Expanded(
                  flex: isNarrow ? 0 : 1,
                  child: _buildSimpleResultCard('Infaq', _infaqAmount, () => _recordTransaction('Infaq', _infaqAmount, 'Gift'), compact: true),
                ),
              ];
              return isNarrow ? Column(children: results) : Row(children: results);
            }
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSimpleInfoCard(String title, String desc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(fontSize: 12, color: AppColors.primary.withValues(alpha: 0.6))),
        ],
      ),
    );
  }

  Widget _buildAlignedInput(String label, TextEditingController controller, Function(String) onChanged, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary.withValues(alpha: 0.4))),
        ),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [_RibuanFormatter()],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryLight),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(color: AppColors.primary.withValues(alpha: 0.1)),
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 20, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: AppColors.primary, size: 20),
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
            fillColor: const Color(0xFF0A0A0A),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.05))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleResultCard(String title, double amount, VoidCallback onAction, {String? warningText, bool compact = false}) {
    final hasVal = amount > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary.withValues(alpha: 0.4))),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount),
              style: GoogleFonts.comicNeue(
                fontSize: compact ? 22 : 32,
                fontWeight: FontWeight.bold,
                color: hasVal ? AppColors.primary : AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ),
          if (warningText != null) ...[
            const SizedBox(height: 8),
            Text(warningText, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: hasVal ? onAction : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.03),
              ),
              child: const Text('Catat Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
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
