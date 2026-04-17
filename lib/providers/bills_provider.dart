import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/bill_model.dart';
import 'package:tabunganku/services/bills_service.dart';

final billsStreamProvider = StreamProvider.autoDispose<List<BillModel>>((ref) {
  final service = ref.watch(billsServiceProvider);
  return service.watchBills();
});
