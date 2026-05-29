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
  String _taxType = 'PBB'; // PBB, PKB, PPh, PPN, BPHTB, PB1

  final List<Map<String, dynamic>> _taxTypes = [
    {'code': 'PBB', 'label': 'Pajak Bumi & Bangunan', 'icon': Icons.home_rounded},
    {'code': 'PKB', 'label': 'Pajak Kendaraan Bermotor', 'icon': Icons.directions_car_rounded},
    {'code': 'PPh', 'label': 'Pajak Penghasilan (PPh 21)', 'icon': Icons.wallet_rounded},
    {'code': 'PPN', 'label': 'Pajak Pertambahan Nilai (PPN)', 'icon': Icons.receipt_rounded},
    {'code': 'BPHTB', 'label': 'Bea Perolehan Hak Tanah & Bangunan', 'icon': Icons.domain_rounded},
    {'code': 'PB1', 'label': 'Pajak Restoran & Hotel (PB1)', 'icon': Icons.restaurant_rounded},
  ];

  IconData _getTaxIcon(String code) {
    switch (code) {
      case 'PBB': return Icons.home_rounded;
      case 'PKB': return Icons.directions_car_rounded;
      case 'PPh': return Icons.wallet_rounded;
      case 'PPN': return Icons.receipt_rounded;
      case 'BPHTB': return Icons.domain_rounded;
      case 'PB1': return Icons.restaurant_rounded;
      default: return Icons.payments_rounded;
    }
  }

  void _calculateTax() {
    final text = _valController.text.replaceAll('.', '');
    final amount = double.tryParse(text) ?? 0;
    setState(() {
      switch (_taxType) {
        case 'PBB':
          const njoptkp = 12000000;
          _taxResult = amount > njoptkp ? (amount - njoptkp) * 0.001 : 0;
          break;
        case 'PKB':
          _taxResult = amount * 0.02;
          break;
        case 'PPh':
          const ptkpBulanan = 4500000;
          double pkp = amount - ptkpBulanan;
          if (pkp <= 0) {
            _taxResult = 0;
          } else {
            if (pkp <= 5000000) {
              _taxResult = pkp * 0.05;
            } else {
              _taxResult = (5000000 * 0.05) + ((pkp - 5000000) * 0.15);
            }
          }
          break;
        case 'PPN':
          _taxResult = amount * 0.11;
          break;
        case 'BPHTB':
          const npoptkp = 60000000;
          _taxResult = amount > npoptkp ? (amount - npoptkp) * 0.05 : 0;
          break;
        case 'PB1':
          _taxResult = amount * 0.10;
          break;
        default:
          _taxResult = 0;
      }
    });
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    
    // Page Theme: Mint Green Accent & Classic Black/Light background
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9);
    final accentColor = isDarkMode ? const Color(0xFF2ECC71) : const Color(0xFF27AE60);
    final inputBgColor = isDarkMode ? Colors.white.withOpacity(0.05) : AppColors.background;

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: contentColor, size: 20),
        ),
        title: Text(
          'Kalkulator Pajak',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: contentColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(isDarkMode),
            const SizedBox(height: 24),
            
            // Tipe Pajak - Title
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Tipe Pajak',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: contentColor.withOpacity(0.5),
                ),
              ),
            ),
            
            // Minimalist Custom Dropdown
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: inputBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(_getTaxIcon(_taxType), color: accentColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _taxType,
                        isExpanded: true,
                        dropdownColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
                        icon: Icon(Icons.arrow_drop_down_rounded, color: contentColor.withOpacity(0.4), size: 20),
                        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: contentColor, fontSize: 13),
                        items: _taxTypes.map((t) {
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
                            _taxType = val!;
                            _calculateTax();
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            _buildAlignedInput(
              _taxType == 'PBB' ? 'Nilai Jual Bumi Bangunan (NJOP)' : 
              _taxType == 'PKB' ? 'Nilai Jual Kendaraan (NJKB)' :
              _taxType == 'PPh' ? 'Total Penghasilan Bulanan' :
              _taxType == 'PPN' ? 'Nilai Transaksi Barang/Jasa' :
              _taxType == 'BPHTB' ? 'Harga Transaksi Properti' :
              'Total Tagihan Restoran/Hotel', 
              _valController, 
              (_) => _calculateTax(), 
              _getTaxIcon(_taxType), 
              isDarkMode
            ),
            
            const SizedBox(height: 28),
            _buildResultCard(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildAlignedInput(String label, TextEditingController controller, Function(String) onChanged, IconData icon, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final accentColor = isDarkMode ? const Color(0xFF2ECC71) : const Color(0xFF27AE60);
    final inputBgColor = isDarkMode ? Colors.white.withOpacity(0.05) : AppColors.background;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
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
          keyboardType: TextInputType.number,
          inputFormatters: [_RibuanFormatter()],
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Nominal Dasar Pajak',
            hintStyle: GoogleFonts.quicksand(fontSize: 13, color: isDarkMode ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.25)),
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: accentColor, size: 18),
                  const SizedBox(width: 8),
                  Text('Rp', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: accentColor, fontSize: 13)),
                ],
              ),
            ),
            filled: true,
            fillColor: inputBgColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(bool isDarkMode) {
    final accentColor = isDarkMode ? const Color(0xFF2ECC71) : const Color(0xFF27AE60);
    final infoBgColor = accentColor.withOpacity(0.08);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: infoBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: accentColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Cek nilai akurat pada STNK atau SPPT terbaru Anda.',
              style: GoogleFonts.quicksand(
                fontSize: 11,
                color: isDarkMode ? Colors.white.withOpacity(0.9) : const Color(0xFF1E5F3B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(bool isDarkMode) {
    final cardBgColor = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final accentColor = isDarkMode ? const Color(0xFF2ECC71) : const Color(0xFF27AE60);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
      ),
      child: Column(
        children: [
          Text(
            'Estimasi Pajak ${_taxType}',
            style: GoogleFonts.quicksand(
              color: contentColor.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatRupiah(_taxResult), 
              style: GoogleFonts.quicksand(
                fontSize: 24,
                fontWeight: FontWeight.bold, 
                color: _taxResult > 0 ? accentColor : contentColor.withOpacity(0.2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _taxResult > 0 ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                disabledBackgroundColor: isDarkMode ? Colors.white.withOpacity(0.02) : Colors.grey.shade100,
              ),
              child: Text(
                'Simpan Pengingat',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: _taxResult > 0 ? Colors.white : Colors.grey),
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
