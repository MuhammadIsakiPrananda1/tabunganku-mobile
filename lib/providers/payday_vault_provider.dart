import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabunganku/models/payday_vault_model.dart';

final paydayVaultProvider =
    StateNotifierProvider<PaydayVaultNotifier, PaydayVaultModel>((ref) {
  return PaydayVaultNotifier();
});

class PaydayVaultNotifier extends StateNotifier<PaydayVaultModel> {
  PaydayVaultNotifier() : super(PaydayVaultModel()) {
    _loadVault();
  }

  static const String _key = 'payday_vault_data';

  Future<void> _loadVault() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_key);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        state = PaydayVaultModel.fromJson(jsonStr);
      }
    } catch (_) {}
  }

  Future<void> _saveVault() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, state.toJson());
    } catch (_) {}
  }

  Future<void> updateSalaryAndRules({
    double? monthlySalary,
    int? paydayDate,
    double? needsPercent,
    double? wantsPercent,
    double? savingsPercent,
  }) async {
    state = state.copyWith(
      monthlySalary: monthlySalary ?? state.monthlySalary,
      paydayDate: paydayDate ?? state.paydayDate,
      needsPercent: needsPercent ?? state.needsPercent,
      wantsPercent: wantsPercent ?? state.wantsPercent,
      savingsPercent: savingsPercent ?? state.savingsPercent,
    );
    await _saveVault();
  }

  Future<void> lockVault({
    required double amount,
    required int durationDays,
  }) async {
    final lockUntilDate = DateTime.now().add(Duration(days: durationDays));
    state = state.copyWith(
      isVaultLocked: true,
      lockedAmount: amount,
      lockedUntil: lockUntilDate,
      lockDurationDays: durationDays,
    );
    await _saveVault();
  }

  Future<void> unlockVault() async {
    state = state.copyWith(
      isVaultLocked: false,
      unlockedCount: state.unlockedCount + 1,
    );
    await _saveVault();
  }

  Future<void> emergencyUnlock(String reason) async {
    state = state.copyWith(
      isVaultLocked: false,
      lastEmergencyUnlockReason: reason,
    );
    await _saveVault();
  }

  Future<void> resetAll() async {
    state = PaydayVaultModel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
