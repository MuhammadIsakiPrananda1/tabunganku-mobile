/// Page: GoldSavingsPage
///
/// Tabungan emas dan pelacakan nilai investasi fisik.
library;

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';
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

  double buyPrice = 1250000;
  double sellPrice = 1185000;
  double priceChange = 1.25;

  double get currentGoldPrice =>
      _selectedType == GoldTransactionType.sell ? sellPrice : buyPrice;

  @override
  void initState() {
    super.initState();
    _checkInternet();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
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
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
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
                          side: BorderSide(
                              color: isDarkMode
                                  ? Colors.white24
                                  : Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
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
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: contentColor, size: 20),
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
        actions: [
          IconButton(
            tooltip: 'Tambah Transaksi',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded,
                  color: Color(0xFFD4AF37), size: 20),
            ),
            onPressed: () => _showTransactionSheet(isDarkMode: isDarkMode),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<GoldTransactionModel>>(
        stream: transactionsAsync,
        builder: (context, snapshot) {
          final txs = snapshot.data ?? [];
          final totalGrams =
              ref.read(goldServiceProvider).calculateTotalGrams(txs);
          final avgPrice =
              ref.read(goldServiceProvider).calculateAveragePrice(txs);
          final currentValue = totalGrams * buyPrice;
          final totalInvestment = totalGrams * avgPrice;
          final profitLoss = currentValue - totalInvestment;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Premium Gold Ingot Card
                _buildPortfolioCard(
                    totalGrams, currentValue, avgPrice, profitLoss, isDarkMode),
                const SizedBox(height: 16),

                // 2. Real-time Live Price Ticker
                _buildRealtimePriceCard(isDarkMode),
                const SizedBox(height: 20),

                // 3. Quick Action Buttons (Beli / Jual Cepat)
                _buildQuickActionsRow(isDarkMode),
                const SizedBox(height: 24),

                // 4. Transaction History Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Riwayat Transaksi Emas',
                      style: GoogleFonts.quicksand(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: contentColor,
                      ),
                    ),
                    if (txs.isNotEmpty)
                      Text(
                        '${txs.length} Transaksi',
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // 5. Transaction List
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                      ),
                    ),
                  )
                else if (txs.isEmpty)
                  _buildEmptyState(isDarkMode)
                else
                  ...txs.reversed
                      .map((tx) => _buildTransactionItem(tx, isDarkMode)),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPortfolioCard(double grams, double value, double avgPrice,
      double pl, bool isDarkMode) {
    final isProfit = pl >= 0;
    final returnPercent = (grams > 0 && avgPrice > 0)
        ? ((buyPrice - avgPrice) / avgPrice) * 100
        : 0.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF7C04A),
            Color(0xFFE89A24),
            Color(0xFFC47B16),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC47B16).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle decorative watermark icon
          Positioned(
            right: -15,
            bottom: -20,
            child: Icon(
              Icons.monetization_on_rounded,
              size: 150,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded,
                              color: Colors.white, size: 13),
                          const SizedBox(width: 5),
                          Text(
                            'Emas Batangan 24 Karat',
                            style: GoogleFonts.quicksand(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isProfit
                            ? Colors.black.withValues(alpha: 0.25)
                            : Colors.red.shade900.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isProfit
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            color: isProfit
                                ? Colors.greenAccent.shade100
                                : Colors.redAccent.shade100,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isProfit ? '+' : ''}${returnPercent.toStringAsFixed(1)}%',
                            style: GoogleFonts.quicksand(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Main Grams Display
                Text(
                  'Total Simpanan Emas',
                  style: GoogleFonts.quicksand(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      grams.toStringAsFixed(4),
                      style: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'gram',
                      style: GoogleFonts.quicksand(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 2-Column Glassmorphism Pill (Valuasi & Keuntungan)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimasi Nilai Saat Ini',
                              style: GoogleFonts.quicksand(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatRupiah(value),
                              style: GoogleFonts.quicksand(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isProfit ? 'Total Keuntungan' : 'Total Penurunan',
                              style: GoogleFonts.quicksand(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${isProfit ? '+' : '-'}${_formatRupiah(pl.abs())}',
                              style: GoogleFonts.quicksand(
                                color: isProfit
                                    ? Colors.greenAccent.shade100
                                    : Colors.redAccent.shade100,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
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
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimePriceCard(bool isDarkMode) {
    final priceAsync = ref.watch(goldPriceProvider);
    final cardBgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return priceAsync.when(
      data: (prices) {
        buyPrice = prices['buy'] ?? buyPrice;
        sellPrice = prices['sell'] ?? sellPrice;
        priceChange = prices['change'] ?? priceChange;
        final spread = buyPrice - sellPrice;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.04),
                blurRadius: 12,
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
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF4CAF50),
                              blurRadius: 6,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'HARGA LIVE HARI INI',
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isDarkMode
                              ? Colors.white70
                              : AppColors.primaryDark,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${priceChange >= 0 ? '+' : ''}${priceChange.toStringAsFixed(2)}% 24h',
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

              // 2 Equal columns: Beli & Jual
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.green.withValues(alpha: 0.08)
                            : Colors.green.shade50.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.green.shade100,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.arrow_downward_rounded,
                                  size: 13, color: Colors.green.shade600),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'HARGA BELI',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white60
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _formatRupiah(buyPrice),
                              style: GoogleFonts.quicksand(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: isDarkMode
                                    ? Colors.greenAccent
                                    : Colors.green.shade700,
                              ),
                            ),
                          ),
                          Text(
                            '/gram',
                            style: GoogleFonts.quicksand(
                              fontSize: 9,
                              color: isDarkMode
                                  ? Colors.white38
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.orange.withValues(alpha: 0.08)
                            : Colors.orange.shade50.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.orange.withValues(alpha: 0.2)
                              : Colors.orange.shade100,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.arrow_upward_rounded,
                                  size: 13, color: Colors.orange.shade700),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'HARGA JUAL',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white60
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _formatRupiah(sellPrice),
                              style: GoogleFonts.quicksand(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: isDarkMode
                                    ? Colors.orangeAccent
                                    : Colors.orange.shade800,
                              ),
                            ),
                          ),
                          Text(
                            '/gram',
                            style: GoogleFonts.quicksand(
                              fontSize: 9,
                              color: isDarkMode
                                  ? Colors.white38
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Selisih Spread Info Chip
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Selisih Spread: ${_formatRupiah(spread)}/g',
                    style: GoogleFonts.quicksand(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white38 : Colors.grey.shade600,
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
      height: 90,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
        ),
      ),
    );
  }

  Widget _buildQuickActionsRow(bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() => _selectedType = GoldTransactionType.buy);
              _showTransactionSheet(isDarkMode: isDarkMode);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_shopping_cart_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Beli Emas',
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() => _selectedType = GoldTransactionType.sell);
              _showTransactionSheet(isDarkMode: isDarkMode);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.orange.shade800,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sell_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Jual Emas',
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _deleteGoldTransaction(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : Colors.white,
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
              style: GoogleFonts.quicksand(
                  color: Colors.grey.shade600, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Hapus',
              style: GoogleFonts.quicksand(
                  color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(goldServiceProvider).deleteTransaction(id);
    }
  }

  void _showTransactionSheet(
      {GoldTransactionModel? tx, required bool isDarkMode}) {
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
          final accentColor =
              isBuy ? Colors.green.shade600 : Colors.orange.shade800;

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              top: 20,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    isEdit ? 'Ubah Transaksi Emas' : 'Catat Transaksi Emas',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Segmented Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setSheetState(
                                () => type = GoldTransactionType.buy);
                            if (!isEdit) {
                              setState(
                                  () => _selectedType = GoldTransactionType.buy);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: type == GoldTransactionType.buy
                                  ? Colors.green.shade600
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_shopping_cart_rounded,
                                  color: type == GoldTransactionType.buy
                                      ? Colors.white
                                      : Colors.grey,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Beli Emas',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: type == GoldTransactionType.buy
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setSheetState(
                                () => type = GoldTransactionType.sell);
                            if (!isEdit) {
                              setState(
                                  () => _selectedType = GoldTransactionType.sell);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: type == GoldTransactionType.sell
                                  ? Colors.orange.shade800
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sell_rounded,
                                  color: type == GoldTransactionType.sell
                                      ? Colors.white
                                      : Colors.grey,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Jual Emas',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: type == GoldTransactionType.sell
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Amount Input
                _buildCompactInput(
                  'Nominal Transaksi (Rp)',
                  amountController,
                  Icons.payments_rounded,
                  isDarkMode,
                  'Rp',
                  color: accentColor,
                ),

                // Live Gram Calculation Preview
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: amountController,
                  builder: (context, value, child) {
                    final amount = double.tryParse(
                            value.text.replaceAll(RegExp(r'[^\d]'), '')) ??
                        0;
                    final priceForCalculation =
                        type == GoldTransactionType.sell ? sellPrice : buyPrice;
                    final estGrams = amount / priceForCalculation;
                    if (amount <= 0) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: accentColor.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.scale_rounded,
                              size: 18, color: accentColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Estimasi Emas: ${estGrams.toStringAsFixed(4)} gram (@ ${_formatRupiah(priceForCalculation)}/g)',
                              style: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? Colors.white
                                    : accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final amount = double.tryParse(
                              amountController.text.replaceAll(RegExp(r'[^\d]'), '')) ??
                          0;
                      if (amount > 0) {
                        final priceForCalculation =
                            type == GoldTransactionType.sell
                                ? sellPrice
                                : buyPrice;
                        final grams = amount / priceForCalculation;

                        if (isEdit) {
                          final updatedTx = tx.copyWith(
                            grams: grams,
                            pricePerGram: priceForCalculation,
                            type: type,
                          );
                          await ref
                              .read(goldServiceProvider)
                              .updateTransaction(updatedTx);
                        } else {
                          final newTx = GoldTransactionModel(
                            id: const Uuid().v4(),
                            grams: grams,
                            pricePerGram: priceForCalculation,
                            date: DateTime.now(),
                            type: type,
                          );
                          await ref
                              .read(goldServiceProvider)
                              .addTransaction(newTx);
                        }

                        if (context.mounted) {
                          Navigator.pop(context);
                          showTopToast(
                              context,
                              isEdit
                                  ? 'Transaksi Berhasil Diubah'
                                  : 'Transaksi Berhasil Disimpan');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      isEdit ? 'Simpan Perubahan' : 'Simpan Transaksi',
                      style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold, fontSize: 14),
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
    final cardBgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    final accentColor = isBuy
        ? (isDarkMode ? Colors.greenAccent : Colors.green.shade700)
        : (isDarkMode ? Colors.orangeAccent : Colors.orange.shade800);

    final iconBgColor = isBuy
        ? Colors.green.withValues(alpha: 0.12)
        : Colors.orange.withValues(alpha: 0.12);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isBuy ? Icons.add_shopping_cart_rounded : Icons.sell_rounded,
              color: accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
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
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: contentColor,
                      ),
                    ),
                    Text(
                      '${isBuy ? '+' : '-'}${tx.grams.toStringAsFixed(4)} g',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatRupiah(tx.grams * tx.pricePerGram),
                      style: GoogleFonts.quicksand(
                        color: isDarkMode
                            ? Colors.white70
                            : AppColors.primaryDark.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateFormat('d MMM yyyy').format(tx.date),
                      style: GoogleFonts.quicksand(
                        color: isDarkMode ? Colors.white38 : Colors.black38,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              size: 20,
              color: contentColor.withValues(alpha: 0.4),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
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
                    const Icon(Icons.edit_note_rounded,
                        size: 18, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Ubah',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded,
                        size: 18, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'Hapus',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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

  Widget _buildCompactInput(String label, TextEditingController controller,
      IconData icon, bool isDarkMode, String unit,
      {Color? color}) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final accentColor = color ?? AppColors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? Colors.white70
                  : Colors.black87,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [_RibuanFormatter()],
          style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold, fontSize: 14, color: contentColor),
          decoration: InputDecoration(
            hintText: 'Masukkan Nominal',
            hintStyle: GoogleFonts.quicksand(
              fontSize: 13,
              color: isDarkMode
                  ? Colors.white30
                  : Colors.black26,
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 14, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: accentColor, size: 20),
                  const SizedBox(width: 6),
                  Text(unit,
                      style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          fontSize: 13)),
                ],
              ),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: isDarkMode
                ? Colors.white.withValues(alpha: 0.05)
                : AppColors.background,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.monetization_on_outlined,
                  size: 48, color: Color(0xFFD4AF37)),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada riwayat transaksi emas.',
              style: GoogleFonts.quicksand(
                  color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Tekan tombol Beli Emas di atas untuk mulai mencatat.',
              style: GoogleFonts.quicksand(
                  color: isDarkMode ? Colors.white38 : Colors.grey.shade400,
                  fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
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

