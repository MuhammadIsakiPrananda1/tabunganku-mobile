import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/services/transaction_service.dart';
import 'package:tabunganku/providers/challenge_provider.dart';

final transactionServiceProvider = Provider<TransactionService>((ref) {
  final challengeService = ref.watch(challengeServiceProvider);
  return MockTransactionService(challengeService: challengeService);
});

final addTransactionProvider = Provider((ref) {
  return (TransactionModel transaction) async {
    final transactionService = ref.read(transactionServiceProvider);
    final challengeService = ref.read(challengeServiceProvider);

    final result = await transactionService.addTransaction(transaction);

    await challengeService.checkAndUpdateChallengeFromTransaction(transaction);

    ref.invalidate(transactionsProvider);
    ref.invalidate(activeChallengesProvider);
    ref.invalidate(currentStreakProvider);
    ref.invalidate(totalPointsProvider);

    return result;
  };
});

final transactionsProvider =
    FutureProvider.autoDispose<List<TransactionModel>>((ref) async {
  final service = ref.watch(transactionServiceProvider);
  return service.getTransactions();
});

final transactionsStreamProvider =
    StreamProvider.autoDispose<List<TransactionModel>>((ref) {
  final service = ref.watch(transactionServiceProvider);
  return service.watchTransactions();
});

final transactionsByGroupProvider = Provider.autoDispose
    .family<List<TransactionModel>, String?>((ref, groupId) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  return transactionsAsync.maybeWhen(
    data: (data) => data.toList(),
    orElse: () => <TransactionModel>[],
  );
});

final transactionProvider = FutureProvider.autoDispose
    .family<TransactionModel, String>((ref, id) async {
  final service = ref.watch(transactionServiceProvider);
  return service.getTransaction(id);
});

/// Hitung streak harian berdasarkan total hari unik aktivitas transaksi (pemasukan & pengeluaran).
/// Streak tidak di-reset ketika tidak ada aktivitas (hari berikutnya tanpa transaksi)
/// atau saat memasukkan transaksi baru setelah beberapa hari/bulan tanpa aktivitas.
final savingStreakProvider = Provider.autoDispose<int>((ref) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  return transactionsAsync.maybeWhen(
    data: (transactions) {
      if (transactions.isEmpty) return 0;

      // Ambil semua hari unik di mana ada transaksi (semua tipe)
      final dates = transactions
          .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
          .toSet()
          .toList();

      return dates.length;
    },
    orElse: () => 0,
  );
});
