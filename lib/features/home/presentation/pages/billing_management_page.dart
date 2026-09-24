/// Page: BillingManagementPage
///
/// Manajemen tagihan berkala & riwayat pembayaran.
/// Halaman khusus untuk memanajemen tagihan bulanan (listrik, air, wifi, dsb.)
/// dengan status jatuh tempo, aksi bayar lunas, dan ringkasan bulanan.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/models/bill_model.dart';
import 'package:tabunganku/services/bills_service.dart';

enum BillFilter {
  all,
  unpaid,
  paid,
}

enum BillDueStatus {
  paid,
  overdue,
  dueToday,
  dueSoon,
  upcoming,
}

class BillingManagementPage extends ConsumerStatefulWidget {
  const BillingManagementPage({super.key});

  @override
  ConsumerState<BillingManagementPage> createState() =>
      _BillingManagementPageState();
}

class _BillingManagementPageState extends ConsumerState<BillingManagementPage> {
  BillFilter _selectedFilter = BillFilter.all;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(billsServiceProvider).checkAndResetMonthlyBills();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  /// Memeriksa apakah tagihan sudah dibayar untuk siklus bulan saat ini.
  bool _isPaidCurrentMonth(BillModel bill) {
    if (!bill.isPaid) return false;
    if (bill.lastPaidDate == null) return false;
    final now = DateTime.now();
    return bill.lastPaidDate!.year == now.year &&
        bill.lastPaidDate!.month == now.month;
  }

  // Menghitung status jatuh tempo untuk bulan berjalan
  BillDueStatus _calculateDueStatus(BillModel bill) {
    if (_isPaidCurrentMonth(bill)) return BillDueStatus.paid;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final maxDaysThisMonth = DateTime(today.year, today.month + 1, 0).day;
    final effectiveDay = bill.dueDay > maxDaysThisMonth ? maxDaysThisMonth : bill.dueDay;
    final dueDateThisMonth = DateTime(today.year, today.month, effectiveDay);

    final diffDays = dueDateThisMonth.difference(todayDate).inDays;
    if (diffDays < 0) return BillDueStatus.overdue;
    if (diffDays == 0) return BillDueStatus.dueToday;
    if (diffDays <= 3) return BillDueStatus.dueSoon;
    return BillDueStatus.upcoming;
  }

  String _getDueStatusLabel(BillModel bill) {
    if (_isPaidCurrentMonth(bill)) {
      if (bill.lastPaidDate != null) {
        return 'Lunas • ${DateFormat('d MMM', 'id_ID').format(bill.lastPaidDate!)}';
      }
      return 'Sudah Lunas';
    }

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final maxDaysThisMonth = DateTime(today.year, today.month + 1, 0).day;
    final effectiveDay = bill.dueDay > maxDaysThisMonth ? maxDaysThisMonth : bill.dueDay;
    final dueDateThisMonth = DateTime(today.year, today.month, effectiveDay);

    final diffDays = dueDateThisMonth.difference(todayDate).inDays;
    if (diffDays < 0) {
      final late = -diffDays;
      return 'Terlewat $late hari';
    }
    if (diffDays == 0) return 'Jatuh tempo hari ini';
    if (diffDays == 1) return 'Jatuh tempo besok';
    if (diffDays <= 3) return '$diffDays hari lagi';
    return 'Jatuh tempo tgl $effectiveDay';
  }

  Color _getDueStatusColor(BillDueStatus status, bool isDark) {
    switch (status) {
      case BillDueStatus.paid:
        return const Color(0xFF10B981);
      case BillDueStatus.overdue:
        return const Color(0xFFEF4444);
      case BillDueStatus.dueToday:
        return const Color(0xFFF97316);
      case BillDueStatus.dueSoon:
        return const Color(0xFFF59E0B);
      case BillDueStatus.upcoming:
        return isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
    }
  }

  // Icon kategori otomatis berdasarkan nama tagihan
  IconData _getBillIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('listrik') || lower.contains('pln') || lower.contains('token')) {
      return Icons.bolt_rounded;
    }
    if (lower.contains('air') || lower.contains('pdam')) {
      return Icons.water_drop_rounded;
    }
    if (lower.contains('wifi') ||
        lower.contains('internet') ||
        lower.contains('indihome') ||
        lower.contains('biznet') ||
        lower.contains('first media') ||
        lower.contains('myrepublic') ||
        lower.contains('orbit')) {
      return Icons.wifi_rounded;
    }
    if (lower.contains('bpjs') ||
        lower.contains('kesehatan') ||
        lower.contains('asuransi')) {
      return Icons.health_and_safety_rounded;
    }
    if (lower.contains('sewa') ||
        lower.contains('kost') ||
        lower.contains('kos') ||
        lower.contains('kontrakan') ||
        lower.contains('rumah')) {
      return Icons.home_rounded;
    }
    if (lower.contains('cicilan') ||
        lower.contains('kpr') ||
        lower.contains('kredit') ||
        lower.contains('pinjaman') ||
        lower.contains('paylater') ||
        lower.contains('leasing') ||
        lower.contains('motor') ||
        lower.contains('mobil')) {
      return Icons.credit_card_rounded;
    }
    if (lower.contains('sampah') ||
        lower.contains('keamanan') ||
        lower.contains('iuran') ||
        lower.contains('rt') ||
        lower.contains('rw')) {
      return Icons.shield_outlined;
    }
    if (lower.contains('pulsa') || lower.contains('paket') || lower.contains('kuota')) {
      return Icons.phone_android_rounded;
    }
    return Icons.receipt_long_rounded;
  }

  Color _getBillIconColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('listrik') || lower.contains('pln')) {
      return const Color(0xFFF59E0B);
    }
    if (lower.contains('air') || lower.contains('pdam')) {
      return const Color(0xFF06B6D4);
    }
    if (lower.contains('wifi') || lower.contains('internet')) {
      return const Color(0xFF3B82F6);
    }
    if (lower.contains('bpjs') || lower.contains('kesehatan')) {
      return const Color(0xFF10B981);
    }
    if (lower.contains('sewa') || lower.contains('kost')) {
      return const Color(0xFF8B5CF6);
    }
    if (lower.contains('cicilan') || lower.contains('kpr') || lower.contains('kredit')) {
      return const Color(0xFFEC4899);
    }
    return AppColors.primary;
  }

  // Toggle status bayar
  Future<void> _togglePaidStatus(BillModel bill) async {
    final isPaidNow = _isPaidCurrentMonth(bill);
    final newPaid = !isPaidNow;
    final updated = bill.copyWith(
      isPaid: newPaid,
      lastPaidDate: newPaid ? DateTime.now() : null,
    );

    await ref.read(billsServiceProvider).updateBill(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newPaid
                ? 'Tagihan "${bill.name}" ditandai sudah dibayar bulan ini'
                : 'Tagihan "${bill.name}" diubah ke belum dibayar',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          backgroundColor: newPaid ? const Color(0xFF10B981) : Colors.black87,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Delete tagihan
  Future<void> _deleteBill(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Hapus Tagihan?',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          content: Text(
            'Apakah kamu yakin ingin menghapus tagihan "$name"? Tindakan ini tidak dapat dibatalkan.',
            style: GoogleFonts.quicksand(
              fontSize: 13,
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Batal',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Hapus',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await ref.read(billsServiceProvider).deleteBill(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tagihan "$name" berhasil dihapus',
              style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final billsAsync = ref.watch(billsServiceProvider).watchBills();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC);
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final divClr = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final subClr = isDark ? Colors.white54 : const Color(0xFF64748B);
    final txtClr = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 17,
                      color: isDark ? Colors.white70 : AppColors.primaryDark,
                    ),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  Expanded(
                    child: Text(
                      'Manajemen Tagihan',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: txtClr,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Main Body with StreamBuilder
            Expanded(
              child: StreamBuilder<List<BillModel>>(
                stream: billsAsync,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  final allBills = snapshot.data ?? [];

                  // Kalkulasi Ringkasan
                  double totalAmount = 0.0;
                  double totalPaid = 0.0;
                  double totalUnpaid = 0.0;
                  int paidCount = 0;
                  int unpaidCount = 0;

                  for (var b in allBills) {
                    totalAmount += b.amount;
                    if (_isPaidCurrentMonth(b)) {
                      totalPaid += b.amount;
                      paidCount++;
                    } else {
                      totalUnpaid += b.amount;
                      unpaidCount++;
                    }
                  }

                  final progress =
                      allBills.isEmpty ? 0.0 : (paidCount / allBills.length);

                  // Filtering & Search
                  final filteredBills = allBills.where((b) {
                    final isPaid = _isPaidCurrentMonth(b);
                    // Filter Status
                    if (_selectedFilter == BillFilter.unpaid && isPaid) {
                      return false;
                    }
                    if (_selectedFilter == BillFilter.paid && !isPaid) {
                      return false;
                    }

                    // Search Query
                    if (_searchQuery.trim().isNotEmpty) {
                      final q = _searchQuery.toLowerCase();
                      return b.name.toLowerCase().contains(q);
                    }
                    return true;
                  }).toList();

                  // Sort: Unpaid first (Overdue -> DueToday -> DueSoon -> Upcoming), then Paid
                  filteredBills.sort((a, b) {
                    final paidA = _isPaidCurrentMonth(a);
                    final paidB = _isPaidCurrentMonth(b);
                    if (paidA != paidB) {
                      return paidA ? 1 : -1;
                    }
                    final statusA = _calculateDueStatus(a);
                    final statusB = _calculateDueStatus(b);
                    return statusA.index.compareTo(statusB.index);
                  });

                  return CustomScrollView(
                    slivers: [
                      // Ringkasan Eksekutif Tagihan
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                          child: _buildExecutiveSummaryCard(
                            isDark: isDark,
                            cardBg: cardBg,
                            divClr: divClr,
                            txtClr: txtClr,
                            subClr: subClr,
                            totalAmount: totalAmount,
                            totalPaid: totalPaid,
                            totalUnpaid: totalUnpaid,
                            paidCount: paidCount,
                            unpaidCount: unpaidCount,
                            totalCount: allBills.length,
                            progress: progress,
                          ),
                        ),
                      ),

                      // Search Bar
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildSearchBar(
                            isDark: isDark,
                            cardBg: cardBg,
                            divClr: divClr,
                            txtClr: txtClr,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 12)),

                      // Filter Tipe Dropdown (Persis seperti di Riwayat Transaksi)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text(
                                'Filter Tipe:',
                                style: GoogleFonts.quicksand(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              _buildTypeDropdown(isDark),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 14)),

                      // Section Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedFilter == BillFilter.all
                                    ? 'SEMUA TAGIHAN'
                                    : _selectedFilter == BillFilter.unpaid
                                        ? 'TAGIHAN BELUM BAYAR'
                                        : 'TAGIHAN LUNAS',
                                style: GoogleFonts.quicksand(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: subClr,
                                ),
                              ),
                              Text(
                                '${filteredBills.length} Terdaftar',
                                style: GoogleFonts.quicksand(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: subClr,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 10)),

                      // List Tagihan atau Empty State
                      if (allBills.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(isDark, subClr, txtClr),
                        )
                      else if (filteredBills.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildNoSearchResult(isDark, subClr, txtClr),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final bill = filteredBills[index];
                                return _buildBillCardItem(
                                  bill: bill,
                                  isDark: isDark,
                                  cardBg: cardBg,
                                  divClr: divClr,
                                  txtClr: txtClr,
                                  subClr: subClr,
                                );
                              },
                              childCount: filteredBills.length,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrEditBillSheet(isDark),
        backgroundColor: AppColors.primary,
        elevation: 3,
        highlightElevation: 1,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: Text(
          'Tambah Tagihan',
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ================= SUMMARY CARD =================
  Widget _buildExecutiveSummaryCard({
    required bool isDark,
    required Color cardBg,
    required Color divClr,
    required Color txtClr,
    required Color subClr,
    required double totalAmount,
    required double totalPaid,
    required double totalUnpaid,
    required int paidCount,
    required int unpaidCount,
    required int totalCount,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: divClr),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
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
              Text(
                'Total Kewajiban Tagihan',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: subClr,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalCount Tagihan',
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatRupiah(totalAmount),
              style: GoogleFonts.quicksand(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: txtClr,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2 Mini Cards: Sisa Belum Bayar vs Sudah Dibayar
          Row(
            children: [
              // Belum Bayar
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.red.withValues(alpha: 0.08)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? Colors.red.withValues(alpha: 0.2)
                          : const Color(0xFFFEE2E2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Belum Bayar ($unpaidCount)',
                              style: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFEF4444),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _formatRupiah(totalUnpaid),
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Sudah Dibayar
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.green.withValues(alpha: 0.08)
                        : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? Colors.green.withValues(alpha: 0.2)
                          : const Color(0xFFDCFCE7),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Lunas ($paidCount)',
                              style: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF10B981),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _formatRupiah(totalPaid),
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress Bar Pelunasan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status Pelunasan Bulan Ini',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: subClr,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% Selesai',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: totalCount == 0 ? 0.0 : progress,
              minHeight: 6,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SEARCH BAR =================
  Widget _buildSearchBar({
    required bool isDark,
    required Color cardBg,
    required Color divClr,
    required Color txtClr,
  }) {
    return TextField(
      controller: _searchCtrl,
      onChanged: (val) => setState(() => _searchQuery = val),
      style: GoogleFonts.quicksand(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: txtClr,
      ),
      decoration: InputDecoration(
        hintText: 'Cari tagihan...',
        hintStyle: GoogleFonts.quicksand(
          fontSize: 12.5,
          color: isDark ? Colors.white30 : Colors.black38,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 19,
          color: isDark ? Colors.white38 : Colors.black45,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 17),
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: divClr),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: divClr),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 11,
          horizontal: 14,
        ),
        isDense: true,
      ),
    );
  }

  // ================= FILTER DROPDOWN PERSIS SEPERTI DI RIWAYAT =================
  Widget _buildTypeDropdown(bool isDark) {
    final options = [
      {
        'val': BillFilter.all,
        'label': 'Semua',
        'icon': Icons.receipt_long_rounded,
        'color': AppColors.primary,
      },
      {
        'val': BillFilter.unpaid,
        'label': 'Belum Bayar',
        'icon': Icons.pending_actions_rounded,
        'color': const Color(0xFFEF4444),
      },
      {
        'val': BillFilter.paid,
        'label': 'Sudah Lunas',
        'icon': Icons.check_circle_rounded,
        'color': const Color(0xFF10B981),
      },
    ];

    final currentOption = options.firstWhere(
      (e) => e['val'] == _selectedFilter,
      orElse: () => options[0],
    );
    final currentColor = currentOption['color'] as Color;
    final currentIcon = currentOption['icon'] as IconData;
    final currentLabel = currentOption['label'] as String;

    return PopupMenuButton<BillFilter>(
      initialValue: _selectedFilter,
      onSelected: (BillFilter val) {
        setState(() => _selectedFilter = val);
      },
      borderRadius: BorderRadius.circular(20),
      offset: const Offset(0, 42),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      color: isDark ? AppColors.surfaceDark : Colors.white,
      elevation: 6,
      itemBuilder: (context) => options.map((opt) {
        final val = opt['val'] as BillFilter;
        final selected = _selectedFilter == val;
        final color = opt['color'] as Color;
        return PopupMenuItem<BillFilter>(
          value: val,
          height: 44,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(opt['icon'] as IconData, size: 14, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                opt['label'] as String,
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected
                      ? color
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
              if (selected) ...[
                const Spacer(),
                Icon(Icons.check_circle_rounded, size: 16, color: color),
              ],
            ],
          ),
        );
      }).toList(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: currentColor.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: currentColor.withValues(alpha: isDark ? 0.4 : 0.25),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(currentIcon, size: 14, color: currentColor),
            const SizedBox(width: 8),
            Text(
              currentLabel,
              style: GoogleFonts.quicksand(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : currentColor,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isDark ? Colors.white60 : currentColor,
            ),
          ],
        ),
      ),
    );
  }

  // ================= BILL CARD ITEM =================
  Widget _buildBillCardItem({
    required BillModel bill,
    required bool isDark,
    required Color cardBg,
    required Color divClr,
    required Color txtClr,
    required Color subClr,
  }) {
    final isPaid = _isPaidCurrentMonth(bill);
    final status = _calculateDueStatus(bill);
    final statusLabel = _getDueStatusLabel(bill);
    final statusColor = _getDueStatusColor(status, isDark);
    final iconData = _getBillIcon(bill.name);
    final iconColor = _getBillIconColor(bill.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status == BillDueStatus.overdue
              ? const Color(0xFFEF4444).withValues(alpha: 0.3)
              : divClr,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showBillDetailSheet(bill, isDark),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Icon Category
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(iconData, color: iconColor, size: 21),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              bill.name,
                              style: GoogleFonts.quicksand(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: isPaid
                                    ? txtClr.withValues(alpha: 0.6)
                                    : txtClr,
                                decoration: isPaid
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _formatRupiah(bill.amount),
                              style: GoogleFonts.quicksand(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isPaid
                                    ? txtClr.withValues(alpha: 0.5)
                                    : txtClr,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '•  Tgl ${bill.dueDay}',
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: subClr,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(
                              alpha: isDark ? 0.12 : 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusLabel,
                          style: GoogleFonts.quicksand(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Action Button: Quick Pay / Toggle Lunas
                InkWell(
                  onTap: () => _togglePaidStatus(bill),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? const Color(0xFF10B981).withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPaid
                            ? const Color(0xFF10B981).withValues(alpha: 0.3)
                            : AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPaid
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: 15,
                          color: isPaid
                              ? const Color(0xFF10B981)
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isPaid ? 'Lunas' : 'Bayar',
                          style: GoogleFonts.quicksand(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isPaid
                                ? const Color(0xFF10B981)
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= DETAIL SHEET =================
  void _showBillDetailSheet(BillModel bill, bool isDark) {
    final isPaid = _isPaidCurrentMonth(bill);
    final status = _calculateDueStatus(bill);
    final statusLabel = _getDueStatusLabel(bill);
    final statusColor = _getDueStatusColor(status, isDark);
    final iconData = _getBillIcon(bill.name);
    final iconColor = _getBillIconColor(bill.name);
    final txtClr = isDark ? Colors.white : const Color(0xFF1E293B);
    final subClr = isDark ? Colors.white54 : const Color(0xFF64748B);
    final sheetBg = isDark ? AppColors.surfaceDark : Colors.white;
    final divClr = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 20,
                top: 16,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header Info
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(iconData, color: iconColor, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bill.name,
                              style: GoogleFonts.quicksand(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: txtClr,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tagihan Rutin Bulanan',
                              style: GoogleFonts.quicksand(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: subClr,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(
                              alpha: isDark ? 0.15 : 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusLabel,
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Nominal Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: divClr),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nominal Tagihan',
                          style: GoogleFonts.quicksand(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: subClr,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRupiah(bill.amount),
                          style: GoogleFonts.quicksand(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Jatuh Tempo Bulanan',
                                style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  color: subClr,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Setiap Tanggal ${bill.dueDay}',
                              style: GoogleFonts.quicksand(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: txtClr,
                              ),
                            ),
                          ],
                        ),
                        if (bill.lastPaidDate != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  isPaid ? 'Dibayar Bulan Ini' : 'Terakhir Dibayar',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 12,
                                    color: subClr,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('d MMM yyyy, HH:mm', 'id_ID')
                                    .format(bill.lastPaidDate!),
                                style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isPaid
                                      ? const Color(0xFF10B981)
                                      : subClr,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Button Toggle Paid
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _togglePaidStatus(bill);
                      },
                      icon: Icon(
                        isPaid
                            ? Icons.replay_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 18,
                      ),
                      label: Text(
                        isPaid
                            ? 'Ubah ke Belum Dibayar'
                            : 'Tandai Sudah Dibayar Sekarang',
                        style: GoogleFonts.quicksand(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPaid
                            ? (isDark ? Colors.white12 : Colors.grey.shade200)
                            : AppColors.primary,
                        foregroundColor: isPaid
                            ? (isDark ? Colors.white : Colors.black87)
                            : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Action Buttons: Edit & Delete
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showAddOrEditBillSheet(isDark, bill: bill);
                          },
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: Text(
                            'Ubah Data',
                            style: GoogleFonts.quicksand(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: txtClr,
                            side: BorderSide(color: divClr),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _deleteBill(bill.id, bill.name);
                          },
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 16, color: Colors.redAccent),
                          label: Text(
                            'Hapus',
                            style: GoogleFonts.quicksand(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.redAccent,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: Colors.redAccent.withValues(alpha: 0.3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ================= FORM TAMBAH / UBAH TAGIHAN =================
  void _showAddOrEditBillSheet(bool isDark, {BillModel? bill}) {
    final isEditing = bill != null;
    final nameCtrl = TextEditingController(text: bill?.name ?? '');
    final amountCtrl = TextEditingController(
      text: bill != null
          ? bill.amount.toInt().toString().replaceAllMapped(
                RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                (match) => '${match[1]}.',
              )
          : '',
    );
    int selectedDueDay = bill?.dueDay ?? DateTime.now().day;
    bool nameError = false;
    bool amountError = false;

    final sheetBg = isDark ? AppColors.surfaceDark : Colors.white;
    final txtClr = isDark ? Colors.white : const Color(0xFF1E293B);
    final subClr = isDark ? Colors.white54 : const Color(0xFF64748B);
    final divClr = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom > 0
                    ? MediaQuery.of(context).viewInsets.bottom + 16
                    : MediaQuery.of(context).padding.bottom + 20,
                top: 16,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title Form
                    Text(
                      isEditing ? 'Ubah Tagihan' : 'Tambah Tagihan Baru',
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: txtClr,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Field Nama Tagihan
                    Text(
                      'Nama Tagihan',
                      style: GoogleFonts.quicksand(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: txtClr,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtrl,
                      onChanged: (val) {
                        if (nameError && val.trim().isNotEmpty) {
                          setSheetState(() => nameError = false);
                        }
                      },
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: txtClr,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama tagihan',
                        hintStyle: GoogleFonts.quicksand(
                          fontSize: 12.5,
                          color: isDark ? Colors.white30 : Colors.black38,
                        ),
                        prefixIcon: Icon(
                          Icons.receipt_long_rounded,
                          size: 19,
                          color: nameError ? Colors.redAccent : AppColors.primary,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: nameError ? Colors.redAccent : divClr,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: nameError ? Colors.redAccent : divClr,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: nameError
                                ? Colors.redAccent
                                : AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 14),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Field Nominal
                    Text(
                      'Nominal Tagihan',
                      style: GoogleFonts.quicksand(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: txtClr,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _RibuanFormatter(),
                      ],
                      onChanged: (val) {
                        if (amountError) {
                          final parsed =
                              double.tryParse(val.replaceAll('.', '')) ?? 0.0;
                          if (parsed > 0) {
                            setSheetState(() => amountError = false);
                          }
                        }
                      },
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: txtClr,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Masukkan nominal',
                        hintStyle: GoogleFonts.quicksand(
                          fontSize: 12.5,
                          color: isDark ? Colors.white30 : Colors.black38,
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.centerLeft,
                          width: 44,
                          child: Text(
                            'Rp',
                            style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: amountError ? Colors.redAccent : divClr,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: amountError ? Colors.redAccent : divClr,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: amountError
                                ? Colors.redAccent
                                : AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 14),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Field Tanggal Jatuh Tempo Bulanan
                    Text(
                      'Jatuh Tempo Setiap Tanggal',
                      style: GoogleFonts.quicksand(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: txtClr,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: divClr),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedDueDay,
                          isExpanded: true,
                          dropdownColor:
                              isDark ? AppColors.surfaceDark : Colors.white,
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: txtClr,
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: subClr,
                            size: 20,
                          ),
                          items: List.generate(31, (index) {
                            final day = index + 1;
                            return DropdownMenuItem<int>(
                              value: day,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 15,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Tanggal $day setiap bulan',
                                    style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) {
                              setSheetState(() => selectedDueDay = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tagihan akan berulang setiap tanggal $selectedDueDay tiap bulannya.',
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        color: subClr,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final nameVal = nameCtrl.text.trim();
                          final rawAmount =
                              amountCtrl.text.replaceAll('.', '').trim();
                          final amountVal = double.tryParse(rawAmount) ?? 0.0;

                          setSheetState(() {
                            nameError = nameVal.isEmpty;
                            amountError = amountVal <= 0;
                          });

                          if (nameError || amountError) return;

                          final nav = Navigator.of(ctx);
                          final scaffoldMsg = ScaffoldMessenger.of(context);

                          if (isEditing) {
                            final updated = bill.copyWith(
                              name: nameVal,
                              amount: amountVal,
                              dueDay: selectedDueDay,
                            );
                            await ref
                                .read(billsServiceProvider)
                                .updateBill(updated);
                          } else {
                            final newBill = BillModel(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              name: nameVal,
                              amount: amountVal,
                              dueDay: selectedDueDay,
                              isPaid: false,
                            );
                            await ref.read(billsServiceProvider).addBill(newBill);
                          }

                          nav.pop();

                          if (mounted) {
                            scaffoldMsg.showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEditing
                                      ? 'Tagihan berhasil diperbarui'
                                      : 'Tagihan berhasil ditambahkan',
                                  style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                backgroundColor: const Color(0xFF10B981),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          isEditing ? 'Simpan Perubahan' : 'Simpan Tagihan',
                          style: GoogleFonts.quicksand(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= EMPTY & NO RESULT STATES =================
  Widget _buildEmptyState(bool isDark, Color subClr, Color txtClr) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 34,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Belum Ada Tagihan',
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: txtClr,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Gunakan tombol Tambah Tagihan di bawah untuk mencatat tagihan rutin bulananmu.',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: subClr,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResult(bool isDark, Color subClr, Color txtClr) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: subClr.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 14),
            Text(
              'Tidak Ada Tagihan Ditemukan',
              style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: txtClr,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Coba cari dengan kata kunci lain atau ubah filter status.',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                color: subClr,
              ),
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
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final formatted = digits.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
