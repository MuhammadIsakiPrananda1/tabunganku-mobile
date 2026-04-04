import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/widgets/transaction_tile.dart';
import 'package:tabunganku/features/transaction/presentation/widgets/transaction_detail_sheet.dart';
import 'package:tabunganku/providers/transaction_provider.dart';

class TransactionPage extends ConsumerStatefulWidget {
  const TransactionPage({super.key});

  @override
  ConsumerState<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends ConsumerState<TransactionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Riwayat',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor:
              isDarkMode ? Colors.white38 : AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: const [
            Tab(text: 'Transaksi'),
            Tab(text: 'Hutang/Piutang'),
            Tab(text: 'Belanja'),
          ],
        ),
      ),
      body: transactionsAsync.when(
        data: (allTransactions) {
          // Filter berdasarkan kategori
          final transaksiList = allTransactions
              .where((t) =>
                  t.groupId == null &&
                  t.category != 'Hutang' &&
                  t.category != 'Piutang' &&
                  !t.id.startsWith('shopping_'))
              .toList();

          final hutangPiutangList = allTransactions
              .where((t) =>
                  t.category == 'Hutang' || t.category == 'Piutang')
              .toList();

          final belanjaList = allTransactions
              .where((t) => t.id.startsWith('shopping_'))
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTransactionTab(context, transaksiList, isDarkMode, 'transaksi'),
              _buildHutangPiutangTab(context, hutangPiutangList, isDarkMode),
              _buildBelanjaTab(context, belanjaList, isDarkMode),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TAB 1: Transaksi (Pemasukan & Pengeluaran)
  // ─────────────────────────────────────────────
  Widget _buildTransactionTab(
    BuildContext context,
    List<TransactionModel> transactions,
    bool isDarkMode,
    String type,
  ) {
    if (transactions.isEmpty) {
      return _buildEmptyState(
        isDarkMode,
        icon: Icons.receipt_long_outlined,
        label: 'Belum ada transaksi',
      );
    }

    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (s, t) => s + t.amount);
    final expense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (s, t) => s + t.amount);

    return Column(
      children: [
        // Summary bar
        _buildSummaryBar(isDarkMode, income: income, expense: expense),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final t = transactions[index];
              return InkWell(
                onTap: () => TransactionDetailSheet.show(
                  context,
                  ref,
                  t,
                  onEdit: () {},
                  onDelete: () => _deleteTransaction(context, ref, t, isDarkMode),
                ),
                borderRadius: BorderRadius.circular(16),
                child: TransactionTile(transaction: t),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // TAB 2: Hutang & Piutang
  // ─────────────────────────────────────────────
  Widget _buildHutangPiutangTab(
    BuildContext context,
    List<TransactionModel> transactions,
    bool isDarkMode,
  ) {
    if (transactions.isEmpty) {
      return _buildEmptyState(
        isDarkMode,
        icon: Icons.account_balance_wallet_outlined,
        label: 'Belum ada riwayat hutang/piutang',
        subtitle: 'Akan muncul saat kamu menandai hutang/piutang sebagai lunas',
      );
    }

    final hutangList =
        transactions.where((t) => t.category == 'Hutang').toList();
    final piutangList =
        transactions.where((t) => t.category == 'Piutang').toList();

    final totalHutang =
        hutangList.fold<double>(0, (s, t) => s + t.amount);
    final totalPiutang =
        piutangList.fold<double>(0, (s, t) => s + t.amount);

    return Column(
      children: [
        // Summary hutang vs piutang
        Container(
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.shade100,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildSumItem(
                  isDarkMode,
                  label: 'DIBAYAR (HUTANG)',
                  amount: totalHutang,
                  color: Colors.red.shade400,
                  icon: Icons.call_made_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: isDarkMode
                    ? Colors.white12
                    : Colors.grey.shade200,
              ),
              Expanded(
                child: _buildSumItem(
                  isDarkMode,
                  label: 'DITERIMA (PIUTANG)',
                  amount: totalPiutang,
                  color: Colors.green.shade400,
                  icon: Icons.call_received_rounded,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
            children: [
              if (hutangList.isNotEmpty) ...[
                _buildGroupHeader('HUTANG TERBAYAR', Colors.red.shade400, isDarkMode),
                const SizedBox(height: 8),
                ...hutangList.map((t) => _buildDebtTile(context, ref, t, isDarkMode)),
                const SizedBox(height: 20),
              ],
              if (piutangList.isNotEmpty) ...[
                _buildGroupHeader('PIUTANG DITERIMA', Colors.green.shade400, isDarkMode),
                const SizedBox(height: 8),
                ...piutangList.map((t) => _buildDebtTile(context, ref, t, isDarkMode)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // TAB 3: Belanja
  // ─────────────────────────────────────────────
  Widget _buildBelanjaTab(
    BuildContext context,
    List<TransactionModel> transactions,
    bool isDarkMode,
  ) {
    if (transactions.isEmpty) {
      return _buildEmptyState(
        isDarkMode,
        icon: Icons.shopping_bag_outlined,
        label: 'Belum ada riwayat belanja',
        subtitle: 'Akan muncul saat kamu menandai item belanja sebagai dibeli',
      );
    }

    final total = transactions.fold<double>(0, (s, t) => s + t.amount);

    return Column(
      children: [
        // Summary total belanja
        Container(
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: isDarkMode ? 0.15 : 0.08),
                AppColors.primary.withValues(alpha: isDarkMode ? 0.05 : 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shopping_bag_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL BELANJA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: isDarkMode ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatRupiah(total),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isDarkMode ? Colors.white : Colors.teal.shade900,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${transactions.length} item',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final t = transactions[index];
              return _buildShoppingTile(context, ref, t, isDarkMode);
            },
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SHARED WIDGETS
  // ─────────────────────────────────────────────
  Widget _buildSummaryBar(bool isDarkMode,
      {required double income, required double expense}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSumItem(isDarkMode,
                label: 'PEMASUKAN',
                amount: income,
                color: Colors.green.shade400,
                icon: Icons.arrow_downward_rounded),
          ),
          Container(
              width: 1,
              height: 40,
              color: isDarkMode ? Colors.white12 : Colors.grey.shade200),
          Expanded(
            child: _buildSumItem(isDarkMode,
                label: 'PENGELUARAN',
                amount: expense,
                color: Colors.red.shade400,
                icon: Icons.arrow_upward_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildSumItem(bool isDarkMode,
      {required String label,
      required double amount,
      required Color color,
      required IconData icon}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: isDarkMode ? Colors.white38 : Colors.black38,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatRupiah(amount),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupHeader(String label, Color color, bool isDarkMode) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: isDarkMode ? Colors.white38 : Colors.black38,
          ),
        ),
      ],
    );
  }

  Widget _buildDebtTile(
      BuildContext context, WidgetRef ref, TransactionModel t, bool isDarkMode) {
    final isHutang = t.category == 'Hutang';
    final color = isHutang ? Colors.red.shade400 : Colors.green.shade400;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.shade100),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isHutang ? Icons.call_made_rounded : Icons.call_received_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                if (t.description.isNotEmpty)
                  Text(
                    t.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDarkMode ? Colors.white38 : Colors.black38,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            _formatRupiah(t.amount),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingTile(
      BuildContext context, WidgetRef ref, TransactionModel t, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.shade100),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.shopping_bag_rounded,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                if (t.description.isNotEmpty)
                  Text(
                    t.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDarkMode ? Colors.white38 : Colors.black38,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            _formatRupiah(t.amount),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode,
      {required IconData icon,
      required String label,
      String? subtitle}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                size: 64, color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 20),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? Colors.white38 : Colors.black38,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white24 : Colors.black26,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _deleteTransaction(
      BuildContext context, WidgetRef ref, TransactionModel t, bool isDarkMode) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDarkMode ? AppColors.surfaceDark : Colors.white,
        title: Text('Hapus Riwayat?',
            style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87)),
        content: Text('Hapus "${t.title}"?',
            style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(transactionServiceProvider).deleteTransaction(t.id);
    }
  }
}
