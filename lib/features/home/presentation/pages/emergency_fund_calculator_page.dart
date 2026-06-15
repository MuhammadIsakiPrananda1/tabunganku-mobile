import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';

class EmergencyFundCalculatorPage extends ConsumerStatefulWidget {
  const EmergencyFundCalculatorPage({super.key});

  @override
  ConsumerState<EmergencyFundCalculatorPage> createState() => _EmergencyFundCalculatorPageState();
}

class _EmergencyFundCalculatorPageState extends ConsumerState<EmergencyFundCalculatorPage> {
  final TextEditingController _expenseCtrl = TextEditingController();
  
  String _maritalStatus = 'Lajang'; // Lajang, Menikah, Menikah & Anak
  String _jobType = 'Karyawan'; // Karyawan, Freelancer/Pengusaha
  int _targetMonths = 12; // 6, 12, 18, 24 months

  double _targetAmount = 0;
  double _monthlySavingNeeded = 0;
  int _totalMonthsCovered = 0;

  @override
  void initState() {
    super.initState();
    // Start with blank inputs to show placeholders
    _calculate();
  }

  void _calculate() {
    final double monthlyExpense = double.tryParse(_expenseCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    if (monthlyExpense <= 0) {
      setState(() {
        _targetAmount = 0;
        _monthlySavingNeeded = 0;
        _totalMonthsCovered = 0;
      });
      return;
    }

    int baseMultiplier = 6;
    if (_maritalStatus == 'Menikah') {
      baseMultiplier = 9;
    } else if (_maritalStatus == 'Menikah & Anak') {
      baseMultiplier = 12;
    }

    double jobMultiplier = 1.0;
    if (_jobType == 'Freelancer/Pengusaha') {
      jobMultiplier = 1.5;
    }

    final double monthsCovered = baseMultiplier * jobMultiplier;
    _totalMonthsCovered = monthsCovered.round();

    _targetAmount = monthlyExpense * monthsCovered;
    _monthlySavingNeeded = _targetAmount / _targetMonths;

    setState(() {});
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
    _expenseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9);
    
    // Page Theme Accent: Red/Rose for Emergency/Darurat
    const accentColor = Colors.redAccent;
    final inputBgColor = isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.background;

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
          'Kalkulator Dana Darurat',
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
                color: accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: accentColor, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Hitung jumlah dana cadangan darurat yang ideal untuk melindungi keuangan Anda dari risiko kesehatan, pemutusan hubungan kerja (PHK), atau kondisi darurat lainnya.',
                      style: GoogleFonts.quicksand(fontSize: 11, color: accentColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Inputs
            _buildInput('Pengeluaran Bulanan Anda', _expenseCtrl, Icons.shopping_bag_rounded, isDarkMode, accentColor, isCurrency: true, hintText: 'Masukkan Pengeluaran Bulanan'),
            const SizedBox(height: 18),

            // Dropdowns row 1 (Status & Pekerjaan)
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    'Status Keluarga', 
                    _maritalStatus, 
                    ['Lajang', 'Menikah', 'Menikah & Anak'], 
                    Icons.people_rounded, 
                    isDarkMode, 
                    accentColor, 
                    inputBgColor, 
                    contentColor, 
                    (val) {
                      setState(() {
                        _maritalStatus = val!;
                        _calculate();
                      });
                    }
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    'Pekerjaan', 
                    _jobType, 
                    ['Karyawan', 'Freelancer/Pengusaha'], 
                    Icons.work_rounded, 
                    isDarkMode, 
                    accentColor, 
                    inputBgColor, 
                    contentColor, 
                    (val) {
                      setState(() {
                        _jobType = val!;
                        _calculate();
                      });
                    }
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Target Months Dropdown
            _buildDropdown(
              'Target Waktu Pencapaian', 
              '$_targetMonths Bulan', 
              ['6 Bulan', '12 Bulan', '18 Bulan', '24 Bulan'], 
              Icons.hourglass_empty_rounded, 
              isDarkMode, 
              accentColor, 
              inputBgColor, 
              contentColor, 
              (val) {
                setState(() {
                  _targetMonths = int.parse(val!.split(' ')[0]);
                  _calculate();
                });
              }
            ),
            const SizedBox(height: 28),

            // Results Card
            if (_targetAmount > 0) ...[
              _buildResultCard(isDarkMode, accentColor),
              const SizedBox(height: 24),

              // Dynamic Explanation Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 Analisis Kebutuhan Anda',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: contentColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Berdasarkan profil Anda sebagai $_maritalStatus dengan pekerjaan $_jobType, Anda direkomendasikan memiliki dana darurat setara dengan $_totalMonthsCovered bulan pengeluaran.\n\nDengan menabung ${_formatRupiah(_monthlySavingNeeded)} secara konsisten setiap bulannya, target ini akan tercapai dalam waktu $_targetMonths bulan.',
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        color: contentColor.withValues(alpha: 0.7),
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Educational Guide
              Text(
                '💡 Tips Membangun Dana Darurat',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: contentColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildTipItem(Icons.account_balance_wallet_rounded, 'Pisahkan Rekening', 'Simpan dana darurat di rekening terpisah yang tanpa biaya admin bulanan agar tidak terpakai secara tidak sengaja.', contentColor, isDarkMode),
              const SizedBox(height: 12),
              _buildTipItem(Icons.trending_down_rounded, 'Mulai dengan Konsisten', 'Mulailah dengan menyisihkan nominal kecil terlebih dahulu secara konsisten setiap gajian sebelum menaikkannya secara bertahap.', contentColor, isDarkMode),
              const SizedBox(height: 12),
              _buildTipItem(Icons.lock_rounded, 'Hanya untuk Keadaan Darurat', 'Gunakan dana ini hanya untuk pengeluaran mendesak yang tidak terduga seperti biaya pengobatan, perbaikan kendaraan, atau kehilangan pekerjaan.', contentColor, isDarkMode),
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
    {bool isCurrency = false, String? hintText}
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
              color: contentColor.withValues(alpha: 0.4),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: isCurrency 
              ? [_RibuanFormatter()] 
              : [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
          onChanged: (_) => _calculate(),
          decoration: InputDecoration(
            hintText: hintText ?? 'Masukkan Nominal',
            hintStyle: GoogleFonts.quicksand(
              fontSize: 13,
              color: isDarkMode ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.25),
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
            fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.only(left: 0, right: 16, top: 12, bottom: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label, 
    String currentValue, 
    List<String> items, 
    IconData icon, 
    bool isDarkMode, 
    Color accentColor,
    Color inputBgColor,
    Color contentColor,
    void Function(String?) onChanged
  ) {
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
              color: contentColor.withValues(alpha: 0.4),
            ),
          ),
        ),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: inputBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: accentColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: currentValue,
                    isExpanded: true,
                    dropdownColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
                    icon: Icon(Icons.arrow_drop_down_rounded, color: contentColor.withValues(alpha: 0.4), size: 20),
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: contentColor, fontSize: 13),
                    items: items.map((t) {
                      return DropdownMenuItem<String>(
                        value: t,
                        child: Text(
                          t,
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                        ),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(bool isDarkMode, Color accentColor) {
    final hexBg = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: hexBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
        ),
      ),
      child: Column(
        children: [
          // Total target amount
          Text(
            'Target Total Dana Darurat', 
            style: GoogleFonts.quicksand(
              color: contentColor.withValues(alpha: 0.4), 
              fontSize: 11, 
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatRupiah(_targetAmount), 
              style: GoogleFonts.quicksand(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: accentColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          Divider(
            height: 1,
            color: isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
          ),
          const SizedBox(height: 20),

          // Detail Row
          _buildDetailRow('Ideal Kelipatan Pengeluaran', '$_totalMonthsCovered Bulan', contentColor),
          const SizedBox(height: 12),
          _buildDetailRow('Target Waktu Pengumpulan', '$_targetMonths Bulan', contentColor),
          
          const SizedBox(height: 20),
          Divider(
            height: 1,
            color: isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
          ),
          const SizedBox(height: 20),

          // Monthly Savings target info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.trending_up_rounded, color: Colors.green, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tabungan Bulanan yang Dibutuhkan',
                        style: GoogleFonts.quicksand(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white54 : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _formatRupiah(_monthlySavingNeeded),
                          style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color contentColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: contentColor.withValues(alpha: 0.5),
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: contentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(IconData icon, String title, String desc, Color contentColor, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.02) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.redAccent, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.quicksand(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: contentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    color: contentColor.withValues(alpha: 0.5),
                    height: 1.4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
