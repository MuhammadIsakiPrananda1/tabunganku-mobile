/// Provider: SavingStreakProvider
///
/// Mengelola streak harian menabung sejati (reset jika skip hari),
/// badge reward berdasarkan streak, dan histori milestone.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model: StreakBadge
// ─────────────────────────────────────────────────────────────────────────────

enum StreakBadgeLevel {
  pemula,     // 3 hari
  konsisten,  // 7 hari
  disiplin,   // 14 hari
  handal,     // 30 hari
  master,     // 60 hari
  legenda,    // 100 hari
}

class StreakBadge {
  final StreakBadgeLevel level;
  final String name;
  final String emoji;
  final String description;
  final int requiredDays;
  final bool isEarned;

  const StreakBadge({
    required this.level,
    required this.name,
    required this.emoji,
    required this.description,
    required this.requiredDays,
    this.isEarned = false,
  });

  StreakBadge copyWith({bool? isEarned}) => StreakBadge(
        level: level,
        name: name,
        emoji: emoji,
        description: description,
        requiredDays: requiredDays,
        isEarned: isEarned ?? this.isEarned,
      );
}

const List<StreakBadge> kAllStreakBadges = [
  StreakBadge(
    level: StreakBadgeLevel.pemula,
    name: 'Pemula',
    emoji: '🌱',
    description: 'Menabung 3 hari berturut-turut',
    requiredDays: 3,
  ),
  StreakBadge(
    level: StreakBadgeLevel.konsisten,
    name: 'Konsisten',
    emoji: '🔥',
    description: 'Menabung 7 hari berturut-turut',
    requiredDays: 7,
  ),
  StreakBadge(
    level: StreakBadgeLevel.disiplin,
    name: 'Disiplin',
    emoji: '⚡',
    description: 'Menabung 14 hari berturut-turut',
    requiredDays: 14,
  ),
  StreakBadge(
    level: StreakBadgeLevel.handal,
    name: 'Handal',
    emoji: '💎',
    description: 'Menabung 30 hari berturut-turut',
    requiredDays: 30,
  ),
  StreakBadge(
    level: StreakBadgeLevel.master,
    name: 'Master',
    emoji: '🏆',
    description: 'Menabung 60 hari berturut-turut',
    requiredDays: 60,
  ),
  StreakBadge(
    level: StreakBadgeLevel.legenda,
    name: 'Legenda',
    emoji: '👑',
    description: 'Menabung 100 hari berturut-turut',
    requiredDays: 100,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Model: SavingStreakState
// ─────────────────────────────────────────────────────────────────────────────

class SavingStreakState {
  final int currentStreak;
  final int longestStreak;
  final int totalSavingDays;
  final DateTime? lastSavingDate;
  final List<DateTime> recentDays; // 30 hari terakhir yang ada aktivitas
  final List<StreakBadge> badges;

  const SavingStreakState({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalSavingDays = 0,
    this.lastSavingDate,
    this.recentDays = const [],
    this.badges = const [],
  });

  SavingStreakState copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalSavingDays,
    DateTime? lastSavingDate,
    List<DateTime>? recentDays,
    List<StreakBadge>? badges,
  }) {
    return SavingStreakState(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalSavingDays: totalSavingDays ?? this.totalSavingDays,
      lastSavingDate: lastSavingDate ?? this.lastSavingDate,
      recentDays: recentDays ?? this.recentDays,
      badges: badges ?? this.badges,
    );
  }

  /// Badge tertinggi yang sudah earned
  StreakBadge? get currentBadge {
    final earned = badges.where((b) => b.isEarned).toList();
    if (earned.isEmpty) return null;
    return earned.last;
  }

  /// Badge berikutnya yang belum earned
  StreakBadge? get nextBadge {
    final notEarned = badges.where((b) => !b.isEarned).toList();
    if (notEarned.isEmpty) return null;
    return notEarned.first;
  }

  /// Progress ke badge berikutnya (0.0 - 1.0)
  double get progressToNextBadge {
    final next = nextBadge;
    if (next == null) return 1.0;
    final prev = currentBadge;
    final prevReq = prev?.requiredDays ?? 0;
    final range = next.requiredDays - prevReq;
    final progress = currentStreak - prevReq;
    if (range <= 0) return 1.0;
    return (progress / range).clamp(0.0, 1.0);
  }

  /// Apakah hari ini sudah menabung
  bool get hasSavedToday {
    if (lastSavingDate == null) return false;
    final today = DateTime.now();
    final last = lastSavingDate!;
    return today.year == last.year &&
        today.month == last.month &&
        today.day == last.day;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class SavingStreakNotifier extends StateNotifier<SavingStreakState> {
  SavingStreakNotifier() : super(const SavingStreakState()) {
    _load();
  }

  static const _keyCurrentStreak = 'ss_current_streak';
  static const _keyLongestStreak = 'ss_longest_streak';
  static const _keyTotalDays = 'ss_total_days';
  static const _keyLastDate = 'ss_last_date';
  static const _keyRecentDays = 'ss_recent_days';
  static const _keyEarnedBadges = 'ss_earned_badges';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;
    final longestStreak = prefs.getInt(_keyLongestStreak) ?? 0;
    final totalDays = prefs.getInt(_keyTotalDays) ?? 0;
    final lastDateStr = prefs.getString(_keyLastDate);
    final recentDaysRaw = prefs.getStringList(_keyRecentDays) ?? [];
    final earnedBadgesRaw = prefs.getStringList(_keyEarnedBadges) ?? [];

    final lastDate =
        lastDateStr != null ? DateTime.tryParse(lastDateStr) : null;
    final recentDays =
        recentDaysRaw.map((d) => DateTime.parse(d)).toList();
    final earnedLevels =
        earnedBadgesRaw.map((e) => StreakBadgeLevel.values[int.parse(e)]).toSet();

    final badges = kAllStreakBadges.map((b) {
      return b.copyWith(isEarned: earnedLevels.contains(b.level));
    }).toList();

    // Cek apakah streak perlu di-reset (lebih dari 1 hari gap)
    int actualStreak = currentStreak;
    if (lastDate != null) {
      final today = _toDateOnly(DateTime.now());
      final last = _toDateOnly(lastDate);
      final diff = today.difference(last).inDays;
      if (diff > 1) {
        actualStreak = 0; // streak putus
      }
    }

    state = SavingStreakState(
      currentStreak: actualStreak,
      longestStreak: longestStreak,
      totalSavingDays: totalDays,
      lastSavingDate: lastDate,
      recentDays: recentDays,
      badges: badges,
    );

    if (actualStreak != currentStreak) {
      await prefs.setInt(_keyCurrentStreak, actualStreak);
    }
  }

  /// Catat aktivitas menabung hari ini
  Future<bool> recordSavingActivity() async {
    final today = DateTime.now();
    final todayOnly = _toDateOnly(today);

    // Sudah tercatat hari ini, skip
    if (state.hasSavedToday) return false;

    final prefs = await SharedPreferences.getInstance();

    // Hitung streak baru
    int newStreak = state.currentStreak;
    if (state.lastSavingDate == null) {
      newStreak = 1;
    } else {
      final lastOnly = _toDateOnly(state.lastSavingDate!);
      final diff = todayOnly.difference(lastOnly).inDays;
      if (diff == 1) {
        newStreak = state.currentStreak + 1;
      } else if (diff > 1) {
        newStreak = 1;
      }
    }

    final newLongest = newStreak > state.longestStreak
        ? newStreak
        : state.longestStreak;
    final newTotal = state.totalSavingDays + 1;

    // Update recent days (simpan 30 hari terakhir)
    final newRecentDays = [todayOnly, ...state.recentDays]
        .where((d) => todayOnly.difference(d).inDays <= 30)
        .toList();

    // Cek badge baru
    final newEarnedLevels = kAllStreakBadges
        .where((b) => newStreak >= b.requiredDays)
        .map((b) => b.level)
        .toSet();

    final updatedBadges = kAllStreakBadges.map((b) {
      return b.copyWith(isEarned: newEarnedLevels.contains(b.level));
    }).toList();

    // Simpan ke prefs
    await prefs.setInt(_keyCurrentStreak, newStreak);
    await prefs.setInt(_keyLongestStreak, newLongest);
    await prefs.setInt(_keyTotalDays, newTotal);
    await prefs.setString(_keyLastDate, today.toIso8601String());
    await prefs.setStringList(
      _keyRecentDays,
      newRecentDays.map((d) => d.toIso8601String()).toList(),
    );
    await prefs.setStringList(
      _keyEarnedBadges,
      newEarnedLevels.map((l) => l.index.toString()).toList(),
    );

    state = SavingStreakState(
      currentStreak: newStreak,
      longestStreak: newLongest,
      totalSavingDays: newTotal,
      lastSavingDate: today,
      recentDays: newRecentDays,
      badges: updatedBadges,
    );

    return true;
  }

  /// Reset semua data streak (untuk testing/debug)
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentStreak);
    await prefs.remove(_keyLongestStreak);
    await prefs.remove(_keyTotalDays);
    await prefs.remove(_keyLastDate);
    await prefs.remove(_keyRecentDays);
    await prefs.remove(_keyEarnedBadges);
    state = SavingStreakState(
      badges: kAllStreakBadges.toList(),
    );
  }

  DateTime _toDateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final savingStreakProvider =
    StateNotifierProvider<SavingStreakNotifier, SavingStreakState>((ref) {
  return SavingStreakNotifier();
});
