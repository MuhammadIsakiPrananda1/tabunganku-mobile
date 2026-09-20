import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/saving_target_model.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/providers/saving_target_provider.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';
import 'package:tabunganku/features/home/presentation/widgets/savings_adjustment_dialog.dart';

class TargetDetailSheet extends ConsumerWidget {
  final SavingTargetModel target;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TargetDetailSheet({
    super.key,
    required this.target,
    required this.onEdit,
    required this.onDelete,
  });

  static void show({
    required BuildContext context,
    required SavingTargetModel target,
    required WidgetRef ref,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = ref.read(themeProvider) == ThemeMode.dark ||
        (ref.read(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TargetDetailSheet(
        target: target,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);

    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final surfaceColor = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final cardBg = isDarkMode ? Colors.white.withValues(alpha: 0.01) : Colors.grey.shade50;
    final borderColor = isDarkMode ? Colors.white10 : Colors.grey.shade100;

    final targetsAsync = ref.watch(savingTargetsStreamProvider);
    final currentTarget = targetsAsync.value?.firstWhere(
      (t) => t.id == target.id,
      orElse: () => target,
    ) ?? target;

    final targetBalance = currentTarget.savedAmount;

    final progress = (currentTarget.targetAmount > 0)
        ? (targetBalance / currentTarget.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final remainingDays = currentTarget.dueDate.difference(DateTime.now()).inDays;
    final remainingAmount = (currentTarget.targetAmount - targetBalance).clamp(0.0, double.infinity);
    final isCompleted = progress >= 1.0;

    final targetIconColor = isDarkMode ? Colors.tealAccent : Colors.teal.shade600;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).viewInsets.bottom : MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header Section
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.teal.withValues(alpha: 0.15)
                        : Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.track_changes_rounded,
                    color: targetIconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentTarget.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: contentColor,
                        ),
                      ),
                      Text(
                        'Target Tabungan',
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white24 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isCompleted ? 'SELESAI' : 'AKTIF',
                    style: GoogleFonts.quicksand(
                      color: isCompleted ? Colors.green : targetIconColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Progress Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 76,
                        height: 76,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          strokeCap: StrokeCap.round,
                          backgroundColor: isDarkMode
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted ? Colors.green.shade400 : targetIconColor,
                          ),
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: contentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _statPill(
                          'TERKUMPUL',
                          _formatRupiah(targetBalance),
                          isDarkMode,
                          contentColor,
                        ),
                        const SizedBox(height: 10),
                        _statPill(
                          'GOAL',
                          _formatRupiah(currentTarget.targetAmount),
                          isDarkMode,
                          contentColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Info Cards Row
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _infoCard(
                      'SISA KURANG',
                      remainingAmount <= 0 ? 'Lunas' : _formatRupiah(remainingAmount),
                      Icons.hourglass_bottom_rounded,
                      isDarkMode,
                      color: Colors.redAccent,
                      borderColor: borderColor,
                      contentColor: contentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoCard(
                      'JATUH TEMPO',
                      DateFormat('d MMM yyyy', 'id_ID').format(currentTarget.dueDate),
                      Icons.calendar_today_rounded,
                      isDarkMode,
                      subLabel: remainingDays > 0 ? '$remainingDays Hari lagi' : 'Lewat tenggat',
                      borderColor: borderColor,
                      contentColor: contentColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Date Created
            Text(
              'Dibuat pada ${DateFormat('d MMM yyyy', 'id_ID').format(currentTarget.createdAt)}',
              style: GoogleFonts.quicksand(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
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
                      onEdit();
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
                      onDelete();
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
  }

  Widget _statPill(String label, String value, bool isDarkMode, Color contentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: contentColor,
          ),
        ),
      ],
    );
  }

  Widget _infoCard(
    String label,
    String value,
    IconData icon,
    bool isDarkMode, {
    Color? color,
    String? subLabel,
    required Color borderColor,
    required Color contentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.01) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: color ?? (isDarkMode ? Colors.white24 : Colors.grey),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.quicksand(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white24 : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: contentColor,
            ),
          ),
          if (subLabel != null)
            Text(
              subLabel,
              style: GoogleFonts.quicksand(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.teal.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    );
  }

  void _showSavingsAdjustmentDialog(BuildContext context, WidgetRef ref, SavingTargetModel currentTarget, {required bool isAdd}) {
    SavingsAdjustmentDialog.show(context, ref, currentTarget, isAdd: isAdd);
  }
}


