/// Model: SavingTargetModel
//
// Merepresentasikan target tabungan dengan deadline.
/// Mendukung serialisasi JSON untuk penyimpanan di [SharedPreferences].
library;

class SavingTargetModel {
  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime dueDate;
  final DateTime createdAt;
  final String category;

  SavingTargetModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0.0,
    required this.dueDate,
    required this.createdAt,
    this.category = 'Umum',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'category': category,
    };
  }

  factory SavingTargetModel.fromJson(Map<String, dynamic> json) {
    return SavingTargetModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0.0,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      category: json['category'] as String? ?? 'Umum',
    );
  }

  SavingTargetModel copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    DateTime? dueDate,
    DateTime? createdAt,
    String? category,
  }) {
    return SavingTargetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }
}
