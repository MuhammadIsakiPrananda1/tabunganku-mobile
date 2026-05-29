import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/models/investment_model.dart';
import 'package:tabunganku/services/investment_service.dart';
import 'package:google_fonts/google_fonts.dart';

class InvestmentTrackerPage extends ConsumerStatefulWidget {
  const InvestmentTrackerPage({super.key});

  @override
  ConsumerState<InvestmentTrackerPage> createState() => _InvestmentTrackerPageState();
}

class _InvestmentTrackerPageState extends ConsumerState<InvestmentTrackerPage> {
  final _amountController = TextEditingController();

  String _formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final investmentsAsync = ref.watch(investmentServiceProvider).watchInvestments();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
        title: Text(
          'Portofolio Investasi',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: contentColor,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<InvestmentModel>>(
        stream: investmentsAsync,
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          final totalInvested = items.fold(0.0, (s, i) => s + i.totalInvested);
          final currentVal = items.fold(0.0, (s, i) => s + i.currentValuation);
          final totalPL = currentVal - totalInvested;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(totalInvested, currentVal, totalPL, isDarkMode),
                const SizedBox(height: 32),
                Text(
                  'ASET INVESTASI', 
                  style: GoogleFonts.quicksand(
                    fontSize: 10, 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 1.5, 
                    color: contentColor.withOpacity(0.35),
                  ),
                ),
                const SizedBox(height: 16),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3F51B5)),
                      ),
                    ),
                  )
                else if (items.isEmpty)
                  _buildEmptyState(isDarkMode)
                else
                  ...items.map((i) => _buildInvestmentItem(i, isDarkMode)),
                const SizedBox(height: 80), // Extra space for FAB
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddInvestmentSheet(isDarkMode),
        backgroundColor: const Color(0xFF3F51B5),
        elevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Tambah Aset',
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSummaryCard(double invested, double current, double pl, bool isDarkMode) {
    final isProfit = pl >= 0;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3F51B5),
            Color(0xFF1A237E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'ESTIMASI NILAI ASET',
            style: GoogleFonts.quicksand(
              color: Colors.white.withOpacity(0.65),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatRupiah(current),
              style: GoogleFonts.quicksand(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Total Modal',
                        style: GoogleFonts.quicksand(
                          fontSize: 9,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatRupiah(invested),
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.white.withOpacity(0.08),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        isProfit ? 'Total Profit' : 'Total Loss',
                        style: GoogleFonts.quicksand(
                          fontSize: 9,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isProfit ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                            color: isProfit ? Colors.greenAccent.shade200 : Colors.redAccent.shade100,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatRupiah(pl.abs()),
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isProfit ? Colors.greenAccent.shade200 : Colors.redAccent.shade100,
                            ),
                          ),
                        ],
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

  Widget _buildInvestmentItem(InvestmentModel item, bool isDarkMode) {
    final isProfit = item.profitLoss >= 0;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    // Premium dynamic coloring for contrast
    final accentColor = isProfit 
        ? (isDarkMode ? Colors.greenAccent : Colors.green.shade700)
        : (isDarkMode ? Colors.redAccent : Colors.red.shade700);

    final tagBgColor = isProfit 
        ? (isDarkMode ? Colors.greenAccent.withOpacity(0.12) : Colors.green.withOpacity(0.08))
        : (isDarkMode ? Colors.redAccent.withOpacity(0.12) : Colors.red.withOpacity(0.08));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.02) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3F51B5).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.pie_chart_outline_rounded,
                  color: Color(0xFF3F51B5),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.assetName, 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w800, 
                    fontSize: 13, 
                    color: contentColor,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded, 
                  size: 18, 
                  color: contentColor.withOpacity(0.4),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDarkMode ? Colors.white10 : Colors.grey.shade100,
                    width: 1,
                  ),
                ),
                color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                elevation: 4,
                onSelected: (value) {
                  if (value == 'edit') _showEditInvestmentSheet(item, isDarkMode);
                  if (value == 'delete') {
                    _deleteInvestmentConfirm(item);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_note_rounded, size: 18, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Update Valuasi', 
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold, 
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          'Hapus', 
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold, 
                            fontSize: 11, 
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCompactSubStat('Modal', _formatRupiah(item.totalInvested), isDarkMode),
              _buildCompactSubStat('Valuasi', _formatRupiah(item.currentValuation), isDarkMode),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'PROFIT/LOSS', 
                    style: GoogleFonts.quicksand(
                      fontSize: 8, 
                      color: contentColor.withOpacity(0.3), 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tagBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isProfit ? Icons.trending_up_rounded : Icons.trending_down_rounded, 
                          color: accentColor, 
                          size: 10,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${isProfit ? '+' : ''}${item.profitLossPercentage.toStringAsFixed(1)}%', 
                          style: GoogleFonts.quicksand(
                            color: accentColor, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSubStat(String label, String value, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(), 
          style: GoogleFonts.quicksand(
            fontSize: 8, 
            color: contentColor.withOpacity(0.3), 
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value, 
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold, 
            fontSize: 12, 
            color: contentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.query_stats_rounded, size: 64, color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05)),
            const SizedBox(height: 24),
            Text(
              'Belum ada portofolio investasi.', 
              style: GoogleFonts.quicksand(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteInvestmentConfirm(InvestmentModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Hapus Aset?',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Aset "${item.assetName}" akan dihapus dari portofolio secara permanen.',
          style: GoogleFonts.quicksand(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.quicksand(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Hapus',
              style: GoogleFonts.quicksand(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(investmentServiceProvider).deleteInvestment(item.id);
    }
  }

  void _showAddInvestmentSheet(bool isDarkMode) {
    final nameController = TextEditingController();
    final modalController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 16,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(color: isDarkMode ? Colors.white10 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'TAMBAH ASET INVESTASI', 
                style: GoogleFonts.quicksand(
                  fontSize: 12, 
                  fontWeight: FontWeight.w900, 
                  color: isDarkMode ? Colors.white : AppColors.primaryDark,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildCompactInput('Nama Aset / Instrumen', nameController, Icons.category_rounded, isDarkMode, isPremium: false),
            const SizedBox(height: 16),
            _buildCompactInput('Total Modal Investasi', modalController, Icons.account_balance_wallet_rounded, isDarkMode, isPremium: true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(modalController.text.replaceAll('.', '')) ?? 0;
                  if (nameController.text.isNotEmpty && amount > 0) {
                    final investment = InvestmentModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      assetName: nameController.text,
                      totalInvested: amount,
                      currentValuation: amount,
                      lastUpdated: DateTime.now(),
                    );
                    await ref.read(investmentServiceProvider).addInvestment(investment);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Aset Berhasil Disimpan', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
                          backgroundColor: const Color(0xFF3F51B5),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  'Simpan Portofolio', 
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditInvestmentSheet(InvestmentModel item, bool isDarkMode) {
    final valuationController = TextEditingController(text: item.currentValuation.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.'));
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 16,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(color: isDarkMode ? Colors.white10 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'UPDATE VALUASI', 
                style: GoogleFonts.quicksand(
                  fontSize: 12, 
                  fontWeight: FontWeight.w900, 
                  color: isDarkMode ? Colors.white : AppColors.primaryDark,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                item.assetName, 
                style: GoogleFonts.quicksand(
                  fontSize: 11, 
                  color: Colors.grey, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildCompactInput('Nilai Valuasi Terbaru', valuationController, Icons.update_rounded, isDarkMode, isPremium: true),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await ref.read(investmentServiceProvider).deleteInvestment(item.id);
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: const BorderSide(color: AppColors.error),
                      foregroundColor: AppColors.error,
                    ),
                    child: Text('Hapus', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final newValuation = double.tryParse(valuationController.text.replaceAll('.', '')) ?? 0;
                      final updatedItem = item.copyWith(
                        currentValuation: newValuation,
                        lastUpdated: DateTime.now(),
                      );
                      await ref.read(investmentServiceProvider).updateInvestment(updatedItem);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Valuasi Berhasil Diperbarui', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
                            backgroundColor: const Color(0xFF3F51B5),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF3F51B5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Update Nilai', 
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactInput(String label, TextEditingController controller, IconData icon, bool isDarkMode, {required bool isPremium}) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label, 
            style: GoogleFonts.quicksand(
              fontSize: 10, 
              fontWeight: FontWeight.bold, 
              color: isDarkMode ? Colors.white.withOpacity(0.6) : Colors.black54,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: isPremium ? TextInputType.number : TextInputType.text,
          inputFormatters: isPremium ? [_RibuanFormatter()] : null,
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
          decoration: InputDecoration(
            hintText: isPremium ? '0' : 'Masukkan nama aset...',
            hintStyle: GoogleFonts.quicksand(
              fontSize: 13, 
              color: isDarkMode ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.25),
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: const Color(0xFF3F51B5), size: 18),
                  if (isPremium) ...[
                    const SizedBox(width: 8),
                    Text('Rp', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: const Color(0xFF3F51B5), fontSize: 13)),
                  ],
                ],
              ),
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
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
