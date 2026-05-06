import 'dart:convert';

class ArisanModel {
  final String id;
  final String name;
  final double contributionAmount;
  final String period; // 'Weekly', 'Monthly'
  final DateTime startDate;
  final List<ArisanMemberModel> members;
  final bool isCompleted;

  ArisanModel({
    required this.id,
    required this.name,
    required this.contributionAmount,
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
      'period': period,
      'startDate': startDate.toIso8601String(),
      'members': members.map((m) => m.toJson()).toList(),
      'isCompleted': isCompleted,
    };
  }

  factory ArisanModel.fromJson(Map<String, dynamic> json) {
    return ArisanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      contributionAmount: (json['contributionAmount'] as num).toDouble(),
      period: json['period'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      members: (json['members'] as List).map((m) => ArisanMemberModel.fromJson(m)).toList(),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  ArisanModel copyWith({
    String? name,
    double? contributionAmount,
    String? period,
    DateTime? startDate,
    List<ArisanMemberModel>? members,
    bool? isCompleted,
  }) {
    return ArisanModel(
      id: id,
      name: name ?? this.name,
      contributionAmount: contributionAmount ?? this.contributionAmount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      members: members ?? this.members,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ArisanMemberModel {
  final String id;
  final String name;
  final bool hasWon;
  final List<DateTime> paymentDates;

  ArisanMemberModel({
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

  factory ArisanMemberModel.fromJson(Map<String, dynamic> json) {
    return ArisanMemberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      hasWon: json['hasWon'] as bool? ?? false,
      paymentDates: (json['paymentDates'] as List).map((d) => DateTime.parse(d)).toList(),
    );
  }

  ArisanMemberModel copyWith({
    String? name,
    bool? hasWon,
    List<DateTime>? paymentDates,
  }) {
    return ArisanMemberModel(
      id: id,
      name: name ?? this.name,
      hasWon: hasWon ?? this.hasWon,
      paymentDates: paymentDates ?? this.paymentDates,
    );
  }
}
