/// Provider: RoundUpProvider
///
/// Mengelola konfigurasi dan riwayat Round-Up Tabungan Otomatis.
/// Round-up mengumpulkan selisih pembulatan dari pengeluaran ke PiggyBank.
library;

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model: RoundUpMultiplier
// ─────────────────────────────────────────────────────────────────────────────

/// Kelipatan pembulatan yang tersedia
enum RoundUpMultiplier {
  rp1000(1000, 'Rp 1.000'),
  rp2000(2000, 'Rp 2.000'),
  rp5000(5000, 'Rp 5.000'),
  rp10000(10000, 'Rp 10.000');

  final int value;
  final String label;
  const RoundUpMultiplier(this.value, this.label);
}

// ─────────────────────────────────────────────────────────────────────────────
// Model: RoundUpLog
// ─────────────────────────────────────────────────────────────────────────────

class RoundUpLog {
  final String id;
  final DateTime date;
  final double originalAmount;
  final double roundedAmount;
  final double savedAmount;
  final String description;

  RoundUpLog({
    required this.id,
    required this.date,
    required this.originalAmount,
    required this.roundedAmount,
    required this.savedAmount,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'originalAmount': originalAmount,
        'roundedAmount': roundedAmount,
        'savedAmount': savedAmount,
        'description': description,
      };

  factory RoundUpLog.fromJson(Map<String, dynamic> json) => RoundUpLog(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        originalAmount: (json['originalAmount'] as num).toDouble(),
        roundedAmount: (json['roundedAmount'] as num).toDouble(),
        savedAmount: (json['savedAmount'] as num).toDouble(),
        description: json['description'] as String? ?? '',
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Model: RoundUpState
// ─────────────────────────────────────────────────────────────────────────────

class RoundUpState {
  final bool isActive;
  final RoundUpMultiplier multiplier;
  final List<RoundUpLog> history;
  final double totalSaved;

  const RoundUpState({
    this.isActive = false,
    this.multiplier = RoundUpMultiplier.rp1000,
    this.history = const [],
    this.totalSaved = 0.0,
  });

  RoundUpState copyWith({
    bool? isActive,
    RoundUpMultiplier? multiplier,
    List<RoundUpLog>? history,
    double? totalSaved,
  }) {
    return RoundUpState(
      isActive: isActive ?? this.isActive,
      multiplier: multiplier ?? this.multiplier,
      history: history ?? this.history,
      totalSaved: totalSaved ?? this.totalSaved,
    );
  }

  /// Hitung berapa yang akan dibulatkan dari suatu nominal
  static double calculateRoundUp(double amount, int multiplierValue) {
    if (amount <= 0) return 0;
    final remainder = amount % multiplierValue;
    if (remainder == 0) return 0;
    return multiplierValue - remainder;
  }

  /// Hitung nominal setelah dibulatkan ke atas
  static double calculateRounded(double amount, int multiplierValue) {
    if (amount <= 0) return 0;
    final remainder = amount % multiplierValue;
    if (remainder == 0) return amount;
    return amount + (multiplierValue - remainder);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class RoundUpNotifier extends StateNotifier<RoundUpState> {
  RoundUpNotifier() : super(const RoundUpState()) {
    _load();
  }

  static const _keyIsActive = 'roundup_is_active';
  static const _keyMultiplier = 'roundup_multiplier';
  static const _keyHistory = 'roundup_history';
  static const _keyTotalSaved = 'roundup_total_saved';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final isActive = prefs.getBool(_keyIsActive) ?? false;
    final multiplierIndex = prefs.getInt(_keyMultiplier) ?? 0;
    final historyRaw = prefs.getStringList(_keyHistory) ?? [];
    final totalSaved = prefs.getDouble(_keyTotalSaved) ?? 0.0;

    final multiplier = RoundUpMultiplier.values[
        multiplierIndex.clamp(0, RoundUpMultiplier.values.length - 1)];
    final history = historyRaw
        .map((e) => RoundUpLog.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();

    state = RoundUpState(
      isActive: isActive,
      multiplier: multiplier,
      history: history,
      totalSaved: totalSaved,
    );
  }

  /// Toggle aktivasi round-up
  Future<void> toggleActive() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state.isActive;
    await prefs.setBool(_keyIsActive, newValue);
    state = state.copyWith(isActive: newValue);
  }

  /// Ubah kelipatan pembulatan
  Future<void> setMultiplier(RoundUpMultiplier multiplier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMultiplier, multiplier.index);
    state = state.copyWith(multiplier: multiplier);
  }

  /// Tambah round-up log dan simpan ke total
  Future<double> addRoundUp({
    required double originalAmount,
    required String description,
  }) async {
    final saved = RoundUpState.calculateRoundUp(
      originalAmount,
      state.multiplier.value,
    );
    if (saved <= 0) return 0;

    final rounded = RoundUpState.calculateRounded(
      originalAmount,
      state.multiplier.value,
    );

    final log = RoundUpLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      originalAmount: originalAmount,
      roundedAmount: rounded,
      savedAmount: saved,
      description: description.isEmpty ? 'Pembulatan belanja' : description,
    );

    final newHistory = [log, ...state.history].take(100).toList();
    final newTotal = state.totalSaved + saved;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyHistory,
      newHistory.map((e) => jsonEncode(e.toJson())).toList(),
    );
    await prefs.setDouble(_keyTotalSaved, newTotal);

    state = state.copyWith(history: newHistory, totalSaved: newTotal);
    return saved;
  }

  /// Reset semua data round-up
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHistory);
    await prefs.setDouble(_keyTotalSaved, 0.0);
    state = state.copyWith(history: [], totalSaved: 0.0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final roundUpProvider =
    StateNotifierProvider<RoundUpNotifier, RoundUpState>((ref) {
  return RoundUpNotifier();
});
