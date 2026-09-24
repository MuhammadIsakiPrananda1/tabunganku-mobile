/// Page: BuyingTargetsPage
///
/// Daftar dan pelacakan target pembelian barang.
library;

import 'package:flutter/material.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';
import 'package:tabunganku/features/home/presentation/widgets/savings_adjustment_dialog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/widgets/high_vis_input.dart';
import 'package:tabunganku/providers/saving_target_provider.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/models/saving_target_model.dart';

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

    final pageBg = isDarkMode ? AppColors.backgroundDark : AppColors.background;
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
            fontSize: 16,
            color: txtClr,
          ),
        ),
      ),
      body: SafeArea(
        child: targetsAsync.when(
          data: (targets) {
            final buyingTargets = targets
                .where((t) => t.category == 'Pembelian' || t.category == 'Umum')
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDashboardHeader(buyingTargets, isDarkMode),
                if (buyingTargets.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daftar Target',
                          style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: txtClr,
                          ),
                        ),
                        Text(
                          '${buyingTargets.length} Barang',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: buyingTargets.isEmpty
                      ? _buildEmptyState(isDarkMode)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTargetSheet(context, isDarkMode),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Tambah Target',
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    ref.watch(transactionsByGroupProvider(null));

    double totalEstimated = 0;
    double totalSaved = 0;

    for (var target in buyingTargets) {
      totalEstimated += target.targetAmount;
      final targetBalance = target.savedAmount;
      totalSaved += targetBalance.clamp(0.0, target.targetAmount);
    }

    final remainingNeeded = (totalEstimated - totalSaved).clamp(0.0, double.infinity);
    final overallProgress = totalEstimated > 0 ? (totalSaved / totalEstimated).clamp(0.0, 1.0) : 0.0;
    final totalCount = buyingTargets.length;

    final cardBg = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);
    final subClr = isDarkMode ? Colors.white38 : Colors.grey.shade500;
    final txtClr = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: isDarkMode
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
                    'TOTAL TARGET IMPIAN',
                    style: GoogleFonts.quicksand(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: subClr,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatRupiah(totalEstimated),
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
                    Icon(
                      totalCount > 0 ? Icons.check_circle_outline_rounded : Icons.flag_outlined,
                      color: AppColors.primary,
                      size: 11,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      totalCount > 0 ? '${(overallProgress * 100).toInt()}% Selesai' : '0 Target',
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
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progres Pencapaian',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: subClr,
                ),
              ),
              Text(
                totalCount > 0
                    ? '${(overallProgress * 100).toInt()}% Selesai'
                    : 'Belum ada target',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: totalEstimated > 0 ? overallProgress : 0.0,
              backgroundColor: isDarkMode
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(
                overallProgress >= 1.0 ? Colors.green : AppColors.primary,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Terkumpul: ',
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      color: subClr,
                    ),
                  ),
                  Text(
                    _formatRupiah(totalSaved),
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Kekurangan: ',
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      color: subClr,
                    ),
                  ),
                  Text(
                    _formatRupiah(remainingNeeded),
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
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
    final targetBalance = target.savedAmount;
    final progress = (target.targetAmount > 0)
        ? (targetBalance / target.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    const baseColor = AppColors.primary;

    final daysLeft = target.dueDate.difference(DateTime.now()).inDays;
    final deadlineColor = daysLeft <= 7
        ? Colors.redAccent
        : daysLeft <= 30
            ? Colors.orange
            : baseColor;

    final cardBg = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final borderColor = isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100;
    final subClr = isDarkMode ? Colors.white38 : Colors.grey.shade500;
    final txtClr = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showTargetDetailSheet(target),
          onLongPress: () => _deleteTarget(target.id),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: baseColor.withValues(alpha: isDarkMode ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_mall_rounded,
                        color: baseColor,
                        size: 18,
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
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: txtClr,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('d MMM yyyy', 'id_ID').format(target.dueDate),
                            style: GoogleFonts.quicksand(
                              fontSize: 10.5,
                              color: subClr,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatRupiah(target.targetAmount),
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: baseColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (progress >= 1.0 ? Colors.green : baseColor).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${(progress * 100).toInt()}%',
                            style: GoogleFonts.quicksand(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: progress >= 1.0 ? Colors.green : baseColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: isDarkMode
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0 ? Colors.green : baseColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Terkumpul ${_formatRupiah(targetBalance)}',
                      style: GoogleFonts.quicksand(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.alarm_rounded, size: 11, color: deadlineColor),
                        const SizedBox(width: 3),
                        Text(
                          daysLeft > 0 ? '$daysLeft hari lagi' : 'Tenggat lewat',
                          style: GoogleFonts.quicksand(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: deadlineColor,
                          ),
                        ),
                      ],
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
                
                final targetBalance = currentTarget.savedAmount;
                
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
                    bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).viewInsets.bottom : MediaQuery.of(context).padding.bottom + 24,
                    top: 16,
                    left: 24,
                    right: 24,
                  ),
                  child: SingleChildScrollView(
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
                      const SizedBox(height: 16),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderCol, width: 1.2),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 76,
                              height: 76,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 76,
                                    height: 76,
                                    child: CircularProgressIndicator(
                                      value: progress,
                                      strokeWidth: 8,
                                      strokeCap: StrokeCap.round,
                                      backgroundColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                    ),
                                  ),
                                  Text(
                                    '${(progress * 100).toInt()}%',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: txtClr,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TERKUMPUL',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.grey,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatRupiah(targetBalance),
                                    style: GoogleFonts.quicksand(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: txtClr,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'GOAL',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.grey,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatRupiah(currentTarget.targetAmount),
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
                      const SizedBox(height: 12),
                      
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(16),
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
                                          size: 13,
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
                                    const SizedBox(height: 6),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        _formatRupiah(remainingAmount),
                                        style: GoogleFonts.quicksand(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: txtClr,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(16),
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
                                          size: 12,
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
                                    const SizedBox(height: 6),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        DateFormat('d MMM yyyy', 'id_ID').format(currentTarget.dueDate),
                                        style: GoogleFonts.quicksand(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: txtClr,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
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
                      ),
                      const SizedBox(height: 16),
                      
                      Center(
                        child: Text(
                          'Dibuat pada ${DateFormat('d MMM yyyy', 'id_ID').format(currentTarget.createdAt)}',
                          style: GoogleFonts.quicksand(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200,
                            width: 1.2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.8),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _showSavingsAdjustmentDialog(context, ref, currentTarget, isAdd: true),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.add_rounded,
                                          color: Colors.teal,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Tambah',
                                          style: GoogleFonts.quicksand(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.teal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 1.2,
                                height: 22,
                                color: isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade300,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _showSavingsAdjustmentDialog(context, ref, currentTarget, isAdd: false),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.remove_rounded,
                                          color: Colors.redAccent,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Tarik',
                                          style: GoogleFonts.quicksand(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showEditTargetSheet(currentTarget);
                              },
                              icon: const Icon(Icons.edit_rounded, size: 14),
                              label: Text(
                                'Ubah Target',
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isDarkMode
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.grey.shade300,
                                ),
                                foregroundColor: isDarkMode ? Colors.white70 : Colors.black87,
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteTarget(currentTarget.id);
                              },
                              icon: const Icon(Icons.delete_outline_rounded, size: 14),
                              label: Text(
                                'Hapus Target',
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.redAccent,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isDarkMode
                                      ? Colors.red.withValues(alpha: 0.2)
                                      : Colors.red.shade100,
                                ),
                                foregroundColor: Colors.redAccent,
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 72,
              color: isDarkMode ? Colors.white10 : Colors.teal.shade50,
            ),
            const SizedBox(height: 18),
            Text(
              'Belum ada target impian',
              style: GoogleFonts.quicksand(
                color: isDarkMode ? Colors.white38 : Colors.black38,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tekan tombol + Tambah Target di bawah untuk mulai merencanakan!',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSavingsAdjustmentDialog(BuildContext context, WidgetRef ref, SavingTargetModel currentTarget, {required bool isAdd}) {
    SavingsAdjustmentDialog.show(context, ref, currentTarget, isAdd: isAdd);
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

