import 'dart:io';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:tabunganku/main.dart' show flutterLocalNotificationsPlugin;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/models/saving_target_model.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/providers/family_group_provider.dart';
import 'package:tabunganku/features/transaction/presentation/widgets/transaction_detail_sheet.dart';
import 'package:tabunganku/features/friends/presentation/pages/family_group_page.dart';
import 'package:tabunganku/features/friends/presentation/widgets/name_setup_sheet.dart';
import 'package:tabunganku/providers/saving_target_provider.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tabunganku/features/transaction/presentation/pages/debt_list_page.dart';
import 'package:tabunganku/features/shopping/presentation/pages/shopping_list_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _showBalance = true;
  final PageController _targetPageController = PageController();
  int _currentTargetIndex = 0;
  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  // Pengaturan Pengingat Harian
  bool _reminderEnabled = false;
  int _reminderHour = 19; // Default 19:00
  int _reminderMinute = 0;

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
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Reset Data',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87)),
        content: Text(
            'Semua transaksi, target tabungan, dan saldo akan dihapus. Lanjutkan?',
            style:
                TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal',
                  style: TextStyle(
                      color: isDarkMode ? Colors.white24 : Colors.grey))),
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
              if (ctx.mounted) {
                Navigator.pop(ctx);
                _showSuccess('Data berhasil direset.');
              }
            },
            child: const Text('Reset',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
                            color: isDarkMode
                                ? Colors.white70
                                : Colors.teal.shade700,
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
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
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

    // Load Daily Reminder Settings
    setState(() {
      _reminderEnabled =
          prefs.getBool('daily_reminder_enabled_$userId') ?? false;
      _reminderHour = prefs.getInt('daily_reminder_hour_$userId') ?? 19;
      _reminderMinute = prefs.getInt('daily_reminder_minute_$userId') ?? 0;

      // Reschedule saat app dibuka agar alarm tetap segar dan sinkron dengan timezone terbaru
      if (_reminderEnabled) {
        _scheduleDailyReminder(_reminderHour, _reminderMinute);
      }
    });
  }

  // --- Daily Reminder Logic ---

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> _scheduleDailyReminder(int hour, int minute) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'daily_reminder_channel_v2',
      'Daily Reminder',
      channelDescription: 'Pengingat menabung harian',
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
      playSound: true,
    );
    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        999, // Unique ID for daily reminder
        'Waktunya Menabung! 💰',
        'Jangan lupa catat pengeluaran dan pemasukanmu hari ini ya supaya target makin dekat!',
        _nextInstanceOfTime(hour, minute),
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('Daily reminder scheduled for $hour:$minute');
    } catch (e) {
      // Fallback jika izin alarm presisi belum diberikan (Android 12/13+)
      // Gunakan inexact yang biasanya tetap muncul meskipun selang beberapa menit
      debugPrint('Fallback to inexact schedule due to: $e');
      await flutterLocalNotificationsPlugin.zonedSchedule(
        999,
        'Waktunya Menabung! 💰',
        'Jangan lupa catat pengeluaran dan pemasukanmu hari ini ya supaya target makin dekat!',
        _nextInstanceOfTime(hour, minute),
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> _cancelDailyReminder() async {
    await flutterLocalNotificationsPlugin.cancel(999);
  }

  Future<bool> _checkNotificationPermission() async {
    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  Future<void> _updateReminderSettings(
      bool enabled, int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    const userId = 'default_user';

    // 1. Simpan ke SharedPreferences terlebih dahulu
    await prefs.setBool('daily_reminder_enabled_$userId', enabled);
    await prefs.setInt('daily_reminder_hour_$userId', hour);
    await prefs.setInt('daily_reminder_minute_$userId', minute);

    // 2. Update state lokal segera agar UI berubah
    if (mounted) {
      setState(() {
        _reminderEnabled = enabled;
        _reminderHour = hour;
        _reminderMinute = minute;
      });
    }

    // 3. Coba jadwalkan notifikasi (ini bisa gagal jika izin belum ada)
    try {
      if (enabled) {
        final hasPermission = await _checkNotificationPermission();
        if (hasPermission) {
          await _scheduleDailyReminder(hour, minute);
        } else {
          _showSuccess('Harap berikan izin notifikasi di pengaturan HP Anda.');
        }
      } else {
        await _cancelDailyReminder();
      }
    } catch (e) {
      debugPrint('Error scheduling daily reminder: $e');
      // Jangan biarkan error ini menghentikan proses,
      // tapi ingatkan user jika perlu (opsional)
      if (e.toString().contains('exact_alarms_not_permitted')) {
        _showSuccess(
            'Gagal menjadwalkan: Harap restart aplikasi untuk mengaktifkan izin alarm.');
      }
    }
  }

  void _showDailyReminderSheet() {
    bool localEnabled = _reminderEnabled;
    int localHour = _reminderHour;
    int localMinute = _reminderMinute;

    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                      color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.purple.withValues(alpha: 0.2)
                          : Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.notifications_active_rounded,
                        color: isDarkMode
                            ? Colors.purpleAccent.shade100
                            : Colors.purple,
                        size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pengingat Harian',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black87)),
                        Text('Atur waktu notifikasi menabung',
                            style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode
                                    ? Colors.white24
                                    : Colors.black38,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: localEnabled,
                    activeTrackColor: isDarkMode
                        ? Colors.purpleAccent.shade200
                        : Colors.purple,
                    activeThumbColor: Colors.white,
                    onChanged: (val) => setSheetState(() => localEnabled = val),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (localEnabled) ...[
                Text('Pilih Waktu Pengingat',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white70 : Colors.black87)),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime:
                          TimeOfDay(hour: localHour, minute: localMinute),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: isDarkMode
                                ? ColorScheme.dark(
                                    primary: Colors.purple.shade300,
                                    onPrimary: Colors.white,
                                    surface: AppColors.surfaceDark,
                                    onSurface: Colors.white,
                                  )
                                : ColorScheme.light(
                                    primary: Colors.purple,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.black87,
                                  ),
                          ),
                          child: MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(alwaysUse24HourFormat: true),
                            child: child!,
                          ),
                        );
                      },
                    );
                    if (time != null) {
                      setSheetState(() {
                        localHour = time.hour;
                        localMinute = time.minute;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isDarkMode
                              ? Colors.white10
                              : Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time_rounded,
                            color: isDarkMode
                                ? Colors.purpleAccent.shade100
                                : Colors.purple),
                        const SizedBox(width: 12),
                        Text(
                          '${localHour.toString().padLeft(2, '0')}:${localMinute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color:
                                  isDarkMode ? Colors.white : Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                        'Aktifkan pengingat agar Anda selalu disiplin menabung!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: isDarkMode ? Colors.white12 : Colors.black26,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _updateReminderSettings(
                        localEnabled, localHour, localMinute);
                    Navigator.pop(context);
                    _showSuccess(localEnabled
                        ? 'Pengingat berhasil diset!'
                        : 'Pengingat dimatikan.');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? Colors.purple.shade900.withValues(alpha: 0.5)
                        : Colors.purple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Simpan Pengaturan',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && theme.brightness == Brightness.dark);

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
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.02),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Dekorasi Lingkaran
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
                          Colors.amber
                              .withValues(alpha: isDarkMode ? 0.1 : 0.15),
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
                          Colors.lightBlue
                              .withValues(alpha: isDarkMode ? 0.08 : 0.12),
                          Colors.lightBlue.withValues(alpha: 0.04),
                        ],
                      ),
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
                                _showBalance
                                    ? _formatRupiah(totalBalance)
                                    : '••••••',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.teal.shade900,
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
                              color: isDarkMode
                                  ? Colors.white24
                                  : Colors.teal.shade700.withValues(alpha: 0.3),
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
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.teal.shade50.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 24),

                      // Stats Row within Card
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: _miniStat('Pemasukan', totalIncome,
                                  Colors.green.shade600,
                                  center: true)),
                          const SizedBox(width: 24),
                          Container(
                              width: 1.2,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1),
                                color: isDarkMode
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.teal.shade50,
                              )),
                          const SizedBox(width: 24),
                          Expanded(
                              child: _miniStat('Pengeluaran', totalExpense,
                                  Colors.red.shade600,
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
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildToolAction(Icons.auto_stories_rounded,
                    'Hutang/Piutang', _QuickActionType.debt),
              ),
              Expanded(
                child: _buildToolAction(Icons.family_restroom_rounded,
                    'Keluarga', _QuickActionType.family),
              ),
              Expanded(
                child: _buildToolAction(Icons.shopping_cart_outlined, 'Belanja',
                    _QuickActionType.shoppingList),
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
                Text('ALOKASI KEUANGAN',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: isDarkMode
                            ? Colors.white30
                            : Colors.teal.shade800.withValues(alpha: 0.4))),
                const SizedBox(height: 24),
                if (totalIncome == 0 && totalExpense == 0)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Icon(Icons.pie_chart_outline_rounded,
                              size: 48,
                              color: isDarkMode
                                  ? Colors.white24
                                  : Colors.teal.shade50),
                          const SizedBox(height: 12),
                          Text('Belum ada data untuk dianalisis.',
                              style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white38
                                      : Colors.black26,
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
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.green.shade900),
                                      titlePositionPercentageOffset: 2.2,
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
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.red.shade900),
                                      titlePositionPercentageOffset: 2.2,
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
                                      color: isDarkMode
                                          ? Colors.white30
                                          : Colors.teal.shade800
                                              .withValues(alpha: 0.4))),
                              Text(
                                  _formatCompactRupiah(
                                      totalIncome + totalExpense),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black87)),
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
                      const SizedBox(height: 32),
                      _buildCategoryBreakdown(transactions, isDarkMode),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),

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
            Text('Belum ada aktivitas',
                style: TextStyle(
                    color: isDarkMode ? Colors.white54 : Colors.black38,
                    fontSize: 13))
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
                  Text('Edisi Mint Fresh v1.4.1',
                      style: TextStyle(
                          fontSize: 8,
                          color: isDarkMode ? Colors.white38 : Colors.grey)),
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
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

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
                fontWeight: FontWeight.w900,
                color: color.withValues(alpha: isDarkMode ? 0.9 : 0.8)),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(
      List<TransactionModel> transactions, bool isDarkMode) {
    final expenses =
        transactions.where((t) => t.type == TransactionType.expense).toList();
    if (expenses.isEmpty) {
      return const SizedBox.shrink();
    }

    final categoryMap = <String, double>{};
    double totalExpense = 0;
    for (var t in expenses) {
      categoryMap[t.category] = (categoryMap[t.category] ?? 0) + t.amount;
      totalExpense += t.amount;
    }

    final sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('DETAIL PENGELUARAN',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: isDarkMode ? Colors.white24 : Colors.black26)),
            Text('Persentase',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: isDarkMode ? Colors.white24 : Colors.black26)),
          ],
        ),
        const SizedBox(height: 16),
        ...sortedCategories.take(4).map((entry) {
          final percentage = entry.value / totalExpense;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white70
                                : Colors.teal.shade900)),
                    Text(_formatCompactRupiah(entry.value),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: isDarkMode ? Colors.white : Colors.black87)),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.6)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildToolAction(IconData icon, String label, _QuickActionType type) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _handleQuickActionTap(
            _QuickAction(icon: icon, label: label, type: type)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary
                          .withValues(alpha: isDarkMode ? 0.2 : 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: isDarkMode
                      ? Border.all(color: Colors.white.withValues(alpha: 0.05))
                      : null,
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
                      color: isDarkMode
                          ? Colors.white70
                          : Colors.teal.shade900.withValues(alpha: 0.7),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _minimalTile(TransactionModel t) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);
    final isExpense = t.type == TransactionType.expense;
    final IconData catIcon =
        isExpense ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    final Color catColor = isExpense ? Colors.red : Colors.green;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showTransactionDetailSheet(t),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color:
                      Colors.white.withValues(alpha: isDarkMode ? 0.05 : 0.01)),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.01),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
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
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.teal.shade900)),
                      const SizedBox(height: 2),
                      Text(DateFormat('dd MMM').format(t.date),
                          style: TextStyle(
                              fontSize: 10,
                              color: isDarkMode
                                  ? Colors.white54
                                  : Colors.grey.shade500)),
                    ],
                  ),
                ),
                Text(
                  '${isExpense ? '- ' : '+ '}${_formatRupiah(t.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
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
                                .withValues(alpha: isDarkMode ? 0.05 : 0.01)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDarkMode ? 0.2 : 0.01),
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
                                        fontWeight: FontWeight.w900,
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
                                          fontWeight: FontWeight.w900)),
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
                                  duration: const Duration(milliseconds: 1200),
                                  curve: Curves.easeOutBack,
                                  height: 12,
                                  width:
                                      (MediaQuery.of(context).size.width - 88) *
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
                                                alpha: isDarkMode ? 0.2 : 0.4),
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
                fontWeight: FontWeight.w900,
                color: isDarkMode ? Colors.white : Colors.teal.shade900)),
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
        final txs = ref.read(transactionsStreamProvider).valueOrNull ?? [];
        final bal = txs.fold<double>(
            0,
            (sum, t) =>
                sum +
                (t.type == TransactionType.income ? t.amount : -t.amount));
        await _showSavingTargetDialog(bal);
        break;
      case _QuickActionType.calculator:
        _showCalculatorSheet();
        break;
      case _QuickActionType.history:
        setState(() => _currentIndex = 2);
        break;
      case _QuickActionType.reminder:
        _showDailyReminderSheet();
        break;
      case _QuickActionType.family:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FamilyGroupPage(),
          ),
        );
        break;
      case _QuickActionType.debt:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DebtListPage(),
          ),
        );
        break;
      case _QuickActionType.shoppingList:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ShoppingListPage(),
          ),
        );
        break;
    }
  }

  void _showTargetDetailSheet(SavingTargetModel target, double totalBalance) {
    final progress = (target.targetAmount > 0)
        ? (totalBalance / target.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final remaining = target.dueDate.difference(DateTime.now()).inDays;
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
                              fontWeight: FontWeight.w900,
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
                                fontWeight: FontWeight.w900),
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
                              fontWeight: FontWeight.w900,
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
                  '${DateFormat('d MMM yyyy').format(target.dueDate)} ($remaining Hari lagi)',
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
                fontWeight: FontWeight.w900,
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

  Future<void> _showManualTransactionSheet(TransactionType type) async {
    final amountController = TextEditingController();
    final nameController = TextEditingController();
    final customCategoryController = TextEditingController();
    var selectedCategory = type == TransactionType.expense ? 'Makan' : 'Gaji';
    var noteText = '';

    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

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
                                fontWeight: FontWeight.w900,
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Rp',
                              style: TextStyle(
                                fontSize:
                                    amountController.text.length > 10 ? 24 : 32,
                                fontWeight: FontWeight.w900,
                                color: type == TransactionType.income
                                    ? (isDarkMode
                                        ? Colors.greenAccent.shade200
                                        : Colors.green.shade200)
                                    : (isDarkMode
                                        ? Colors.redAccent.shade100
                                        : Colors.red.shade200),
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
                                        ? (isDarkMode
                                            ? Colors.greenAccent.shade400
                                            : Colors.green.shade700)
                                        : (isDarkMode
                                            ? Colors.redAccent.shade200
                                            : Colors.red.shade700),
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
                                      color: isDarkMode
                                          ? Colors.white10
                                          : Colors.teal.shade50),
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
                                prefixIcon: const Icon(Icons.edit_note_rounded,
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
                            ),
                            const SizedBox(height: 24),
                            Text('PILIH KATEGORI *',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
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
                                  categories.firstWhere((c) =>
                                      c['label'] ==
                                      selectedCategory)['icon'] as IconData,
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
                                      ? Colors.amber.shade900
                                          .withValues(alpha: 0.1)
                                      : Colors.amber.shade50
                                          .withValues(alpha: 0.2),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                          color: isDarkMode
                                              ? Colors.amber.shade900
                                                  .withValues(alpha: 0.3)
                                              : Colors.amber.shade100)),
                                  prefixIcon: const Icon(Icons.star_rounded,
                                      color: Colors.amber),
                                  labelStyle: TextStyle(
                                      color: isDarkMode
                                          ? Colors.amber.shade200
                                          : Colors.black45),
                                  hintStyle: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white12
                                          : Colors.black26),
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
                                  creatorName: ref.read(userNameProvider),
                                );

                                await ref
                                    .read(transactionServiceProvider)
                                    .addTransaction(tx);
                                if (sheetContext.mounted) {
                                  Navigator.pop(sheetContext);
                                }
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
                                shadowColor:
                                    AppColors.primary.withValues(alpha: 0.4),
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
                            fontWeight: FontWeight.w900,
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
                      fontWeight: FontWeight.w900,
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
                            fontWeight: FontWeight.w900,
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
                        _RibuanSeparatorInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                            color:
                                isDarkMode ? Colors.white12 : Colors.black26),
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
                            fontWeight: FontWeight.w900,
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
                            fontWeight: FontWeight.w900,
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
                          if (isEdit && mounted) {
                            Navigator.pop(
                                context); // Close management sheet if edit
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
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: isDarkMode
                            ? Colors.white30
                            : Colors.teal.shade800.withValues(alpha: 0.4))),
                const SizedBox(height: 8),
                Text(_formatRupiah(totalIncome - totalExpense),
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
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
                                if (value != value.toInt())
                                  return const SizedBox.shrink();
                                final index = value.toInt();
                                if (index < 0 || index >= trendData.length)
                                  return const SizedBox.shrink();
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
                            fontWeight: FontWeight.w900,
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
                _miniStat('Total Pemasukan', totalIncome, Colors.green),
                Container(
                    width: 1,
                    height: 32,
                    color: isDarkMode ? Colors.white10 : Colors.teal.shade50),
                _miniStat('Total Pengeluaran', totalExpense, Colors.red),
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
                            fontWeight: FontWeight.w900,
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
                  fontWeight: FontWeight.w900,
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
                    fontWeight: FontWeight.w900,
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
                    fontWeight: FontWeight.w900,
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

    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    // Gunakan widget terpisah agar bisa punya TabController sendiri
    return _HistoryTabView(
      allTransactions: transactions,
      isDarkMode: isDarkMode,
      buildTransactionCard: _buildTransactionCard,
      miniHeaderStat: _miniHeaderStat,
      formatRupiah: _formatRupiah,
      formatCompact: _formatCompactRupiah,
      onTransactionTap: _showTransactionDetailSheet,
    );
  }

  Widget _miniHeaderStat(String label, double amount, Color color) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDarkMode ? 0.15 : 0.05),
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
                              fontWeight: FontWeight.w800,
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
                    fontWeight: FontWeight.w900,
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

    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && theme.brightness == Brightness.dark);
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
    final selectedColor =
        avatarColors[profile.colorIndex % avatarColors.length];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Profile Header Section
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
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    // Avatar — tampilkan foto atau ikon default
                    GestureDetector(
                      onTap: () => _pickProfilePhoto(),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor.withValues(alpha: 0.4),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: selectedColor.withValues(alpha: 0.25),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: profile.photoUrl != null
                              ? Image.network(
                                  profile.photoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: selectedColor,
                                    child: Icon(selectedIcon,
                                        size: 48, color: Colors.white),
                                  ),
                                )
                              : Container(
                                  color: selectedColor,
                                  child: Icon(selectedIcon,
                                      size: 48, color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                    // Badge kamera
                    GestureDetector(
                      onTap: () => _pickProfilePhoto(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? theme.scaffoldBackgroundColor
                              : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: Icon(Icons.camera_alt_rounded,
                            size: 16,
                            color:
                                isDarkMode ? Colors.white : AppColors.primary),
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
                    color: isDarkMode ? Colors.white : Colors.teal.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Member (Free)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? Colors.white30
                        : Colors.teal.shade800.withValues(alpha: 0.4),
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
            icon:
                isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            title: 'Mode Gelap',
            subtitle: isDarkMode
                ? 'Mode gelap saat ini aktif'
                : 'Mode terang saat ini aktif',
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (val) =>
                  ref.read(themeProvider.notifier).toggleTheme(),
              activeTrackColor: AppColors.primary,
              activeThumbColor: Colors.white,
            ),
            onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
            color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade600,
          ),

          _profileMenuCard(
            icon: Icons.notifications_none_rounded,
            title: 'Pengingat Harian',
            subtitle: _reminderEnabled
                ? 'Aktif pada ${_reminderHour.toString().padLeft(2, '0')}:${_reminderMinute.toString().padLeft(2, '0')}'
                : 'Aktifkan notifikasi menabung',
            onTap: () => _showDailyReminderSheet(),
            color: Colors.purple.shade400,
          ),

          const SizedBox(height: 24),
          _sectionHeader('APLIKASI'),

          _profileMenuCard(
            icon: Icons.info_outline_rounded,
            title: 'Tentang TabunganKu',
            subtitle: 'Informasi aplikasi & Versi v1.4.1',
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
            opacity: isDarkMode ? 0.2 : 0.3,
            child: Column(
              children: [
                Text('HANDCRAFTED BY',
                    style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color:
                            isDarkMode ? Colors.white : Colors.teal.shade900)),
                const SizedBox(height: 4),
                Text('NEVERLAND STUDIO',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color:
                            isDarkMode ? Colors.white : Colors.teal.shade900)),
                const SizedBox(height: 8),
                Text('Versi 1.4.1 (Global Release)',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white54 : Colors.black87)),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Buka picker foto profil dari kamera atau galeri
  Future<void> _pickProfilePhoto() async {
    final isDarkMode = ref.read(themeProvider) == ThemeMode.dark ||
        (ref.read(themeProvider) == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white12 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text('Ganti Foto Profil',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDarkMode ? Colors.white : Colors.black87)),
            const SizedBox(height: 24),
            ListTile(
              onTap: () => Navigator.pop(context, ImageSource.camera),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              ),
              title: Text('Buka Kamera',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87)),
              subtitle: Text('Ambil foto langsung',
                  style: TextStyle(
                      color: isDarkMode ? Colors.white38 : Colors.black38,
                      fontSize: 12)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            ListTile(
              onTap: () => Navigator.pop(context, ImageSource.gallery),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.photo_library_rounded, color: Colors.purple),
              ),
              title: Text('Pilih dari Galeri',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87)),
              subtitle: Text('Gunakan foto yang sudah ada',
                  style: TextStyle(
                      color: isDarkMode ? Colors.white38 : Colors.black38,
                      fontSize: 12)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (picked == null || !mounted) return;

    final result = await ref
        .read(userProfileProvider.notifier)
        .uploadAndSetPhoto(File(picked.path));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result != null
            ? 'Foto profil berhasil diperbarui! ✓'
            : 'Gagal mengupload foto. Coba lagi.'),
        backgroundColor: result != null ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }




  Widget _buildSimpleStatCard(
      String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDarkMode ? 0.15 : 0.05),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: color.withValues(alpha: isDarkMode ? 0.3 : 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white30 : Colors.black38)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isDarkMode ? Colors.white : Colors.teal.shade900)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: isDarkMode
                    ? Colors.white30
                    : Colors.teal.shade800.withValues(alpha: 0.4))),
      ),
    );
  }

  Widget _profileMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Color? color,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);
    final themeColor = color ?? AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.015),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: themeColor.withValues(alpha: isDarkMode ? 0.2 : 0.08),
                borderRadius: BorderRadius.circular(18)),
            child: Icon(icon, color: themeColor, size: 24),
          ),
          title: Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.teal.shade900)),
          subtitle: Text(subtitle,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white38 : Colors.black38)),
          trailing: trailing ??
              Icon(Icons.chevron_right_rounded,
                  size: 20,
                  color: isDarkMode ? Colors.white12 : Colors.black12),
        ),
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
                              fontWeight: FontWeight.w900,
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
                          _RibuanSeparatorInputFormatter()
                        ],
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: isDarkMode ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Input Nominal Baru *',
                          labelStyle: TextStyle(
                              color:
                                  isDarkMode ? Colors.white38 : Colors.black45),
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

  void _showAboutAppDialog() {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
        surfaceTintColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.teal.shade900.withValues(alpha: 0.2)
                    : Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.stars_rounded, color: Colors.teal.shade600),
            ),
            const SizedBox(width: 16),
            Text('TabunganKu',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: isDarkMode ? Colors.white : Colors.black87)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aplikasi manajemen keuangan pribadi yang cerdas untuk membantu kamu mencapai target finansial dengan lebih mudah.',
              style: TextStyle(
                  height: 1.5,
                  color: isDarkMode ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(height: 24),
            _aboutInfoRow('Versi', '1.4.1+141'),
            _aboutInfoRow('Build', 'Global Release'),
            _aboutInfoRow('Developer', 'Neverland Studio'),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '© 2026 Neverland Studio. All rights reserved.',
                style: TextStyle(
                    fontSize: 10,
                    color: isDarkMode ? Colors.white12 : Colors.black26),
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
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isDarkMode ? Colors.white24 : Colors.black38)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: isDarkMode ? Colors.white70 : Colors.teal.shade900)),
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

enum _QuickActionType {
  expense,
  income,
  savingTarget,
  calculator,
  history,
  family,
  reminder,
  debt,
  shoppingList
}

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
    if (newValue.text.isEmpty) return newValue;

    // Clean for processing
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');

    // Format with dots
    final formatted = digitsOnly.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );

    // Precise cursor positioning by counting digits
    int numDigitsBefore = newValue.selection.end -
        newValue.text
            .substring(0, newValue.selection.end)
            .replaceAll(RegExp(r'[0-9]'), '')
            .length;

    int newSelectionIndex = 0;
    int digitsCount = 0;
    while (
        digitsCount < numDigitsBefore && newSelectionIndex < formatted.length) {
      if (RegExp(r'[0-9]').hasMatch(formatted[newSelectionIndex])) {
        digitsCount++;
      }
      newSelectionIndex++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}

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
                        fontWeight: FontWeight.w900,
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
              fontWeight: FontWeight.w900,
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

  const _HistoryTabView({
    required this.allTransactions,
    required this.isDarkMode,
    required this.buildTransactionCard,
    required this.miniHeaderStat,
    required this.formatRupiah,
    required this.formatCompact,
    required this.onTransactionTap,
  });

  @override
  State<_HistoryTabView> createState() => _HistoryTabViewState();
}

class _HistoryTabViewState extends State<_HistoryTabView> {
  int _filterIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _isHutangPiutang(TransactionModel t) =>
      t.category == 'Hutang' || t.category == 'Piutang';
  bool _isBelanja(TransactionModel t) => t.id.startsWith('shopping_');
  bool _isRegular(TransactionModel t) =>
      !_isHutangPiutang(t) && !_isBelanja(t);

  String _fmtCur(double amount) => NumberFormat.currency(
          locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
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

        // ── Konten Filtered ───────────────────────────────────────────────
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildFilteredBody(sorted, regularList, hutangList, belanjaList, isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryFilter(bool isDark, List<TransactionModel> regularList, List<TransactionModel> hutangList, List<TransactionModel> belanjaList) {
    final categories = ['Pemasukan & Pengeluaran', 'Hutang', 'Belanja'];
    final categoryIcons = [Icons.account_balance_rounded, Icons.account_balance_wallet_rounded, Icons.shopping_basket_rounded];

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
                final RenderBox button = context.findRenderObject() as RenderBox;
                final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
                final RelativeRect position = RelativeRect.fromRect(
                  Rect.fromPoints(
                    button.localToGlobal(const Offset(0, 45), ancestor: overlay),
                    button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                  ),
                  Offset.zero & overlay.size,
                );

                final int? result = await showMenu<int>(
                  context: context,
                  position: position,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                                    : (isDark ? Colors.white38 : Colors.black38)),
                            const SizedBox(width: 12),
                            Text(categories[i],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: _filterIndex == i
                                      ? FontWeight.w900
                                      : FontWeight.w600,
                                  color: _filterIndex == i
                                      ? AppColors.primary
                                      : (isDark ? Colors.white : Colors.black87),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.03)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(categoryIcons[_filterIndex], size: 16, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      categories[_filterIndex],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
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
              _filterIndex == 0 ? '${regularList.length} Item' : (_filterIndex == 1 ? '${hutangList.length} Item' : '${belanjaList.length} Item'),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.primary),
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
  // List: hanya transaksi reguler
  // Header bulan: MASUK & KELUAR mencakup SEMUA jenis transaksi
  Widget _buildRegularTab(
      List<TransactionModel> allSorted,
      List<TransactionModel> regularList,
      bool isDark) {
    if (regularList.isEmpty) {
      return _emptyState(isDark,
          icon: Icons.receipt_long_outlined,
          label: 'Belum ada pemasukan/pengeluaran');
    }

    // Group regular by month
    final Map<String, List<TransactionModel>> grouped = {};
    for (final t in regularList) {
      final k = DateFormat('MMMM yyyy', 'id_ID').format(t.date).toUpperCase();
      grouped.putIfAbsent(k, () => []).add(t);
    }
    // Group ALL by month (untuk summary)
    final Map<String, List<TransactionModel>> allGrouped = {};
    for (final t in allSorted) {
      final k = DateFormat('MMMM yyyy', 'id_ID').format(t.date).toUpperCase();
      allGrouped.putIfAbsent(k, () => []).add(t);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
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
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? Colors.white60
                                    : Colors.teal.shade900,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 10),
                        Row(children: [
                          widget.miniHeaderStat(
                              'MASUK',
                              totalIn,
                              isDark
                                  ? Colors.greenAccent.shade400
                                  : Colors.green),
                          const SizedBox(width: 10),
                          widget.miniHeaderStat(
                              'KELUAR',
                              totalOut,
                              isDark
                                  ? Colors.redAccent.shade200
                                  : Colors.red),
                        ])
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
          subtitle:
              'Muncul saat hutang/piutang ditandai lunas');
    }

    final hutangOnly = list.where((t) => t.category == 'Hutang').toList();
    final piutangOnly = list.where((t) => t.category == 'Piutang').toList();
    final totalH = hutangOnly.fold(0.0, (s, t) => s + t.amount);
    final totalP = piutangOnly.fold(0.0, (s, t) => s + t.amount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
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
              Expanded(child: _sumItemMinimalist(isDark,
                  label: 'HUTANG DIBAYAR',
                  amount: totalH,
                  color: Colors.red.shade400)),
              Container(width: 1, height: 30,
                  color: isDark ? Colors.white12 : Colors.grey.shade200),
              Expanded(child: _sumItemMinimalist(isDark,
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
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
              Expanded(child: _sumItemMinimalist(isDark,
                  label: 'TOTAL BELANJA',
                  amount: total,
                  color: AppColors.primary)),
              Container(width: 1, height: 30,
                  color: isDark ? Colors.white12 : Colors.grey.shade200),
              Expanded(child: _sumItemMinimalist(isDark,
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
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13)),
                  child: Icon(
                      isHutang
                          ? Icons.call_made_rounded
                          : Icons.call_received_rounded,
                      color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.title,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : Colors.black87)),
                      if (t.description.isNotEmpty)
                        Text(t.description,
                            style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white38 : Colors.black38)),
                    ],
                  ),
                ),
                Text(_fmtCur(t.amount),
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w900, color: color)),
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
                  width: 40, height: 40,
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
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87)),
                ),
                Text(_fmtCur(t.amount),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
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
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: isDark ? Colors.white38 : Colors.black38)),
      const SizedBox(height: 5),
      Text(isCurrency ? _fmtCur(amount) : amount.toInt().toString(),
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w900, color: color)),
    ]);
  }

  Widget _groupHeader(String label, Color color, bool isDark) {
    return Row(children: [
      Container(
          width: 4, height: 14,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Text(label,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
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
                size: 60,
                color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 20),
          Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
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
