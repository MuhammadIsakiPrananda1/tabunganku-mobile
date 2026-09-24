/// Page: ShoppingBudgetPage
///
/// Anggaran dan daftar belanja terencana.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';

class _ShoppingItem {
  final String name;
  final double budget;
  double spent;
  final String category;

  _ShoppingItem({
    required this.name,
    required this.budget,
    this.spent = 0,
    required this.category,
  });

  double get remaining => budget - spent;
  double get percentage => budget > 0 ? (spent / budget).clamp(0, 1) : 0;

  String toRaw() =>
      '$name||$budget||$spent||$category';

  factory _ShoppingItem.fromRaw(String raw) {
    final parts = raw.split('||');
    if (parts.length < 4) throw Exception('Invalid format');
    return _ShoppingItem(
      name: parts[0],
      budget: double.tryParse(parts[1]) ?? 0,
      spent: double.tryParse(parts[2]) ?? 0,
      category: parts[3],
    );
  }
}

const _categories = [
  {'label': 'Kebutuhan', 'icon': Icons.shopping_basket_rounded, 'color': Color(0xFF00BFA5)},
  {'label': 'Hiburan', 'icon': Icons.movie_rounded, 'color': Color(0xFF9C27B0)},
  {'label': 'Fashion', 'icon': Icons.checkroom_rounded, 'color': Color(0xFFE91E63)},
  {'label': 'Elektronik', 'icon': Icons.devices_rounded, 'color': Color(0xFF2196F3)},
  {'label': 'Makanan', 'icon': Icons.restaurant_rounded, 'color': Color(0xFFFFA500)},
  {'label': 'Lainnya', 'icon': Icons.category_rounded, 'color': Color(0xFF607D8B)},
];

class ShoppingBudgetPage extends ConsumerStatefulWidget {
  const ShoppingBudgetPage({super.key});

  @override
  ConsumerState<ShoppingBudgetPage> createState() => _ShoppingBudgetPageState();
}

class _ShoppingBudgetPageState extends ConsumerState<ShoppingBudgetPage> {
  List<_ShoppingItem> _items = [];
  bool _isLoading = true;

  final _fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  double get _totalBudget => _items.fold(0, (s, i) => s + i.budget);
  double get _totalSpent => _items.fold(0, (s, i) => s + i.spent);
  double get _totalRemaining => _totalBudget - _totalSpent;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('shopping_budget_items') ?? [];
    setState(() {
      _items = raw
          .map((r) {
            try {
              return _ShoppingItem.fromRaw(r);
            } catch (_) {
              return null;
            }
          })
          .whereType<_ShoppingItem>()
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'shopping_budget_items', _items.map((i) => i.toRaw()).toList());
  }

  void _showAddItemSheet(bool isDark) {
    final nameCtrl = TextEditingController();
    final budgetCtrl = TextEditingController();
    String selectedCategory = 'Kebutuhan';

    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
          final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
          final textSecondary =
              isDark ? Colors.white60 : AppColors.textSecondary;

          return Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom > 0 ? MediaQuery.of(ctx).viewInsets.bottom : MediaQuery.of(ctx).padding.bottom),
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Tambah Budget Belanja',
                      style: GoogleFonts.quicksand(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: textPrimary)),
                  const SizedBox(height: 16),

                  // Nama item
                  TextField(
                    controller: nameCtrl,
                    style: GoogleFonts.quicksand(
                        color: textPrimary, fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Nama Belanjaan',
                      labelStyle: GoogleFonts.quicksand(
                          color: textSecondary, fontSize: 13),
                      prefixIcon: const Icon(Icons.shopping_bag_outlined,
                          color: AppColors.primary, size: 20),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFF5FAF9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Budget
                  TextField(
                    controller: budgetCtrl,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.quicksand(
                        color: textPrimary, fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Budget (Rp)',
                      labelStyle: GoogleFonts.quicksand(
                          color: textSecondary, fontSize: 13),
                      prefixIcon: const Icon(Icons.wallet_outlined,
                          color: AppColors.primary, size: 20),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFF5FAF9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Kategori
                  Text('Kategori',
                      style: GoogleFonts.quicksand(
                          fontSize: 12, color: textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = selectedCategory == cat['label'];
                      return GestureDetector(
                        onTap: () => setSheet(
                            () => selectedCategory = cat['label'] as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (cat['color'] as Color)
                                    .withValues(alpha: 0.15)
                                : (isDark
                                    ? const Color(0xFF2A2A2A)
                                    : const Color(0xFFF5F5F5)),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? cat['color'] as Color
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(cat['icon'] as IconData,
                                  size: 14,
                                  color: isSelected
                                      ? cat['color'] as Color
                                      : textSecondary),
                              const SizedBox(width: 4),
                              Text(cat['label'] as String,
                                  style: GoogleFonts.quicksand(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? cat['color'] as Color
                                          : textSecondary)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        final budget = double.tryParse(budgetCtrl.text
                                .replaceAll(RegExp(r'[^\d]'), '')) ??
                            0;
                        if (name.isEmpty || budget <= 0) return;
                        setState(() {
                          _items.add(_ShoppingItem(
                            name: name,
                            budget: budget,
                            category: selectedCategory,
                          ));
                        });
                        _saveData();
                        Navigator.pop(ctx);
                        HapticFeedback.mediumImpact();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text('Simpan',
                          style: GoogleFonts.quicksand(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
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

  void _showAddSpendingDialog(bool isDark, int index) {
    final item = _items[index];
    final spentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
        final textSecondary = isDark ? Colors.white60 : AppColors.textSecondary;

        return AlertDialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: Text('Tambah Pengeluaran',
              style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${item.name}\nSisa: ${_fmt.format(item.remaining)}',
                  style: GoogleFonts.quicksand(
                      fontSize: 13, color: textSecondary)),
              const SizedBox(height: 12),
              TextField(
                controller: spentCtrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: GoogleFonts.quicksand(color: textPrimary),
                decoration: InputDecoration(
                  labelText: 'Nominal (Rp)',
                  labelStyle: GoogleFonts.quicksand(
                      color: textSecondary, fontSize: 13),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFF5FAF9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal',
                  style: GoogleFonts.quicksand(color: textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final add = double.tryParse(
                        spentCtrl.text.replaceAll(RegExp(r'[^\d]'), '')) ??
                    0;
                if (add <= 0) return;
                setState(() => _items[index].spent += add);
                _saveData();
                Navigator.pop(ctx);
                HapticFeedback.lightImpact();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text('Tambah',
                  style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    final bg = isDark ? AppColors.backgroundDark : const Color(0xFFF8FAF9);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? Colors.white60 : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Budget Belanja',
            style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded,
                color: AppColors.primary, size: 28),
            onPressed: () => _showAddItemSheet(isDark),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary card
                  if (_items.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _totalSpent > _totalBudget
                              ? [const Color(0xFFE53935), const Color(0xFFC62828)]
                              : [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: (_totalSpent > _totalBudget
                                    ? const Color(0xFFE53935)
                                    : AppColors.primary)
                                .withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Budget',
                                      style: GoogleFonts.quicksand(
                                          color: Colors.white70,
                                          fontSize: 12)),
                                  Text(_fmt.format(_totalBudget),
                                      style: GoogleFonts.quicksand(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Terpakai',
                                      style: GoogleFonts.quicksand(
                                          color: Colors.white70,
                                          fontSize: 12)),
                                  Text(_fmt.format(_totalSpent),
                                      style: GoogleFonts.quicksand(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _totalBudget > 0
                                  ? (_totalSpent / _totalBudget).clamp(0, 1)
                                  : 0,
                              minHeight: 8,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _totalRemaining >= 0
                                    ? 'Sisa ${_fmt.format(_totalRemaining)}'
                                    : 'Melebihi ${_fmt.format(_totalRemaining.abs())}',
                                style: GoogleFonts.quicksand(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${(_totalBudget > 0 ? (_totalSpent / _totalBudget * 100) : 0).toStringAsFixed(0)}%',
                                style: GoogleFonts.quicksand(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text('Daftar Belanjaan',
                        style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textPrimary)),
                    const SizedBox(height: 12),
                  ],

                  if (_items.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.shopping_cart_outlined,
                                  size: 56, color: AppColors.primary),
                            ),
                            const SizedBox(height: 20),
                            Text('Belum ada budget belanja',
                                style: GoogleFonts.quicksand(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary)),
                            const SizedBox(height: 8),
                            Text('Tambahkan budget untuk\nsetiap kebutuhan belanjamu',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.quicksand(
                                    fontSize: 13, color: textSecondary)),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => _showAddItemSheet(isDark),
                              icon: const Icon(Icons.add_rounded,
                                  color: Colors.white, size: 18),
                              label: Text('Buat Budget',
                                  style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...List.generate(_items.length, (i) {
                      final item = _items[i];
                      final cat = _categories.firstWhere(
                          (c) => c['label'] == item.category,
                          orElse: () => _categories.last);
                      final isOver = item.spent > item.budget;
                      final color = isOver
                          ? const Color(0xFFE53935)
                          : cat['color'] as Color;

                      return Dismissible(
                        key: Key('${item.name}_$i'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_rounded,
                              color: Color(0xFFE53935)),
                        ),
                        onDismissed: (_) {
                          setState(() => _items.removeAt(i));
                          _saveData();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: isDark ? 0.15 : 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color:
                                          color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(cat['icon'] as IconData,
                                        color: color, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name,
                                            style: GoogleFonts.quicksand(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: textPrimary)),
                                        Text(item.category,
                                            style: GoogleFonts.quicksand(
                                                fontSize: 11,
                                                color: textSecondary)),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        _showAddSpendingDialog(isDark, i),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color:
                                            color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text('+ Catat',
                                          style: GoogleFonts.quicksand(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: color)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_fmt.format(item.spent),
                                      style: GoogleFonts.quicksand(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: color)),
                                  Text(
                                      isOver
                                          ? 'Melebihi ${_fmt.format((item.spent - item.budget).abs())}'
                                          : 'Sisa ${_fmt.format(item.remaining)}',
                                      style: GoogleFonts.quicksand(
                                          fontSize: 12,
                                          color: isOver
                                              ? const Color(0xFFE53935)
                                              : textSecondary)),
                                  Text(_fmt.format(item.budget),
                                      style: GoogleFonts.quicksand(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: textPrimary)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: item.percentage,
                                  minHeight: 6,
                                  backgroundColor: color.withValues(alpha: 0.12),
                                  valueColor: AlwaysStoppedAnimation<Color>(color),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
      floatingActionButton: _items.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _showAddItemSheet(isDark),
              backgroundColor: AppColors.primary,
              elevation: 4,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
    );
  }
}

