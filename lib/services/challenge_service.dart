import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
  Future<void> updateStreakOnIncome();
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

  static int _updateCounter = 0;
  static final StreamController<int> _updateController =
      StreamController<int>.broadcast();
  static Stream<int> get updateStream => _updateController.stream;

  static void _logToFile(String message) {
    try {
      final file = File('c:/Users/Neverland Studio/Documents/Folder Semua Aplikasi/Aplikasi TabunganKu/debug_log.txt');
      file.writeAsStringSync('${DateTime.now().toIso8601String()}: $message\n', mode: FileMode.append);
    } catch (e) {
      debugPrint('Failed to log to file: $e');
    }
  }

  void _notifyListeners() {
    _updateCounter++;
    _updateController.add(_updateCounter);
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
    try {
      final userId = await _secureStorage.getUserId();
      return (userId == null || userId.isEmpty) ? 'guest' : userId;
    } catch (e) {
      _logToFile('_getCurrentUserId ERROR: $e');
      return 'guest';
    }
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
    await _evaluateExpiredChallenges(userId);
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
    final userId = await _getCurrentUserId();
    final allChallenges = _userChallenges[userId] ?? [];
    debugPrint('ChallengeService debug: userId=$userId, total challenges in memory=${allChallenges.length}');
    for (var c in allChallenges) {
      debugPrint('ChallengeService debug: challenge title="${c.title}" status=${c.status.toString()} endDate=${c.endDate}');
    }

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
    _logToFile('_restoreFromSecureStorageIfNeeded() called');
    try {
      final streakKey = '$_streakKey$userId';
      final pointsKey = '$_pointsKey$userId';
      final lastCompletionKey = '$_lastCompletionKey$userId';

      final prefStreak = prefs.getInt(streakKey);
      final prefPoints = prefs.getInt(pointsKey);
      final prefLastCompletion = prefs.getString(lastCompletionKey);
      _logToFile('_restoreFromSecureStorageIfNeeded: prefStreak=$prefStreak, prefPoints=$prefPoints, prefLastCompletion=$prefLastCompletion');

      // Pulihkan streak jika null atau 0
      if (prefStreak == null || prefStreak == 0) {
        try {
          final secStreak =
              await _secureStorage.readSecureData('$_secureStreakPrefix$userId');
          _logToFile('_restoreFromSecureStorageIfNeeded: secStreak=$secStreak');
          if (secStreak != null) {
            final val = int.tryParse(secStreak) ?? 0;
            if (val > 0) {
              await prefs.setInt(streakKey, val);
              debugPrint('ChallengeService: Restored streak from secure storage: $val');
              _logToFile('_restoreFromSecureStorageIfNeeded: Restored streak: $val');
            }
          }
        } catch (secErr) {
          _logToFile('_restoreFromSecureStorageIfNeeded: secure storage read streak error: $secErr');
        }
      }

      // Pulihkan points jika null atau 0
      if (prefPoints == null || prefPoints == 0) {
        try {
          final secPoints =
              await _secureStorage.readSecureData('$_securePointsPrefix$userId');
          _logToFile('_restoreFromSecureStorageIfNeeded: secPoints=$secPoints');
          if (secPoints != null) {
            final val = int.tryParse(secPoints) ?? 0;
            if (val > 0) {
              await prefs.setInt(pointsKey, val);
              debugPrint('ChallengeService: Restored points from secure storage: $val');
              _logToFile('_restoreFromSecureStorageIfNeeded: Restored points: $val');
            }
          }
        } catch (secErr) {
          _logToFile('_restoreFromSecureStorageIfNeeded: secure storage read points error: $secErr');
        }
      }

      // Pulihkan last completion jika null atau kosong
      if (prefLastCompletion == null || prefLastCompletion.isEmpty) {
        try {
          final secLastCompletion = await _secureStorage
              .readSecureData('$_secureLastCompletionPrefix$userId');
          _logToFile('_restoreFromSecureStorageIfNeeded: secLastCompletion=$secLastCompletion');
          if (secLastCompletion != null && secLastCompletion.isNotEmpty) {
            await prefs.setString(lastCompletionKey, secLastCompletion);
            debugPrint('ChallengeService: Restored last completion from secure storage: $secLastCompletion');
            _logToFile('_restoreFromSecureStorageIfNeeded: Restored last completion: $secLastCompletion');
          }
        } catch (secErr) {
          _logToFile('_restoreFromSecureStorageIfNeeded: secure storage read last completion error: $secErr');
        }
      }

      final lastVersionKey = 'challenge_last_version_$userId';
      final prefLastVersion = prefs.getString(lastVersionKey);

      // Pulihkan last completed version jika null atau kosong
      if (prefLastVersion == null || prefLastVersion.isEmpty) {
        try {
          final secLastVersion = await _secureStorage
              .readSecureData('secure_last_completed_version_$userId');
          _logToFile('_restoreFromSecureStorageIfNeeded: secLastVersion=$secLastVersion');
          if (secLastVersion != null && secLastVersion.isNotEmpty) {
            await prefs.setString(lastVersionKey, secLastVersion);
            debugPrint('ChallengeService: Restored last completed version from secure storage: $secLastVersion');
            _logToFile('_restoreFromSecureStorageIfNeeded: Restored last completed version: $secLastVersion');
          }
        } catch (secErr) {
          _logToFile('_restoreFromSecureStorageIfNeeded: secure storage read last completed version error: $secErr');
        }
      }
    } catch (e, stack) {
      _logToFile('_restoreFromSecureStorageIfNeeded ERROR: $e\n$stack');
    }
  }

  static bool _isEvaluating = false;

  Future<void> _evaluateExpiredChallenges(String userId) async {
    if (_isEvaluating) return;
    _isEvaluating = true;
    _logToFile('_evaluateExpiredChallenges() called for userId=$userId');
    try {
      final challenges = _userChallenges[userId];
      if (challenges == null || challenges.isEmpty) {
        _logToFile('_evaluateExpiredChallenges: no challenges found');
        return;
      }

      final now = DateTime.now();
      bool updated = false;
      int streakIncrementCount = 0;
      int pointsEarned = 0;

      final List<ChallengeModel> updatedList = [];

      for (final challenge in challenges) {
        _logToFile('_evaluateExpiredChallenges: challenge title="${challenge.title}" status=${challenge.status} endDate=${challenge.endDate}');
        if (challenge.status == ChallengeStatus.active && now.isAfter(challenge.endDate)) {
          ChallengeStatus newStatus = ChallengeStatus.failed;
          DateTime? completedDate;

          switch (challenge.targetType) {
            case ChallengeTargetType.zeroExpense:
            case ChallengeTargetType.noTransactionType:
              // Passive challenges succeed if no violation happened
              newStatus = ChallengeStatus.completed;
              completedDate = challenge.endDate;
              break;
            case ChallengeTargetType.limitExpense:
            case ChallengeTargetType.categoryLimit:
              // Succeeds if currentProgress has not exceeded the limit
              if (challenge.targetAmount != null && challenge.currentProgress <= challenge.targetAmount!) {
                newStatus = ChallengeStatus.completed;
                completedDate = challenge.endDate;
              } else {
                newStatus = ChallengeStatus.failed;
              }
              break;
            case ChallengeTargetType.saveAmount:
              // Succeeds if currentProgress reached target
              if (challenge.targetAmount != null && challenge.currentProgress >= challenge.targetAmount!) {
                newStatus = ChallengeStatus.completed;
                completedDate = challenge.endDate;
              } else {
                newStatus = ChallengeStatus.failed;
              }
              break;
            case ChallengeTargetType.custom:
              // Custom challenges: check if they met the target amount (if any) or assume success
              if (challenge.targetAmount == null || challenge.currentProgress >= challenge.targetAmount!) {
                newStatus = ChallengeStatus.completed;
                completedDate = challenge.endDate;
              } else {
                newStatus = ChallengeStatus.failed;
              }
              break;
          }

          _logToFile('_evaluateExpiredChallenges: challenge "${challenge.title}" evaluated as $newStatus');
          final updatedChallenge = challenge.copyWith(
            status: newStatus,
            completedDate: completedDate,
          );
          updatedList.add(updatedChallenge);
          updated = true;

          if (newStatus == ChallengeStatus.completed) {
            streakIncrementCount++;
            pointsEarned += challenge.points;
          }
        } else {
          updatedList.add(challenge);
        }
      }

      if (updated) {
        _userChallenges[userId] = updatedList;
        await _saveUserChallenges(userId);
        _logToFile('_evaluateExpiredChallenges: saved updated challenges. pointsEarned=$pointsEarned, streakIncrementCount=$streakIncrementCount');

        if (pointsEarned > 0) {
          await _addPoints(pointsEarned);
        }
        if (streakIncrementCount > 0) {
          await _updateStreakOnCompletion();
        }

        final prefs = await _getPrefs();
        final streakKey = '$_streakKey$userId';
        final pointsKey = '$_pointsKey$userId';
        final currentStreakVal = prefs.getInt(streakKey) ?? 0;
        final currentPointsVal = prefs.getInt(pointsKey) ?? 0;

        if (badgeService != null) {
          await badgeService!.checkAndUnlockBadges(currentPointsVal, currentStreakVal);
          for (final challenge in updatedList) {
            if (challenge.status == ChallengeStatus.completed && challenge.badgeId != null) {
              await badgeService!.unlockChallengeBadge(challenge.badgeId!);
            }
          }
        }

        await _emitChallenges(userId);
      }
    } catch (e, stack) {
      _logToFile('_evaluateExpiredChallenges ERROR: $e\n$stack');
      debugPrint('ChallengeService: Error in _evaluateExpiredChallenges: $e');
    } finally {
      _isEvaluating = false;
    }
  }

  @override
  Future<void> updateStreakOnIncome() async {
    _logToFile('updateStreakOnIncome() called');
    try {
      final prefs = await _getPrefs();
      final userId = await _getCurrentUserId();
      final streakKey = '$_streakKey$userId';
      final lastCompletionKey = '$_lastCompletionKey$userId';
      final lastVersionKey = 'challenge_last_version_$userId';

      // Pulihkan dulu jika SharedPreferences kosong atau parsial
      await _restoreFromSecureStorageIfNeeded(prefs, userId);

      final currentStreak = prefs.getInt(streakKey) ?? 0;
      final lastCompletionStr = prefs.getString(lastCompletionKey);
      _logToFile('updateStreakOnIncome: currentStreak=$currentStreak, lastCompletionStr=$lastCompletionStr');

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      int newStreak;
      if (lastCompletionStr != null && lastCompletionStr.isNotEmpty) {
        final lastCompletion = DateTime.tryParse(lastCompletionStr);
        if (lastCompletion != null) {
          final lastDate = DateTime(
              lastCompletion.year, lastCompletion.month, lastCompletion.day);
          final daysDiff = today.difference(lastDate).inDays;
          _logToFile('updateStreakOnIncome: daysDiff=$daysDiff');

          if (daysDiff == 1) {
            newStreak = currentStreak + 1;
          } else if (daysDiff > 1) {
            newStreak = 1;
          } else {
            // Same day, keep current streak (or set to 1 if it was 0)
            newStreak = currentStreak > 0 ? currentStreak : 1;
          }
        } else {
          newStreak = currentStreak > 0 ? currentStreak + 1 : 1;
        }
      } else {
        newStreak = currentStreak > 0 ? currentStreak + 1 : 1;
      }
      _logToFile('updateStreakOnIncome: newStreak=$newStreak');

      await prefs.setInt(streakKey, newStreak);
      await prefs.setString(lastCompletionKey, now.toIso8601String());
      await prefs.setString(lastVersionKey, AppVersion.version);

      // Backup ke secure storage
      try {
        await _secureStorage.writeSecureData(
            '$_secureStreakPrefix$userId', newStreak.toString());
        await _secureStorage.writeSecureData(
            '$_secureLastCompletionPrefix$userId', now.toIso8601String());
        await _secureStorage.writeSecureData(
            'secure_last_completed_version_$userId', AppVersion.version);
        _logToFile('updateStreakOnIncome: secure storage write success');
      } catch (secError) {
        _logToFile('updateStreakOnIncome: secure storage write failed: $secError');
      }

      _notifyListeners();
    } catch (e, stack) {
      _logToFile('updateStreakOnIncome ERROR: $e\n$stack');
      rethrow;
    }
  }

  Future<void> _updateStreakOnCompletion() async {
    _logToFile('_updateStreakOnCompletion() called');
    try {
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
      _logToFile('_updateStreakOnCompletion: currentStreak=$currentStreak, lastCompletionStr=$lastCompletionStr, lastCompletedVersion=$lastCompletedVersion');

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      int newStreak;
      // Deteksi jika aplikasi baru di-update (versi berbeda, atau versi null tapi streak > 0)
      final isAppUpdated = (lastCompletedVersion == null && currentStreak > 0) ||
          (lastCompletedVersion != null && lastCompletedVersion != AppVersion.version);
      _logToFile('_updateStreakOnCompletion: isAppUpdated=$isAppUpdated');

      if (isAppUpdated) {
        newStreak = currentStreak > 0 ? currentStreak + 1 : 1;
        debugPrint('ChallengeService: App updated from $lastCompletedVersion to ${AppVersion.version}. Continuing streak: $newStreak');
      } else if (lastCompletionStr != null && lastCompletionStr.isNotEmpty) {
        final lastCompletion = DateTime.tryParse(lastCompletionStr);
        if (lastCompletion != null) {
          final lastDate = DateTime(
              lastCompletion.year, lastCompletion.month, lastCompletion.day);
          final daysDiff = today.difference(lastDate).inDays;
          _logToFile('_updateStreakOnCompletion: daysDiff=$daysDiff');

          if (daysDiff == 1) {
            newStreak = currentStreak + 1;
          } else if (daysDiff > 1) {
            newStreak = 1;
          } else {
            newStreak = currentStreak;
          }
        } else {
          newStreak = currentStreak > 0 ? currentStreak + 1 : 1;
        }
      } else {
        newStreak = currentStreak > 0 ? currentStreak + 1 : 1;
      }
      _logToFile('_updateStreakOnCompletion: newStreak=$newStreak');

      await prefs.setInt(streakKey, newStreak);
      await prefs.setString(lastCompletionKey, now.toIso8601String());
      await prefs.setString(lastVersionKey, AppVersion.version);

      // Backup ke secure storage
      try {
        await _secureStorage.writeSecureData(
            '$_secureStreakPrefix$userId', newStreak.toString());
        await _secureStorage.writeSecureData(
            '$_secureLastCompletionPrefix$userId', now.toIso8601String());
        await _secureStorage.writeSecureData(
            'secure_last_completed_version_$userId', AppVersion.version);
        _logToFile('_updateStreakOnCompletion: secure storage write success');
      } catch (secError) {
        _logToFile('_updateStreakOnCompletion: secure storage write failed: $secError');
      }

      _notifyListeners();
    } catch (e, stack) {
      _logToFile('_updateStreakOnCompletion ERROR: $e\n$stack');
      rethrow;
    }
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
    _logToFile('getCurrentStreak() called');
    try {
      final prefs = await _getPrefs();
      final userId = await _getCurrentUserId();
      _logToFile('getCurrentStreak: userId=$userId');

      // Pulihkan dulu jika SharedPreferences kosong
      await _restoreFromSecureStorageIfNeeded(prefs, userId);
      await _ensureUserLoaded(userId);
      await _evaluateExpiredChallenges(userId);

      final streakKey = '$_streakKey$userId';
      final lastCompletionKey = '$_lastCompletionKey$userId';

      final currentStreak = prefs.getInt(streakKey) ?? 0;
      final lastCompletionStr = prefs.getString(lastCompletionKey);
      _logToFile('getCurrentStreak: currentStreak=$currentStreak, lastCompletionStr=$lastCompletionStr');

      if (currentStreak > 0 && lastCompletionStr != null && lastCompletionStr.isNotEmpty) {
        final lastCompletion = DateTime.tryParse(lastCompletionStr);
        if (lastCompletion != null) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final lastDate = DateTime(
              lastCompletion.year, lastCompletion.month, lastCompletion.day);
          final daysDiff = today.difference(lastDate).inDays;
          _logToFile('getCurrentStreak: daysDiff=$daysDiff');

          if (daysDiff > 1) {
            _logToFile('getCurrentStreak: Streak is broken, returning 0 dynamically');
            return 0;
          }
        }
      }

      _logToFile('getCurrentStreak: returning $currentStreak');
      return currentStreak;
    } catch (e, stack) {
      _logToFile('getCurrentStreak ERROR: $e\n$stack');
      rethrow;
    }
  }

  @override
  Future<int> getTotalPoints() async {
    _logToFile('getTotalPoints() called');
    try {
      final prefs = await _getPrefs();
      final userId = await _getCurrentUserId();
      _logToFile('getTotalPoints: userId=$userId');

      // Pulihkan dulu jika SharedPreferences kosong
      await _restoreFromSecureStorageIfNeeded(prefs, userId);
      await _ensureUserLoaded(userId);
      await _evaluateExpiredChallenges(userId);

      final pointsKey = '$_pointsKey$userId';
      final points = prefs.getInt(pointsKey) ?? 0;
      _logToFile('getTotalPoints: returning $points');
      return points;
    } catch (e, stack) {
      _logToFile('getTotalPoints ERROR: $e\n$stack');
      rethrow;
    }
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
