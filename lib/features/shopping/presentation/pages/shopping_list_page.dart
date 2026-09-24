import 'dart:io';
import 'package:tabunganku/core/widgets/top_toast.dart';
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
import 'package:tabunganku/services/api_image_service.dart';
import '../widgets/shopping_form_sheet.dart';

class ShoppingListPage extends ConsumerStatefulWidget {
  const ShoppingListPage({super.key});

  @override
  ConsumerState<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends ConsumerState<ShoppingListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSyncingAll = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        imageUrl: item.url ?? item.imagePath,
      );
      await ref.read(transactionServiceProvider).addTransaction(transaction);
    } else {

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
      showTopToast(context, nowBought 
                ? '"${item.name}" ditandai sudah dibeli & dicatat ke pengeluaran!'
                : 'Batal membeli "${item.name}" & catatan pengeluaran dihapus.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final shoppingItemsAsync = ref.watch(shoppingItemsStreamProvider);
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    final pageBg = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF9FAFB);
    final txtClr = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: txtClr, size: 20),
        ),
        title: Text(
          'Catatan Belanja',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: txtClr,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: shoppingItemsAsync.when(
                data: (items) {
                  final filteredItems = items.where((item) {
                    return item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        (item.category != null &&
                            item.category!.toLowerCase().contains(_searchQuery.toLowerCase()));
                  }).toList();

                  final unSyncedItems = items.where((i) =>
                      i.imagePath != null &&
                      i.imagePath!.isNotEmpty &&
                      (i.url == null || i.url!.isEmpty)).toList();

                  return Column(
                    children: [
                      _buildDashboardHeader(items, isDarkMode),
                      if (unSyncedItems.isNotEmpty)
                        _buildCloudSyncBanner(unSyncedItems, isDarkMode),
                      _buildSearchAndFilters(isDarkMode),
                      Expanded(
                        child: filteredItems.isEmpty
                            ? _buildEmptyState(isDarkMode, hasFilter: _searchQuery.isNotEmpty)
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
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
    final borderCol = isDarkMode ? Colors.white10 : Colors.grey.shade200;

    String statusLabel = 'Kosong';
    Color statusColor = Colors.grey;
    if (totalCount > 0) {
      if (progress >= 1.0) {
        statusLabel = 'Selesai';
        statusColor = Colors.green;
      } else {
        statusLabel = 'Belum Selesai';
        statusColor = AppColors.primary;
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.08 : 0.02),
            blurRadius: 16,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL ANGGARAN BELANJA',
                    style: GoogleFonts.quicksand(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatRupiah(totalEstimated),
                    style: GoogleFonts.quicksand(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: isDarkMode ? Colors.white : AppColors.primaryDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.quicksand(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            totalCount > 0 ? 'dari $totalCount rencana belanja' : 'Belum membuat rencana belanja',
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progres Belanja',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey,
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
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: totalCount > 0 ? progress : 0.0,
                        backgroundColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(progress >= 1.0 ? Colors.green : AppColors.primary),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: borderCol,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatCell(
                label: 'TERBELANJA',
                value: _formatRupiah(totalBought),
                color: totalCount > 0 ? Colors.green : Colors.grey,
              ),
              Container(
                width: 1,
                height: 32,
                color: borderCol,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              _StatCell(
                label: 'SISA ANGGARAN',
                value: _formatRupiah(remainingCost),
                color: remainingCost > 0 ? AppColors.primary : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
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
          filled: true,
          fillColor: isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
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

                GestureDetector(
                  onTap: () => _toggleBoughtStatus(item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    color: Colors.transparent,
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

                GestureDetector(
                  onTap: (item.imagePath != null && item.imagePath!.isNotEmpty) ||
                          (item.url != null && item.url!.isNotEmpty)
                      ? () => _showImagePreviewDialog(context, item, isDarkMode)
                      : null,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Builder(
                        builder: (context) {
                          final hasLocalFile = item.imagePath != null &&
                              item.imagePath!.isNotEmpty &&
                              File(item.imagePath!).existsSync();
                          final hasRemote = item.url != null && item.url!.isNotEmpty;

                          Widget imageContent;
                          if (hasLocalFile) {
                            imageContent = Image.file(
                              File(item.imagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.shopping_bag_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            );
                          } else if (hasRemote) {
                            imageContent = Image.network(
                              item.url!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.broken_image_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            );
                          } else {
                            imageContent = const Icon(
                              Icons.shopping_bag_rounded,
                              color: AppColors.primary,
                              size: 20,
                            );
                          }

                          return Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: isDarkMode ? 0.15 : 0.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: imageContent,
                            ),
                          );
                        },
                      ),
                      if (item.url != null && item.url!.contains('neverlandstudio.my.id'))
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF00E676),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cloud_done_rounded,
                            color: Colors.black,
                            size: 10,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

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
            if ((item.url != null && item.url!.isNotEmpty) ||
                (item.imagePath != null && item.imagePath!.isNotEmpty))
              _buildOptionTile(
                icon: Icons.image_search_rounded,
                label: 'Lihat Foto Barang',
                color: Colors.teal,
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.pop(context);
                  _showImagePreviewDialog(context, item, isDarkMode);
                },
              ),
            if (item.imagePath != null &&
                item.imagePath!.isNotEmpty &&
                (item.url == null || item.url!.isEmpty))
              _buildOptionTile(
                icon: Icons.cloud_upload_rounded,
                label: 'Unggah Foto ke Cloud API',
                color: Colors.blueAccent,
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.pop(context);
                  _uploadSingleItemToCloud(item);
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

                // Bersihkan gambar di server TabunganKu jika ada
                if (item.url != null && item.url!.contains('neverlandstudio.my.id')) {
                  ApiImageService.deleteImage(item.url!);
                }

                try {
                  await ref.read(transactionServiceProvider).deleteTransaction('shopping_${item.id}');
                } catch (_) {}
                
                await ref.read(shoppingItemServiceProvider).deleteItem(item.id);
                
                if (context.mounted) {
                  showTopToast(context, 'Rencana "${item.name}" berhasil dihapus.', isError: true);
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

  void _showImagePreviewDialog(BuildContext context, ShoppingItem item, bool isDarkMode) {
    final hasLocal = item.imagePath != null && item.imagePath!.isNotEmpty;
    final hasRemote = item.url != null && item.url!.isNotEmpty;
    if (!hasLocal && !hasRemote) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          if (hasRemote)
                            Row(
                              children: [
                                const Icon(Icons.cloud_done_rounded, color: Color(0xFF00E676), size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  'Tersimpan di Cloud API (WebP)',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          else if (hasLocal)
                            Row(
                              children: [
                                const Icon(Icons.phone_android_rounded, color: Colors.amber, size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  'Tersimpan Lokal di Memori HP',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 11,
                                    color: Colors.amber.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                    minHeight: 200,
                  ),
                  width: double.infinity,
                  color: isDarkMode ? Colors.black26 : Colors.grey.shade100,
                  child: InteractiveViewer(
                    clipBehavior: Clip.none,
                    child: hasLocal && File(item.imagePath!).existsSync()
                        ? Image.file(
                            File(item.imagePath!),
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => hasRemote
                                ? Image.network(
                                    item.url!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.broken_image_outlined,
                                          color: AppColors.primary, size: 48),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(Icons.broken_image_outlined,
                                        color: AppColors.primary, size: 48),
                                  ),
                          )
                        : (hasRemote
                            ? Image.network(
                                item.url!,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                          : null,
                                      color: AppColors.primary,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.broken_image_outlined,
                                      color: AppColors.primary, size: 48),
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.broken_image_outlined,
                                    color: AppColors.primary, size: 48),
                              )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadSingleItemToCloud(ShoppingItem item) async {
    if (item.imagePath == null) return;
    final file = File(item.imagePath!);
    if (!file.existsSync()) {
      showTopToast(context, 'Berkas foto lokal tidak ditemukan di memori.', isError: true);
      return;
    }

    showTopToast(context, 'Mengunggah foto "${item.name}" ke Cloud API...');
    final result = await ApiImageService.uploadImageDetailed(file);
    if (!mounted) return;

    if (result.success && result.url != null) {
      final updated = item.copyWith(
        url: result.url,
        isOnline: true,
      );
      await ref.read(shoppingItemServiceProvider).updateItem(updated);
      if (!mounted) return;
      showTopToast(context, 'Foto "${item.name}" berhasil dicadangkan ke Cloud API!');
    } else {
      if (!mounted) return;
      showTopToast(
        context,
        result.errorMessage ?? 'Gagal mengunggah foto ke Cloud API.',
        isError: true,
      );
    }
  }

  Future<void> _syncAllUnsyncedItems(List<ShoppingItem> unSyncedItems) async {
    if (unSyncedItems.isEmpty || _isSyncingAll) return;

    setState(() => _isSyncingAll = true);
    showTopToast(context, 'Memulai sinkronisasi ${unSyncedItems.length} foto ke Cloud API...');

    int successCount = 0;
    String? lastError;

    for (final item in unSyncedItems) {
      if (item.imagePath == null) continue;
      final file = File(item.imagePath!);
      if (!file.existsSync()) continue;

      // Beri jeda antar upload untuk mematuhi rate limit server
      await Future.delayed(const Duration(milliseconds: 350));

      final result = await ApiImageService.uploadImageDetailed(file);
      if (result.success && result.url != null) {
        final updated = item.copyWith(
          url: result.url,
          isOnline: true,
        );
        await ref.read(shoppingItemServiceProvider).updateItem(updated);
        successCount++;
      } else {
        lastError = result.errorMessage;
        if (result.statusCode == 429) {
          // Kuota rate limit habis, hentikan batch agar request tidak sia-sia
          break;
        }
      }
    }

    if (mounted) {
      setState(() => _isSyncingAll = false);
      if (successCount == unSyncedItems.length) {
        showTopToast(context, 'Semua ($successCount) foto berhasil disinkronkan ke Cloud API!');
      } else if (successCount > 0) {
        showTopToast(
          context,
          '$successCount foto disinkronkan.${lastError != null ? " Sisa: $lastError" : ""}',
        );
      } else {
        showTopToast(
          context,
          lastError ?? 'Sinkronisasi gagal. Pastikan koneksi internet stabil.',
          isError: true,
        );
      }
    }
  }

  Widget _buildCloudSyncBanner(List<ShoppingItem> unSyncedItems, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.amber.shade900.withValues(alpha: 0.2)
            : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.shade600.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.amber.shade700.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cloud_upload_rounded, color: Colors.amber.shade800, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${unSyncedItems.length} Foto Belum di Cloud',
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.amber.shade300 : Colors.amber.shade900,
                  ),
                ),
                Text(
                  'Cadangkan foto barang ke Cloud API',
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    color: isDarkMode ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _isSyncingAll ? null : () => _syncAllUnsyncedItems(unSyncedItems),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: _isSyncingAll
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    'Sinkronkan',
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

}


class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCell({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
