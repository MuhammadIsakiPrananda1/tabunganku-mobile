import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/investment_model.dart';
import 'package:tabunganku/services/investment_service.dart';

final investmentStreamProvider = StreamProvider.autoDispose<List<InvestmentModel>>((ref) {
  final service = ref.watch(investmentServiceProvider);
  return service.watchInvestments();
});
