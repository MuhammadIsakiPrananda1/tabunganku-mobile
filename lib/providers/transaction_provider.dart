import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/services/transaction_service.dart';
import 'package:tabunganku/providers/challenge_provider.dart';

// Provider untuk TransactionService
final transactionServiceProvider = Provider<TransactionService>((ref) {
  final challengeService = ref.watch(challengeServiceProvider);
  return MockTransactionService(challengeService: challengeService);
});

// Helper provider untuk menambah transaksi dengan auto-update challenge
final addTransactionProvider = Provider((ref) {
  return (TransactionModel transaction) async {
    final transactionService = ref.read(transactionServiceProvider);
    final challengeService = ref.read(challengeServiceProvider);
    
    // Add transaction
    final result = await transactionService.addTransaction(transaction);
    
    // Auto-update challenge progress
    await challengeService.checkAndUpdateChallengeFromTransaction(transaction);
    
    // Refresh providers
    ref.invalidate(transactionsProvider);
    ref.invalidate(activeChallengesProvider);
    ref.invalidate(currentStreakProvider);
    ref.invalidate(totalPointsProvider);
    
    return result;
  };
});

// Provider untuk mendapatkan semua transaksi
final transactionsProvider = FutureProvider.autoDispose<List<TransactionModel>>((ref) async {
  final service = ref.watch(transactionServiceProvider);
  return service.getTransactions();
});

// Provider untuk menonton transaksi secara real-time
final transactionsStreamProvider =
    StreamProvider.autoDispose<List<TransactionModel>>((ref) {
  final service = ref.watch(transactionServiceProvider);
  return service.watchTransactions();
});

// Provider untuk mendapatkan transaksi (null untuk filter jika diperlukan nanti)
final transactionsByGroupProvider =
    Provider.autoDispose.family<List<TransactionModel>, String?>((ref, groupId) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  return transactionsAsync.maybeWhen(
    data: (data) => data.toList(),
    orElse: () => <TransactionModel>[],
  );
});

// Provider untuk transaksi tertentu
final transactionProvider =
    FutureProvider.autoDispose.family<TransactionModel, String>((ref, id) async {
  final service = ref.watch(transactionServiceProvider);
  return service.getTransaction(id);
});

// Provider untuk menghitung streak secara mandiri dari transaksi
final savingStreakProvider = Provider.autoDispose<int>((ref) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  return transactionsAsync.maybeWhen(
    data: (transactions) {
      // Ambil transaksi personal (groupId null), baik pemasukan (income) maupun pengeluaran (expense)
      final personalTx = transactions
          .where((t) => t.groupId == null)
          .toList();
      if (personalTx.isEmpty) return 0;

      // Dapatkan tanggal unik (hanya hari/bulan/tahun) dan urutkan descending (terbaru dahulu)
      final dates = personalTx
          .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      if (dates.isEmpty) return 0;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final newestDate = dates.first;

      final daysDiffFromToday = today.difference(newestDate).inDays;
      if (daysDiffFromToday > 1) {
        // Jika transaksi terakhir lebih lama dari kemarin, streak pecah/reset ke 0
        return 0;
      }

      int streakCount = 1;
      for (int i = 0; i < dates.length - 1; i++) {
        final diff = dates[i].difference(dates[i + 1]).inDays;
        if (diff == 1) {
          streakCount++;
        } else {
          break;
        }
      }
      return streakCount;
    },
    orElse: () => 0,
  );
});
