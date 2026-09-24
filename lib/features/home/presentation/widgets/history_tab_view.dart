/// Widget: HistoryTabView
///
/// Tab riwayat transaksi yang mendukung pencarian, filter kategori
/// (Semua, Hutang/Piutang, Belanja), filter tipe, dan export bulanan.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/models/transaction_model.dart';

class HistoryTabView extends StatefulWidget {
  final List<TransactionModel> allTransactions;
  final bool isDarkMode;
  final Widget Function(TransactionModel) buildTransactionCard;
  final Widget Function(String, double, Color) miniHeaderStat;
  final String Function(double) formatRupiah;
  final String Function(double) formatCompact;
  final void Function(TransactionModel) onTransactionTap;
  final Future<void> Function({
    required List<TransactionModel> monthTx,
    required String monthLabel,
  }) onExportMonth;

  const HistoryTabView({
    super.key,
    required this.allTransactions,
    required this.isDarkMode,
    required this.buildTransactionCard,
    required this.miniHeaderStat,
    required this.formatRupiah,
    required this.formatCompact,
    required this.onTransactionTap,
    required this.onExportMonth,
  });

  @override
  State<HistoryTabView> createState() => _HistoryTabViewState();
}

class _HistoryTabViewState extends State<HistoryTabView> {
  int _filterIndex = 0;

  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  int _typeFilter = 0;

  int _debtTypeFilter = 0;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _isHutangPiutang(TransactionModel t) =>
      t.category == 'Hutang' || t.category == 'Piutang';
  bool _isBelanja(TransactionModel t) => t.id.startsWith('shopping_');
  bool _isRegular(TransactionModel t) => !_isHutangPiutang(t) && !_isBelanja(t);

  String _fmtCur(double amount) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
          .format(amount);

  @override
  Widget build(BuildContext context) {
    final sorted = [...widget.allTransactions]
      ..sort((a, b) => b.date.compareTo(a.date));

    final regularList = sorted.where(_isRegular).toList();
    final hutangList = sorted.where(_isHutangPiutang).toList();
    final belanjaList = sorted.where(_isBelanja).toList();
    final isDark = widget.isDarkMode;

    return Column(
      children: [
        _buildHistoryFilter(isDark, regularList, hutangList, belanjaList),
        _buildSearchBar(isDark, regularList),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildFilteredBody(
                sorted, regularList, hutangList, belanjaList, isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark, List<TransactionModel> regularList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Builder(builder: (context) {
            final isDk = isDark;
            return TextField(
              controller: _searchCtrl,
              style: GoogleFonts.quicksand(
                  fontSize: 11,
                  color: isDk ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Cari transaksi...',
                hintStyle: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: isDk ? Colors.white24 : Colors.black26,
                    fontWeight: FontWeight.bold),
                prefixIcon: Icon(Icons.search_rounded,
                    color: isDk ? Colors.white38 : Colors.black38, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded,
                            size: 18,
                            color: isDk ? Colors.white38 : Colors.black38),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDk
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                        color: isDk
                            ? Colors.white10
                            : Colors.black.withValues(alpha: 0.04))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5)),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        if (_filterIndex == 0 || _filterIndex == 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Filter Tipe:',
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 10),
                if (_filterIndex == 0)
                  _buildTypeDropdown(isDark)
                else if (_filterIndex == 1)
                  _buildDebtTypeDropdown(isDark),
              ],
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTypeDropdown(bool isDark) {
    final options = [
      {
        'val': 0,
        'label': 'Semua',
        'icon': Icons.receipt_long_rounded,
        'color': AppColors.primary
      },
      {
        'val': 1,
        'label': 'Pemasukan',
        'icon': Icons.arrow_downward_rounded,
        'color': const Color(0xFF2ECC71)
      },
      {
        'val': 2,
        'label': 'Pengeluaran',
        'icon': Icons.arrow_upward_rounded,
        'color': const Color(0xFFE74C3C)
      },
    ];

    final currentOption = options.firstWhere((e) => e['val'] == _typeFilter,
        orElse: () => options[0]);
    final currentColor = currentOption['color'] as Color;
    final currentIcon = currentOption['icon'] as IconData;
    final currentLabel = currentOption['label'] as String;

    return PopupMenuButton<int>(
      initialValue: _typeFilter,
      onSelected: (int val) {
        setState(() => _typeFilter = val);
      },
      borderRadius: BorderRadius.circular(20),
      offset: const Offset(0, 42),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      color: isDark ? AppColors.surfaceDark : Colors.white,
      elevation: 6,
      itemBuilder: (context) => options.map((opt) {
        final val = opt['val'] as int;
        final selected = _typeFilter == val;
        final color = opt['color'] as Color;
        return PopupMenuItem<int>(
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

  Widget _buildDebtTypeDropdown(bool isDark) {
    final options = [
      {
        'val': 0,
        'label': 'Semua',
        'icon': Icons.receipt_long_rounded,
        'color': AppColors.primary
      },
      {
        'val': 1,
        'label': 'Hutang',
        'icon': Icons.call_made_rounded,
        'color': const Color(0xFFE74C3C)
      },
      {
        'val': 2,
        'label': 'Piutang',
        'icon': Icons.call_received_rounded,
        'color': const Color(0xFF2ECC71)
      },
    ];

    final currentOption = options.firstWhere((e) => e['val'] == _debtTypeFilter,
        orElse: () => options[0]);
    final currentColor = currentOption['color'] as Color;
    final currentIcon = currentOption['icon'] as IconData;
    final currentLabel = currentOption['label'] as String;

    return PopupMenuButton<int>(
      initialValue: _debtTypeFilter,
      onSelected: (int val) {
        setState(() => _debtTypeFilter = val);
      },
      borderRadius: BorderRadius.circular(20),
      offset: const Offset(0, 42),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      color: isDark ? AppColors.surfaceDark : Colors.white,
      elevation: 6,
      itemBuilder: (context) => options.map((opt) {
        final val = opt['val'] as int;
        final selected = _debtTypeFilter == val;
        final color = opt['color'] as Color;
        return PopupMenuItem<int>(
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

  Widget _buildHistoryFilter(bool isDark, List<TransactionModel> regularList,
      List<TransactionModel> hutangList, List<TransactionModel> belanjaList) {
    final categories = [
      'Pemasukan & Pengeluaran',
      'Hutang & Piutang',
      'Belanja'
    ];
    final categoryIcons = [
      Icons.account_balance_rounded,
      Icons.account_balance_wallet_rounded,
      Icons.shopping_basket_rounded
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () async {
                final RenderBox button =
                    context.findRenderObject() as RenderBox;
                final RenderBox overlay = Navigator.of(context)
                    .overlay!
                    .context
                    .findRenderObject() as RenderBox;
                final RelativeRect position = RelativeRect.fromRect(
                  Rect.fromPoints(
                    button.localToGlobal(const Offset(0, 45),
                        ancestor: overlay),
                    button.localToGlobal(button.size.bottomRight(Offset.zero),
                        ancestor: overlay),
                  ),
                  Offset.zero & overlay.size,
                );

                final int? result = await showMenu<int>(
                  context: context,
                  position: position,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  clipBehavior: Clip.antiAlias,
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  elevation: 8,
                  items: [
                    for (int i = 0; i < categories.length; i++)
                      PopupMenuItem(
                        value: i,
                        padding: EdgeInsets.zero,
                        height: 52,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context, i),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(categoryIcons[i],
                                    size: 18,
                                    color: _filterIndex == i
                                        ? AppColors.primary
                                        : (isDark
                                            ? Colors.white38
                                            : Colors.black38)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(categories[i],
                                      style: GoogleFonts.quicksand(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _filterIndex == i
                                            ? AppColors.primary
                                            : (isDark
                                                ? Colors.white
                                                : Colors.black87),
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
                if (result != null && mounted) {
                  setState(() => _filterIndex = result);
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: 0.03)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(categoryIcons[_filterIndex],
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      categories[_filterIndex],
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: isDark ? Colors.white38 : Colors.black38),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _filterIndex == 0
                  ? '${regularList.length} Item'
                  : (_filterIndex == 1
                      ? '${hutangList.length} Item'
                      : '${belanjaList.length} Item'),
              style: GoogleFonts.quicksand(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredBody(
      List<TransactionModel> allSorted,
      List<TransactionModel> regularList,
      List<TransactionModel> hutangList,
      List<TransactionModel> belanjaList,
      bool isDark) {
    switch (_filterIndex) {
      case 0:
        return _buildRegularTab(allSorted, regularList, isDark);
      case 1:
        return _buildHutangTab(hutangList, isDark);
      case 2:
        return _buildBelanjaTab(belanjaList, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRegularTab(List<TransactionModel> allSorted,
      List<TransactionModel> regularList, bool isDark) {
    final filtered = regularList.where((t) {
      if (_typeFilter == 1 && t.type != TransactionType.income) {
        return false;
      }
      if (_typeFilter == 2 && t.type != TransactionType.expense) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery;
        if (!t.title.toLowerCase().contains(q) &&
            !t.category.toLowerCase().contains(q) &&
            !t.description.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    final isFiltering = _searchQuery.isNotEmpty || _typeFilter != 0;

    if (regularList.isEmpty) {
      return _emptyState(isDark,
          icon: Icons.receipt_long_outlined,
          label: 'Belum ada pemasukan/pengeluaran');
    }

    if (filtered.isEmpty && isFiltering) {
      return _emptyState(isDark,
          icon: Icons.search_off_rounded,
          label: 'Tidak ada hasil',
          subtitle: 'Coba ubah kata kunci atau hapus filter');
    }

    final Map<String, List<TransactionModel>> grouped = {};
    for (final t in filtered) {
      final k = DateFormat('MMMM yyyy', 'id_ID').format(t.date).toUpperCase();
      grouped.putIfAbsent(k, () => []).add(t);
    }

    final Map<String, List<TransactionModel>> allGrouped = {};
    for (final t in allSorted) {
      final k = DateFormat('MMMM yyyy', 'id_ID').format(t.date).toUpperCase();
      allGrouped.putIfAbsent(k, () => []).add(t);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
      itemCount: grouped.keys.length,
      itemBuilder: (context, i) {
        final monthKey = grouped.keys.elementAt(i);
        final monthTx = grouped[monthKey]!;
        final allMonthTx = allGrouped[monthKey] ?? monthTx;

        final totalIn = allMonthTx
            .where((t) => t.type == TransactionType.income)
            .fold(0.0, (s, t) => s + t.amount);
        final totalOut = allMonthTx
            .where((t) => t.type == TransactionType.expense)
            .fold(0.0, (s, t) => s + t.amount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(monthKey,
                            style: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white60
                                    : Colors.teal.shade900,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            widget.miniHeaderStat(
                                'MASUK',
                                totalIn,
                                isDark
                                    ? Colors.greenAccent.shade400
                                    : Colors.green),
                            widget.miniHeaderStat(
                                'KELUAR',
                                totalOut,
                                isDark
                                    ? Colors.redAccent.shade200
                                    : Colors.red),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ...monthTx.map((t) => widget.buildTransactionCard(t)),
          ],
        );
      },
    );
  }

  Widget _buildHutangTab(List<TransactionModel> list, bool isDark) {
    if (list.isEmpty) {
      return _emptyState(isDark,
          icon: Icons.account_balance_wallet_outlined,
          label: 'Belum ada riwayat hutang/piutang',
          subtitle: 'Muncul saat hutang/piutang ditandai lunas');
    }

    final filtered = list.where((t) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!t.title.toLowerCase().contains(q) &&
            !t.category.toLowerCase().contains(q) &&
            !t.description.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    if (filtered.isEmpty && _searchQuery.isNotEmpty) {
      return _emptyState(isDark,
          icon: Icons.search_off_rounded,
          label: 'Tidak ada hasil',
          subtitle: 'Coba ubah kata kunci pencarian Anda');
    }

    final hutangOnly = filtered.where((t) => t.category == 'Hutang').toList();
    final piutangOnly = filtered.where((t) => t.category == 'Piutang').toList();
    final totalH = hutangOnly.fold(0.0, (s, t) => s + t.amount);
    final totalP = piutangOnly.fold(0.0, (s, t) => s + t.amount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Expanded(
                  child: _sumItemMinimalist(isDark,
                      label: 'HUTANG DIBAYAR',
                      amount: totalH,
                      color: Colors.red.shade400)),
              Container(
                  width: 1,
                  height: 30,
                  color: isDark ? Colors.white12 : Colors.grey.shade200),
              Expanded(
                  child: _sumItemMinimalist(isDark,
                      label: 'PIUTANG DITERIMA',
                      amount: totalP,
                      color: Colors.green.shade400)),
            ],
          ),
        ),
        if ((_debtTypeFilter == 0 || _debtTypeFilter == 1) &&
            hutangOnly.isNotEmpty) ...[
          ...hutangOnly.map((t) => _debtCard(t, isDark)),
        ],
        if ((_debtTypeFilter == 0 || _debtTypeFilter == 2) &&
            piutangOnly.isNotEmpty) ...[
          ...piutangOnly.map((t) => _debtCard(t, isDark)),
        ],
      ],
    );
  }

  Widget _buildBelanjaTab(List<TransactionModel> list, bool isDark) {
    if (list.isEmpty) {
      return _emptyState(isDark,
          icon: Icons.shopping_bag_outlined,
          label: 'Belum ada riwayat belanja',
          subtitle: 'Muncul saat item belanja ditandai dibeli');
    }

    final filtered = list.where((t) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!t.title.toLowerCase().contains(q) &&
            !t.category.toLowerCase().contains(q) &&
            !t.description.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    if (filtered.isEmpty && _searchQuery.isNotEmpty) {
      return _emptyState(isDark,
          icon: Icons.search_off_rounded,
          label: 'Tidak ada hasil',
          subtitle: 'Coba ubah kata kunci pencarian Anda');
    }

    final total = filtered.fold(0.0, (s, t) => s + t.amount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Expanded(
                  child: _sumItemMinimalist(isDark,
                      label: 'TOTAL BELANJA',
                      amount: total,
                      color: AppColors.primary)),
              Container(
                  width: 1,
                  height: 30,
                  color: isDark ? Colors.white12 : Colors.grey.shade200),
              Expanded(
                  child: _sumItemMinimalist(isDark,
                      label: 'JUMLAH ITEM',
                      amount: filtered.length.toDouble(),
                      isCurrency: false,
                      color: isDark ? Colors.white38 : Colors.black38)),
            ],
          ),
        ),
        ...filtered.map((t) => _shoppingCard(t, isDark)),
      ],
    );
  }

  Widget _debtCard(TransactionModel t, bool isDark) {
    final isHutang = t.category == 'Hutang';
    final color = isHutang ? Colors.red.shade400 : Colors.green.shade400;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => widget.onTransactionTap(t),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13)),
                  child: Icon(
                      isHutang
                          ? Icons.call_made_rounded
                          : Icons.call_received_rounded,
                      color: color,
                      size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.title,
                          style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87)),
                      if (t.description.isNotEmpty)
                        Text(t.description,
                            style: GoogleFonts.quicksand(
                                fontSize: 11,
                                color:
                                    isDark ? Colors.white38 : Colors.black38)),
                      Text('#${t.id.replaceAll('paid_debt_', '')}',
                          style: GoogleFonts.quicksand(
                              fontSize: 9,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.grey.shade400)),
                    ],
                  ),
                ),
                Text(_fmtCur(t.amount),
                    style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _shoppingCard(TransactionModel t, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => widget.onTransactionTap(t),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(13)),
                  child: const Icon(Icons.shopping_bag_rounded,
                      color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(t.title,
                      style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87)),
                ),
                Text(_fmtCur(t.amount),
                    style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sumItemMinimalist(bool isDark,
      {required String label,
      required double amount,
      required Color color,
      bool isCurrency = true}) {
    return Column(children: [
      Text(label,
          style: GoogleFonts.quicksand(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: isDark ? Colors.white38 : Colors.black38)),
      const SizedBox(height: 5),
      Text(isCurrency ? _fmtCur(amount) : amount.toInt().toString(),
          style: GoogleFonts.quicksand(
              fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    ]);
  }

  Widget _emptyState(bool isDark,
      {required IconData icon, required String label, String? subtitle}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle),
            child: Icon(icon,
                size: 60, color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 20),
          Text(label,
              style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white38 : Colors.black38)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                      fontSize: 11,
                      color: isDark ? Colors.white24 : Colors.black26)),
            ),
          ],
        ],
      ),
    );
  }
}

