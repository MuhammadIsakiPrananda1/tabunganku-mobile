enum GoldTransactionType { buy, sell }

class GoldTransactionModel {
  final String id;
  final double grams;
  final double pricePerGram;
  final DateTime date;
  final GoldTransactionType type;
  final String? note;

  GoldTransactionModel({
    required this.id,
    required this.grams,
    required this.pricePerGram,
    required this.date,
    required this.type,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grams': grams,
      'pricePerGram': pricePerGram,
      'date': date.toIso8601String(),
      'type': type.name,
      'note': note,
    };
  }

  factory GoldTransactionModel.fromJson(Map<String, dynamic> json) {
    return GoldTransactionModel(
      id: json['id'] as String,
      grams: (json['grams'] as num).toDouble(),
      pricePerGram: (json['pricePerGram'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      type: GoldTransactionType.values.byName(json['type'] as String),
      note: json['note'] as String?,
    );
  }

  GoldTransactionModel copyWith({
    String? id,
    double? grams,
    double? pricePerGram,
    DateTime? date,
    GoldTransactionType? type,
    String? note,
  }) {
    return GoldTransactionModel(
      id: id ?? this.id,
      grams: grams ?? this.grams,
      pricePerGram: pricePerGram ?? this.pricePerGram,
      date: date ?? this.date,
      type: type ?? this.type,
      note: note ?? this.note,
    );
  }
}
