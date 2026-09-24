/// Page: DebtListPage
///
/// Daftar transaksi hutang dan piutang beserta riwayat cicilan.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';
import 'package:tabunganku/models/debt_model.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/debt_provider.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/features/transaction/presentation/widgets/debt_form_sheet.dart';

class DebtListPage extends ConsumerStatefulWidget {
  const DebtListPage({super.key});

  @override
  ConsumerState<DebtListPage> createState() => _DebtListPageState();
}

class _DebtListPageState extends ConsumerState<DebtListPage> {
  String _filter = 'Hutang';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  static final _fmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debtsAsync = ref.watch(debtsStreamProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    final pageBg = isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC);
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final divClr = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final subClr = isDark ? Colors.white54 : const Color(0xFF64748B);
    final txtClr = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 17,
                      color: isDark ? Colors.white70 : AppColors.primaryDark,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  Expanded(
                    child: Text(
                      'Catatan Pinjaman',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: txtClr,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: txtClr,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari nama atau keterangan...',
                  hintStyle: GoogleFonts.quicksand(
                    fontSize: 12.5,
                    color: isDark ? Colors.white24 : Colors.black38,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 19,
                    color: isDark ? Colors.white38 : Colors.black45,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 17),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: divClr),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: divClr),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 11,
                    horizontal: 14,
                  ),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Filter Chips (Hutang / Piutang)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _filterChip(
                    label: 'Hutang',
                    icon: Icons.north_east_rounded,
                    color: const Color(0xFFF43F5E),
                    isSelected: _filter == 'Hutang',
                    isDark: isDark,
                    onTap: () => setState(() => _filter = 'Hutang'),
                  ),
                  const SizedBox(width: 8),
                  _filterChip(
                    label: 'Piutang',
                    icon: Icons.south_west_rounded,
                    color: const Color(0xFF10B981),
                    isSelected: _filter == 'Piutang',
                    isDark: isDark,
                    onTap: () => setState(() => _filter = 'Piutang'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Debt List
            Expanded(
              child: debtsAsync.when(
                data: (debts) {
                  final filtered = debts.where((d) {
                    if (_searchQuery.isNotEmpty) {
                      final q = _searchQuery.toLowerCase();
                      if (!d.contactName.toLowerCase().contains(q) &&
                          !d.title.toLowerCase().contains(q)) {
                        return false;
                      }
                    }
                    return _filter == 'Hutang'
                        ? d.type == DebtType.hutang
                        : d.type == DebtType.piutang;
                  }).toList();

                  if (filtered.isEmpty) {
                    return _emptyState(isDark, subClr);
                  }

                  final unpaid = filtered.where((d) => !d.isPaid).toList();
                  final paid = filtered.where((d) => d.isPaid).toList();

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      if (unpaid.isNotEmpty) ...[
                        _sectionHeader(
                          'Belum Lunas',
                          const Color(0xFFF43F5E),
                          isDark,
                        ),
                        const SizedBox(height: 8),
                        ...unpaid.map(
                          (d) => _debtCard(
                            context,
                            ref,
                            d,
                            isDark,
                            txtClr,
                            subClr,
                            divClr,
                          ),
                        ),
                      ],
                      if (paid.isNotEmpty) ...[
                        if (unpaid.isNotEmpty) const SizedBox(height: 18),
                        _sectionHeader(
                          'Sudah Lunas',
                          const Color(0xFF10B981),
                          isDark,
                        ),
                        const SizedBox(height: 8),
                        ...paid.map(
                          (d) => _debtCard(
                            context,
                            ref,
                            d,
                            isDark,
                            txtClr,
                            subClr,
                            divClr,
                          ),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Error: $e',
                    style: GoogleFonts.quicksand(fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => DebtFormSheet.show(
          context,
          initialType:
              _filter == 'Piutang' ? DebtType.piutang : DebtType.hutang,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text(
          'Tambah',
          style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.22 : 0.12)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06)),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? color
                  : (isDark ? Colors.white38 : Colors.black38),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? color
                    : (isDark ? Colors.white60 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 13,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.quicksand(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: isDark ? Colors.white54 : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _debtCard(
    BuildContext context,
    WidgetRef ref,
    DebtModel debt,
    bool isDark,
    Color txtClr,
    Color subClr,
    Color divClr,
  ) {
    final isHutang = debt.type == DebtType.hutang;
    final accentColor =
        isHutang ? const Color(0xFFF43F5E) : const Color(0xFF10B981);

    final isOverdue = !debt.isPaid &&
        debt.dueDate != null &&
        debt.dueDate!.isBefore(
          DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue && !debt.isPaid
              ? const Color(0xFFEF4444).withValues(alpha: 0.35)
              : divClr,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showOptions(context, ref, debt, isDark),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Soft Squircle Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withValues(alpha: isDark ? 0.20 : 0.14),
                        accentColor.withValues(alpha: isDark ? 0.08 : 0.04),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.18),
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      debt.isPaid
                          ? Icons.check_circle_rounded
                          : (isHutang
                              ? Icons.north_east_rounded
                              : Icons.south_west_rounded),
                      color: debt.isPaid ? const Color(0xFF10B981) : accentColor,
                      size: 19,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Center Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debt.contactName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.quicksand(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: debt.isPaid ? subClr : txtClr,
                          decoration:
                              debt.isPaid ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (debt.title.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          debt.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.quicksand(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: subClr,
                          ),
                        ),
                      ],
                      if (debt.dueDate != null) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              isOverdue
                                  ? Icons.warning_amber_rounded
                                  : Icons.calendar_today_rounded,
                              size: 11,
                              color: isOverdue
                                  ? const Color(0xFFEF4444)
                                  : subClr,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isOverdue
                                  ? 'Terlambat (${DateFormat('d MMM yyyy').format(debt.dueDate!)})'
                                  : DateFormat('d MMM yyyy').format(debt.dueDate!),
                              style: GoogleFonts.quicksand(
                                fontSize: 10.5,
                                fontWeight: isOverdue
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: isOverdue
                                    ? const Color(0xFFEF4444)
                                    : subClr,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Right Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _fmt.format(debt.amount),
                      style: GoogleFonts.quicksand(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: debt.isPaid
                            ? subClr
                            : (isDark
                                ? Colors.white
                                : (isHutang
                                    ? const Color(0xFFE11D48)
                                    : const Color(0xFF059669))),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: debt.isPaid
                            ? const Color(0xFF10B981).withValues(alpha: 0.12)
                            : accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (debt.isPaid
                                  ? const Color(0xFF10B981)
                                  : accentColor)
                              .withValues(alpha: 0.20),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        debt.isPaid
                            ? 'LUNAS'
                            : (isHutang ? 'HUTANG' : 'PIUTANG'),
                        style: GoogleFonts.quicksand(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: debt.isPaid
                              ? const Color(0xFF10B981)
                              : accentColor,
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

  Widget _emptyState(bool isDark, Color subClr) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.22),
                  width: 1.2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.handshake_rounded,
                  size: 34,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Belum ada catatan',
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Catat hutang & piutangmu\nagar keuangan lebih teratur.',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: subClr,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(
    BuildContext context,
    WidgetRef ref,
    DebtModel debt,
    bool isDark,
  ) {
    final isHutang = debt.type == DebtType.hutang;
    final accentColor =
        isHutang ? const Color(0xFFF43F5E) : const Color(0xFF10B981);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          24 + MediaQuery.of(ctx).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),

            // Header Info Tile
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.18),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isHutang
                        ? Icons.north_east_rounded
                        : Icons.south_west_rounded,
                    size: 18,
                    color: accentColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          debt.contactName,
                          style: GoogleFonts.quicksand(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          _fmt.format(debt.amount),
                          style: GoogleFonts.quicksand(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      debt.isPaid
                          ? 'Lunas'
                          : (isHutang ? 'Hutang' : 'Piutang'),
                      style: GoogleFonts.quicksand(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            if (!debt.isPaid)
              _optionTile(
                icon: Icons.check_circle_outline_rounded,
                label: 'Tandai Sudah Lunas',
                color: const Color(0xFF10B981),
                isDark: isDark,
                onTap: () {
                  Navigator.pop(ctx);
                  _markAsPaid(context, ref, debt);
                },
              ),
            _optionTile(
              icon: Icons.edit_outlined,
              label: 'Edit Catatan',
              color: AppColors.primary,
              isDark: isDark,
              onTap: () {
                Navigator.pop(ctx);
                DebtFormSheet.show(context, debt: debt);
              },
            ),
            _optionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Hapus Catatan',
              color: const Color(0xFFF43F5E),
              isDark: isDark,
              onTap: () {
                Navigator.pop(ctx);
                _deleteDebt(context, ref, debt);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        label,
        style: GoogleFonts.quicksand(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Future<void> _markAsPaid(
    BuildContext context,
    WidgetRef ref,
    DebtModel debt,
  ) async {
    await ref.read(debtServiceProvider).updateDebt(debt.copyWith(isPaid: true));

    final isHutang = debt.type == DebtType.hutang;
    final tx = TransactionModel(
      id: debt.id,
      title: isHutang
          ? 'Pembayaran Hutang ke ${debt.contactName}'
          : 'Pembayaran Piutang dari ${debt.contactName}',
      description: debt.title.isNotEmpty
          ? debt.title
          : (isHutang ? 'Hutang' : 'Piutang'),
      amount: debt.amount,
      type: isHutang ? TransactionType.expense : TransactionType.income,
      date: DateTime.now(),
      category: isHutang ? 'Hutang' : 'Piutang',
    );
    await ref.read(transactionServiceProvider).addTransaction(tx);

    if (context.mounted) {
      showTopToast(
        context,
        '${isHutang ? 'Hutang' : 'Piutang'} lunas & tercatat di Riwayat',
      );
    }
  }

  Future<void> _deleteDebt(
    BuildContext context,
    WidgetRef ref,
    DebtModel debt,
  ) async {
    try {
      await ref.read(transactionServiceProvider).deleteTransaction(debt.id);
    } catch (_) {}
    await ref.read(debtServiceProvider).deleteDebt(debt.id);
    if (context.mounted) {
      showTopToast(context, 'Catatan dihapus');
    }
  }
}
