import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/models/saving_target_model.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/providers/saving_target_provider.dart';
import 'package:tabunganku/core/constants/app_constants.dart';
import 'package:tabunganku/core/constants/quick_action_type.dart';
import '../../../../core/constants/app_version.dart';

class HomeTabView extends ConsumerWidget {
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

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Fetch personal transactions
    final personalTransactions = ref.watch(transactionsByGroupProvider(null));
    final transactions = List<TransactionModel>.from(personalTransactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final totalBalance = totalIncome - totalExpense;

    final targetsAsync = ref.watch(savingTargetsStreamProvider);
    final targets = targetsAsync.valueOrNull ?? [];

    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Main Finance Card (Consolidated)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(32),
              // Simplified shadow for low-spec
              boxShadow: isDarkMode ? [] : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decoration Circles (Simplified for performance)
                Positioned(
                  top: -40,
                  right: -30,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber.withValues(alpha: isDarkMode ? 0.05 : 0.08),
                    ),
                  ),
                ),
                // Content Utama
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'TOTAL SALDO TERKUMPUL',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.comicNeue(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.5,
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
                                showBalance ? _formatRupiah(totalBalance) : '••••••',
                                style: GoogleFonts.comicNeue(
                                  color: isDarkMode ? Colors.white : Colors.teal.shade900,
                                  fontSize: 42,
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
                              showBalance ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: isDarkMode ? Colors.white24 : Colors.teal.shade700.withValues(alpha: 0.3),
                              size: 22,
                            ),
                            onPressed: onToggleBalance,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Estimasi Akhir Bulan
                      _buildEstimationCard(totalIncome, totalExpense, isDarkMode),
                      const SizedBox(height: 24),

                      // Stats Row Divider
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.teal.shade50.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 24),

                      // Stats Row within Card
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: _miniStat('Pemasukan', totalIncome, Colors.green.shade600, isDarkMode, center: true)),
                          const SizedBox(width: 24),
                          Container(
                              width: 1.2,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1),
                                color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.teal.shade50,
                              )),
                          const SizedBox(width: 24),
                          Expanded(
                              child: _miniStat('Pengeluaran', totalExpense, Colors.red.shade600, isDarkMode, center: true)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Primary Navigation grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            childAspectRatio: 0.85,
            children: [
              _buildToolAction(Icons.add_circle_outline_rounded, 'Pemasukan', QuickActionType.income, isDarkMode),
              _buildToolAction(Icons.remove_circle_outline_rounded, 'Pengeluaran', QuickActionType.expense, isDarkMode),
              _buildToolAction(Icons.account_balance_wallet_rounded, 'Budget', QuickActionType.budget, isDarkMode),
              _buildToolAction(Icons.auto_stories_rounded, 'Hutang/Piutang', QuickActionType.debt, isDarkMode),
              _buildToolAction(Icons.family_restroom_rounded, 'Keluarga', QuickActionType.family, isDarkMode),
              _buildToolAction(Icons.shopping_cart_outlined, 'Belanja', QuickActionType.shoppingList, isDarkMode),
              _buildToolAction(Icons.document_scanner_rounded, 'Scan Bukti', QuickActionType.scanReceipt, isDarkMode),
              _buildToolAction(Icons.emoji_events_rounded, 'Challenge', QuickActionType.challenge, isDarkMode),
              _buildToolAction(Icons.track_changes_rounded, 'Target', QuickActionType.savingTarget, isDarkMode),
              _buildToolAction(Icons.loop_rounded, 'Langganan', QuickActionType.recurring, isDarkMode),
              _buildToolAction(Icons.volunteer_activism_rounded, 'Zakat/Infaq', QuickActionType.zakat, isDarkMode),
              _buildToolAction(Icons.calculate_outlined, 'Simulasi', QuickActionType.simulator, isDarkMode),
            ],
          ),

          const SizedBox(height: 40),
          _buildSavingTargetSection(totalBalance, targets, isDarkMode),

          const SizedBox(height: 40),
          _buildAllocationSection(totalIncome, totalExpense, transactions, isDarkMode),

          const SizedBox(height: 40),
          _buildRecentActivitySection(transactions, isDarkMode),

          const SizedBox(height: 60),
          _buildWatermark(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildEstimationCard(double totalIncome, double totalExpense, bool isDarkMode) {
    final now = DateTime.now();
    final totalDays = DateTime(now.year, now.month + 1, 0).day;
    final day = now.day;
    final currentDay = day > 0 ? day : 1;
    final estIncome = (totalIncome / currentDay) * totalDays;
    final estExpense = (totalExpense / currentDay) * totalDays;
    final estBalance = estIncome - estExpense;
    final isDanger = estBalance < 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDanger ? Colors.red.withValues(alpha: 0.1) : (isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.teal.shade50.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isDanger ? Icons.warning_amber_rounded : Icons.auto_graph_rounded, size: 14, color: isDanger ? Colors.red : Colors.teal),
          const SizedBox(width: 8),
          Text(
            'Estimasi Akhir Bulan: ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white38 : Colors.teal.shade900.withValues(alpha: 0.5),
            ),
          ),
          Text(
            showBalance ? _formatRupiah(estBalance) : '••••••',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDanger ? Colors.red : (isDarkMode ? Colors.white70 : Colors.teal.shade900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, double amount, Color color, bool isDarkMode, {bool center = false}) {
    return Column(
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white54 : Colors.grey.shade500, letterSpacing: 1.2)),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            showBalance ? _formatRupiah(amount) : '••••',
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color.withValues(alpha: isDarkMode ? 0.9 : 0.8)),
          ),
        ),
      ],
    );
  }

  Widget _buildToolAction(IconData icon, String label, QuickActionType type, bool isDarkMode) {
    Color iconColor = AppColors.primary;
    switch (type) {
      case QuickActionType.income: iconColor = Colors.green.shade400; break;
      case QuickActionType.expense: iconColor = Colors.red.shade400; break;
      case QuickActionType.savingTarget: iconColor = Colors.amber.shade500; break;
      case QuickActionType.budget: iconColor = Colors.cyan.shade400; break;
      case QuickActionType.debt: iconColor = Colors.orange.shade500; break;
      case QuickActionType.family: iconColor = Colors.blue.shade500; break;
      case QuickActionType.shoppingList: iconColor = Colors.purple.shade300; break;
      case QuickActionType.scanReceipt: iconColor = Colors.tealAccent.shade700; break;
      case QuickActionType.zakat: iconColor = Colors.teal.shade400; break;
      case QuickActionType.simulator: iconColor = Colors.cyan.shade600; break;
      default: break;
    }

    return GestureDetector(
      onTap: () => onActionTap(type),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Material(
              color: isDarkMode ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              elevation: isDarkMode ? 0 : 1, // Use standard elevation instead of custom shadows
              child: InkWell(
                onTap: () => onActionTap(type),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white38 : Colors.teal.shade900.withValues(alpha: 0.5),
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingTargetSection(double totalBalance, List<SavingTargetModel> targets, bool isDarkMode) {
    if (targets.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('TARGET TABUNGAN',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: isDarkMode ? Colors.white30 : Colors.teal.shade800.withValues(alpha: 0.4))),
            if (targets.length > 1)
              Text('${targets.length} Target',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber.shade700)),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: targets.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final target = targets[index];
              return _targetCard(target, totalBalance, isDarkMode);
            },
          ),
        ),
      ],
    );
  }

  Widget _targetCard(SavingTargetModel target, double totalBalance, bool isDarkMode) {
    final progress = (target.targetAmount > 0) ? (totalBalance / target.targetAmount).clamp(0.0, 1.0) : 0.0;
    
    return GestureDetector(
      onTap: () => onTargetTap(target, totalBalance),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.primary.withValues(alpha: isDarkMode ? 0.05 : 0.1)),
          // Removed expensive shadows for horizontal list
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(target.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progress', style: TextStyle(fontSize: 11, color: isDarkMode ? Colors.white30 : Colors.black26, fontWeight: FontWeight.bold)),
                Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                color: AppColors.primary,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Text(showBalance ? '${_formatRupiah(totalBalance)} / ${_formatRupiah(target.targetAmount)}' : '••••••',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white70 : Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationSection(double totalIncome, double totalExpense, List<TransactionModel> transactions, bool isDarkMode) {
    if (totalIncome == 0 && totalExpense == 0) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ALOKASI KEUANGAN',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: isDarkMode ? Colors.white30 : Colors.teal.shade800.withValues(alpha: 0.4))),
          const SizedBox(height: 24),
          // Centered Pie Chart simplified for performance
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: [
                  if (totalIncome > 0)
                    PieChartSectionData(color: Colors.green.shade400, value: totalIncome, radius: 12, showTitle: false),
                  if (totalExpense > 0)
                    PieChartSectionData(color: Colors.red.shade400, value: totalExpense, radius: 12, showTitle: false),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildCategoryBreakdown(transactions, totalExpense, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(List<TransactionModel> transactions, double totalExpense, bool isDarkMode) {
    final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
    if (expenses.isEmpty) return const SizedBox.shrink();

    final categoryMap = <String, double>{};
    for (var t in expenses) {
      categoryMap[t.category] = (categoryMap[t.category] ?? 0) + t.amount;
    }

    final sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedCategories.take(4).map((entry) {
        final percentage = entry.value / totalExpense;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(entry.key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('${(percentage * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentActivitySection(List<TransactionModel> transactions, bool isDarkMode) {
    if (transactions.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Aktivitas Terakhir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.5)),
        const SizedBox(height: 16),
        ...transactions.take(3).map((t) => _minimalTile(t, isDarkMode)),
      ],
    );
  }

  Widget _minimalTile(TransactionModel t, bool isDarkMode) {
    final bool isExpense = t.type == TransactionType.expense;
    final IconData catIcon = AppConstants.categoryIcons[t.category] ?? (isExpense ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded);
    final Color catColor = isExpense ? Colors.red : Colors.green;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => onTransactionTap(t),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: catColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(catIcon, color: catColor, size: 18),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(DateFormat('dd MMM').format(t.date), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
                Text('${isExpense ? '- ' : '+ '}${_formatRupiah(t.amount)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWatermark(bool isDarkMode) {
    return Center(
      child: Opacity(
        opacity: 0.2,
        child: Column(
          children: [
            const Text('NEVERLAND STUDIO', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 4),
            Text(AppVersion.edition, style: const TextStyle(fontSize: 8)),
          ],
        ),
      ),
    );
  }
}
