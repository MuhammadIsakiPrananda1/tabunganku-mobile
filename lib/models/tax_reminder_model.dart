
class TaxReminderModel {
  final String id;
  final String title;
  final DateTime dueDate;
  final String status;
  final int iconCodePoint;
  final int colorValue;
  final double amount;

  TaxReminderModel({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.status,
    required this.iconCodePoint,
    required this.colorValue,
    required this.amount,
  });

  TaxReminderModel copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    String? status,
    int? iconCodePoint,
    int? colorValue,
    double? amount,
  }) {
    return TaxReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'amount': amount,
    };
  }

  factory TaxReminderModel.fromJson(Map<String, dynamic> json) {
    return TaxReminderModel(
      id: json['id'] as String,
      title: json['title'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: json['status'] as String,
      iconCodePoint: json['iconCodePoint'] as int,
      colorValue: json['colorValue'] as int,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
