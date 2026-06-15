import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/models/transaction_model.dart';

class ZakatPage extends ConsumerStatefulWidget {
  const ZakatPage({super.key});

  @override
  ConsumerState<ZakatPage> createState() => _ZakatPageState();
}

class _ZakatPageState extends ConsumerState<ZakatPage> {
  String _activeType = 'Profesi'; // Profesi, Maal, Fitrah
  
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

  final List<Map<String, dynamic>> _zakatTypes = [
    {'code': 'Profesi', 'label': 'Zakat Profesi', 'icon': Icons.payments_rounded},
    {'code': 'Maal', 'label': 'Zakat Harta / Maal', 'icon': Icons.account_balance_wallet_rounded},
    {'code': 'Fitrah', 'label': 'Zakat Fitrah & Infaq', 'icon': Icons.favorite_rounded},
  ];

  @override
  void dispose() {
    _profesiController.dispose();
    _maalController.dispose();
    _fitrahController.dispose();
    _infaqController.dispose();
    super.dispose();
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

  void _recordTransaction(String title, double amount, String category, Color accentColor) async {
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
          content: Text(
            '$title berhasil dicatat!',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
          ),
          backgroundColor: accentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

  IconData _getZakatIcon(String code) {
    return _zakatTypes.firstWhere((t) => t['code'] == code)['icon'] as IconData;
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
    final inputBgColor = isDarkMode ? Colors.white.withOpacity(0.05) : AppColors.background;

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
          'Zakat & Infaq', 
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

            Text(
              'Tipe Zakat', 
              style: GoogleFonts.quicksand(
                fontSize: 11, 
                fontWeight: FontWeight.bold, 
                color: contentColor.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 8),

            // Premium Dropdown like Tax Calculator
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: inputBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(_getZakatIcon(_activeType), color: accentColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _activeType,
                        isExpanded: true,
                        dropdownColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
                        icon: Icon(Icons.arrow_drop_down_rounded, color: contentColor.withOpacity(0.4), size: 20),
                        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: contentColor, fontSize: 13),
                        items: _zakatTypes.map((t) {
                          return DropdownMenuItem<String>(
                            value: t['code'] as String,
                            child: Text(
                              t['label'] as String,
                              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _activeType = val!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            if (_activeType == 'Profesi') _buildProfesiContent(isDarkMode, accentColor),
            if (_activeType == 'Maal') _buildMaalContent(isDarkMode, accentColor),
            if (_activeType == 'Fitrah') _buildFitrahContent(isDarkMode, accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildProfesiContent(bool isDarkMode, Color accentColor) {
    return Column(
      children: [
        _buildAlignedInput(
          'Penghasilan Bulanan', 
          _profesiController, 
          (_) => _calculateProfesi(), 
          Icons.wallet_rounded, 
          isDarkMode,
          accentColor,
          'Masukkan Nominal'
        ),
        const SizedBox(height: 32),
        _buildResultCard(
          'Estimasi Zakat Profesi', 
          _profesiAmount, 
          () => _recordTransaction('Zakat Profesi', _profesiAmount, 'Zakat', accentColor), 
          isDarkMode,
          accentColor
        ),
      ],
    );
  }

  Widget _buildMaalContent(bool isDarkMode, Color accentColor) {
    final warningText = (_maalAmount == 0 && _maalController.text.isNotEmpty) 
      ? 'Saldo belum mencapai nishab (~Rp ${NumberFormat.decimalPattern('id_ID').format(_nishabMaal)})' 
      : null;

    return Column(
      children: [
        _buildAlignedInput(
          'Total Harta Simpanan', 
          _maalController, 
          (_) => _calculateMaal(), 
          Icons.account_balance_rounded, 
          isDarkMode,
          accentColor,
          'Masukkan Nominal'
        ),
        const SizedBox(height: 32),
        _buildResultCard(
          'Estimasi Zakat Maal', 
          _maalAmount, 
          () => _recordTransaction('Zakat Maal', _maalAmount, 'Zakat', accentColor), 
          isDarkMode,
          accentColor,
          warningText: warningText
        ),
      ],
    );
  }

  Widget _buildFitrahContent(bool isDarkMode, Color accentColor) {
    return Column(
      children: [
        _buildAlignedInput(
          'Zakat Fitrah', 
          _fitrahController, 
          (v) => setState(() => _fitrahAmount = double.tryParse(v.replaceAll('.', '')) ?? 0), 
          Icons.face_rounded, 
          isDarkMode,
          accentColor,
          'Masukkan Nominal'
        ),
        const SizedBox(height: 20),
        _buildAlignedInput(
          'Infaq / Sedekah', 
          _infaqController, 
          (v) => setState(() => _infaqAmount = double.tryParse(v.replaceAll('.', '')) ?? 0), 
          Icons.favorite_rounded, 
          isDarkMode,
          accentColor,
          'Masukkan Nominal'
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: _buildResultCard(
                'Fitrah', 
                _fitrahAmount, 
                () => _recordTransaction('Zakat Fitrah', _fitrahAmount, 'Zakat', accentColor), 
                isDarkMode,
                accentColor,
                compact: true
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildResultCard(
                'Infaq', 
                _infaqAmount, 
                () => _recordTransaction('Infaq', _infaqAmount, 'Gift', accentColor), 
                isDarkMode,
                accentColor,
                compact: true
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlignedInput(
    String label, 
    TextEditingController controller, 
    Function(String) onChanged, 
    IconData icon, 
    bool isDarkMode,
    Color accentColor,
    String hintText
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
          inputFormatters: [_RibuanFormatter()],
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
              padding: const EdgeInsets.only(left: 12, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: accentColor, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Rp', 
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: accentColor, fontSize: 13),
                  ),
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
              _activeType == 'Profesi' ? 'Zakat profesi wajib dikeluarkan jika mencapai nishab setara 522kg beras.' :
              _activeType == 'Maal' ? 'Zakat harta simpanan (Maal) wajib dikeluarkan jika mencapai nishab 85g emas.' :
              'Sucikan harta Anda dengan zakat fitrah dan infaq/sedekah.',
              style: GoogleFonts.quicksand(fontSize: 11, color: accentColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(
    String title, 
    double amount, 
    VoidCallback onRecord, 
    bool isDarkMode, 
    Color accentColor,
    {String? warningText, 
    bool compact = false}
  ) {
    final hexBg = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final hasValue = amount > 0;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 16 : 24),
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
            title, 
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
              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount), 
              style: GoogleFonts.quicksand(
                fontSize: compact ? 22 : 26, 
                fontWeight: FontWeight.bold, 
                color: hasValue ? accentColor : contentColor.withOpacity(0.1),
              ),
            ),
          ),
          if (warningText != null) ...[
            const SizedBox(height: 8),
            Text(
              warningText, 
              textAlign: TextAlign.center, 
              style: GoogleFonts.quicksand(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: hasValue ? onRecord : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                disabledBackgroundColor: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.grey.shade100,
              ),
              child: Text(
                'Catat', 
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: hasValue ? Colors.white : Colors.grey),
              ),
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
