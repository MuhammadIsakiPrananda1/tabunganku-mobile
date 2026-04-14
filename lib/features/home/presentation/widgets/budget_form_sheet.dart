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
    {'label': 'Makanan & Minuman', 'icon': Icons.fastfood_rounded},
    {'label': 'Transportasi', 'icon': Icons.directions_car_rounded},
    {'label': 'Kebutuhan Rumah', 'icon': Icons.home_work_rounded},
    {'label': 'Belanja Bulanan', 'icon': Icons.shopping_cart_rounded},
    {'label': 'Tagihan & Listrik', 'icon': Icons.bolt_rounded},
    {'label': 'Hiburan & Hobi', 'icon': Icons.smart_display_rounded},
    {'label': 'Kesehatan', 'icon': Icons.medical_services_rounded},
    {'label': 'Pendidikan', 'icon': Icons.school_rounded},
    {'label': 'Zakat & Sedekah', 'icon': Icons.volunteer_activism_rounded},
    {'label': 'Cicilan & Hutang', 'icon': Icons.credit_card_rounded},
    {'label': 'Pulsa & Internet', 'icon': Icons.wifi_rounded},
    {'label': 'Perbaikan Rumah', 'icon': Icons.home_repair_service_rounded},
    {'label': 'Gaya Hidup', 'icon': Icons.style_rounded},
    {'label': 'Biaya Admin', 'icon': Icons.account_balance_rounded},
    {'label': 'Lain-lain', 'icon': Icons.more_horiz_rounded},
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: inset + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Handle bar
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),

            // Header: judul + tombol hapus (jika edit)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit_calendar_rounded : Icons.add_chart_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Perbarui Budget' : 'Budget Baru',
                          style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : AppColors.primaryDark,
                          ),
                        ),
                        Text(
                          'Atur batas pengeluaran bulanan Anda',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white38 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isEditing)
                    IconButton(
                      onPressed: _deleteBudget,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                      ),
                      tooltip: 'Hapus budget ini',
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Pilih Kategori ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Pilih Kategori',
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 110,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _fixedCategories.length,
                itemBuilder: (context, index) {
                  final cat = _fixedCategories[index];
                  final label = cat['label'] as String;
                  final isLainnya = label == 'Lainnya';
                  final isSelected = _selectedCategory == label;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedCategory = label;
                        _isCustomCategory = isLainnya;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 85,
                      margin: const EdgeInsets.only(right: 16, bottom: 8, top: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          else
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                        ],
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            cat['icon'] as IconData,
                            color: isSelected
                                ? Colors.white
                                : (isDarkMode ? Colors.white30 : Colors.grey.shade600),
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isDarkMode ? Colors.white38 : Colors.grey.shade700),
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

            // ── Custom kategori input ─────
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
                    labelText: 'Nama Kategori Kustom',
                    hintText: 'Misal: Gym, Netflix, Skincare...',
                    prefixIcon: const Icon(Icons.label_outline_rounded, color: AppColors.primary),
                    filled: true,
                    fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // ── Input Nominal ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Limit Anggaran',
                    style: TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Rp',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              RibuanFormatter(),
                            ],
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: isDarkMode ? Colors.white : Colors.black87,
                              letterSpacing: -0.5,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0',
                              hintStyle: TextStyle(
                                color: isDarkMode ? Colors.white12 : Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // ── Tombol Simpan ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _saveBudget,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 10,
                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isEditing ? Icons.update_rounded : Icons.check_circle_rounded, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        isEditing ? 'Perbarui Anggaran' : 'Simpan Anggaran',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
