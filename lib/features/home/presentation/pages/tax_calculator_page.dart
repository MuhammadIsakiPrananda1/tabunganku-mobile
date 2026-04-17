
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class TaxCalculatorPage extends ConsumerStatefulWidget {
  const TaxCalculatorPage({super.key});

  @override
  ConsumerState<TaxCalculatorPage> createState() => _TaxCalculatorPageState();
}

class _TaxCalculatorPageState extends ConsumerState<TaxCalculatorPage> {
  final TextEditingController _valController = TextEditingController();
  double _taxResult = 0;
  String _taxType = 'PBB'; // PBB or PKB

  void _calculateTax() {
    final text = _valController.text.replaceAll('.', '');
    final amount = double.tryParse(text) ?? 0;
    setState(() {
      if (_taxType == 'PBB') {
        _taxResult = amount * 0.001; // 0.1% of NJOP as a simple mock
      } else {
        _taxResult = amount * 0.02; // 2% of vehicle value as a simple mock
      }
    });
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: contentColor, size: 20),
        ),
        title: Text('Kalkulator Pajak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: contentColor)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(isDarkMode),
            const SizedBox(height: 32),
            
            Text('TIPE PAJAK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: contentColor.withValues(alpha: 0.4))),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTypeCard('PBB', 'Pajak Bumi Bangunan', Icons.home_rounded, isDarkMode)),
                const SizedBox(width: 12),
                Expanded(child: _buildTypeCard('PKB', 'Pajak Kendaraan', Icons.directions_car_rounded, isDarkMode)),
              ],
            ),
            
            const SizedBox(height: 32),
            _buildAlignedInput(
              _taxType == 'PBB' ? 'Nilai Jual Objek Pajak (NJOP)' : 'Nilai Jual Kendaraan (NJKB)', 
              _valController, 
              (_) => _calculateTax(), 
              _taxType == 'PBB' ? Icons.home_work_rounded : Icons.directions_car_filled_rounded, 
              isDarkMode
            ),
            
            const SizedBox(height: 48),
            _buildResultCard(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(String type, String desc, IconData icon, bool isDarkMode) {
    final isSelected = _taxType == type;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    
    return GestureDetector(
      onTap: () => setState(() {
        _taxType = type;
        _calculateTax();
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : (isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : (isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05))),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isSelected ? Colors.white : AppColors.primary, size: 24),
            const SizedBox(height: 12),
            Text(type, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSelected ? Colors.white : contentColor)),
            Text(desc, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white70 : Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlignedInput(String label, TextEditingController controller, Function(String) onChanged, IconData icon, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: contentColor.withValues(alpha: 0.5))),
        ),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [_RibuanFormatter()],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: contentColor),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white10 : Colors.black38),
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 20, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text('Rp', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
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

  Widget _buildInfoCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Cek nilai akurat pada STNK atau SPPT terbaru Anda.',
              style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(bool isDarkMode) {
    final hexBg = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: hexBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Text('ESTIMASI PAJAK ${_taxType}', style: TextStyle(color: contentColor.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatRupiah(_taxResult), 
              style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: _taxResult > 0 ? AppColors.primary : contentColor.withValues(alpha: 0.1))
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _taxResult > 0 ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                disabledBackgroundColor: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade100,
              ),
              child: const Text('Simpan Pengingat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
