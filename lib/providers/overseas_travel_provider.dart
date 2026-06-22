import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/overseas_travel_model.dart';
import 'package:tabunganku/services/overseas_travel_service.dart';

final overseasTravelServiceProvider = Provider<OverseasTravelService>((ref) {
  return MockOverseasTravelService();
});

final overseasTravelStreamProvider =
    StreamProvider.autoDispose<List<OverseasTravelGoalModel>>((ref) {
  final service = ref.watch(overseasTravelServiceProvider);
  return service.watchGoals();
});
