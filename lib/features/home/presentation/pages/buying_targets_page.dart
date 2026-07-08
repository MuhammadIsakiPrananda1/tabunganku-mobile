import 'package:flutter/material.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/widgets/high_vis_input.dart';
import 'package:tabunganku/providers/saving_target_provider.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/models/saving_target_model.dart';
import 'package:tabunganku/models/transaction_model.dart';

class BuyingTargetsPage extends ConsumerStatefulWidget {
  const BuyingTargetsPage({super.key});

  @override
  ConsumerState<BuyingTargetsPage> createState() => _BuyingTargetsPageState();
}

class _BuyingTargetsPageState extends ConsumerState<BuyingTargetsPage> {
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 90));

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final targetsAsync = ref.watch(savingTargetsStreamProvider);

    final pageBg = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF9FAFB);
    final txtClr = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: txtClr, size: 20),
        ),
        title: Text(
          'Target Saya',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: txtClr,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: targetsAsync.when(
                data: (targets) {
                  final buyingTargets = targets
                      .where((t) => t.category == 'Pembelian' || t.category == 'Umum')
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDashboardHeader(buyingTargets, isDarkMode),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Text(
                          'DAFTAR TARGET BELANJA',
                          style: GoogleFonts.quicksand(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: txtClr.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                      Expanded(
                        child: buyingTargets.isEmpty
                            ? _buildEmptyState(isDarkMode)
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(24, 4, 24, 100),
                                itemCount: buyingTargets.length,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final t = buyingTargets[index];
                                  return _buildTargetItem(t, isDarkMode);
                                },
                              ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTargetSheet(context, isDarkMode),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 8,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: Text(
          'Tambah Target',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label, bool isDarkMode) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.quicksand(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: Colors.grey,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildHighVisInput({
    required TextEditingController controller,
    required IconData icon,
    required String unit,
    required Color color,
    required bool isDarkMode,
    bool isPremium = false,
    String? hint,
    bool hasError = false,
    ValueChanged<String>? onChanged,
  }) {
    return HighVisInput(
      controller: controller,
      icon: icon,
      label: '',
      isDarkMode: isDarkMode,
      prefixText: unit.isNotEmpty ? unit : null,
      hintText: hint,
      keyboardType: isPremium ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      inputFormatters: isPremium ? [_RibuanFormatter()] : null,
      hasError: hasError,
      onChanged: onChanged,
    );
  }

  Widget _buildDashboardHeader(List<SavingTargetModel> buyingTargets, bool isDarkMode) {
    final transactions = ref.watch(transactionsByGroupProvider(null));

    double totalEstimated = 0;
    double totalSaved = 0;

    for (var target in buyingTargets) {
      totalEstimated += target.targetAmount;
      final targetBalance = transactions
          .where((t) => !t.date.isBefore(target.createdAt))
          .fold<double>(0, (s, t) => s + (t.type == TransactionType.income ? t.amount : -t.amount));
      totalSaved += targetBalance.clamp(0.0, target.targetAmount);
    }

    final remainingNeeded = totalEstimated - totalSaved;
    final overallProgress = totalEstimated > 0 ? totalSaved / totalEstimated : 0.0;
    final totalCount = buyingTargets.length;

    final cardBg = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final borderCol = isDarkMode ? Colors.white10 : Colors.grey.shade200;
    final txtClr = isDarkMode ? Colors.white : AppColors.primaryDark;

    String statusLabel = 'Kosong';
    Color statusColor = Colors.grey;
    if (totalCount > 0) {
      if (overallProgress >= 1.0) {
        statusLabel = 'Tercapai';
        statusColor = Colors.green;
      } else {
        statusLabel = 'Dalam Proses';
        statusColor = AppColors.primary;
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.08 : 0.02),
            blurRadius: 16,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL TARGET IMPIAN',
                    style: GoogleFonts.quicksand(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatRupiah(totalEstimated),
                    style: GoogleFonts.quicksand(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: txtClr,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.quicksand(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            totalCount > 0 ? 'dari $totalCount target impian' : 'Belum menentukan target impian',
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progres Pencapaian',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${(overallProgress * 100).toInt()}% Selesai',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: totalEstimated > 0 ? overallProgress : 0.0,
                        backgroundColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(overallProgress >= 1.0 ? Colors.green : AppColors.primary),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: borderCol,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatCell(
                label: 'TERKUMPUL',
                value: _formatRupiah(totalSaved),
                color: totalCount > 0 ? Colors.green : Colors.grey,
              ),
              Container(
                width: 1,
                height: 32,
                color: borderCol,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              _StatCell(
                label: 'KEKURANGAN',
                value: _formatRupiah(remainingNeeded),
                color: remainingNeeded > 0 ? AppColors.primary : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddTargetSheet(BuildContext context, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final surfaceColor = isDarkMode ? AppColors.surfaceDark : Colors.white;

    bool nameHasError = false;
    bool amountHasError = false;
    bool dateIsFocused = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final Color dateBorderColor;
          final double dateBorderWidth;
          if (dateIsFocused) {
            dateBorderColor = AppColors.primary;
            dateBorderWidth = 1.8;
          } else {
            dateBorderColor = isDarkMode 
                ? Colors.white.withValues(alpha: 0.05) 
                : Colors.grey.shade200;
            dateBorderWidth = 1.2;
          }

          return Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                      color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_mall_rounded,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Tambah Target Impian',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: contentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInputLabel('Barang Impian', isDarkMode),
                const SizedBox(height: 4),
                _buildHighVisInput(
                  controller: _nameController,
                  icon: Icons.local_mall_rounded,
                  unit: '',
                  color: AppColors.primary,
                  isDarkMode: isDarkMode,
                  hint: 'Masukkan nama barang impian',
                  hasError: nameHasError,
                  onChanged: (val) {
                    if (nameHasError && val.trim().isNotEmpty) {
                      setSheetState(() => nameHasError = false);
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildInputLabel('Harga Estimasi', isDarkMode),
                const SizedBox(height: 4),
                _buildHighVisInput(
                  controller: _amountController,
                  icon: Icons.price_check_rounded,
                  unit: 'Rp',
                  color: Colors.green,
                  isDarkMode: isDarkMode,
                  isPremium: true,
                  hint: 'Masukkan nominal harga',
                  hasError: amountHasError,
                  onChanged: (val) {
                    if (amountHasError) {
                      final amount = double.tryParse(val.replaceAll('.', '')) ?? 0;
                      if (amount > 0) {
                        setSheetState(() => amountHasError = false);
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildInputLabel('Target Tenggat Waktu', isDarkMode),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () async {
                    setSheetState(() => dateIsFocused = true);
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    setSheetState(() => dateIsFocused = false);
                    if (picked != null) {
                      setSheetState(() => _selectedDate = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: dateBorderColor,
                        width: dateBorderWidth,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            DateFormat('d MMMM yyyy', 'id_ID').format(_selectedDate),
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: contentColor,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down_rounded,
                            color: isDarkMode ? Colors.white24 : Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final nameVal = _nameController.text.trim();
                      final amount = double.tryParse(
                              _amountController.text.replaceAll('.', '')) ??
                          0;

                      setSheetState(() {
                        nameHasError = nameVal.isEmpty;
                        amountHasError = amount <= 0;
                      });

                      if (nameHasError || amountHasError) {
                        String errorMessage = 'Nama target tidak boleh kosong!';
                        if (amountHasError) {
                          errorMessage = 'Estimasi harga harus lebih dari 0!';
                        }
                        showTopToast(context, errorMessage, isError: true);
                        return;
                      }

                      final target = SavingTargetModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameVal,
                        targetAmount: amount,
                        dueDate: _selectedDate,
                        createdAt: DateTime.now(),
                        category: 'Pembelian',
                      );
                      await ref
                          .read(savingTargetServiceProvider)
                          .addTarget(target);
                      _amountController.clear();
                      _nameController.clear();
                      _selectedDate =
                          DateTime.now().add(const Duration(days: 90));
                      if (context.mounted) {
                        Navigator.pop(context);
                        showTopToast(context, 'Target Berhasil Ditambahkan!');
                      }
                    },
                    icon: const Icon(Icons.add_task_rounded, size: 20),
                    label: Text(
                      'Buat Target Impian Sekarang',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTargetItem(SavingTargetModel target, bool isDarkMode) {
    final transactions = ref.watch(transactionsByGroupProvider(null));
    final targetBalance = transactions
        .where((t) => !t.date.isBefore(target.createdAt))
        .fold<double>(0, (s, t) => s + (t.type == TransactionType.income ? t.amount : -t.amount));
    final progress = (target.targetAmount > 0)
        ? (targetBalance / target.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    const baseColor = AppColors.primary;

    final daysLeft = target.dueDate.difference(DateTime.now()).inDays;
    final remainingAmount = (target.targetAmount - targetBalance).clamp(0.0, double.infinity);
    final deadlineColor = daysLeft <= 7
        ? Colors.redAccent
        : daysLeft <= 30
            ? Colors.orange
            : baseColor;

    final cardBg = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final borderColor = isDarkMode ? Colors.white10 : Colors.grey.shade200;
    final subClr = isDarkMode ? Colors.white30 : Colors.grey.shade400;
    final txtClr = isDarkMode ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.08 : 0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showTargetDetailSheet(target),
          onLongPress: () => _deleteTarget(target.id),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [

                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: baseColor.withValues(alpha: isDarkMode ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.local_mall_rounded,
                    color: baseColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        target.name,
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: txtClr,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: deadlineColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.alarm_rounded, size: 9, color: deadlineColor),
                                const SizedBox(width: 3),
                                Text(
                                  daysLeft > 0 ? '$daysLeft hari lagi' : 'Tenggat lewat',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: deadlineColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd MMM yyyy', 'id_ID').format(target.dueDate),
                            style: GoogleFonts.quicksand(
                              fontSize: 9,
                              color: subClr,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: isDarkMode
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.grey.shade100,
                          valueColor: const AlwaysStoppedAnimation<Color>(baseColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatRupiah(target.targetAmount),
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: baseColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: baseColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(progress * 100).toInt()}%',
                        style: GoogleFonts.quicksand(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: baseColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sisa ${_formatRupiah(remainingAmount)}',
                      style: GoogleFonts.quicksand(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
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

  void _showTargetDetailSheet(SavingTargetModel target) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final targetsAsync = ref.watch(savingTargetsStreamProvider);
            return targetsAsync.when(
              data: (targets) {
                final currentTarget = targets.firstWhere(
                  (t) => t.id == target.id,
                  orElse: () => target,
                );
                
                final transactions = ref.watch(transactionsByGroupProvider(null));
                final targetBalance = transactions
                    .where((t) => !t.date.isBefore(currentTarget.createdAt))
                    .fold<double>(0, (s, t) => s + (t.type == TransactionType.income ? t.amount : -t.amount));
                
                final progress = (currentTarget.targetAmount > 0)
                    ? (targetBalance / currentTarget.targetAmount).clamp(0.0, 1.0)
                    : 0.0;
                
                final remainingAmount = (currentTarget.targetAmount - targetBalance).clamp(0.0, double.infinity);
                final daysLeft = currentTarget.dueDate.difference(DateTime.now()).inDays;
                
                final sheetBg = isDarkMode ? const Color(0xFF151515) : Colors.white;
                final cardBg = isDarkMode ? AppColors.surfaceDark : const Color(0xFFF9FAFB);
                final borderCol = isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200;
                final txtClr = isDarkMode ? Colors.white : AppColors.primaryDark;
                
                final isCompleted = progress >= 1.0;
                
                return Container(
                  decoration: BoxDecoration(
                    color: sheetBg,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                            color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
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
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.local_mall_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentTarget.name,
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
                                  'Target Tabungan',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: (isCompleted ? Colors.green : AppColors.primary).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isCompleted ? 'SELESAI' : 'AKTIF',
                              style: GoogleFonts.quicksand(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isCompleted ? Colors.green : AppColors.primary,
                                letterSpacing: 0.5,
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
                                      value: progress,
                                      strokeWidth: 9,
                                      backgroundColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                    ),
                                  ),
                                  Text(
                                    '${(progress * 100).toInt()}%',
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
                                    'TERKUMPUL',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.grey,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatRupiah(targetBalance),
                                    style: GoogleFonts.quicksand(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: txtClr,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'GOAL',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.grey,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatRupiah(currentTarget.targetAmount),
                                    style: GoogleFonts.quicksand(
                                      fontSize: 18,
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
                                      const Icon(
                                        Icons.hourglass_bottom_rounded,
                                        color: Colors.redAccent,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'SISA KURANG',
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
                                      _formatRupiah(remainingAmount),
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
                                        Icons.calendar_today_rounded,
                                        color: isDarkMode ? Colors.white60 : Colors.grey,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'JATUH TEMPO',
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
                                      DateFormat('d MMM yyyy', 'id_ID').format(currentTarget.dueDate),
                                      style: GoogleFonts.quicksand(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: txtClr,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    daysLeft > 0 ? '$daysLeft Hari lagi' : 'Tenggat lewat',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: daysLeft > 0 ? AppColors.primary : Colors.redAccent,
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
                          'Dibuat pada ${DateFormat('d MMM yyyy', 'id_ID').format(currentTarget.createdAt)}',
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
                                  _showEditTargetSheet(currentTarget);
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
                                  'Ubah Target',
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
                              color: isDarkMode ? const Color(0xFF2C1C1C) : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteTarget(currentTarget.id);
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
              loading: () => const SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (e, _) => SizedBox(
                height: 200,
                child: Center(child: Text('Error: $e')),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditTargetSheet(SavingTargetModel target) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final surfaceColor = isDarkMode ? AppColors.surfaceDark : Colors.white;

    final nameController = TextEditingController(text: target.name);
    final amountController = TextEditingController(
        text: target.targetAmount
            .round()
            .toString()
            .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.'));
    DateTime selectedDate = target.dueDate;

    bool nameHasError = false;
    bool amountHasError = false;
    bool dateIsFocused = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final Color dateBorderColor;
          final double dateBorderWidth;
          if (dateIsFocused) {
            dateBorderColor = AppColors.primary;
            dateBorderWidth = 1.8;
          } else {
            dateBorderColor = isDarkMode 
                ? Colors.white.withValues(alpha: 0.05) 
                : Colors.grey.shade200;
            dateBorderWidth = 1.2;
          }

          return Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                      color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_calendar_rounded,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Ubah Target Impian',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: contentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInputLabel('Barang Impian', isDarkMode),
                const SizedBox(height: 4),
                _buildHighVisInput(
                  controller: nameController,
                  icon: Icons.local_mall_rounded,
                  unit: '',
                  color: AppColors.primary,
                  isDarkMode: isDarkMode,
                  hint: 'Masukkan nama barang impian',
                  hasError: nameHasError,
                  onChanged: (val) {
                    if (nameHasError && val.trim().isNotEmpty) {
                      setSheetState(() => nameHasError = false);
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildInputLabel('Harga Estimasi', isDarkMode),
                const SizedBox(height: 4),
                _buildHighVisInput(
                  controller: amountController,
                  icon: Icons.price_check_rounded,
                  unit: 'Rp',
                  color: Colors.green,
                  isDarkMode: isDarkMode,
                  isPremium: true,
                  hint: 'Masukkan nominal harga',
                  hasError: amountHasError,
                  onChanged: (val) {
                    if (amountHasError) {
                      final amount = double.tryParse(val.replaceAll('.', '')) ?? 0;
                      if (amount > 0) {
                        setSheetState(() => amountHasError = false);
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildInputLabel('Target Tenggat Waktu', isDarkMode),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () async {
                    setSheetState(() => dateIsFocused = true);
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    setSheetState(() => dateIsFocused = false);
                    if (picked != null) {
                      setSheetState(() => selectedDate = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: dateBorderColor,
                        width: dateBorderWidth,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            DateFormat('d MMMM yyyy', 'id_ID').format(selectedDate),
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: contentColor,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down_rounded,
                            color: isDarkMode ? Colors.white24 : Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final nameVal = nameController.text.trim();
                      final amount = double.tryParse(
                              amountController.text.replaceAll('.', '')) ??
                          0;

                      setSheetState(() {
                        nameHasError = nameVal.isEmpty;
                        amountHasError = amount <= 0;
                      });

                      if (nameHasError || amountHasError) {
                        String errorMessage = 'Nama target tidak boleh kosong!';
                        if (amountHasError) {
                          errorMessage = 'Estimasi harga harus lebih dari 0!';
                        }
                        showTopToast(context, errorMessage, isError: true);
                        return;
                      }

                      await ref.read(savingTargetServiceProvider).updateTarget(
                            target.copyWith(
                              name: nameVal,
                              targetAmount: amount,
                              dueDate: selectedDate,
                            ),
                          );
                      
                      if (context.mounted) {
                        Navigator.pop(context);
                        showTopToast(context, 'Target Berhasil Diperbarui!');
                      }
                    },
                    icon: const Icon(Icons.save_rounded, size: 20),
                    label: Text(
                      'Simpan Perubahan',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _deleteTarget(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Hapus Target?',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Target belanja ini akan dihapus permanen dari riwayat Anda.',
          style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.quicksand(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Hapus',
              style: GoogleFonts.quicksand(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(savingTargetServiceProvider).deleteTarget(id);
      if (mounted) {
        showTopToast(context, 'Target berhasil dihapus.');
      }
    }
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white.withValues(alpha: 0.02) : Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum ada target pembelian.',
              style: GoogleFonts.quicksand(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tekan tombol + di bawah untuk menambahkan.',
              style: GoogleFonts.quicksand(
                color: Colors.grey.shade400,
                fontSize: 10.5,
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
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final intValue = int.tryParse(newValue.text.replaceAll('.', ''));
    if (intValue == null) return oldValue;
    final newText = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(intValue).trim();
    return TextEditingValue(text: newText, selection: TextSelection.collapsed(offset: newText.length));
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCell({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
