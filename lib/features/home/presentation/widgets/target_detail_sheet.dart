import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/saving_target_model.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/transaction_provider.dart';

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

    // Reactively watch transactions to compute target savings progress
    final transactions = ref.watch(transactionsByGroupProvider(null));
    final targetBalance = transactions
        .where((t) => !t.date.isBefore(target.createdAt))
        .fold<double>(0, (s, t) => s + (t.type == TransactionType.income ? t.amount : -t.amount));

    final progress = (target.targetAmount > 0)
        ? (targetBalance / target.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final remainingDays = target.dueDate.difference(DateTime.now()).inDays;
    final remainingAmount = (target.targetAmount - targetBalance).clamp(0.0, double.infinity);
    final isCompleted = progress >= 1.0;

    final targetIconColor = isDarkMode ? Colors.tealAccent : Colors.teal.shade600;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                        target.name,
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 86,
                        height: 86,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 9,
                          backgroundColor: isDarkMode
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted ? Colors.green.shade400 : targetIconColor,
                          ),
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: GoogleFonts.quicksand(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: contentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
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
                        const SizedBox(height: 14),
                        _statPill(
                          'GOAL',
                          _formatRupiah(target.targetAmount),
                          isDarkMode,
                          contentColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

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
                      DateFormat('d MMM yyyy', 'id_ID').format(target.dueDate),
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
            const SizedBox(height: 24),

            // Date Created
            Text(
              'Dibuat pada ${DateFormat('d MMM yyyy', 'id_ID').format(target.createdAt)}',
              style: GoogleFonts.quicksand(
                fontSize: 10,
                color: isDarkMode ? Colors.white10 : Colors.black12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onEdit();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade500, // teal/green
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Ubah Target',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.red.shade900.withValues(alpha: 0.1)
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onDelete();
                    },
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: isDarkMode ? Colors.red.shade300 : Colors.red,
                      size: 20,
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
}


