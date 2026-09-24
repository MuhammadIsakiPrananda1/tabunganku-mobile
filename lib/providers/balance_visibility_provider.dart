/// Provider: BalanceVisibilityProvider
//
// Mengelola preferensi tampil/sembunyikan saldo di seluruh app.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final balanceVisibilityProvider =
    StateNotifierProvider<BalanceVisibilityNotifier, bool>((ref) {
  return BalanceVisibilityNotifier();
});

class BalanceVisibilityNotifier extends StateNotifier<bool> {
  BalanceVisibilityNotifier([bool? initial]) : super(initial ?? true) {
    if (initial == null) {
      _loadPreference();
    }
  }

  static const String _prefKey = 'pref_show_balance';

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(_prefKey);
      if (saved != null) {
        state = saved;
      }
    } catch (_) {}
  }

  Future<void> toggle() async {
    final next = !state;
    state = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, next);
    } catch (_) {}
  }

  Future<void> setVisibility(bool visible) async {
    state = visible;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, visible);
    } catch (_) {}
  }
}
