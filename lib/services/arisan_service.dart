import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabunganku/models/arisan_model.dart';

class ArisanService {
  static const String _storageKey = 'arisan_data';

  Future<List<ArisanModel>> getArisans() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data == null) return [];
    final List decoded = json.decode(data);
    return decoded.map((item) => ArisanModel.fromJson(item)).toList();
  }

  Future<void> saveArisans(List<ArisanModel> arisans) async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(arisans.map((a) => a.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }

  Future<void> addArisan(ArisanModel arisan) async {
    final arisans = await getArisans();
    arisans.add(arisan);
    await saveArisans(arisans);
  }

  Future<void> updateArisan(ArisanModel arisan) async {
    final arisans = await getArisans();
    final index = arisans.indexWhere((a) => a.id == arisan.id);
    if (index != -1) {
      arisans[index] = arisan;
      await saveArisans(arisans);
    }
  }

  Future<void> deleteArisan(String id) async {
    final arisans = await getArisans();
    arisans.removeWhere((a) => a.id == id);
    await saveArisans(arisans);
  }
}
