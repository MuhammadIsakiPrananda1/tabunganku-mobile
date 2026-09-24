/// Provider: SavingTargetProvider
//
// Menyediakan akses reaktif ke target tabungan.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/saving_target_model.dart';
import 'package:tabunganku/services/saving_target_service.dart';

final savingTargetServiceProvider = Provider<SavingTargetService>((ref) {
  return LocalSavingTargetService();
});

final savingTargetsStreamProvider =
    StreamProvider.autoDispose<List<SavingTargetModel>>((ref) {
  final service = ref.watch(savingTargetServiceProvider);
  return service.watchTargets();
});
