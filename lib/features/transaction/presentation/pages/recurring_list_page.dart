/// Page: RecurringListPage
///
/// Halaman kelola langganan dan transaksi rutin.
/// Menyediakan fitur pencatatan, ringkasan biaya bulanan, jeda/aktifkan,
/// serta pengingat jatuh tempo dengan tampilan minimalis dan konsisten.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/constants/transaction_categories.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';
import 'package:tabunganku/models/recurring_transaction_model.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/services/recurring_service.dart';

class _CategoryItem {
  final String label;
  final IconData icon;
  final Color color;

  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.color,
  });
}

const List<_CategoryItem> _expenseCategories = [
  _CategoryItem(
    label: 'Langganan & Streaming',
    icon: Icons.play_circle_fill_rounded,
    color: Color(0xFF8B5CF6),
  ),
  _CategoryItem(
    label: 'Tagihan & Utilitas',
    icon: Icons.bolt_rounded,
    color: Color(0xFFF59E0B),
  ),
  _CategoryItem(
    label: 'Internet & WiFi',
    icon: Icons.wifi_rounded,
    color: Color(0xFF3B82F6),
  ),
  _CategoryItem(
    label: 'Tempat Tinggal & Kos',
    icon: Icons.home_rounded,
    color: Color(0xFFEC4899),
  ),
  _CategoryItem(
    label: 'Asuransi & BPJS',
    icon: Icons.health_and_safety_rounded,
    color: Color(0xFF10B981),
  ),
  _CategoryItem(
    label: 'Pendidikan & Kursus',
    icon: Icons.school_rounded,
    color: Color(0xFF06B6D4),
  ),
  _CategoryItem(
    label: 'Transportasi & Bensin',
    icon: Icons.directions_car_rounded,
    color: Color(0xFFF97316),
  ),
  _CategoryItem(
    label: 'Cicilan Pinjaman',
    icon: Icons.credit_card_rounded,
    color: Color(0xFFEF4444),
  ),
  _CategoryItem(
    label: 'Lainnya',
    icon: Icons.category_rounded,
    color: Color(0xFF64748B),
  ),
];

const List<_CategoryItem> _incomeCategories = [
  _CategoryItem(
    label: 'Gaji & Upah',
    icon: Icons.account_balance_wallet_rounded,
    color: Color(0xFF10B981),
  ),
  _CategoryItem(
    label: 'Bisnis & Usaha',
    icon: Icons.storefront_rounded,
    color: Color(0xFF8B5CF6),
  ),
  _CategoryItem(
    label: 'Investasi & Dividen',
    icon: Icons.trending_up_rounded,
    color: Color(0xFF3B82F6),
  ),
  _CategoryItem(
    label: 'Sewa & Royalti',
    icon: Icons.apartment_rounded,
    color: Color(0xFFF59E0B),
  ),
  _CategoryItem(
    label: 'Tunjangan Rutin',
    icon: Icons.attach_money_rounded,
    color: Color(0xFF06B6D4),
  ),
  _CategoryItem(
    label: 'Pemasukan Lainnya',
    icon: Icons.savings_rounded,
    color: Color(0xFF64748B),
  ),
];

class RecurringListPage extends ConsumerStatefulWidget {
  const RecurringListPage({super.key});

  @override
  ConsumerState<RecurringListPage> createState() => _RecurringListPageState();
}

class _RecurringListPageState extends ConsumerState<RecurringListPage> {
  List<RecurringTransactionModel> _items = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua'; // 'Semua', 'Pengeluaran', 'Pemasukan'
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  static final _currencyFmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final items =
        await ref.read(recurringServiceProvider).getRecurringTransactions();
    if (mounted) {
      setState(() {
        _items = items;
        _isLoading = false;
      });
    }
  }

  String _formatRupiah(double amount) {
    return _currencyFmt.format(amount);
  }

  IconData _getCategoryIcon(String category) {
    for (final c in [..._expenseCategories, ..._incomeCategories]) {
      if (c.label.toLowerCase() == category.toLowerCase()) return c.icon;
    }
    return AppCategories.getIconForCategory(category);
  }

  Color _getCategoryColor(String category) {
    for (final c in [..._expenseCategories, ..._incomeCategories]) {
      if (c.label.toLowerCase() == category.toLowerCase()) return c.color;
    }
    return AppCategories.getColorForCategory(category);
  }

  String _getFreqLabel(RecurringFrequency f) {
    switch (f) {
      case RecurringFrequency.daily:
        return 'Harian';
      case RecurringFrequency.weekly:
        return 'Mingguan';
      case RecurringFrequency.monthly:
        return 'Bulanan';
      case RecurringFrequency.quarterly:
        return 'Tiap 3 Bulan';
      case RecurringFrequency.semiAnnually:
        return 'Tiap 6 Bulan';
      case RecurringFrequency.yearly:
        return 'Tahunan';
    }
  }

  String _getFreqShort(RecurringFrequency f) {
    switch (f) {
      case RecurringFrequency.daily:
        return '/hari';
      case RecurringFrequency.weekly:
        return '/mgg';
      case RecurringFrequency.monthly:
        return '/bln';
      case RecurringFrequency.quarterly:
        return '/3bln';
      case RecurringFrequency.semiAnnually:
        return '/6bln';
      case RecurringFrequency.yearly:
        return '/thn';
    }
  }

  double _getMonthlyEquivalent(double amount, RecurringFrequency freq) {
    switch (freq) {
      case RecurringFrequency.daily:
        return amount * 30;
      case RecurringFrequency.weekly:
        return amount * 4.33;
      case RecurringFrequency.monthly:
        return amount;
      case RecurringFrequency.quarterly:
        return amount / 3;
      case RecurringFrequency.semiAnnually:
        return amount / 6;
      case RecurringFrequency.yearly:
        return amount / 12;
    }
  }

  DateTime _getNextDueDate(RecurringTransactionModel item) {
    DateTime base = item.lastProcessedDate;
    final now = DateTime.now();

    DateTime next = base;
    while (!next.isAfter(DateTime(now.year, now.month, now.day))) {
      switch (item.frequency) {
        case RecurringFrequency.daily:
          next = next.add(const Duration(days: 1));
          break;
        case RecurringFrequency.weekly:
          next = next.add(const Duration(days: 7));
          break;
        case RecurringFrequency.monthly:
          int nextMonth = next.month + 1;
          int nextYear = next.year;
          if (nextMonth > 12) {
            nextMonth = 1;
            nextYear += 1;
          }
          int maxDays = DateTime(nextYear, nextMonth + 1, 0).day;
          int day = item.startDate.day > maxDays ? maxDays : item.startDate.day;
          next = DateTime(nextYear, nextMonth, day);
          break;
        case RecurringFrequency.quarterly:
          int nextMonth = next.month + 3;
          int nextYear = next.year;
          if (nextMonth > 12) {
            nextMonth -= 12;
            nextYear += 1;
          }
          int maxDays = DateTime(nextYear, nextMonth + 1, 0).day;
          int day = item.startDate.day > maxDays ? maxDays : item.startDate.day;
          next = DateTime(nextYear, nextMonth, day);
          break;
        case RecurringFrequency.semiAnnually:
          int nextMonth = next.month + 6;
          int nextYear = next.year;
          if (nextMonth > 12) {
            nextMonth -= 12;
            nextYear += 1;
          }
          int maxDays = DateTime(nextYear, nextMonth + 1, 0).day;
          int day = item.startDate.day > maxDays ? maxDays : item.startDate.day;
          next = DateTime(nextYear, nextMonth, day);
          break;
        case RecurringFrequency.yearly:
          next = DateTime(next.year + 1, item.startDate.month, item.startDate.day);
          break;
      }
    }
    return next;
  }

  String _getDueDateStatusText(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diffDays = target.difference(today).inDays;

    if (diffDays == 0) return 'Jatuh tempo hari ini';
    if (diffDays == 1) return 'Besok';
    if (diffDays <= 7) return '$diffDays hari lagi';
    return DateFormat('d MMM', 'id_ID').format(dueDate);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC);
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final divClr = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final subClr = isDark ? Colors.white54 : const Color(0xFF64748B);
    final txtClr = isDark ? Colors.white : const Color(0xFF1E293B);

    final activeExpenses = _items
        .where((i) => i.type == TransactionType.expense && i.isActive)
        .toList();
    final activeIncomes = _items
        .where((i) => i.type == TransactionType.income && i.isActive)
        .toList();

    double totalMonthlyCost = 0.0;
    for (var item in activeExpenses) {
      totalMonthlyCost += _getMonthlyEquivalent(item.amount, item.frequency);
    }

    double totalMonthlyIncome = 0.0;
    for (var item in activeIncomes) {
      totalMonthlyIncome += _getMonthlyEquivalent(item.amount, item.frequency);
    }

    // Filter items
    final filteredItems = _items.where((item) {
      if (_selectedFilter == 'Pengeluaran' &&
          item.type != TransactionType.expense) {
        return false;
      }
      if (_selectedFilter == 'Pemasukan' &&
          item.type != TransactionType.income) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = item.title.toLowerCase().contains(q);
        final matchCategory = item.category.toLowerCase().contains(q);
        return matchTitle || matchCategory;
      }
      return true;
    }).toList();

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
                      'Kelola Langganan',
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

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: AppColors.primary,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                        children: [
                          // Hero Summary Card
                          _buildSummaryCard(
                            totalCost: totalMonthlyCost,
                            totalIncome: totalMonthlyIncome,
                            activeCount: activeExpenses.length,
                            isDark: isDark,
                            cardBg: cardBg,
                            divClr: divClr,
                            txtClr: txtClr,
                            subClr: subClr,
                          ),
                          const SizedBox(height: 14),

                          // Search Bar
                          _buildSearchBar(
                            isDark: isDark,
                            cardBg: cardBg,
                            divClr: divClr,
                            txtClr: txtClr,
                          ),
                          const SizedBox(height: 12),

                          // Filter Tipe Dropdown (Persis seperti di Riwayat Transaksi)
                          Row(
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
                          const SizedBox(height: 14),

                          // Section Header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedFilter == 'Semua'
                                      ? 'SEMUA LANGGANAN & RUTIN'
                                      : _selectedFilter == 'Pengeluaran'
                                          ? 'LANGGANAN PENGELUARAN'
                                          : 'PEMASUKAN RUTIN',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: subClr,
                                  ),
                                ),
                                Text(
                                  '${filteredItems.length} Terdaftar',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: subClr,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // List Cards or Empty State
                          if (filteredItems.isEmpty)
                            _buildEmptyState(isDark: isDark, subClr: subClr)
                          else
                            ...filteredItems.map(
                              (item) => _buildSubscriptionCard(
                                item: item,
                                isDark: isDark,
                                cardBg: cardBg,
                                divClr: divClr,
                                txtClr: txtClr,
                                subClr: subClr,
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrEditSheet(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text(
          'Tambah Langganan',
          style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ================= SUMMARY HERO CARD =================
  Widget _buildSummaryCard({
    required double totalCost,
    required double totalIncome,
    required int activeCount,
    required bool isDark,
    required Color cardBg,
    required Color divClr,
    required Color txtClr,
    required Color subClr,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: divClr, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                'ESTIMASI PENGELUARAN BULANAN',
                style: GoogleFonts.quicksand(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: subClr,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$activeCount Aktif',
                  style: GoogleFonts.quicksand(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatRupiah(totalCost),
              style: GoogleFonts.quicksand(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: txtClr,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 13,
                color: subClr,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  totalIncome > 0
                      ? 'Dihitung per bulan • Rutin masuk: ${_formatRupiah(totalIncome)}'
                      : 'Total biaya rutin otomatis yang aktif per bulan',
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: subClr,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
      onChanged: (v) => setState(() => _searchQuery = v),
      style: GoogleFonts.quicksand(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: txtClr,
      ),
      decoration: InputDecoration(
        hintText: 'Cari langganan...',
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
        'val': 'Semua',
        'label': 'Semua',
        'icon': Icons.receipt_long_rounded,
        'color': AppColors.primary,
      },
      {
        'val': 'Pemasukan',
        'label': 'Pemasukan',
        'icon': Icons.arrow_downward_rounded,
        'color': const Color(0xFF2ECC71),
      },
      {
        'val': 'Pengeluaran',
        'label': 'Pengeluaran',
        'icon': Icons.arrow_upward_rounded,
        'color': const Color(0xFFE74C3C),
      },
    ];

    final currentOption = options.firstWhere(
      (e) => e['val'] == _selectedFilter,
      orElse: () => options[0],
    );
    final currentColor = currentOption['color'] as Color;
    final currentIcon = currentOption['icon'] as IconData;
    final currentLabel = currentOption['label'] as String;

    return PopupMenuButton<String>(
      initialValue: _selectedFilter,
      onSelected: (String val) {
        setState(() => _selectedFilter = val);
      },
      borderRadius: BorderRadius.circular(20),
      offset: const Offset(0, 42),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      color: isDark ? AppColors.surfaceDark : Colors.white,
      elevation: 6,
      itemBuilder: (context) => options.map((opt) {
        final val = opt['val'] as String;
        final selected = _selectedFilter == val;
        final color = opt['color'] as Color;
        return PopupMenuItem<String>(
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

  // ================= SUBSCRIPTION ITEM CARD =================
  Widget _buildSubscriptionCard({
    required RecurringTransactionModel item,
    required bool isDark,
    required Color cardBg,
    required Color divClr,
    required Color txtClr,
    required Color subClr,
  }) {
    final isExpense = item.type == TransactionType.expense;
    final catColor = _getCategoryColor(item.category);
    final catIcon = _getCategoryIcon(item.category);
    final dueDate = _getNextDueDate(item);
    final dueText = _getDueDateStatusText(dueDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.isActive
              ? divClr
              : (isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.grey.shade200),
          width: 1.0,
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
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showDetailSheet(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Soft Squircle Category Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: catColor.withValues(
                      alpha: item.isActive ? (isDark ? 0.20 : 0.12) : 0.06,
                    ),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: catColor.withValues(
                        alpha: item.isActive ? 0.25 : 0.10,
                      ),
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      catIcon,
                      color: item.isActive ? catColor : Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Center Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.quicksand(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: item.isActive ? txtClr : subClr,
                              ),
                            ),
                          ),
                          if (!item.isActive) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Dijeda',
                                style: GoogleFonts.quicksand(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            _getFreqLabel(item.frequency),
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: subClr,
                            ),
                          ),
                          Text(
                            ' • ',
                            style: TextStyle(
                              fontSize: 10,
                              color: subClr.withValues(alpha: 0.6),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item.isActive
                                  ? 'Jatuh tempo $dueText'
                                  : 'Dinonaktifkan',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: item.isActive
                                    ? (dueText.contains('hari ini') ||
                                            dueText.contains('Besok')
                                        ? const Color(0xFFF59E0B)
                                        : subClr)
                                    : subClr,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Amount & Period
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatRupiah(item.amount),
                      style: GoogleFonts.quicksand(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: item.isActive
                            ? (isExpense
                                ? const Color(0xFFF43F5E)
                                : const Color(0xFF10B981))
                            : subClr,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getFreqShort(item.frequency),
                      style: GoogleFonts.quicksand(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: subClr,
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

  // ================= EMPTY STATE (Tanpa Double Button) =================
  Widget _buildEmptyState({required bool isDark, required Color subClr}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.autorenew_rounded,
              size: 30,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'Tidak ada hasil pencarian'
                : 'Belum ada langganan tercatat',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _searchQuery.isNotEmpty
                ? 'Coba kata kunci lain atau ubah pilihan filter tipe.'
                : 'Gunakan tombol Tambah Langganan di bawah untuk mencatat tagihan dan langganan rutinmu.',
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
    );
  }

  // ================= DETAIL & ACTION BOTTOM SHEET =================
  void _showDetailSheet(RecurringTransactionModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final sheetBg = isDark ? AppColors.surfaceDark : Colors.white;
            final txtClr = isDark ? Colors.white : const Color(0xFF1E293B);
            final subClr = isDark ? Colors.white54 : const Color(0xFF64748B);
            final divClr = isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06);

            final currentItem =
                _items.firstWhere((i) => i.id == item.id, orElse: () => item);
            final catColor = _getCategoryColor(currentItem.category);
            final catIcon = _getCategoryIcon(currentItem.category);
            final dueDate = _getNextDueDate(currentItem);
            final monthlyCost = _getMonthlyEquivalent(
                currentItem.amount, currentItem.frequency);

            return Container(
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 14,
                bottom: MediaQuery.of(context).padding.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle pill
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Header with Category Icon & Title
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: catColor
                              .withValues(alpha: isDark ? 0.20 : 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: catColor.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Icon(catIcon, color: catColor, size: 24),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentItem.title,
                              style: GoogleFonts.quicksand(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: txtClr,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${currentItem.category} • ${currentItem.type == TransactionType.expense ? "Pengeluaran" : "Pemasukan"}',
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
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (currentItem.isActive
                                  ? const Color(0xFF10B981)
                                  : Colors.grey)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentItem.isActive ? 'Aktif' : 'Dijeda',
                          style: GoogleFonts.quicksand(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: currentItem.isActive
                                ? const Color(0xFF10B981)
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Detail Info Cards (Two columns)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
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
                                'NOMINAL',
                                style: GoogleFonts.quicksand(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: subClr,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _formatRupiah(currentItem.amount),
                                  style: GoogleFonts.quicksand(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: txtClr,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getFreqLabel(currentItem.frequency),
                                style: GoogleFonts.quicksand(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: subClr,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
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
                                'JATUH TEMPO',
                                style: GoogleFonts.quicksand(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: subClr,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  DateFormat('d MMM yyyy', 'id_ID')
                                      .format(dueDate),
                                  style: GoogleFonts.quicksand(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: txtClr,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getDueDateStatusText(dueDate),
                                style: GoogleFonts.quicksand(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Monthly Equivalent Bar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Beban Rutin Per Bulan:',
                          style: GoogleFonts.quicksand(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: txtClr,
                          ),
                        ),
                        Text(
                          _formatRupiah(monthlyCost),
                          style: GoogleFonts.quicksand(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Action Buttons
                  // 1. Toggle Active / Pause
                  OutlinedButton.icon(
                    onPressed: () async {
                      final updated = currentItem.copyWith(
                        isActive: !currentItem.isActive,
                      );
                      final service = ref.read(recurringServiceProvider);
                      final items = await service.getRecurringTransactions();
                      final idx =
                          items.indexWhere((i) => i.id == currentItem.id);
                      if (idx != -1) {
                        items[idx] = updated;
                        await service.saveRecurringTransactions(items);
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                        showTopToast(
                          context,
                          updated.isActive
                              ? 'Langganan berhasil diaktifkan kembali'
                              : 'Langganan berhasil dijeda',
                        );
                      }
                      _loadData();
                    },
                    icon: Icon(
                      currentItem.isActive
                          ? Icons.pause_circle_outline_rounded
                          : Icons.play_circle_outline_rounded,
                      size: 18,
                    ),
                    label: Text(
                      currentItem.isActive
                          ? 'Jeda Sementara'
                          : 'Aktifkan Kembali',
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: currentItem.isActive
                          ? Colors.orange.shade700
                          : const Color(0xFF10B981),
                      side: BorderSide(
                        color: (currentItem.isActive
                                ? Colors.orange
                                : const Color(0xFF10B981))
                            .withValues(alpha: 0.35),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. Edit and Delete
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showAddOrEditSheet(itemToEdit: currentItem);
                          },
                          icon: const Icon(Icons.edit_outlined, size: 17),
                          label: Text(
                            'Ubah Data',
                            style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filledTonal(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: isDark
                                  ? AppColors.surfaceDark
                                  : Colors.white,
                              title: Text(
                                'Hapus Langganan?',
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              content: Text(
                                'Apakah Anda yakin ingin menghapus catatan langganan "${currentItem.title}"?',
                                style: GoogleFonts.quicksand(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(
                                    'Batal',
                                    style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.w700,
                                      color: subClr,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(
                                    'Hapus',
                                    style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFF43F5E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            Navigator.pop(context); // Close detail sheet
                            await ref
                                .read(recurringServiceProvider)
                                .deleteRecurring(currentItem.id);
                            if (context.mounted) {
                              showTopToast(
                                context,
                                'Langganan berhasil dihapus',
                              );
                            }
                            _loadData();
                          }
                        },
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFF43F5E),
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFF43F5E).withValues(alpha: 0.1),
                          minimumSize: const Size(48, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
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

  // ================= ADD / EDIT BOTTOM SHEET =================
  void _showAddOrEditSheet({RecurringTransactionModel? itemToEdit}) {
    final isEditing = itemToEdit != null;

    final titleCtrl = TextEditingController(text: itemToEdit?.title ?? '');
    final amountCtrl = TextEditingController(
      text: itemToEdit != null
          ? itemToEdit.amount.toInt().toString().replaceAllMapped(
                RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                (m) => '${m[1]}.',
              )
          : '',
    );

    TransactionType selectedType =
        itemToEdit?.type ?? TransactionType.expense;
    RecurringFrequency selectedFreq =
        itemToEdit?.frequency ?? RecurringFrequency.monthly;
    String selectedCategory = itemToEdit?.category ??
        (selectedType == TransactionType.expense
            ? _expenseCategories.first.label
            : _incomeCategories.first.label);

    DateTime selectedDate = itemToEdit?.startDate ?? DateTime.now();

    bool titleError = false;
    bool amountError = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final inset = MediaQuery.of(context).viewInsets.bottom;
          final sheetBg = isDark ? AppColors.surfaceDark : Colors.white;
          final txtClr = isDark ? Colors.white : const Color(0xFF1E293B);
          final subClr = isDark ? Colors.white54 : const Color(0xFF64748B);
          final divClr = isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06);

          final availableCategories = selectedType == TransactionType.expense
              ? _expenseCategories
              : _incomeCategories;

          final hasMatch = availableCategories.any((c) => c.label == selectedCategory);
          if (!hasMatch) {
            selectedCategory = availableCategories.first.label;
          }

          final isExpense = selectedType == TransactionType.expense;
          final typeColor =
              isExpense ? const Color(0xFFE74C3C) : const Color(0xFF2ECC71);
          final typeIcon = isExpense
              ? Icons.arrow_upward_rounded
              : Icons.arrow_downward_rounded;
          final typeLabel = isExpense ? 'Pengeluaran' : 'Pemasukan';

          return Container(
            padding: EdgeInsets.only(
              bottom: inset > 0
                  ? inset + 16
                  : MediaQuery.of(context).padding.bottom + 20,
              top: 14,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header Title
                  Text(
                    isEditing
                        ? 'Ubah Transaksi Rutin'
                        : 'Tambah Langganan Rutin',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: txtClr,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Row: Jenis Transaksi (Label di kiri, Dropdown Filter di kanan)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: divClr),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              size: 18,
                              color: isDark ? Colors.white70 : AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Jenis Transaksi:',
                              style: GoogleFonts.quicksand(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: txtClr,
                              ),
                            ),
                          ],
                        ),
                        // Dropdown 2 opsi bergaya filter riwayat
                        PopupMenuButton<TransactionType>(
                          initialValue: selectedType,
                          onSelected: (TransactionType val) {
                            setSheetState(() {
                              selectedType = val;
                              selectedCategory = val == TransactionType.expense
                                  ? _expenseCategories.first.label
                                  : _incomeCategories.first.label;
                            });
                          },
                          borderRadius: BorderRadius.circular(18),
                          offset: const Offset(0, 42),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          clipBehavior: Clip.antiAlias,
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          elevation: 6,
                          itemBuilder: (context) => [
                            PopupMenuItem<TransactionType>(
                              value: TransactionType.expense,
                              height: 44,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE74C3C)
                                          .withValues(alpha: isDark ? 0.2 : 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_upward_rounded,
                                      size: 14,
                                      color: Color(0xFFE74C3C),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Pengeluaran',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 12,
                                      fontWeight: isExpense
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: isExpense
                                          ? const Color(0xFFE74C3C)
                                          : (isDark
                                              ? Colors.white
                                              : Colors.black87),
                                    ),
                                  ),
                                  if (isExpense) ...[
                                    const Spacer(),
                                    const Icon(Icons.check_circle_rounded,
                                        size: 16, color: Color(0xFFE74C3C)),
                                  ],
                                ],
                              ),
                            ),
                            PopupMenuItem<TransactionType>(
                              value: TransactionType.income,
                              height: 44,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2ECC71)
                                          .withValues(alpha: isDark ? 0.2 : 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_downward_rounded,
                                      size: 14,
                                      color: Color(0xFF2ECC71),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Pemasukan',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 12,
                                      fontWeight: !isExpense
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: !isExpense
                                          ? const Color(0xFF2ECC71)
                                          : (isDark
                                              ? Colors.white
                                              : Colors.black87),
                                    ),
                                  ),
                                  if (!isExpense) ...[
                                    const Spacer(),
                                    const Icon(Icons.check_circle_rounded,
                                        size: 16, color: Color(0xFF2ECC71)),
                                  ],
                                ],
                              ),
                            ),
                          ],
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: typeColor
                                  .withValues(alpha: isDark ? 0.16 : 0.10),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: typeColor
                                    .withValues(alpha: isDark ? 0.45 : 0.28),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(typeIcon, size: 14, color: typeColor),
                                const SizedBox(width: 6),
                                Text(
                                  typeLabel,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : typeColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: isDark ? Colors.white70 : typeColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Field Nama
                  Text(
                    selectedType == TransactionType.expense
                        ? 'Nama Layanan / Langganan'
                        : 'Nama Pemasukan Rutin',
                    style: GoogleFonts.quicksand(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: txtClr,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleCtrl,
                    onChanged: (val) {
                      if (titleError && val.trim().isNotEmpty) {
                        setSheetState(() => titleError = false);
                      }
                    },
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: txtClr,
                    ),
                    decoration: InputDecoration(
                      hintText: selectedType == TransactionType.expense
                          ? 'Masukkan nama langganan'
                          : 'Masukkan nama pemasukan rutin',
                      hintStyle: GoogleFonts.quicksand(
                        fontSize: 12.5,
                        color: isDark ? Colors.white30 : Colors.black38,
                      ),
                      prefixIcon: Icon(
                        Icons.bookmark_outline_rounded,
                        size: 19,
                        color: titleError ? Colors.redAccent : AppColors.primary,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: titleError ? Colors.redAccent : divClr,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: titleError ? Colors.redAccent : divClr,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: titleError
                              ? Colors.redAccent
                              : AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 14,
                      ),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Field Nominal
                  Text(
                    selectedType == TransactionType.expense
                        ? 'Nominal Tagihan'
                        : 'Nominal Pemasukan',
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
                      const _RibuanFormatter(),
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
                        vertical: 12,
                        horizontal: 14,
                      ),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Frekuensi & Kategori (2 columns)
                  Row(
                    children: [
                      // Frekuensi
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Frekuensi Siklus',
                              style: GoogleFonts.quicksand(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: txtClr,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 46,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: divClr),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<RecurringFrequency>(
                                  value: selectedFreq,
                                  isExpanded: true,
                                  dropdownColor: isDark
                                      ? AppColors.surfaceDark
                                      : Colors.white,
                                  style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5,
                                    color: txtClr,
                                  ),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: subClr,
                                    size: 19,
                                  ),
                                  items: RecurringFrequency.values.map((f) {
                                    return DropdownMenuItem(
                                      value: f,
                                      child: Text(_getFreqLabel(f)),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setSheetState(() => selectedFreq = val);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Kategori
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kategori',
                              style: GoogleFonts.quicksand(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: txtClr,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 46,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: divClr),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedCategory,
                                  isExpanded: true,
                                  dropdownColor: isDark
                                      ? AppColors.surfaceDark
                                      : Colors.white,
                                  style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5,
                                    color: txtClr,
                                  ),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: subClr,
                                    size: 19,
                                  ),
                                  items: availableCategories.map((c) {
                                    return DropdownMenuItem<String>(
                                      value: c.label,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: c.color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              c.label,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setSheetState(
                                          () => selectedCategory = val);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Tanggal Mulai / Jatuh Tempo Pertama
                  Text(
                    'Tanggal Mulai / Jatuh Tempo',
                    style: GoogleFonts.quicksand(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: txtClr,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.fromSeed(
                                seedColor: AppColors.primary,
                                brightness: isDark
                                    ? Brightness.dark
                                    : Brightness.light,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setSheetState(() => selectedDate = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: divClr),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 17,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                                .format(selectedDate),
                            style: GoogleFonts.quicksand(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: txtClr,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 13,
                            color: subClr,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final titleVal = titleCtrl.text.trim();
                        final rawAmount =
                            amountCtrl.text.replaceAll('.', '').trim();
                        final amountVal = double.tryParse(rawAmount) ?? 0.0;

                        setSheetState(() {
                          titleError = titleVal.isEmpty;
                          amountError = amountVal <= 0;
                        });

                        if (titleError || amountError) {
                          showTopToast(
                            context,
                            titleError
                                ? 'Nama langganan tidak boleh kosong!'
                                : 'Nominal harus lebih dari 0!',
                            isError: true,
                          );
                          return;
                        }

                        final service = ref.read(recurringServiceProvider);
                        final items = await service.getRecurringTransactions();

                        if (isEditing) {
                          final updatedItem = itemToEdit.copyWith(
                            title: titleVal,
                            amount: amountVal,
                            type: selectedType,
                            category: selectedCategory,
                            frequency: selectedFreq,
                            startDate: selectedDate,
                          );
                          final idx =
                              items.indexWhere((i) => i.id == itemToEdit.id);
                          if (idx != -1) {
                            items[idx] = updatedItem;
                            await service.saveRecurringTransactions(items);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                            showTopToast(
                              context,
                              'Transaksi rutin berhasil diperbarui!',
                            );
                          }
                        } else {
                          final newItem = RecurringTransactionModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: titleVal,
                            amount: amountVal,
                            type: selectedType,
                            category: selectedCategory,
                            frequency: selectedFreq,
                            startDate: selectedDate,
                            lastProcessedDate: selectedDate,
                            isActive: true,
                          );
                          await service.addRecurring(newItem);
                          if (context.mounted) {
                            Navigator.pop(context);
                            showTopToast(
                              context,
                              'Langganan berhasil ditambahkan!',
                            );
                          }
                        }

                        _loadData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isEditing
                            ? 'Simpan Perubahan'
                            : 'Simpan Transaksi Rutin',
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
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
      ),
    );
  }
}

// Formatter ribuan dengan pemisah titik
class _RibuanFormatter extends TextInputFormatter {
  const _RibuanFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String cleanText = newValue.text.replaceAll('.', '');
    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final double? value = double.tryParse(cleanText);
    if (value == null) return oldValue;

    final formatter = NumberFormat('#,###', 'id_ID');
    String newFormatted = formatter.format(value).replaceAll(',', '.');

    return TextEditingValue(
      text: newFormatted,
      selection: TextSelection.collapsed(offset: newFormatted.length),
    );
  }
}
