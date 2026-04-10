import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/budget_model.dart';
import 'package:tabunganku/providers/budget_provider.dart';
import 'package:tabunganku/core/utils/currency_formatter.dart';

// ────────────────────────────────────────────────────────────────────────────

class BudgetFormSheet extends ConsumerStatefulWidget {
  final BudgetModel? budget;
  final String? initialCategory;

  const BudgetFormSheet({super.key, this.budget, this.initialCategory});

  static Future<void> show(BuildContext context,
      {BudgetModel? budget, String? initialCategory}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          BudgetFormSheet(budget: budget, initialCategory: initialCategory),
    );
  }

  @override
  ConsumerState<BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends ConsumerState<BudgetFormSheet> {
  final _amountController = TextEditingController();
  final _customCategoryController = TextEditingController();
  String? _selectedCategory;
  bool _isCustomCategory = false;

  static const _fixedCategories = [
    {'label': 'Makan', 'icon': Icons.restaurant_rounded},
    {'label': 'Transport', 'icon': Icons.directions_bus_rounded},
    {'label': 'Belanja', 'icon': Icons.shopping_bag_rounded},
    {'label': 'Tagihan', 'icon': Icons.receipt_rounded},
    {'label': 'Hiburan', 'icon': Icons.movie_rounded},
    {'label': 'Kopi', 'icon': Icons.coffee_rounded},
    {'label': 'Kesehatan', 'icon': Icons.medical_services_rounded},
    {'label': 'Pendidikan', 'icon': Icons.school_rounded},
    {'label': 'Hobi', 'icon': Icons.sports_esports_rounded},
    {'label': 'Cicilan', 'icon': Icons.credit_card_rounded},
    {'label': 'Zakat', 'icon': Icons.volunteer_activism_rounded},
    {'label': 'Keperluan Rumah', 'icon': Icons.home_work_rounded},
    {'label': 'Pulsa/Data', 'icon': Icons.tap_and_play_rounded},
    {'label': 'Lainnya', 'icon': Icons.edit_note_rounded},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      final rawAmount = widget.budget!.limitAmount.toInt().toString();
      // Format dengan titik saat load existing
      final formatted = rawAmount.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
      _amountController.text = formatted;

      final existingCat = widget.budget!.category;
      final isKnown =
          _fixedCategories.any((c) => c['label'] == existingCat) &&
              existingCat != 'Lainnya';
      if (isKnown) {
        _selectedCategory = existingCat;
        _isCustomCategory = false;
      } else {
        _selectedCategory = 'Lainnya';
        _isCustomCategory = true;
        _customCategoryController.text =
            existingCat == 'Lainnya' ? '' : existingCat;
      }
    } else if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  String get _effectiveCategory {
    if (_isCustomCategory) {
      final custom = _customCategoryController.text.trim();
      return custom.isEmpty ? 'Lainnya' : custom;
    }
    return _selectedCategory ?? '';
  }

  Future<void> _saveBudget() async {
    final amountRaw =
        _amountController.text.replaceAll('.', '').replaceAll(',', '');
    final amount = double.tryParse(amountRaw) ?? 0;
    if (amount <= 0) return;
    if (_effectiveCategory.isEmpty) return;

    final now = DateTime.now();
    final budget = BudgetModel(
      id: widget.budget?.id ??
          'budget_${DateTime.now().millisecondsSinceEpoch}',
      category: _effectiveCategory,
      limitAmount: amount,
      month: now.month,
      year: now.year,
    );

    await ref.read(budgetServiceProvider).saveBudget(budget);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _deleteBudget() async {
    if (widget.budget == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Budget?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Hapus budget kategori "${widget.budget!.category}"?\nLangkah ini tidak bisa dibatalkan.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref
          .read(budgetServiceProvider)
          .deleteBudget(widget.budget!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);
    final inset = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.budget != null;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(bottom: inset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Header: judul + tombol hapus (jika edit)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Budget' : 'Set Budget Bulanan',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (isEditing)
                    IconButton(
                      onPressed: _deleteBudget,
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Colors.red),
                      tooltip: 'Hapus budget ini',
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Pilih Kategori ────────────────────────────────────────────
            SizedBox(
              height: 100,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _fixedCategories.length,
                itemBuilder: (context, index) {
                  final cat = _fixedCategories[index];
                  final label = cat['label'] as String;
                  final isLainnya = label == 'Lainnya';
                  final isSelected = _selectedCategory == label;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = label;
                        _isCustomCategory = isLainnya;
                      });
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDarkMode
                                  ? Colors.white10
                                  : Colors.grey.shade200),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            cat['icon'] as IconData,
                            color: isSelected
                                ? AppColors.primary
                                : (isDarkMode
                                    ? Colors.white30
                                    : Colors.grey),
                            size: 28,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDarkMode
                                      ? Colors.white30
                                      : Colors.grey),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Custom kategori input (muncul jika "Lainnya" dipilih) ─────
            if (_isCustomCategory) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _customCategoryController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Nama Kategori Custom',
                    hintText: 'cth: Gym, Netflix, Skincare...',
                    prefixIcon: const Icon(Icons.label_outline_rounded,
                        color: AppColors.primary),
                    filled: true,
                    fillColor: isDarkMode
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: TextStyle(
                      color: isDarkMode ? Colors.white38 : Colors.black45,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 28),

            // ── Input Nominal ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white10
                        : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // "Rp" prefix — selalu terlihat
                    const Text(
                      'Rp',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          RibuanFormatter(),
                        ],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.white12
                                : Colors.grey.shade300,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Tombol Simpan ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveBudget,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    isEditing ? 'Perbarui Budget' : 'Simpan Budget',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
