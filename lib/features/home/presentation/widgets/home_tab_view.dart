import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/models/saving_target_model.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/providers/saving_target_provider.dart';
import 'package:tabunganku/core/constants/quick_action_type.dart';
import '../../../../core/constants/app_version.dart';
import 'package:tabunganku/core/constants/transaction_categories.dart';
import 'package:tabunganku/models/gold_investment_model.dart';
import 'package:tabunganku/providers/gold_provider.dart';
import 'package:tabunganku/providers/bills_provider.dart';
import 'package:tabunganku/providers/investment_provider.dart';
import 'package:tabunganku/providers/insurance_provider.dart';

class HomeTabView extends ConsumerStatefulWidget {
  final bool showBalance;
  final VoidCallback onToggleBalance;
  final Function(TransactionModel) onTransactionTap;
  final Function(SavingTargetModel, double) onTargetTap;
  final Function(QuickActionType) onActionTap;

  const HomeTabView({
    super.key,
    required this.showBalance,
    required this.onToggleBalance,
    required this.onTransactionTap,
    required this.onTargetTap,
    required this.onActionTap,
  });

  @override
  ConsumerState<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends ConsumerState<HomeTabView> {
  int _currentTargetIndex = 0;
  int _selectedAllocationTab = 2;

  String _formatRupiah(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final formatted = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(absAmount);
    return isNegative ? '-$formatted' : formatted;
  }

  @override
  Widget build(BuildContext context) {

    final personalTransactions = ref.watch(transactionsByGroupProvider(null));
    final transactions = List<TransactionModel>.from(personalTransactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    final now = DateTime.now();
    final monthlyTransactions = transactions
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .toList();

    final totalIncome = monthlyTransactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final totalExpense = monthlyTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final allTimeIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final allTimeExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final totalBalance = allTimeIncome - allTimeExpense;

    final targetsAsync = ref.watch(savingTargetsStreamProvider);
    final targets = targetsAsync.valueOrNull ?? [];

final goldTxs = ref.watch(goldTransactionsStreamProvider).valueOrNull ?? [];
    final goldGramBalance = goldTxs.fold<double>(
        0,
        (sum, t) =>
            sum + (t.type == GoldTransactionType.buy ? t.grams : -t.grams));

    final bills = ref.watch(billsStreamProvider).valueOrNull ?? [];
    final unpaidBillsTotal =
        bills.fold<double>(0, (sum, b) => sum + (b.isPaid ? 0 : b.amount));

    final investments = ref.watch(investmentStreamProvider).valueOrNull ?? [];
    final totalInvestmentValuation =
        investments.fold<double>(0, (sum, i) => sum + i.currentValuation);

    final insurances = ref.watch(insuranceStreamProvider).valueOrNull ?? [];
    final totalMonthlyInsurance =
        insurances.fold<double>(0, (sum, i) => sum + i.premiumAmount);

    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(32),

              boxShadow: isDarkMode
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [

                Positioned(
                  top: -40,
                  right: -30,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber
                          .withValues(alpha: isDarkMode ? 0.05 : 0.08),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'TOTAL SALDO TERKUMPUL',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                          color: isDarkMode
                              ? Colors.white30
                              : Colors.teal.shade800.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 40),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.showBalance
                                    ? _formatRupiah(totalBalance)
                                    : '••••••',
                                style: GoogleFonts.quicksand(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.teal.shade900,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              widget.showBalance
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: isDarkMode
                                  ? Colors.white24
                                  : Colors.teal.shade700.withValues(alpha: 0.3),
                              size: 22,
                            ),
                            onPressed: widget.onToggleBalance,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _buildEstimationCard(
                          totalBalance, totalIncome, totalExpense, isDarkMode),
                      const SizedBox(height: 20),

Container(
                        height: 1,
                        width: double.infinity,
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.teal.shade50.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 20),

Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: _miniStat('Pemasukan', totalIncome,
                                  Colors.green.shade600, isDarkMode,
                                  center: true)),
                          const SizedBox(width: 20),
                          Container(
                              width: 1.2,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1),
                                color: isDarkMode
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.teal.shade50,
                              )),
                          const SizedBox(width: 20),
                          Expanded(
                              child: _miniStat('Pengeluaran', totalExpense,
                                  Colors.red.shade600, isDarkMode,
                                  center: true)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

_buildActionGrid(
            isDarkMode,
            goldGramBalance: goldGramBalance,
            unpaidBillsTotal: unpaidBillsTotal,
            totalInvestmentValuation: totalInvestmentValuation,
            totalMonthlyInsurance: totalMonthlyInsurance,
            targets: targets,
          ),

          const SizedBox(height: 24),
          _buildSavingTargetSection(transactions, targets, isDarkMode),

          const SizedBox(height: 12),
          _buildAllocationSection(
              totalIncome, totalExpense, monthlyTransactions, isDarkMode),

          const SizedBox(height: 24),

          _buildRecentActivitySection(transactions, isDarkMode),

          const SizedBox(height: 40),
          _buildWatermark(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildEstimationCard(double totalBalance, double totalIncome,
      double totalExpense, bool isDarkMode) {
    final now = DateTime.now();
    final totalDays = DateTime(now.year, now.month + 1, 0).day;
    final day = now.day;
    final currentDay = day > 0 ? day : 1;
    final estIncome = (totalIncome / currentDay) * totalDays;
    final estExpense = (totalExpense / currentDay) * totalDays;

    final rawRemainingNet =
        (estIncome - totalIncome) - (estExpense - totalExpense);

final double dampingFactor = rawRemainingNet >= 0
        ? 1.0
        : (currentDay / 10.0).clamp(0.1, 1.0);
    final remainingNet = rawRemainingNet * dampingFactor;
    
    final projectedBalance = totalBalance + remainingNet;

    final isDanger = projectedBalance < totalBalance;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDanger
            ? Colors.red.withValues(alpha: isDarkMode ? 0.08 : 0.04)
            : (isDarkMode
                ? Colors.white.withValues(alpha: 0.02)
                : Colors.teal.shade50.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDanger
              ? Colors.red.withValues(alpha: 0.1)
              : (isDarkMode ? Colors.white10 : Colors.teal.shade100.withValues(alpha: 0.15)),
          width: 0.5,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDanger ? Icons.trending_down_rounded : Icons.trending_up_rounded,
              size: 11,
              color: isDanger ? Colors.red : Colors.teal,
            ),
            const SizedBox(width: 6),
            Text(
              'Saldo Akhir Bulan:',
              style: GoogleFonts.quicksand(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white30 : Colors.teal.shade700,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              _formatRupiah(projectedBalance),
              style: GoogleFonts.quicksand(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isDanger
                    ? Colors.redAccent.shade100
                    : (isDarkMode ? Colors.tealAccent : Colors.teal.shade900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, double amount, Color color, bool isDarkMode,
      {bool center = false}) {
    return Column(
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: GoogleFonts.quicksand(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white54 : Colors.grey.shade500,
                letterSpacing: 1.0)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.showBalance ? _formatRupiah(amount) : '••••',
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color.withValues(alpha: isDarkMode ? 0.9 : 0.8)),
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid(
    bool isDarkMode, {
    required double goldGramBalance,
    required double unpaidBillsTotal,
    required double totalInvestmentValuation,
    required double totalMonthlyInsurance,
    required List<SavingTargetModel> targets,
  }) {
    final Map<QuickActionType, String> balances = {
      QuickActionType.goldSavings:
          goldGramBalance > 0 ? '${goldGramBalance.toStringAsFixed(3)} Gr' : '',
      QuickActionType.bills:
          unpaidBillsTotal > 0 ? _formatRupiah(unpaidBillsTotal) : '',
      QuickActionType.investment: totalInvestmentValuation > 0
          ? _formatRupiah(totalInvestmentValuation)
          : '',
      QuickActionType.insurance: totalMonthlyInsurance > 0
          ? '${_formatRupiah(totalMonthlyInsurance)}/bln'
          : '',
      QuickActionType.savingPlans: _getPlansTotal(targets),
      QuickActionType.buyingTarget: '',
    };

    final primaryActions = _allActions.take(7).toList();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      crossAxisCount: 4,
      mainAxisSpacing: 8,
      crossAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: [
        for (var action in primaryActions)
          _buildToolAction(
            action.icon,
            action.label,
            action.type,
            isDarkMode,
            color: action.baseColor,
            subLabel: balances[action.type],
          ),

        _buildToolAction(
          Icons.apps_rounded,
          'Lainnya',
          null,
          isDarkMode,
          color: Colors.blueGrey,
          onTap: () => context.push('/all-services'),
        ),
      ],
    );
  }

  String _getPlansTotal(List<SavingTargetModel> targets) {
    final planCategories = ['Darurat', 'Pendidikan', 'Pensiun', 'Kurban'];
    final total = targets
        .where((t) => planCategories.contains(t.category))
        .fold<double>(0, (sum, t) => sum + t.targetAmount);
    return total > 0 ? _formatRupiah(total) : '';
  }

  String _getBuyingTotal(List<SavingTargetModel> targets) {
    final total = targets
        .where((t) => t.category == 'Pembelian' || t.category == 'Umum')
        .fold<double>(0, (sum, t) => sum + t.targetAmount);
    return total > 0 ? _formatRupiah(total) : '';
  }

  Widget _buildToolAction(
    IconData icon,
    String label,
    QuickActionType? type,
    bool isDarkMode, {
    required Color color,
    VoidCallback? onTap,
    String? subLabel,
  }) {
    return GestureDetector(
      onTap: onTap ?? () => widget.onActionTap(type!),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDarkMode ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: isDarkMode ? color.withValues(alpha: 0.9) : color,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.quicksand(
              fontSize: 10.2,
              fontWeight: FontWeight.bold,
              height: 1.0,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          if (subLabel != null && subLabel.isNotEmpty)
            Text(
              subLabel,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.quicksand(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white30 : Colors.black38,
              ),
            ),
        ],
      ),
    );
  }

  static const List<_QuickActionItem> _allActions = [
    _QuickActionItem(
      icon: Icons.add_circle_outline_rounded,
      label: 'Pemasukan',
      type: QuickActionType.income,
      baseColor: Colors.green,
    ),
    _QuickActionItem(
      icon: Icons.remove_circle_outline_rounded,
      label: 'Pengeluaran',
      type: QuickActionType.expense,
      baseColor: Colors.red,
    ),
    _QuickActionItem(
      icon: Icons.account_balance_wallet_rounded,
      label: 'Budget',
      type: QuickActionType.budget,
      baseColor: Colors.cyan,
    ),
    _QuickActionItem(
      icon: Icons.auto_stories_rounded,
      label: 'Pinjaman',
      type: QuickActionType.debt,
      baseColor: Colors.orange,
    ),
    _QuickActionItem(
      icon: Icons.groups_rounded,
      label: 'Nabung Bersama',
      type: QuickActionType.nabungBersama,
      baseColor: Colors.pink,
    ),
    _QuickActionItem(
      icon: Icons.shopping_cart_outlined,
      label: 'Belanja',
      type: QuickActionType.shoppingList,
      baseColor: Colors.purple,
    ),
    _QuickActionItem(
      icon: Icons.track_changes_rounded,
      label: 'Target Saya',
      type: QuickActionType.buyingTarget,
      baseColor: AppColors.primary,
    ),
    _QuickActionItem(
      icon: Icons.document_scanner_rounded,
      label: 'Scan Bukti',
      type: QuickActionType.scanReceipt,
      baseColor: Colors.teal,
    ),
    _QuickActionItem(
      icon: Icons.emoji_events_rounded,
      label: 'Challenge',
      type: QuickActionType.challenge,
      baseColor: Colors.amber,
    ),
    _QuickActionItem(
      icon: Icons.loop_rounded,
      label: 'Langganan',
      type: QuickActionType.recurring,
      baseColor: Colors.blue,
    ),
    _QuickActionItem(
      icon: Icons.volunteer_activism_rounded,
      label: 'Zakat/Infaq',
      type: QuickActionType.zakat,
      baseColor: Colors.teal,
    ),
    _QuickActionItem(
      icon: Icons.calculate_outlined,
      label: 'Simulasi',
      type: QuickActionType.simulator,
      baseColor: Colors.cyan,
    ),
    _QuickActionItem(
      icon: Icons.monetization_on_rounded,
      label: 'Nabung Emas',
      type: QuickActionType.goldSavings,
      baseColor: Colors.amber,
    ),
    _QuickActionItem(
      icon: Icons.assignment_turned_in_rounded,
      label: 'Dana Rencana',
      type: QuickActionType.savingPlans,
      baseColor: AppColors.primary,
    ),
    _QuickActionItem(
      icon: Icons.request_quote_rounded,
      label: 'Pajak',
      type: QuickActionType.tax,
      baseColor: Colors.orange,
    ),
    _QuickActionItem(
      icon: Icons.receipt_long_rounded,
      label: 'Tagihan',
      type: QuickActionType.bills,
      baseColor: Colors.lightBlue,
    ),
    _QuickActionItem(
      icon: Icons.trending_up_rounded,
      label: 'Investasi',
      type: QuickActionType.investment,
      baseColor: Colors.indigo,
    ),
    _QuickActionItem(
      icon: Icons.shield_rounded,
      label: 'Asuransi',
      type: QuickActionType.insurance,
      baseColor: Colors.blueGrey,
    ),
  ];

  Widget _buildSavingTargetSection(List<TransactionModel> transactions,
      List<SavingTargetModel> targets, bool isDarkMode) {

    final buyingTargets = targets
        .where((t) => t.category == 'Pembelian' || t.category == 'Umum')
        .toList();
    final bool isEmpty = buyingTargets.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Target Pembelian Saya',
                style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? Colors.white30
                        : AppColors.primaryDark.withValues(alpha: 0.4))),
            if (buyingTargets.length > 1)
              Text('${buyingTargets.length} Barang Impian',
                  style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 20),
        if (isEmpty)
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.02)
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: isDarkMode
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.05)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined,
                    size: 32,
                    color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
                const SizedBox(height: 12),
                Text('Belum ada target barang impian',
                    style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkMode ? Colors.white : AppColors.primaryDark)),
              ],
            ),
          )
        else
          SizedBox(
            height: 180,
            child: PageView.builder(
              itemCount: buyingTargets.length,
              onPageChanged: (idx) => setState(() => _currentTargetIndex = idx),
              itemBuilder: (context, index) {
                final target = buyingTargets[index];
                return _targetCardMinimalist(
                    target, transactions, isDarkMode, index);
              },
            ),
          ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(buyingTargets.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _currentTargetIndex == index ? 24 : 6,
              decoration: BoxDecoration(
                color: _currentTargetIndex == index
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _targetCardMinimalist(SavingTargetModel target,
      List<TransactionModel> transactions, bool isDarkMode, int index) {

    final targetBalance = transactions
        .where((t) => !t.date.isBefore(target.createdAt))
        .fold<double>(
            0, (s, t) => s + (t.type == TransactionType.income ? t.amount : 0));

    final progress = (target.targetAmount > 0)
        ? (targetBalance / target.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => widget.onTargetTap(target, targetBalance),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isDarkMode ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: isDarkMode
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned(
                top: -20,
                right: -10,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary
                        .withValues(alpha: isDarkMode ? 0.03 : 0.04),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withValues(alpha: isDarkMode ? 0.1 : 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'TARGET #${index + 1}',
                            style: GoogleFonts.quicksand(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            target.name.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.quicksand(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: isDarkMode ? Colors.white30 : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: GoogleFonts.quicksand(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),

                    Container(
                      height: 5,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _targetDetailItem(
                            'TERKUMPUL',
                            widget.showBalance
                                ? _formatRupiah(targetBalance)
                                : '••••••',
                            isDarkMode,
                            crossAxisAlignment: CrossAxisAlignment.start),
                        _targetDetailItem(
                            'SISA',
                            widget.showBalance
                                ? _formatRupiah(
                                    (target.targetAmount - targetBalance)
                                        .clamp(0, double.infinity))
                                : '••••••',
                            isDarkMode,
                            valueColor:
                                (target.targetAmount - targetBalance) <= 0
                                    ? Colors.green
                                    : null,
                            crossAxisAlignment: CrossAxisAlignment.center),
                        _targetDetailItem('GOAL',
                            _formatRupiah(target.targetAmount), isDarkMode,
                            crossAxisAlignment: CrossAxisAlignment.end),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _targetDetailItem(String label, String value, bool isDarkMode,
      {required CrossAxisAlignment crossAxisAlignment, Color? valueColor}) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 7.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            color: valueColor ?? (isDarkMode ? Colors.white60 : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildAllocationDropdown(bool isDarkMode) {
    final labels = {
      0: 'Pemasukan',
      1: 'Pengeluaran',
      2: 'Semua',
    };
    
    final activeColors = {
      0: isDarkMode ? const Color(0xFF2ECC71) : const Color(0xFF27AE60),
      1: isDarkMode ? const Color(0xFFE74C3C) : const Color(0xFFC0392B),
      2: isDarkMode ? const Color(0xFF3498DB) : const Color(0xFF2980B9),
    };
    
    final currentColor = activeColors[_selectedAllocationTab] ?? AppColors.primary;

    return PopupMenuButton<int>(
      initialValue: _selectedAllocationTab,
      onSelected: (int newValue) {
        setState(() {
          _selectedAllocationTab = newValue;
        });
      },
      offset: const Offset(0, 34),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      itemBuilder: (BuildContext context) {
        return labels.entries.map((entry) {
          final color = activeColors[entry.key] ?? currentColor;
          return PopupMenuItem<int>(
            value: entry.key,
            height: 38,
            child: Text(
              entry.value,
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w900,
                fontSize: 11,
                color: color,
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: currentColor.withOpacity(isDarkMode ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: currentColor.withOpacity(isDarkMode ? 0.3 : 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              labels[_selectedAllocationTab]!,
              style: GoogleFonts.quicksand(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: currentColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: currentColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationSection(double totalIncome, double totalExpense,
      List<TransactionModel> transactions, bool isDarkMode) {
    final bool isEmptyAll = totalIncome == 0 && totalExpense == 0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.04)
              : Colors.black.withOpacity(0.03),
        ),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ALOKASI DANA',
                  style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.8,
                      color: isDarkMode
                          ? Colors.white30
                          : AppColors.primaryDark.withValues(alpha: 0.4))),
              _buildAllocationDropdown(isDarkMode),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              if (_selectedAllocationTab == 0) ...[

                _buildIncomeChartAndData(transactions, isDarkMode),
              ] else if (_selectedAllocationTab == 1) ...[

                _buildExpenseChartAndData(transactions, isDarkMode),
              ] else ...[

                _buildAllAllocationChartAndData(totalIncome, totalExpense,
                    transactions, isDarkMode, isEmptyAll),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeChartAndData(
      List<TransactionModel> transactions, bool isDarkMode) {
    final incomes =
        transactions.where((t) => t.type == TransactionType.income).toList();
    final bool isEmpty = incomes.isEmpty;

    final categoryMap = <String, double>{};
    for (var t in incomes) {
      categoryMap[t.category] = (categoryMap[t.category] ?? 0) + t.amount;
    }
    final totalInc = categoryMap.values.fold(0.0, (sum, val) => sum + val);
    final sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 46,
                  sections: isEmpty
                      ? [
                          PieChartSectionData(
                            color: isDarkMode
                                ? Colors.white10
                                : Colors.grey.shade100,
                            value: 1,
                            radius: 14,
                            showTitle: false,
                          ),
                        ]
                      : sortedCategories.asMap().entries.map((e) {
                          final index = e.key;
                          final entry = e.value;
                          final percentage = totalInc > 0
                              ? (entry.value / totalInc * 100)
                              : 0.0;
                          final baseColor = const Color(0xFF2ECC71);
                          final color = baseColor.withOpacity((1.0 - (index * 0.15)).clamp(0.4, 1.0));
                          final showTitle = percentage >= 5;
                          return PieChartSectionData(
                            color: color,
                            value: entry.value,
                            radius: 14,
                            title: showTitle ? '${percentage.toStringAsFixed(0)}%' : '',
                            showTitle: false,
                            titlePositionPercentageOffset: 0.55,
                            titleStyle: GoogleFonts.quicksand(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    isEmpty || sortedCategories.isEmpty
                        ? '0%'
                        : '${(sortedCategories.first.value / totalInc * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.quicksand(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDarkMode ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildDynamicCategoryBreakdown(
            incomes, totalInc, isDarkMode, 'Belum ada pemasukan bulan ini', const Color(0xFF2ECC71)),
      ],
    );
  }

  Widget _buildExpenseChartAndData(
      List<TransactionModel> transactions, bool isDarkMode) {
    final expenses =
        transactions.where((t) => t.type == TransactionType.expense).toList();
    final bool isEmpty = expenses.isEmpty;

    final categoryMap = <String, double>{};
    for (var t in expenses) {
      categoryMap[t.category] = (categoryMap[t.category] ?? 0) + t.amount;
    }
    final totalExp = categoryMap.values.fold(0.0, (sum, val) => sum + val);
    final sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 46,
                  sections: isEmpty
                      ? [
                          PieChartSectionData(
                            color: isDarkMode
                                ? Colors.white10
                                : Colors.grey.shade100,
                            value: 1,
                            radius: 14,
                            showTitle: false,
                          ),
                        ]
                      : sortedCategories.asMap().entries.map((e) {
                          final index = e.key;
                          final entry = e.value;
                          final percentage = totalExp > 0
                              ? (entry.value / totalExp * 100)
                              : 0.0;
                          final baseColor = const Color(0xFFE74C3C);
                          final color = baseColor.withOpacity((1.0 - (index * 0.15)).clamp(0.4, 1.0));
                          final showTitle = percentage >= 5;
                          return PieChartSectionData(
                            color: color,
                            value: entry.value,
                            radius: 14,
                            title: showTitle ? '${percentage.toStringAsFixed(0)}%' : '',
                            showTitle: false,
                            titlePositionPercentageOffset: 0.55,
                            titleStyle: GoogleFonts.quicksand(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    isEmpty || sortedCategories.isEmpty
                        ? '0%'
                        : '${(sortedCategories.first.value / totalExp * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.quicksand(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDarkMode ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildDynamicCategoryBreakdown(
            expenses, totalExp, isDarkMode, 'Belum ada pengeluaran bulan ini', const Color(0xFFE74C3C)),
      ],
    );
  }

  Widget _buildAllAllocationChartAndData(
      double totalIncome,
      double totalExpense,
      List<TransactionModel> transactions,
      bool isDarkMode,
      bool isEmpty) {
    final actualTotal = totalIncome + totalExpense;
    final totalVal = isEmpty ? 1.0 : actualTotal;
    final incomePercent =
        isEmpty ? '0' : (totalIncome / totalVal * 100).toStringAsFixed(0);
    final expensePercent =
        isEmpty ? '0' : (totalExpense / totalVal * 100).toStringAsFixed(0);

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 46,
                  sections: isEmpty
                      ? [
                          PieChartSectionData(
                            color: isDarkMode
                                ? Colors.white10
                                : Colors.grey.shade100,
                            value: 1,
                            radius: 14,
                            showTitle: false,
                          ),
                        ]
                      : [
                          if (totalIncome > 0)
                            PieChartSectionData(
                              color: const Color(0xFF2ECC71),
                              value: totalIncome,
                              radius: 14,
                              title: incomePercent != '0' ? '$incomePercent%' : '',
                              showTitle: incomePercent != '0',
                              titlePositionPercentageOffset: 2.2,
                              titleStyle: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: isDarkMode ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          if (totalExpense > 0)
                            PieChartSectionData(
                              color: const Color(0xFFE74C3C),
                              value: totalExpense,
                              radius: 14,
                              title: expensePercent != '0' ? '$expensePercent%' : '',
                              showTitle: expensePercent != '0',
                              titlePositionPercentageOffset: 2.2,
                              titleStyle: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: isDarkMode ? Colors.white70 : Colors.black87,
                              ),
                            ),
                        ],
                ),
              ),
              if (isEmpty)
                Container(
                  width: 76,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.analytics_outlined,
                            size: 18,
                            color:
                                isDarkMode ? Colors.white10 : Colors.grey.shade300),
                        const SizedBox(height: 3),
                        Text('Belum Ada Data',
                            style: GoogleFonts.quicksand(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? Colors.white30
                                    : Colors.grey.shade400)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(3.5),
              1: FlexColumnWidth(0.5),
              2: FlexColumnWidth(3.0),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              _buildTableRow(
                  'Pemasukan ($incomePercent%)', totalIncome, const Color(0xFF2ECC71), isDarkMode),
              _buildTableRow(
                  'Pengeluaran ($expensePercent%)', totalExpense, const Color(0xFFE74C3C), isDarkMode),
              _buildTableRow('Total Alokasi', actualTotal,
                  isDarkMode ? Colors.white : Colors.black87, isDarkMode,
                  isTotal: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicCategoryBreakdown(List<TransactionModel> filteredTxs,
      double totalAmount, bool isDarkMode, String emptyPlaceholder, Color baseColor) {
    if (filteredTxs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.white10
                                : Colors.grey.shade200,
                            shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          emptyPlaceholder,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.quicksand(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: isDarkMode ? Colors.white24 : Colors.black26,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '0.0%',
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: isDarkMode ? Colors.white10 : Colors.black12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0,
                backgroundColor: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade100,
                color: Colors.grey.shade300,
                minHeight: 4,
              ),
            ),
          ],
        ),
      );
    }

    final categoryMap = <String, double>{};
    for (var t in filteredTxs) {
      categoryMap[t.category] = (categoryMap[t.category] ?? 0) + t.amount;
    }
    final sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedCategories.asMap().entries.take(4).map((e) {
        final index = e.key;
        final entry = e.value;
        final percentage = totalAmount > 0 ? entry.value / totalAmount : 0.0;
        final color = baseColor.withOpacity((1.0 - (index * 0.15)).clamp(0.4, 1.0));
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration:
                              BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.key,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(percentage * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: isDarkMode
                      ? Colors.white.withOpacity(0.04)
                      : Colors.grey.shade100,
                  color: color,
                  minHeight: 5,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  TableRow _buildTableRow(
      String label, double val, Color color, bool isDarkMode,
      {bool isTotal = false}) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: isTotal ? FontWeight.w800 : FontWeight.bold,
                    color: isDarkMode
                        ? (isTotal ? Colors.white : Colors.white70)
                        : (isTotal ? AppColors.primaryDark : Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              _formatRupiah(val),
              textAlign: TextAlign.right,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

Widget _buildRecentActivitySection(
      List<TransactionModel> transactions, bool isDarkMode) {
    final displayTxs = transactions.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('AKTIVITAS TERAKHIR',
                style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: isDarkMode
                        ? Colors.white30
                        : Colors.teal.shade800.withValues(alpha: 0.4))),
            Icon(Icons.history_rounded,
                size: 16,
                color: isDarkMode ? Colors.white24 : Colors.grey.shade300),
          ],
        ),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.04)
                    : Colors.black.withOpacity(0.03),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (isDarkMode
                            ? const Color(0xFF2ECC71)
                            : const Color(0xFF27AE60))
                        .withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (isDarkMode
                              ? const Color(0xFF2ECC71)
                              : const Color(0xFF27AE60))
                          .withOpacity(0.12),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: 18,
                    color: isDarkMode
                        ? const Color(0xFF2ECC71)
                        : const Color(0xFF27AE60),
                  ),
                ),
                const SizedBox(height: 10),
                Text('Belum Ada Transaksi',
                    style: GoogleFonts.quicksand(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white70 : Colors.black87)),
                const SizedBox(height: 2),
                Text('Catatan transaksi keuanganmu akan muncul di sini',
                    style: GoogleFonts.quicksand(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white30 : Colors.black38)),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.04)
                    : Colors.black.withOpacity(0.03),
              ),
            ),
            child: Column(
              children: [
                for (int i = 0; i < displayTxs.length; i++) ...[
                  _minimalTile(displayTxs[i], isDarkMode),
                  if (i < displayTxs.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.03)
                          : Colors.black.withOpacity(0.02),
                      indent: 64,
                    ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _minimalTile(TransactionModel t, bool isDarkMode) {
    final bool isExpense = t.type == TransactionType.expense;
    final IconData icon =
        isExpense ? Icons.arrow_outward_rounded : Icons.call_received_rounded;
    final Color color = isExpense ? Colors.red.shade400 : Colors.green.shade400;

    return InkWell(
      onTap: () => widget.onTransactionTap(t),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.12),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(DateFormat('dd MMM yyyy').format(t.date),
                      style: GoogleFonts.quicksand(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white30 : Colors.black38)),
                ],
              ),
            ),
            Text(
              '${isExpense ? '- ' : '+ '}${_formatRupiah(t.amount)}',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: isExpense
                    ? (isDarkMode ? Colors.red.shade300 : Colors.red.shade700)
                    : (isDarkMode
                        ? Colors.green.shade300
                        : Colors.green.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatermark(bool isDarkMode) {
    return Center(
      child: Opacity(
        opacity: 0.4,
        child: Column(
          children: [
            Text('NEVERLAND STUDIO',
                style: GoogleFonts.quicksand(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3)),
            const SizedBox(height: 6),
            Text(
              AppVersion.fullVersion,
              style: GoogleFonts.quicksand(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionItem {
  final IconData icon;
  final String label;
  final QuickActionType type;
  final Color baseColor;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.type,
    required this.baseColor,
  });
}
