import 'package:flutter/material.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';
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
    bool titleHasError = false;
    bool amountHasError = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(builder: (context, setSheetState) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final inset = MediaQuery.of(context).viewInsets.bottom;

        return Container(
          padding: EdgeInsets.only(bottom: inset > 0 ? inset : MediaQuery.of(context).padding.bottom),
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
                    });

                    if (titleHasError || amountHasError) {
                      showTopToast(context, titleHasError
                                      ? 'Nama tagihan tidak boleh kosong!'
                                      : 'Nominal harus lebih dari 0!', isError: true);
                      return;
                    }

                    final model = RecurringTransactionModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleVal,
                      amount: amountVal,
                      type: selectedType,
                      category: selectedType == TransactionType.expense ? 'Langganan' : 'Pemasukan',
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

  void _showRecurringDetailSheet(RecurringTransactionModel item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final currentItem = _items.firstWhere((i) => i.id == item.id, orElse: () => item);
            final nextBilling = _getNextBillingDate(currentItem);
            final elapsedDays = DateTime.now().difference(currentItem.lastProcessedDate).inDays;
            final totalDays = nextBilling.difference(currentItem.lastProcessedDate).inDays;
            final progress = totalDays > 0 ? (elapsedDays / totalDays).clamp(0.0, 1.0) : 0.0;
            final daysLeft = nextBilling.difference(DateTime.now()).inDays;
            final categoryColor = AppCategories.getColorForCategory(currentItem.category);
            final categoryIcon = AppCategories.getIconForCategory(currentItem.category);
            final isExpense = currentItem.type == TransactionType.expense;

            double monthlyEquivalent = 0.0;
            switch (currentItem.frequency) {
              case RecurringFrequency.daily:
                monthlyEquivalent = currentItem.amount * 30;
                break;
              case RecurringFrequency.weekly:
                monthlyEquivalent = currentItem.amount * 4.33;
                break;
              case RecurringFrequency.monthly:
                monthlyEquivalent = currentItem.amount;
                break;
              case RecurringFrequency.quarterly:
                monthlyEquivalent = currentItem.amount / 3;
                break;
              case RecurringFrequency.semiAnnually:
                monthlyEquivalent = currentItem.amount / 6;
                break;
              case RecurringFrequency.yearly:
                monthlyEquivalent = currentItem.amount / 12;
                break;
            }

            final sheetBg = isDark ? const Color(0xFF151515) : Colors.white;
            final cardBg = isDark ? AppColors.surfaceDark : const Color(0xFFF9FAFB);
            final borderCol = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200;
            final txtClr = isDark ? Colors.white : AppColors.primaryDark;

            return Container(
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).viewInsets.bottom : MediaQuery.of(context).padding.bottom + 24,
                top: 16,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          categoryIcon,
                          color: categoryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentItem.title,
                              style: GoogleFonts.quicksand(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: txtClr,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currentItem.category,
                              style: GoogleFonts.quicksand(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          final updated = currentItem.copyWith(isActive: !currentItem.isActive);
                          final service = ref.read(recurringServiceProvider);
                          final items = await service.getRecurringTransactions();
                          final idx = items.indexWhere((i) => i.id == currentItem.id);
                          if (idx != -1) {
                            items[idx] = updated;
                            await service.saveRecurringTransactions(items);
                          }
                          await _loadData();
                          setSheetState(() {});
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: (currentItem.isActive ? AppColors.primary : Colors.grey).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: (currentItem.isActive ? AppColors.primary : Colors.grey).withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            currentItem.isActive ? 'AKTIF' : 'NON-AKTIF',
                            style: GoogleFonts.quicksand(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: currentItem.isActive ? AppColors.primary : Colors.grey,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderCol, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 90,
                                height: 90,
                                child: CircularProgressIndicator(
                                  value: currentItem.isActive ? progress : 0.0,
                                  strokeWidth: 9,
                                  backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                                  valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                                ),
                              ),
                              Text(
                                currentItem.isActive ? '${(progress * 100).toInt()}%' : '0%',
                                style: GoogleFonts.quicksand(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: txtClr,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isExpense ? 'ESTIMASI BULANAN' : 'ESTIMASI MASUKAN BULAN',
                                style: GoogleFonts.quicksand(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatRupiah(monthlyEquivalent),
                                style: GoogleFonts.quicksand(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isExpense ? Colors.redAccent : Colors.green,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'NOMINAL TRANSAKSI',
                                style: GoogleFonts.quicksand(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${isExpense ? "-" : "+"} ${_formatRupiah(currentItem.amount)}',
                                style: GoogleFonts.quicksand(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: txtClr,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderCol, width: 1.2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.event_available_rounded,
                                    color: categoryColor,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'TANGGAL MULAI',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.grey,
                                        letterSpacing: 0.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  DateFormat('d MMM yyyy', 'id_ID').format(currentItem.startDate),
                                  style: GoogleFonts.quicksand(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: txtClr,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderCol, width: 1.2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.alarm_rounded,
                                    color: isDark ? Colors.white60 : Colors.grey,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'BERIKUTNYA',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.grey,
                                        letterSpacing: 0.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  DateFormat('d MMM yyyy', 'id_ID').format(nextBilling),
                                  style: GoogleFonts.quicksand(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: txtClr,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentItem.isActive
                                    ? (daysLeft > 0 ? '$daysLeft Hari lagi' : 'Hari ini')
                                    : 'Transaksi Non-aktif',
                                style: GoogleFonts.quicksand(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: currentItem.isActive
                                      ? (daysLeft > 0 ? AppColors.primary : Colors.orange)
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  Center(
                    child: Text(
                      'Jenis Transaksi: ${currentItem.type == TransactionType.expense ? "Pengeluaran" : "Pemasukan"} (${_getFreqLabel(currentItem.frequency)})',
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showEditSheet(currentItem);
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
                              'Ubah Transaksi',
                              style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2C1C1C) : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                                title: Text(
                                  'Hapus Transaksi?',
                                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                content: Text(
                                  'Apakah kamu yakin ingin menghapus tagihan rutin "${currentItem.title}"?',
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
                            if (confirm == true && context.mounted) {
                              Navigator.pop(context); // Close detail sheet
                              await ref.read(recurringServiceProvider).deleteRecurring(currentItem.id);
                              _loadData();
                            }
                          },
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                            size: 24,
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

  void _showEditSheet(RecurringTransactionModel item) {
    final amountController = TextEditingController(
      text: item.amount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      ),
    );
    final titleController = TextEditingController(text: item.title);
    TransactionType selectedType = item.type;
    RecurringFrequency selectedFreq = item.frequency;
    bool titleHasError = false;
    bool amountHasError = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(builder: (context, setSheetState) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final inset = MediaQuery.of(context).viewInsets.bottom;

        return Container(
          padding: EdgeInsets.only(bottom: inset > 0 ? inset : MediaQuery.of(context).padding.bottom),
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
                  'Ubah Transaksi Rutin',
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
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


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
                    });

                    if (titleHasError || amountHasError) {
                      showTopToast(context, titleHasError
                                      ? 'Nama tagihan tidak boleh kosong!'
                                      : 'Nominal harus lebih dari 0!', isError: true);
                      return;
                    }

                    final updatedModel = item.copyWith(
                      title: titleVal,
                      amount: amountVal,
                      type: selectedType,
                      category: selectedType == TransactionType.expense ? 'Langganan' : 'Pemasukan',
                      frequency: selectedFreq,
                    );
                    
                    final service = ref.read(recurringServiceProvider);
                    final items = await service.getRecurringTransactions();
                    final index = items.indexWhere((i) => i.id == item.id);
                    if (index != -1) {
                      items[index] = updatedModel;
                      await service.saveRecurringTransactions(items);
                    }
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      showTopToast(context, 'Transaksi Rutin Berhasil Diperbarui!');
                    }
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
                    'Simpan Perubahan',
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
          onTap: () => _showRecurringDetailSheet(item),
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
