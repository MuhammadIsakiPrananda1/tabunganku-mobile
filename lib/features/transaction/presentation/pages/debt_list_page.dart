import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/debt_model.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/debt_provider.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/features/transaction/presentation/widgets/debt_form_sheet.dart';

// ── Type scale ──────────────────────────────────────────────────────────────
// label   : 10  w800  letterSpacing 1.0   (badge, section header)
// caption : 11  w500                      (subtitle, hint)
// body    : 13  w600                      (main text, amount)
// title   : 15  w700                      (page title)

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
      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

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

    final pageBg  = isDark ? AppColors.backgroundDark : const Color(0xFFF0F3F7);
    final cardBg  = isDark ? AppColors.surfaceDark : Colors.white;
    final divClr  = isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.07);
    final subClr  = isDark ? Colors.white38 : Colors.black38;
    final txtClr  = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [

            // ── AppBar ─────────────────────────────────────────────────
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
                    child: Text('Catatan Pinjaman',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: txtClr)),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ── Search bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: GoogleFonts.quicksand(fontSize: 13, color: txtClr),
                decoration: InputDecoration(
                  hintText: 'Cari nama atau keterangan...',
                  hintStyle: GoogleFonts.quicksand(
                      fontSize: 13,
                      color: isDark ? Colors.white24 : Colors.black26),
                  prefixIcon: Icon(Icons.search_rounded,
                      size: 19,
                      color: isDark ? Colors.white24 : Colors.black26),
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
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: divClr)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: divClr)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 1.5)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Filter chips ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _filterChip(
                    label: 'Hutang',
                    icon: Icons.call_made_rounded,
                    color: const Color(0xFFE53935),
                    isSelected: _filter == 'Hutang',
                    isDark: isDark,
                    onTap: () => setState(() => _filter = 'Hutang'),
                  ),
                  const SizedBox(width: 8),
                  _filterChip(
                    label: 'Piutang',
                    icon: Icons.call_received_rounded,
                    color: AppColors.primary,
                    isSelected: _filter == 'Piutang',
                    isDark: isDark,
                    onTap: () => setState(() => _filter = 'Piutang'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ── List ────────────────────────────────────────────────────
            Expanded(
              child: debtsAsync.when(
                data: (debts) {
                  final filtered = debts.where((d) {
                    if (_searchQuery.isNotEmpty) {
                      final q = _searchQuery.toLowerCase();
                      if (!d.contactName.toLowerCase().contains(q) &&
                          !d.title.toLowerCase().contains(q)) return false;
                    }
                    return _filter == 'Hutang'
                        ? d.type == DebtType.hutang
                        : d.type == DebtType.piutang;
                  }).toList();

                  if (filtered.isEmpty) {
                    return _emptyState(isDark, subClr);
                  }

                  final unpaid = filtered.where((d) => !d.isPaid).toList();
                  final paid   = filtered.where((d) =>  d.isPaid).toList();

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    children: [
                      if (unpaid.isNotEmpty) ...[
                        _sectionHeader('Belum Lunas', const Color(0xFFE53935), isDark),
                        const SizedBox(height: 8),
                        ...unpaid.map((d) => _debtCard(context, ref, d, isDark, txtClr, subClr, divClr)),
                      ],
                      if (paid.isNotEmpty) ...[
                        if (unpaid.isNotEmpty) const SizedBox(height: 20),
                        _sectionHeader('Sudah Lunas', AppColors.primary, isDark),
                        const SizedBox(height: 8),
                        ...paid.map((d) => _debtCard(context, ref, d, isDark, txtClr, subClr, divClr)),
                      ],
                    ],
                  );
                },
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, _) => Center(
                    child: Text('Error: $e',
                        style: GoogleFonts.quicksand(fontSize: 13))),
              ),
            ),
          ],
        ),
      ),

      // ── FAB ──────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => DebtFormSheet.show(
          context,
          initialType:
              _filter == 'Piutang' ? DebtType.piutang : DebtType.hutang,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text('Tambah',
            style: GoogleFonts.quicksand(
                fontSize: 13, fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

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
              ? color.withValues(alpha: 0.12)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 13,
                color: isSelected
                    ? color
                    : (isDark ? Colors.white38 : Colors.black38)),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? color
                      : (isDark ? Colors.white38 : Colors.black38),
                )),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.quicksand(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: isDark ? Colors.white38 : Colors.black38,
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
    final accentColor = isHutang ? const Color(0xFFE53935) : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: divClr),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(
                        alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isHutang
                        ? Icons.call_made_rounded
                        : Icons.call_received_rounded,
                    color: accentColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debt.contactName,
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: debt.isPaid
                              ? subClr
                              : txtClr,
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
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: subClr,
                          ),
                        ),
                      ],
                      if (debt.dueDate != null) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.event_rounded,
                                size: 11, color: subClr),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('d MMM yyyy').format(debt.dueDate!),
                              style: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: subClr,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Amount + badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _fmt.format(debt.amount),
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: debt.isPaid ? subClr : accentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: debt.isPaid
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        debt.isPaid ? 'LUNAS' : (isHutang ? 'HUTANG' : 'PIUTANG'),
                        style: GoogleFonts.quicksand(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: debt.isPaid ? AppColors.primary : accentColor,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_stories_outlined,
                size: 52, color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 20),
          Text('Belum ada catatan',
              style: GoogleFonts.quicksand(
                  fontSize: 13, fontWeight: FontWeight.w700, color: subClr)),
          const SizedBox(height: 6),
          Text('Catat hutang & piutangmu\nagar keuangan lebih teratur.',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: subClr.withValues(alpha: 0.6))),
        ],
      ),
    );
  }

  // ── Bottom Sheet Options ──────────────────────────────────────────────────

  void _showOptions(
      BuildContext context, WidgetRef ref, DebtModel debt, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pull bar
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Debt info summary
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: (debt.type == DebtType.hutang
                        ? const Color(0xFFE53935)
                        : AppColors.primary)
                    .withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    debt.type == DebtType.hutang
                        ? Icons.call_made_rounded
                        : Icons.call_received_rounded,
                    size: 16,
                    color: debt.type == DebtType.hutang
                        ? const Color(0xFFE53935)
                        : AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(debt.contactName,
                            style: GoogleFonts.quicksand(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87)),
                        Text(_fmt.format(debt.amount),
                            style: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white38 : Colors.black38)),
                      ],
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
                color: AppColors.primary,
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
              color: const Color(0xFFE53935),
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
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label,
          style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          )),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _markAsPaid(
      BuildContext context, WidgetRef ref, DebtModel debt) async {
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            '${isHutang ? 'Hutang' : 'Piutang'} lunas & tercatat di Riwayat',
            style: GoogleFonts.quicksand(
                fontSize: 13, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ));
    }
  }

  Future<void> _deleteDebt(
      BuildContext context, WidgetRef ref, DebtModel debt) async {
    try {
      await ref.read(transactionServiceProvider).deleteTransaction(debt.id);
    } catch (_) {}
    await ref.read(debtServiceProvider).deleteDebt(debt.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Catatan dihapus',
            style: GoogleFonts.quicksand(
                fontSize: 13, fontWeight: FontWeight.bold)),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ));
    }
  }
}
