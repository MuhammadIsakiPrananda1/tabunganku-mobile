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

final transactionsProvider = FutureProvider.autoDispose<List<TransactionModel>>((ref) async {
  final service = ref.watch(transactionServiceProvider);
  return service.getTransactions();
});

final transactionsStreamProvider =
    StreamProvider.autoDispose<List<TransactionModel>>((ref) {
  final service = ref.watch(transactionServiceProvider);
  return service.watchTransactions();
});

final transactionsByGroupProvider =
    Provider.autoDispose.family<List<TransactionModel>, String?>((ref, groupId) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  return transactionsAsync.maybeWhen(
    data: (data) => data.toList(),
    orElse: () => <TransactionModel>[],
  );
});

final transactionProvider =
    FutureProvider.autoDispose.family<TransactionModel, String>((ref, id) async {
  final service = ref.watch(transactionServiceProvider);
  return service.getTransaction(id);
});

final savingStreakProvider = Provider.autoDispose<int>((ref) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  return transactionsAsync.maybeWhen(
    data: (transactions) {

      final incomeTx = transactions
          .where((t) => t.groupId == null && t.type == TransactionType.income)
          .toList();
      if (incomeTx.isEmpty) return 0;

final dates = incomeTx
          .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      if (dates.isEmpty) return 0;

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
