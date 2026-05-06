import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/arisan_model.dart';
import 'package:tabunganku/services/arisan_service.dart';

final arisanServiceProvider = Provider<ArisanService>((ref) {
  return ArisanService();
});

class ArisanNotifier extends StateNotifier<AsyncValue<List<ArisanModel>>> {
  final ArisanService _service;

  ArisanNotifier(this._service) : super(const AsyncValue.loading()) {
    loadArisans();
  }

  Future<void> loadArisans() async {
    state = const AsyncValue.loading();
    try {
      final data = await _service.getArisans();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addArisan(ArisanModel arisan) async {
    await _service.addArisan(arisan);
    await loadArisans();
  }

  Future<void> updateArisan(ArisanModel arisan) async {
    await _service.updateArisan(arisan);
    await loadArisans();
  }

  Future<void> deleteArisan(String id) async {
    await _service.deleteArisan(id);
    await loadArisans();
  }
}

final arisanProvider = StateNotifierProvider<ArisanNotifier, AsyncValue<List<ArisanModel>>>((ref) {
  final service = ref.watch(arisanServiceProvider);
  return ArisanNotifier(service);
});
