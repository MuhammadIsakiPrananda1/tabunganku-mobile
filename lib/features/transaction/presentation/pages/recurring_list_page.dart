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

HighVisInput(
                  controller: amountController,
                  icon: Icons.payments_rounded,
                  label: 'Nominal',
                  isDarkMode: isDark,
                  hintText: 'Masukkan Nominal Transaksi',
                  prefixText: 'Rp',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.grey.shade200,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selectedType == TransactionType.expense
                            ? Icons.call_made_rounded
                            : Icons.call_received_rounded,
                        size: 18,
                        color: selectedType == TransactionType.expense
                            ? Colors.redAccent
                            : Colors.green,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<TransactionType>(
                            value: selectedType,
                            isExpanded: true,
                            dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            icon: Icon(
                              Icons.arrow_drop_down_rounded,
                              color: isDark ? Colors.white38 : Colors.grey,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: TransactionType.expense,
                                child: Text('Pengeluaran'),
                              ),
                              DropdownMenuItem(
                                value: TransactionType.income,
                                child: Text('Pemasukan'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setSheetState(() {
                                  selectedType = val;
                                  selectedCategory = null;
                                  categoryHasError = false;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
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
                const SizedBox(height: 8),
                Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.grey.shade200,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.repeat_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<RecurringFrequency>(
                            value: selectedFreq,
                            isExpanded: true,
                            dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            icon: Icon(
                              Icons.arrow_drop_down_rounded,
                              color: isDark ? Colors.white38 : Colors.grey,
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
                const SizedBox(height: 12),

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

    final txtClr = isDark ? Colors.white : Colors.black87;
    final pageBg = isDark ? AppColors.backgroundDark : const Color(0xFFF0F3F7);

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 17,
                        color: isDark ? Colors.white70 : AppColors.primaryDark),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  Expanded(
                    child: Text(
                      'Langganan & Tagihan',
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
            const SizedBox(height: 6),

if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else ...[  
              _buildMetricsDashboard(isDark),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                            horizontal: 16, vertical: 12),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return _buildRecurringCard(item, isDark);
                        },
                      ),
              ),
            ],
          ],
        ),
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

    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);
    final subClr = isDark ? Colors.white38 : Colors.grey.shade500;
    final txtClr = isDark ? Colors.white : AppColors.primaryDark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: isDark
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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL PENGELUARAN BULANAN',
                    style: GoogleFonts.quicksand(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: subClr,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatRupiah(totalMonthlyExpense),
                    style: GoogleFonts.quicksand(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: txtClr,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.loop_rounded, color: AppColors.primary, size: 11),
                    const SizedBox(width: 5),
                    Text(
                      'Estimasi',
                      style: GoogleFonts.quicksand(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

Divider(
            height: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
          ),
          const SizedBox(height: 20),

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
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'TAGIHAN AKTIF',
                          style: GoogleFonts.quicksand(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: subClr,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$activeSubscriptionsCount Layanan',
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: txtClr,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade200,
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
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'PENDAPATAN RUTIN ($activeIncomesCount Sumber)',
                            style: GoogleFonts.quicksand(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: subClr,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatRupiah(totalMonthlyIncome),
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: txtClr,
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
    final amountColor = isExpense
        ? (isDark ? Colors.redAccent.shade100 : Colors.red.shade700)
        : (isDark ? Colors.greenAccent.shade200 : Colors.green.shade700);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.grey.shade100,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onLongPress: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                title: Text(
                  'Hapus Transaksi Rutin?',
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                content: Text(
                  'Apakah kamu yakin ingin menghapus tagihan rutin "${item.title}"?',
                  style: GoogleFonts.quicksand(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black54),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Batal',
                        style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white38 : Colors.grey)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('Hapus',
                        style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ),
                ],
              ),
            );
            if (confirm == true && mounted) {
              await ref.read(recurringServiceProvider).deleteRecurring(item.id);
              _loadData();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [

                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(categoryIcon, color: categoryColor, size: 24),
                ),
                const SizedBox(width: 16),

Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _getFreqLabel(item.frequency),
                              style: GoogleFonts.quicksand(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: categoryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Berikutnya: $formattedNextBilling',
                            style: GoogleFonts.quicksand(
                              color: isDark ? Colors.white30 : Colors.grey.shade400,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

Text(
                  '${isExpense ? "-" : "+"} ${_formatRupiah(item.amount)}',
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                    color: amountColor,
                  ),
                ),
              ],
            ),
          ),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {

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
                              final totalItemsInGroup = categoryObjects.where((c) => c.group == groupName).length;
                              final groupColor = items.isNotEmpty
                                  ? items.first.color
                                  : AppColors.primary;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

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
              SizedBox(width: widget.prefixText != null ? 4 : 8),
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
