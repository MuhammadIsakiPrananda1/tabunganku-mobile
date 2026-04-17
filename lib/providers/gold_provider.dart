import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/gold_investment_model.dart';
import 'package:tabunganku/services/gold_service.dart';

final goldTransactionsStreamProvider = StreamProvider.autoDispose<List<GoldTransactionModel>>((ref) {
  final service = ref.watch(goldServiceProvider);
  return service.watchTransactions();
});
