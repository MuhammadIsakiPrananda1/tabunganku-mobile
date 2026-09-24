/// Provider: DebtProvider
//
// Menyediakan akses reaktif ke data hutang dan piutang.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/debt_model.dart';
import 'package:tabunganku/services/debt_service.dart';

final debtServiceProvider = Provider<DebtService>((ref) {
  return LocalDebtService();
});

final debtsStreamProvider = StreamProvider.autoDispose<List<DebtModel>>((ref) {
  final service = ref.watch(debtServiceProvider);
  return service.watchDebts();
});

final debtsProvider = FutureProvider.autoDispose<List<DebtModel>>((ref) async {
  final service = ref.watch(debtServiceProvider);
  return service.getDebts();
});
