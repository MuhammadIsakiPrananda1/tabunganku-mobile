import 'package:flutter/material.dart';
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

    final txtClr = isDarkMode ? Colors.white : Colors.black87;
    final pageBg = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF0F3F7);

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar (Catatan Pinjaman style) ────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 17,
                        color: isDarkMode ? Colors.white70 : AppColors.primaryDark),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  Expanded(
                    child: Text(
                      'Target Saya',
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

            // ── Body content ───────────────────────────────────────────
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
      label,
      style: GoogleFonts.quicksand(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white70 : Colors.black87,
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

    final cardBg = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);
    final subClr = isDarkMode ? Colors.white38 : Colors.grey.shade500;
    final txtClr = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 2, 16, 12),
      padding: const EdgeInsets.all(20),
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
          // Row 1: Title & Status Badge
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
                  color: totalCount == 0
                      ? (isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100)
                      : (overallProgress >= 1.0
                          ? Colors.green.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: totalCount == 0
                        ? (isDarkMode ? Colors.white10 : Colors.grey.shade300)
                        : (overallProgress >= 1.0
                            ? Colors.green.withValues(alpha: 0.2)
                            : AppColors.primary.withValues(alpha: 0.2)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      totalCount == 0
                          ? Icons.hourglass_empty_rounded
                          : (overallProgress >= 1.0
                              ? Icons.check_circle_rounded
                              : Icons.cached_rounded),
                      color: totalCount == 0
                          ? (isDarkMode ? Colors.white30 : Colors.grey.shade500)
                          : (overallProgress >= 1.0 ? Colors.green : AppColors.primary),
                      size: 11,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      totalCount == 0
                          ? 'Kosong'
                          : '${(overallProgress * 100).toInt()}% Tercapai',
                      style: GoogleFonts.quicksand(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: totalCount == 0
                            ? (isDarkMode ? Colors.white54 : Colors.grey.shade600)
                            : (overallProgress >= 1.0 ? Colors.green : AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Row 2: Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progres Target',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: subClr,
                ),
              ),
              Text(
                '$totalCount Barang Impian',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: txtClr,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: totalEstimated > 0 ? overallProgress : 0.0,
              backgroundColor: isDarkMode
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 20),

          // Divider
          Divider(
            height: 1,
            color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
          ),
          const SizedBox(height: 16),

          // Row 3: Terkumpul & Sisa Target
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
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'TERKUMPUL',
                          style: GoogleFonts.quicksand(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: subClr,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(totalSaved),
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
                color: isDarkMode
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
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'SISA TARGET',
                          style: GoogleFonts.quicksand(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: subClr,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(remainingNeeded),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.red.shade700,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Target Berhasil Ditambahkan!',
                                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
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

    final cardBg = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.grey.shade100;
    final subClr = isDarkMode ? Colors.white30 : Colors.grey.shade400;
    final txtClr = isDarkMode ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showEditDialog(target),
          onLongPress: () => _deleteTarget(target.id),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Icon placeholder
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

                // Name & meta
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
                      // Thin progress bar
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

                // Price & percentage on the right
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

  void _showEditDialog(SavingTargetModel target) async {
    final nameController = TextEditingController(text: target.name);
    final amountController = TextEditingController(
        text: target.targetAmount
            .round()
            .toString()
            .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.'));
    DateTime selectedDate = target.dueDate;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    bool nameHasError = false;
    bool amountHasError = false;
    bool dateIsFocused = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
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

          return AlertDialog(
            backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(
              'Ubah Target',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                color: contentColor,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputLabel('Nama Barang', isDarkMode),
                const SizedBox(height: 8),
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
                      setDialogState(() => nameHasError = false);
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildInputLabel('Harga Estimasi', isDarkMode),
                const SizedBox(height: 8),
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
                        setDialogState(() => amountHasError = false);
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildInputLabel('Tenggat Tanggal Target', isDarkMode),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    setDialogState(() => dateIsFocused = true);
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    setDialogState(() => dateIsFocused = false);
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: dateBorderColor,
                        width: dateBorderWidth,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            DateFormat('d MMMM yyyy', 'id_ID').format(selectedDate),
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              color: contentColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down_rounded,
                            color: isDarkMode ? Colors.white24 : Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: GoogleFonts.quicksand(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final nameVal = nameController.text.trim();
                  final amount = double.tryParse(amountController.text.replaceAll('.', '')) ?? 0;

                  setDialogState(() {
                    nameHasError = nameVal.isEmpty;
                    amountHasError = amount <= 0;
                  });

                  if (nameHasError || amountHasError) {
                    String errorMessage = 'Nama target tidak boleh kosong!';
                    if (amountHasError) {
                      errorMessage = 'Estimasi harga harus lebih dari 0!';
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage,
                                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red.shade700,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    return;
                  }

                  await ref.read(savingTargetServiceProvider).updateTarget(target.copyWith(
                        name: nameVal,
                        targetAmount: amount,
                        dueDate: selectedDate,
                      ));
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Target berhasil diperbarui!',
                              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Simpan',
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Target berhasil dihapus.'),
          ),
        );
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
