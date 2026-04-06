import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabunganku/features/settings/presentation/providers/achievement_provider.dart';
import 'package:tabunganku/providers/saving_target_provider.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/providers/notification_provider.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:intl/intl.dart';

class NotificationObserver extends ConsumerStatefulWidget {
  final Widget child;
  const NotificationObserver({super.key, required this.child});

  @override
  ConsumerState<NotificationObserver> createState() => _NotificationObserverState();
}

class _NotificationObserverState extends ConsumerState<NotificationObserver> {
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool _isNotified(String key) {
    return _prefs?.getBool('notified_$key') ?? false;
  }

  Future<void> _markAsNotified(String key) async {
    await _prefs?.setBool('notified_$key', true);
    if (mounted) setState(() {}); // Rebuild to ensure consistency if needed
  }

  @override
  Widget build(BuildContext context) {
    final notificationService = ref.read(notificationServiceProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    // ── Achievement Listener ───────────────────────────────────
    ref.listen(achievementsProvider, (previous, next) {
      if (previous == null) return;
      
      for (final achievement in next) {
        if (achievement.isUnlocked && !_isNotified('achievement_${achievement.id}')) {
          notificationService.showAchievementNotification(achievement.title, achievement.description);
          _markAsNotified('achievement_${achievement.id}');
        }
      }
    });

    // ── Saving Target Achievement Listener ─────────────────────
    // Listen to changes in targets or transactions/balance
    ref.listen(transactionsStreamProvider, (previous, next) {
      final transactions = next.valueOrNull;
      final targets = ref.read(savingTargetsStreamProvider).valueOrNull;
      
      if (transactions != null && targets != null) {
        final personalTransactions = transactions.where((t) => t.groupId == null).toList();
        final totalIncome = personalTransactions
            .where((t) => t.type == TransactionType.income)
            .fold<double>(0, (sum, t) => sum + t.amount);
        final totalExpense = personalTransactions
            .where((t) => t.type == TransactionType.expense)
            .fold<double>(0, (sum, t) => sum + t.amount);
        final currentBalance = totalIncome - totalExpense;

        for (final target in targets) {
          if (currentBalance >= target.targetAmount && !_isNotified('target_reached_${target.id}')) {
            notificationService.showTargetReachedNotification(
              target.name,
              currencyFormatter.format(target.targetAmount),
            );
            _markAsNotified('target_reached_${target.id}');
          }
        }
      }
    });

    return widget.child;
  }
}
