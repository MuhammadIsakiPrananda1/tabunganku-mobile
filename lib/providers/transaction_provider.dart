/// Provider: TransactionProvider
///
/// Menyediakan akses reaktif ke transaksi keuangan dan statistik terkait.
///
/// ## Arsitektur
/// - [transactionServiceProvider] — singleton service layer
/// - [addTransactionProvider] — action provider untuk tambah transaksi
/// - [transactionsProvider] — FutureProvider snapshot sekali
/// - [transactionsStreamProvider] — StreamProvider reaktif
/// - [savingStreakProvider] — hitung hari unik aktivitas keuangan
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/challenge_provider.dart';
import 'package:tabunganku/services/transaction_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Service provider
// ─────────────────────────────────────────────────────────────────────────────

final transactionServiceProvider = Provider<TransactionService>((ref) {
  final challengeService = ref.watch(challengeServiceProvider);
  return LocalTransactionService(challengeService: challengeService);
});

// ─────────────────────────────────────────────────────────────────────────────
// Action providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider yang mengembalikan fungsi untuk menambah transaksi baru.
///
/// Challenge check **hanya** dilakukan di dalam [TransactionService.addTransaction]
/// untuk menghindari double-check.
final addTransactionProvider = Provider((ref) {
  return (TransactionModel transaction) async {
    final service = ref.read(transactionServiceProvider);
    final result = await service.addTransaction(transaction);

    // Invalidate semua provider yang bergantung pada data transaksi
    ref.invalidate(transactionsProvider);
    ref.invalidate(activeChallengesProvider);
    ref.invalidate(currentStreakProvider);
    ref.invalidate(totalPointsProvider);

    return result;
  };
});

// ─────────────────────────────────────────────────────────────────────────────
// Data providers
// ─────────────────────────────────────────────────────────────────────────────

/// Snapshot one-shot dari semua transaksi (auto-dispose).
final transactionsProvider =
    FutureProvider.autoDispose<List<TransactionModel>>((ref) async {
  final service = ref.watch(transactionServiceProvider);
  return service.getTransactions();
});

/// Stream reaktif dari semua transaksi — diperbarui otomatis saat ada perubahan.
final transactionsStreamProvider =
    StreamProvider.autoDispose<List<TransactionModel>>((ref) {
  final service = ref.watch(transactionServiceProvider);
  return service.watchTransactions();
});

/// Filter transaksi berdasarkan [groupId]. Null = semua transaksi.
final transactionsByGroupProvider =
    Provider.autoDispose.family<List<TransactionModel>, String?>((ref, groupId) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  return transactionsAsync.maybeWhen(
    data: (data) => data.toList(),
    orElse: () => <TransactionModel>[],
  );
});

/// Satu transaksi berdasarkan ID.
final transactionProvider =
    FutureProvider.autoDispose.family<TransactionModel, String>((ref, id) async {
  final service = ref.watch(transactionServiceProvider);
  return service.getTransaction(id);
});

// ─────────────────────────────────────────────────────────────────────────────
// Statistics providers
// ─────────────────────────────────────────────────────────────────────────────

/// Hitung streak berdasarkan jumlah **hari unik** yang ada transaksinya.
///
/// Streak tidak di-reset saat hari tanpa aktivitas — ini by design agar
/// pengguna tidak kehilangan motivasi karena lupa input satu hari.
final savingStreakProvider = Provider.autoDispose<int>((ref) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  return transactionsAsync.maybeWhen(
    data: (transactions) {
      if (transactions.isEmpty) return 0;
      final uniqueDays = transactions
          .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
          .toSet();
      return uniqueDays.length;
    },
    orElse: () => 0,
  );
});
