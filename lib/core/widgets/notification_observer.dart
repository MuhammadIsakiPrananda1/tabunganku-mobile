import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabunganku/features/settings/presentation/providers/achievement_provider.dart';
import 'package:tabunganku/providers/saving_target_provider.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/providers/notification_provider.dart';
import 'package:tabunganku/models/notification_model.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/gold_provider.dart';
import 'package:tabunganku/models/gold_investment_model.dart';
import 'package:tabunganku/providers/bills_provider.dart';
import 'package:tabunganku/models/bill_model.dart';
import 'package:tabunganku/providers/investment_provider.dart';
import 'package:tabunganku/models/investment_model.dart';
import 'package:tabunganku/providers/insurance_provider.dart';
import 'package:tabunganku/models/insurance_model.dart';
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
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

ref.listen(achievementsProvider, (previous, next) {
      if (previous == null) return;
      
      for (final achievement in next) {
        if (achievement.isUnlocked && !_isNotified('achievement_${achievement.id}')) {
          ref.read(notificationNotifierProvider.notifier).addNotification(
            NotificationModel(
              id: 'achievement_${achievement.id}_${DateTime.now().millisecondsSinceEpoch}',
              title: 'Pencapaian Baru! 🏅',
              message: '${achievement.title}: ${achievement.description}',
              timestamp: DateTime.now(),
              type: NotificationType.badge,
              actionData: achievement.id,
            ),
          );
          _markAsNotified('achievement_${achievement.id}');
        }
      }
    });

ref.listen(transactionsStreamProvider, (previous, next) {
      final prevList = previous?.valueOrNull;
      final nextList = next.valueOrNull;
      final targets = ref.read(savingTargetsStreamProvider).valueOrNull;
      
      if (nextList != null) {
        final personalTransactions = nextList.where((t) => t.groupId == null).toList();

if (prevList != null) {
          final prevIds = prevList.map((t) => t.id).toSet();
          final newTxs = nextList.where((t) => !prevIds.contains(t.id)).toList();

          for (final tx in newTxs) {
            if (!_isNotified('tx_${tx.id}')) {
              final isIncome = tx.type == TransactionType.income;
              ref.read(notificationNotifierProvider.notifier).addNotification(
                NotificationModel(
                  id: 'tx_${tx.id}_${DateTime.now().millisecondsSinceEpoch}',
                  title: isIncome ? 'Pemasukan Baru! 💰' : 'Pengeluaran Baru! 💸',
                  message: isIncome
                      ? 'Pemasukan "${tx.title}" sebesar ${currencyFormatter.format(tx.amount)} telah berhasil dicatat.'
                      : 'Pengeluaran "${tx.title}" sebesar ${currencyFormatter.format(tx.amount)} telah berhasil dicatat.',
                  timestamp: DateTime.now(),
                  type: isIncome ? NotificationType.savings : NotificationType.system,
                  actionData: tx.id,
                ),
              );
              _markAsNotified('tx_${tx.id}');
            }
          }
        }

if (targets != null) {
          for (final target in targets) {
            final targetBalance = personalTransactions
                .where((t) => !t.date.isBefore(target.createdAt))
                .fold<double>(0, (s, t) => s + (t.type == TransactionType.income ? t.amount : -t.amount));

            if (targetBalance >= target.targetAmount && target.targetAmount > 0 && !_isNotified('target_reached_${target.id}')) {
              ref.read(notificationNotifierProvider.notifier).addNotification(
                NotificationModel(
                  id: 'target_reached_${target.id}_${DateTime.now().millisecondsSinceEpoch}',
                  title: 'Target Tercapai! 🎯',
                  message: 'Selamat! Saldo target "${target.name}" telah mencapai ${currencyFormatter.format(target.targetAmount)}.',
                  timestamp: DateTime.now(),
                  type: NotificationType.savings,
                  actionData: target.id,
                ),
              );
              _markAsNotified('target_reached_${target.id}');
            }
          }
        }

if (_prefs != null) {
          final now = DateTime.now();
          final limit = _prefs!.getDouble('monthly_budget_${now.year}_${now.month}') ?? 0.0;
          if (limit > 0) {
            final monthlyTransactions = personalTransactions
                .where((t) => t.date.year == now.year && t.date.month == now.month)
                .toList();
            final totalExpense = monthlyTransactions
                .where((t) => t.type == TransactionType.expense)
                .fold<double>(0, (sum, t) => sum + t.amount);

            final progress = totalExpense / limit;
            final isOver = totalExpense > limit;
            final isCritical = progress >= 0.9 && !isOver;

            final warning10Key = 'budget_warning_10percent_${now.year}_${now.month}';
            final warningExceededKey = 'budget_warning_exceeded_${now.year}_${now.month}';

            if (isCritical && !_isNotified(warning10Key)) {
              ref.read(notificationNotifierProvider.notifier).addNotification(
                NotificationModel(
                  id: 'budget_warning_10percent_${now.year}_${now.month}_${DateTime.now().millisecondsSinceEpoch}',
                  title: 'Batas Budget Mendekati! ⚠️',
                  message: 'Pengeluaran Anda bulan ini telah mencapai ${(progress * 100).toStringAsFixed(0)}%. Sisa budget kurang dari 10%!',
                  timestamp: DateTime.now(),
                  type: NotificationType.system,
                  actionData: 'monthly-budget',
                ),
              );
              _markAsNotified(warning10Key);
            } else if (isOver && !_isNotified(warningExceededKey)) {
              ref.read(notificationNotifierProvider.notifier).addNotification(
                NotificationModel(
                  id: 'budget_warning_exceeded_${now.year}_${now.month}_${DateTime.now().millisecondsSinceEpoch}',
                  title: 'Limit Budget Terlampaui! 🚨',
                  message: 'Waduh! Pengeluaran Anda bulan ini (${currencyFormatter.format(totalExpense)}) telah melebihi limit budget Anda (${currencyFormatter.format(limit)}).',
                  timestamp: DateTime.now(),
                  type: NotificationType.system,
                  actionData: 'monthly-budget',
                ),
              );
              _markAsNotified(warningExceededKey);
            }
          }
        }
      }
    });

ref.listen(goldTransactionsStreamProvider, (previous, next) {
      final prevList = previous?.valueOrNull;
      final nextList = next.valueOrNull;

      if (prevList != null && nextList != null && nextList.length > prevList.length) {
        final prevIds = prevList.map((t) => t.id).toSet();
        final newTxs = nextList.where((t) => !prevIds.contains(t.id)).toList();

        for (final tx in newTxs) {
          if (!_isNotified('gold_tx_${tx.id}')) {
            final isBuy = tx.type == GoldTransactionType.buy;
            final totalPrice = tx.grams * tx.pricePerGram;
            ref.read(notificationNotifierProvider.notifier).addNotification(
              NotificationModel(
                id: 'gold_tx_${tx.id}_${DateTime.now().millisecondsSinceEpoch}',
                title: isBuy ? 'Beli Emas Berhasil! 🪙' : 'Jual Emas Berhasil! 💵',
                message: isBuy
                    ? 'Pembelian emas seberat ${tx.grams.toStringAsFixed(3)} gr senilai ${currencyFormatter.format(totalPrice)} telah berhasil dicatat.'
                    : 'Penjualan emas seberat ${tx.grams.toStringAsFixed(3)} gr senilai ${currencyFormatter.format(totalPrice)} telah berhasil dicatat.',
                timestamp: DateTime.now(),
                type: NotificationType.gold,
                actionData: tx.id,
              ),
            );
            _markAsNotified('gold_tx_${tx.id}');
          }
        }
      }
    });

ref.listen(billsStreamProvider, (previous, next) {
      final prevList = previous?.valueOrNull;
      final nextList = next.valueOrNull;

      if (prevList != null && nextList != null) {

        if (nextList.length > prevList.length) {
          final prevIds = prevList.map((b) => b.id).toSet();
          final newBills = nextList.where((b) => !prevIds.contains(b.id)).toList();

          for (final bill in newBills) {
            if (!_isNotified('bill_add_${bill.id}')) {
              ref.read(notificationNotifierProvider.notifier).addNotification(
                NotificationModel(
                  id: 'bill_add_${bill.id}_${DateTime.now().millisecondsSinceEpoch}',
                  title: 'Tagihan Baru Terdaftar! 📋',
                  message: 'Tagihan "${bill.name}" sebesar ${currencyFormatter.format(bill.amount)} (Jatuh tempo tanggal ${bill.dueDay}) telah terdaftar.',
                  timestamp: DateTime.now(),
                  type: NotificationType.bills,
                  actionData: bill.id,
                ),
              );
              _markAsNotified('bill_add_${bill.id}');
            }
          }
        }

for (final bill in nextList) {
          final prevBill = prevList.firstWhere((b) => b.id == bill.id, orElse: () => bill);
          if (bill.isPaid && !prevBill.isPaid) {
            final notifyKey = 'bill_paid_${bill.id}_${bill.lastPaidDate?.millisecondsSinceEpoch}';
            if (!_isNotified(notifyKey)) {
              ref.read(notificationNotifierProvider.notifier).addNotification(
                NotificationModel(
                  id: 'bill_paid_${bill.id}_${DateTime.now().millisecondsSinceEpoch}',
                  title: 'Pembayaran Tagihan Berhasil! ✅',
                  message: 'Tagihan "${bill.name}" sebesar ${currencyFormatter.format(bill.amount)} telah berhasil dibayar.',
                  timestamp: DateTime.now(),
                  type: NotificationType.bills,
                  actionData: bill.id,
                ),
              );
              _markAsNotified(notifyKey);
            }
          }
        }
      }
    });

ref.listen(investmentStreamProvider, (previous, next) {
      final prevList = previous?.valueOrNull;
      final nextList = next.valueOrNull;

      if (prevList != null && nextList != null && nextList.length > prevList.length) {
        final prevIds = prevList.map((i) => i.id).toSet();
        final newInv = nextList.where((i) => !prevIds.contains(i.id)).toList();

        for (final inv in newInv) {
          if (!_isNotified('inv_${inv.id}')) {
            ref.read(notificationNotifierProvider.notifier).addNotification(
              NotificationModel(
                id: 'inv_${inv.id}_${DateTime.now().millisecondsSinceEpoch}',
                title: 'Investasi Baru Ditambahkan! 📈',
                message: 'Aset investasi "${inv.assetName}" dengan nilai nominal ${currencyFormatter.format(inv.totalInvested)} telah berhasil dicatat.',
                timestamp: DateTime.now(),
                type: NotificationType.investment,
                actionData: inv.id,
              ),
            );
            _markAsNotified('inv_${inv.id}');
          }
        }
      }
    });

ref.listen(insuranceStreamProvider, (previous, next) {
      final prevList = previous?.valueOrNull;
      final nextList = next.valueOrNull;

      if (prevList != null && nextList != null && nextList.length > prevList.length) {
        final prevIds = prevList.map((i) => i.id).toSet();
        final newIns = nextList.where((i) => !prevIds.contains(i.id)).toList();

        for (final ins in newIns) {
          if (!_isNotified('ins_${ins.id}')) {
            ref.read(notificationNotifierProvider.notifier).addNotification(
              NotificationModel(
                id: 'ins_${ins.id}_${DateTime.now().millisecondsSinceEpoch}',
                title: 'Polis Asuransi Terdaftar! 🛡️',
                message: 'Polis asuransi "${ins.policyName}" dari ${ins.provider} dengan premi bulanan ${currencyFormatter.format(ins.premiumAmount)} telah berhasil terdaftar.',
                timestamp: DateTime.now(),
                type: NotificationType.system,
                actionData: ins.id,
              ),
            );
            _markAsNotified('ins_${ins.id}');
          }
        }
      }
    });

    return widget.child;
  }
}
