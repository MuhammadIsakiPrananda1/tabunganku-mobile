import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tabunganku/main.dart' show flutterLocalNotificationsPlugin;
import 'package:tabunganku/services/recurring_service.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/providers/family_group_provider.dart';
import 'package:tabunganku/features/transaction/presentation/widgets/transaction_detail_sheet.dart';
import 'package:tabunganku/features/friends/presentation/pages/family_group_page.dart';
import 'package:tabunganku/providers/saving_target_provider.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tabunganku/features/transaction/presentation/pages/debt_list_page.dart';
import 'package:tabunganku/features/shopping/presentation/pages/shopping_list_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/models/saving_target_model.dart';
import 'package:tabunganku/features/settings/presentation/pages/settings_page.dart';
import 'package:tabunganku/features/transaction/presentation/pages/recurring_list_page.dart';
import 'package:tabunganku/core/utils/currency_formatter.dart';
import 'package:tabunganku/core/services/export_service.dart';
import 'package:tabunganku/features/home/presentation/widgets/smart_clock_widgets.dart';
import 'package:tabunganku/core/constants/quick_action_type.dart';
import 'package:tabunganku/features/home/presentation/widgets/home_tab_view.dart'
    as widgets;

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _showBalance = true;
  final PageController _targetPageController = PageController();
  int _currentTargetIndex = 0;
  // Timer removed for optimization - isolated in specialized widgets

  // --- Fitur Simulasi Tabungan ---
  void _showSavingSimulatorSheet() {
    context.push('/saving-simulator');
  }

  Future<void> _deleteSavingTarget(String? targetId) async {
    if (targetId == null) return;
    await ref.read(savingTargetServiceProvider).deleteTarget(targetId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Target tabungan dihapus.')));
    }
  }

  // Pindahkan ke atas agar bisa direferensikan sebelum _buildProfileTab

  // Pindahkan ke atas agar bisa direferensikan
  // Primary Colors (Stellar Sky Edition)
  // Gunakan instance global dari main.dart

  int _currentIndex = 0;
  String? _loadedUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadLocalData();
      // Proses transaksi rutin otomatis
      await ref.read(recurringServiceProvider).processRecurring();
    });
  }

  @override
  void dispose() {
    _targetPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const activeUserId = 'default_user';
    if (_loadedUserId != activeUserId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadLocalData();
      });
    }

    // 1. Fetch personal transactions (groupId == null)
    final personalTransactions = ref.watch(transactionsByGroupProvider(null));

    // Note: Group transactions are handled via global familyBalanceSyncProvider

    // 3. Main dashboard only shows personal transactions (Isolasi)
    final transactionsAsync = AsyncValue.data(personalTransactions);
    final transactions = List<TransactionModel>.from(personalTransactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 80,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(_navItems[_currentIndex].label,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24)),
                  ),
                  if (_currentIndex != 3) ...[
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: SmartDateDisplay(isDarkMode: isDarkMode),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (_currentIndex != 3)
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: SmartDigitalClock(),
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.notifications_active_outlined,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        const Text('Belum ada notifikasi baru untuk Anda'),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          widgets.HomeTabView(
            showBalance: _showBalance,
            onToggleBalance: () => setState(() => _showBalance = !_showBalance),
            onTransactionTap: _showTransactionDetailSheet,
            onTargetTap: _showTargetDetailSheet,
            onActionTap: (type) => _handleQuickActionTap(
                _QuickAction(icon: Icons.add, label: '', type: type)),
          ),
          _buildFinanceTab(transactionsAsync, transactions),
          _buildHistoryTab(transactionsAsync, transactions),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: SizedBox(
          height: 100, // Slightly taller for more airy feel
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                left: 16,
                right: 16,
                bottom: 12,
                child: Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDarkMode ? 0.2 : 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildNavItem(0),
                      _buildNavItem(1),
                      const SizedBox(width: 72), // Space for center button
                      _buildNavItem(2),
                      _buildNavItem(3),
                    ],
                  ),
                ),
              ),
              // Floating Center Camera Button
              Positioned(
                top: 0,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showCalculatorSheet(),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primaryLight, AppColors.primary],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(
                                  0x4D00BFA5), // AppColors.primary with alpha 0.3
                              blurRadius: 15,
                              offset: Offset(0, 6),
                            ),
                          ],
                          border: Border.all(
                              color: Theme.of(context).cardColor, width: 4),
                        ),
                        child: const Icon(Icons.calculate_rounded,
                            color: Colors.white, size: 36),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Kalkulator',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
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

  // Notifikasi sudah diinisialisasi di main.dart

  Future<void> _loadLocalData() async {
    const userId = 'default_user';
    final prefs = await SharedPreferences.getInstance();

    // Migration logic for old single-target data
    const migrationKey =
        'migration_saving_target_v3_done_$userId'; // Use v3 to be sure
    if (prefs.getBool(migrationKey) != true) {
      final oldAmount = prefs.getString('saving_target_amount_$userId');
      final oldItem = prefs.getString('saving_target_item_$userId');
      final oldDueRaw = prefs.getString('saving_target_due_$userId');

      if (oldAmount != null && oldItem != null && oldDueRaw != null) {
        final oldDue = DateTime.tryParse(oldDueRaw);
        if (oldDue != null) {
          // Add as a new target in the new service
          final target = SavingTargetModel(
            id: 'legacy_${DateTime.now().millisecondsSinceEpoch}',
            name: oldItem,
            targetAmount: _toAmount(oldAmount) ?? 0,
            dueDate: oldDue,
            createdAt: DateTime.now(),
          );
          await ref.read(savingTargetServiceProvider).addTarget(target);

          // Mark migration as done immediately
          await prefs.setBool(migrationKey, true);

          // Remove old keys
          await prefs.remove('saving_target_amount_$userId');
          await prefs.remove('saving_target_item_$userId');
          await prefs.remove('saving_target_due_$userId');
        } else {
          await prefs.setBool(
              migrationKey, true); // Even if invalid, don't retry forever
        }
      } else {
        await prefs.setBool(migrationKey, true); // Nothing to migrate
      }
    }

    if (!mounted) return;
    setState(() {
      _loadedUserId = userId;
    });

    final targets = await ref.read(savingTargetServiceProvider).getTargets();
    for (final t in targets) {
      await _maybeShowTargetReminder(userId, t);
    }
  }

  Future<void> _maybeShowTargetReminder(
      String userId, SavingTargetModel target) async {
    final remaining = target.dueDate.difference(DateTime.now()).inDays;
    if (remaining < 0 || remaining > 3) return;

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    final notifiedKey = 'saving_target_notified_${target.id}_day_$userId';
    if (prefs.getString(notifiedKey) == todayKey) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'saving_target_channel',
        'Saving Target Reminder',
        channelDescription: 'Pengingat target tabungan',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      target.id.hashCode,
      'Target Tabungan Hampir Jatuh Tempo',
      'Sisa $remaining hari untuk target ${target.name} (${_formatRupiah(target.targetAmount)})',
      details,
    );
    await prefs.setString(notifiedKey, todayKey);
  }

  Widget _buildSavingTargetSection(
      double totalBalance, List<SavingTargetModel> targets) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    if (targets.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.02),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.track_changes_rounded,
                color: isDarkMode ? Colors.white10 : Colors.teal.shade100,
                size: 48),
            const SizedBox(height: 16),
            Text('Belum Ada Target',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black87)),
            const SizedBox(height: 8),
            Text('Mulai menabung untuk impian Anda',
                style: TextStyle(
                    color: isDarkMode ? Colors.white24 : Colors.black38,
                    fontSize: 13)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showSavingTargetDialog(totalBalance),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Buat Target Pertama'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 265, // Slightly taller for some padding
          child: PageView.builder(
            controller: _targetPageController,
            onPageChanged: (index) {
              setState(() {
                _currentTargetIndex = index;
              });
            },
            itemCount: targets.length,
            itemBuilder: (context, index) {
              final target = targets[index];
              final progress = (target.targetAmount > 0)
                  ? (totalBalance / target.targetAmount).clamp(0.0, 1.0)
                  : 0.0;
              final remaining =
                  target.dueDate.difference(DateTime.now()).inDays;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDarkMode ? 0.2 : 0.01),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Material(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(32),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _showTargetDetailSheet(target, totalBalance),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white
                                .withValues(alpha: isDarkMode ? 0.05 : 0.01),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('TARGET TABUNGAN #${index + 1}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                      color: isDarkMode
                                          ? Colors.white54
                                          : Colors.teal.shade800
                                              .withValues(alpha: 0.4),
                                    )),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(target.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.teal.shade900,
                                          letterSpacing: -0.5)),
                                ),
                                if (progress >= 1.0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade500,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text('TERCAPAI! 🎊',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  Container(
                                      height: 12,
                                      color: isDarkMode
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.teal.shade50),
                                  AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 1200),
                                    curve: Curves.easeOutBack,
                                    height: 12,
                                    width: (MediaQuery.of(context).size.width -
                                            88) *
                                        progress,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: progress >= 1.0
                                            ? [
                                                Colors.tealAccent.shade400,
                                                AppColors.primary
                                              ]
                                            : [
                                                AppColors.primaryLight,
                                                AppColors.primary
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (progress >= 1.0
                                                  ? Colors.greenAccent
                                                  : AppColors.primary)
                                              .withValues(
                                                  alpha:
                                                      isDarkMode ? 0.2 : 0.4),
                                          blurRadius: progress >= 1.0 ? 15 : 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildTargetStat(
                                    'Terkumpul',
                                    _formatRupiah(totalBalance),
                                    Icons.wallet_rounded,
                                    Colors.green),
                                _buildTargetStat(
                                    'Target',
                                    _formatRupiah(target.targetAmount),
                                    Icons.track_changes_rounded,
                                    Colors.teal),
                                _buildTargetStat(
                                    'Sisa Waktu',
                                    remaining < 0 ? 'Tempo' : '$remaining Hari',
                                    Icons.access_time_rounded,
                                    Colors.orange),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Custom Page Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(targets.length, (index) {
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

  Widget _buildTargetStat(
      String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon,
                size: 12,
                color: color.withValues(alpha: isDarkMode ? 0.4 : 0.6)),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white54 : Colors.black38)),
          ],
        ),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.teal.shade900)),
      ],
    );
  }

  Future<void> _handleQuickActionTap(_QuickAction action) async {
    switch (action.type) {
      case QuickActionType.expense:
        await _showManualTransactionSheet(TransactionType.expense);
        break;
      case QuickActionType.income:
        await _showManualTransactionSheet(TransactionType.income);
        break;
      case QuickActionType.savingTarget:
        final txs = ref.read(transactionsByGroupProvider(null));
        final bal = txs.fold<double>(
            0,
            (sum, t) =>
                sum +
                (t.type == TransactionType.income ? t.amount : -t.amount));
        await _showSavingTargetDialog(bal);
        break;
      case QuickActionType.budget:
        context.push('/monthly-budget');
        break;
      case QuickActionType.calculator:
        _showCalculatorSheet();
        break;
      case QuickActionType.history:
        setState(() => _currentIndex = 2);
        break;
      case QuickActionType.simulator:
        _showSavingSimulatorSheet();
        break;
      case QuickActionType.family:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FamilyGroupPage(),
          ),
        );
        break;
      case QuickActionType.debt:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DebtListPage(),
          ),
        );
        break;
      case QuickActionType.shoppingList:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ShoppingListPage(),
          ),
        );
        break;
      case QuickActionType.scanReceipt:
        context.push('/scan-receipt');
        break;
      case QuickActionType.challenge:
        context.push('/challenge');
        break;
      case QuickActionType.recurring:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RecurringListPage(),
          ),
        );
        break;
      case QuickActionType.zakat:
        context.push('/zakat');
        break;
    }
  }

  void _showTargetDetailSheet(SavingTargetModel target, double totalBalance) {
    final progress = (target.targetAmount > 0)
        ? (totalBalance / target.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final remainingDays = target.dueDate.difference(DateTime.now()).inDays;
    final remainingAmount = target.targetAmount - totalBalance;
    final isCompleted = progress >= 1.0;

    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 36),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Header with Icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary
                          .withValues(alpha: isDarkMode ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.track_changes_rounded,
                        color: AppColors.primary, size: 32),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          target.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.teal.shade900),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? (isDarkMode
                                    ? Colors.green.shade800
                                    : Colors.green.shade500)
                                : (isDarkMode
                                    ? Colors.orange.shade800
                                    : Colors.orange.shade500),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isCompleted
                                ? 'TARGET TERCAPAI 🎊'
                                : 'SEDANG BERJALAN 🚀',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Progress Section
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 12,
                        backgroundColor: isDarkMode
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.teal.shade50,
                        valueColor: AlwaysStoppedAnimation<Color>(isCompleted
                            ? Colors.green.shade400
                            : AppColors.primary),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.teal.shade900),
                        ),
                        Text(
                          'Progress',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white54
                                  : Colors.teal.shade800
                                      .withValues(alpha: 0.4)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Detailed Stats Grid
              _buildDetailRow(
                  'Target Nominal',
                  _formatRupiah(target.targetAmount),
                  Icons.flag_rounded,
                  Colors.teal),
              Divider(
                  height: 32,
                  color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
              _buildDetailRow('Telah Terkumpul', _formatRupiah(totalBalance),
                  Icons.account_balance_wallet_rounded, Colors.green),
              Divider(
                  height: 32,
                  color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
              _buildDetailRow(
                  'Sisa Kekurangan',
                  remainingAmount <= 0
                      ? 'Lunas'
                      : _formatRupiah(remainingAmount),
                  Icons.hourglass_bottom_rounded,
                  Colors.red),
              Divider(
                  height: 32,
                  color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
              _buildDetailRow(
                  'Jatuh Tempo',
                  '${DateFormat('d MMM yyyy').format(target.dueDate)} ($remainingDays Hari lagi)',
                  Icons.calendar_today_rounded,
                  Colors.orange),

              const SizedBox(height: 40),

              // Subtitle info
              Center(
                child: Text(
                  'Dibuat pada ${DateFormat('d MMM yyyy').format(target.createdAt)}',
                  style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white12 : Colors.black26,
                      fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showAddEditTargetDialog(target: target);
                      },
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text('Ubah Target',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode
                            ? Colors.teal.shade900.withValues(alpha: 0.2)
                            : Colors.teal.shade50,
                        foregroundColor: isDarkMode
                            ? Colors.teal.shade300
                            : AppColors.primary,
                        elevation: 0,
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _deleteSavingTarget(target.id);
                      },
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Hapus',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode
                            ? Colors.red.shade900.withValues(alpha: 0.2)
                            : Colors.red.shade50,
                        foregroundColor:
                            isDarkMode ? Colors.red.shade300 : Colors.red,
                        elevation: 0,
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    return Row(
      children: [
        Icon(icon,
            color: isDarkMode ? color.withValues(alpha: 0.8) : color, size: 20),
        const SizedBox(width: 16),
        Expanded(
            child: Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white38 : Colors.black54))),
        const SizedBox(width: 8),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.teal.shade900)),
      ],
    );
  }

  void _showCalculatorSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CalculatorSheetContent(),
    );
  }

  Widget _buildSmartAllocationPlanner(double amount, bool isDarkMode) {
    if (amount <= 0) return const SizedBox.shrink();

    final needs = amount * 0.5;
    final wants = amount * 0.3;
    final savings = amount * 0.2;
    final zakat = amount * 0.025;

    Widget allocationChip(
        String label, double val, Color color, IconData icon) {
      return Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDarkMode ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white38 : Colors.black38)),
                Text(_formatRupiah(val),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white70 : Colors.black87)),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Icon(Icons.auto_awesome_rounded,
                size: 14, color: Colors.amber.shade600),
            const SizedBox(width: 8),
            Text('ALOKASI CERDAS (50/30/20)',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? Colors.white24
                        : Colors.teal.shade800.withValues(alpha: 0.4),
                    letterSpacing: 1.2)),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              allocationChip(
                  'Kebutuhan (50%)', needs, Colors.blue, Icons.home_rounded),
              allocationChip('Keinginan (30%)', wants, Colors.orange,
                  Icons.shopping_bag_rounded),
              allocationChip('Tabungan (20%)', savings, Colors.green,
                  Icons.savings_rounded),
              allocationChip('Zakat (2.5%)', zakat, Colors.purple,
                  Icons.volunteer_activism_rounded),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showManualTransactionSheet(TransactionType type) async {
    final amountController = TextEditingController();
    final nameController = TextEditingController();
    final customCategoryController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var selectedCategory =
        type == TransactionType.expense ? 'Makanan & Minuman' : 'Gaji';
    var noteText = '';
    String? selectedTopUpSource;
    String topUpBankName = '';

    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    final List<Map<String, dynamic>> categories = type == TransactionType.income
        ? [
            {'label': 'Gaji', 'icon': Icons.payments_rounded},
            {'label': 'Hasil Jualan', 'icon': Icons.storefront_rounded},
            {'label': 'Bonus & Insentif', 'icon': Icons.stars_rounded},
            {'label': 'Hadiah / THR', 'icon': Icons.card_giftcard_rounded},
            {'label': 'Dividen / Investasi', 'icon': Icons.trending_up_rounded},
            {'label': 'Tabungan', 'icon': Icons.savings_rounded},
            {'label': 'Lainnya', 'icon': Icons.more_horiz_rounded},
          ]
        : [
            {'label': 'Makanan & Minuman', 'icon': Icons.fastfood_rounded},
            {'label': 'Transportasi', 'icon': Icons.directions_car_rounded},
            {'label': 'Kebutuhan Rumah', 'icon': Icons.home_work_rounded},
            {'label': 'Belanja Bulanan', 'icon': Icons.shopping_cart_rounded},
            {'label': 'Tagihan & Listrik', 'icon': Icons.bolt_rounded},
            {'label': 'Hiburan & Hobi', 'icon': Icons.smart_display_rounded},
            {'label': 'Kesehatan', 'icon': Icons.medical_services_rounded},
            {'label': 'Pendidikan', 'icon': Icons.school_rounded},
            {
              'label': 'Zakat & Sedekah',
              'icon': Icons.volunteer_activism_rounded
            },
            {'label': 'Cicilan & Hutang', 'icon': Icons.credit_card_rounded},
            {'label': 'Pulsa & Internet', 'icon': Icons.wifi_rounded},
            {
              'label': 'Perbaikan Rumah',
              'icon': Icons.home_repair_service_rounded
            },
            {'label': 'Gaya Hidup', 'icon': Icons.style_rounded},
            {'label': 'Biaya Admin', 'icon': Icons.account_balance_rounded},
            {'label': 'Lain-lain', 'icon': Icons.more_horiz_rounded},
          ];

    final topUpSources = [
      {'label': 'Bank', 'icon': Icons.account_balance_rounded},
      {'label': 'GoPay', 'icon': Icons.account_balance_wallet_rounded},
      {'label': 'OVO', 'icon': Icons.account_balance_wallet_rounded},
      {'label': 'Dana', 'icon': Icons.account_balance_wallet_rounded},
      {'label': 'ShopeePay', 'icon': Icons.account_balance_wallet_rounded},
      {'label': 'LinkAja', 'icon': Icons.account_balance_wallet_rounded},
    ];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final inset = MediaQuery.of(context).viewInsets.bottom;
            return Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(bottom: inset),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.white10
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Center(
                            child: Text(
                              type == TransactionType.expense
                                  ? 'Catat Pengeluaran'
                                  : 'Tambah Pemasukan',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.teal.shade900),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: TextFormField(
                            controller: amountController,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : AppColors.primaryDark,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              RibuanFormatter(),
                            ],
                            onChanged: (val) => setSheetState(() {}),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? Colors.white10
                                    : Colors.teal.shade50,
                              ),
                              prefixIcon: Container(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.payments_rounded,
                                      color: type == TransactionType.income
                                          ? AppColors.success
                                          : AppColors.error,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Rp',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: type == TransactionType.income
                                            ? AppColors.success
                                            : AppColors.error,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              filled: true,
                              fillColor: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : AppColors.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Nominal tidak boleh kosong!';
                              }
                              final amount = _toAmount(val);
                              if (amount == null || amount <= 0) {
                                return 'Nominal transaksi tidak valid.';
                              }
                              return null;
                            },
                          ),
                        ),
                        if (type == TransactionType.expense) ...[
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('BIAYA ADMIN TOP-UP (CEPAT)',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white24
                                            : Colors.teal.shade800
                                                .withValues(alpha: 0.4),
                                        letterSpacing: 1.2)),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: selectedTopUpSource,
                                  isExpanded: true,
                                  dropdownColor: isDarkMode
                                      ? AppColors.surfaceDark
                                      : Colors.white,
                                  decoration: InputDecoration(
                                    labelText: 'Pilih Sumber Top-up',
                                    filled: true,
                                    fillColor: isDarkMode
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                            color: isDarkMode
                                                ? Colors.white10
                                                : Colors.grey.shade200)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                            color: isDarkMode
                                                ? Colors.white10
                                                : Colors.grey.shade200)),
                                    prefixIcon: const Icon(
                                        Icons.account_balance_wallet_rounded,
                                        color: Colors.teal),
                                    labelStyle: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white38
                                            : Colors.black45),
                                  ),
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('Bukan Top-up / Bersihkan'),
                                    ),
                                    ...topUpSources.map((source) {
                                      final label = source['label'] as String;
                                      return DropdownMenuItem<String>(
                                        value: label,
                                        child: Row(
                                          children: [
                                            Icon(source['icon'] as IconData,
                                                size: 18,
                                                color: Colors.teal.shade700),
                                            const SizedBox(width: 12),
                                            Text(label,
                                                style: TextStyle(
                                                    color: isDarkMode
                                                        ? Colors.white70
                                                        : Colors.black87)),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                  onChanged: (val) {
                                    setSheetState(() {
                                      selectedTopUpSource = val;
                                      if (val == null) {
                                        nameController.clear();
                                        selectedCategory =
                                            type == TransactionType.expense
                                                ? 'Makanan & Minuman'
                                                : 'Gaji';
                                      } else if (val != 'Bank') {
                                        nameController.text =
                                            'Biaya Admin $val';
                                        selectedCategory = 'Biaya Admin';
                                      } else {
                                        nameController.text =
                                            'Biaya Admin Bank ${topUpBankName.trim()}'
                                                .trim();
                                        selectedCategory = 'Biaya Admin';
                                      }
                                    });
                                  },
                                ),
                                if (selectedTopUpSource == 'Bank') ...[
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black87),
                                    decoration: InputDecoration(
                                      labelText: 'Nama Bank',
                                      hintText: 'Misal: BRI, BCA, Mandiri...',
                                      filled: true,
                                      fillColor: isDarkMode
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                              color: isDarkMode
                                                  ? Colors.white10
                                                  : Colors.grey.shade200)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                              color: isDarkMode
                                                  ? Colors.white10
                                                  : Colors.grey.shade200)),
                                      prefixIcon: const Icon(
                                          Icons.account_balance_rounded,
                                          color: Colors.teal),
                                      labelStyle: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white38
                                              : Colors.black45),
                                    ),
                                    onChanged: (val) {
                                      topUpBankName = val;
                                      setSheetState(() {
                                        nameController.text =
                                            'Biaya Admin Bank ${val.trim()}'
                                                .trim();
                                      });
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: nameController,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87),
                                decoration: InputDecoration(
                                  labelText: 'Keterangan Transaksi *',
                                  hintText: 'Input Keterangan',
                                  filled: true,
                                  fillColor: isDarkMode
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                          color: isDarkMode
                                              ? Colors.white10
                                              : Colors.grey.shade200)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                          color: isDarkMode
                                              ? Colors.white10
                                              : Colors.grey.shade200)),
                                  prefixIcon: const Icon(
                                      Icons.edit_note_rounded,
                                      color: Colors.teal),
                                  labelStyle: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white38
                                          : Colors.black45),
                                  hintStyle: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white12
                                          : Colors.black26),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Keterangan transaksi harus diisi!';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              Text('PILIH KATEGORI *',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white24
                                          : Colors.teal.shade800
                                              .withValues(alpha: 0.4),
                                      letterSpacing: 1.2)),
                              const SizedBox(height: 24),
                              DropdownButtonFormField<String>(
                                value: selectedCategory,
                                dropdownColor: isDarkMode
                                    ? AppColors.surfaceDark
                                    : Colors.white,
                                decoration: InputDecoration(
                                  labelText: 'Pilih Kategori',
                                  filled: true,
                                  fillColor: isDarkMode
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                          color: isDarkMode
                                              ? Colors.white10
                                              : Colors.grey.shade200)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                          color: isDarkMode
                                              ? Colors.white10
                                              : Colors.grey.shade200)),
                                  prefixIcon: Icon(
                                    categories.any((c) =>
                                            c['label'] == selectedCategory)
                                        ? (categories.firstWhere((c) =>
                                                c['label'] ==
                                                selectedCategory)['icon']
                                            as IconData)
                                        : Icons.more_horiz_rounded,
                                    color: Colors.teal,
                                  ),
                                  labelStyle: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white38
                                          : Colors.black45),
                                ),
                                selectedItemBuilder: (context) {
                                  return categories.map((cat) {
                                    return Text(
                                      cat['label'] as String,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black87),
                                    );
                                  }).toList();
                                },
                                items: categories.map((cat) {
                                  return DropdownMenuItem<String>(
                                    value: cat['label'] as String,
                                    child: Row(
                                      children: [
                                        Icon(cat['icon'] as IconData,
                                            size: 18,
                                            color: Colors.teal.shade700),
                                        const SizedBox(width: 12),
                                        Text(cat['label'] as String,
                                            style: TextStyle(
                                                color: isDarkMode
                                                    ? Colors.white70
                                                    : Colors.black87)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setSheetState(() {
                                      selectedCategory = val;
                                    });
                                  }
                                },
                              ),
                              if (selectedCategory == 'Lainnya') ...[
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: customCategoryController,
                                  autofocus: true,
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black87),
                                  decoration: InputDecoration(
                                    labelText: 'Kategori Kustom',
                                    hintText: 'Misal: Sedekah, Investasi...',
                                    filled: true,
                                    fillColor: isDarkMode
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                            color: isDarkMode
                                                ? Colors.white10
                                                : Colors.grey.shade200)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                            color: isDarkMode
                                                ? Colors.white10
                                                : Colors.grey.shade200)),
                                    prefixIcon: const Icon(Icons.star_rounded,
                                        color: Colors.teal),
                                    labelStyle: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white38
                                            : Colors.black45),
                                    hintStyle: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white12
                                            : Colors.black26),
                                  ),
                                  validator: (val) {
                                    if (selectedCategory == 'Lainnya' &&
                                        (val == null || val.trim().isEmpty)) {
                                      return 'Kategori kustom harus diisi!';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                              if (type == TransactionType.income)
                                _buildSmartAllocationPlanner(
                                    _toAmount(amountController.text) ?? 0,
                                    isDarkMode),
                              const SizedBox(height: 32),
                              ElevatedButton(
                                onPressed: () async {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }

                                  final amount =
                                      _toAmount(amountController.text);
                                  if (amount == null)
                                    return; // Should be handled by validator

                                  final finalCategory =
                                      (selectedCategory == 'Lainnya' &&
                                              customCategoryController.text
                                                  .trim()
                                                  .isNotEmpty)
                                          ? customCategoryController.text.trim()
                                          : selectedCategory;

                                  final tx = TransactionModel(
                                    id: DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString(),
                                    title: nameController.text.trim().isEmpty
                                        ? finalCategory
                                        : nameController.text.trim(),
                                    description: noteText.trim(),
                                    amount: amount,
                                    type: type,
                                    date: DateTime.now(),
                                    category: finalCategory,
                                    creatorName: ref.read(userNameProvider),
                                  );

                                  await ref
                                      .read(transactionServiceProvider)
                                      .addTransaction(tx);
                                  if (sheetContext.mounted) {
                                    Navigator.pop(sheetContext);
                                  }
                                  if (sheetContext.mounted && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Berhasil mencatat transaksi! ✨')));
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 64),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  elevation: 8,
                                  shadowColor:
                                      AppColors.primary.withValues(alpha: 0.4),
                                ),
                                child: const Text('Simpan Transaksi',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        letterSpacing: 0.5)),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showSavingTargetDialog(double totalBalance) async {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.backgroundDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white10 : Colors.black12,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Daftar Target',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: isDarkMode ? Colors.white : Colors.black87)),
                    TextButton.icon(
                      onPressed: () => _showAddEditTargetDialog(),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Tambah'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final targetsAsync = ref.watch(savingTargetsStreamProvider);
                    return targetsAsync.when(
                      data: (targets) {
                        if (targets.isEmpty) {
                          return Center(
                              child: Text('Belum ada target.',
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white60
                                          : Colors.black38)));
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: targets.length,
                          itemBuilder: (context, index) {
                            final t = targets[index];
                            return ListTile(
                              leading: CircleAvatar(
                                  backgroundColor: AppColors.primary.withValues(
                                      alpha: isDarkMode ? 0.15 : 0.1),
                                  child: const Icon(Icons.track_changes_rounded,
                                      color: AppColors.primary)),
                              title: Text(t.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black87)),
                              subtitle: Text(
                                  'Target: ${_formatRupiah(t.targetAmount)}',
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white24
                                          : Colors.black54)),
                              onTap: () {
                                Navigator.pop(
                                    sheetContext); // Close the list sheet
                                _showTargetDetailSheet(t, totalBalance);
                              },
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Center(child: Text('Error: $e')),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddEditTargetDialog({SavingTargetModel? target}) async {
    final isEdit = target != null;
    final amountController = TextEditingController(
        text: isEdit
            ? _formatDigitsWithDots(target.targetAmount.round().toString())
            : '');
    final itemController =
        TextEditingController(text: isEdit ? target.name : '');
    DateTime selectedDate =
        isEdit ? target.dueDate : DateTime.now().add(const Duration(days: 30));

    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor:
                  isDarkMode ? AppColors.surfaceDark : Colors.white,
              surfaceTintColor:
                  isDarkMode ? AppColors.surfaceDark : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
              title: Text(isEdit ? 'Edit Target' : 'Target Baru',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: isDarkMode ? Colors.white : Colors.black87)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NOMINAL TARGET *',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white24 : Colors.black38,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountController,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isDarkMode ? Colors.white : Colors.black87),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        RibuanFormatter(),
                      ],
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                            color:
                                isDarkMode ? Colors.white12 : Colors.black26),
                        prefixIcon: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 16),
                            Icon(Icons.account_balance_wallet_rounded,
                                color: Colors.teal, size: 20),
                            SizedBox(width: 8),
                            Text('Rp',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                    fontSize: 16)),
                            SizedBox(width: 8),
                          ],
                        ),
                        filled: true,
                        fillColor: isDarkMode
                            ? Colors.teal.shade900.withValues(alpha: 0.2)
                            : Colors.teal.shade50.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('TARGET PEMBELIAN *',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white24 : Colors.black38,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: itemController,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Contoh: Laptop, Motor, HP...',
                        hintStyle: TextStyle(
                            color:
                                isDarkMode ? Colors.white12 : Colors.black26),
                        filled: true,
                        fillColor: isDarkMode
                            ? Colors.teal.shade900.withValues(alpha: 0.2)
                            : Colors.teal.shade50.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.shopping_bag_rounded,
                            color: Colors.teal, size: 20),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('TANGGAL TARGET SELESAI *',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white24 : Colors.black38,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 3650)), // 10 years max
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: isDarkMode
                                    ? ColorScheme.dark(
                                        primary: AppColors.primary,
                                        onPrimary: Colors.white,
                                        surface: AppColors.surfaceDark,
                                        onSurface: Colors.white,
                                      )
                                    : ColorScheme.light(
                                        primary: AppColors.primary,
                                        onPrimary: Colors.white,
                                        onSurface: Colors.teal.shade900,
                                      ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.teal.shade900.withValues(alpha: 0.2)
                              : Colors.teal.shade50.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded,
                                color: Colors.teal, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                                    .format(selectedDate),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          backgroundColor: isDarkMode
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey.shade50,
                        ),
                        child: Text('Batal',
                            style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white38
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final amount = _toAmount(amountController.text);
                          final name = itemController.text.trim();

                          if (amount == null || amount <= 0 || name.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Mohon lengkapi data dengan benar.')));
                            return;
                          }

                          const userId = 'default_user';
                          if (isEdit) {
                            final updated = target.copyWith(
                              name: name,
                              targetAmount: amount,
                              dueDate: selectedDate,
                            );
                            await ref
                                .read(savingTargetServiceProvider)
                                .updateTarget(updated);
                          } else {
                            final newTarget = SavingTargetModel(
                              id: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              name: name,
                              targetAmount: amount,
                              dueDate: selectedDate,
                              createdAt: DateTime.now(),
                            );
                            await ref
                                .read(savingTargetServiceProvider)
                                .addTarget(newTarget);
                            await _maybeShowTargetReminder(userId, newTarget);
                          }

                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                          if (isEdit && context.mounted) {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(
                                  context); // Close management sheet if edit
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Simpan',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  double? _toAmount(String raw) {
    // Bersihkan dari karakter non-angka
    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return null;
    return double.tryParse(digitsOnly);
  }

  Widget _buildFinanceTab(
    AsyncValue<List<TransactionModel>> transactionsAsync,
    List<TransactionModel> transactions,
  ) {
    if (transactionsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (s, a) => s + a.amount);
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (s, a) => s + a.amount);

    // NEW DATA LOGIC: Daily trend for the entire current month
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    // Financial Insight Logic
    final remainingDays = lastDayOfMonth.day - now.day + 1;
    final totalBalance = totalIncome - totalExpense;
    final dailyAllowance =
        totalBalance > 0 ? totalBalance / remainingDays : 0.0;
    final savingsRate =
        totalIncome > 0 ? ((totalBalance / totalIncome) * 100) : 0.0;

    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && theme.brightness == Brightness.dark);

    String healthStatus = "Boros";
    Color healthColor =
        isDarkMode ? Colors.redAccent.shade100 : Colors.redAccent.shade200;
    IconData healthIcon = Icons.warning_amber_rounded;
    if (savingsRate >= 50) {
      healthStatus = "SANGAT HEMAT";
      healthColor = isDarkMode
          ? Colors.greenAccent.shade700
          : Colors.greenAccent.shade400;
      healthIcon = Icons.verified_rounded;
    } else if (savingsRate >= 20) {
      healthStatus = "WAJAR / STABIL";
      healthColor = isDarkMode
          ? Colors.orangeAccent.shade700
          : Colors.orangeAccent.shade200;
      healthIcon = Icons.info_outline_rounded;
    }

    final Map<int, Map<String, double>> monthlyDataMap = {};
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      monthlyDataMap[day] = {'income': 0.0, 'expense': 0.0};
    }

    // Filter transactions for current month only
    for (var t in transactions) {
      if (t.date.year == now.year && t.date.month == now.month) {
        if (t.type == TransactionType.income) {
          monthlyDataMap[t.date.day]!['income'] =
              (monthlyDataMap[t.date.day]!['income'] ?? 0) + t.amount;
        } else {
          monthlyDataMap[t.date.day]!['expense'] =
              (monthlyDataMap[t.date.day]!['expense'] ?? 0) + t.amount;
        }
      }
    }

    final List<Map<String, dynamic>> trendData = [];
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      trendData.add({
        'day': day,
        'label': '$day',
        'income': monthlyDataMap[day]!['income'] ?? 0.0,
        'expense': monthlyDataMap[day]!['expense'] ?? 0.0,
        'index': (day - 1).toDouble()
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual Header: Balance & Trend
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                    color:
                        Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.02),
                    blurRadius: 20,
                    offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TOTAL SALDO',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: isDarkMode
                            ? Colors.white30
                            : Colors.teal.shade800.withValues(alpha: 0.4))),
                const SizedBox(height: 8),
                Text(_formatRupiah(totalIncome - totalExpense),
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.teal.shade900,
                        letterSpacing: -1)),
                const SizedBox(height: 4),
                Text(DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now()),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? Colors.white38
                            : Colors.teal.shade700)),
                // Premium Wealth Trend Chart (Scrollable Line Chart)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 24, right: 32, left: 24, bottom: 8),
                    height: 220,
                    width: math.max(MediaQuery.of(context).size.width - 80,
                        trendData.length * 48.0),
                    child: LineChart(
                      LineChartData(
                        minX: -1.0,
                        maxX: trendData.length - 0.5,
                        minY: 0,
                        maxY: trendData.fold<double>(0, (max, d) {
                              final val = d['income'] > d['expense']
                                  ? d['income']
                                  : d['expense'];
                              return val > max ? val : max;
                            }) *
                            1.5,
                        lineTouchData: LineTouchData(
                          getTouchedSpotIndicator: (LineChartBarData barData,
                              List<int> spotIndexes) {
                            return spotIndexes.map((index) {
                              return TouchedSpotIndicatorData(
                                FlLine(
                                    color:
                                        barData.color?.withValues(alpha: 0.4),
                                    strokeWidth: 2,
                                    dashArray: [4, 4]),
                                FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) =>
                                          FlDotCirclePainter(
                                    radius: 6,
                                    color: barData.color ?? Colors.teal,
                                    strokeWidth: 2,
                                    strokeColor: isDarkMode
                                        ? AppColors.surfaceDark
                                        : Colors.white,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: isDarkMode
                                ? Colors.indigo.shade900
                                : Colors.indigo.shade800,
                            tooltipRoundedRadius: 12,
                            tooltipPadding: const EdgeInsets.all(8),
                            tooltipMargin: 8,
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final d = trendData[spot.x.toInt()];
                                final isIncome = spot.barIndex == 0;
                                final val =
                                    isIncome ? d['income'] : d['expense'];
                                return LineTooltipItem(
                                  "${isIncome ? '+' : '-'}${_formatCompactRupiah(val)}",
                                  TextStyle(
                                      color: isIncome
                                          ? (isDarkMode
                                              ? Colors.greenAccent.shade200
                                              : Colors.greenAccent.shade400)
                                          : (isDarkMode
                                              ? Colors.redAccent.shade100
                                              : Colors.redAccent.shade400),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                if (value != value.toInt()) {
                                  return const SizedBox.shrink();
                                }
                                final index = value.toInt();
                                if (index < 0 || index >= trendData.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    trendData[index]['label'],
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white24
                                          : Colors.teal.shade800
                                              .withValues(alpha: 0.4),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          drawHorizontalLine: true,
                          verticalInterval: 1,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.teal.shade50.withValues(alpha: 0.3),
                            strokeWidth: 1,
                            dashArray: [5, 5],
                          ),
                          getDrawingVerticalLine: (value) => FlLine(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.teal.shade50.withValues(alpha: 0.3),
                            strokeWidth: 1,
                            dashArray: [5, 5],
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: trendData
                                .map((d) => FlSpot(d['index'] as double,
                                    d['income'] as double))
                                .toList(),
                            isCurved: false,
                            color: isDarkMode
                                ? Colors.greenAccent.shade400
                                : Colors.green.shade400,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: (isDarkMode
                                      ? Colors.greenAccent.shade400
                                      : Colors.green.shade400)
                                  .withValues(alpha: 0.1),
                            ),
                          ),
                          LineChartBarData(
                            spots: trendData
                                .map((d) => FlSpot(d['index'] as double,
                                    d['expense'] as double))
                                .toList(),
                            isCurved: false,
                            color: isDarkMode
                                ? Colors.redAccent.shade200
                                : Colors.red.shade400,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: (isDarkMode
                                      ? Colors.redAccent.shade200
                                      : Colors.red.shade400)
                                  .withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                    child: Text('GRAFIK PEMASUKAN vs PENGELUARAN',
                        style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: isDarkMode
                                ? Colors.white10
                                : Colors.teal.shade800
                                    .withValues(alpha: 0.15)))),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Total Stats Center Row
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                    color:
                        Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.02),
                    blurRadius: 20,
                    offset: const Offset(0, 10))
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _miniStat(
                    'Total Pemasukan', totalIncome, Colors.green, isDarkMode),
                Container(
                    width: 1,
                    height: 32,
                    color: isDarkMode ? Colors.white10 : Colors.teal.shade50),
                _miniStat(
                    'Total Pengeluaran', totalExpense, Colors.red, isDarkMode),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // INSIGHT KEUANGAN
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [Colors.indigo.shade900, Colors.deepPurple.shade900]
                    : [Colors.indigo.shade700, Colors.deepPurple.shade600],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                    color: (isDarkMode ? AppColors.primary : Colors.teal)
                        .withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('INSIGHT KEUANGAN',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Colors.white.withValues(alpha: 0.5))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: healthColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(healthIcon, size: 10, color: healthColor),
                          const SizedBox(width: 4),
                          Text(healthStatus,
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: healthColor)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jatah Harian',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(_formatRupiah(dailyAllowance),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          Text('Sisa $remainingDays hari bulan ini',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 4),
                      ),
                      child: Center(
                        child: Text('${savingsRate.toInt()}%',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Container(
                          height: 6,
                          color: Colors.white.withValues(alpha: 0.1)),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 1000),
                        height: 6,
                        width: (MediaQuery.of(context).size.width - 110) *
                            (savingsRate / 100).clamp(0, 1),
                        decoration: BoxDecoration(
                          color: healthColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: healthColor.withValues(alpha: 0.5),
                                blurRadius: 10)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  savingsRate >= 20
                      ? 'Kondisi keuanganmu sehat. Pertahankan rasio tabungan di atas 20%!'
                      : 'Ayo hemat lagi! Rasio tabunganmu saat ini masih di bawah target minimal 20%.',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),

          // TIPS & MOTIVASI SECTION
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Tips & Motivasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Motivational Quote Hero Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [
                        Colors.orange.shade700.withValues(alpha: 0.8),
                        Colors.orange.shade900.withValues(alpha: 0.8)
                      ]
                    : [Colors.orange.shade400, Colors.orange.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.orange.withValues(alpha: isDarkMode ? 0.2 : 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.format_quote_rounded,
                    color: Colors.white, size: 40),
                const SizedBox(height: 12),
                const Text(
                  '"Jangan menabung apa yang tersisa setelah dibelanjakan, tapi belanjakan apa yang tersisa setelah ditabung."',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '- Warren Buffett',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Horizontal Tips Scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTipCard(
                  'Aturan 50/30/20',
                  '50% Kebutuhan, 30% Keinginan, dan 20% Tabungan.',
                  Icons.pie_chart_rounded,
                  Colors.blue,
                ),
                _buildTipCard(
                  'Tunda 24 Jam',
                  'Tunggu 24 jam sebelum membeli barang yang tidak direncanakan.',
                  Icons.timer_rounded,
                  Colors.purple,
                ),
                _buildTipCard(
                  'Catat Pengeluaran',
                  'Sekecil apapun uang yang keluar, pastikan tercatat di TabunganKu.',
                  Icons.edit_note_rounded,
                  Colors.teal,
                ),
                _buildTipCard(
                  'Masak Sendiri',
                  'Membawa bekal dan masak di rumah jauh lebih hemat & sehat.',
                  Icons.restaurant_rounded,
                  Colors.orange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 48), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildTipCard(String title, String desc, IconData icon, Color color) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            width: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: isDarkMode
                      ? Colors.white10
                      : color.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDarkMode ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon,
                      color: isDarkMode ? color.withValues(alpha: 0.8) : color,
                      size: 20),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDarkMode ? Colors.white54 : Colors.black54,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenteredIndicator(String label, double amount, Color color) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    return Column(
      children: [
        Row(
          children: [
            Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.6),
                    shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white54 : Colors.black45)),
          ],
        ),
        const SizedBox(height: 4),
        Text(_formatCompactRupiah(amount),
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildHistoryTab(
    AsyncValue<List<TransactionModel>> transactionsAsync,
    List<TransactionModel> transactions,
  ) {
    if (transactionsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    return _HistoryTabView(
      allTransactions: transactions,
      isDarkMode: isDarkMode,
      buildTransactionCard: _buildTransactionCard,
      miniHeaderStat: _miniHeaderStat,
      formatRupiah: _formatRupiah,
      formatCompact: _formatCompactRupiah,
      onTransactionTap: _showTransactionDetailSheet,
      onExportMonth: _showExportSheetForMonth,
    );
  }

  /// Tampilkan bottom sheet ekspor untuk bulan tertentu
  Future<void> _showExportSheetForMonth({
    required List<TransactionModel> monthTx,
    required String monthLabel,
  }) async {
    final isDark = ref.read(themeProvider) == ThemeMode.dark ||
        (ref.read(themeProvider) == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    final regular = monthTx.where((t) {
      if (t.category == 'Hutang' || t.category == 'Piutang') return false;
      if (t.id.startsWith('shopping_')) return false;
      return true;
    }).toList();

    final income = regular
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final expense = regular
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);
    final fmtNum =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setSheet) {
          return Container(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 36),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                // Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.share_rounded,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ekspor Laporan',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDark ? Colors.white : Colors.black87)),
                          Text(
                              'Bulan $monthLabel (${regular.length} transaksi)',
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isDark ? Colors.white38 : Colors.black45,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Summary mini
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: isDark ? Colors.white10 : Colors.grey.shade100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _miniExportStat(isDark, 'PEMASUKAN',
                          fmtNum.format(income), Colors.green),
                      Container(
                          width: 1,
                          height: 32,
                          color:
                              isDark ? Colors.white10 : Colors.grey.shade200),
                      _miniExportStat(isDark, 'PENGELUARAN',
                          fmtNum.format(expense), Colors.red),
                      Container(
                          width: 1,
                          height: 32,
                          color:
                              isDark ? Colors.white10 : Colors.grey.shade200),
                      _miniExportStat(
                          isDark,
                          'SALDO',
                          fmtNum.format(income - expense),
                          (income - expense) >= 0 ? Colors.teal : Colors.red),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                // Export options
                _exportOptionTile(
                  ctx2,
                  isDark: isDark,
                  icon: Icons.picture_as_pdf_rounded,
                  iconColor: Colors.red.shade500,
                  title: 'Bagikan sebagai PDF',
                  subtitle: 'Laporan lengkap dalam format PDF siap cetak',
                  onTap: () async {
                    Navigator.pop(ctx2);
                    try {
                      await ExportService.shareMonthlyReport(
                        context: ctx2,
                        transactions: regular,
                        monthLabel: monthLabel,
                        asPdf: true,
                      );
                    } catch (_) {}
                  },
                ),
                const SizedBox(height: 12),
                _exportOptionTile(
                  ctx2,
                  isDark: isDark,
                  icon: Icons.content_copy_rounded,
                  iconColor: Colors.blue.shade500,
                  title: 'Salin Ringkasan Teks',
                  subtitle: 'Ringkasan singkat siap kirim via WhatsApp, dll.',
                  onTap: () async {
                    Navigator.pop(ctx2);
                    try {
                      await ExportService.shareMonthlyReport(
                        context: ctx2,
                        transactions: regular,
                        monthLabel: monthLabel,
                        asPdf: false,
                      );
                    } catch (_) {}
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _miniExportStat(bool isDark, String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: isDark ? Colors.white38 : Colors.black38)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _exportOptionTile(
    BuildContext ctx, {
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color:
          isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.black45,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: isDark ? Colors.white24 : Colors.black26),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniHeaderStat(String label, double amount, Color color) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDarkMode ? 0.15 : 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          Text(_formatRupiah(amount),
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? color : color.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel t) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);
    final isExpense = t.type == TransactionType.expense;

    // Simplified Icons for History
    final IconData catIcon =
        isExpense ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    final Color catColor = isExpense
        ? (isDarkMode ? Colors.redAccent.shade100 : Colors.red)
        : (isDarkMode ? Colors.greenAccent.shade400 : Colors.green);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showTransactionDetailSheet(t),
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? theme.cardColor
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.01)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: isDarkMode ? 0.2 : 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(catIcon, color: catColor, size: 18),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.teal.shade900)),
                      const SizedBox(height: 2),
                      Text(
                          '${DateFormat('EEEE, dd MMM', 'id_ID').format(t.date)} • ${DateFormat('HH:mm', 'id_ID').format(t.date)}',
                          style: TextStyle(
                              color:
                                  isDarkMode ? Colors.white54 : Colors.black26,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Text(
                  '${isExpense ? '- ' : '+ '}${_formatRupiah(t.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isExpense
                        ? (isDarkMode ? Colors.redAccent : Colors.red.shade700)
                        : (isDarkMode
                            ? Colors.greenAccent
                            : Colors.green.shade700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showTransactionDetailSheet(TransactionModel t) async {
    final isSystemLinked = t.category == 'Hutang' ||
        t.category == 'Piutang' ||
        t.id.startsWith('shopping_');

    await TransactionDetailSheet.show(
      context,
      ref,
      t,
      onEdit: isSystemLinked ? null : () => _showEditTransactionSheet(t),
      onDelete: () => _confirmDeleteTransaction(t),
    );
  }

  // _buildReceiptRow has been moved to TransactionDetailSheet

  Future<void> _confirmDeleteTransaction(TransactionModel t) async {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Hapus Transaksi?',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87)),
        content: Text(
            'Yakin ingin menghapus ${t.title}? Langkah ini tidak bisa dibatalkan.',
            style:
                TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Batal',
                  style: TextStyle(
                      color: isDarkMode ? Colors.white30 : Colors.grey))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(transactionServiceProvider).deleteTransaction(t.id);
      if (mounted) setState(() {});
    }
  }

  Widget _buildNavItem(int index) {
    final isSelected = _currentIndex == index;
    final item = _navItems[index];
    final color = isSelected ? AppColors.primary : const Color(0xFF94A3B8);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _currentIndex = index),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: color, size: 22),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: color,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRupiah(double value) {
    final rounded = value.round();
    final text = rounded.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
    return 'Rp $text';
  }

  String _formatCompactRupiah(double value) {
    if (value >= 1000000000) {
      return 'Rp ${(value / 1000000000).toStringAsFixed(1)} M';
    }
    if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)} jt';
    }
    if (value >= 1000) return 'Rp ${(value / 1000).toStringAsFixed(0)} rb';
    return _formatRupiah(value);
  }

  String _formatDigitsWithDots(String digitsText) {
    final digits = digitsText.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    return digits.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  Future<void> _showEditTransactionSheet(TransactionModel t) async {
    final amountController = TextEditingController(
        text: _formatDigitsWithDots(t.amount.round().toString()));
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final inset = MediaQuery.of(sheetContext).viewInsets.bottom;
        return StatefulBuilder(
          builder: (sheetContext, sheetSetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: inset),
              child: Container(
                padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.white10
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(2))),
                      Text('Edit Nominal',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode ? Colors.white : Colors.black87)),
                      const SizedBox(height: 12),
                      Text(t.title,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white38
                                  : Colors.teal.shade800
                                      .withValues(alpha: 0.4))),
                      const SizedBox(height: 24),

                      // Amount Input
                      TextFormField(
                        controller: amountController,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          RibuanFormatter()
                        ],
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Input Nominal Baru *',
                          labelStyle: TextStyle(
                              color:
                                  isDarkMode ? Colors.white38 : Colors.black45),
                          prefixIcon: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 16),
                              Icon(Icons.account_balance_wallet_rounded,
                                  color: Colors.teal, size: 20),
                              SizedBox(width: 8),
                              Text('Rp',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                      fontSize: 16)),
                              SizedBox(width: 8),
                            ],
                          ),
                          filled: true,
                          fillColor: isDarkMode
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey.shade50,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: isDarkMode
                                      ? Colors.white10
                                      : Colors.grey.shade200)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final valText =
                                amountController.text.replaceAll('.', '');
                            final finalAmount = double.tryParse(valText);
                            if (finalAmount == null || finalAmount <= 0) {
                              return;
                            }

                            final updated = t.copyWith(
                              amount: finalAmount,
                            );

                            await ref
                                .read(transactionServiceProvider)
                                .updateTransaction(updated);

                            if (mounted) {
                              if (sheetContext.mounted &&
                                  Navigator.canPop(sheetContext)) {
                                Navigator.pop(sheetContext);
                              }
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Nominal berhasil diperbarui!')));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Simpan Perubahan',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white54 : Colors.grey.shade500,
                letterSpacing: 1.2)),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _showBalance ? _formatRupiah(amount) : '••••',
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color.withValues(alpha: isDarkMode ? 0.9 : 0.8)),
          ),
        ),
      ],
    );
  }
}

const List<_NavItem> _navItems = [
  _NavItem(icon: Icons.home_rounded, label: 'Beranda'),
  _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Keuangan'),
  _NavItem(icon: Icons.receipt_long_rounded, label: 'Riwayat'),
  _NavItem(icon: Icons.person_outline_rounded, label: 'Profil'),
];

class _CalculatorSheetContent extends ConsumerStatefulWidget {
  const _CalculatorSheetContent();

  @override
  ConsumerState<_CalculatorSheetContent> createState() =>
      _CalculatorSheetContentState();
}

class _CalculatorSheetContentState
    extends ConsumerState<_CalculatorSheetContent> {
  String _output = "0";
  String _expression = "";
  double? _num1;
  double? _num2;
  String? _operand;

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "AC") {
        _output = "0";
        _expression = "";
        _num1 = null;
        _num2 = null;
        _operand = null;
      } else if (buttonText == "C") {
        if (_output != "0") {
          _output = _output.length > 1
              ? _output.substring(0, _output.length - 1)
              : "0";
        }
      } else if (buttonText == "+" ||
          buttonText == "-" ||
          buttonText == "×" ||
          buttonText == "÷") {
        _num1 =
            double.tryParse(_output.replaceAll('.', '').replaceAll(',', '.'));
        _operand = buttonText;
        _expression = "$_output $buttonText";
        _output = "0";
      } else if (buttonText == "%") {
        double val =
            double.tryParse(_output.replaceAll('.', '').replaceAll(',', '.')) ??
                0;
        _output = (val / 100).toString().replaceAll('.', ',');
      } else if (buttonText == "+/-") {
        if (_output.startsWith("-")) {
          _output = _output.substring(1);
        } else if (_output != "0") {
          _output = "-$_output";
        }
      } else if (buttonText == "=") {
        _num2 =
            double.tryParse(_output.replaceAll('.', '').replaceAll(',', '.'));
        if (_num1 != null && _operand != null && _num2 != null) {
          double result = 0;
          if (_operand == "+") result = _num1! + _num2!;
          if (_operand == "-") result = _num1! - _num2!;
          if (_operand == "×") result = _num1! * _num2!;
          if (_operand == "÷") result = _num1! / _num2!;

          _output = result % 1 == 0
              ? result.toInt().toString()
              : result.toStringAsFixed(2).replaceAll('.', ',');
          _expression = "";
          _num1 = null;
          _num2 = null;
          _operand = null;
        }
      } else {
        if (_output == "0") {
          _output = buttonText;
        } else {
          _output = _output + buttonText;
        }
      }
    });
  }

  String _formatDisplay(String val) {
    if (val == "0") return "0";
    if (val.contains(',')) return val;
    final clean = val.replaceAll('.', '');
    final parts = clean.split(',');
    final whole = parts[0];
    final formattedWhole = whole.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return parts.length > 1 ? '$formattedWhole,${parts[1]}' : formattedWhole;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: isDarkMode
            ? [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 40,
                    offset: const Offset(0, -10))
              ]
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 40,
                    offset: const Offset(0, -10))
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
                color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2)),
          ),
          // Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.03)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_expression,
                    style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode
                            ? Colors.white24
                            : Colors.teal.shade800.withValues(alpha: 0.4),
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Text(
                    _formatDisplay(_output),
                    style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.teal.shade900,
                        letterSpacing: -1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Buttons Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _calcButton("AC", isAction: true, isDarkMode: isDarkMode),
              _calcButton("+/-", isAction: true, isDarkMode: isDarkMode),
              _calcButton("%", isAction: true, isDarkMode: isDarkMode),
              _calcButton("÷", isOperator: true, isDarkMode: isDarkMode),
              _calcButton("7", isDarkMode: isDarkMode),
              _calcButton("8", isDarkMode: isDarkMode),
              _calcButton("9", isDarkMode: isDarkMode),
              _calcButton("×", isOperator: true, isDarkMode: isDarkMode),
              _calcButton("4", isDarkMode: isDarkMode),
              _calcButton("5", isDarkMode: isDarkMode),
              _calcButton("6", isDarkMode: isDarkMode),
              _calcButton("-", isOperator: true, isDarkMode: isDarkMode),
              _calcButton("1", isDarkMode: isDarkMode),
              _calcButton("2", isDarkMode: isDarkMode),
              _calcButton("3", isDarkMode: isDarkMode),
              _calcButton("+", isOperator: true, isDarkMode: isDarkMode),
              _calcButton("C", isDarkMode: isDarkMode),
              _calcButton("0", isDarkMode: isDarkMode),
              _calcButton(",", isDarkMode: isDarkMode),
              _calcButton("=",
                  isOperator: true, isPrimary: true, isDarkMode: isDarkMode),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _calcButton(String text,
      {bool isOperator = false,
      bool isAction = false,
      bool isPrimary = false,
      required bool isDarkMode}) {
    Color bgColor =
        isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.teal.shade900;

    if (isOperator) {
      bgColor = isPrimary
          ? AppColors.primary
          : (isDarkMode
              ? Colors.teal.shade900.withValues(alpha: 0.3)
              : Colors.teal.shade50);
      textColor = isPrimary
          ? Colors.white
          : (isDarkMode ? Colors.teal.shade300 : AppColors.primary);
    } else if (isAction) {
      bgColor = isDarkMode
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.grey.shade50;
      textColor = isDarkMode ? Colors.teal.shade200 : Colors.teal.shade700;
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _buttonPressed(text == "," ? "." : text),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.teal.shade50.withValues(alpha: 0.5),
                width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget Riwayat 3-Tab (terpisah agar punya TabController sendiri)
// ─────────────────────────────────────────────────────────────────────────────
class _HistoryTabView extends StatefulWidget {
  final List<TransactionModel> allTransactions;
  final bool isDarkMode;
  final Widget Function(TransactionModel) buildTransactionCard;
  final Widget Function(String, double, Color) miniHeaderStat;
  final String Function(double) formatRupiah;
  final String Function(double) formatCompact;
  final void Function(TransactionModel) onTransactionTap;
  final Future<void> Function({
    required List<TransactionModel> monthTx,
    required String monthLabel,
  }) onExportMonth;

  const _HistoryTabView({
    required this.allTransactions,
    required this.isDarkMode,
    required this.buildTransactionCard,
    required this.miniHeaderStat,
    required this.formatRupiah,
    required this.formatCompact,
    required this.onTransactionTap,
    required this.onExportMonth,
  });

  @override
  State<_HistoryTabView> createState() => _HistoryTabViewState();
}

class _HistoryTabViewState extends State<_HistoryTabView> {
  int _filterIndex = 0;

  // ── Search & Filter state ──────────────────────────────────────────
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  // 0 = Semua, 1 = Pemasukan, 2 = Pengeluaran
  int _typeFilter = 0;
  // null = semua kategori
  String? _categoryFilter;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _isHutangPiutang(TransactionModel t) =>
      t.category == 'Hutang' || t.category == 'Piutang';
  bool _isBelanja(TransactionModel t) => t.id.startsWith('shopping_');
  bool _isRegular(TransactionModel t) => !_isHutangPiutang(t) && !_isBelanja(t);

  String _fmtCur(double amount) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
          .format(amount);

  @override
  Widget build(BuildContext context) {
    final sorted = [...widget.allTransactions]
      ..sort((a, b) => b.date.compareTo(a.date));

    final regularList = sorted.where(_isRegular).toList();
    final hutangList = sorted.where(_isHutangPiutang).toList();
    final belanjaList = sorted.where(_isBelanja).toList();
    final isDark = widget.isDarkMode;

    return Column(
      children: [
        // ── Minimalist Filter Selektor ────────────────────────────────────
        _buildHistoryFilter(isDark, regularList, hutangList, belanjaList),

        // ── Search Bar (hanya tampil di tab reguler) ─────────────────────
        if (_filterIndex == 0) _buildSearchBar(isDark, regularList),

        // ── Konten Filtered ───────────────────────────────────────────────
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildFilteredBody(
                sorted, regularList, hutangList, belanjaList, isDark),
          ),
        ),
      ],
    );
  }

  // ── Search Bar + Type + Category Filters ─────────────────────────────
  Widget _buildSearchBar(bool isDark, List<TransactionModel> regularList) {
    // Build unique category list from regular transactions
    final categories = regularList.map((t) => t.category).toSet().toList()
      ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search TextField
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Builder(builder: (context) {
            final isDk = isDark;
            return TextField(
              controller: _searchCtrl,
              style: TextStyle(
                  fontSize: 14,
                  color: isDk ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Cari transaksi...',
                hintStyle: TextStyle(
                    fontSize: 14,
                    color: isDk ? Colors.white24 : Colors.black26,
                    fontWeight: FontWeight.w500),
                prefixIcon: Icon(Icons.search_rounded,
                    color: isDk ? Colors.white38 : Colors.black38, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded,
                            size: 18,
                            color: isDk ? Colors.white38 : Colors.black38),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDk
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                        color: isDk
                            ? Colors.white10
                            : Colors.black.withValues(alpha: 0.04))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 1.5)),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        // Type Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _typeChip(isDark, 0, 'Semua', Icons.receipt_long_rounded),
              const SizedBox(width: 8),
              _typeChip(isDark, 1, 'Pemasukan', Icons.arrow_downward_rounded),
              const SizedBox(width: 8),
              _typeChip(isDark, 2, 'Pengeluaran', Icons.arrow_upward_rounded),
              if (categories.isNotEmpty) ...[const SizedBox(width: 16)],
              ...categories.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _categoryChip(isDark, cat),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _typeChip(bool isDark, int value, String label, IconData icon) {
    final selected = _typeFilter == value;
    return GestureDetector(
      onTap: () => setState(() {
        _typeFilter = value;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.12)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 13,
                color: selected
                    ? AppColors.primary
                    : (isDark ? Colors.white38 : Colors.black38)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                    color: selected
                        ? AppColors.primary
                        : (isDark ? Colors.white54 : Colors.black54))),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(bool isDark, String category) {
    final selected = _categoryFilter == category;
    return GestureDetector(
      onTap: () => setState(() {
        _categoryFilter = selected ? null : category;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Colors.teal.withValues(alpha: isDark ? 0.25 : 0.1)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected
                  ? Colors.teal
                  : (isDark ? Colors.white10 : Colors.grey.shade200),
              width: 1),
        ),
        child: Text(
          '# $category',
          style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.bold : FontWeight.w600,
              color: selected
                  ? (isDark ? Colors.tealAccent : Colors.teal.shade700)
                  : (isDark ? Colors.white38 : Colors.black45)),
        ),
      ),
    );
  }

  Widget _buildHistoryFilter(bool isDark, List<TransactionModel> regularList,
      List<TransactionModel> hutangList, List<TransactionModel> belanjaList) {
    final categories = ['Pemasukan & Pengeluaran', 'Hutang', 'Belanja'];
    final categoryIcons = [
      Icons.account_balance_rounded,
      Icons.account_balance_wallet_rounded,
      Icons.shopping_basket_rounded
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Filter Dropdown / Pill Minimalist
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () async {
                final RenderBox button =
                    context.findRenderObject() as RenderBox;
                final RenderBox overlay = Navigator.of(context)
                    .overlay!
                    .context
                    .findRenderObject() as RenderBox;
                final RelativeRect position = RelativeRect.fromRect(
                  Rect.fromPoints(
                    button.localToGlobal(const Offset(0, 45),
                        ancestor: overlay),
                    button.localToGlobal(button.size.bottomRight(Offset.zero),
                        ancestor: overlay),
                  ),
                  Offset.zero & overlay.size,
                );

                final int? result = await showMenu<int>(
                  context: context,
                  position: position,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  elevation: 8,
                  items: [
                    for (int i = 0; i < categories.length; i++)
                      PopupMenuItem(
                        value: i,
                        child: Row(
                          children: [
                            Icon(categoryIcons[i],
                                size: 18,
                                color: _filterIndex == i
                                    ? AppColors.primary
                                    : (isDark
                                        ? Colors.white38
                                        : Colors.black38)),
                            const SizedBox(width: 12),
                            Text(categories[i],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: _filterIndex == i
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: _filterIndex == i
                                      ? AppColors.primary
                                      : (isDark
                                          ? Colors.white
                                          : Colors.black87),
                                )),
                          ],
                        ),
                      ),
                  ],
                );
                if (result != null && mounted) {
                  setState(() => _filterIndex = result);
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: 0.03)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(categoryIcons[_filterIndex],
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      categories[_filterIndex],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: isDark ? Colors.white38 : Colors.black38),
                  ],
                ),
              ),
            ),
          ),

          // Count Badge (Optional, added for minimalist premium feel)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _filterIndex == 0
                  ? '${regularList.length} Item'
                  : (_filterIndex == 1
                      ? '${hutangList.length} Item'
                      : '${belanjaList.length} Item'),
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredBody(
      List<TransactionModel> allSorted,
      List<TransactionModel> regularList,
      List<TransactionModel> hutangList,
      List<TransactionModel> belanjaList,
      bool isDark) {
    switch (_filterIndex) {
      case 0:
        return _buildRegularTab(allSorted, regularList, isDark);
      case 1:
        return _buildHutangTab(hutangList, isDark);
      case 2:
        return _buildBelanjaTab(belanjaList, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Tab 1: Pemasukan & Pengeluaran ───────────────────────────────────────
  // List: hanya transaksi reguler, difilter search + tipe + kategori
  Widget _buildRegularTab(List<TransactionModel> allSorted,
      List<TransactionModel> regularList, bool isDark) {
    // Apply search + type + category filter
    final filtered = regularList.where((t) {
      // Type filter
      if (_typeFilter == 1 && t.type != TransactionType.income) return false;
      if (_typeFilter == 2 && t.type != TransactionType.expense) return false;
      // Category filter
      if (_categoryFilter != null && t.category != _categoryFilter)
        return false;
      // Search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery;
        if (!t.title.toLowerCase().contains(q) &&
            !t.category.toLowerCase().contains(q) &&
            !t.description.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    final isFiltering =
        _searchQuery.isNotEmpty || _typeFilter != 0 || _categoryFilter != null;

    if (regularList.isEmpty) {
      return _emptyState(isDark,
          icon: Icons.receipt_long_outlined,
          label: 'Belum ada pemasukan/pengeluaran');
    }

    if (filtered.isEmpty && isFiltering) {
      return _emptyState(isDark,
          icon: Icons.search_off_rounded,
          label: 'Tidak ada hasil',
          subtitle: 'Coba ubah kata kunci atau hapus filter');
    }

    // Group filtered by month
    final Map<String, List<TransactionModel>> grouped = {};
    for (final t in filtered) {
      final k = DateFormat('MMMM yyyy', 'id_ID').format(t.date).toUpperCase();
      grouped.putIfAbsent(k, () => []).add(t);
    }
    // Group ALL sorted by month (untuk summary header)
    final Map<String, List<TransactionModel>> allGrouped = {};
    for (final t in allSorted) {
      final k = DateFormat('MMMM yyyy', 'id_ID').format(t.date).toUpperCase();
      allGrouped.putIfAbsent(k, () => []).add(t);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
      itemCount: grouped.keys.length,
      itemBuilder: (context, i) {
        final monthKey = grouped.keys.elementAt(i);
        final monthTx = grouped[monthKey]!;
        final allMonthTx = allGrouped[monthKey] ?? monthTx;

        // Summary dari SEMUA (incl hutang & belanja)
        final totalIn = allMonthTx
            .where((t) => t.type == TransactionType.income)
            .fold(0.0, (s, t) => s + t.amount);
        final totalOut = allMonthTx
            .where((t) => t.type == TransactionType.expense)
            .fold(0.0, (s, t) => s + t.amount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(monthKey,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white60
                                    : Colors.teal.shade900,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            widget.miniHeaderStat(
                                'MASUK',
                                totalIn,
                                isDark
                                    ? Colors.greenAccent.shade400
                                    : Colors.green),
                            widget.miniHeaderStat(
                                'KELUAR',
                                totalOut,
                                isDark
                                    ? Colors.redAccent.shade200
                                    : Colors.red),
                            // ── Tombol ekspor per bulan ────────────────
                            GestureDetector(
                              onTap: () => widget.onExportMonth(
                                monthTx: allMonthTx,
                                monthLabel: monthKey,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: isDark ? 0.18 : 0.10),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.share_rounded,
                                        size: 13, color: AppColors.primary),
                                    SizedBox(width: 4),
                                    Text('EKSPOR',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ...monthTx.map((t) => widget.buildTransactionCard(t)),
          ],
        );
      },
    );
  }

  // ── Tab 2: Hutang/Piutang ────────────────────────────────────────────────
  Widget _buildHutangTab(List<TransactionModel> list, bool isDark) {
    if (list.isEmpty) {
      return _emptyState(isDark,
          icon: Icons.account_balance_wallet_outlined,
          label: 'Belum ada riwayat hutang/piutang',
          subtitle: 'Muncul saat hutang/piutang ditandai lunas');
    }

    final hutangOnly = list.where((t) => t.category == 'Hutang').toList();
    final piutangOnly = list.where((t) => t.category == 'Piutang').toList();
    final totalH = hutangOnly.fold(0.0, (s, t) => s + t.amount);
    final totalP = piutangOnly.fold(0.0, (s, t) => s + t.amount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
      children: [
        // Summary Minimalist (Style Masuk/Keluar)
        Container(
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Expanded(
                  child: _sumItemMinimalist(isDark,
                      label: 'HUTANG DIBAYAR',
                      amount: totalH,
                      color: Colors.red.shade400)),
              Container(
                  width: 1,
                  height: 30,
                  color: isDark ? Colors.white12 : Colors.grey.shade200),
              Expanded(
                  child: _sumItemMinimalist(isDark,
                      label: 'PIUTANG DITERIMA',
                      amount: totalP,
                      color: Colors.green.shade400)),
            ],
          ),
        ),
        if (hutangOnly.isNotEmpty) ...[
          _groupHeader('HUTANG TERBAYAR', Colors.red.shade400, isDark),
          const SizedBox(height: 10),
          ...hutangOnly.map((t) => _debtCard(t, isDark)),
          const SizedBox(height: 20),
        ],
        if (piutangOnly.isNotEmpty) ...[
          _groupHeader('PIUTANG DITERIMA', Colors.green.shade400, isDark),
          const SizedBox(height: 10),
          ...piutangOnly.map((t) => _debtCard(t, isDark)),
        ],
      ],
    );
  }

  // ── Tab 3: Belanja ───────────────────────────────────────────────────────
  Widget _buildBelanjaTab(List<TransactionModel> list, bool isDark) {
    if (list.isEmpty) {
      return _emptyState(isDark,
          icon: Icons.shopping_bag_outlined,
          label: 'Belum ada riwayat belanja',
          subtitle: 'Muncul saat item belanja ditandai dibeli');
    }

    final total = list.fold(0.0, (s, t) => s + t.amount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
      children: [
        // Summary Minimalist (Style Masuk/Keluar)
        Container(
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Expanded(
                  child: _sumItemMinimalist(isDark,
                      label: 'TOTAL BELANJA',
                      amount: total,
                      color: AppColors.primary)),
              Container(
                  width: 1,
                  height: 30,
                  color: isDark ? Colors.white12 : Colors.grey.shade200),
              Expanded(
                  child: _sumItemMinimalist(isDark,
                      label: 'JUMLAH ITEM',
                      amount: list.length.toDouble(),
                      isCurrency: false,
                      color: isDark ? Colors.white38 : Colors.black38)),
            ],
          ),
        ),
        ...list.map((t) => _shoppingCard(t, isDark)),
      ],
    );
  }

  // ── Shared Widgets ───────────────────────────────────────────────────────
  Widget _debtCard(TransactionModel t, bool isDark) {
    final isHutang = t.category == 'Hutang';
    final color = isHutang ? Colors.red.shade400 : Colors.green.shade400;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => widget.onTransactionTap(t),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13)),
                  child: Icon(
                      isHutang
                          ? Icons.call_made_rounded
                          : Icons.call_received_rounded,
                      color: color,
                      size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.title,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87)),
                      if (t.description.isNotEmpty)
                        Text(t.description,
                            style: TextStyle(
                                fontSize: 11,
                                color:
                                    isDark ? Colors.white38 : Colors.black38)),
                    ],
                  ),
                ),
                Text(_fmtCur(t.amount),
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _shoppingCard(TransactionModel t, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => widget.onTransactionTap(t),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(13)),
                  child: const Icon(Icons.shopping_bag_rounded,
                      color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(t.title,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87)),
                ),
                Text(_fmtCur(t.amount),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sumItemMinimalist(bool isDark,
      {required String label,
      required double amount,
      required Color color,
      bool isCurrency = true}) {
    return Column(children: [
      Text(label,
          style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: isDark ? Colors.white38 : Colors.black38)),
      const SizedBox(height: 5),
      Text(isCurrency ? _fmtCur(amount) : amount.toInt().toString(),
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: color)),
    ]);
  }

  Widget _groupHeader(String label, Color color, bool isDark) {
    return Row(children: [
      Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Text(label,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: isDark ? Colors.white38 : Colors.black38)),
    ]);
  }

  Widget _emptyState(bool isDark,
      {required IconData icon, required String label, String? subtitle}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle),
            child: Icon(icon,
                size: 60, color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 20),
          Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white38 : Colors.black38)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white24 : Colors.black26)),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final QuickActionType type;

  const _QuickAction(
      {required this.icon, required this.label, required this.type});
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
