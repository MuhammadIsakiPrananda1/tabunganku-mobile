import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/budget_model.dart';
import 'package:tabunganku/providers/budget_provider.dart';
import 'package:tabunganku/core/utils/currency_formatter.dart';
import 'package:tabunganku/core/constants/transaction_categories.dart';
import 'package:google_fonts/google_fonts.dart';

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
  String? _selectedGroup;
  bool _isCustomCategory = false;
  bool _amountHasError = false;

  static final _fixedCategories = AppCategories.expenseCategories
      .map((c) => {'label': c.label, 'icon': c.icon})
      .toList();

  final Map<String, List<TransactionCategory>> groupedCategories = {};

  @override
  void initState() {
    super.initState();

for (var cat in AppCategories.expenseCategories) {
      groupedCategories.putIfAbsent(cat.group, () => []).add(cat);
    }
    
    if (widget.budget != null) {
      final rawAmount = widget.budget!.limitAmount.toInt().toString();

      final formatted = rawAmount.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
      _amountController.text = formatted;

      final existingCat = widget.budget!.category;
      final isKnown =
          _fixedCategories.any((c) => c['label'] == existingCat) &&
              existingCat != AppCategories.otherLabel;
      if (isKnown) {
        _selectedCategory = existingCat;
        _isCustomCategory = false;

        _selectedGroup = AppCategories.expenseCategories.firstWhere((c) => c.label == existingCat).group;
      } else {
        _selectedCategory = AppCategories.otherLabel;
        _isCustomCategory = true;
        _customCategoryController.text =
            existingCat == AppCategories.otherLabel ? '' : existingCat;
        _selectedGroup = AppCategories.expenseCategories.firstWhere((c) => c.label == AppCategories.otherLabel).group;
      }
    } else if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory;
      try {
        _selectedGroup = AppCategories.expenseCategories.firstWhere((c) => c.label == _selectedCategory).group;
      } catch (_) {
        _selectedGroup = AppCategories.expenseCategories.first.group;
      }
    } else {

      _selectedCategory = 'Makanan & Minuman';
      _selectedGroup = 'Kebutuhan Pokok';
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
      return custom.isEmpty ? AppCategories.otherLabel : custom;
    }
    return _selectedCategory ?? '';
  }

  Future<void> _saveBudget() async {
    final amountRaw =
        _amountController.text.replaceAll('.', '').replaceAll(',', '');
    final amount = double.tryParse(amountRaw) ?? 0;
    if (amount <= 0) {
      setState(() {
        _amountHasError = true;
      });
      return;
    }
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
          style: const TextStyle(fontSize: 11),
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
      padding: EdgeInsets.only(bottom: inset > 0 ? inset : MediaQuery.of(context).padding.bottom > 0 ? inset + 24 : 24 + MediaQuery.of(context).padding.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white10 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      isEditing ? 'Perbarui Anggaran' : 'Anggaran Baru',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        color: isDarkMode ? Colors.white : Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  if (isEditing)
                    Positioned(
                      right: 0,
                      child: IconButton(
                        onPressed: _deleteBudget,
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                        ),
                        tooltip: 'Hapus budget ini',
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white70 : Colors.black87),
                      children: const [
                        TextSpan(text: 'Kategori Anggaran '),
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      _showCategorySearchSheet(
                        context: context,
                        isDarkMode: isDarkMode,
                        currentSelected: _selectedCategory ?? '',
                        categoryObjects: AppCategories.expenseCategories,
                        onSelected: (cat) {
                          setState(() {
                            _selectedCategory = cat.label;
                            _selectedGroup = cat.group;
                            _isCustomCategory = cat.label == AppCategories.otherLabel;
                          });
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.white24
                              : Colors.black26,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            AppCategories.expenseCategories.any((c) =>
                                    c.label == _selectedCategory)
                                ? AppCategories.expenseCategories
                                    .firstWhere((c) => c.label == _selectedCategory)
                                    .icon
                                : Icons.category_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedCategory ?? 'Pilih Kategori',
                              style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDarkMode ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down_rounded,
                            size: 24,
                            color: isDarkMode ? Colors.white38 : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (_isCustomCategory) ...[
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode ? Colors.white70 : Colors.black87),
                        children: const [
                          TextSpan(text: 'Nama Kategori Kustom '),
                          TextSpan(
                            text: '*',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _customCategoryController,
                      textCapitalization: TextCapitalization.words,
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Misal: Gym, Netflix, Skincare...',
                        hintStyle: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white10 : Colors.grey.shade400,
                        ),
                        prefixIcon: const Icon(Icons.label_outline_rounded, color: AppColors.primary, size: 20),
                        filled: true,
                        fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: isDarkMode ? Colors.white24 : Colors.black26,
                              width: 1.2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: isDarkMode ? Colors.white24 : Colors.black26,
                              width: 1.2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white70 : Colors.black87),
                      children: const [
                        TextSpan(text: 'Limit Anggaran '),
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    autofocus: false,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.left,
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      RibuanFormatter(),
                    ],
                    onChanged: (val) {
                      final amountRaw = val.replaceAll('.', '').replaceAll(',', '');
                      final amount = double.tryParse(amountRaw) ?? 0;
                      if (amount > 0 && _amountHasError) {
                        setState(() {
                          _amountHasError = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Masukkan Nominal',
                      hintStyle: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white10 : Colors.grey.shade400,
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.payments_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Rp',
                              style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      filled: true,
                      fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: isDarkMode ? Colors.white24 : Colors.black26,
                              width: 1.2)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: _amountHasError 
                                  ? Colors.redAccent 
                                  : (isDarkMode ? Colors.white24 : Colors.black26),
                              width: 1.2)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: _amountHasError ? Colors.redAccent : AppColors.primary,
                              width: 1.5)),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                      contentPadding: const EdgeInsets.only(left: 0, right: 16, top: 14, bottom: 14),
                    ),
                  ),
                  if (_amountHasError) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Nominal limit anggaran harus lebih besar dari Rp 0!',
                        style: GoogleFonts.quicksand(
                          color: Colors.redAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _saveBudget,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        isEditing ? 'Perbarui Anggaran' : 'Simpan Anggaran',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
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
    );
  }

  void _showCategorySearchSheet({
    required BuildContext context,
    required bool isDarkMode,
    required String currentSelected,
    required List<TransactionCategory> categoryObjects,
    required ValueChanged<TransactionCategory> onSelected,
  }) {
    FocusScope.of(context).unfocus();
    final searchController = TextEditingController();
    String searchQuery = '';
    String selectedGroupFilter = 'Semua';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {

            final allGroups = ['Semua', ...categoryObjects.map((c) => c.group).toSet()];
            final Map<String, List<TransactionCategory>> displayGrouped = {};
            for (var cat in categoryObjects) {
              final labelLower = cat.label.toLowerCase();
              final groupLower = cat.group.toLowerCase();
              final queryLower = searchQuery.toLowerCase();
              if (labelLower.contains(queryLower) ||
                  groupLower.contains(queryLower)) {
                if (selectedGroupFilter == 'Semua' || cat.group == selectedGroupFilter) {
                  displayGrouped.putIfAbsent(cat.group, () => []).add(cat);
                }
              }
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white10 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'CARI KATEGORI',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.5,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: TextField(
                      controller: searchController,
                      autofocus: true,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Cari kategori...',
                        hintStyle: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white30 : Colors.black38,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: isDarkMode ? Colors.white38 : Colors.black45,
                          size: 20,
                        ),
                        suffixIcon: searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  searchController.clear();
                                  setModalState(() {
                                    searchQuery = '';
                                  });
                                },
                                child: Icon(
                                  Icons.close_rounded,
                                  color: isDarkMode ? Colors.white54 : Colors.black54,
                                  size: 20,
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: isDarkMode
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                     onChanged: (val) {
                         setModalState(() {
                           searchQuery = val;
                         });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedGroupFilter,
                          isExpanded: true,
                          dropdownColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          icon: Icon(
                            Icons.arrow_drop_down_rounded,
                            color: isDarkMode ? Colors.white54 : Colors.black54,
                          ),
                          style: GoogleFonts.quicksand(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          items: allGroups.map((group) {
                            return DropdownMenuItem<String>(
                              value: group,
                              child: Text(group),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                selectedGroupFilter = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: displayGrouped.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 48,
                                  color: isDarkMode ? Colors.white24 : Colors.black26,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Kategori tidak ditemukan.',
                                  style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white38 : Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            physics: const BouncingScrollPhysics(),
                            itemCount: displayGrouped.length,
                            itemBuilder: (context, groupIndex) {
                              final groupName = displayGrouped.keys.elementAt(groupIndex);
                              final items = displayGrouped[groupName]!;
                              final totalItemsInGroup = categoryObjects.where((c) => c.group == groupName).length;
                              final groupColor = items.isNotEmpty ? items.first.color : AppColors.primary;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20, bottom: 10, left: 24, right: 24),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 3.5,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: groupColor,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '${groupName.toUpperCase()} ($totalItemsInGroup)',
                                          style: GoogleFonts.quicksand(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.5,
                                            color: groupColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  ...items.map((cat) {
                                    final isSelected = cat.label == currentSelected;
                                    return GestureDetector(
                                      onTap: () {
                                        onSelected(cat);
                                        Navigator.pop(sheetContext);
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 20),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? Colors.white.withValues(alpha: 0.03)
                                              : Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isSelected
                                                ? cat.color
                                                : (isDarkMode
                                                    ? Colors.white.withValues(alpha: 0.05)
                                                    : Colors.grey.shade100),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: cat.color.withValues(
                                                    alpha: isDarkMode ? 0.15 : 0.08),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                cat.icon,
                                                size: 18,
                                                color: cat.color,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                cat.label,
                                                style: GoogleFonts.quicksand(
                                                  fontSize: 13,
                                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.bold,
                                                  color: isSelected
                                                      ? cat.color
                                                      : (isDarkMode ? Colors.white : Colors.black87),
                                                ),
                                              ),
                                            ),
                                            if (isSelected)
                                              Icon(
                                                Icons.check_circle_rounded,
                                                color: cat.color,
                                                size: 20,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}


