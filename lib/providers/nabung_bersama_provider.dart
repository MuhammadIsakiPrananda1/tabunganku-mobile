import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/nabung_bersama_model.dart';
import 'package:tabunganku/services/nabung_bersama_service.dart';

final nabungBersamaServiceProvider = Provider<NabungBersamaService>((ref) {
  return NabungBersamaService();
});

class NabungBersamaNotifier extends StateNotifier<AsyncValue<List<NabungBersamaModel>>> {
  final NabungBersamaService _service;

  NabungBersamaNotifier(this._service) : super(const AsyncValue.loading()) {
    loadNabungBersamaList();
  }

  Future<void> loadNabungBersamaList() async {
    state = const AsyncValue.loading();
    try {
      final data = await _service.getNabungBersamaList();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addNabungBersama(NabungBersamaModel item) async {
    await _service.addNabungBersama(item);
    await loadNabungBersamaList();
  }

  Future<void> updateNabungBersama(NabungBersamaModel item) async {
    await _service.updateNabungBersama(item);
    await loadNabungBersamaList();
  }

  Future<void> deleteNabungBersama(String id) async {
    await _service.deleteNabungBersama(id);
    await loadNabungBersamaList();
  }
}

final nabungBersamaProvider = StateNotifierProvider<NabungBersamaNotifier, AsyncValue<List<NabungBersamaModel>>>((ref) {
  final service = ref.watch(nabungBersamaServiceProvider);
  return NabungBersamaNotifier(service);
});
