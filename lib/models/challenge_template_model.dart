import 'package:flutter/material.dart';
import 'challenge_model.dart';

class ChallengeTemplateModel {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeDifficulty difficulty;
  final int defaultDurationDays;
  final ChallengeTargetType targetType;
  final double? suggestedTargetAmount;
  final String? targetCategory;
  final List<String> tips;
  final IconData? icon;
  final int points;

  ChallengeTemplateModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.defaultDurationDays,
    required this.targetType,
    this.suggestedTargetAmount,
    this.targetCategory,
    this.tips = const [],
    this.icon,
    required this.points,
  });

  factory ChallengeTemplateModel.fromJson(Map<String, dynamic> json) {
    return ChallengeTemplateModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: ChallengeType.values[json['type'] as int],
      difficulty: ChallengeDifficulty.values[json['difficulty'] as int],
      defaultDurationDays: json['defaultDurationDays'] as int,
      targetType: ChallengeTargetType.values[json['targetType'] as int],
      suggestedTargetAmount: json['suggestedTargetAmount'] != null 
          ? (json['suggestedTargetAmount'] as num).toDouble() 
          : null,
      targetCategory: json['targetCategory'] as String?,
      tips: (json['tips'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      icon: _resolveIcon(json['iconCodePoint'] as int?),
      points: json['points'] as int,
    );
  }

  static IconData? _resolveIcon(int? codePoint) {
    if (codePoint == null) return null;
    if (codePoint == Icons.no_meals_rounded.codePoint) return Icons.no_meals_rounded;
    if (codePoint == Icons.savings_rounded.codePoint) return Icons.savings_rounded;
    if (codePoint == Icons.lock_outline_rounded.codePoint) return Icons.lock_outline_rounded;
    if (codePoint == Icons.coffee_rounded.codePoint) return Icons.coffee_rounded;
    if (codePoint == Icons.directions_walk_rounded.codePoint) return Icons.directions_walk_rounded;
    if (codePoint == Icons.fastfood_rounded.codePoint) return Icons.fastfood_rounded;
    if (codePoint == Icons.shopping_cart_rounded.codePoint) return Icons.shopping_cart_rounded;
    if (codePoint == Icons.receipt_long_rounded.codePoint) return Icons.receipt_long_rounded;
    if (codePoint == Icons.electric_bolt_rounded.codePoint) return Icons.electric_bolt_rounded;
    if (codePoint == Icons.emoji_events_rounded.codePoint) return Icons.emoji_events_rounded;
    return Icons.emoji_events_rounded;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'difficulty': difficulty.index,
      'defaultDurationDays': defaultDurationDays,
      'targetType': targetType.index,
      'suggestedTargetAmount': suggestedTargetAmount,
      'targetCategory': targetCategory,
      'tips': tips,
      'iconCodePoint': icon?.codePoint,
      'points': points,
    };
  }

ChallengeModel toChallenge({
    String? customTitle,
    double? customTargetAmount,
    int? customDuration,
    bool isGroupChallenge = false,
    String? groupId,
  }) {
    final now = DateTime.now();
    final duration = customDuration ?? defaultDurationDays;
    
    return ChallengeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: customTitle ?? title,
      description: description,
      type: type,
      difficulty: difficulty,
      durationDays: duration,
      targetType: targetType,
      targetAmount: customTargetAmount ?? suggestedTargetAmount,
      targetCategory: targetCategory,
      startDate: now,
      endDate: now.add(Duration(days: duration)),
      currentProgress: 0.0,
      status: ChallengeStatus.active,
      points: points,
      isGroupChallenge: isGroupChallenge,
      groupId: groupId,
      badgeId: id,
    );
  }

  String get difficultyLabel {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return 'Mudah';
      case ChallengeDifficulty.medium:
        return 'Sedang';
      case ChallengeDifficulty.hard:
        return 'Sulit';
    }
  }

  String get typeLabel {
    switch (type) {
      case ChallengeType.daily:
        return 'Harian';
      case ChallengeType.weekly:
        return 'Mingguan';
      case ChallengeType.monthly:
        return 'Bulanan';
    }
  }
}
