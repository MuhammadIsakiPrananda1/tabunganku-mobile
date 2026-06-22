import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';

class BudgetRulePage extends ConsumerStatefulWidget {
  const BudgetRulePage({super.key});

  @override
  ConsumerState<BudgetRulePage> createState() => _BudgetRulePageState();
}

class _BudgetRulePageState extends ConsumerState<BudgetRulePage> {
  final TextEditingController _incomeController = TextEditingController();
  double _income = 0;

  void _calculate() {
    final double value = double.tryParse(_incomeController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    setState(() {
      _income = value;
    });
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
    _incomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9);

final needsColor = isDarkMode ? const Color(0xFF3498DB) : const Color(0xFF2980B9);
    final wantsColor = isDarkMode ? const Color(0xFFE74C3C) : const Color(0xFFC0392B);
    final savingsColor = isDarkMode ? const Color(0xFF2ECC71) : const Color(0xFF27AE60);

    final double needsVal = _income * 0.50;
    final double wantsVal = _income * 0.30;
    final double savingsVal = _income * 0.20;

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
          'Aturan Budget 50/30/20',
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

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Aturan 50/30/20 membagi gaji bersih Anda menjadi 3 pos: Kebutuhan Pokok (50%), Keinginan (30%), dan Tabungan/Investasi (20%).',
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        color: isDarkMode ? Colors.white70 : AppColors.primaryDark.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    'Pendapatan Bersih Bulanan (Take Home Pay)',
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: contentColor.withOpacity(0.4),
                    ),
                  ),
                ),
                TextFormField(
                  controller: _incomeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [_RibuanFormatter()],
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                  onChanged: (_) => _calculate(),
                  decoration: InputDecoration(
                    hintText: 'Masukkan Nominal',
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
                          Icon(Icons.wallet_rounded, color: AppColors.primary, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            'Rp',
                            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
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
            ),
            const SizedBox(height: 16),

if (_income > 0) ...[
              Text(
                'Alokasi Anggaran Anda',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: contentColor,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 20,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 50,
                        child: Container(
                          color: needsColor,
                          alignment: Alignment.center,
                          child: Text(
                            '50%',
                            style: GoogleFonts.quicksand(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 30,
                        child: Container(
                          color: wantsColor,
                          alignment: Alignment.center,
                          child: Text(
                            '30%',
                            style: GoogleFonts.quicksand(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 20,
                        child: Container(
                          color: savingsColor,
                          alignment: Alignment.center,
                          child: Text(
                            '20%',
                            style: GoogleFonts.quicksand(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

_buildAllocationCard(
                title: 'Needs / Kebutuhan Pokok (50%)',
                amount: needsVal,
                color: needsColor,
                icon: Icons.home_repair_service_rounded,
                isDarkMode: isDarkMode,
                contentColor: contentColor,
                items: ['Tempat Tinggal (Sewa/Cicilan KPR)', 'Utilitas & Tagihan (Listrik, Air, Wifi)', 'Belanja Bahan Makanan Pokok', 'Kesehatan & Asuransi Dasar'],
              ),
              const SizedBox(height: 16),
              _buildAllocationCard(
                title: 'Wants / Keinginan & Gaya Hidup (30%)',
                amount: wantsVal,
                color: wantsColor,
                icon: Icons.local_play_rounded,
                isDarkMode: isDarkMode,
                contentColor: contentColor,
                items: ['Makan di Luar / Jajan', 'Hiburan (Netflix, Bioskop, Konser)', 'Belanja Pakaian & Gadget Non-Esensial', 'Hobi & Liburan'],
              ),
              const SizedBox(height: 16),
              _buildAllocationCard(
                title: 'Savings / Tabungan & Investasi (20%)',
                amount: savingsVal,
                color: savingsColor,
                icon: Icons.savings_rounded,
                isDarkMode: isDarkMode,
                contentColor: contentColor,
                items: ['Dana Darurat (Minimal 3-6 bulan pengeluaran)', 'Investasi Saham, Reksadana, atau Emas', 'Pelunasan Hutang Konsumtif', 'Tabungan Target Jangka Panjang'],
              ),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Masukkan nominal pendapatan untuk melihat alokasi.',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: contentColor.withOpacity(0.35),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
    required bool isDarkMode,
    required Color contentColor,
    required List<String> items,
  }) {
    final hexBg = isDarkMode ? AppColors.surfaceDark : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hexBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: contentColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatRupiah(amount),
                      style: GoogleFonts.quicksand(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_rounded, color: color.withOpacity(0.6), size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      color: contentColor.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )),
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
