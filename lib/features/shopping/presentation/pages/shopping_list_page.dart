import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/models/shopping_item_model.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/shopping_item_provider.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'dart:ui';
import '../widgets/shopping_form_sheet.dart';

class ShoppingListPage extends ConsumerStatefulWidget {
  const ShoppingListPage({super.key});

  @override
  ConsumerState<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends ConsumerState<ShoppingListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    _searchController.dispose();
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
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
                      'Sambungkan ke internet untuk memuat gambar belanja dari server dan mengelola data.',
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

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  Future<void> _toggleBoughtStatus(ShoppingItem item) async {
    final nowBought = !item.isBought;
    final txId = 'shopping_${item.id}';

    if (nowBought) {
      // Buat transaksi pengeluaran otomatis
      final transaction = TransactionModel(
        id: txId,
        title: item.name,
        description: 'Belanja ${item.quantity.toString().replaceAll('.0', '')} ${item.unit}',
        amount: item.estimatedPrice,
        type: TransactionType.expense,
        date: DateTime.now(),
        category: item.category != null && item.category!.trim().isNotEmpty
            ? item.category!.trim()
            : 'Belanja Bulanan',
      );
      await ref.read(transactionServiceProvider).addTransaction(transaction);
    } else {
      // Hapus transaksi terkait jika di-uncheck
      try {
        await ref.read(transactionServiceProvider).deleteTransaction(txId);
      } catch (_) {}
    }

    final updated = item.copyWith(
      isBought: nowBought,
      linkedTransactionId: nowBought ? txId : null,
    );
    await ref.read(shoppingItemServiceProvider).updateItem(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nowBought 
                ? '"${item.name}" ditandai sudah dibeli & dicatat ke pengeluaran!'
                : 'Batal membeli "${item.name}" & catatan pengeluaran dihapus.',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
          ),
          backgroundColor: nowBought ? AppColors.success : AppColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shoppingItemsAsync = ref.watch(shoppingItemsStreamProvider);
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    final pageBg = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF0F3F7);
    final txtClr = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar (Catatan Pinjaman style) ────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _dismissNoInternetPopup();
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 17,
                        color: isDarkMode ? Colors.white70 : AppColors.primaryDark),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  Expanded(
                    child: Text(
                      'Catatan Belanja',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: txtClr),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ── Body content ───────────────────────────────────────────
            Expanded(
              child: shoppingItemsAsync.when(
                data: (items) {
                  final filteredItems = items.where((item) {
                    return item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        (item.category != null &&
                            item.category!.toLowerCase().contains(_searchQuery.toLowerCase()));
                  }).toList();

                  return Column(
                    children: [
                      _buildDashboardHeader(items, isDarkMode),
                      _buildSearchAndFilters(isDarkMode),
                      Expanded(
                        child: filteredItems.isEmpty
                            ? _buildEmptyState(isDarkMode, hasFilter: _searchQuery.isNotEmpty)
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                                itemCount: filteredItems.length,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final item = filteredItems[index];
                                  return _buildShoppingCard(context, ref, item, isDarkMode);
                                },
                              ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ShoppingFormSheet.show(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 8,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: Text('Tambah Rencana', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  Widget _buildDashboardHeader(List<ShoppingItem> items, bool isDarkMode) {
    final totalEstimated = items.fold<double>(0, (sum, item) => sum + item.estimatedPrice);
    final totalBought = items.where((i) => i.isBought).fold<double>(0, (sum, item) => sum + item.estimatedPrice);
    final remainingCost = totalEstimated - totalBought;
    
    final totalCount = items.length;
    final boughtCount = items.where((i) => i.isBought).length;
    final progress = totalCount > 0 ? boughtCount / totalCount : 0.0;

    final theme = Theme.of(context);
    final cardBg = isDarkMode ? theme.cardColor : Colors.white;
    final borderColor = isDarkMode 
        ? Colors.white.withValues(alpha: 0.08) 
        : Colors.black.withValues(alpha: 0.05);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 2, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: isDarkMode 
            ? [] 
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Title & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL ANGGARAN BELANJA',
                    style: GoogleFonts.quicksand(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatRupiah(totalEstimated),
                    style: GoogleFonts.quicksand(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDarkMode ? Colors.white : AppColors.primaryDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: totalCount == 0 
                      ? (isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100)
                      : (progress >= 1.0 
                          ? Colors.green.withValues(alpha: 0.1) 
                          : AppColors.primary.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: totalCount == 0 
                        ? (isDarkMode ? Colors.white10 : Colors.grey.shade300)
                        : (progress >= 1.0 
                            ? Colors.green.withValues(alpha: 0.2) 
                            : AppColors.primary.withValues(alpha: 0.2)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      totalCount == 0 
                          ? Icons.hourglass_empty_rounded 
                          : (progress >= 1.0 ? Icons.check_circle_rounded : Icons.cached_rounded),
                      color: totalCount == 0 
                          ? (isDarkMode ? Colors.white30 : Colors.grey.shade500)
                          : (progress >= 1.0 ? Colors.green : AppColors.primary),
                      size: 11,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      totalCount == 0 
                          ? 'Kosong' 
                          : '${(progress * 100).toInt()}% Selesai',
                      style: GoogleFonts.quicksand(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: totalCount == 0 
                            ? (isDarkMode ? Colors.white54 : Colors.grey.shade600)
                            : (progress >= 1.0 ? Colors.green : AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          
          // Row 2: Progress Text & Sleek Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progres Barang',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                ),
              ),
              Text(
                '$boughtCount dari $totalCount Barang',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: totalCount > 0 ? progress : 0.0,
              backgroundColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 20),
          
          // Divider
          Divider(
            height: 1, 
            color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
          ),
          const SizedBox(height: 16),

          // Row 3: Terbelanja & Sisa Anggaran (Minimalist Columns)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'TERBELANJA',
                          style: GoogleFonts.quicksand(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(totalBought),
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'SISA ANGGARAN',
                          style: GoogleFonts.quicksand(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(remainingCost),
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
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

  Widget _buildSearchAndFilters(bool isDarkMode) {
    return Column(
      children: [
        // Search Bar minimalis
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Cari rencana belanja atau kategori...',
                hintStyle: GoogleFonts.quicksand(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white30 : Colors.black38,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: Colors.grey, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 9),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildEmptyState(bool isDarkMode, {required bool hasFilter}) {
    return Center(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilter ? Icons.search_off_rounded : Icons.shopping_basket_outlined,
                size: 54,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilter ? 'Pencarian tidak ditemukan' : 'Belum ada rencana belanja',
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                hasFilter 
                    ? 'Coba gunakan kata kunci lain atau ubah filter kategori Anda.'
                    : 'Catat semua kebutuhan & keinginanmu agar pengeluaran lebih terencana!',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 11, 
                  color: isDarkMode ? Colors.white38 : Colors.black45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingCard(BuildContext context, WidgetRef ref, ShoppingItem item, bool isDarkMode) {
    final theme = Theme.of(context);
    final isBought = item.isBought;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isBought
            ? (isDarkMode ? Colors.white.withValues(alpha: 0.02) : Colors.grey.shade50)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBought
              ? (isDarkMode ? Colors.white.withValues(alpha: 0.02) : Colors.grey.shade200)
              : (isDarkMode ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100),
          width: 1.2,
        ),
        boxShadow: isBought 
            ? [] 
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.02),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showOptions(context, ref, item, isDarkMode),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 1. Direct Checkbox (Tactile Interactive Tap Area)
                GestureDetector(
                  onTap: () => _toggleBoughtStatus(item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    color: Colors.transparent, // Expand tap target
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isBought 
                            ? AppColors.primary 
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isBought 
                              ? AppColors.primary 
                              : (isDarkMode ? Colors.white30 : Colors.black26),
                          width: 2,
                        ),
                      ),
                      child: isBought
                          ? const Icon(Icons.check, color: Colors.white, size: 14)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 2. Photo / Image preview
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: isDarkMode ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: item.isOnline && item.url != null && item.url!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                item.url!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image_outlined, color: AppColors.primary, size: 20),
                              ),
                            )
                          : item.imagePath != null && item.imagePath!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(
                                    File(item.imagePath!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.shopping_bag_rounded, color: AppColors.primary, size: 20),
                                  ),
                                )
                              : const Icon(Icons.shopping_bag_rounded, color: AppColors.primary, size: 20),
                    ),
                    // Small storage indicator (Cloud / Phone)
                    if (item.url != null && item.url!.isNotEmpty)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.cloud_done_rounded, color: Colors.white, size: 8),
                        ),
                      )
                    else if (item.imagePath != null && item.imagePath!.isNotEmpty)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.smartphone_rounded, color: Colors.white, size: 8),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),

                // 3. Name & Meta Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isBought
                              ? (isDarkMode ? Colors.white24 : Colors.grey.shade400)
                              : (isDarkMode ? Colors.white : Colors.black87),
                          decoration: isBought ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (item.category != null && item.category!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: isBought ? 0.04 : 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.category!,
                                style: GoogleFonts.quicksand(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isBought 
                                      ? (isDarkMode ? Colors.white24 : Colors.grey.shade400)
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            DateFormat('dd MMM').format(item.createdAt),
                            style: GoogleFonts.quicksand(
                              fontSize: 9,
                              color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // 4. Prices & Stats
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatRupiah(item.estimatedPrice),
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isBought
                            ? (isDarkMode ? Colors.white24 : Colors.grey.shade400)
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.quantity.toString().replaceAll('.0', '')} ${item.unit}',
                      style: GoogleFonts.quicksand(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref, ShoppingItem item, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _buildOptionTile(
              icon: item.isBought ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
              label: item.isBought ? 'Tandai Belum Dibeli' : 'Tandai Sudah Dibeli',
              color: AppColors.primary,
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.pop(context);
                _toggleBoughtStatus(item);
              },
            ),
            _buildOptionTile(
              icon: Icons.edit_outlined,
              label: 'Edit Rencana',
              color: AppColors.primary,
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.pop(context);
                ShoppingFormSheet.show(context, item: item);
              },
            ),
            _buildOptionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Hapus Rencana',
              color: const Color(0xFFE53935),
              isDarkMode: isDarkMode,
              onTap: () async {
                Navigator.pop(context);
                // Hapus transaksi terkait di Riwayat jika ada
                try {
                  await ref.read(transactionServiceProvider).deleteTransaction('shopping_${item.id}');
                } catch (_) {}
                
                await ref.read(shoppingItemServiceProvider).deleteItem(item.id);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Rencana "${item.name}" berhasil dihapus.', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: GoogleFonts.quicksand(
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
