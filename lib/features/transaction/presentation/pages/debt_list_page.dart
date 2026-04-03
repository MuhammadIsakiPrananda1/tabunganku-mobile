import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/debt_model.dart';
import 'package:tabunganku/providers/debt_provider.dart';
import 'package:tabunganku/features/transaction/presentation/widgets/debt_form_sheet.dart';

class DebtListPage extends ConsumerWidget {
  const DebtListPage({super.key});

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtsStreamProvider);
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Catatan Hutang',
            style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: debtsAsync.when(
        data: (debts) {
          if (debts.isEmpty) {
            return _buildEmptyState(context, isDarkMode);
          }

          final unpaidDebts = debts.where((d) => !d.isPaid).toList();
          final paidDebts = debts.where((d) => d.isPaid).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              if (unpaidDebts.isNotEmpty) ...[
                _buildSectionHeader('Belum Lunas', Colors.orange, isDarkMode),
                const SizedBox(height: 12),
                ...unpaidDebts.map((d) => _buildDebtTile(context, ref, d, isDarkMode)),
              ],
              if (paidDebts.isNotEmpty) ...[
                const SizedBox(height: 32),
                _buildSectionHeader('Sudah Lunas', Colors.green, isDarkMode),
                const SizedBox(height: 12),
                ...paidDebts.map((d) => _buildDebtTile(context, ref, d, isDarkMode)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => DebtFormSheet.show(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Catatan', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDarkMode ? 0.05 : 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_stories_outlined,
                size: 80, color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum ada catatan',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDarkMode ? Colors.white60 : Colors.black38),
          ),
          const SizedBox(height: 8),
          Text(
            'Catat semua hutang & piutangmu\nagar keuangan lebih teratur!',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, color: isDarkMode ? Colors.white38 : Colors.black26),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color, bool isDarkMode) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: isDarkMode ? Colors.white54 : Colors.black38,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildDebtTile(
      BuildContext context, WidgetRef ref, DebtModel debt, bool isDarkMode) {
    final isHutang = debt.type == DebtType.hutang;
    final color = isHutang ? Colors.red : Colors.green;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showOptions(context, ref, debt, isDarkMode),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDarkMode ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isHutang ? Icons.call_made_rounded : Icons.call_received_rounded,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debt.contactName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isDarkMode ? Colors.white : Colors.black87,
                          decoration: debt.isPaid ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        debt.title,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white38 : Colors.black45,
                        ),
                      ),
                      if (debt.dueDate != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.event_rounded,
                                size: 12,
                                color: isDarkMode ? Colors.white24 : Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd MMM yyyy').format(debt.dueDate!),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white24 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatRupiah(debt.amount),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: debt.isPaid
                            ? (isDarkMode ? Colors.white24 : Colors.grey.shade400)
                            : color,
                      ),
                    ),
                    if (debt.isPaid)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'LUNAS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Colors.green,
                          ),
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

  void _showOptions(
      BuildContext context, WidgetRef ref, DebtModel debt, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 32),
            if (!debt.isPaid)
              _buildOptionTile(
                icon: Icons.check_circle_outline_rounded,
                label: 'Tandai Sudah Lunas',
                color: Colors.green,
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.pop(context);
                  _markAsPaid(context, ref, debt);
                },
              ),
            _buildOptionTile(
              icon: Icons.edit_outlined,
              label: 'Edit Catatan',
              color: Colors.blue,
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.pop(context);
                DebtFormSheet.show(context, debt: debt);
              },
            ),
            _buildOptionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Hapus Catatan',
              color: Colors.red,
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.pop(context);
                _deleteDebt(context, ref, debt);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  void _markAsPaid(BuildContext context, WidgetRef ref, DebtModel debt) async {
    final updatedDebt = debt.copyWith(isPaid: true);
    await ref.read(debtServiceProvider).updateDebt(updatedDebt);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan ditandai sebagai lunas'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteDebt(BuildContext context, WidgetRef ref, DebtModel debt) async {
    await ref.read(debtServiceProvider).deleteDebt(debt.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan dihapus'), behavior: SnackBarBehavior.floating),
      );
    }
  }
}
