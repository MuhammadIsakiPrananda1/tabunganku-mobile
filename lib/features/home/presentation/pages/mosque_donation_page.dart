import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/models/transaction_model.dart';

class MosqueDonationPage extends ConsumerStatefulWidget {
  const MosqueDonationPage({super.key});

  @override
  ConsumerState<MosqueDonationPage> createState() => _MosqueDonationPageState();
}

class _MosqueDonationPageState extends ConsumerState<MosqueDonationPage> {
  final TextEditingController _mosqueNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _customTypeController = TextEditingController();
  String _selectedType = 'Infaq Jumat';

  final List<String> _donationTypes = [
    'Infaq Jumat',
    'Pembangunan',
    'Operasional Masjid',
    'Santunan Yatim',
    'Zakat Mal',
    'Lainnya',
  ];

  @override
  void dispose() {
    _mosqueNameController.dispose();
    _amountController.dispose();
    _customTypeController.dispose();
    super.dispose();
  }

  void _saveDonation(Color accentColor) async {
    final amountText = _amountController.text.replaceAll('.', '');
    final amount = double.tryParse(amountText) ?? 0;
    final mosqueName = _mosqueNameController.text.trim();
    final customType = _customTypeController.text.trim();

    if (amount <= 0 || mosqueName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mohon isi nama masjid dan nominal sedekah',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (_selectedType == 'Lainnya' && customType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mohon isi jenis sedekah kustom Anda',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Sedekah: $mosqueName',
      description: 'Sedekah ${_selectedType == 'Lainnya' ? customType : _selectedType} untuk $mosqueName',
      amount: amount,
      type: TransactionType.expense,
      date: DateTime.now(),
      category: 'Social',
    );

    await ref.read(transactionServiceProvider).addTransaction(transaction);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sedekah berhasil dicatat! ✨',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
          ),
          backgroundColor: accentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

  IconData _getDonationIcon(String type) {
    switch (type) {
      case 'Infaq Jumat':
        return Icons.calendar_today_rounded;
      case 'Pembangunan':
        return Icons.home_work_rounded;
      case 'Operasional Masjid':
        return Icons.settings_rounded;
      case 'Santunan Yatim':
        return Icons.child_care_rounded;
      case 'Zakat Mal':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

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
          'Sedekah Masjid',
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
            
            _buildAlignedInput(
              'Nama Masjid',
              _mosqueNameController,
              (_) {},
              Icons.mosque_rounded,
              isDarkMode,
              accentColor,
              'Nama Masjid',
            ),
            const SizedBox(height: 20),
            
            _buildAlignedInput(
              'Nominal Sedekah',
              _amountController,
              (_) {},
              Icons.account_balance_wallet_rounded,
              isDarkMode,
              accentColor,
              'Nominal Sedekah',
              isCurrency: true,
            ),
            const SizedBox(height: 20),
            
            Text(
              'Jenis Sedekah',
              style: GoogleFonts.quicksand(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: contentColor.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 8),

Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: inputBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(_getDonationIcon(_selectedType), color: accentColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedType,
                        isExpanded: true,
                        dropdownColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
                        icon: Icon(Icons.arrow_drop_down_rounded, color: contentColor.withOpacity(0.4), size: 20),
                        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: contentColor, fontSize: 13),
                        items: _donationTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(
                              type,
                              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedType = val!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            if (_selectedType == 'Lainnya') ...[
              const SizedBox(height: 20),
              _buildAlignedInput(
                'Jenis Sedekah Kustom',
                _customTypeController,
                (_) {},
                Icons.edit_note_rounded,
                isDarkMode,
                accentColor,
                'Jenis Sedekah Kustom',
              ),
            ],
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => _saveDonation(accentColor),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  'Simpan Catatan Sedekah',
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlignedInput(
    String label, 
    TextEditingController controller, 
    Function(String) onChanged, 
    IconData icon, 
    bool isDarkMode,
    Color accentColor,
    String hintText,
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

  Widget _buildInfoCard(Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.volunteer_activism_rounded, color: accentColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sedekah adalah bukti keimanan. Catat setiap kebaikanmu untuk memantau keberkahan hartamu.',
              style: GoogleFonts.quicksand(fontSize: 11, color: accentColor, fontWeight: FontWeight.bold, height: 1.4),
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
