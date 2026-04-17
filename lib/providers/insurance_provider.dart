import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/insurance_model.dart';
import 'package:tabunganku/services/insurance_service.dart';

final insuranceStreamProvider = StreamProvider.autoDispose<List<InsuranceModel>>((ref) {
  final service = ref.watch(insuranceServiceProvider);
  return service.watchInsurance();
});
