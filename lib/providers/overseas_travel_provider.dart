/// Provider: OverseasTravelProvider
//
// Menyediakan akses reaktif ke rencana perjalanan luar negeri.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/overseas_travel_model.dart';
import 'package:tabunganku/services/overseas_travel_service.dart';

final overseasTravelServiceProvider = Provider<OverseasTravelService>((ref) {
  return LocalOverseasTravelService();
});

final overseasTravelStreamProvider =
    StreamProvider.autoDispose<List<OverseasTravelGoalModel>>((ref) {
  final service = ref.watch(overseasTravelServiceProvider);
  return service.watchGoals();
});
