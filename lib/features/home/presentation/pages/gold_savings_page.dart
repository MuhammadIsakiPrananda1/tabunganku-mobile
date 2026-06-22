import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/models/gold_investment_model.dart';
import 'package:tabunganku/services/gold_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'dart:ui';

class GoldSavingsPage extends ConsumerStatefulWidget {
  const GoldSavingsPage({super.key});

  @override
  ConsumerState<GoldSavingsPage> createState() => _GoldSavingsPageState();
}

class _GoldSavingsPageState extends ConsumerState<GoldSavingsPage> {
  final _amountController = TextEditingController();
  GoldTransactionType _selectedType = GoldTransactionType.buy;

  bool _isNoInternetDialogShowing = false;
  BuildContext? _dialogContext;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkInternet();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.none)) {
        _showNoInternetPopup();
      } else {
        _dismissNoInternetPopup();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _checkInternet() async {
    final results = await Connectivity().checkConnectivity();
    if (results.contains(ConnectivityResult.none) && mounted) {
      _showNoInternetPopup();
    }
  }

  void _showNoInternetPopup() {
    if (_isNoInternetDialogShowing) return;
    _isNoInternetDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (dialogCtx) {
        _dialogContext = dialogCtx;
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              _dismissNoInternetPopup();
              Navigator.of(context).pop();
            },
            child: AlertDialog(
              backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              content: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC48E2E)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Koneksi Terputus',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sambungkan ke internet untuk memperbarui harga emas live dan memproses data.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () {
                          _dismissNoInternetPopup();
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isDarkMode ? Colors.white24 : Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Kembali',
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      _isNoInternetDialogShowing = false;
      _dialogContext = null;
    });
  }

  void _dismissNoInternetPopup() {
    if (_isNoInternetDialogShowing && _dialogContext != null) {
      Navigator.of(_dialogContext!).pop();
      _isNoInternetDialogShowing = false;
      _dialogContext = null;
    }
  }

double buyPrice = 1250000;
  double sellPrice = 1185000;
  double priceChange = 1.25;

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
          onPressed: () {
            _dismissNoInternetPopup();
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: contentColor, size: 20),
        ),
        title: Text(
          'Tabungan Emas',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: contentColor,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<GoldTransactionModel>>(
        stream: transactionsAsync,
        builder: (context, snapshot) {
          final txs = snapshot.data ?? [];
          final totalGrams = ref.read(goldServiceProvider).calculateTotalGrams(txs);
          final avgPrice = ref.read(goldServiceProvider).calculateAveragePrice(txs);
          final currentValue = totalGrams * buyPrice;
          final totalInvestment = totalGrams * avgPrice;
          final profitLoss = currentValue - totalInvestment;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPortfolioCard(totalGrams, currentValue, profitLoss, isDarkMode),
                const SizedBox(height: 16),
                _buildRealtimePriceCard(isDarkMode),
                const SizedBox(height: 24),
                Text(
                  'RIWAYAT TRANSAKSI',
                  style: GoogleFonts.quicksand(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: contentColor.withOpacity(0.35),
                  ),
                ),
                const SizedBox(height: 12),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDAA520)),
                      ),
                    ),
                  )
                else if (txs.isEmpty)
                  _buildEmptyState(isDarkMode)
                else
                  ...txs.reversed.map((tx) => _buildTransactionItem(tx, isDarkMode)),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTransactionSheet(isDarkMode: isDarkMode),
        backgroundColor: const Color(0xFFC48E2E),
        elevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Tambah Transaksi',
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

  Widget _buildPortfolioCard(double grams, double value, double pl, bool isDarkMode) {
    final isProfit = pl >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE5A93B),
            Color(0xFFC48E2E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'TOTAL SALDO EMAS',
            style: GoogleFonts.quicksand(
              color: Colors.white.withOpacity(0.65),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                grams.toStringAsFixed(4),
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'g',
                style: GoogleFonts.quicksand(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            _formatRupiah(value),
            style: GoogleFonts.quicksand(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isProfit ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  color: isProfit ? Colors.greenAccent.shade200 : Colors.redAccent.shade100,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  '${isProfit ? 'Profit' : 'Loss'}: ${_formatRupiah(pl.abs())}',
                  style: GoogleFonts.quicksand(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimePriceCard(bool isDarkMode) {
    final priceAsync = ref.watch(goldPriceProvider);
    final cardBgColor = isDarkMode ? AppColors.surfaceDark : Colors.white;

    return priceAsync.when(
      data: (prices) {
        buyPrice = prices['buy'] ?? buyPrice;
        sellPrice = prices['sell'] ?? sellPrice;
        priceChange = prices['change'] ?? priceChange;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDarkMode ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green,
                              blurRadius: 4,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'LIVE HARGA EMAS HARI INI',
                        style: GoogleFonts.quicksand(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isDarkMode ? Colors.white.withValues(alpha: 0.5) : AppColors.primaryDark.withValues(alpha: 0.5),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC48E2E).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${priceChange > 0 ? '+' : ''}${priceChange.toStringAsFixed(2)}%',
                      style: GoogleFonts.quicksand(
                        color: const Color(0xFFC48E2E),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.green.withValues(alpha: 0.05) : Colors.green.shade50.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode ? Colors.green.withValues(alpha: 0.15) : Colors.green.shade100,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 12,
                                color: isDarkMode ? Colors.greenAccent : Colors.green.shade700,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'HARGA BELI',
                                style: GoogleFonts.quicksand(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white38 : Colors.grey.shade600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _formatRupiah(buyPrice),
                              style: GoogleFonts.quicksand(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isDarkMode ? Colors.greenAccent : Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.red.withValues(alpha: 0.05) : Colors.red.shade50.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode ? Colors.red.withValues(alpha: 0.15) : Colors.red.shade100,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.sell_rounded,
                                size: 12,
                                color: isDarkMode ? Colors.redAccent : Colors.red.shade700,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'HARGA JUAL',
                                style: GoogleFonts.quicksand(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white38 : Colors.grey.shade600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _formatRupiah(sellPrice),
                              style: GoogleFonts.quicksand(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isDarkMode ? Colors.redAccent : Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => _buildPriceLoading(isDarkMode),
      error: (_, __) => _buildPriceLoading(isDarkMode),
    );
  }

  Widget _buildPriceLoading(bool isDarkMode) {
    return Container(
      height: 42,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  void _deleteGoldTransaction(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Hapus Transaksi?',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Data transaksi emas ini akan dihapus secara permanen.',
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
      await ref.read(goldServiceProvider).deleteTransaction(id);
    }
  }

  void _showTransactionSheet({GoldTransactionModel? tx, required bool isDarkMode}) {
    final isEdit = tx != null;
    final initialAmount = isEdit ? (tx.grams * tx.pricePerGram).toInt() : 0;
    
    final amountController = TextEditingController(
      text: isEdit 
          ? NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0)
              .format(initialAmount)
              .trim()
          : '',
    );
    GoldTransactionType type = isEdit ? tx.type : _selectedType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final isBuy = type == GoldTransactionType.buy;
          final accentColor = isBuy ? Colors.green.shade600 : Colors.red.shade600;

          return Container(
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
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white10 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    isEdit ? 'UBAH TRANSAKSI EMAS' : 'TAMBAH TRANSAKSI EMAS',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isDarkMode ? Colors.white : AppColors.primaryDark,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setSheetState(() => type = GoldTransactionType.buy);
                          if (!isEdit) setState(() => _selectedType = GoldTransactionType.buy);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: type == GoldTransactionType.buy
                                ? Colors.green.shade600
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: type == GoldTransactionType.buy
                                  ? Colors.green.shade600
                                  : (isDarkMode ? Colors.white10 : Colors.grey.shade300),
                              width: type == GoldTransactionType.buy ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_shopping_cart_rounded,
                                color: type == GoldTransactionType.buy ? Colors.white : Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Beli Emas',
                                style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: type == GoldTransactionType.buy ? Colors.white : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setSheetState(() => type = GoldTransactionType.sell);
                          if (!isEdit) setState(() => _selectedType = GoldTransactionType.sell);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: type == GoldTransactionType.sell
                                ? Colors.red.shade600
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: type == GoldTransactionType.sell
                                  ? Colors.red.shade600
                                  : (isDarkMode ? Colors.white10 : Colors.grey.shade300),
                              width: type == GoldTransactionType.sell ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.sell_rounded,
                                color: type == GoldTransactionType.sell ? Colors.white : Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Jual Emas',
                                style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: type == GoldTransactionType.sell ? Colors.white : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildCompactInput(
                  'Nominal Transaksi (Rp)',
                  amountController,
                  Icons.payments_rounded,
                  isDarkMode,
                  'Rp',
                  color: accentColor,
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: amountController,
                  builder: (context, value, child) {
                    final amount = double.tryParse(value.text.replaceAll('.', '')) ?? 0;
                    final priceForCalculation = type == GoldTransactionType.sell ? sellPrice : buyPrice;
                    final estGrams = amount / priceForCalculation;
                    if (amount <= 0) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.scale_rounded, size: 14, color: accentColor),
                          const SizedBox(width: 8),
                          Text(
                            'Estimasi Emas: ${estGrams.toStringAsFixed(4)} gram',
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white70 : accentColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      final amount = double.tryParse(amountController.text.replaceAll('.', '')) ?? 0;
                      if (amount > 0) {
                        final priceForCalculation = type == GoldTransactionType.sell ? sellPrice : buyPrice;
                        final grams = amount / priceForCalculation;
                        
                        if (isEdit) {
                          final updatedTx = tx.copyWith(
                            grams: grams,
                            pricePerGram: priceForCalculation,
                            type: type,
                          );
                          await ref.read(goldServiceProvider).updateTransaction(updatedTx);
                        } else {
                          final newTx = GoldTransactionModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            grams: grams,
                            pricePerGram: priceForCalculation,
                            date: DateTime.now(),
                            type: type,
                          );
                          await ref.read(goldServiceProvider).addTransaction(newTx);
                        }
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEdit ? 'Transaksi Berhasil Diubah' : 'Transaksi Berhasil Disimpan',
                                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: const Color(0xFFDAA520),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      isEdit ? 'Simpan Perubahan' : 'Simpan Transaksi',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(GoldTransactionModel tx, bool isDarkMode) {
    final isBuy = tx.type == GoldTransactionType.buy;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

final accentColor = isBuy 
        ? (isDarkMode ? Colors.greenAccent : Colors.green.shade700)
        : (isDarkMode ? Colors.redAccent : Colors.red.shade700);

    final iconBgColor = isBuy 
        ? (isDarkMode ? Colors.greenAccent.withOpacity(0.12) : Colors.green.withOpacity(0.08))
        : (isDarkMode ? Colors.redAccent.withOpacity(0.12) : Colors.red.withOpacity(0.08));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.02) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isBuy ? Icons.add_shopping_cart_rounded : Icons.sell_rounded,
              color: accentColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isBuy ? 'Beli Emas' : 'Jual Emas',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: contentColor,
                      ),
                    ),
                    Text(
                      '${isBuy ? '+' : '-'}${tx.grams.toStringAsFixed(4)} g',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatRupiah(tx.grams * tx.pricePerGram),
                      style: GoogleFonts.quicksand(
                        color: isDarkMode ? Colors.white70 : AppColors.primaryDark.withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('d MMM yyyy').format(tx.date),
                      style: GoogleFonts.quicksand(
                        color: isDarkMode ? Colors.white30 : Colors.black38,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
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
              if (value == 'edit') {
                _showTransactionSheet(tx: tx, isDarkMode: isDarkMode);
              }
              if (value == 'delete') {
                _deleteGoldTransaction(tx.id);
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
                      'Ubah',
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
    );
  }

  Widget _buildCompactInput(String label, TextEditingController controller, IconData icon, bool isDarkMode, String unit, {Color? color}) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final accentColor = color ?? AppColors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [_RibuanFormatter()],
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
          decoration: InputDecoration(
            hintText: 'Masukkan Nominal',
            hintStyle: GoogleFonts.quicksand(
              fontSize: 13, 
              color: isDarkMode ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.25),
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 12, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: accentColor, size: 18),
                  const SizedBox(width: 4),
                  Text(unit, style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: accentColor, fontSize: 13)),
                ],
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.only(left: 0, right: 16, top: 14, bottom: 14),
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
            Icon(Icons.history_toggle_off_rounded, size: 64, color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05)),
            const SizedBox(height: 24),
            Text(
              'Belum ada riwayat transaksi.',
              style: GoogleFonts.quicksand(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
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
