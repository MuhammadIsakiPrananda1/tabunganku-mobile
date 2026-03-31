import 'dart:io';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tabunganku/main.dart' show flutterLocalNotificationsPlugin;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/models/saving_target_model.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/providers/family_group_provider.dart';
import 'package:tabunganku/features/friends/presentation/pages/family_group_page.dart';
import 'package:tabunganku/features/friends/presentation/widgets/name_setup_sheet.dart';
import 'package:tabunganku/providers/saving_target_provider.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _showBalance = true;
  bool _isAutoDeletingTarget = false;
  final PageController _targetPageController = PageController();
  int _currentTargetIndex = 0;
  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  Future<void> _deleteSavingTarget(String? targetId) async {
    if (targetId == null) return;
    await ref.read(savingTargetServiceProvider).deleteTarget(targetId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Target tabungan dihapus.')));
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.teal.shade700,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _showResetDataDialog(String userId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Data'),
        content: const Text(
            'Semua transaksi, target tabungan, dan saldo akan dihapus. Lanjutkan?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              // Hapus data target tabungan
              final targets =
                  await ref.read(savingTargetServiceProvider).getTargets();
              for (final t in targets) {
                await ref.read(savingTargetServiceProvider).deleteTarget(t.id);
              }
              // Hapus transaksi user
              await ref.read(transactionServiceProvider).clearAllTransactions();
              if (mounted) {
                setState(() {
                  _currentTargetIndex = 0;
                });
              }
              if (context.mounted) Navigator.pop(context);
              if (context.mounted)
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data berhasil direset.')));
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  // Pindahkan ke atas agar bisa direferensikan sebelum _buildProfileTab

  // Pindahkan ke atas agar bisa direferensikan
  // Primary Colors (Mint Fresh Edition)
  // Gunakan instance global dari main.dart

  int _currentIndex = 0;
  String? _loadedUserId;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadLocalData();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        // Optimization: Hanya update state lokal jika benar-benar diperlukan
        // Namun untuk kesederhanaan saat ini kita biarkan dulu, 
        // tapi kita pindahkan penggunaan waktunya ke widget yang lebih spesifik.
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _targetPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeUserId = 'default_user';
    if (_loadedUserId != activeUserId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadLocalData();
      });
    }

    // 1. Ambil semua transaksi pribadi (groupId == null)
    final personalTransactions = ref.watch(transactionsByGroupProvider(null));
    // 2. Wrap as AsyncValue for existing UI components
    final transactionsAsync = AsyncValue.data(personalTransactions);
    final transactions = List<TransactionModel>.from(personalTransactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    // 3. Sinkronisasi saldo keluarga secara terpisah (hanya jika dalam grup)
    final groupId = ref.watch(userGroupIdProvider);
    if (groupId != null && groupId.isNotEmpty) {
      // Listen ke perubahan transaksi khusus grup ini
      ref.listen(transactionsByGroupProvider(groupId), (previous, next) {
        final totalBalance = next.fold(0.0, (sum, t) => 
          sum + (t.type == TransactionType.income ? t.amount : -t.amount));
        ref.read(familyGroupServiceProvider).syncLocalBalance(totalBalance);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
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
                            fontWeight: FontWeight.w900, fontSize: 24)),
                  ),
                  if (_currentIndex != 3) ...[
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                            .format(_currentTime),
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.teal.shade700,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (_currentIndex != 3)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  DateFormat('HH:mm:ss').format(_currentTime),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(transactionsAsync, transactions),
          _buildFinanceTab(transactionsAsync, transactions),
          _buildHistoryTab(transactionsAsync, transactions),
          _buildProfileTab(transactions),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
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
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: const Icon(Icons.calculate_rounded,
                            color: Colors.white, size: 36),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kalkulator',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
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
    final userId = 'default_user';
    final prefs = await SharedPreferences.getInstance();

    // Migration logic for old single-target data
    final migrationKey =
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

  Widget _buildHomeTab(
    AsyncValue<List<TransactionModel>> transactionsAsync,
    List<TransactionModel> transactions,
  ) {
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final totalBalance = totalIncome - totalExpense;

    final targetsAsync = ref.watch(savingTargetsStreamProvider);
    final targets = targetsAsync.valueOrNull ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Main Finance Card (Consolidated)
          Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Dekorasi Lingkaran ala Splash (Keren & Modern - Warna Kontras)
                Positioned(
                  top: -40,
                  right: -30,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.amber.withValues(alpha: 0.15),
                          Colors.amber.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  left: -20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                        colors: [
                          Colors.lightBlue.withValues(alpha: 0.12),
                          Colors.lightBlue.withValues(alpha: 0.04),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 70,
                  left: -15,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber.withValues(alpha: 0.06),
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
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: Colors.teal.shade800.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                              width: 40), // Balanced with the visibility icon
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _showBalance ? _formatRupiah(totalBalance) : '••••••',
                                style: TextStyle(
                                  color: Colors.teal.shade900,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              _showBalance
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.teal.shade700.withOpacity(0.3),
                              size: 22,
                            ),
                            onPressed: () =>
                                setState(() => _showBalance = !_showBalance),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Stats Row Divider
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: Colors.teal.shade50.withOpacity(0.5),
                      ),
                      const SizedBox(height: 24),

                      // Stats Row within Card
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: _miniStat(
                                  'Pemasukan', totalIncome, Colors.green.shade600,
                                  center: true)),
                          const SizedBox(width: 24), // Added space before the line
                          Container(
                              width: 1.2,
                              height: 48, // Increased height for a "longer" look
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1),
                                color: Colors.teal.shade50,
                              )),
                          const SizedBox(width: 24), // Added space after the line
                          Expanded(
                              child: _miniStat(
                                  'Pengeluaran', totalExpense, Colors.red.shade600,
                                  center: true)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Primary Navigation / Actions
          Row(
            children: [
              Expanded(
                child: _buildToolAction(Icons.add_circle_outline_rounded,
                    'Pemasukan', _QuickActionType.income),
              ),
              Expanded(
                child: _buildToolAction(Icons.remove_circle_outline_rounded,
                    'Pengeluaran', _QuickActionType.expense),
              ),
              Expanded(
                child: _buildToolAction(Icons.track_changes_rounded, 'Target',
                    _QuickActionType.savingTarget),
              ),
              Expanded(
                child: _buildToolAction(Icons.family_restroom_rounded,
                    'Keluarga', _QuickActionType.family),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Primary Saving Target Card
          _buildSavingTargetSection(totalBalance, targets),

          const SizedBox(height: 40),

          // Integrated Allocation Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 20,
                    offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ALOKASI KEUANGAN',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.teal.shade800.withOpacity(0.4))),
                const SizedBox(height: 24),
                if (totalIncome == 0 && totalExpense == 0)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Icon(Icons.pie_chart_outline_rounded,
                              size: 48, color: Colors.teal.shade50),
                          const SizedBox(height: 12),
                          const Text('Belum ada data untuk dianalisis.',
                              style: TextStyle(
                                  color: Colors.black26,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      // Centered Pie Chart with Percentages
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 50,
                                sections: [
                                  if (totalIncome > 0)
                                    PieChartSectionData(
                                      color: Colors.green.shade400,
                                      value: totalIncome,
                                      title:
                                          '${(totalIncome / (totalIncome + totalExpense) * 100).toInt()}%',
                                      radius: 12,
                                      titleStyle: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.green.shade900),
                                      titlePositionPercentageOffset:
                                          2.2, // Significantly further outside
                                    ),
                                  if (totalExpense > 0)
                                    PieChartSectionData(
                                      color: Colors.red.shade400,
                                      value: totalExpense,
                                      title:
                                          '${(totalExpense / (totalIncome + totalExpense) * 100).toInt()}%',
                                      radius: 12,
                                      titleStyle: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.red.shade900),
                                      titlePositionPercentageOffset:
                                          2.2, // Significantly further outside
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Total',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade800
                                          .withOpacity(0.4))),
                              Text(
                                  _formatCompactRupiah(
                                      totalIncome + totalExpense),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Centered Indicators below
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCenteredIndicator(
                              'Pemasukan', totalIncome, Colors.green),
                          const SizedBox(width: 32),
                          _buildCenteredIndicator(
                              'Pengeluaran', totalExpense, Colors.red),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Recent Activity Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Aktivitas Terakhir',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: -0.5)),
              TextButton(
                onPressed: () => setState(() => _currentIndex = 2),
                child: const Text('Semua',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (transactionsAsync.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (transactions.isEmpty)
            const Text('Belum ada aktivitas',
                style: TextStyle(color: Colors.black38, fontSize: 13))
          else
            ...transactions.take(3).map((t) => _minimalTile(t)),

          const SizedBox(height: 60),

          // Subtle Watermark
          Center(
            child: Opacity(
              opacity: 0.25,
              child: Column(
                children: [
                  const Text(
                    'NEVERLAND STUDIO',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Edisi Mint Fresh v1.2.0',
                      style: TextStyle(fontSize: 8, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, double amount, Color color,
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
                color: Colors.grey.shade500,
                letterSpacing: 1.2)),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _showBalance ? _formatRupiah(amount) : '••••',
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: color.withOpacity(0.8)),
          ),
        ),
      ],
    );
  }

  Widget _buildToolAction(IconData icon, String label, _QuickActionType type) {
    return GestureDetector(
      onTap: () => _handleQuickActionTap(
          _QuickAction(icon: icon, label: label, type: type)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.teal.shade900.withValues(alpha: 0.7),
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _minimalTile(TransactionModel t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (t.type == TransactionType.expense
                      ? Colors.red
                      : Colors.green)
                  .withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              t.type == TransactionType.expense
                  ? Icons.remove_rounded
                  : Icons.add_rounded,
              color:
                  t.type == TransactionType.expense ? Colors.red : Colors.green,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                Text(DateFormat('dd MMM').format(t.date),
                    style:
                        TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Text(
            '${t.type == TransactionType.expense ? '- ' : '+ '}${_formatRupiah(t.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: t.type == TransactionType.expense
                  ? Colors.red.shade700
                  : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingTargetSection(
      double totalBalance, List<SavingTargetModel> targets) {
    if (targets.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.track_changes_rounded,
                color: Colors.teal.shade100, size: 48),
            const SizedBox(height: 16),
            const Text('Belum Ada Target',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Mulai menabung untuk impian Anda',
                style: TextStyle(color: Colors.black38, fontSize: 13)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showSavingTargetDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
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
          height: 260, // Fixed height for carousel
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

              // Celebration logic per target
              if (progress >= 1.0 && !_isAutoDeletingTarget) {
                // We only show snackbar once per session/target if needed
                // For now, keep it simple UI
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
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
                          Text('TARGET TABUNGAN #${index + 1}',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: Colors.teal.shade800.withOpacity(0.4),
                              )),
                          GestureDetector(
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  title: const Text('Hapus Target?'),
                                  content:
                                      Text('Hapus target "${target.name}"?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Batal')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Hapus',
                                            style:
                                                TextStyle(color: Colors.red))),
                                  ],
                                ),
                              );
                              if (confirm == true)
                                await _deleteSavingTarget(target.id);
                            },
                            child: Icon(Icons.delete_outline_rounded,
                                color: Colors.red.shade200, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(target.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                    color: Colors.teal.shade900,
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
                                      fontWeight: FontWeight.w900)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            Container(height: 12, color: Colors.teal.shade50),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 1200),
                              curve: Curves.easeOutBack,
                              height: 12,
                              width: (MediaQuery.of(context).size.width - 88) *
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
                                        .withOpacity(0.4),
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
                    : AppColors.primary.withOpacity(0.2),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color.withOpacity(0.6)),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black38)),
          ],
        ),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Colors.teal.shade900)),
      ],
    );
  }

  Future<void> _handleQuickActionTap(_QuickAction action) async {
    switch (action.type) {
      case _QuickActionType.expense:
        await _showManualTransactionSheet(TransactionType.expense);
        break;
      case _QuickActionType.income:
        await _showManualTransactionSheet(TransactionType.income);
        break;
      case _QuickActionType.savingTarget:
        await _showSavingTargetDialog();
        break;
      case _QuickActionType.calculator:
        _showCalculatorSheet();
        break;
      case _QuickActionType.history:
        setState(() => _currentIndex = 2);
        break;
      case _QuickActionType.family:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FamilyGroupPage(),
          ),
        );
        break;
    }
  }

  void _showCalculatorSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CalculatorSheetContent(),
    );
  }

  Future<void> _showManualTransactionSheet(TransactionType type) async {
    final amountController = TextEditingController();
    final nameController = TextEditingController();
    final customCategoryController = TextEditingController();
    var selectedCategory = type == TransactionType.expense ? 'Makan' : 'Gaji';
    var noteText = '';

    final List<Map<String, dynamic>> categories = type == TransactionType.income
        ? [
            {'label': 'Gaji', 'icon': Icons.payments_rounded},
            {'label': 'Jualan', 'icon': Icons.storefront_rounded},
            {'label': 'Bonus', 'icon': Icons.redeem_rounded},
            {'label': 'Hadiah', 'icon': Icons.card_giftcard_rounded},
            {'label': 'Investasi', 'icon': Icons.trending_up_rounded},
            {'label': 'Tabungan', 'icon': Icons.savings_rounded},
            {'label': 'Lainnya', 'icon': Icons.more_horiz_rounded},
          ]
        : [
            {'label': 'Makan', 'icon': Icons.restaurant_rounded},
            {'label': 'Transport', 'icon': Icons.directions_bus_rounded},
            {'label': 'Belanja', 'icon': Icons.shopping_bag_rounded},
            {'label': 'Tagihan', 'icon': Icons.receipt_rounded},
            {'label': 'Hiburan', 'icon': Icons.movie_rounded},
            {'label': 'Kopi', 'icon': Icons.coffee_rounded},
            {'label': 'Kesehatan', 'icon': Icons.medical_services_rounded},
            {'label': 'Pendidikan', 'icon': Icons.school_rounded},
            {'label': 'Hobi', 'icon': Icons.sports_esports_rounded},
            {'label': 'Cicilan', 'icon': Icons.credit_card_rounded},
            {'label': 'Zakat', 'icon': Icons.volunteer_activism_rounded},
            {'label': 'Keperluan Rumah', 'icon': Icons.home_work_rounded},
            {'label': 'Pulsa/Data', 'icon': Icons.tap_and_play_rounded},
            {'label': 'Lainnya', 'icon': Icons.more_horiz_rounded},
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
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(bottom: inset),
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
                            color: Colors.grey.shade300,
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
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                                color: Colors.teal.shade900),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Rp ',
                              style: TextStyle(
                                fontSize:
                                    amountController.text.length > 10 ? 24 : 32,
                                fontWeight: FontWeight.w900,
                                color: type == TransactionType.income
                                    ? Colors.green.shade200
                                    : Colors.red.shade200,
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: amountController,
                                autofocus: true,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: amountController.text.length > 18
                                        ? 24
                                        : amountController.text.length > 14
                                            ? 32
                                            : amountController.text.length > 10
                                                ? 40
                                                : 48,
                                    fontWeight: FontWeight.w900,
                                    color: type == TransactionType.income
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                    letterSpacing: -1.5),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  _RibuanSeparatorInputFormatter(),
                                ],
                                onChanged: (val) => setSheetState(() {}),
                                decoration: InputDecoration(
                                  hintText: '0',
                                  hintStyle: TextStyle(
                                      fontSize: 45,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.teal.shade50),
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: nameController,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                labelText: 'Keterangan Transaksi',
                                hintText: 'Input Keterangan',
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade200)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade200)),
                                prefixIcon: const Icon(Icons.edit_note_rounded,
                                    color: Colors.teal),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text('PILIH KATEGORI',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color:
                                        Colors.teal.shade800.withOpacity(0.4),
                                    letterSpacing: 1.2)),
                            const SizedBox(height: 24),
                            DropdownButtonFormField<String>(
                              value: selectedCategory,
                              decoration: InputDecoration(
                                labelText: 'Pilih Kategori',
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade200)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade200)),
                                prefixIcon: Icon(
                                  categories.firstWhere((c) =>
                                      c['label'] ==
                                      selectedCategory)['icon'] as IconData,
                                  color: Colors.teal,
                                ),
                              ),
                              selectedItemBuilder: (context) {
                                return categories.map((cat) {
                                  return Text(
                                    cat['label'] as String,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
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
                                      Text(cat['label'] as String),
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
                                decoration: InputDecoration(
                                  labelText: 'Kategori Kustom',
                                  hintText: 'Misal: Sedekah, Investasi...',
                                  filled: true,
                                  fillColor:
                                      Colors.amber.shade50.withOpacity(0.2),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                          color: Colors.amber.shade100)),
                                  prefixIcon: const Icon(Icons.star_rounded,
                                      color: Colors.amber),
                                ),
                              ),
                            ],
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: () async {
                                final amount = _toAmount(amountController.text);
                                if (amount == null || amount <= 0) {
                                  ScaffoldMessenger.of(sheetContext)
                                      .showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Nominal transaksi tidak valid.')),
                                  );
                                  return;
                                }

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
                                );

                                await ref
                                    .read(transactionServiceProvider)
                                    .addTransaction(tx);
                                if (sheetContext.mounted)
                                  Navigator.pop(sheetContext);
                                if (mounted) {
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
                                shadowColor: AppColors.primary.withOpacity(0.4),
                              ),
                              child: const Text('Simpan Transaksi',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
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
            );
          },
        );
      },
    );
  }

  Future<void> _showSavingTargetDialog() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Daftar Target',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 20)),
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
                          return const Center(child: Text('Belum ada target.'));
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: targets.length,
                          itemBuilder: (context, index) {
                            final t = targets[index];
                            return ListTile(
                              leading: const CircleAvatar(
                                  child: Icon(Icons.track_changes_rounded)),
                              title: Text(t.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  'Target: ${_formatRupiah(t.targetAmount)}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit_rounded, size: 20),
                                onPressed: () =>
                                    _showAddEditTargetDialog(target: t),
                              ),
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

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
              title: Text(isEdit ? 'Edit Target' : 'Target Baru',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 22)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NOMINAL TARGET',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.black38,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountController,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _RibuanSeparatorInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        hintText: '0',
                        prefixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 16),
                            const Icon(Icons.account_balance_wallet_rounded,
                                color: Colors.teal, size: 20),
                            const SizedBox(width: 8),
                            const Text('Rp',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                    fontSize: 16)),
                            const SizedBox(width: 8),
                          ],
                        ),
                        filled: true,
                        fillColor: Colors.teal.shade50.withOpacity(0.3),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('TARGET PEMBELIAN',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.black38,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: itemController,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: 'Contoh: Laptop, Motor, HP...',
                        filled: true,
                        fillColor: Colors.teal.shade50.withOpacity(0.3),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.shopping_bag_rounded,
                            color: Colors.teal, size: 20),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('TANGGAL TARGET SELESAI',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.black38,
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
                                colorScheme: ColorScheme.light(
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
                          color: Colors.teal.shade50.withOpacity(0.3),
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: Colors.grey.shade50,
                        ),
                        child: Text('Batal',
                            style: TextStyle(
                                color: Colors.grey.shade600,
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
                                    content:
                                        Text('Mohon lengkapi data dengan benar.')));
                            return;
                          }

                          final userId = 'default_user';
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
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
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

                          if (dialogContext.mounted) Navigator.pop(dialogContext);
                          if (isEdit && mounted)
                            Navigator.pop(context); // Close management sheet if edit
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
    if (transactionsAsync.isLoading)
      return const Center(child: CircularProgressIndicator());

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
    final dailyAllowance = totalBalance > 0 ? totalBalance / remainingDays : 0.0;
    final savingsRate = totalIncome > 0 ? ((totalBalance / totalIncome) * 100) : 0.0;
    
    String healthStatus = "Boros";
    Color healthColor = Colors.redAccent.shade200;
    IconData healthIcon = Icons.warning_amber_rounded;
    if (savingsRate >= 50) {
      healthStatus = "SANGAT HEMAT";
      healthColor = Colors.greenAccent.shade400;
      healthIcon = Icons.verified_rounded;
    } else if (savingsRate >= 20) {
      healthStatus = "WAJAR / STABIL";
      healthColor = Colors.orangeAccent.shade200;
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.02),
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
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.teal.shade800.withOpacity(0.4))),
                const SizedBox(height: 8),
                Text(_formatRupiah(totalIncome - totalExpense),
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.teal.shade900,
                        letterSpacing: -1)),
                const SizedBox(height: 4),
                Text(DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now()),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700)),
                const SizedBox(height: 24),

                // Premium Wealth Trend Chart (Scrollable Line Chart)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding: const EdgeInsets.only(top: 24, right: 24, left: 16, bottom: 8),
                    height: 220,
                    width: math.max(MediaQuery.of(context).size.width - 88, trendData.length * 45.0),
                    child: LineChart(
                      LineChartData(
                        minX: -0.5,
                        maxX: trendData.length - 0.5,
                        minY: 0,
                        maxY: trendData.fold<double>(0, (max, d) {
                              final val = d['income'] > d['expense'] ? d['income'] : d['expense'];
                              return val > max ? val : max;
                            }) * 1.5,
                        lineTouchData: LineTouchData(
                          getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                            return spotIndexes.map((index) {
                              return TouchedSpotIndicatorData(
                                FlLine(color: barData.color?.withOpacity(0.4), strokeWidth: 2, dashArray: [4, 4]),
                                FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                    radius: 6,
                                    color: barData.color ?? Colors.teal,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: Colors.teal.shade900.withOpacity(0.9),
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final d = trendData[spot.x.toInt()];
                                final isIncome = spot.bar.color == Colors.green.shade400;
                                final val = isIncome ? d['income'] : d['expense'];
                                return LineTooltipItem(
                                  "${isIncome ? '+' : '-'}${_formatCompactRupiah(val)}",
                                  TextStyle(
                                      color: isIncome ? Colors.greenAccent.shade400 : Colors.redAccent.shade400,
                                      fontWeight: FontWeight.w900,
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
                                if (value != value.toInt()) return const SizedBox.shrink();
                                final index = value.toInt();
                                if (index < 0 || index >= trendData.length) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    trendData[index]['label'],
                                    style: TextStyle(
                                      color: Colors.teal.shade800.withOpacity(0.4),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          drawHorizontalLine: true,
                          verticalInterval: 1,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.teal.shade50.withOpacity(0.3),
                            strokeWidth: 1,
                            dashArray: [5, 5],
                          ),
                          getDrawingVerticalLine: (value) => FlLine(
                            color: Colors.teal.shade50.withOpacity(0.3),
                            strokeWidth: 1,
                            dashArray: [5, 5],
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: trendData.map((d) => FlSpot(d['index'] as double, d['income'] as double)).toList(),
                            isCurved: false,
                            color: Colors.green.shade400,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.green.shade400.withOpacity(0.15),
                            ),
                          ),
                          LineChartBarData(
                            spots: trendData.map((d) => FlSpot(d['index'] as double, d['expense'] as double)).toList(),
                            isCurved: false,
                            color: Colors.red.shade400,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.red.shade400.withOpacity(0.15),
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
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: Colors.teal.shade800.withOpacity(0.15)))),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Total Stats Center Row
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 20,
                    offset: const Offset(0, 10))
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _miniStat('Total Pemasukan', totalIncome, Colors.green),
                Container(width: 1, height: 32, color: Colors.teal.shade50),
                _miniStat('Total Pengeluaran', totalExpense, Colors.red),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // INSIGHT KEUANGAN (NEW FEATURE)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.teal.shade900, Colors.teal.shade800],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
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
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: Colors.white.withOpacity(0.5))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: healthColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(healthIcon, size: 10, color: healthColor),
                          const SizedBox(width: 4),
                          Text(healthStatus,
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
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
                                  fontWeight: FontWeight.w900)),
                          Text('Sisa $remainingDays hari bulan ini',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
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
                        border: Border.all(color: Colors.white.withOpacity(0.1), width: 4),
                      ),
                      child: Center(
                        child: Text('${savingsRate.toInt()}%',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Container(height: 6, color: Colors.white.withOpacity(0.1)),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 1000),
                        height: 6,
                        width: (MediaQuery.of(context).size.width - 110) * (savingsRate / 100).clamp(0, 1),
                        decoration: BoxDecoration(
                          color: healthColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: healthColor.withOpacity(0.5), blurRadius: 10)
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
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Integrated Allocation Section dipindah ke _buildHomeTab
        ],
      ),
    );
  }

  Widget _buildCenteredIndicator(String label, double amount, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.6), shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black45)),
          ],
        ),
        const SizedBox(height: 4),
        Text(_formatCompactRupiah(amount),
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  Widget _buildHistoryTab(
    AsyncValue<List<TransactionModel>> transactionsAsync,
    List<TransactionModel> transactions,
  ) {
    if (transactionsAsync.isLoading)
      return const Center(child: CircularProgressIndicator());
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded,
                size: 64, color: Colors.teal.shade50),
            const SizedBox(height: 16),
            const Text('Belum ada riwayat transaksi.',
                style: TextStyle(
                    color: Colors.black26, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    // Grouping by Month
    final Map<String, List<TransactionModel>> monthlyGrouped = {};
    for (var t in transactions) {
      final monthKey =
          DateFormat('MMMM yyyy', 'id_ID').format(t.date).toUpperCase();
      if (!monthlyGrouped.containsKey(monthKey)) monthlyGrouped[monthKey] = [];
      monthlyGrouped[monthKey]!.add(t);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
      itemCount: monthlyGrouped.length,
      itemBuilder: (context, index) {
        final monthLabel = monthlyGrouped.keys.elementAt(index);
        final monthTransactions = monthlyGrouped[monthLabel]!;

        // Calculate monthly totals
        final monthIncome = monthTransactions
            .where((t) => t.type == TransactionType.income)
            .fold<double>(0, (s, t) => s + t.amount);
        final monthExpense = monthTransactions
            .where((t) => t.type == TransactionType.expense)
            .fold<double>(0, (s, t) => s + t.amount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Header with Summary
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(monthLabel,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Colors.teal.shade900,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _miniHeaderStat('MASUK', monthIncome, Colors.green),
                            const SizedBox(width: 12),
                            _miniHeaderStat('KELUAR', monthExpense, Colors.red),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildPdfDownloadButton(monthLabel, monthTransactions),
                ],
              ),
            ),
            ...monthTransactions.map((t) => _buildTransactionCard(t)),
          ],
        );
      },
    );
  }

  Widget _miniHeaderStat(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ',
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          Text(_formatCompactRupiah(amount),
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: color.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel t) {
    final isExpense = t.type == TransactionType.expense;

    // Simplified Icons for History
    final IconData catIcon =
        isExpense ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    final Color catColor = isExpense ? Colors.red : Colors.green;

    return GestureDetector(
      onTap: () => _showTransactionDetailSheet(t),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.015),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.08),
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
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Colors.teal.shade900)),
                  const SizedBox(height: 2),
                  Text(
                      '${DateFormat('EEEE, dd MMM', 'id_ID').format(t.date)} • ${DateFormat('HH:mm', 'id_ID').format(t.date)}',
                      style: const TextStyle(
                          color: Colors.black26,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Text(
              '${isExpense ? '- ' : '+ '}${_formatRupiah(t.amount)}',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color:
                      isExpense ? Colors.red.shade400 : Colors.green.shade400),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTransactionDetailSheet(TransactionModel t) async {
    final isExpense = t.type == TransactionType.expense;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 32),

            // Receipt Header
            Text(isExpense ? 'PENGELUARAN' : 'PEMASUKAN',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: isExpense ? Colors.red : Colors.green)),
            const SizedBox(height: 12),
            Text(_formatRupiah(t.amount),
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.teal.shade900,
                    letterSpacing: -1)),
            const SizedBox(height: 32),

            // Punched paper line simulation
            Row(
              children: List.generate(
                  30,
                  (index) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: 1,
                          color: Colors.grey.shade200,
                        ),
                      )),
            ),
            const SizedBox(height: 32),

            // Receipt Details
            _buildReceiptRow(
                'Waktu',
                DateFormat('EEEE, dd MMMM yyyy • HH:mm', 'id_ID')
                    .format(t.date)),
            const SizedBox(height: 16),
            _buildReceiptRow('Kategori', t.category),
            const SizedBox(height: 16),
            _buildReceiptRow('Keterangan', t.title),
            const SizedBox(height: 48),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditTransactionSheet(t);
                    },
                    icon: const Icon(Icons.edit_document, size: 18),
                    label: const Text('Edit Nominal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue.shade700,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDeleteTransaction(t);
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Hapus'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red.shade700,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800.withOpacity(0.3))),
        ),
        Expanded(
          child: Text(value,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.teal.shade900)),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteTransaction(TransactionModel t) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus Transaksi?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Yakin ingin menghapus ${t.title}? Langkah ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
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

  Widget _buildProfileTab(List<TransactionModel> transactions) {
    final profile = ref.watch(userProfileProvider);
    final userName = profile.name;
    final totalTransactions = transactions.length;
    
    // Calculate total balance for the summary card
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final currentBalance = totalIncome - totalExpense;

    final userId = 'default_user';

    // Avatar configuration
    final avatarIcons = [
      Icons.person_rounded,
      Icons.face_rounded,
      Icons.emoji_emotions_rounded,
      Icons.pets_rounded,
      Icons.rocket_launch_rounded,
      Icons.castle_rounded,
      Icons.military_tech_rounded,
      Icons.star_rounded,
    ];

    final avatarColors = [
      AppColors.primary,
      Colors.blue.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.pink.shade600,
      Colors.cyan.shade600,
      Colors.indigo.shade600,
      Colors.teal.shade700,
    ];

    final selectedIcon = avatarIcons[profile.avatarIndex % avatarIcons.length];
    final selectedColor = avatarColors[profile.colorIndex % avatarColors.length];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      child: Column(
        children: [
          const SizedBox(height: 12),
          
          // Profile Header Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    GestureDetector(
                      onTap: () => _showAvatarSelectionSheet(profile, avatarIcons, avatarColors),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [selectedColor, selectedColor.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: selectedColor.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            selectedIcon,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showAvatarSelectionSheet(profile, avatarIcons, avatarColors),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 16, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  userName.isEmpty ? 'Pengguna TabunganKu' : userName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.teal.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Member (Free)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildSimpleStatCard(
                        'Total Transaksi',
                        totalTransactions.toString(),
                        Icons.receipt_long_rounded,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSimpleStatCard(
                        'Saldo Aktif',
                        _formatCompactRupiah(currentBalance),
                        Icons.account_balance_wallet_rounded,
                        Colors.teal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Group: Pengaturan
          _sectionHeader('PENGATURAN & KEUANGAN'),

          _profileMenuCard(
            icon: Icons.person_outline_rounded,
            title: 'Ubah Nama Panggilan',
            subtitle: 'Ganti nama tampilan kamu',
            onTap: () => showNameSetupSheet(context),
            color: Colors.orange.shade400,
          ),
          _profileMenuCard(
            icon: Icons.picture_as_pdf_rounded,
            title: 'Laporan PDF Bulanan',
            subtitle: 'Akses rekap dari tab Riwayat',
            onTap: () async {
              // Add a small delay to let the ripple animation finish beautifully
              await Future.delayed(const Duration(milliseconds: 150));
              if (mounted) setState(() => _currentIndex = 2);
            },
            color: Colors.blue.shade600,
          ),
          _profileMenuCard(
            icon: Icons.notifications_none_rounded,
            title: 'Pengingat Harian',
            subtitle: 'Aktifkan notifikasi menabung',
            onTap: () => _showSuccess('Fitur pengingat sedang dalam pengembangan!'),
            color: Colors.purple.shade400,
          ),

          const SizedBox(height: 24),
          _sectionHeader('APLIKASI'),

          _profileMenuCard(
            icon: Icons.info_outline_rounded,
            title: 'Tentang TabunganKu',
            subtitle: 'Informasi aplikasi & Versi v1.2.0',
            onTap: () => _showAboutAppDialog(),
            color: Colors.teal.shade600,
          ),
          _profileMenuCard(
            icon: Icons.refresh_rounded,
            title: 'Reset Seluruh Data',
            subtitle: 'Hapus data & mulai dari nol',
            onTap: userId.isEmpty ? null : () => _showResetDataDialog(userId),
            color: Colors.red.shade400,
          ),

          const SizedBox(height: 48),

          // Neverland Signature
          Opacity(
            opacity: 0.3,
            child: Column(
              children: [
                Text('HANDCRAFTED BY',
                    style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.teal.shade900)),
                const SizedBox(height: 4),
                Text('NEVERLAND STUDIO',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: Colors.teal.shade900)),
                const SizedBox(height: 8),
                const Text('Versi 1.2.0 (Global Release)',
                    style:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showAvatarSelectionSheet(UserProfile profile, List<IconData> icons, List<Color> colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Pilih Foto Profil',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            const Text('Ikon Kamu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: icons.length,
                itemBuilder: (context, index) {
                  final isSelected = profile.avatarIndex == index;
                  return GestureDetector(
                    onTap: () => ref.read(userProfileProvider.notifier).updateProfile(avatarIndex: index),
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
                      ),
                      child: Icon(icons[index], color: isSelected ? AppColors.primary : Colors.grey, size: 28),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
            const Text('Warna Tema', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  final isSelected = profile.colorIndex == index;
                  return GestureDetector(
                    onTap: () => ref.read(userProfileProvider.notifier).updateProfile(colorIndex: index),
                    child: Container(
                      width: 50,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: colors[index],
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.white, width: 4) : null,
                        boxShadow: isSelected ? [BoxShadow(color: colors[index].withOpacity(0.4), blurRadius: 10)] : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Simpan Foto', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black38)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.teal.shade900)),
        ],
      ),
    );
  }



  Widget _buildPdfDownloadButton(
      String monthLabel, List<TransactionModel> transactions) {
    final bool isComplete = _isMonthComplete(monthLabel);

    return Column(
      children: [
        IconButton(
          onPressed: isComplete
              ? () => _generateAndOpenMonthlyPdf(monthLabel, transactions)
              : null,
          icon: Icon(
            isComplete
                ? Icons.picture_as_pdf_rounded
                : Icons.lock_clock_rounded,
            color: isComplete ? Colors.blue.shade600 : Colors.grey.shade300,
            size: 28,
          ),
          tooltip: isComplete ? 'Unduh Rekap PDF' : 'Belum Tersedia',
        ),
        Text(
          isComplete ? 'UNDUH' : 'TUNGGU',
          style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: isComplete ? Colors.blue.shade700 : Colors.grey.shade400,
              letterSpacing: 0.5),
        )
      ],
    );
  }

  bool _isMonthComplete(String monthLabel) {
    try {
      // monthLabel is like "MARET 2024"
      final date = DateFormat('MMMM yyyy', 'id_ID').parse(monthLabel);
      final now = DateTime.now();

      // If the current year is greater, it's definitely complete
      if (now.year > date.year) return true;
      // If same year, month must be strictly less than current month
      if (now.year == date.year && now.month > date.month) return true;

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _generateAndOpenMonthlyPdf(
      String monthLabel, List<TransactionModel> transactions) async {
    final pdf = pw.Document();

    // Sort transactions by date (newest first for the report)
    final sortedTransactions = List<TransactionModel>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (s, t) => s + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (s, t) => s + t.amount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('TabunganKu',
                        style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.teal900)),
                    pw.Text('Rekap Transaksi Bulanan',
                        style: const pw.TextStyle(
                            fontSize: 12, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(monthLabel,
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                        'Dicetak: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.teal50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(
                  children: [
                    pw.Text('TOTAL PEMASUKAN',
                        style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green)),
                    pw.Text(_formatRupiah(totalIncome),
                        style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text('TOTAL PENGELUARAN',
                        style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red)),
                    pw.Text(_formatRupiah(totalExpense),
                        style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text('SALDO BERSIH',
                        style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue)),
                    pw.Text(_formatRupiah(totalIncome - totalExpense),
                        style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 32),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.teal900),
            cellHeight: 30,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerRight,
            },
            headers: ['Tanggal', 'Kategori', 'Keterangan', 'Nominal'],
            data: sortedTransactions.map((t) {
              return [
                DateFormat('dd/MM/yy').format(t.date),
                t.category,
                t.title,
                '${t.type == TransactionType.expense ? "-" : "+"} ${_formatRupiah(t.amount)}',
              ];
            }).toList(),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 48),
            child: pw.Center(
              child: pw.Text(
                  'Laporan ini dihasilkan otomatis oleh aplikasi TabunganKu.',
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey500)),
            ),
          ),
        ],
      ),
    );

    try {
      final output = await getTemporaryDirectory();
      final file =
          File("${output.path}/Rekap_${monthLabel.replaceAll(' ', '_')}.pdf");
      await file.writeAsBytes(await pdf.save());

      await OpenFilex.open(file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan PDF: $e')),
        );
      }
    }
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Colors.teal.shade800.withOpacity(0.4))),
      ),
    );
  }

  Widget _profileMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Color? color,
  }) {
    final themeColor = color ?? AppColors.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
              color: themeColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18)),
          child: Icon(icon, color: themeColor, size: 24),
        ),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: Colors.teal.shade900)),
        subtitle: Text(subtitle,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black38)),
        trailing: const Icon(Icons.chevron_right_rounded,
            size: 20, color: Colors.black12),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = _currentIndex == index;
    final item = _navItems[index];
    final color = isSelected ? AppColors.primary : const Color(0xFF94A3B8);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
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
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: color,
                letterSpacing: 0.2,
              ),
            ),
          ],
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
    if (value >= 1000000000)
      return 'Rp ${(value / 1000000000).toStringAsFixed(1)} M';
    if (value >= 1000000)
      return 'Rp ${(value / 1000000).toStringAsFixed(1)} jt';
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
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
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(2))),
                      const Text('Edit Nominal',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87)),
                      const SizedBox(height: 12),
                      Text(t.title,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade800.withOpacity(0.4))),
                      const SizedBox(height: 24),

                      // Amount Input
                      TextFormField(
                        controller: amountController,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _RibuanSeparatorInputFormatter()
                        ],
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w900),
                        decoration: InputDecoration(
                          labelText: 'Input Nominal Baru',
                          prefixText: 'Rp ',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16)),
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
                            if (finalAmount == null || finalAmount <= 0) return;

                            final updated = t.copyWith(
                              amount: finalAmount,
                            );

                            await ref
                                .read(transactionServiceProvider)
                                .updateTransaction(updated);

                            if (mounted) {
                              if (Navigator.canPop(sheetContext)) {
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

  void _showAboutAppDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.stars_rounded, color: Colors.teal.shade600),
            ),
            const SizedBox(width: 16),
            const Text('TabunganKu',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aplikasi manajemen keuangan pribadi yang cerdas untuk membantu kamu mencapai target finansial dengan lebih mudah.',
              style: TextStyle(height: 1.5, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            _aboutInfoRow('Versi', '1.2.0+3'),
            _aboutInfoRow('Build', 'Global Release'),
            _aboutInfoRow('Developer', 'Neverland Studio'),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                '© 2026 Neverland Studio. All rights reserved.',
                style: TextStyle(fontSize: 10, color: Colors.black26),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup',
                style: TextStyle(
                    color: Colors.teal.shade700, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _aboutInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black38)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: Colors.teal.shade900)),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final _QuickActionType type;

  const _QuickAction(
      {required this.icon, required this.label, required this.type});
}

enum _QuickActionType { expense, income, savingTarget, calculator, history, family }

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}

const List<_NavItem> _navItems = [
  _NavItem(icon: Icons.home_rounded, label: 'Beranda'),
  _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Keuangan'),
  _NavItem(icon: Icons.receipt_long_rounded, label: 'Riwayat'),
  _NavItem(icon: Icons.person_outline_rounded, label: 'Profil'),
];

class _RibuanSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');

    final formatted = digits.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );

    return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length));
  }
}

class _CalculatorSheetContent extends StatefulWidget {
  const _CalculatorSheetContent();

  @override
  State<_CalculatorSheetContent> createState() =>
      _CalculatorSheetContentState();
}

class _CalculatorSheetContentState extends State<_CalculatorSheetContent> {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2)),
          ),
          // Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_expression,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.teal.shade800.withOpacity(0.4),
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Text(
                    _formatDisplay(_output),
                    style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.teal.shade900,
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
              _calcButton("AC", isAction: true),
              _calcButton("+/-", isAction: true),
              _calcButton("%", isAction: true),
              _calcButton("÷", isOperator: true),
              _calcButton("7"),
              _calcButton("8"),
              _calcButton("9"),
              _calcButton("×", isOperator: true),
              _calcButton("4"),
              _calcButton("5"),
              _calcButton("6"),
              _calcButton("-", isOperator: true),
              _calcButton("1"),
              _calcButton("2"),
              _calcButton("3"),
              _calcButton("+", isOperator: true),
              _calcButton("C"),
              _calcButton("0"),
              _calcButton(","),
              _calcButton("=", isOperator: true, isPrimary: true),
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
      bool isPrimary = false}) {
    Color bgColor = Colors.white;
    Color textColor = Colors.teal.shade900;

    if (isOperator) {
      bgColor = isPrimary ? AppColors.primary : Colors.teal.shade50;
      textColor = isPrimary ? Colors.white : AppColors.primary;
    } else if (isAction) {
      bgColor = Colors.grey.shade50;
      textColor = Colors.teal.shade700;
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
                color: Colors.teal.shade50.withOpacity(0.5), width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

// --- DATA MODELS ---
class _ScoreCandidate {
  final double amount;
  final int score;
  _ScoreCandidate({required this.amount, required this.score});
}
