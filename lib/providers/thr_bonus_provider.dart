import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabunganku/models/thr_bonus_model.dart';

final thrBonusProvider =
    StateNotifierProvider<ThrBonusNotifier, ThrBonusModel>((ref) {
  return ThrBonusNotifier();
});

class ThrBonusNotifier extends StateNotifier<ThrBonusModel> {
  ThrBonusNotifier() : super(ThrBonusModel()) {
    _loadData();
  }

  static const String _key = 'thr_bonus_planner_data';

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_key);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        state = ThrBonusModel.fromJson(jsonStr);
      }
    } catch (_) {}
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, state.toJson());
    } catch (_) {}
  }

  Future<void> updateTotalThr(double newAmount) async {
    state = state.copyWith(totalThr: newAmount);
    await _saveData();
  }

  Future<void> selectPreset(String eventType) async {
    state = ThrBonusModel.createPreset(eventType, state.totalThr);
    await _saveData();
  }

  Future<void> updateCategoryPercentage(String categoryId, double newPercent) async {
    final updated = state.categories.map((c) {
      if (c.id == categoryId) {
        return c.copyWith(percentage: newPercent);
      }
      return c;
    }).toList();

    state = state.copyWith(categories: updated);
    await _saveData();
  }

  Future<void> updateCategoryActualSpent(String categoryId, double spent) async {
    final updated = state.categories.map((c) {
      if (c.id == categoryId) {
        return c.copyWith(actualSpent: spent);
      }
      return c;
    }).toList();

    state = state.copyWith(categories: updated);
    await _saveData();
  }

  Future<void> addRecipient(
      String categoryId, String name, double amount) async {
    final newRecipient = ThrRecipientItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      amount: amount,
    );

    final updated = state.categories.map((c) {
      if (c.id == categoryId) {
        final list = List<ThrRecipientItem>.from(c.recipients)..add(newRecipient);
        return c.copyWith(recipients: list);
      }
      return c;
    }).toList();

    state = state.copyWith(categories: updated);
    await _saveData();
  }

  Future<void> toggleRecipientGiven(String categoryId, String recipientId) async {
    final updated = state.categories.map((c) {
      if (c.id == categoryId) {
        final list = c.recipients.map((r) {
          if (r.id == recipientId) {
            return r.copyWith(isGiven: !r.isGiven);
          }
          return r;
        }).toList();
        return c.copyWith(recipients: list);
      }
      return c;
    }).toList();

    state = state.copyWith(categories: updated);
    await _saveData();
  }

  Future<void> deleteRecipient(String categoryId, String recipientId) async {
    final updated = state.categories.map((c) {
      if (c.id == categoryId) {
        final list = c.recipients.where((r) => r.id != recipientId).toList();
        return c.copyWith(recipients: list);
      }
      return c;
    }).toList();

    state = state.copyWith(categories: updated);
    await _saveData();
  }

  Future<void> addCategory(ThrCategory category) async {
    final updated = List<ThrCategory>.from(state.categories)..add(category);
    state = state.copyWith(categories: updated);
    await _saveData();
  }

  Future<void> removeCategory(String categoryId) async {
    final updated = state.categories.where((c) => c.id != categoryId).toList();
    state = state.copyWith(categories: updated);
    await _saveData();
  }

  Future<void> resetToDefault() async {
    state = ThrBonusModel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
