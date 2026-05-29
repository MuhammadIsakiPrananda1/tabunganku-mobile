import 'dart:convert';

class NabungBersamaModel {
  final String id;
  final String name;
  final double contributionAmount;
  final double targetAmount;
  final String period; // 'Weekly', 'Monthly'
  final DateTime startDate;
  final List<NabungBersamaMemberModel> members;
  final bool isCompleted;

  NabungBersamaModel({
    required this.id,
    required this.name,
    required this.contributionAmount,
    required this.targetAmount,
    required this.period,
    required this.startDate,
    required this.members,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contributionAmount': contributionAmount,
      'targetAmount': targetAmount,
      'period': period,
      'startDate': startDate.toIso8601String(),
      'members': members.map((m) => m.toJson()).toList(),
      'isCompleted': isCompleted,
    };
  }

  factory NabungBersamaModel.fromJson(Map<String, dynamic> json) {
    return NabungBersamaModel(
      id: json['id'] as String,
      name: json['name'] as String,
      contributionAmount: (json['contributionAmount'] as num).toDouble(),
      targetAmount: (json['targetAmount'] as num? ?? 0.0).toDouble(),
      period: json['period'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      members: (json['members'] as List).map((m) => NabungBersamaMemberModel.fromJson(m)).toList(),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  NabungBersamaModel copyWith({
    String? name,
    double? contributionAmount,
    double? targetAmount,
    String? period,
    DateTime? startDate,
    List<NabungBersamaMemberModel>? members,
    bool? isCompleted,
  }) {
    return NabungBersamaModel(
      id: id,
      name: name ?? this.name,
      contributionAmount: contributionAmount ?? this.contributionAmount,
      targetAmount: targetAmount ?? this.targetAmount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      members: members ?? this.members,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class NabungBersamaMemberModel {
  final String id;
  final String name;
  final bool hasWon;
  final List<DateTime> paymentDates;

  NabungBersamaMemberModel({
    required this.id,
    required this.name,
    this.hasWon = false,
    required this.paymentDates,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hasWon': hasWon,
      'paymentDates': paymentDates.map((d) => d.toIso8601String()).toList(),
    };
  }

  factory NabungBersamaMemberModel.fromJson(Map<String, dynamic> json) {
    return NabungBersamaMemberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      hasWon: json['hasWon'] as bool? ?? false,
      paymentDates: (json['paymentDates'] as List).map((d) => DateTime.parse(d)).toList(),
    );
  }

  NabungBersamaMemberModel copyWith({
    String? name,
    bool? hasWon,
    List<DateTime>? paymentDates,
  }) {
    return NabungBersamaMemberModel(
      id: id,
      name: name ?? this.name,
      hasWon: hasWon ?? this.hasWon,
      paymentDates: paymentDates ?? this.paymentDates,
    );
  }
}

