
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/models/gold_investment_model.dart';
import 'package:tabunganku/services/gold_service.dart';
import 'package:google_fonts/google_fonts.dart';

class GoldSavingsPage extends ConsumerStatefulWidget {
  const GoldSavingsPage({super.key});

  @override
  ConsumerState<GoldSavingsPage> createState() => _GoldSavingsPageState();
}

class _GoldSavingsPageState extends ConsumerState<GoldSavingsPage> {
  final double buyPrice = 1250000;
  final double sellPrice = 1185000;
  final _amountController = TextEditingController();
  GoldTransactionType _selectedType = GoldTransactionType.buy;

  double get currentGoldPrice => 
      _selectedType == GoldTransactionType.sell ? sellPrice : buyPrice;

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(goldServiceProvider).watchTransactions();
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
        title: Text('Tabungan Emas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: contentColor)),
        centerTitle: true,
      ),
      body: StreamBuilder<List<GoldTransactionModel>>(
        stream: transactionsAsync,
        builder: (context, snapshot) {
          final txs = snapshot.data ?? [];
          final totalGrams = ref.read(goldServiceProvider).calculateTotalGrams(txs);
          final avgPrice = ref.read(goldServiceProvider).calculateAveragePrice(txs);
          final currentValue = totalGrams * currentGoldPrice;
          final totalInvestment = totalGrams * avgPrice;
          final profitLoss = currentValue - totalInvestment;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPortfolioCard(totalGrams, currentValue, profitLoss, isDarkMode),
                const SizedBox(height: 32),
                
                 _buildPriceCard(currentGoldPrice, isDarkMode),
                const SizedBox(height: 32),

                _buildInlineInputForm(isDarkMode),
                const SizedBox(height: 32),

                Text('RIWAYAT TRANSAKSI', 
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: contentColor.withValues(alpha: 0.4))),
                const SizedBox(height: 16),
                if (txs.isEmpty)
                   _buildEmptyState(isDarkMode)
                else
                  ...txs.reversed.map((tx) => _buildTransactionItem(tx, isDarkMode)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInlineInputForm(bool isDarkMode) {
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildCompactTypeToggle(GoldTransactionType.buy, 'Beli', Icons.add_shopping_cart_rounded, isDarkMode),
              const SizedBox(width: 8),
              _buildCompactTypeToggle(GoldTransactionType.sell, 'Jual', Icons.sell_rounded, isDarkMode),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              _buildHighVisInput(
                controller: _amountController,
                icon: Icons.payments_rounded,
                label: 'Nominal Transaksi',
                unit: 'Rp',
                color: Colors.amber,
                isDarkMode: isDarkMode,
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _amountController,
                builder: (context, value, child) {
                  final amount = double.tryParse(value.text.replaceAll('.', '')) ?? 0;
                  final estGrams = amount / currentGoldPrice;
                  if (amount <= 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.scale_rounded, size: 14, color: Colors.amber),
                        const SizedBox(width: 8),
                        Text(
                          'Estimasi Emas: ${estGrams.toStringAsFixed(4)} gram',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white70 : Colors.teal.shade900.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final amount = double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
                    if (amount > 0) {
                      final grams = amount / currentGoldPrice;
                      final tx = GoldTransactionModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        grams: grams,
                        pricePerGram: currentGoldPrice,
                        date: DateTime.now(),
                        type: _selectedType,
                      );
                      await ref.read(goldServiceProvider).addTransaction(tx);
                      _amountController.clear();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Transaksi Berhasil Disimpan'),
                            backgroundColor: Colors.amber,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Simpan Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTypeToggle(GoldTransactionType type, String label, IconData icon, bool isDarkMode) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.amber.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? Colors.amber : (isDarkMode ? Colors.white10 : Colors.grey.shade300)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.amber : Colors.grey, size: 16),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.amber : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighVisInput({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String unit,
    required Color color,
    required bool isDarkMode,
  }) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [_RibuanFormatter()],
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: contentColor),
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        hintText: '0',
        hintStyle: TextStyle(
            fontSize: 18,
            color: isDarkMode ? Colors.white10 : Colors.black38),
        prefixIcon: Container(
          padding: const EdgeInsets.only(left: 20, right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(unit, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
            ],
          ),
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.03) : AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }


  Widget _buildPortfolioCard(double grams, double value, double pl, bool isDarkMode) {
    final isProfit = pl >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: const Color(0xFFDAA520).withValues(alpha: 0.4), blurRadius: 25, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        children: [
          const Text('TOTAL SALDO EMAS', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('${grams.toStringAsFixed(3)} g', 
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: -1)),
          ),
          const SizedBox(height: 8),
          Text(_formatRupiah(value), 
            style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isProfit ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  '${isProfit ? 'Profit' : 'Loss'}: ${_formatRupiah(pl.abs())}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(double price, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.auto_graph_rounded, color: Colors.amber, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedType == GoldTransactionType.buy ? 'Harga Beli Hari Ini' : 'Harga Jual Hari Ini',
                  style: TextStyle(color: contentColor.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('${_formatRupiah(price)} /gram', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: contentColor)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Text('+1.25%', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _deleteGoldTransaction(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus Transaksi?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Data transaksi emas ini akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(goldServiceProvider).deleteTransaction(id);
    }
  }

  void _showEditGoldTransactionSheet(GoldTransactionModel tx, bool isDarkMode) {
    final amountController = TextEditingController(text: (tx.grams * tx.pricePerGram).toInt().toString());
    GoldTransactionType type = tx.type;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            top: 24,
            left: 28,
            right: 28,
          ),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: isDarkMode ? Colors.white10 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text('UBAH TRANSAKSI EMAS', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.teal.shade900)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildTypeOption(GoldTransactionType.buy, 'Beli', Icons.add_circle_outline_rounded, type, (v) => setSheetState(() => type = v), isDarkMode)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTypeOption(GoldTransactionType.sell, 'Jual', Icons.remove_circle_outline_rounded, type, (v) => setSheetState(() => type = v), isDarkMode)),
                ],
              ),
              const SizedBox(height: 24),
              _buildCompactInput('Nominal Transaksi (Rp)', amountController, Icons.payments_rounded, isDarkMode, 'Rp'),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: amountController,
                builder: (context, value, child) {
                  final amount = double.tryParse(value.text.replaceAll('.', '')) ?? 0;
                  final estGrams = amount / currentGoldPrice;
                  if (amount <= 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Center(
                      child: Text(
                        'Estimasi: ${estGrams.toStringAsFixed(4)} gram',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white38 : Colors.teal.shade900.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text.replaceAll('.', '')) ?? 0;
                    if (amount > 0) {
                      final grams = amount / currentGoldPrice;
                      final updatedTx = tx.copyWith(
                        grams: grams,
                        type: type,
                      );
                      await ref.read(goldServiceProvider).updateTransaction(updatedTx);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(GoldTransactionModel tx, bool isDarkMode) {
    final isBuy = tx.type == GoldTransactionType.buy;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.02) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isBuy ? Colors.green : Colors.red).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(isBuy ? Icons.add_business_rounded : Icons.sell_rounded, color: isBuy ? Colors.green : Colors.red, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isBuy ? 'Pembelian Emas' : 'Penjualan Emas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: contentColor)),
                Text(DateFormat('d MMMM yyyy').format(tx.date), style: TextStyle(color: contentColor.withValues(alpha: 0.4), fontSize: 10)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${isBuy ? '+' : '-'}${tx.grams.toStringAsFixed(3)} g', 
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15, color: isBuy ? Colors.green : Colors.red)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_note_rounded, size: 18, color: contentColor.withValues(alpha: 0.3)),
                    onPressed: () => _showEditGoldTransactionSheet(tx, isDarkMode),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded, size: 16, color: contentColor.withValues(alpha: 0.2)),
                    onPressed: () => _deleteGoldTransaction(tx.id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.history_toggle_off_rounded, size: 64, color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            const SizedBox(height: 24),
            const Text('Belum ada riwayat transaksi.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }


  Widget _buildTypeOption(GoldTransactionType value, String label, IconData icon, GoldTransactionType selected, Function(GoldTransactionType) onTap, bool isDarkMode) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : (isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.background),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactInput(String label, TextEditingController controller, IconData icon, bool isDarkMode, String unit) {
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: contentColor),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(fontSize: 18, color: isDarkMode ? Colors.white10 : Colors.teal.shade50),
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 20, right: 8),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            suffixText: unit,
            suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 15),
            filled: true,
            fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
    final intValue = int.tryParse(newValue.text.replaceAll('.', ''));
    if (intValue == null) return oldValue;
    final newText = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    ).format(intValue).trim();
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
