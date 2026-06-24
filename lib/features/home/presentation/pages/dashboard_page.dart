import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tabunganku/main.dart' show flutterLocalNotificationsPlugin;
import 'package:tabunganku/services/recurring_service.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/providers/user_provider.dart';
import 'package:tabunganku/features/transaction/presentation/widgets/transaction_detail_sheet.dart';
import 'package:tabunganku/providers/saving_target_provider.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/widgets/high_vis_input.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/features/transaction/presentation/pages/debt_list_page.dart';
import 'package:tabunganku/features/shopping/presentation/pages/shopping_list_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/models/saving_target_model.dart';
import 'package:tabunganku/features/settings/presentation/pages/settings_page.dart';
import 'package:tabunganku/features/transaction/presentation/pages/recurring_list_page.dart' hide HighVisInput;
import 'package:tabunganku/core/utils/currency_formatter.dart';
import 'package:tabunganku/core/services/export_service.dart';
import 'package:tabunganku/features/home/presentation/widgets/smart_clock_widgets.dart';
import 'package:tabunganku/core/constants/quick_action_type.dart';
import 'package:tabunganku/features/home/presentation/widgets/home_tab_view.dart'
    as widgets;
import 'package:tabunganku/providers/notification_provider.dart';
import 'package:tabunganku/features/home/presentation/widgets/notification_sheet.dart';
import 'package:tabunganku/core/constants/transaction_categories.dart';

import 'package:tabunganku/providers/bills_provider.dart';
import 'package:tabunganku/models/bill_model.dart';
import 'package:tabunganku/features/home/presentation/widgets/connectivity_guard.dart';
import 'package:tabunganku/providers/gold_provider.dart';
import 'package:tabunganku/providers/investment_provider.dart';
import 'package:tabunganku/models/gold_investment_model.dart';
import 'package:tabunganku/models/investment_model.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _showBalance = true;
  int? _wisdomIndex;
  int _savingsXp = 0;
  int _selectedQuickChallengeIndex = 0;
  final List<_QuickChallenge> _quickChallenges = [
    _QuickChallenge(
      icon: '💧',
      title: 'Bawa Botol Sendiri',
      subtitle: 'Hemat beli air kemasan',
      xpReward: 15,
      savingsAmount: 5000,
      category: 'Makanan & Minuman',
    ),
    _QuickChallenge(
      icon: '🍱',
      title: 'Bawa Bekal Makan',
      subtitle: 'Bawa bekal dari rumah',
      xpReward: 20,
      savingsAmount: 20000,
      category: 'Makanan & Minuman',
    ),
    _QuickChallenge(
      icon: '☕',
      title: 'Skip Kopi Kafe',
      subtitle: 'Seduh kopi sendiri',
      xpReward: 15,
      savingsAmount: 15000,
      category: 'Makanan & Minuman',
    ),
    _QuickChallenge(
      icon: '🚶',
      title: 'Jalan Kaki / Bus',
      subtitle: 'Hemat bensin & parkir',
      xpReward: 15,
      savingsAmount: 10000,
      category: 'Transportasi',
    ),
    _QuickChallenge(
      icon: '🛒',
      title: 'Belanja dengan Catatan',
      subtitle: 'Hindari belanja impulsif',
      xpReward: 20,
      savingsAmount: 25000,
      category: 'Belanja',
    ),
    _QuickChallenge(
      icon: '🎬',
      title: 'Bioskop di Rumah',
      subtitle: 'Nonton hemat bareng keluarga',
      xpReward: 30,
      savingsAmount: 50000,
      category: 'Hiburan',
    ),
    _QuickChallenge(
      icon: '🚫',
      title: 'Hari Tanpa Belanja',
      subtitle: 'Tantang Rp 0 seharian penuh',
      xpReward: 35,
      savingsAmount: 30000,
      category: 'Gaya Hidup',
    ),
    _QuickChallenge(
      icon: '🗑️',
      title: 'Bersihkan Keranjang',
      subtitle: 'Hapus belanjaan tidak mendesak',
      xpReward: 25,
      savingsAmount: 75000,
      category: 'Belanja',
    ),
    _QuickChallenge(
      icon: '🍳',
      title: 'Masak Dinner Sendiri',
      subtitle: 'Gunakan bahan di kulkas',
      xpReward: 25,
      savingsAmount: 40000,
      category: 'Makanan & Minuman',
    ),
    _QuickChallenge(
      icon: '🔌',
      title: 'Hemat Listrik & Air',
      subtitle: 'Matikan lampu & cabut colokan',
      xpReward: 10,
      savingsAmount: 8000,
      category: 'Tagihan',
    ),
  ];
  final List<_DailyMission> _dailyMissions = [];
  final PageController _targetPageController = PageController();

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

  void _showNotificationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationSheet(),
    );
  }

  void _showAddMissionSheet() {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    String selectedEmoji = '💰';
    final isDark = ref.read(themeProvider) == ThemeMode.dark ||
        (ref.read(themeProvider) == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 36),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
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
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.add_task_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Tambah Misi Baru',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                'NAMA MISI',
                style: GoogleFonts.quicksand(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: isDark ? Colors.white30 : Colors.black38,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                style: GoogleFonts.quicksand(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
                  hintText: 'Masukkan nama misi menabung',
                  hintStyle: GoogleFonts.quicksand(
                    fontSize: 13,
                    color: isDark ? Colors.white24 : Colors.black38,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.white.withOpacity(0.02) : Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white10 : Colors.grey.shade200,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white10 : Colors.grey.shade100,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'DESKRIPSI MISI',
                style: GoogleFonts.quicksand(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: isDark ? Colors.white30 : Colors.black38,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: subtitleController,
                style: GoogleFonts.quicksand(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.notes_rounded, color: AppColors.primary),
                  hintText: 'Masukkan deskripsi misi (opsional)',
                  hintStyle: GoogleFonts.quicksand(
                    fontSize: 12,
                    color: isDark ? Colors.white24 : Colors.black38,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.white.withOpacity(0.02) : Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white10 : Colors.grey.shade200,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white10 : Colors.grey.shade100,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'PILIH IKON MISI',
                style: GoogleFonts.quicksand(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: isDark ? Colors.white30 : Colors.black38,
                ),
              ),
              const SizedBox(height: 10),
              StatefulBuilder(
                builder: (ctx2, setStateSheet) {
                  final emojis = ['💰', '☕', '🍱', '🛍️', '💸', '🚗', '🏡', '🎯'];
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: emojis.map((emoji) {
                        final isSelected = selectedEmoji == emoji;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              setStateSheet(() {
                                selectedEmoji = emoji;
                              });
                              HapticFeedback.lightImpact();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.15)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final subtitle = subtitleController.text.trim();
                    if (title.isEmpty) return;

                    setState(() {
                      _dailyMissions.add(
                        _DailyMission(
                          title: '$title $selectedEmoji',
                          subtitle: subtitle.isEmpty ? 'Misi menabung pilihan Anda.' : subtitle,
                        ),
                      );
                    });

                    HapticFeedback.mediumImpact();
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Tambah Misi',
                    style: GoogleFonts.quicksand(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

int _currentIndex = 0;
  String? _loadedUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadLocalData();

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

final personalTransactions = ref.watch(transactionsByGroupProvider(null));

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
        toolbarHeight: 90,
        title: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(_navItems[_currentIndex].label,
                          style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold, fontSize: 24)),
                    ),
                    if (_currentIndex != 3) ...[
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: SmartDateDisplay(isDarkMode: isDarkMode),
                      ),
                      const SizedBox(height: 1),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: SmartDigitalClock(
                          isDarkMode: isDarkMode,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
        actions: [
          if (_currentIndex == 0)
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 12),
              child: Consumer(
                builder: (context, ref, child) {
                  final unreadCountAsync =
                      ref.watch(unreadNotificationsCountProvider);
                  return Badge(
                    label: unreadCountAsync.maybeWhen(
                      data: (count) =>
                          count > 0 ? Text(count.toString()) : null,
                      orElse: () => null,
                    ),
                    isLabelVisible: unreadCountAsync.maybeWhen(
                      data: (count) => count > 0,
                      orElse: () => false,
                    ),
                    backgroundColor: AppColors.primary,
                    offset: const Offset(-4, 4),
                    child: IconButton(
                      onPressed: _showNotificationSheet,
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                  );
                },
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
          height: 100,
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
                      const SizedBox(width: 72),
                      _buildNavItem(2),
                      _buildNavItem(3),
                    ],
                  ),
                ),
              ),

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
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primaryLight, AppColors.primary],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(
                                  0x4D00BFA5),
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
                    Text(
                      'Kalkulator',
                      style: GoogleFonts.quicksand(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
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

Future<void> _loadLocalData() async {
    const userId = 'default_user';
    final prefs = await SharedPreferences.getInstance();

const migrationKey =
        'migration_saving_target_v3_done_$userId';
    if (prefs.getBool(migrationKey) != true) {
      final oldAmount = prefs.getString('saving_target_amount_$userId');
      final oldItem = prefs.getString('saving_target_item_$userId');
      final oldDueRaw = prefs.getString('saving_target_due_$userId');

      if (oldAmount != null && oldItem != null && oldDueRaw != null) {
        final oldDue = DateTime.tryParse(oldDueRaw);
        if (oldDue != null) {

          final target = SavingTargetModel(
            id: 'legacy_${DateTime.now().millisecondsSinceEpoch}',
            name: oldItem,
            targetAmount: _toAmount(oldAmount) ?? 0,
            dueDate: oldDue,
            createdAt: DateTime.now(),
          );
          await ref.read(savingTargetServiceProvider).addTarget(target);

await prefs.setBool(migrationKey, true);

await prefs.remove('saving_target_amount_$userId');
          await prefs.remove('saving_target_item_$userId');
          await prefs.remove('saving_target_due_$userId');
        } else {
          await prefs.setBool(
              migrationKey, true);
        }
      } else {
        await prefs.setBool(migrationKey, true);
      }
    }

    final savedXp = prefs.getInt('savings_xp_$userId') ?? 0;
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final savedDate = prefs.getString('completed_challenges_date_$userId') ?? '';
    List<String> completedList = [];
    if (savedDate == todayStr) {
      completedList = prefs.getStringList('completed_challenges_list_$userId') ?? [];
    } else {
      await prefs.setString('completed_challenges_date_$userId', todayStr);
      await prefs.setStringList('completed_challenges_list_$userId', []);
    }

    if (!mounted) return;
    setState(() {
      _loadedUserId = userId;
      _savingsXp = savedXp;
      for (var ch in _quickChallenges) {
        ch.isCompleted = completedList.contains(ch.title);
      }
    });

    final targets = await ref.read(savingTargetServiceProvider).getTargets();
    for (final t in targets) {
      await _maybeShowTargetReminder(userId, t);
    }
  }

  int get _savingsLevel => (_savingsXp / 100).floor() + 1;
  int get _xpToNextLevel => 100 - (_savingsXp % 100);
  double get _levelProgress => (_savingsXp % 100) / 100.0;

  String _getLevelName(int lvl) {
    if (lvl == 1) return 'Penabung Pemula';
    if (lvl == 2) return 'Penabung Cerdas';
    if (lvl == 3) return 'Penjaga Anggaran';
    if (lvl == 4) return 'Ksatria Finansial';
    if (lvl == 5) return 'Master Kemakmuran';
    return 'Legenda Finansial';
  }

  String get _savingsLevelTitle {
    return _getLevelName(_savingsLevel);
  }

  IconData _getChallengeIconData(String emoji) {
    switch (emoji) {
      case '💧':
        return Icons.local_drink_rounded;
      case '🍱':
        return Icons.lunch_dining_rounded;
      case '☕':
        return Icons.coffee_rounded;
      case '🚶':
        return Icons.directions_walk_rounded;
      case '🛒':
        return Icons.shopping_cart_rounded;
      case '🎬':
        return Icons.movie_rounded;
      case '🚫':
        return Icons.do_not_disturb_on_rounded;
      case '🗑️':
        return Icons.delete_sweep_rounded;
      case '🍳':
        return Icons.restaurant_rounded;
      case '🔌':
        return Icons.power_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }

  Color _getChallengeIconColor(String emoji) {
    switch (emoji) {
      case '💧':
        return const Color(0xFF2196F3);
      case '🍱':
        return const Color(0xFFFF9800);
      case '☕':
        return const Color(0xFF8D6E63);
      case '🚶':
        return const Color(0xFF4CAF50);
      case '🛒':
        return const Color(0xFF9C27B0);
      case '🎬':
        return const Color(0xFFE91E63);
      case '🚫':
        return const Color(0xFF607D8B);
      case '🗑️':
        return const Color(0xFFFF5722);
      case '🍳':
        return const Color(0xFF009688);
      case '🔌':
        return const Color(0xFFFFC107);
      default:
        return AppColors.primary;
    }
  }

  Future<void> _updateSavingsXp(int delta) async {
    const userId = 'default_user';
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savingsXp = (_savingsXp + delta).clamp(0, 10000);
    });
    await prefs.setInt('savings_xp_$userId', _savingsXp);
  }

  void _showChallengeVerificationSheet(_QuickChallenge challenge) {
    final isDark = ref.read(themeProvider) == ThemeMode.dark ||
        (ref.read(themeProvider) == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

final amountController = TextEditingController(
      text: NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0)
          .format(challenge.savingsAmount.toInt())
          .trim(),
    );

bool check1 = false;
    bool check2 = false;
    bool logToKas = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx2, setFormState) {
            final canComplete = check1 && check2;
            return Container(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
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
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                challenge.icon,
                                style: const TextStyle(fontSize: 26),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TANTANGAN HARI INI',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.4,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    challenge.title,
                                    style: GoogleFonts.quicksand(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    challenge.subtitle,
                                    style: GoogleFonts.quicksand(
                                      fontSize: 11.5,
                                      color: isDark ? Colors.white.withOpacity(0.5) : Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.amber.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '+${challenge.xpReward} XP',
                                style: GoogleFonts.quicksand(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Divider(
                          color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade100,
                          thickness: 1,
                        ),
                        const SizedBox(height: 20),

                        Text(
                          'NOMINAL PENGHEMATAN',
                          style: GoogleFonts.quicksand(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                            color: isDark ? Colors.white30 : Colors.black38,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sesuaikan dengan penghematan nyata kamu hari ini.',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            color: isDark ? Colors.white.withOpacity(0.4) : Colors.black38,
                          ),
                        ),
                        const SizedBox(height: 10),

                        TextField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _RibuanFormatter(),
                          ],
                          style: GoogleFonts.quicksand(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            prefixText: 'Rp ',
                            prefixStyle: GoogleFonts.quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? AppColors.primary.withOpacity(0.06)
                                : AppColors.primary.withOpacity(0.04),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: AppColors.primary.withOpacity(0.4),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          'VERIFIKASI KOMITMEN',
                          style: GoogleFonts.quicksand(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                            color: isDark ? Colors.white30 : Colors.black38,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Centang kedua pernyataan untuk mengaktifkan tombol selesai.',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            color: isDark ? Colors.white.withOpacity(0.4) : Colors.black38,
                          ),
                        ),
                        const SizedBox(height: 12),

                        InkWell(
                          onTap: () {
                            setFormState(() => check1 = !check1);
                            HapticFeedback.selectionClick();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: check1
                                  ? Colors.teal.withOpacity(0.08)
                                  : isDark
                                      ? Colors.white.withOpacity(0.03)
                                      : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: check1
                                    ? Colors.teal.withOpacity(0.3)
                                    : isDark
                                        ? Colors.white.withOpacity(0.06)
                                        : Colors.grey.shade200,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: check1 ? Colors.teal : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: check1
                                          ? Colors.teal
                                          : isDark
                                              ? Colors.white24
                                              : Colors.grey.shade400,
                                      width: 2,
                                    ),
                                  ),
                                  child: check1
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 14,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Saya benar-benar telah menyelesaikan tantangan "${challenge.title}" hari ini.',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        InkWell(
                          onTap: () {
                            setFormState(() => check2 = !check2);
                            HapticFeedback.selectionClick();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: check2
                                  ? Colors.teal.withOpacity(0.08)
                                  : isDark
                                      ? Colors.white.withOpacity(0.03)
                                      : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: check2
                                    ? Colors.teal.withOpacity(0.3)
                                    : isDark
                                        ? Colors.white.withOpacity(0.06)
                                        : Colors.grey.shade200,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: check2 ? Colors.teal : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: check2
                                          ? Colors.teal
                                          : isDark
                                              ? Colors.white24
                                              : Colors.grey.shade400,
                                      width: 2,
                                    ),
                                  ),
                                  child: check2
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 14,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Saya berkomitmen mengalokasikan dana hemat ini ke tabungan aktif.',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        InkWell(
                          onTap: () {
                            setFormState(() => logToKas = !logToKas);
                            HapticFeedback.selectionClick();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.savings_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Catat nominal hemat ke Buku Kas utama',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: logToKas,
                                  onChanged: (val) {
                                    setFormState(() => logToKas = val);
                                    HapticFeedback.selectionClick();
                                  },
                                  activeColor: AppColors.primary,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: canComplete
                                ? () async {
                                    final rawText = amountController.text
                                        .replaceAll('.', '')
                                        .replaceAll(',', '');
                                    final actualAmount =
                                        double.tryParse(rawText) ?? challenge.savingsAmount;

setState(() {
                                      challenge.isCompleted = true;
                                    });
                                    await _updateSavingsXp(challenge.xpReward);

final prefs = await SharedPreferences.getInstance();
                                    const userId = 'default_user';
                                    final completedTitles = _quickChallenges
                                        .where((c) => c.isCompleted)
                                        .map((c) => c.title)
                                        .toList();
                                    await prefs.setStringList(
                                        'completed_challenges_list_$userId', completedTitles);

if (logToKas) {
                                      final tx = TransactionModel(
                                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                                        title: 'Hemat: ${challenge.title} ${challenge.icon}',
                                        description: 'Tabungan nyata dari tantangan harian.',
                                        amount: actualAmount,
                                        type: TransactionType.income,
                                        date: DateTime.now(),
                                        category: challenge.category,
                                        creatorName: ref.read(userNameProvider),
                                      );
                                      await ref
                                          .read(transactionServiceProvider)
                                          .addTransaction(tx);
                                    }

                                    HapticFeedback.heavyImpact();
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            logToKas
                                                ? 'Luar biasa! +${challenge.xpReward} XP & ${_formatRupiah(actualAmount)} tercatat di tabungan! 💰'
                                                : 'Keren! +${challenge.xpReward} XP dikreditkan ke level kamu! 🚀',
                                            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
                                          ),
                                          backgroundColor: Colors.teal.shade700,
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  canComplete ? AppColors.primary : Colors.grey.shade400,
                              disabledBackgroundColor: isDark
                                  ? Colors.white.withOpacity(0.07)
                                  : Colors.grey.shade200,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: canComplete ? 4 : 0,
                              shadowColor: AppColors.primary.withOpacity(0.3),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  canComplete
                                      ? Icons.emoji_events_rounded
                                      : Icons.lock_outline_rounded,
                                  color: canComplete
                                      ? Colors.white
                                      : isDark
                                          ? Colors.white24
                                          : Colors.grey.shade400,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  canComplete
                                      ? 'Selesaikan & Klaim XP! 🚀'
                                      : 'Centang kedua pernyataan dulu',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: canComplete
                                        ? Colors.white
                                        : isDark
                                            ? Colors.white24
                                            : Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
          },
        ),
      ),
    );
  }

void _showChallengeSuccessSheet(_QuickChallenge challenge) {
    final isDark = ref.read(themeProvider) == ThemeMode.dark ||
        (ref.read(themeProvider) == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: AppColors.primary,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'TANTANGAN DISELESAIKAN!',
              style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Hebat! Kamu berhasil menyelesaikan tantangan "${challenge.title} ${challenge.icon}" hari ini dan berhak mengklaim +${challenge.xpReward} XP untuk mempercepat kenaikan Level Finansialmu! 🚀',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 13,
                height: 1.5,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'ESTIMASI DANA YANG DIHEMAT',
                    style: GoogleFonts.quicksand(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatRupiah(challenge.savingsAmount),
                    style: GoogleFonts.quicksand(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {

                      final tx = TransactionModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: 'Hemat: ${challenge.title} ${challenge.icon}',
                        description: 'Tabungan hasil penyelesaian tantangan cepat.',
                        amount: challenge.savingsAmount,
                        type: TransactionType.income,
                        date: DateTime.now(),
                        category: challenge.category,
                        creatorName: ref.read(userNameProvider),
                      );

                      await ref.read(transactionServiceProvider).addTransaction(tx);
                      HapticFeedback.heavyImpact();
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Dana hemat ${_formatRupiah(challenge.savingsAmount)} berhasil dimasukkan ke tabungan! 💰✨',
                              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: Colors.teal.shade700,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Ya, Catat Tabungan! 💰',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Klaim berhasil! +${challenge.xpReward} XP dikreditkan. 🚀',
                            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Hanya Klaim XP',
                      style: GoogleFonts.quicksand(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
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

  Widget _buildLevelAndChallengesCard(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF151618) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.04)
              : Colors.black.withOpacity(0.03),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.12)
                : Colors.black.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEVEL FINANSIAL',
                      style: GoogleFonts.quicksand(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: isDarkMode ? Colors.white30 : Colors.black38,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _savingsLevelTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_savingsXp XP',
                  style: GoogleFonts.quicksand(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 10,
              child: LinearProgressIndicator(
                value: _levelProgress,
                backgroundColor: isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.shade100,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_xpToNextLevel XP lagi menuju level berikutnya',
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white30 : Colors.black38,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withOpacity(0.02) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TINGKATAN LEVEL FINANSIAL',
                  style: GoogleFonts.quicksand(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: isDarkMode ? Colors.white30 : Colors.black38,
                  ),
                ),
                const SizedBox(height: 10),

                ...List.generate(6, (idx) {
                  final lvlIndex = idx + 1;
                  final lvlName = _getLevelName(lvlIndex);
                  final isCurrent = _savingsLevel == lvlIndex;
                  final isPassed = _savingsLevel > lvlIndex;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.5),
                    child: Row(
                      children: [

                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrent 
                                ? AppColors.primary 
                                : (isPassed ? AppColors.primary.withOpacity(0.4) : Colors.transparent),
                            border: Border.all(
                              color: isCurrent || isPassed 
                                  ? AppColors.primary 
                                  : (isDarkMode ? Colors.white24 : Colors.grey.shade300),
                              width: 1.2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: isPassed 
                              ? const Icon(Icons.check, size: 7, color: Colors.white) 
                              : null,
                        ),
                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            'Level $lvlIndex: $lvlName',
                            style: GoogleFonts.quicksand(
                              fontSize: 10.5,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                              color: isCurrent 
                                  ? (isDarkMode ? Colors.white : AppColors.primaryDark)
                                  : (isPassed 
                                      ? (isDarkMode ? Colors.white54 : Colors.black87)
                                      : (isDarkMode ? Colors.white24 : Colors.grey.shade400)),
                            ),
                          ),
                        ),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Kamu di Sini',
                              style: GoogleFonts.quicksand(
                                fontSize: 7.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Divider(
              color: isDarkMode ? Colors.white.withOpacity(0.06) : Colors.grey.shade100,
              thickness: 1,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'TANTANGAN CEPAT HARIAN',
            style: GoogleFonts.quicksand(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: isDarkMode ? Colors.white30 : Colors.black38,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Selesaikan tantangan kecil & klaim XP + Catat Tabungan!',
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 18),

Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withOpacity(0.02) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.04)
                    : Colors.black.withOpacity(0.04),
                width: 1.2,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedQuickChallengeIndex,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isDarkMode ? Colors.white54 : Colors.black45,
                  size: 20,
                ),
                isExpanded: true,
                dropdownColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                items: List.generate(_quickChallenges.length, (idx) {
                  final challenge = _quickChallenges[idx];
                  return DropdownMenuItem<int>(
                    value: idx,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getChallengeIconData(challenge.icon),
                              color: _getChallengeIconColor(challenge.icon),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              challenge.title,
                              style: GoogleFonts.quicksand(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        if (challenge.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Selesai',
                              style: GoogleFonts.quicksand(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                onChanged: (int? newIndex) {
                  if (newIndex != null) {
                    setState(() {
                      _selectedQuickChallengeIndex = newIndex;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          Builder(
            builder: (context) {
              final challenge = _quickChallenges[_selectedQuickChallengeIndex];
              final challengeColor = _getChallengeIconColor(challenge.icon);
              final challengeIcon = _getChallengeIconData(challenge.icon);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: challenge.isCompleted
                      ? (isDarkMode
                          ? Colors.teal.withOpacity(0.04)
                          : Colors.teal.withOpacity(0.03))
                      : (isDarkMode
                          ? Colors.white.withOpacity(0.01)
                          : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: challenge.isCompleted
                        ? Colors.teal.withOpacity(0.12)
                        : (isDarkMode
                            ? Colors.white.withOpacity(0.04)
                            : Colors.black.withOpacity(0.04)),
                    width: 1.2,
                  ),
                  boxShadow: isDarkMode || challenge.isCompleted
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: challenge.isCompleted
                            ? Colors.teal.withOpacity(0.10)
                            : challengeColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        challenge.isCompleted ? Icons.check_circle_outline_rounded : challengeIcon,
                        color: challenge.isCompleted ? Colors.teal : challengeColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            challenge.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.quicksand(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.35)
                                  : Colors.black45,
                            ),
                          ),
                          const SizedBox(height: 6),

                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '+${challenge.xpReward} XP',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade700,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Hemat ${_formatRupiah(challenge.savingsAmount)}',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    challenge.isCompleted
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Selesai',
                              style: GoogleFonts.quicksand(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          )
                        : Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _showChallengeVerificationSheet(challenge);
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.play_arrow_rounded,
                                      color: AppColors.primary,
                                      size: 13,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      'Mulai',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              );
            },
          ),
        ],
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
        'saving_target_channel_v2',
        'Saving Target Reminder',
        channelDescription: 'Pengingat target tabungan',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
          presentAlert: true, presentBadge: true, presentSound: true),
    );

    await flutterLocalNotificationsPlugin.show(
      target.id.hashCode,
      'Target Tabungan Hampir Jatuh Tempo',
      'Sisa $remaining hari untuk target ${target.name} (${_formatRupiah(target.targetAmount)})',
      details,
    );
    await prefs.setString(notifiedKey, todayKey);
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
                sum + (t.type == TransactionType.income ? t.amount : 0));
        await _showSavingTargetDialog(bal);
        break;
      case QuickActionType.buyingTarget:
        context.push('/buying-targets');
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
      case QuickActionType.nabungBersama:
        context.push('/nabung-bersama');
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
      case QuickActionType.goldSavings:
        context.push('/gold');
        break;
      case QuickActionType.emergencyFund:
        context.push('/emergency-fund');
        break;
      case QuickActionType.educationFund:
        context.push('/education-fund');
        break;
      case QuickActionType.retirementFund:
        context.push('/retirement-fund');
        break;
      case QuickActionType.tax:
        context.push('/tax');
        break;
      case QuickActionType.bills:
        context.push('/bills');
        break;

      case QuickActionType.qurban:
        context.push('/qurban');
        break;
      case QuickActionType.investment:
        context.push('/investment');
        break;
      case QuickActionType.insurance:
        context.push('/insurance');
        break;
      case QuickActionType.savingPlans:
        context.push('/saving-plans');
        break;
    }
  }

  void _showTargetDetailSheet(SavingTargetModel target, double _) {
    final transactions = ref.read(transactionsByGroupProvider(null));
    final targetBalance = transactions
        .where((t) => !t.date.isBefore(target.createdAt))
        .fold<double>(
            0, (s, t) => s + (t.type == TransactionType.income ? t.amount : -t.amount));

    final progress = (target.targetAmount > 0)
        ? (targetBalance / target.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final remainingDays = target.dueDate.difference(DateTime.now()).inDays;
    final remainingAmount = target.targetAmount - targetBalance;
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
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary
                          .withValues(alpha: isDarkMode ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.track_changes_rounded,
                        color: AppColors.primary, size: 24),
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
                              color:
                                  isDarkMode ? Colors.white : Colors.black87),
                        ),
                        Text(
                          'Target Tabungan',
                          style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white24 : Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isCompleted ? 'SELESAI' : 'AKTIF',
                      style: GoogleFonts.quicksand(
                        color: isCompleted ? Colors.green : AppColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.01)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDarkMode ? Colors.white10 : Colors.grey.shade100,
                  ),
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
                                isCompleted
                                    ? Colors.green.shade400
                                    : AppColors.primary),
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: GoogleFonts.quicksand(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode ? Colors.white : Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _targetStatPill(
                              'TERKUMPUL',
                              _formatRupiah(targetBalance),
                              isDarkMode,
                              Colors.green),
                          const SizedBox(height: 14),
                          _targetStatPill(
                              'GOAL',
                              _formatRupiah(target.targetAmount),
                              isDarkMode,
                              AppColors.primary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _targetInfoCard(
                          'SISA KURANG',
                          remainingAmount <= 0
                              ? 'Lunas'
                              : _formatRupiah(remainingAmount),
                          Icons.hourglass_bottom_rounded,
                          isDarkMode,
                          color: Colors.red),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _targetInfoCard(
                          'JATUH TEMPO',
                          DateFormat('d MMM yyyy').format(target.dueDate),
                          Icons.calendar_today_rounded,
                          isDarkMode,
                          subLabel: '$remainingDays Hari lagi'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

Text(
                'Dibuat pada ${DateFormat('d MMM yyyy').format(target.createdAt)}',
                style: GoogleFonts.quicksand(
                    fontSize: 10,
                    color: isDarkMode ? Colors.white10 : Colors.black12,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showAddEditTargetDialog(target: target);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Ubah Target',
                          style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold, fontSize: 13)),
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
                      onPressed: () async {
                        Navigator.pop(context);
                        await _deleteSavingTarget(target.id);
                      },
                      icon: Icon(Icons.delete_outline_rounded,
                          color: isDarkMode ? Colors.red.shade300 : Colors.red,
                          size: 20),
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

  Widget _targetStatPill(
      String label, String value, bool isDarkMode, Color color) {
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
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _targetInfoCard(
      String label, String value, IconData icon, bool isDarkMode,
      {Color? color, String? subLabel}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.01) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 14,
                  color: color ?? (isDarkMode ? Colors.white24 : Colors.grey)),
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
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          if (subLabel != null)
            Text(
              subLabel,
              style: GoogleFonts.quicksand(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
        ],
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
                style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDarkMode ? Colors.white38 : Colors.black54))),
        const SizedBox(width: 8),
        Text(value,
            style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDarkMode ? Colors.white : AppColors.primaryDark)),
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
                    style: GoogleFonts.quicksand(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white38 : Colors.black38)),
                Text(_formatRupiah(val),
                    style: GoogleFonts.quicksand(
                        fontSize: 11,
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
                style: GoogleFonts.quicksand(
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

  void _applyTopUpBankNameToKeterangan({
    required TextEditingController nameController,
    required String bankName,
    required StateSetter setSheetState,
  }) {
    if (nameController.text.isEmpty ||
        nameController.text.startsWith('Biaya Admin')) {
      final now = DateTime.now();
      const monthNames = [
        '',
        'Januari', 'Februari', 'Maret',
        'April', 'Mei', 'Juni', 'Juli',
        'Agustus', 'September', 'Oktober',
        'November', 'Desember',
      ];
      final monthName = monthNames[now.month];
      final trimmed = bankName.trim();
      setSheetState(() {
        nameController.text = trimmed.isEmpty
            ? 'Biaya Admin Bank ${now.day} $monthName ${now.year}'
            : 'Biaya Admin Bank $trimmed ${now.day} $monthName ${now.year}';
      });
    }
  }

  void _applyInterestBankNameToKeterangan({
    required TextEditingController nameController,
    required String bankName,
    required StateSetter setSheetState,
  }) {
    if (nameController.text.isEmpty ||
        nameController.text.startsWith('Bunga ')) {
      final now = DateTime.now();
      const monthNames = [
        '',
        'Januari', 'Februari', 'Maret',
        'April', 'Mei', 'Juni', 'Juli',
        'Agustus', 'September', 'Oktober',
        'November', 'Desember',
      ];
      final monthName = monthNames[now.month];
      final trimmed = bankName.trim();
      setSheetState(() {
        nameController.text = trimmed.isEmpty
            ? ''
            : 'Bunga Bank $trimmed ${now.day} $monthName ${now.year}';

      });
    }
  }

  Future<void> _showManualTransactionSheet(TransactionType type) async {
    final amountController = TextEditingController();
    final nameController = TextEditingController();
    final customCategoryController = TextEditingController();
    final topUpBankController = TextEditingController();
    final interestBankController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final List<TransactionCategory> categoryObjects =
        type == TransactionType.income
            ? AppCategories.incomeCategories
            : AppCategories.expenseCategories;

final Map<String, List<TransactionCategory>> groupedCategories = {};
    for (var cat in categoryObjects) {
      groupedCategories.putIfAbsent(cat.group, () => []).add(cat);
    }

    var selectedCategory = type == TransactionType.expense
        ? 'Makanan & Minuman Harian'
        : 'Gaji Pokok Bulanan';

if (categoryObjects.isNotEmpty &&
        !categoryObjects.any((cat) => cat.label == selectedCategory)) {
      selectedCategory = categoryObjects.first.label;
    }

    var selectedGroup =
        categoryObjects.any((cat) => cat.label == selectedCategory)
            ? categoryObjects
                .firstWhere((cat) => cat.label == selectedCategory)
                .group
            : (categoryObjects.isNotEmpty ? categoryObjects.first.group : '');
    var categoryUserSelected = false;
    var noteText = '';
    final interestBankOptions = [
      {
        'value': 'SeaBank (Standar)',
        'label': 'SeaBank (Standar)',
        'subtitle': '2,5% p.a. – Tanpa min. saldo',
        'icon': Icons.savings_rounded,
        'color': Colors.teal,
      },
      {
        'value': 'SeaBank (Deposito)',
        'label': 'SeaBank (Deposito)',
        'subtitle': 'Up to 6% p.a. – Deposito Tinggi',
        'icon': Icons.trending_up_rounded,
        'color': Colors.orangeAccent,
      },
      {
        'value': 'Bank Neo Commerce',
        'label': 'Bank Neo Commerce',
        'subtitle': 'Bunga cair harian & bunga tinggi',
        'icon': Icons.bolt_rounded,
        'color': Colors.amber.shade700,
      },
      {
        'value': 'Bank Jago',
        'label': 'Bank Jago',
        'subtitle': 'Bunga cair bulanan & Kantong Jago',
        'icon': Icons.account_balance_wallet_rounded,
        'color': Colors.orange.shade800,
      },
      {
        'value': 'Blu by BCA Digital',
        'label': 'Blu by BCA Digital',
        'subtitle': 'Blu – Digital banking by BCA',
        'icon': Icons.water_drop_rounded,
        'color': Colors.blue.shade500,
      },
      {
        'value': 'Allo Bank',
        'label': 'Allo Bank',
        'subtitle': 'Allo – Belanja hemat & Bunga menarik',
        'icon': Icons.credit_card_rounded,
        'color': Colors.purple.shade600,
      },
      {
        'value': 'Bank BCA',
        'label': 'Bank BCA',
        'subtitle': 'BCA – Bank Swasta Terbesar',
        'icon': Icons.account_balance_rounded,
        'color': Colors.blue.shade800,
      },
      {
        'value': 'Bank Mandiri',
        'label': 'Bank Mandiri',
        'subtitle': 'Mandiri – Bank BUMN Terbesar',
        'icon': Icons.account_balance_rounded,
        'color': Colors.yellow.shade800,
      },
      {
        'value': 'Bank BRI',
        'label': 'Bank BRI',
        'subtitle': 'BRI – Melayani Hingga Pelosok',
        'icon': Icons.account_balance_rounded,
        'color': Colors.blue.shade900,
      },
      {
        'value': 'Bank BNI',
        'label': 'Bank BNI',
        'subtitle': 'BNI – Melayani Negeri Kebanggaan',
        'icon': Icons.account_balance_rounded,
        'color': Colors.orange.shade600,
      },
      {
        'value': 'Bank Syariah Indonesia (BSI)',
        'label': 'Bank Syariah Indonesia (BSI)',
        'subtitle': 'BSI – Perbankan Syariah Modern',
        'icon': Icons.account_balance_rounded,
        'color': Colors.teal.shade700,
      },
      {
        'value': 'Bank CIMB Niaga',
        'label': 'Bank CIMB Niaga',
        'subtitle': 'CIMB Niaga – Transaksi Cerdas',
        'icon': Icons.account_balance_rounded,
        'color': Colors.red.shade800,
      },
      {
        'value': 'Bank Permata',
        'label': 'Bank Permata',
        'subtitle': 'Permata Bank – Solusi Finansial Modern',
        'icon': Icons.account_balance_rounded,
        'color': Colors.green.shade700,
      },
      {
        'value': 'DBS Bank',
        'label': 'DBS Bank',
        'subtitle': 'DBS – Bank Terbesar di Asia Tenggara',
        'icon': Icons.account_balance_rounded,
        'color': Colors.red.shade600,
      },
      {
        'value': 'UOB Bank',
        'label': 'UOB Bank',
        'subtitle': 'UOB – Solusi Keuangan Regional Asia',
        'icon': Icons.account_balance_rounded,
        'color': Colors.blue.shade700,
      },
      {
        'value': 'HSBC Bank',
        'label': 'HSBC Bank',
        'subtitle': 'HSBC – Global Wealth & Banking',
        'icon': Icons.account_balance_rounded,
        'color': Colors.red.shade900,
      },
      {
        'value': 'Citibank',
        'label': 'Citibank',
        'subtitle': 'Citibank – Layanan Finansial Global',
        'icon': Icons.public_rounded,
        'color': Colors.blue.shade600,
      },
      {
        'value': 'Standard Chartered',
        'label': 'Standard Chartered',
        'subtitle': 'StanChart – Perbankan Internasional',
        'icon': Icons.account_balance_rounded,
        'color': Colors.green.shade800,
      },
      {
        'value': 'GoPay',
        'label': 'GoPay',
        'subtitle': 'GoPay – Ekosistem GoTo terintegrasi',
        'icon': Icons.account_balance_wallet_rounded,
        'color': Colors.teal.shade500,
      },
      {
        'value': 'OVO',
        'label': 'OVO',
        'subtitle': 'OVO – Cashback & merchant terluas',
        'icon': Icons.account_balance_wallet_rounded,
        'color': Colors.deepPurple.shade700,
      },
      {
        'value': 'Dana',
        'label': 'Dana',
        'subtitle': 'DANA – Dompet digital serbabisa',
        'icon': Icons.account_balance_wallet_rounded,
        'color': Colors.blue.shade400,
      },
      {
        'value': 'ShopeePay',
        'label': 'ShopeePay',
        'subtitle': 'ShopeePay – Belanja & promo Shopee',
        'icon': Icons.account_balance_wallet_rounded,
        'color': Colors.orange.shade900,
      },
      {
        'value': 'LinkAja',
        'label': 'LinkAja',
        'subtitle': 'LinkAja – Layanan BUMN & Transportasi',
        'icon': Icons.account_balance_wallet_rounded,
        'color': Colors.red.shade700,
      },
      {
        'value': 'PayPal',
        'label': 'PayPal',
        'subtitle': 'PayPal – Pembayaran Global Internasional',
        'icon': Icons.payment_rounded,
        'color': Colors.blue.shade900,
      },
      {
        'value': 'Wise',
        'label': 'Wise',
        'subtitle': 'Wise – Transfer & Saldo Multi-Mata Uang',
        'icon': Icons.sync_alt_rounded,
        'color': Colors.green.shade600,
      },
      {
        'value': 'Bank Lainnya',
        'label': 'Bank Lainnya',
        'subtitle': 'Bank digital/konvensional lainnya',
        'icon': Icons.more_horiz_rounded,
        'color': Colors.grey.shade600,
      },
    ];
    StateSetter? sheetSetter;

nameController.addListener(() {
      if (type == TransactionType.expense) {
        final text = nameController.text.toLowerCase();
        final adminKeywords = [
          'admin',
          'dana',
          'top up',
          'fee',
          'transfer',
          'biaya'
        ];

if (adminKeywords.any((k) => text.contains(k))) {
          const adminCat = 'Biaya Admin Bank';
          if (selectedCategory != adminCat) {
            sheetSetter?.call(() {
              selectedCategory = adminCat;
              selectedGroup = 'Keuangan';
            });
          }
        }
      }
    });
    String? selectedTopUpSource;
    String topUpBankName = '';
    String? selectedInterestBank;
    String interestOtherBankName = '';

    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    final topUpSources = [
      {
        'label': 'Bank (Kustom)',
        'subtitle': 'Masukkan nama bank secara manual',
        'icon': Icons.account_balance_rounded,
        'color': Colors.blueGrey.shade600,
      },

      {
        'label': 'GoPay',
        'subtitle': 'GoPay – Ekosistem GoTo terintegrasi',
        'icon': Icons.account_balance_wallet_rounded,
        'color': Colors.teal.shade500,
      },
      {
        'label': 'OVO',
        'subtitle': 'OVO – Cashback & merchant terluas',
        'icon': Icons.account_balance_wallet_rounded,
        'color': Colors.deepPurple.shade600,
      },
      {
        'label': 'Dana',
        'subtitle': 'DANA – Dompet digital serbabisa',
        'icon': Icons.account_balance_wallet_rounded,
        'color': Colors.blue.shade500,
      },
      {
        'label': 'ShopeePay',
        'subtitle': 'ShopeePay – Belanja & promo Shopee',
        'icon': Icons.account_balance_wallet_rounded,
        'color': Colors.orange.shade800,
      },
      {
        'label': 'LinkAja',
        'subtitle': 'LinkAja – Layanan BUMN & Transportasi',
        'icon': Icons.account_balance_wallet_rounded,
        'color': Colors.red.shade600,
      },
      {
        'label': 'Ovo Points',
        'subtitle': 'OVO Points – Konversi cashback OVO',
        'icon': Icons.star_rounded,
        'color': Colors.purple.shade400,
      },

      {
        'label': 'SeaBank',
        'subtitle': 'SeaBank – Top-up & transfer digital',
        'icon': Icons.savings_rounded,
        'color': Colors.teal.shade600,
      },
      {
        'label': 'Bank Jago',
        'subtitle': 'Jago – Fitur Kantong & transfer instan',
        'icon': Icons.account_balance_wallet_rounded,
        'color': Colors.orange.shade700,
      },
      {
        'label': 'Bank Neo Commerce',
        'subtitle': 'Neo – Admin gratis & bunga harian',
        'icon': Icons.bolt_rounded,
        'color': Colors.amber.shade700,
      },
      {
        'label': 'Blu by BCA',
        'subtitle': 'Blu – Bank digital by BCA',
        'icon': Icons.water_drop_rounded,
        'color': Colors.blue.shade400,
      },
      {
        'label': 'Allo Bank',
        'subtitle': 'Allo Bank – Belanja hemat Transmart',
        'icon': Icons.credit_card_rounded,
        'color': Colors.purple.shade500,
      },

      {
        'label': 'Bank BCA',
        'subtitle': 'BCA – Bank Swasta Nasional Terbesar',
        'icon': Icons.account_balance_rounded,
        'color': Colors.blue.shade800,
      },
      {
        'label': 'Bank Mandiri',
        'subtitle': 'Mandiri – Bank BUMN Terbesar',
        'icon': Icons.account_balance_rounded,
        'color': Colors.yellow.shade700,
      },
      {
        'label': 'Bank BRI',
        'subtitle': 'BRI – Melayani Hingga Pelosok',
        'icon': Icons.account_balance_rounded,
        'color': Colors.blue.shade900,
      },
      {
        'label': 'Bank BNI',
        'subtitle': 'BNI – Melayani Negeri Kebanggaan',
        'icon': Icons.account_balance_rounded,
        'color': Colors.orange.shade600,
      },
      {
        'label': 'Bank BSI',
        'subtitle': 'BSI – Perbankan Syariah Terbesar',
        'icon': Icons.account_balance_rounded,
        'color': Colors.teal.shade700,
      },
      {
        'label': 'Bank CIMB Niaga',
        'subtitle': 'CIMB Niaga – Transaksi Cerdas',
        'icon': Icons.account_balance_rounded,
        'color': Colors.red.shade700,
      },
      {
        'label': 'Bank Permata',
        'subtitle': 'PermataBank – Layanan Prima',
        'icon': Icons.account_balance_rounded,
        'color': Colors.green.shade700,
      },
      {
        'label': 'Bank Danamon',
        'subtitle': 'Danamon – Layanan Perbankan Lengkap',
        'icon': Icons.account_balance_rounded,
        'color': Colors.blue.shade600,
      },
      {
        'label': 'Bank Mega',
        'subtitle': 'Bank Mega – Solusi Finansial Modern',
        'icon': Icons.account_balance_rounded,
        'color': Colors.deepOrange.shade600,
      },
      {
        'label': 'Bank Panin',
        'subtitle': 'Panin Bank – Tabungan & Investasi',
        'icon': Icons.account_balance_rounded,
        'color': Colors.indigo.shade500,
      },

      {
        'label': 'DBS Bank',
        'subtitle': 'DBS – Bank Terbesar di Asia Tenggara',
        'icon': Icons.account_balance_rounded,
        'color': Colors.red.shade500,
      },
      {
        'label': 'HSBC Bank',
        'subtitle': 'HSBC – Global Wealth & Banking',
        'icon': Icons.account_balance_rounded,
        'color': Colors.red.shade800,
      },
      {
        'label': 'Citibank',
        'subtitle': 'Citibank – Layanan Finansial Global',
        'icon': Icons.public_rounded,
        'color': Colors.blue.shade600,
      },
      {
        'label': 'UOB Bank',
        'subtitle': 'UOB – Solusi Keuangan Regional Asia',
        'icon': Icons.account_balance_rounded,
        'color': Colors.blue.shade700,
      },
      {
        'label': 'Standard Chartered',
        'subtitle': 'StanChart – Perbankan Internasional',
        'icon': Icons.account_balance_rounded,
        'color': Colors.green.shade800,
      },

      {
        'label': 'PayPal',
        'subtitle': 'PayPal – Pembayaran Global Internasional',
        'icon': Icons.payment_rounded,
        'color': Colors.blue.shade900,
      },
      {
        'label': 'Wise',
        'subtitle': 'Wise – Transfer Multi-Mata Uang',
        'icon': Icons.sync_alt_rounded,
        'color': Colors.green.shade600,
      },
      {
        'label': 'Revolut',
        'subtitle': 'Revolut – Neo-bank Digital Global',
        'icon': Icons.account_balance_wallet_rounded,
        'color': Colors.indigo.shade700,
      },
      {
        'label': 'Jenius',
        'subtitle': 'Jenius – Kartu Debit & Tabungan Digital',
        'icon': Icons.credit_card_rounded,
        'color': Colors.teal.shade400,
      },
    ];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        bool prevKeyboardVisible = false;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            sheetSetter = setSheetState;
            final inset = MediaQuery.of(context).viewInsets.bottom;
            final isKeyboardVisible = inset > 0;

            if (prevKeyboardVisible && !isKeyboardVisible) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
            prevKeyboardVisible = isKeyboardVisible;

final formContrastColor = Colors.teal;
            final formLabelColor = isDarkMode ? Colors.white70 : Colors.black87;
            final formSubTextColor =
                isDarkMode ? Colors.white54 : Colors.black54;
            final formBorderColor =
                isDarkMode ? Colors.white10 : Colors.black26;

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
                  autovalidateMode: AutovalidateMode.disabled,
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
                                  ? 'Tambah Pengeluaran'
                                  : 'Tambah Pemasukan',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.bold,
                                fontSize: 19,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.quicksand(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.black87),
                                  children: const [
                                    TextSpan(text: 'Nominal Transaksi '),
                                    TextSpan(
                                      text: '*',
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: amountController,
                                autofocus: false,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.left,
                                style: GoogleFonts.quicksand(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  RibuanFormatter(),
                                ],
                                onChanged: (val) => setSheetState(() {}),
                                onEditingComplete: () =>
                                    FocusScope.of(context).unfocus(),
                                onTapOutside: (event) =>
                                    FocusScope.of(context).unfocus(),
                                decoration: InputDecoration(
                                  hintText: 'Masukkan Nominal',
                                  hintStyle: GoogleFonts.quicksand(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white10
                                        : formSubTextColor,
                                  ),
                                  prefixIcon: Container(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.payments_rounded,
                                          color: type == TransactionType.income
                                              ? AppColors.primary
                                              : const Color(0xFFE53935),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Rp',
                                          style: GoogleFonts.quicksand(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                type == TransactionType.income
                                                    ? AppColors.primary
                                                    : const Color(0xFFE53935),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: isDarkMode
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: formBorderColor, width: 1.2)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: formBorderColor, width: 1.2)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: formContrastColor,
                                          width: 1.5)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
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
                            ],
                          ),
                        ),
                        if (type == TransactionType.income) ...[
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Pilih Bank / Jenis Bunga',
                                    style: GoogleFonts.quicksand(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isDarkMode
                                            ? Colors.white70
                                            : Colors.black87)),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  initialValue: selectedInterestBank,
                                  isExpanded: true,
                                  isDense: true,
                                  itemHeight: 56,
                                  dropdownColor: isDarkMode
                                      ? AppColors.surfaceDark
                                      : Colors.white,
                                  decoration: InputDecoration(
                                    hintText: 'Pilih Bank / Jenis Bunga',
                                    filled: true,
                                    fillColor: isDarkMode
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: formBorderColor,
                                            width: 1.2)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: formBorderColor,
                                            width: 1.2)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: formContrastColor,
                                            width: 1.5)),
                                    prefixIcon: Icon(
                                        Icons.account_balance_rounded,
                                        color: AppColors.primary,
                                        size: 20),
                                    labelStyle: GoogleFonts.quicksand(
                                        color: formLabelColor),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                  selectedItemBuilder: (context) {
                                    return [
                                      Text('None',
                                          style: GoogleFonts.quicksand(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: isDarkMode
                                                  ? Colors.white54
                                                  : Colors.black54)),
                                      ...(interestBankOptions.map((item) {
                                        return Text(item['label'] as String,
                                            style: GoogleFonts.quicksand(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: isDarkMode
                                                    ? Colors.white70
                                                    : Colors.black87));
                                      }))
                                    ];
                                  },
                                  items: [
                                    DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('None',
                                          style: GoogleFonts.quicksand(
                                              color: isDarkMode
                                                  ? Colors.white54
                                                  : Colors.black54)),
                                    ),
                                    ...(interestBankOptions.map((item) {
                                      return DropdownMenuItem<String>(
                                        value: item['value'] as String,
                                        child: Row(
                                          children: [
                                            Icon(
                                              item['icon'] as IconData,
                                              size: 18,
                                              color: item['color'] as Color,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    item['label'] as String,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.quicksand(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 11,
                                                            color: isDarkMode
                                                                ? Colors.white70
                                                                : Colors
                                                                    .black87),
                                                  ),
                                                  Text(
                                                    item['subtitle'] as String,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts.quicksand(
                                                        fontSize: 9.5,
                                                        color:
                                                            formSubTextColor),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    })),
                                  ],
                                  onChanged: (val) {
                                    setSheetState(() {
                                      selectedInterestBank = val;
                                      interestOtherBankName = '';
                                      if (val == null) {
                                        if (nameController.text
                                            .startsWith('Bunga ')) {
                                          nameController.clear();
                                        }
                                        categoryUserSelected = false;
                                      } else if (val == 'Bank Lainnya') {

                                        if (nameController.text.isEmpty ||
                                            nameController.text
                                                .startsWith('Bunga ')) {
                                          final now = DateTime.now();
                                          const monthNames = [
                                            '',
                                            'Januari', 'Februari', 'Maret',
                                            'April', 'Mei', 'Juni', 'Juli',
                                            'Agustus', 'September', 'Oktober',
                                            'November', 'Desember',
                                          ];
                                          nameController.text =
                                              'Bunga Bank ${now.day} ${monthNames[now.month]} ${now.year}';
                                        }
                                        categoryUserSelected = true;
                                        selectedCategory =
                                            'Bunga Bank & Deposito';
                                        selectedGroup = 'Keuangan & Bank';
                                      } else {
                                        final now = DateTime.now();
                                        final monthName = [
                                          '',
                                          'Januari',
                                          'Februari',
                                          'Maret',
                                          'April',
                                          'Mei',
                                          'Juni',
                                          'Juli',
                                          'Agustus',
                                          'September',
                                          'Oktober',
                                          'November',
                                          'Desember'
                                        ][now.month];
                                        String bankClean = val
                                            .replaceAll(' (Premium)', '')
                                            .replaceAll(' (Standar)', '');

if (nameController.text.isEmpty ||
                                            nameController.text
                                                .startsWith('Bunga ')) {
                                          nameController.text =
                                              'Bunga $bankClean ${now.day} $monthName ${now.year}';
                                        }

                                        categoryUserSelected = true;
                                        selectedCategory =
                                            'Bunga Bank & Deposito';
                                        selectedGroup = 'Keuangan & Bank';
                                      }
                                    });

                                    FocusScope.of(context).unfocus();
                                  },
                                ),
                                if (selectedInterestBank == 'Bank Lainnya') ...[
                                  const SizedBox(height: 16),
                                  RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.quicksand(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isDarkMode
                                              ? Colors.white70
                                              : Colors.black87),
                                      children: const [
                                        TextSpan(text: 'Nama Bank (Opsional)'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: interestBankController,
                                    style: GoogleFonts.quicksand(
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black87),
                                    decoration: InputDecoration(
                                      hintText: 'Masukkan Nama Bank',
                                      filled: true,
                                      fillColor: isDarkMode
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: formBorderColor,
                                              width: 1.2)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: formBorderColor,
                                              width: 1.2)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: formContrastColor,
                                              width: 1.5)),
                                      prefixIcon: Icon(
                                          Icons.account_balance_rounded,
                                          color: AppColors.primary,
                                          size: 20),
                                      labelStyle: GoogleFonts.quicksand(
                                          color: formLabelColor),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                    ),
                                    onChanged: (val) {
                                      interestOtherBankName = val;
                                    },
                                    onEditingComplete: () {
                                      _applyInterestBankNameToKeterangan(
                                        nameController: nameController,
                                        bankName: interestBankController.text,
                                        setSheetState: setSheetState,
                                      );
                                      FocusScope.of(context).unfocus();
                                    },
                                    onTapOutside: (_) {
                                      _applyInterestBankNameToKeterangan(
                                        nameController: nameController,
                                        bankName: interestBankController.text,
                                        setSheetState: setSheetState,
                                      );
                                      FocusScope.of(context).unfocus();
                                    },
                                  ),
                                ],
                                if (selectedInterestBank != null) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: isDarkMode
                                            ? [
                                                AppColors.primary
                                                    .withValues(alpha: 0.25),
                                                AppColors.primary
                                                    .withValues(alpha: 0.15),
                                              ]
                                            : [
                                                Colors.grey.shade100,
                                                Colors.white,
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.25)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            Icons.info_outline_rounded,
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                selectedInterestBank ==
                                                            'Bank Lainnya' &&
                                                        interestOtherBankName
                                                            .trim()
                                                            .isNotEmpty
                                                    ? 'Bunga ${interestOtherBankName.trim()}'
                                                    : 'Bunga $selectedInterestBank',
                                                style: GoogleFonts.quicksand(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                    color: isDarkMode
                                                        ? Colors.white
                                                        : Colors.black87),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                selectedInterestBank ==
                                                        'SeaBank (Premium)'
                                                    ? '7,4% p.a. dihitung harian untuk saldo ≥ Rp 1 juta. Dikreditkan otomatis setiap hari.'
                                                    : selectedInterestBank ==
                                                            'SeaBank (Standar)'
                                                        ? '2,5% p.a. Tanpa saldo minimum, bebas tarik kapan saja. Bunga dihitung & dikreditkan harian.'
                                                        : selectedInterestBank ==
                                                                'SeaBank (Deposito)'
                                                            ? 'Sampai dengan 6% p.a. Bunga deposito tinggi untuk simpanan berjangka Anda.'
                                                            : selectedInterestBank ==
                                                                    'Bank Lainnya'
                                                                ? 'Masukkan nama bank Anda di kolom atas. Nama transaksi akan terisi otomatis.'
                                                                : 'Bunga tabungan dari $selectedInterestBank. Tambahkan catatan nominal pajak jika diperlukan.',
                                                style: GoogleFonts.quicksand(
                                                    fontSize: 11,
                                                    color: isDarkMode
                                                        ? Colors.white54
                                                        : Colors.black54),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        if (type == TransactionType.expense) ...[
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.quicksand(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isDarkMode
                                            ? Colors.white70
                                            : Colors.black87),
                                    children: const [
                                      TextSpan(
                                          text:
                                              'Biaya Admin Top-Up (Opsional)'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  initialValue: selectedTopUpSource,
                                  isExpanded: true,
                                  isDense: true,
                                  itemHeight: 56,
                                  dropdownColor: isDarkMode
                                      ? AppColors.surfaceDark
                                      : Colors.white,
                                  decoration: InputDecoration(
                                    hintText: 'Pilih Sumber Top-up',
                                    filled: true,
                                    fillColor: isDarkMode
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: formBorderColor,
                                            width: 1.2)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: formBorderColor,
                                            width: 1.2)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: formContrastColor,
                                            width: 1.5)),
                                    prefixIcon: Icon(
                                        selectedTopUpSource == 'Bank (Kustom)'
                                            ? Icons.account_balance_rounded
                                            : Icons
                                                .account_balance_wallet_rounded,
                                        color: AppColors.primary,
                                        size: 20),
                                    labelStyle: GoogleFonts.quicksand(
                                        color: isDarkMode
                                            ? Colors.white38
                                            : Colors.black45),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                  ),
                                  selectedItemBuilder: (context) {
                                    return [
                                      Text('None',
                                          style: GoogleFonts.quicksand(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: isDarkMode
                                                  ? Colors.white54
                                                  : Colors.black54)),
                                      ...topUpSources.map((source) {
                                        return Text(
                                            source['label'] as String,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.quicksand(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: isDarkMode
                                                    ? Colors.white70
                                                    : Colors.black87));
                                      }),
                                    ];
                                  },
                                  items: [
                                    DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('None',
                                          style: GoogleFonts.quicksand(
                                              color: isDarkMode
                                                  ? Colors.white54
                                                  : Colors.black54)),
                                    ),
                                    ...topUpSources.map((source) {
                                      final label = source['label'] as String;
                                      final subtitle = source['subtitle'] as String;
                                      final icon = source['icon'] as IconData;
                                      final color = source['color'] as Color;
                                      return DropdownMenuItem<String>(
                                        value: label,
                                        child: Row(
                                          children: [
                                            Icon(icon, size: 18, color: color),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    label,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: GoogleFonts.quicksand(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 11,
                                                        color: isDarkMode
                                                            ? Colors.white70
                                                            : Colors.black87),
                                                  ),
                                                  Text(
                                                    subtitle,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: GoogleFonts.quicksand(
                                                        fontSize: 9.5,
                                                        color: formSubTextColor),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                  onChanged: (val) {
                                    setSheetState(() {
                                      selectedTopUpSource = val;
                                      if (val == null) {
                                        if (nameController.text
                                            .startsWith('Biaya Admin')) {
                                          nameController.clear();
                                        }
                                        categoryUserSelected = false;
                                      } else if (val != 'Bank (Kustom)') {
                                        if (nameController.text.isEmpty ||
                                            nameController.text
                                                .startsWith('Biaya Admin')) {
                                          final now = DateTime.now();
                                          final monthNames = [
                                            '',
                                            'Januari', 'Februari', 'Maret',
                                            'April', 'Mei', 'Juni', 'Juli',
                                            'Agustus', 'September', 'Oktober',
                                            'November', 'Desember'
                                          ];
                                          final monthName =
                                              monthNames[now.month];
                                          nameController.text =
                                              'Biaya Admin $val ${now.day} $monthName ${now.year}';
                                        }
                                        categoryUserSelected = true;
                                        selectedCategory = 'Biaya Admin Bank';
                                        selectedGroup = 'Keuangan';
                                      } else {
                                        if (nameController.text.isEmpty ||
                                            nameController.text
                                                .startsWith('Biaya Admin')) {
                                          final now = DateTime.now();
                                          final monthNames = [
                                            '',
                                            'Januari', 'Februari', 'Maret',
                                            'April', 'Mei', 'Juni', 'Juli',
                                            'Agustus', 'September', 'Oktober',
                                            'November', 'Desember'
                                          ];
                                          final monthName =
                                              monthNames[now.month];
                                          final bankName =
                                              topUpBankName.trim();
                                          nameController.text = bankName.isEmpty
                                              ? 'Biaya Admin Bank ${now.day} $monthName ${now.year}'
                                              : 'Biaya Admin $bankName ${now.day} $monthName ${now.year}';
                                        }
                                        categoryUserSelected = true;
                                        selectedCategory = 'Biaya Admin Bank';
                                        selectedGroup = 'Keuangan';
                                      }
                                    });
                                    FocusScope.of(context).unfocus();
                                  },
                                ),
                                if (selectedTopUpSource == 'Bank (Kustom)') ...[
                                  const SizedBox(height: 16),
                                  RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.quicksand(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isDarkMode
                                              ? Colors.white70
                                              : Colors.black87),
                                      children: const [
                                        TextSpan(text: 'Nama Bank (Opsional)'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: topUpBankController,
                                    style: GoogleFonts.quicksand(
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black87),
                                    decoration: InputDecoration(
                                      hintText: 'Masukkan Nama Bank',
                                      filled: true,
                                      fillColor: isDarkMode
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: formBorderColor,
                                              width: 1.2)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: formBorderColor,
                                              width: 1.2)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: formContrastColor,
                                              width: 1.5)),
                                      prefixIcon: Icon(
                                          Icons.account_balance_rounded,
                                          color: AppColors.primary,
                                          size: 20),
                                      labelStyle: GoogleFonts.quicksand(
                                          color: isDarkMode
                                              ? Colors.white38
                                              : Colors.black45),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                    ),
                                    onChanged: (val) {
                                      topUpBankName = val;
                                    },
                                    onEditingComplete: () {
                                      _applyTopUpBankNameToKeterangan(
                                        nameController: nameController,
                                        bankName: topUpBankController.text,
                                        setSheetState: setSheetState,
                                      );
                                      FocusScope.of(context).unfocus();
                                    },
                                    onTapOutside: (_) {
                                      _applyTopUpBankNameToKeterangan(
                                        nameController: nameController,
                                        bankName: topUpBankController.text,
                                        setSheetState: setSheetState,
                                      );
                                      FocusScope.of(context).unfocus();
                                    },
                                  ),
                                ],
                                if (selectedTopUpSource != null) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: isDarkMode
                                            ? [
                                                formContrastColor
                                                    .withValues(alpha: 0.25),
                                                formContrastColor
                                                    .withValues(alpha: 0.15),
                                              ]
                                            : [
                                                Colors.grey.shade100,
                                                Colors.white,
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: formContrastColor
                                              .withValues(alpha: 0.25)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: formContrastColor
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            Icons.info_outline_rounded,
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                selectedTopUpSource ==
                                                            'Bank (Kustom)' &&
                                                        topUpBankName
                                                            .trim()
                                                            .isNotEmpty
                                                    ? 'Biaya Admin ${topUpBankName.trim()}'
                                                    : 'Biaya Admin $selectedTopUpSource',
                                                style: GoogleFonts.quicksand(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                    color: isDarkMode
                                                        ? Colors.white
                                                        : Colors.black87),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                selectedTopUpSource == 'GoPay'
                                                    ? 'Biaya top-up Rp 1.000 - Rp 2.000 via Mobile Banking / ATM. Bebas biaya jika menggunakan GoPay Tabungan.'
                                                    : selectedTopUpSource == 'OVO'
                                                        ? 'Biaya top-up Rp 1.000 - Rp 1.500 dipotong langsung dari nominal yang Anda top-up.'
                                                        : selectedTopUpSource == 'Dana'
                                                            ? 'Biaya top-up Rp 500 - Rp 1.000 via Virtual Account. Bebas biaya admin transfer keluar 10x per bulan.'
                                                            : selectedTopUpSource == 'ShopeePay'
                                                                ? 'Biaya top-up Rp 500 - Rp 1.000 via Transfer Bank / Virtual Account.'
                                                                : selectedTopUpSource == 'LinkAja'
                                                                    ? 'Biaya top-up Rp 1.000 via ATM Himbara & Mobile Banking.'
                                                                    : selectedTopUpSource == 'Ovo Points'
                                                                        ? 'Menggunakan cashback points OVO. Bebas biaya admin tambahan.'
                                                                        : selectedTopUpSource == 'SeaBank'
                                                                            ? 'Bebas biaya transfer ke seluruh bank & e-wallet (kuota bulanan melimpah).'
                                                                            : selectedTopUpSource == 'Bank Jago'
                                                                                ? 'Bebas biaya transfer ke seluruh bank & e-wallet hingga 150x per bulan sesuai level Kantong.'
                                                                                : selectedTopUpSource == 'Bank Neo Commerce'
                                                                                    ? 'Bebas biaya transfer antar bank & bunga cair harian tinggi.'
                                                                                    : selectedTopUpSource == 'Blu by BCA'
                                                                                        ? 'Bebas biaya transfer antar bank (BI-Fast) dengan metode bluRewards.'
                                                                                        : selectedTopUpSource == 'Allo Bank'
                                                                                            ? 'Bebas biaya transfer jika menggunakan Allo Prime & saldo mencukupi.'
                                                                                            : selectedTopUpSource == 'Bank BCA'
                                                                                                ? 'Biaya transfer antar bank Rp 6.500 (Online) atau Rp 2.500 (BI-Fast).'
                                                                                                : selectedTopUpSource == 'Bank Mandiri'
                                                                                                    ? 'Biaya transfer antar bank Rp 6.500 (Online) atau Rp 2.500 (BI-Fast) via Livin\' by Mandiri.'
                                                                                                    : selectedTopUpSource == 'Bank BRI'
                                                                                                        ? 'Biaya transfer antar bank Rp 6.500 (Online) atau Rp 2.500 (BI-Fast) via BRIMO.'
                                                                                                        : selectedTopUpSource == 'Bank BNI'
                                                                                                            ? 'Biaya transfer antar bank Rp 6.500 (Online) atau Rp 2.500 (BI-Fast) via BNI Mobile.'
                                                                                                            : selectedTopUpSource == 'Bank Syariah Indonesia (BSI)'
                                                                                                                ? 'Biaya transfer antar bank Rp 6.500 (Online) atau Rp 2.500 (BI-Fast) via BSI Mobile.'
                                                                                                                : selectedTopUpSource == 'Bank CIMB Niaga'
                                                                                                                    ? 'Biaya transfer antar bank Rp 6.500 (Online) atau Rp 2.500 (BI-Fast) via OCTO Mobile.'
                                                                                                                    : selectedTopUpSource == 'Bank Permata'
                                                                                                                        ? 'Biaya transfer antar bank Rp 6.500 (Online) atau Rp 2.500 (BI-Fast) via PermataMobile X.'
                                                                                                                        : selectedTopUpSource == 'Bank Danamon'
                                                                                                                            ? 'Biaya transfer antar bank Rp 6.500 (Online) atau Rp 2.500 (BI-Fast) via D-Bank PRO.'
                                                                                                                            : selectedTopUpSource == 'Bank Mega'
                                                                                                                                ? 'Biaya transfer antar bank Rp 6.500 (Online) atau Rp 2.500 (BI-Fast) via M-Smile.'
                                                                                                                                : selectedTopUpSource == 'Bank Panin'
                                                                                                                                    ? 'Biaya transfer antar bank Rp 6.500 (Online) atau Rp 2.500 (BI-Fast) via Mobile Panin.'
                                                                                                                                    : selectedTopUpSource == 'DBS Bank'
                                                                                                                                        ? 'Bebas biaya transfer menggunakan Digibank ke seluruh bank di Indonesia.'
                                                                                                                                        : selectedTopUpSource == 'HSBC Bank'
                                                                                                                                            ? 'Biaya transfer antar bank internasional / lokal bervariasi bergantung jenis akun HSBC Anda.'
                                                                                                                                            : selectedTopUpSource == 'Citibank'
                                                                                                                                                ? 'Biaya transfer antar bank internasional / lokal bervariasi bergantung level wealth / nasabah prima.'
                                                                                                                                                : selectedTopUpSource == 'UOB Bank'
                                                                                                                                                    ? 'Biaya transfer antar bank Rp 6.500 (Online) atau Rp 2.500 (BI-Fast) via TMRW by UOB.'
                                                                                                                                                    : selectedTopUpSource == 'Standard Chartered'
                                                                                                                                                        ? 'Biaya transfer antar bank internasional / lokal bervariasi.'
                                                                                                                                                        : selectedTopUpSource == 'PayPal'
                                                                                                                                                            ? 'Fee penarikan ke bank lokal Rp 16.000 jika penarikan di bawah Rp 1.500.000. Gratis jika di atas Rp 1.500.000.'
                                                                                                                                                            : selectedTopUpSource == 'Wise'
                                                                                                                                                                ? 'Biaya pengiriman uang internasional murah & transparan, menggunakan kurs pasar riil tanpa markup.'
                                                                                                                                                                : selectedTopUpSource == 'Revolut'
                                                                                                                                                                    ? 'Biaya kirim / tukar mata uang asing bervariasi dengan kuota gratis sesuai jenis paket member bulanan.'
                                                                                                                                                                    : selectedTopUpSource == 'Jenius'
                                                                                                                                                                        ? 'Bebas biaya transfer ke seluruh bank & e-wallet hingga 25x per bulan tergantung level saldo (Feesible).'
                                                                                                                                                                        : 'Biaya administrasi top-up/transfer default berkisar Rp 1.000 - Rp 6.500 bergantung pada bank yang Anda gunakan.',
                                                style: GoogleFonts.quicksand(
                                                    fontSize: 11,
                                                    color: isDarkMode
                                                        ? Colors.white54
                                                        : Colors.black54),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
                              const SizedBox(height: 20),
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.quicksand(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.black87),
                                  children: const [
                                    TextSpan(text: 'Keterangan Transaksi '),
                                    TextSpan(
                                      text: '*',
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: nameController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87),
                                decoration: InputDecoration(
                                  hintText: 'Masukkan Keterangan',
                                  filled: true,
                                  fillColor: isDarkMode
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: formBorderColor, width: 1.2)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: formBorderColor, width: 1.2)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: formContrastColor,
                                          width: 1.5)),
                                  prefixIcon: Icon(Icons.edit_note_rounded,
                                      color: AppColors.primary, size: 20),
                                  hintStyle: GoogleFonts.quicksand(
                                      color: formSubTextColor),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                                onChanged: (val) {
                                  if (type == TransactionType.expense) {
                                    final lowerVal = val.toLowerCase();
                                    if (lowerVal.contains('makan') ||
                                        lowerVal.contains('minum') ||
                                        lowerVal.contains('warung') ||
                                        lowerVal.contains('nasi')) {
                                      setSheetState(() {
                                        categoryUserSelected = true;
                                        selectedCategory =
                                            'Makanan & Minuman Harian';
                                        selectedGroup = 'Kebutuhan Pokok';
                                      });
                                    } else if (lowerVal.contains('sembako') ||
                                        lowerVal.contains('beras') ||
                                        lowerVal.contains('minyak')) {
                                      setSheetState(() {
                                        categoryUserSelected = true;
                                        selectedCategory =
                                            'Belanja Sembako / Pasar';
                                        selectedGroup = 'Kebutuhan Pokok';
                                      });
                                    } else if (lowerVal.contains('listrik') ||
                                        lowerVal.contains('pln') ||
                                        lowerVal.contains('token')) {
                                      setSheetState(() {
                                        categoryUserSelected = true;
                                        selectedCategory =
                                            'Token Listrik / PLN';
                                        selectedGroup = 'Kebutuhan Pokok';
                                      });
                                    } else if (lowerVal.contains('bensin') ||
                                        lowerVal.contains('pertalite') ||
                                        lowerVal.contains('pertamax') ||
                                        lowerVal.contains('spbu')) {
                                      setSheetState(() {
                                        categoryUserSelected = true;
                                        selectedCategory = 'Bahan Bakar (BBM)';
                                        selectedGroup = 'Transportasi';
                                      });
                                    } else if (lowerVal.contains('ojek') ||
                                        lowerVal.contains('gojek') ||
                                        lowerVal.contains('grab') ||
                                        lowerVal.contains('maxim')) {
                                      setSheetState(() {
                                        categoryUserSelected = true;
                                        selectedCategory =
                                            'Ojek Online (Gojek/Grab)';
                                        selectedGroup = 'Transportasi';
                                      });
                                    } else if (lowerVal.contains('pulsa') ||
                                        lowerVal.contains('kuota') ||
                                        lowerVal.contains('data')) {
                                      setSheetState(() {
                                        categoryUserSelected = true;
                                        selectedCategory =
                                            'Pulsa & Paket Data Seluler';
                                        selectedGroup = 'Teknologi';
                                      });
                                    } else if (lowerVal.contains('wifi') ||
                                        lowerVal.contains('indihome') ||
                                        lowerVal.contains('biznet')) {
                                      setSheetState(() {
                                        categoryUserSelected = true;
                                        selectedCategory =
                                            'WiFi / Internet Rumah';
                                        selectedGroup = 'Teknologi';
                                      });
                                    } else if (lowerVal.contains('netflix') ||
                                        lowerVal.contains('disney') ||
                                        lowerVal.contains('spotify') ||
                                        lowerVal.contains('youtube')) {
                                      setSheetState(() {
                                        categoryUserSelected = true;
                                        selectedCategory =
                                            'Langganan Netflix / Disney+';
                                        selectedGroup = 'Teknologi';
                                      });
                                    } else if (lowerVal.contains('obat') ||
                                        lowerVal.contains('sakit') ||
                                        lowerVal.contains('vitamin') ||
                                        lowerVal.contains('apotek')) {
                                      setSheetState(() {
                                        categoryUserSelected = true;
                                        selectedCategory = 'Obat & Vitamin';
                                        selectedGroup = 'Kesehatan';
                                      });
                                    } else if (lowerVal.contains('kopi') ||
                                        lowerVal.contains('coffee') ||
                                        lowerVal.contains('cafe') ||
                                        lowerVal.contains('nongkrong')) {
                                      setSheetState(() {
                                        categoryUserSelected = true;
                                        selectedCategory =
                                            'Nongkrong / Coffee Shop';
                                        selectedGroup = 'Gaya Hidup';
                                      });
                                    } else if (lowerVal.contains('zakat') ||
                                        lowerVal.contains('sedekah') ||
                                        lowerVal.contains('infak')) {
                                      setSheetState(() {
                                        categoryUserSelected = true;
                                        selectedCategory =
                                            'Zakat / Infak / Sedekah';
                                        selectedGroup = 'Sosial & Ibadah';
                                      });
                                    } else if (lowerVal.contains('admin') ||
                                        lowerVal.contains('biaya') ||
                                        lowerVal.contains('fee') ||
                                        lowerVal.contains('top up')) {
                                      setSheetState(() {
                                        categoryUserSelected = true;
                                        selectedCategory = 'Biaya Admin Bank';
                                        selectedGroup = 'Keuangan';
                                      });
                                    } else if (lowerVal.contains('hutang') ||
                                        lowerVal.contains('cicilan') ||
                                        lowerVal.contains('pinjol') ||
                                        lowerVal.contains('bayar')) {
                                      setSheetState(() {
                                        categoryUserSelected = true;
                                        selectedCategory =
                                            'Bayar Hutang / Pinjol';
                                        selectedGroup = 'Keuangan';
                                      });
                                    }
                                  }
                                },
                                onEditingComplete: () =>
                                    FocusScope.of(context).unfocus(),
                                onTapOutside: (event) =>
                                    FocusScope.of(context).unfocus(),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Keterangan transaksi harus diisi!';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.quicksand(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.black87),
                                  children: const [
                                    TextSpan(text: 'Pilih Kategori '),
                                    TextSpan(
                                      text: '*',
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              InkWell(
                                onTap: () {
                                  _showCategorySearchSheet(
                                    context: context,
                                    type: type,
                                    isDarkMode: isDarkMode,
                                    currentSelected: categoryUserSelected ? selectedCategory : '',
                                    categoryObjects: categoryObjects,
                                    onSelected: (cat) {
                                      setSheetState(() {
                                        categoryUserSelected = true;
                                        selectedCategory = cat.label;
                                        selectedGroup = cat.group;
                                        categoryUserSelected = true;
                                      });
                                    },
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: !categoryUserSelected
                                          ? formBorderColor
                                          : (categoryObjects.any((c) =>
                                                  c.label == selectedCategory)
                                              ? categoryObjects
                                                  .firstWhere((c) =>
                                                      c.label == selectedCategory)
                                                  .color
                                              : formBorderColor),
                                      width: 1.2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        !categoryUserSelected
                                            ? Icons.category_rounded
                                            : (categoryObjects.any((c) =>
                                                    c.label == selectedCategory)
                                                ? categoryObjects
                                                    .firstWhere((c) =>
                                                        c.label == selectedCategory)
                                                    .icon
                                                : Icons.category_rounded),
                                        size: 20,
                                        color: !categoryUserSelected
                                            ? (isDarkMode
                                                ? Colors.white38
                                                : Colors.black38)
                                            : (selectedCategory ==
                                                    AppCategories.otherLabel)
                                                ? AppColors.primary
                                                : (categoryObjects.any((c) =>
                                                        c.label ==
                                                        selectedCategory)
                                                    ? categoryObjects
                                                        .firstWhere((c) =>
                                                            c.label ==
                                                            selectedCategory)
                                                        .color
                                                    : AppColors.primary),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          !categoryUserSelected
                                              ? 'Pilih Kategori...'
                                              : selectedCategory,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.quicksand(
                                            fontWeight: !categoryUserSelected
                                                ? FontWeight.w500
                                                : FontWeight.bold,
                                            fontSize: 14,
                                            color: !categoryUserSelected
                                                ? (isDarkMode
                                                    ? Colors.white38
                                                    : Colors.black38)
                                                : (isDarkMode
                                                    ? Colors.white
                                                    : Colors.black87),
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down_rounded,
                                        size: 28,
                                        color: isDarkMode
                                            ? Colors.white38
                                            : Colors.black38,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (selectedCategory ==
                                  AppCategories.otherLabel) ...[
                                const SizedBox(height: 16),
                                RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.quicksand(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                    children: const [
                                      TextSpan(text: 'Nama Kategori Kustom '),
                                      TextSpan(
                                        text: '*',
                                        style:
                                            TextStyle(color: Colors.redAccent),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: customCategoryController,
                                  style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black87),
                                  decoration: InputDecoration(
                                    hintText: type == TransactionType.income
                                        ? 'Misal: Hibah dari Atasan'
                                        : 'Misal: Gym, Netflix, Skincare...',
                                    filled: true,
                                    fillColor: isDarkMode
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: formBorderColor,
                                            width: 1.2)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: formBorderColor,
                                            width: 1.2)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: formContrastColor,
                                            width: 1.5)),
                                    prefixIcon: Icon(Icons.star_rounded,
                                        color: AppColors.primary, size: 20),
                                    hintStyle: GoogleFonts.quicksand(
                                        color: formSubTextColor),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                  validator: (val) {
                                    if (selectedCategory ==
                                            AppCategories.otherLabel &&
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
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () async {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }
                                  if (!categoryUserSelected) {
                                    setSheetState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.redAccent,
                                          content: Text(
                                            'Pilih kategori terlebih dahulu!',
                                            style: GoogleFonts.quicksand(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                        ));
                                    return;
                                  }

                                  final amount =
                                      _toAmount(amountController.text);
                                  if (amount == null) {
                                    return;
                                  }

                                  final finalCategory = (selectedCategory ==
                                              AppCategories.otherLabel &&
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
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  elevation: 4,
                                  shadowColor:
                                      AppColors.primary.withValues(alpha: 0.3),
                                ),
                                child: Text('Simpan Transaksi',
                                    style: GoogleFonts.quicksand(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        letterSpacing: 0.5)),
                              ),
                              const SizedBox(height: 24),
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

  void _showCategorySearchSheet({
    required BuildContext context,
    required TransactionType type,
    required bool isDarkMode,
    required String currentSelected,
    required List<TransactionCategory> categoryObjects,
    required ValueChanged<TransactionCategory> onSelected,
  }) {
    FocusScope.of(context).unfocus();
    final searchController = TextEditingController();
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {

            final Map<String, List<TransactionCategory>> displayGrouped = {};
            for (var cat in categoryObjects) {
              final labelLower = cat.label.toLowerCase();
              final groupLower = cat.group.toLowerCase();
              final queryLower = searchQuery.toLowerCase();
              if (labelLower.contains(queryLower) ||
                  groupLower.contains(queryLower)) {
                displayGrouped.putIfAbsent(cat.group, () => []).add(cat);
              }
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white10 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'CARI KATEGORI',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.5,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: TextField(
                      controller: searchController,
                      autofocus: false,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Cari kategori...',
                        hintStyle: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white30 : Colors.black38,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: isDarkMode ? Colors.white38 : Colors.black45,
                          size: 20,
                        ),
                        suffixIcon: searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  searchController.clear();
                                  setModalState(() {
                                    searchQuery = '';
                                  });
                                },
                                child: Icon(
                                  Icons.close_rounded,
                                  color: isDarkMode
                                      ? Colors.white54
                                      : Colors.black54,
                                  size: 20,
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: isDarkMode
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          searchQuery = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: displayGrouped.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 48,
                                  color: isDarkMode
                                      ? Colors.white38
                                      : Colors.black26,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Kategori tidak ditemukan.',
                                  style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white38
                                        : Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            physics: const BouncingScrollPhysics(),
                            itemCount: displayGrouped.length,
                            itemBuilder: (context, groupIndex) {
                              final groupName =
                                  displayGrouped.keys.elementAt(groupIndex);
                              final items = displayGrouped[groupName]!;
                              final totalItemsInGroup = categoryObjects.where((c) => c.group == groupName).length;
                              final groupColor = items.isNotEmpty
                                  ? items.first.color
                                  : AppColors.primary;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20,
                                        bottom: 10,
                                        left: 24,
                                        right: 24),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 3.5,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: groupColor,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '${groupName.toUpperCase()} ($totalItemsInGroup)',
                                          style: GoogleFonts.quicksand(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.5,
                                            color: groupColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  ...items.map((cat) {
                                    final isSelected =
                                        cat.label == currentSelected;
                                    return GestureDetector(
                                      onTap: () {
                                        onSelected(cat);
                                        Navigator.pop(sheetContext);
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 3, horizontal: 20),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? Colors.white
                                                  .withValues(alpha: 0.03)
                                              : Colors.grey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected
                                                ? cat.color
                                                : (isDarkMode
                                                    ? Colors.white
                                                        .withValues(alpha: 0.05)
                                                    : Colors.grey.shade100),
                                            width: 1.2,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: cat.color.withValues(
                                                    alpha: isDarkMode
                                                        ? 0.15
                                                        : 0.08),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                cat.icon,
                                                size: 15,
                                                color: cat.color,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                cat.label,
                                                style: GoogleFonts.quicksand(
                                                  fontSize: 12,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w800
                                                      : FontWeight.bold,
                                                  color: isSelected
                                                      ? cat.color
                                                      : (isDarkMode
                                                          ? Colors.white
                                                          : Colors.black87),
                                                ),
                                              ),
                                            ),
                                            if (isSelected)
                                              Icon(
                                                Icons.check_circle_rounded,
                                                color: cat.color,
                                                size: 16,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              );
                            },
                          ),
                  ),
                ],
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
                        style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
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
                                  style: GoogleFonts.quicksand(
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
                                  style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black87)),
                              subtitle: Text(
                                  'Target: ${_formatRupiah(t.targetAmount)}',
                                  style: GoogleFonts.quicksand(
                                      color: isDarkMode
                                          ? Colors.white24
                                          : Colors.black54)),
                              onTap: () {
                                Navigator.pop(
                                    sheetContext);
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
        bool prevKeyboardVisible = false;
        bool nameHasError = false;
        bool amountHasError = false;
        bool dateIsFocused = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final inset = MediaQuery.of(context).viewInsets.bottom;
            final isKeyboardVisible = inset > 0;

            if (prevKeyboardVisible && !isKeyboardVisible) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
            prevKeyboardVisible = isKeyboardVisible;

            final Color dateBorderColor;
            final double dateBorderWidth;
            if (dateIsFocused) {
              dateBorderColor = AppColors.primary;
              dateBorderWidth = 1.8;
            } else {
              dateBorderColor = isDarkMode 
                  ? Colors.white.withValues(alpha: 0.05) 
                  : Colors.grey.shade200;
              dateBorderWidth = 1.2;
            }

            return AlertDialog(
              backgroundColor:
                  isDarkMode ? AppColors.surfaceDark : Colors.white,
              surfaceTintColor:
                  isDarkMode ? AppColors.surfaceDark : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
              title: Text(isEdit ? 'Ubah Target' : 'Target Baru',
                  style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      color: isDarkMode ? Colors.white : Colors.black87)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HighVisInput(
                      controller: amountController,
                      icon: Icons.account_balance_wallet_rounded,
                      label: 'Nominal Target',
                      isDarkMode: isDarkMode,
                      prefixText: 'Rp',
                      hintText: 'Masukkan Nominal',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        RibuanFormatter(),
                      ],
                      hasError: amountHasError,
                      onChanged: (val) {
                        if (amountHasError) {
                          final amt = double.tryParse(val.replaceAll('.', '')) ?? 0;
                          if (amt > 0) {
                            setDialogState(() => amountHasError = false);
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    HighVisInput(
                      controller: itemController,
                      icon: Icons.shopping_bag_rounded,
                      label: 'Target Pembelian',
                      isDarkMode: isDarkMode,
                      hintText: 'Contoh: Laptop, HP...',
                      hasError: nameHasError,
                      onChanged: (val) {
                        if (nameHasError && val.trim().isNotEmpty) {
                          setDialogState(() => nameHasError = false);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Text('Target Tanggal Selesai',
                        style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white70 : Colors.black87)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        setDialogState(() => dateIsFocused = true);
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 3650)),
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
                        setDialogState(() => dateIsFocused = false);
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.03)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: dateBorderColor,
                            width: dateBorderWidth,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded,
                                color: AppColors.primary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                                    .format(selectedDate),
                                style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black87,
                                    fontSize: 12),
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
                            style: GoogleFonts.quicksand(
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

                          setDialogState(() {
                            nameHasError = name.isEmpty;
                            amountHasError = amount == null || amount <= 0;
                          });

                          if (nameHasError || amountHasError) {
                            String errorMessage = 'Target pembelian tidak boleh kosong!';
                            if (amountHasError) {
                              errorMessage = 'Nominal target harus lebih dari 0!';
                            }
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        errorMessage,
                                        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.red.shade700,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                            return;
                          }

                          const userId = 'default_user';
                          if (isEdit) {
                            final updated = target.copyWith(
                              name: name,
                              targetAmount: amount!,
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
                              targetAmount: amount!,
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
                                  context);
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
                        child: Text('Simpan',
                            style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.bold)),
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

  Widget _buildInputLabel(String label, bool isDarkMode) {
    return Text(
      label,
      style: GoogleFonts.quicksand(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white70 : Colors.black87,
      ),
    );
  }

  double? _toAmount(String raw) {

    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return null;
    return double.tryParse(digitsOnly);
  }

  Widget _buildMiniAuditMetric(String label, String value, bool isDarkMode, IconData icon, {Color? valueColor}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 11,
              color: isDarkMode ? Colors.white38 : Colors.teal.shade800.withOpacity(0.4),
            ),
            const SizedBox(width: 4),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.quicksand(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: isDarkMode ? Colors.white30 : Colors.black38,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: valueColor ?? (isDarkMode ? Colors.white : AppColors.primaryDark),
          ),
        ),
      ],
    );
  }

  Widget _buildInlineAsset(
      String label, double amount, Color color, bool isDarkMode, IconData icon) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 11,
                  color: color,
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: GoogleFonts.quicksand(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white30 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _showBalance ? _formatRupiah(amount) : '••••',
              style: GoogleFonts.quicksand(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isDarkMode
                    ? Colors.white70
                    : Colors.teal.shade900.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
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

final now = DateTime.now();

    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && theme.brightness == Brightness.dark);

final currentMonthTx = transactions
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .toList();

final categoryTotals = <String, double>{};
    for (var t
        in currentMonthTx.where((t) => t.type == TransactionType.expense)) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
    }
    final topCategory = categoryTotals.entries.isEmpty
        ? null
        : categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b);

final largestTransaction = currentMonthTx.isEmpty
        ? null
        : currentMonthTx.reduce((a, b) => a.amount > b.amount ? a : b);

final monthlyActivity = currentMonthTx.length;

final targetsAsync = ref.watch(savingTargetsStreamProvider);
    final targets = targetsAsync.valueOrNull ?? [];

final billsAsync = ref.watch(billsStreamProvider);
    final bills =
        billsAsync.maybeWhen(data: (d) => d, orElse: () => <BillModel>[]);

final balance = totalIncome - totalExpense;
    final goldTxs =
        ref.watch(goldTransactionsStreamProvider).asData?.value ?? [];
    final totalGoldGrams = goldTxs.fold(0.0,
        (s, t) => s + (t.type == GoldTransactionType.buy ? t.grams : -t.grams));
    final investments = ref.watch(investmentStreamProvider).asData?.value ?? [];
    final investmentValuation =
        investments.fold(0.0, (s, i) => s + i.currentValuation);
    final unpaidBillsAmount =
        bills.where((b) => !b.isPaid).fold(0.0, (s, b) => s + b.amount);

    BillModel? closestBill;
    int? daysUntilDue;
    if (bills.isNotEmpty) {
      final unpaid = bills.where((b) => !b.isPaid).toList();
      if (unpaid.isNotEmpty) {
        unpaid.sort((a, b) {
          int daysA = a.dueDay >= now.day
              ? a.dueDay - now.day
              : (30 - now.day + a.dueDay);
          int daysB = b.dueDay >= now.day
              ? b.dueDay - now.day
              : (30 - now.day + b.dueDay);
          return daysA.compareTo(daysB);
        });
        closestBill = unpaid.first;
        daysUntilDue = closestBill.dueDay >= now.day
            ? closestBill.dueDay - now.day
            : (30 - now.day + closestBill.dueDay);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [const Color(0xFF161719), const Color(0xFF111714)]
                    : [const Color(0xFFEDF7F4), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDarkMode
                    ? const Color(0xFF2ECC71).withOpacity(0.06)
                    : Colors.teal.shade100.withOpacity(0.4),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode 
                      ? Colors.black.withOpacity(0.12) 
                      : Colors.black.withOpacity(0.02),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'KEKAYAAN BERSIH',
                            style: GoogleFonts.quicksand(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: isDarkMode
                                  ? Colors.white38
                                  : Colors.teal.shade800.withOpacity(0.5),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => setState(() => _showBalance = !_showBalance),
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isDarkMode 
                                      ? Colors.white.withOpacity(0.02) 
                                      : Colors.teal.shade50.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _showBalance 
                                      ? Icons.visibility_outlined 
                                      : Icons.visibility_off_outlined,
                                  size: 14,
                                  color: isDarkMode 
                                      ? Colors.white54 
                                      : Colors.teal.shade800.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _showBalance
                              ? _formatRupiah(balance +
                                  totalGoldGrams * 1200000.0 +
                                  investmentValuation -
                                  unpaidBillsAmount)
                              : '••••••••',
                          style: GoogleFonts.quicksand(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : AppColors.primaryDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMiniAuditMetric(
                              'Saving Rate',
                              '${((totalIncome - totalExpense) / (totalIncome > 0 ? totalIncome : 1) * 100).toStringAsFixed(0)}%',
                              isDarkMode,
                              Icons.trending_up_rounded,
                              valueColor: isDarkMode ? const Color(0xFF2ECC71) : const Color(0xFF27AE60)),
                          Container(
                              width: 1,
                              height: 20,
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.05)),
                          _buildMiniAuditMetric(
                              'Ketahanan',
                              '${(totalExpense / 30 > 0 ? (balance / (totalExpense / 30)) : 0).toInt()} Hari',
                              isDarkMode,
                              Icons.security_rounded,
                              valueColor: isDarkMode ? const Color(0xFFF1C40F) : const Color(0xFFD4AC0D)),
                          Container(
                              width: 1,
                              height: 20,
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.05)),
                          _buildMiniAuditMetric(
                              'Tagihan',
                              unpaidBillsAmount > 0
                                  ? _formatRupiah(unpaidBillsAmount)
                                  : 'Lunas',
                              isDarkMode,
                              Icons.receipt_long_rounded,
                              valueColor: unpaidBillsAmount > 0
                                  ? (isDarkMode ? const Color(0xFFE74C3C) : const Color(0xFFC0392B))
                                  : (isDarkMode ? const Color(0xFF2ECC71) : const Color(0xFF27AE60))),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.02)
                        : Colors.teal.shade50.withOpacity(0.15),
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(28)),
                    border: Border(
                      top: BorderSide(
                        color: isDarkMode ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildInlineAsset(
                          'Saldo', balance, const Color(0xFF2ECC71), isDarkMode, Icons.account_balance_wallet_rounded),
                      Container(
                          width: 1,
                          height: 20,
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05)),
                      _buildInlineAsset('Emas', totalGoldGrams * 1200000.0,
                          const Color(0xFFF1C40F), isDarkMode, Icons.workspace_premium_rounded),
                      Container(
                          width: 1,
                          height: 20,
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05)),
                      _buildInlineAsset('Invest', investmentValuation,
                          const Color(0xFF3498DB), isDarkMode, Icons.show_chart_rounded),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

_buildSpendingCalendarCard(transactions, isDarkMode),

          const SizedBox(height: 24),

_buildDailyMissionsCard(isDarkMode),

          const SizedBox(height: 24),

_buildLevelAndChallengesCard(isDarkMode),

          const SizedBox(height: 40),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSpendingCalendarCard(List<TransactionModel> transactions, bool isDarkMode) {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDayOfMonth = DateTime(year, month, 1);
    final firstDayOffset = firstDayOfMonth.weekday - 1;

final Map<int, List<TransactionModel>> dailyTx = {};
    for (final t in transactions) {
      if (t.date.year == year && t.date.month == month) {
        dailyTx.putIfAbsent(t.date.day, () => []).add(t);
      }
    }

    final weekdays = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

    int hematCount = 0;
    int borosCount = 0;
    int tidakMenabungCount = 0;

    for (int day = 1; day <= now.day; day++) {
      final txs = dailyTx[day] ?? [];
      final income = txs.where((t) => t.type == TransactionType.income).fold(0.0, (s, t) => s + t.amount);
      final expense = txs.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount);

      if (income == 0 && expense == 0) {
        tidakMenabungCount++;
      } else if (expense > 0 && expense > income) {
        borosCount++;
      } else {
        hematCount++;
      }
    }

    final totalTracked = hematCount + tidakMenabungCount + borosCount;
    final double disciplineScore = totalTracked > 0 ? ((hematCount + tidakMenabungCount) / totalTracked) : 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF151618) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.04)
              : Colors.black.withOpacity(0.03),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.12) 
                : Colors.black.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JURNAL SPENDING HARI INI',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.quicksand(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: isDarkMode ? Colors.white30 : Colors.black38,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM yyyy', 'id_ID').format(now).toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays.map((day) {
              return SizedBox(
                width: 32,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: isDarkMode ? Colors.white24 : Colors.black26,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: daysInMonth + firstDayOffset,
            itemBuilder: (context, index) {
              if (index < firstDayOffset) {
                return const SizedBox.shrink();
              }

              final day = index - firstDayOffset + 1;
              final isFuture = day > now.day;
              final isToday = day == now.day;

Color dayColor = isDarkMode ? const Color(0xFF1B1D1F) : const Color(0xFFF8FAFC);
              Color textColor = isDarkMode ? Colors.white30 : Colors.black26;
              Border border = Border.all(color: Colors.transparent);

              if (!isFuture) {
                final txs = dailyTx[day] ?? [];
                final income = txs.where((t) => t.type == TransactionType.income).fold(0.0, (s, t) => s + t.amount);
                final expense = txs.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount);

                if (income == 0 && expense == 0) {

                  dayColor = isDarkMode ? const Color(0xFF222528) : const Color(0xFFF1F5F9);
                  textColor = isDarkMode ? Colors.white60 : Colors.black54;
                  border = Border.all(
                    color: isDarkMode ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                    width: 1,
                  );
                } else if (expense > 0 && expense > income) {

                  dayColor = isDarkMode ? const Color(0xFF2C1515) : const Color(0xFFFDF0F0);
                  textColor = const Color(0xFFE74C3C);
                  border = Border.all(color: const Color(0xFFE74C3C).withOpacity(0.2), width: 1);
                } else {

                  dayColor = isDarkMode ? const Color(0xFF102A1F) : const Color(0xFFE8F8F0);
                  textColor = const Color(0xFF2ECC71);
                  border = Border.all(color: const Color(0xFF2ECC71).withOpacity(0.2), width: 1);
                }
              }

              if (isToday) {
                border = Border.all(
                  color: isDarkMode ? Colors.white : AppColors.primary,
                  width: 1.6,
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: dayColor,
                  borderRadius: BorderRadius.circular(12),
                  border: border,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),

Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SKOR DISIPLIN KEUANGAN',
                    style: GoogleFonts.quicksand(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: isDarkMode ? Colors.white30 : Colors.black38,
                    ),
                  ),
                  Text(
                    '${(disciplineScore * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: disciplineScore >= 0.5 ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 6,
                  width: double.infinity,
                  color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  child: totalTracked == 0
                      ? const SizedBox.shrink()
                      : Row(
                          children: [
                            if (hematCount > 0)
                              Expanded(
                                flex: hematCount,
                                child: Container(
                                  color: const Color(0xFF2ECC71),
                                ),
                              ),
                            if (tidakMenabungCount > 0)
                              Expanded(
                                flex: tidakMenabungCount,
                                child: Container(
                                  color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                                ),
                              ),
                            if (borosCount > 0)
                              Expanded(
                                flex: borosCount,
                                child: Container(
                                  color: const Color(0xFFE74C3C),
                                ),
                              ),
                          ],
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2ECC71),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Hemat: $hematCount Hari',
                    style: GoogleFonts.quicksand(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tidak Menabung: $tidakMenabungCount Hari',
                    style: GoogleFonts.quicksand(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE74C3C),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Boros: $borosCount Hari',
                    style: GoogleFonts.quicksand(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

Widget _buildDailyMissionsCard(bool isDarkMode) {
    final completedCount = _dailyMissions.where((m) => m.isCompleted).length;
    final totalCount = _dailyMissions.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF151618) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.04)
              : Colors.black.withOpacity(0.03),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.12) 
                : Colors.black.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MISI MENABUNG HARIAN',
                      style: GoogleFonts.quicksand(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: isDarkMode ? Colors.white30 : Colors.black38,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'BANGUN HABIT POSITIF',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showAddMissionSheet,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_rounded,
                          color: AppColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tambah',
                          style: GoogleFonts.quicksand(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 5,
                    color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                    child: totalCount == 0
                        ? const SizedBox.shrink()
                        : FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Container(
                              color: progress == 1.0 ? const Color(0xFF2ECC71) : const Color(0xFF3498DB),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$completedCount/$totalCount Selesai',
                style: GoogleFonts.quicksand(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: progress == 1.0 ? const Color(0xFF2ECC71) : const Color(0xFF3498DB),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

totalCount == 0
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.task_alt_rounded,
                          size: 36,
                          color: isDarkMode ? Colors.white24 : Colors.black26,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada misi harian.\nKetuk "+ Tambah" untuk memulai!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white30 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: totalCount,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final mission = _dailyMissions[index];
                    final isCompleted = mission.isCompleted;

                    return Container(
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? (isDarkMode ? const Color(0xFF102A1F) : const Color(0xFFE8F8F0))
                            : (isDarkMode ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.01)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCompleted
                              ? const Color(0xFF2ECC71).withOpacity(0.3)
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [

                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  mission.isCompleted = !isCompleted;
                                });
                                HapticFeedback.mediumImpact();
                              },
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [

                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isCompleted
                                            ? const Color(0xFF2ECC71)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isCompleted
                                              ? const Color(0xFF2ECC71)
                                              : (isDarkMode ? Colors.white24 : Colors.black26),
                                          width: 1.8,
                                        ),
                                      ),
                                      child: isCompleted
                                          ? const Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                              size: 14,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 14),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mission.title,
                                            style: GoogleFonts.quicksand(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                              color: isCompleted
                                                  ? const Color(0xFF2ECC71)
                                                  : (isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87),
                                              decoration: isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            mission.subtitle,
                                            style: GoogleFonts.quicksand(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w500,
                                              color: isCompleted
                                                  ? const Color(0xFF2ECC71).withOpacity(0.7)
                                                  : (isDarkMode ? Colors.white38 : Colors.black45),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          IconButton(
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: isCompleted
                                  ? const Color(0xFFE74C3C).withOpacity(0.5)
                                  : const Color(0xFFE74C3C).withOpacity(0.7),
                            ),
                            onPressed: () {
                              setState(() {
                                _dailyMissions.removeAt(index);
                              });
                              HapticFeedback.lightImpact();
                            },
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    );
                  },
                ),
          
          if (totalCount > 0 && progress == 1.0) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '🔥 SEMUA MISI TERCAPAI! LUAR BIASA! 🎉',
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
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
                              style: GoogleFonts.quicksand(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDark ? Colors.white : Colors.black87)),
                          Text(
                              'Bulan $monthLabel (${regular.length} transaksi)',
                              style: GoogleFonts.quicksand(
                                  fontSize: 11,
                                  color:
                                      isDark ? Colors.white38 : Colors.black45,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

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
            style: GoogleFonts.quicksand(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: isDark ? Colors.white38 : Colors.black38)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.quicksand(
                fontSize: 11, fontWeight: FontWeight.bold, color: color)),
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
                        style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: GoogleFonts.quicksand(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.black45,
                            fontWeight: FontWeight.bold)),
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
              style: GoogleFonts.quicksand(
                  fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          Text(_formatRupiah(amount),
              style: GoogleFonts.quicksand(
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
                          style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.teal.shade900)),
                      const SizedBox(height: 2),
                      Text(
                          '${DateFormat('EEEE, dd MMM', 'id_ID').format(t.date)} • ${DateFormat('HH:mm', 'id_ID').format(t.date)}',
                          style: GoogleFonts.quicksand(
                              color:
                                  isDarkMode ? Colors.white54 : Colors.black26,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Text(
                  '${isExpense ? '- ' : '+ '}${_formatRupiah(t.amount)}',
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
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
            style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87)),
        content: Text(
            'Yakin ingin menghapus ${t.title}? Langkah ini tidak bisa dibatalkan.',
            style: GoogleFonts.quicksand(
                color: isDarkMode ? Colors.white70 : Colors.black54)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Batal',
                  style: GoogleFonts.quicksand(
                      color: isDarkMode ? Colors.white30 : Colors.grey))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Hapus',
                  style: GoogleFonts.quicksand(
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
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Icon(item.icon, color: color, size: 22),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: GoogleFonts.quicksand(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.bold,
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
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
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
                          style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode ? Colors.white : Colors.black87)),
                      const SizedBox(height: 12),
                      Text(t.title,
                          style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white38
                                  : Colors.teal.shade800
                                      .withValues(alpha: 0.4))),
                      const SizedBox(height: 24),

TextFormField(
                        controller: amountController,
                        autofocus: t.type == TransactionType.expense,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          RibuanFormatter()
                        ],
                        style: GoogleFonts.quicksand(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Input Nominal Baru *',
                          labelStyle: GoogleFonts.quicksand(
                              color:
                                  isDarkMode ? Colors.white38 : Colors.black45),
                          prefixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 16),
                              const Icon(Icons.account_balance_wallet_rounded,
                                  color: Colors.teal, size: 20),
                              const SizedBox(width: 8),
                              Text('Rp',
                                  style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                      fontSize: 11)),
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
                          child: Text('Simpan Perubahan',
                              style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.bold, fontSize: 11)),
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

  void _calculate() {
    if (_num1 == null || _operand == null) return;
    _num2 = double.tryParse(_output.replaceAll('.', '').replaceAll(',', '.'));
    if (_num2 == null) return;

    double result = 0;
    switch (_operand) {
      case "+":
        result = _num1! + _num2!;
        break;
      case "-":
        result = _num1! - _num2!;
        break;
      case "×":
        result = _num1! * _num2!;
        break;
      case "÷":
        result = _num2 == 0 ? 0 : _num1! / _num2!;
        break;
    }

    _output = result % 1 == 0
        ? result.toInt().toString()
        : result.toStringAsFixed(2).replaceAll('.', ',');
    _num1 = result;
    _num2 = null;
    _operand = null;
  }

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
        double currentVal =
            double.tryParse(_output.replaceAll('.', '').replaceAll(',', '.')) ??
                0;

        if (_num1 == null) {
          _num1 = currentVal;
          _operand = buttonText;
          _expression = "$_output $buttonText";
          _output = "0";
        } else if (_operand != null) {
          if (_output == "0") {

            _operand = buttonText;
            _expression =
                _expression.substring(0, _expression.length - 1) + buttonText;
          } else {

            _calculate();
            _operand = buttonText;
            _expression = "$_output $buttonText";
            _output = "0";
          }
        } else {

          _num1 = currentVal;
          _operand = buttonText;
          _expression = "$_output $buttonText";
          _output = "0";
        }
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
        if (_num1 != null && _operand != null) {
          _expression = "";
          _calculate();

          _num1 = null;
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
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2)),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                      style: GoogleFonts.quicksand(
                          fontSize: 11,
                          color: isDarkMode
                              ? Colors.white24
                              : Colors.teal.shade800.withValues(alpha: 0.4),
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      _formatDisplay(_output),
                      style: GoogleFonts.quicksand(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color:
                              isDarkMode ? Colors.white : Colors.teal.shade900,
                          letterSpacing: -1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
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
            const SizedBox(height: 8),
          ],
        ),
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
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

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

final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  int _typeFilter = 0;

  int _debtTypeFilter = 0;

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

        _buildHistoryFilter(isDark, regularList, hutangList, belanjaList),

_buildSearchBar(isDark, regularList),

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

Widget _buildSearchBar(bool isDark, List<TransactionModel> regularList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Builder(builder: (context) {
            final isDk = isDark;
            return TextField(
              controller: _searchCtrl,
              style: GoogleFonts.quicksand(
                  fontSize: 11,
                  color: isDk ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Cari transaksi...',
                hintStyle: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: isDk ? Colors.white24 : Colors.black26,
                    fontWeight: FontWeight.bold),
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

        if (_filterIndex == 0 || _filterIndex == 1)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                if (_filterIndex == 0) ...[
                  _typeChip(isDark, 0, 'Semua', Icons.receipt_long_rounded),
                  const SizedBox(width: 8),
                  _typeChip(
                      isDark, 1, 'Pemasukan', Icons.arrow_downward_rounded),
                  const SizedBox(width: 8),
                  _typeChip(
                      isDark, 2, 'Pengeluaran', Icons.arrow_upward_rounded),
                ] else if (_filterIndex == 1) ...[
                  _debtTypeChip(isDark, 0, 'Semua', Icons.receipt_long_rounded),
                  const SizedBox(width: 8),
                  _debtTypeChip(isDark, 1, 'Hutang', Icons.call_made_rounded),
                  const SizedBox(width: 8),
                  _debtTypeChip(
                      isDark, 2, 'Piutang', Icons.call_received_rounded),
                ],
              ],
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _typeChip(bool isDark, int value, String label, IconData icon) {
    final selected = _typeFilter == value;
    const activeColor = Color(0xFF00BFA5);

    return GestureDetector(
      onTap: () => setState(() => _typeFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.15)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: selected ? activeColor : Colors.transparent, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: selected
                    ? activeColor
                    : (isDark ? Colors.white38 : Colors.grey)),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.bold : FontWeight.bold,
                    color: selected
                        ? (isDark ? Colors.white : activeColor)
                        : (isDark ? Colors.white38 : Colors.grey))),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryFilter(bool isDark, List<TransactionModel> regularList,
      List<TransactionModel> hutangList, List<TransactionModel> belanjaList) {
    final categories = [
      'Pemasukan & Pengeluaran',
      'Hutang & Piutang',
      'Belanja'
    ];
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
                        padding: EdgeInsets.zero,
                        height: 52,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context, i),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                Expanded(
                                  child: Text(categories[i],
                                      style: GoogleFonts.quicksand(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _filterIndex == i
                                            ? AppColors.primary
                                            : (isDark
                                                ? Colors.white
                                                : Colors.black87),
                                      )),
                                ),
                              ],
                            ),
                          ),
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
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
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
              style: GoogleFonts.quicksand(
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

Widget _buildRegularTab(List<TransactionModel> allSorted,
      List<TransactionModel> regularList, bool isDark) {

    final filtered = regularList.where((t) {
      if (_typeFilter == 1 && t.type != TransactionType.income) {
        return false;
      }
      if (_typeFilter == 2 && t.type != TransactionType.expense) {
        return false;
      }

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

    final isFiltering = _searchQuery.isNotEmpty || _typeFilter != 0;

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

final Map<String, List<TransactionModel>> grouped = {};
    for (final t in filtered) {
      final k = DateFormat('MMMM yyyy', 'id_ID').format(t.date).toUpperCase();
      grouped.putIfAbsent(k, () => []).add(t);
    }

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
                            style: GoogleFonts.quicksand(
                                fontSize: 11,
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

Widget _buildHutangTab(List<TransactionModel> list, bool isDark) {
    if (list.isEmpty) {
      return _emptyState(isDark,
          icon: Icons.account_balance_wallet_outlined,
          label: 'Belum ada riwayat hutang/piutang',
          subtitle: 'Muncul saat hutang/piutang ditandai lunas');
    }

final filtered = list.where((t) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!t.title.toLowerCase().contains(q) &&
            !t.category.toLowerCase().contains(q) &&
            !t.description.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    if (filtered.isEmpty && _searchQuery.isNotEmpty) {
      return _emptyState(isDark,
          icon: Icons.search_off_rounded,
          label: 'Tidak ada hasil',
          subtitle: 'Coba ubah kata kunci pencarian Anda');
    }

    final hutangOnly = filtered.where((t) => t.category == 'Hutang').toList();
    final piutangOnly = filtered.where((t) => t.category == 'Piutang').toList();
    final totalH = hutangOnly.fold(0.0, (s, t) => s + t.amount);
    final totalP = piutangOnly.fold(0.0, (s, t) => s + t.amount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
      children: [
        const SizedBox(height: 12),

Container(
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 24),
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

        if ((_debtTypeFilter == 0 || _debtTypeFilter == 1) &&
            hutangOnly.isNotEmpty) ...[
          ...hutangOnly.map((t) => _debtCard(t, isDark)),
        ],
        if ((_debtTypeFilter == 0 || _debtTypeFilter == 2) &&
            piutangOnly.isNotEmpty) ...[
          ...piutangOnly.map((t) => _debtCard(t, isDark)),
        ],
      ],
    );
  }

  Widget _debtTypeChip(bool isDark, int value, String label, IconData icon) {
    final selected = _debtTypeFilter == value;
    const activeColor = Color(0xFF00BFA5);

    return GestureDetector(
      onTap: () => setState(() => _debtTypeFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.15)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: selected ? activeColor : Colors.transparent, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: selected
                    ? activeColor
                    : (isDark ? Colors.white38 : Colors.grey)),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.bold : FontWeight.bold,
                    color: selected
                        ? (isDark ? Colors.white : activeColor)
                        : (isDark ? Colors.white38 : Colors.grey))),
          ],
        ),
      ),
    );
  }

Widget _buildBelanjaTab(List<TransactionModel> list, bool isDark) {
    if (list.isEmpty) {
      return _emptyState(isDark,
          icon: Icons.shopping_bag_outlined,
          label: 'Belum ada riwayat belanja',
          subtitle: 'Muncul saat item belanja ditandai dibeli');
    }

final filtered = list.where((t) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!t.title.toLowerCase().contains(q) &&
            !t.category.toLowerCase().contains(q) &&
            !t.description.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    if (filtered.isEmpty && _searchQuery.isNotEmpty) {
      return _emptyState(isDark,
          icon: Icons.search_off_rounded,
          label: 'Tidak ada hasil',
          subtitle: 'Coba ubah kata kunci pencarian Anda');
    }

    final total = filtered.fold(0.0, (s, t) => s + t.amount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
      children: [

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
                      amount: filtered.length.toDouble(),
                      isCurrency: false,
                      color: isDark ? Colors.white38 : Colors.black38)),
            ],
          ),
        ),
        ...filtered.map((t) => _shoppingCard(t, isDark)),
      ],
    );
  }

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
                          style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87)),
                      if (t.description.isNotEmpty)
                        Text(t.description,
                            style: GoogleFonts.quicksand(
                                fontSize: 11,
                                color:
                                    isDark ? Colors.white38 : Colors.black38)),
                      Text('#${t.id.replaceAll('paid_debt_', '')}',
                          style: GoogleFonts.quicksand(
                              fontSize: 9,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.grey.shade400)),
                    ],
                  ),
                ),
                Text(_fmtCur(t.amount),
                    style: GoogleFonts.quicksand(
                        fontSize: 11,
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
                      style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87)),
                ),
                Text(_fmtCur(t.amount),
                    style: GoogleFonts.quicksand(
                        fontSize: 11,
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
          style: GoogleFonts.quicksand(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: isDark ? Colors.white38 : Colors.black38)),
      const SizedBox(height: 5),
      Text(isCurrency ? _fmtCur(amount) : amount.toInt().toString(),
          style: GoogleFonts.quicksand(
              fontSize: 11, fontWeight: FontWeight.bold, color: color)),
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
          style: GoogleFonts.quicksand(
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
              style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white38 : Colors.black38)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                      fontSize: 11,
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

class _RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final intValue = int.tryParse(newValue.text.replaceAll('.', ''));
    if (intValue == null) return oldValue;
    final newText =
        NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0)
            .format(intValue)
            .trim();
    return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length));
  }
}

class _DailyMission {
  final String title;
  final String subtitle;
  bool isCompleted;

  _DailyMission({
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
  });
}

class _QuickChallenge {
  final String icon;
  final String title;
  final String subtitle;
  final int xpReward;
  final double savingsAmount;
  final String category;
  bool isCompleted;

  _QuickChallenge({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.xpReward,
    required this.savingsAmount,
    required this.category,
    this.isCompleted = false,
  });
}
