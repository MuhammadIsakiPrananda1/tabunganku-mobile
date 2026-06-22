import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabunganku/models/nabung_bersama_model.dart';

class NabungBersamaService {
  static const String _storageKey = 'nabung_bersama_data';

  Future<List<NabungBersamaModel>> getNabungBersamaList() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data == null) return [];
    final List decoded = json.decode(data);
    return decoded.map((item) => NabungBersamaModel.fromJson(item)).toList();
  }

  Future<void> saveNabungBersamaList(List<NabungBersamaModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(list.map((a) => a.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }

  Future<void> addNabungBersama(NabungBersamaModel item) async {
    final list = await getNabungBersamaList();
    list.add(item);
    await saveNabungBersamaList(list);
  }

  Future<void> updateNabungBersama(NabungBersamaModel item) async {
    final list = await getNabungBersamaList();
    final index = list.indexWhere((a) => a.id == item.id);
    if (index != -1) {
      list[index] = item;
      await saveNabungBersamaList(list);
    }
  }

  Future<void> deleteNabungBersama(String id) async {
    final list = await getNabungBersamaList();
    list.removeWhere((a) => a.id == id);
    await saveNabungBersamaList(list);
  }
}
