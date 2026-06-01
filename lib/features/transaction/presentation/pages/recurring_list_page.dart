import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/models/recurring_transaction_model.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/services/recurring_service.dart';
import 'package:tabunganku/core/theme/app_colors.dart';

import 'package:tabunganku/core/utils/currency_formatter.dart';
import 'package:tabunganku/core/constants/transaction_categories.dart';
import 'package:google_fonts/google_fonts.dart';

class RecurringListPage extends ConsumerStatefulWidget {
  const RecurringListPage({super.key});

  @override
  ConsumerState<RecurringListPage> createState() => _RecurringListPageState();
}

class _RecurringListPageState extends ConsumerState<RecurringListPage> {
  List<RecurringTransactionModel> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
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
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
        .format(amount);
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
        return 'Triwulan';
      case RecurringFrequency.semiAnnually:
        return 'Semester';
      case RecurringFrequency.yearly:
        return 'Tahunan';
    }
  }

  String _getFreqDesc(RecurringFrequency f) {
    switch (f) {
      case RecurringFrequency.daily:
        return 'Terulang otomatis setiap hari';
      case RecurringFrequency.weekly:
        return 'Terulang otomatis setiap minggu';
      case RecurringFrequency.monthly:
        return 'Terulang otomatis setiap bulan';
      case RecurringFrequency.quarterly:
        return 'Terulang otomatis setiap 3 bulan';
      case RecurringFrequency.semiAnnually:
        return 'Terulang otomatis setiap 6 bulan';
      case RecurringFrequency.yearly:
        return 'Terulang otomatis setiap tahun';
    }
  }

  double _calculateTotalMonthlyCost() {
    double total = 0.0;
    for (var item in _items) {
      if (item.type == TransactionType.expense && item.isActive) {
        switch (item.frequency) {
          case RecurringFrequency.daily:
            total += item.amount * 30;
            break;
          case RecurringFrequency.weekly:
            total += item.amount * 4.33;
            break;
          case RecurringFrequency.monthly:
            total += item.amount;
            break;
          case RecurringFrequency.quarterly:
            total += item.amount / 3;
            break;
          case RecurringFrequency.semiAnnually:
            total += item.amount / 6;
            break;
          case RecurringFrequency.yearly:
            total += item.amount / 12;
            break;
        }
      }
    }
    return total;
  }

  double _calculateTotalMonthlyIncome() {
    double total = 0.0;
    for (var item in _items) {
      if (item.type == TransactionType.income && item.isActive) {
        switch (item.frequency) {
          case RecurringFrequency.daily:
            total += item.amount * 30;
            break;
          case RecurringFrequency.weekly:
            total += item.amount * 4.33;
            break;
          case RecurringFrequency.monthly:
            total += item.amount;
            break;
          case RecurringFrequency.quarterly:
            total += item.amount / 3;
            break;
          case RecurringFrequency.semiAnnually:
            total += item.amount / 6;
            break;
          case RecurringFrequency.yearly:
            total += item.amount / 12;
            break;
        }
      }
    }
    return total;
  }

  DateTime _getNextBillingDate(RecurringTransactionModel item) {
    DateTime base = item.lastProcessedDate;
    switch (item.frequency) {
      case RecurringFrequency.daily:
        return base.add(const Duration(days: 1));
      case RecurringFrequency.weekly:
        return base.add(const Duration(days: 7));
      case RecurringFrequency.monthly:
        int nextMonth = base.month + 1;
        int nextYear = base.year;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear += 1;
        }
        int maxDays = DateTime(nextYear, nextMonth + 1, 0).day;
        int day = base.day > maxDays ? maxDays : base.day;
        return DateTime(nextYear, nextMonth, day);
      case RecurringFrequency.quarterly:
        int nextMonth = base.month + 3;
        int nextYear = base.year;
        if (nextMonth > 12) {
          nextMonth = nextMonth - 12;
          nextYear += 1;
        }
        int maxDays = DateTime(nextYear, nextMonth + 1, 0).day;
        int day = base.day > maxDays ? maxDays : base.day;
        return DateTime(nextYear, nextMonth, day);
      case RecurringFrequency.semiAnnually:
        int nextMonth = base.month + 6;
        int nextYear = base.year;
        if (nextMonth > 12) {
          nextMonth = nextMonth - 12;
          nextYear += 1;
        }
        int maxDays = DateTime(nextYear, nextMonth + 1, 0).day;
        int day = base.day > maxDays ? maxDays : base.day;
        return DateTime(nextYear, nextMonth, day);
      case RecurringFrequency.yearly:
        return DateTime(base.year + 1, base.month, base.day);
    }
  }

  Widget _typeButton({
    required String label,
    required bool isSelected,
    required bool isDarkMode,
    Color? color,
    required VoidCallback onTap,
  }) {
    final activeColor = color ?? Colors.red.shade400;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.1)
              : (isDarkMode
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? activeColor.withValues(alpha: 0.8)
                : (isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade200),
            width: 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? (isDarkMode ? Colors.white : activeColor)
                : (isDarkMode ? Colors.white60 : Colors.black54),
          ),
        ),
      ),
    );
  }

  void _showAddSheet() {
    final amountController = TextEditingController();
    final titleController = TextEditingController();
    TransactionType selectedType = TransactionType.expense;
    RecurringFrequency selectedFreq = RecurringFrequency.monthly;
    String? selectedCategory;
    bool titleHasError = false;
    bool amountHasError = false;
    bool categoryHasError = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(builder: (context, setSheetState) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final inset = MediaQuery.of(context).viewInsets.bottom;

        return Container(
          padding: EdgeInsets.only(bottom: inset),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tambah Transaksi Rutin',
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // Unified Capsule Input for Title
                HighVisInput(
                  controller: titleController,
                  icon: Icons.branding_watermark_rounded,
                  label: 'Nama Tagihan / Langganan',
                  isDarkMode: isDark,
                  hintText: 'Masukkan Nama Tagihan / Langganan',
                  hasError: titleHasError,
                  onChanged: (val) {
                    if (titleHasError) {
                      setSheetState(() => titleHasError = false);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Unified Capsule Input for Amount
                HighVisInput(
                  controller: amountController,
                  icon: Icons.payments_rounded,
                  label: 'Nominal',
                  isDarkMode: isDark,
                  hintText: 'Masukkan Nominal Transaksi',
                  prefixText: 'Rp',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    RibuanFormatter(),
                  ],
                  hasError: amountHasError,
                  onChanged: (val) {
                    if (amountHasError) {
                      setSheetState(() => amountHasError = false);
                    }
                  },
                ),
                const SizedBox(height: 24),

                Text(
                  'Jenis Transaksi',
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _typeButton(
                        label: 'PENGELUARAN',
                        isSelected: selectedType == TransactionType.expense,
                        isDarkMode: isDark,
                        color: Colors.redAccent,
                        onTap: () => setSheetState(() {
                          selectedType = TransactionType.expense;
                          selectedCategory = null;
                          categoryHasError = false;
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _typeButton(
                        label: 'PEMASUKAN',
                        isSelected: selectedType == TransactionType.income,
                        isDarkMode: isDark,
                        color: Colors.green,
                        onTap: () => setSheetState(() {
                          selectedType = TransactionType.income;
                          selectedCategory = null;
                          categoryHasError = false;
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Text(
                  'Kategori',
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    _showCategorySearchSheet(
                      context: context,
                      isDarkMode: isDark,
                      currentSelected: selectedCategory ?? '',
                      categoryObjects: selectedType == TransactionType.expense
                          ? AppCategories.expenseCategories
                          : AppCategories.incomeCategories,
                      onSelected: (cat) {
                        setSheetState(() {
                          selectedCategory = cat.label;
                          categoryHasError = false;
                        });
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: categoryHasError
                            ? Colors.red.shade400
                            : (isDark ? Colors.white10 : Colors.grey.shade200),
                        width: 1.2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          selectedCategory != null &&
                                  (selectedType == TransactionType.expense
                                          ? AppCategories.expenseCategories
                                          : AppCategories.incomeCategories)
                                      .any((c) => c.label == selectedCategory)
                              ? (selectedType == TransactionType.expense
                                      ? AppCategories.expenseCategories
                                      : AppCategories.incomeCategories)
                                  .firstWhere(
                                      (c) => c.label == selectedCategory)
                                  .icon
                              : Icons.category_rounded,
                          size: 20,
                          color: selectedCategory != null
                              ? AppColors.primary
                              : (isDark ? Colors.white30 : Colors.black38),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedCategory ?? 'Pilih Kategori',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: selectedCategory != null
                                  ? (isDark ? Colors.white : Colors.black87)
                                  : (isDark ? Colors.white30 : Colors.black38),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          size: 24,
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Frekuensi Penagihan',
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: RecurringFrequency.values.map((f) {
                    final isSelected = selectedFreq == f;
                    return ChoiceChip(
                      label: Text(
                        _getFreqLabel(f),
                        style: GoogleFonts.quicksand(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => setSheetState(() => selectedFreq = f),
                      selectedColor: AppColors.primary,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide.none),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _getFreqDesc(selectedFreq),
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: () async {
                    final titleVal = titleController.text.trim();
                    final rawAmount = amountController.text.replaceAll('.', '');
                    final amountVal = double.tryParse(rawAmount) ?? 0.0;

                    setSheetState(() {
                      titleHasError = titleVal.isEmpty;
                      amountHasError = amountVal <= 0;
                      categoryHasError = selectedCategory == null;
                    });

                    if (titleHasError || amountHasError || categoryHasError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  titleHasError
                                      ? 'Nama tagihan tidak boleh kosong!'
                                      : (amountHasError
                                          ? 'Nominal harus lebih dari 0!'
                                          : 'Silakan pilih kategori terlebih dahulu!'),
                                  style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red.shade700,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                      return;
                    }

                    final model = RecurringTransactionModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleVal,
                      amount: amountVal,
                      type: selectedType,
                      category: selectedCategory!,
                      frequency: selectedFreq,
                      startDate: DateTime.now(),
                      lastProcessedDate: DateTime.now(),
                    );
                    final navigator = Navigator.of(context);
                    await ref
                        .read(recurringServiceProvider)
                        .addRecurring(model);
                    navigator.pop();
                    _loadData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Simpan Transaksi Rutin',
                    style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Langganan & Tagihan',
          style:
              GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildMetricsDashboard(isDark),
                const SizedBox(height: 12),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'DAFTAR TAGIHAN & PEMASUKAN',
                      style: GoogleFonts.quicksand(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white30 : Colors.black38,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _items.isEmpty
                      ? _buildEmptyState(isDark)
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return _buildRecurringCard(item, isDark);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Tambah Rutin',
          style: GoogleFonts.quicksand(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildMetricsDashboard(bool isDark) {
    final totalMonthlyExpense = _calculateTotalMonthlyCost();
    final totalMonthlyIncome = _calculateTotalMonthlyIncome();
    final activeSubscriptionsCount = _items
        .where((i) => i.type == TransactionType.expense && i.isActive)
        .length;
    final activeIncomesCount = _items
        .where((i) => i.type == TransactionType.income && i.isActive)
        .length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.primary.withValues(alpha: 0.15),
                  Colors.teal.shade900.withValues(alpha: 0.3)
                ]
              : [AppColors.primary, AppColors.primary.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
        border: Border.all(
          color: isDark
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL PENGELUARAN BULANAN (ESTIMASI)',
            style: GoogleFonts.quicksand(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.teal.shade300 : Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatRupiah(totalMonthlyExpense),
            style: GoogleFonts.quicksand(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TAGIHAN AKTIF',
                      style: GoogleFonts.quicksand(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white30 : Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$activeSubscriptionsCount Layanan',
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.2),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PENDAPATAN RUTIN ($activeIncomesCount Sumber)',
                      style: GoogleFonts.quicksand(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white30 : Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(totalMonthlyIncome),
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark ? Colors.greenAccent.shade200 : Colors.white,
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.loop_rounded,
              size: 80, color: isDark ? Colors.white10 : Colors.teal.shade50),
          const SizedBox(height: 20),
          Text(
            'Belum ada transaksi rutin',
            style: GoogleFonts.quicksand(
              color: isDark ? Colors.white38 : Colors.black38,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan Netflix, Spotify, atau kost-kosan kamu!',
            style: GoogleFonts.quicksand(
                color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringCard(RecurringTransactionModel item, bool isDark) {
    final categoryColor = AppCategories.getColorForCategory(item.category);
    final categoryIcon = AppCategories.getIconForCategory(item.category);
    final nextBilling = _getNextBillingDate(item);
    final formattedNextBilling = DateFormat('dd MMM yyyy').format(nextBilling);

    final isExpense = item.type == TransactionType.expense;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.shade100,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Category-Branded Icon Container
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: categoryColor.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: Icon(
              categoryIcon,
              color: categoryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          // Subscriptions Details
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
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Dynamic frequency badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: categoryColor.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getFreqLabel(item.frequency),
                        style: GoogleFonts.quicksand(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: categoryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Selanjutnya: $formattedNextBilling',
                  style: GoogleFonts.quicksand(
                    color: isDark ? Colors.white38 : Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Amount & Delete Icon
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${isExpense ? "-" : "+"} ${_formatRupiah(item.amount)}',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: isExpense
                      ? (isDark
                          ? Colors.redAccent.shade100
                          : Colors.red.shade700)
                      : (isDark
                          ? Colors.greenAccent.shade200
                          : Colors.green.shade700),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  if (!context.mounted) return;
                  final isDarkTheme = isDark;
                  final itemId = item.id;
                  final itemTitle = item.title;

                  // Beautiful confirmation dialog
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      backgroundColor:
                          isDarkTheme ? AppColors.surfaceDark : Colors.white,
                      title: Text(
                        'Hapus Transaksi Rutin?',
                        style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      content: Text(
                        'Apakah kamu yakin ingin menghapus tagihan rutin "$itemTitle"?',
                        style: GoogleFonts.quicksand(
                            fontSize: 13,
                            color:
                                isDarkTheme ? Colors.white70 : Colors.black54),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'Batal',
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              color: isDarkTheme ? Colors.white38 : Colors.grey,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            'Hapus',
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && mounted) {
                    await ref
                        .read(recurringServiceProvider)
                        .deleteRecurring(itemId);
                    _loadData();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red.shade400,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
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
    FocusScope.of(context).unfocus(); // Unfocus parent fields immediately!
    final searchController = TextEditingController();
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Group filtered items dynamically
            final Map<String, List<TransactionCategory>> displayGrouped = {};
            for (var cat in categoryObjects) {
              final labelLower = cat.label.toLowerCase();
              final groupLower = cat.group.toLowerCase();
              final queryLower = searchQuery.toLowerCase();
              if (labelLower.contains(queryLower) ||
                  groupLower.contains(queryLower)) {
                displayGrouped.putIfAbsent(cat.group, () => []).add(cat);
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: TextField(
                      controller: searchController,
                      autofocus: false,
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
                                  color: isDarkMode
                                      ? Colors.white54
                                      : Colors.black54,
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
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          searchQuery = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: displayGrouped.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 48,
                                  color: isDarkMode
                                      ? Colors.white24
                                      : Colors.black26,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Kategori tidak ditemukan.',
                                  style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white38
                                        : Colors.black38,
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
                              final groupName =
                                  displayGrouped.keys.elementAt(groupIndex);
                              final items = displayGrouped[groupName]!;
                              final groupColor = items.isNotEmpty
                                  ? items.first.color
                                  : AppColors.primary;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Group Header (Minimalist & Clear)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20,
                                        bottom: 10,
                                        left: 24,
                                        right: 24),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 3.5,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: groupColor,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          groupName.toUpperCase(),
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
                                  // Group Items
                                  ...items.map((cat) {
                                    final isSelected =
                                        cat.label == currentSelected;
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
                                              ? Colors.white
                                                  .withValues(alpha: 0.03)
                                              : Colors.grey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isSelected
                                                ? cat.color
                                                : (isDarkMode
                                                    ? Colors.white
                                                        .withValues(alpha: 0.05)
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
                                                    alpha: isDarkMode
                                                        ? 0.15
                                                        : 0.08),
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
                                                  fontWeight: isSelected
                                                      ? FontWeight.w800
                                                      : FontWeight.bold,
                                                  color: isSelected
                                                      ? cat.color
                                                      : (isDarkMode
                                                          ? Colors.white
                                                          : Colors.black87),
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

class HighVisInput extends StatefulWidget {
  final TextEditingController controller;
  final IconData icon;
  final String label;
  final bool isDarkMode;
  final String? prefixText;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextStyle? style;
  final bool hasError;
  final ValueChanged<String>? onChanged;

  const HighVisInput({
    super.key,
    required this.controller,
    required this.icon,
    required this.label,
    required this.isDarkMode,
    this.prefixText,
    this.hintText,
    this.inputFormatters,
    this.keyboardType,
    this.style,
    this.hasError = false,
    this.onChanged,
  });

  @override
  State<HighVisInput> createState() => _HighVisInputState();
}

class _HighVisInputState extends State<HighVisInput> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentColor =
        widget.isDarkMode ? Colors.white : AppColors.primaryDark;
    final surfaceColor = widget.isDarkMode
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.grey.shade100;

    final Color borderColor;
    final double borderWidth;
    if (widget.hasError) {
      borderColor = Colors.red.shade400;
      borderWidth = 1.5;
    } else if (_isFocused) {
      borderColor = AppColors.primary;
      borderWidth = 1.8;
    } else {
      borderColor = widget.isDarkMode
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.grey.shade200;
      borderWidth = 1.2;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: widget.isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(widget.icon, color: AppColors.primary, size: 20),
              if (widget.prefixText != null) ...[
                const SizedBox(width: 8),
                Text(
                  widget.prefixText!,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  focusNode: _focusNode,
                  controller: widget.controller,
                  onChanged: widget.onChanged,
                  keyboardType: widget.keyboardType ?? TextInputType.text,
                  inputFormatters: widget.inputFormatters,
                  style: widget.style ??
                      GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: contentColor,
                      ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color:
                          widget.isDarkMode ? Colors.white30 : Colors.black38,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                    filled: false,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
