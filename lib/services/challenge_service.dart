import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabunganku/core/security/secure_storage_service.dart';
import 'package:tabunganku/core/constants/app_version.dart';
import 'package:tabunganku/models/challenge_model.dart';
import 'package:tabunganku/models/challenge_template_model.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/services/challenge_templates.dart';
import 'package:tabunganku/services/badge_service.dart';
import 'package:tabunganku/core/constants/transaction_categories.dart';

/// Service untuk mengelola Challenge
abstract class ChallengeService {
  Future<List<ChallengeModel>> getChallenges();
  Future<List<ChallengeModel>> getActiveChallenges();
  Future<List<ChallengeModel>> getCompletedChallenges();
  Future<ChallengeModel> getChallenge(String id);
  Future<ChallengeModel> createChallenge(
    ChallengeTemplateModel template, {
    double? customTargetAmount,
    int? customDuration,
    bool isGroupChallenge = false,
    String? groupId,
  });
  Future<ChallengeModel> createCustomChallenge(ChallengeModel challenge);
  Future<void> updateChallenge(ChallengeModel challenge);
  Future<void> deleteChallenge(String id);
  Future<void> abandonChallenge(String id);
  Future<void> updateChallengeProgress(String challengeId, double progress);
  Future<void> checkAndUpdateChallengeFromTransaction(
      TransactionModel transaction);
  Future<int> getCurrentStreak();
  Future<int> getTotalPoints();
  Stream<List<ChallengeModel>> watchActiveChallenges();
  List<ChallengeTemplateModel> getAllTemplates();
  ChallengeTemplateModel? getTemplateById(String id);
}

/// Mock implementation dengan SharedPreferences
class MockChallengeService implements ChallengeService {
  final BadgeService? badgeService;

  MockChallengeService({this.badgeService});

  static final StreamController<void> _updateController =
      StreamController<void>.broadcast();
  static Stream<void> get updateStream => _updateController.stream;

  void _notifyListeners() {
    _updateController.add(null);
  }

  static const String _storagePrefix = 'challenges_user_';
  static const String _streakKey = 'challenge_streak_';
  static const String _pointsKey = 'challenge_points_';
  static const String _lastCompletionKey = 'last_challenge_completion_';

  static final SecureStorageService _secureStorage = SecureStorageService();
  Future<SharedPreferences>? _prefsFuture;
  static final Map<String, List<ChallengeModel>> _userChallenges = {};
  static final StreamController<List<ChallengeModel>> _streamController =
      StreamController<List<ChallengeModel>>.broadcast();

  Future<SharedPreferences> _getPrefs() {
    _prefsFuture ??= SharedPreferences.getInstance();
    return _prefsFuture!;
  }

  Future<String> _getCurrentUserId() async {
    final userId = await _secureStorage.getUserId();
    return (userId == null || userId.isEmpty) ? 'guest' : userId;
  }

  Future<void> _ensureUserLoaded(String userId) async {
    if (_userChallenges.containsKey(userId)) {
      return;
    }

    final prefs = await _getPrefs();
    final key = '$_storagePrefix$userId';
    final jsonString = prefs.getString(key);

    if (jsonString == null || jsonString.isEmpty) {
      _userChallenges[userId] = [];
      return;
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      _userChallenges[userId] = jsonList
          .map((json) => ChallengeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _userChallenges[userId] = [];
    }
  }

  Future<void> _saveUserChallenges(String userId) async {
    final prefs = await _getPrefs();
    final key = '$_storagePrefix$userId';
    final challenges = _userChallenges[userId] ?? [];
    final jsonString = jsonEncode(challenges.map((t) => t.toJson()).toList());
    await prefs.setString(key, jsonString);
  }

  Future<void> _emitChallenges(String userId) async {
    final activeChallenges = (_userChallenges[userId] ?? [])
        .where((c) => c.status == ChallengeStatus.active)
        .toList();
    _streamController.add(activeChallenges);
    _notifyListeners();
  }

  @override
  Future<List<ChallengeModel>> getChallenges() async {
    final userId = await _getCurrentUserId();
    await _ensureUserLoaded(userId);
    return List.from(_userChallenges[userId] ?? []);
  }

  @override
  Future<List<ChallengeModel>> getActiveChallenges() async {
    final challenges = await getChallenges();
    return challenges.where((c) => c.status == ChallengeStatus.active).toList();
  }

  @override
  Future<List<ChallengeModel>> getCompletedChallenges() async {
    final challenges = await getChallenges();
    return challenges
        .where((c) => c.status == ChallengeStatus.completed)
        .toList();
  }

  @override
  Future<ChallengeModel> getChallenge(String id) async {
    final challenges = await getChallenges();
    return challenges.firstWhere(
      (c) => c.id == id,
      orElse: () => throw Exception('Challenge not found'),
    );
  }

  @override
  Future<ChallengeModel> createChallenge(
    ChallengeTemplateModel template, {
    double? customTargetAmount,
    int? customDuration,
    bool isGroupChallenge = false,
    String? groupId,
  }) async {
    final challenge = template.toChallenge(
      customTargetAmount: customTargetAmount,
      customDuration: customDuration,
      isGroupChallenge: isGroupChallenge,
      groupId: groupId,
    );

    return await createCustomChallenge(challenge);
  }

  @override
  Future<ChallengeModel> createCustomChallenge(ChallengeModel challenge) async {
    final userId = await _getCurrentUserId();
    await _ensureUserLoaded(userId);

    _userChallenges[userId]!.add(challenge);
    await _saveUserChallenges(userId);
    await _emitChallenges(userId);

    return challenge;
  }

  @override
  Future<void> updateChallenge(ChallengeModel challenge) async {
    final userId = await _getCurrentUserId();
    await _ensureUserLoaded(userId);

    final index =
        _userChallenges[userId]!.indexWhere((c) => c.id == challenge.id);
    if (index != -1) {
      _userChallenges[userId]![index] = challenge;
      await _saveUserChallenges(userId);
      await _emitChallenges(userId);
    }
  }

  @override
  Future<void> deleteChallenge(String id) async {
    final userId = await _getCurrentUserId();
    await _ensureUserLoaded(userId);

    _userChallenges[userId]!.removeWhere((c) => c.id == id);
    await _saveUserChallenges(userId);
    await _emitChallenges(userId);
  }

  @override
  Future<void> abandonChallenge(String id) async {
    final challenge = await getChallenge(id);
    final abandoned = challenge.copyWith(
      status: ChallengeStatus.abandoned,
    );
    await updateChallenge(abandoned);
  }

  @override
  Future<void> updateChallengeProgress(
      String challengeId, double progress) async {
    final challenge = await getChallenge(challengeId);

    // Check if challenge should be completed
    ChallengeStatus newStatus = challenge.status;
    DateTime? completedDate;

    if (challenge.status != ChallengeStatus.completed &&
        challenge.targetAmount != null && progress >= challenge.targetAmount!) {
      newStatus = ChallengeStatus.completed;
      completedDate = DateTime.now();

      // Update streak and points
      await _updateStreakOnCompletion();
      await _addPoints(challenge.points);

      // Unlock badges
      if (badgeService != null) {
        final currentStreakVal = await getCurrentStreak();
        final currentPointsVal = await getTotalPoints();
        await badgeService!.checkAndUnlockBadges(currentPointsVal, currentStreakVal);

        // First challenge completion badge
        final completedList = await getCompletedChallenges();
        if (completedList.isEmpty) {
          await badgeService!.unlockFirstChallengeBadge();
        }

        // Specific badge from template
        if (challenge.badgeId != null) {
          await badgeService!.unlockChallengeBadge(challenge.badgeId!);
        }
      }
    }

    // Check if challenge expired
    if (DateTime.now().isAfter(challenge.endDate) &&
        newStatus != ChallengeStatus.completed) {
      newStatus = ChallengeStatus.failed;
    }

    final updated = challenge.copyWith(
      currentProgress: progress,
      status: newStatus,
      completedDate: completedDate,
    );

    await updateChallenge(updated);
  }

  bool _isCategoryMatch(String txCatLabel, String? targetCat) {
    if (targetCat == null || targetCat.isEmpty) return false;
    final txCatLower = txCatLabel.toLowerCase().trim();
    final targetCatLower = targetCat.toLowerCase().trim();

    // 1. Direct label match (case insensitive)
    if (txCatLower == targetCatLower) return true;

    // 2. Find the TransactionCategory in AppCategories to get its group
    TransactionCategory? foundCategory;
    for (final cat in AppCategories.expenseCategories) {
      if (cat.label.toLowerCase().trim() == txCatLower) {
        foundCategory = cat;
        break;
      }
    }
    if (foundCategory == null) {
      for (final cat in AppCategories.incomeCategories) {
        if (cat.label.toLowerCase().trim() == txCatLower) {
          foundCategory = cat;
          break;
        }
      }
    }

    if (foundCategory != null) {
      final groupLower = foundCategory.group.toLowerCase().trim();
      // Match group name
      if (groupLower == targetCatLower) return true;

      // Handle mappings/compatibility for older target categories
      // e.g. target 'transportasi & bensin' matches group 'transportasi'
      if (targetCatLower == 'transportasi & bensin' && groupLower == 'transportasi') return true;
      if (targetCatLower == 'transportasi' && groupLower == 'transportasi & bensin') return true;

      // target 'belanja / lifestyle' matches group 'belanja & sembako' or 'gaya hidup & hiburan'
      if (targetCatLower == 'belanja / lifestyle' &&
          (groupLower == 'belanja & sembako' || groupLower == 'gaya hidup & hiburan')) {
        return true;
      }

      // target 'hiburan & langganan' matches group 'gaya hidup & hiburan' or 'pengeluaran digital'
      if (targetCatLower == 'hiburan & langganan' &&
          (groupLower == 'gaya hidup & hiburan' || groupLower == 'pengeluaran digital')) {
        return true;
      }

      // target 'biaya admin & lainnya' matches group 'lainnya' or 'keuangan'
      if (targetCatLower == 'biaya admin & lainnya' &&
          (groupLower == 'lainnya' || groupLower == 'keuangan')) {
        return true;
      }
    }

    // 3. Fallback: partial match
    if (txCatLower.contains(targetCatLower) || targetCatLower.contains(txCatLower)) return true;

    return false;
  }

  @override
  Future<void> checkAndUpdateChallengeFromTransaction(
      TransactionModel transaction) async {
    final activeChallenges = await getActiveChallenges();
    debugPrint(
        'ChallengeService: Checking ${activeChallenges.length} active challenges for transaction: ${transaction.title} (${transaction.category})');

    for (final challenge in activeChallenges) {
      switch (challenge.targetType) {
        case ChallengeTargetType.saveAmount:
          if (transaction.type == TransactionType.income) {
            debugPrint(
                'ChallengeService: Updating saveAmount challenge ${challenge.id}');
            await updateChallengeProgress(
              challenge.id,
              challenge.currentProgress + transaction.amount,
            );
          }
          break;

        case ChallengeTargetType.limitExpense:
          if (transaction.type == TransactionType.expense) {
            final totalExpense = challenge.currentProgress + transaction.amount;
            debugPrint(
                'ChallengeService: Updating limitExpense challenge ${challenge.id}. Current total: $totalExpense');
            if (challenge.targetAmount != null &&
                totalExpense > challenge.targetAmount!) {
              debugPrint(
                  'ChallengeService: Challenge ${challenge.id} FAILED (limit exceeded)');
              final failed = challenge.copyWith(status: ChallengeStatus.failed);
              await updateChallenge(failed);
            } else {
              await updateChallengeProgress(challenge.id, totalExpense);
            }
          }
          break;

        case ChallengeTargetType.zeroExpense:
          if (transaction.type == TransactionType.expense) {
            debugPrint(
                'ChallengeService: Challenge ${challenge.id} FAILED (zeroExpense violation)');
            final failed = challenge.copyWith(status: ChallengeStatus.failed);
            await updateChallenge(failed);
          }
          break;

        case ChallengeTargetType.categoryLimit:
          if (transaction.type == TransactionType.expense &&
              _isCategoryMatch(transaction.category, challenge.targetCategory)) {
            final categoryExpense =
                challenge.currentProgress + transaction.amount;
            debugPrint(
                'ChallengeService: Updating categoryLimit challenge ${challenge.id}. New total: $categoryExpense');
            if (challenge.targetAmount != null &&
                categoryExpense > challenge.targetAmount!) {
              debugPrint(
                  'ChallengeService: Challenge ${challenge.id} FAILED (category limit exceeded)');
              final failed = challenge.copyWith(status: ChallengeStatus.failed);
              await updateChallenge(failed);
            } else {
              await updateChallengeProgress(challenge.id, categoryExpense);
            }
          }
          break;

        case ChallengeTargetType.noTransactionType:
          if (_isCategoryMatch(transaction.category, challenge.targetCategory)) {
            debugPrint(
                'ChallengeService: Challenge ${challenge.id} FAILED (forbidden category used)');
            final failed = challenge.copyWith(status: ChallengeStatus.failed);
            await updateChallenge(failed);
          }
          break;
        case ChallengeTargetType.custom:
          // For custom challenges, we might just track activity
          // e.g., 'Input All Expense' simply increments progress by 1 for each transaction
          await updateChallengeProgress(
              challenge.id, challenge.currentProgress + 1);
          break;
      }
    }
  }

  // ── Secure storage backup keys ─────────────────────────────────────────
  static const String _secureStreakPrefix = 'secure_streak_';
  static const String _securePointsPrefix = 'secure_points_';
  static const String _secureLastCompletionPrefix = 'secure_last_completion_';

  /// Restore streak & points from secure storage into SharedPreferences
  /// jika SharedPreferences kosong (misal setelah update/reinstall).
  Future<void> _restoreFromSecureStorageIfNeeded(
      SharedPreferences prefs, String userId) async {
    final streakKey = '$_streakKey$userId';
    final pointsKey = '$_pointsKey$userId';
    final lastCompletionKey = '$_lastCompletionKey$userId';

    final prefStreak = prefs.getInt(streakKey);
    final prefPoints = prefs.getInt(pointsKey);
    final prefLastCompletion = prefs.getString(lastCompletionKey);

    // Pulihkan streak jika null atau 0
    if (prefStreak == null || prefStreak == 0) {
      final secStreak =
          await _secureStorage.readSecureData('$_secureStreakPrefix$userId');
      if (secStreak != null) {
        final val = int.tryParse(secStreak) ?? 0;
        if (val > 0) {
          await prefs.setInt(streakKey, val);
          debugPrint('ChallengeService: Restored streak from secure storage: $val');
        }
      }
    }

    // Pulihkan points jika null atau 0
    if (prefPoints == null || prefPoints == 0) {
      final secPoints =
          await _secureStorage.readSecureData('$_securePointsPrefix$userId');
      if (secPoints != null) {
        final val = int.tryParse(secPoints) ?? 0;
        if (val > 0) {
          await prefs.setInt(pointsKey, val);
          debugPrint('ChallengeService: Restored points from secure storage: $val');
        }
      }
    }

    // Pulihkan last completion jika null atau kosong
    if (prefLastCompletion == null || prefLastCompletion.isEmpty) {
      final secLastCompletion = await _secureStorage
          .readSecureData('$_secureLastCompletionPrefix$userId');
      if (secLastCompletion != null && secLastCompletion.isNotEmpty) {
        await prefs.setString(lastCompletionKey, secLastCompletion);
        debugPrint('ChallengeService: Restored last completion from secure storage: $secLastCompletion');
      }
    }

    final lastVersionKey = 'challenge_last_version_$userId';
    final prefLastVersion = prefs.getString(lastVersionKey);

    // Pulihkan last completed version jika null atau kosong
    if (prefLastVersion == null || prefLastVersion.isEmpty) {
      final secLastVersion = await _secureStorage
          .readSecureData('secure_last_completed_version_$userId');
      if (secLastVersion != null && secLastVersion.isNotEmpty) {
        await prefs.setString(lastVersionKey, secLastVersion);
        debugPrint('ChallengeService: Restored last completed version from secure storage: $secLastVersion');
      }
    }
  }

  Future<void> _updateStreakOnCompletion() async {
    final prefs = await _getPrefs();
    final userId = await _getCurrentUserId();
    final streakKey = '$_streakKey$userId';
    final lastCompletionKey = '$_lastCompletionKey$userId';
    final lastVersionKey = 'challenge_last_version_$userId';

    // Pulihkan dulu jika SharedPreferences kosong atau parsial
    await _restoreFromSecureStorageIfNeeded(prefs, userId);

    final currentStreak = prefs.getInt(streakKey) ?? 0;
    final lastCompletionStr = prefs.getString(lastCompletionKey);
    final lastCompletedVersion = prefs.getString(lastVersionKey) ??
        await _secureStorage.readSecureData('secure_last_completed_version_$userId');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int newStreak;
    // Deteksi jika aplikasi baru di-update (versi berbeda, atau versi null tapi streak > 0)
    final isAppUpdated = (lastCompletedVersion == null && currentStreak > 0) ||
        (lastCompletedVersion != null && lastCompletedVersion != AppVersion.version);

    if (isAppUpdated) {
      newStreak = currentStreak > 0 ? currentStreak + 1 : 1;
      debugPrint('ChallengeService: App updated from $lastCompletedVersion to ${AppVersion.version}. Continuing streak: $newStreak');
    } else if (lastCompletionStr != null && lastCompletionStr.isNotEmpty) {
      final lastCompletion = DateTime.tryParse(lastCompletionStr);
      if (lastCompletion != null) {
        final lastDate = DateTime(
            lastCompletion.year, lastCompletion.month, lastCompletion.day);
        final daysDiff = today.difference(lastDate).inDays;

        if (daysDiff == 1) {
          // Consecutive day
          newStreak = currentStreak + 1;
        } else if (daysDiff > 1) {
          // Streak broken, reset
          newStreak = 1;
        } else {
          // Same day, don't update streak
          newStreak = currentStreak;
        }
      } else {
        // Parse error, fallback to preserving streak
        newStreak = currentStreak > 0 ? currentStreak + 1 : 1;
      }
    } else {
      // First completion, or lastCompletionStr is null/missing
      // If we already have a streak restored/saved, don't reset it to 1!
      // Instead, assume this completes/continues the streak.
      newStreak = currentStreak > 0 ? currentStreak + 1 : 1;
    }

    await prefs.setInt(streakKey, newStreak);
    await prefs.setString(lastCompletionKey, now.toIso8601String());
    await prefs.setString(lastVersionKey, AppVersion.version);

    // Backup ke secure storage
    await _secureStorage.writeSecureData(
        '$_secureStreakPrefix$userId', newStreak.toString());
    await _secureStorage.writeSecureData(
        '$_secureLastCompletionPrefix$userId', now.toIso8601String());
    await _secureStorage.writeSecureData(
        'secure_last_completed_version_$userId', AppVersion.version);

    _notifyListeners();
  }

  Future<void> _addPoints(int points) async {
    final prefs = await _getPrefs();
    final userId = await _getCurrentUserId();
    final pointsKey = '$_pointsKey$userId';

    // Pulihkan dulu jika SharedPreferences kosong
    await _restoreFromSecureStorageIfNeeded(prefs, userId);

    final currentPoints = prefs.getInt(pointsKey) ?? 0;
    final newPoints = currentPoints + points;
    await prefs.setInt(pointsKey, newPoints);

    // Backup ke secure storage
    await _secureStorage.writeSecureData(
        '$_securePointsPrefix$userId', newPoints.toString());

    _notifyListeners();
  }

  @override
  Future<int> getCurrentStreak() async {
    final prefs = await _getPrefs();
    final userId = await _getCurrentUserId();

    // Pulihkan dulu jika SharedPreferences kosong
    await _restoreFromSecureStorageIfNeeded(prefs, userId);

    final streakKey = '$_streakKey$userId';
    final lastCompletionKey = '$_lastCompletionKey$userId';

    final currentStreak = prefs.getInt(streakKey) ?? 0;
    final lastCompletionStr = prefs.getString(lastCompletionKey);

    if (currentStreak > 0 && lastCompletionStr != null && lastCompletionStr.isNotEmpty) {
      final lastCompletion = DateTime.tryParse(lastCompletionStr);
      if (lastCompletion != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final lastDate = DateTime(
            lastCompletion.year, lastCompletion.month, lastCompletion.day);
        final daysDiff = today.difference(lastDate).inDays;

        if (daysDiff > 1) {
          // Streak is broken, return 0 dynamically
          return 0;
        }
      }
    }

    return currentStreak;
  }

  @override
  Future<int> getTotalPoints() async {
    final prefs = await _getPrefs();
    final userId = await _getCurrentUserId();

    // Pulihkan dulu jika SharedPreferences kosong
    await _restoreFromSecureStorageIfNeeded(prefs, userId);

    final pointsKey = '$_pointsKey$userId';
    return prefs.getInt(pointsKey) ?? 0;
  }

  @override
  Stream<List<ChallengeModel>> watchActiveChallenges() {
    return _streamController.stream;
  }

  @override
  List<ChallengeTemplateModel> getAllTemplates() {
    return ChallengeTemplates.getAllTemplates();
  }

  @override
  ChallengeTemplateModel? getTemplateById(String id) {
    return ChallengeTemplates.getTemplateById(id);
  }
}
