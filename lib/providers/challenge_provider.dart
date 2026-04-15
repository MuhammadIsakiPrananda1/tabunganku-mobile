import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/challenge_model.dart';
import 'package:tabunganku/models/challenge_template_model.dart';
import 'package:tabunganku/models/badge_model.dart';
import 'package:tabunganku/services/challenge_service.dart';
import 'package:tabunganku/services/badge_service.dart';
import 'package:tabunganku/providers/notification_provider.dart';

// ==================== SERVICE PROVIDERS ====================

final challengeServiceProvider = Provider<ChallengeService>((ref) {
  return MockChallengeService();
});

final badgeServiceProvider = Provider<BadgeService>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return MockBadgeService(notificationService);
});

// ==================== CHALLENGE PROVIDERS ====================

// Provider untuk mendapatkan semua challenges
final challengesProvider = FutureProvider.autoDispose<List<ChallengeModel>>((ref) async {
  final service = ref.watch(challengeServiceProvider);
  return service.getChallenges();
});

// Provider untuk active challenges
final activeChallengesProvider = FutureProvider.autoDispose<List<ChallengeModel>>((ref) async {
  final service = ref.watch(challengeServiceProvider);
  return service.getActiveChallenges();
});

// Provider untuk completed challenges
final completedChallengesProvider = FutureProvider.autoDispose<List<ChallengeModel>>((ref) async {
  final service = ref.watch(challengeServiceProvider);
  return service.getCompletedChallenges();
});

// Stream provider untuk active challenges (real-time)
final activeChallengesStreamProvider = StreamProvider.autoDispose<List<ChallengeModel>>((ref) {
  final service = ref.watch(challengeServiceProvider);
  return service.watchActiveChallenges();
});

// Provider untuk challenge tertentu
final challengeProvider = FutureProvider.autoDispose.family<ChallengeModel, String>((ref, id) async {
  final service = ref.watch(challengeServiceProvider);
  return service.getChallenge(id);
});

// ==================== TEMPLATE PROVIDERS ====================

// Provider untuk semua challenge templates
final challengeTemplatesProvider = Provider<List<ChallengeTemplateModel>>((ref) {
  final service = ref.watch(challengeServiceProvider);
  return service.getAllTemplates();
});

// Provider untuk template berdasarkan type
final templatesByTypeProvider = Provider.family<List<ChallengeTemplateModel>, ChallengeType>(
  (ref, type) {
    final allTemplates = ref.watch(challengeTemplatesProvider);
    return allTemplates.where((t) => t.type == type).toList();
  },
);

// Provider untuk template berdasarkan difficulty
final templatesByDifficultyProvider = Provider.family<List<ChallengeTemplateModel>, ChallengeDifficulty>(
  (ref, difficulty) {
    final allTemplates = ref.watch(challengeTemplatesProvider);
    return allTemplates.where((t) => t.difficulty == difficulty).toList();
  },
);

// Provider untuk template tertentu
final templateProvider = Provider.family<ChallengeTemplateModel?, String>((ref, id) {
  final service = ref.watch(challengeServiceProvider);
  return service.getTemplateById(id);
});

// ==================== GAMIFICATION PROVIDERS ====================

// Provider untuk current streak
final currentStreakProvider = FutureProvider.autoDispose<int>((ref) async {
  final service = ref.watch(challengeServiceProvider);
  return service.getCurrentStreak();
});

// Provider untuk total points
final totalPointsProvider = FutureProvider.autoDispose<int>((ref) async {
  final service = ref.watch(challengeServiceProvider);
  return service.getTotalPoints();
});

// ==================== BADGE PROVIDERS ====================

// Provider untuk semua badges
final allBadgesProvider = FutureProvider.autoDispose<List<BadgeModel>>((ref) async {
  final service = ref.watch(badgeServiceProvider);
  return service.getAllBadges();
});

// Provider untuk earned badges
final earnedBadgesProvider = FutureProvider.autoDispose<List<BadgeModel>>((ref) async {
  final service = ref.watch(badgeServiceProvider);
  return service.getEarnedBadges();
});

// Provider untuk available badges (not earned yet)
final availableBadgesProvider = FutureProvider.autoDispose<List<BadgeModel>>((ref) async {
  final service = ref.watch(badgeServiceProvider);
  return service.getAvailableBadges();
});

// Provider untuk badge berdasarkan category
final badgesByCategoryProvider = Provider.autoDispose.family<List<BadgeModel>, BadgeCategory>(
  (ref, category) {
    final badgesAsync = ref.watch(allBadgesProvider);
    return badgesAsync.maybeWhen(
      data: (badges) => badges.where((b) => b.category == category).toList(),
      orElse: () => <BadgeModel>[],
    );
  },
);

// Provider untuk badge tertentu
final badgeProvider = FutureProvider.autoDispose.family<BadgeModel?, String>((ref, id) async {
  final service = ref.watch(badgeServiceProvider);
  return service.getBadgeById(id);
});

// ==================== STATISTICS PROVIDERS ====================

// Provider untuk challenge statistics
final challengeStatsProvider = Provider.autoDispose((ref) {
  final challengesAsync = ref.watch(challengesProvider);
  
  return challengesAsync.maybeWhen(
    data: (challenges) {
      final total = challenges.length;
      final completed = challenges.where((c) => c.status == ChallengeStatus.completed).length;
      final active = challenges.where((c) => c.status == ChallengeStatus.active).length;
      final failed = challenges.where((c) => c.status == ChallengeStatus.failed).length;
      final completionRate = total > 0 ? (completed / total * 100).toStringAsFixed(1) : '0.0';
      
      return {
        'total': total,
        'completed': completed,
        'active': active,
        'failed': failed,
        'completionRate': completionRate,
      };
    },
    orElse: () => {
      'total': 0,
      'completed': 0,
      'active': 0,
      'failed': 0,
      'completionRate': '0.0',
    },
  );
});

// Provider untuk badge statistics
final badgeStatsProvider = Provider.autoDispose((ref) {
  final badgesAsync = ref.watch(allBadgesProvider);
  
  return badgesAsync.maybeWhen(
    data: (badges) {
      final total = badges.length;
      final earned = badges.where((b) => b.isEarned).length;
      final percentage = total > 0 ? (earned / total * 100).toStringAsFixed(1) : '0.0';
      
      return {
        'total': total,
        'earned': earned,
        'remaining': total - earned,
        'percentage': percentage,
      };
    },
    orElse: () => {
      'total': 0,
      'earned': 0,
      'remaining': 0,
      'percentage': '0.0',
    },
  );
});
