import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/services/transaction_service.dart';

// Provider untuk TransactionService
final transactionServiceProvider = Provider<TransactionService>((ref) {
  // Timpa dengan Firebase service nanti
  return MockTransactionService();
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

// Provider untuk mendapatkan transaksi berdasarkan groupId (null untuk pribadi) secara reaktif
final transactionsByGroupProvider =
    Provider.autoDispose.family<List<TransactionModel>, String?>((ref, groupId) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  return transactionsAsync.maybeWhen(
    data: (data) => data.where((t) => t.groupId == groupId).toList(),
    orElse: () => <TransactionModel>[],
  );
});

// Provider untuk transaksi tertentu
final transactionProvider =
    FutureProvider.autoDispose.family<TransactionModel, String>((ref, id) async {
  final service = ref.watch(transactionServiceProvider);
  return service.getTransaction(id);
});
