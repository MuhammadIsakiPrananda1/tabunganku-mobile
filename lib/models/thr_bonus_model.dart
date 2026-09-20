import 'dart:convert';
import 'package:flutter/material.dart';

class ThrRecipientItem {
  final String id;
  final String name;
  final double amount;
  final bool isGiven;

  ThrRecipientItem({
    required this.id,
    required this.name,
    required this.amount,
    this.isGiven = false,
  });

  ThrRecipientItem copyWith({
    String? id,
    String? name,
    double? amount,
    bool? isGiven,
  }) {
    return ThrRecipientItem(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      isGiven: isGiven ?? this.isGiven,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'isGiven': isGiven,
    };
  }

  factory ThrRecipientItem.fromMap(Map<String, dynamic> map) {
    return ThrRecipientItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      isGiven: map['isGiven'] ?? false,
    );
  }
}

class ThrCategory {
  final String id;
  final String name;
  final int iconCode;
  final int colorValue;
  final double percentage;
  final double actualSpent;
  final String notes;
  final List<ThrRecipientItem> recipients;

  ThrCategory({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    required this.percentage,
    this.actualSpent = 0.0,
    this.notes = '',
    this.recipients = const [],
  });

  double allocatedAmount(double totalThr) => totalThr * (percentage / 100);

  double get recipientTotal =>
      recipients.fold(0.0, (prev, elem) => prev + elem.amount);

  ThrCategory copyWith({
    String? id,
    String? name,
    int? iconCode,
    int? colorValue,
    double? percentage,
    double? actualSpent,
    String? notes,
    List<ThrRecipientItem>? recipients,
  }) {
    return ThrCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      percentage: percentage ?? this.percentage,
      actualSpent: actualSpent ?? this.actualSpent,
      notes: notes ?? this.notes,
      recipients: recipients ?? this.recipients,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCode': iconCode,
      'colorValue': colorValue,
      'percentage': percentage,
      'actualSpent': actualSpent,
      'notes': notes,
      'recipients': recipients.map((x) => x.toMap()).toList(),
    };
  }

  factory ThrCategory.fromMap(Map<String, dynamic> map) {
    return ThrCategory(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      iconCode: map['iconCode'] ?? Icons.category_rounded.codePoint,
      colorValue: map['colorValue'] ?? 0xFF00BFA5,
      percentage: (map['percentage'] as num?)?.toDouble() ?? 0.0,
      actualSpent: (map['actualSpent'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] ?? '',
      recipients: (map['recipients'] as List<dynamic>?)
              ?.map((x) => ThrRecipientItem.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ThrBonusModel {
  final double totalThr;
  final String eventType;
  final int targetYear;
  final List<ThrCategory> categories;

  ThrBonusModel({
    this.totalThr = 0.0,
    this.eventType = 'Idul Fitri',
    int? targetYear,
    List<ThrCategory>? categories,
  })  : targetYear = targetYear ?? DateTime.now().year,
        categories = categories ?? _defaultCategoriesFor('Idul Fitri');

  double get totalAllocatedPercent =>
      categories.fold(0.0, (prev, c) => prev + c.percentage);

  double get totalAllocatedAmount =>
      categories.fold(0.0, (prev, c) => prev + c.allocatedAmount(totalThr));

  double get totalSpent =>
      categories.fold(0.0, (prev, c) => prev + c.actualSpent);

  double get remainingThr => totalThr - totalSpent;

  double get savingsAndInvestAmount {
    return categories
        .where((c) =>
            c.id.contains('savings') ||
            c.name.toLowerCase().contains('tabungan') ||
            c.name.toLowerCase().contains('investasi'))
        .fold(0.0, (prev, c) => prev + c.allocatedAmount(totalThr));
  }

  ThrBonusModel copyWith({
    double? totalThr,
    String? eventType,
    int? targetYear,
    List<ThrCategory>? categories,
  }) {
    return ThrBonusModel(
      totalThr: totalThr ?? this.totalThr,
      eventType: eventType ?? this.eventType,
      targetYear: targetYear ?? this.targetYear,
      categories: categories ?? this.categories,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalThr': totalThr,
      'eventType': eventType,
      'targetYear': targetYear,
      'categories': categories.map((x) => x.toMap()).toList(),
    };
  }

  factory ThrBonusModel.fromMap(Map<String, dynamic> map) {
    return ThrBonusModel(
      totalThr: (map['totalThr'] as num?)?.toDouble() ?? 0.0,
      eventType: map['eventType'] ?? 'Idul Fitri',
      targetYear: map['targetYear'] ?? DateTime.now().year,
      categories: (map['categories'] as List<dynamic>?)
              ?.map((x) => ThrCategory.fromMap(x as Map<String, dynamic>))
              .toList() ??
          _defaultCategoriesFor(map['eventType'] ?? 'Idul Fitri'),
    );
  }

  String toJson() => json.encode(toMap());

  factory ThrBonusModel.fromJson(String source) =>
      ThrBonusModel.fromMap(json.decode(source) as Map<String, dynamic>);

  static List<ThrCategory> _defaultCategoriesFor(String eventType) {
    if (eventType == 'Idul Fitri') {
      return [
        ThrCategory(
          id: 'zakat',
          name: 'Zakat & Sedekah',
          iconCode: Icons.volunteer_activism_rounded.codePoint,
          colorValue: 0xFF00BFA5,
          percentage: 10.0,
          notes: 'Zakat fitrah & sedekah kaum dhuafa',
          recipients: [
            ThrRecipientItem(
                id: '1', name: 'Zakat Fitrah Keluarga', amount: 200000),
            ThrRecipientItem(id: '2', name: 'Infaq Masjid', amount: 100000),
          ],
        ),
        ThrCategory(
          id: 'angpau',
          name: 'Angpau & THR Keluarga',
          iconCode: Icons.card_giftcard_rounded.codePoint,
          colorValue: 0xFFE91E63,
          percentage: 25.0,
          notes: 'Bagi-bagi untuk orang tua, keponakan, sanak saudara',
          recipients: [
            ThrRecipientItem(
                id: '1', name: 'Orang Tua / Mertua', amount: 750000),
            ThrRecipientItem(id: '2', name: 'Keponakan', amount: 500000),
          ],
        ),
        ThrCategory(
          id: 'mudik',
          name: 'Mudik & Transportasi',
          iconCode: Icons.directions_car_filled_rounded.codePoint,
          colorValue: 0xFF3F51B5,
          percentage: 20.0,
          notes: 'Bensin, tol, tiket, servis kendaraan',
        ),
        ThrCategory(
          id: 'kebutuhan_raya',
          name: 'Sajian & Baju Lebaran',
          iconCode: Icons.shopping_bag_rounded.codePoint,
          colorValue: 0xFFFF9800,
          percentage: 15.0,
          notes: 'Baju baru, kue kering, parsel/hampers',
        ),
        ThrCategory(
          id: 'savings',
          name: 'Tabungan & Investasi',
          iconCode: Icons.savings_rounded.codePoint,
          colorValue: 0xFF4CAF50,
          percentage: 20.0,
          notes: 'Investasikan agar THR tidak habis tak berbekas',
        ),
        ThrCategory(
          id: 'emergency',
          name: 'Dana Cadangan Pasca Hari Raya',
          iconCode: Icons.shield_rounded.codePoint,
          colorValue: 0xFF607D8B,
          percentage: 10.0,
          notes: 'Antisipasi tanggal tua pasca libur panjang',
        ),
      ];
    } else if (eventType == 'Natal & Tahun Baru') {
      return [
        ThrCategory(
          id: 'natal_perayaan',
          name: 'Kado & Parsel Natal',
          iconCode: Icons.card_giftcard_rounded.codePoint,
          colorValue: 0xFFE53935,
          percentage: 25.0,
          notes: 'Hadiah keluarga & hampers rekan kerja',
        ),
        ThrCategory(
          id: 'liburan',
          name: 'Liburan & Family Gathering',
          iconCode: Icons.flight_takeoff_rounded.codePoint,
          colorValue: 0xFF1E88E5,
          percentage: 25.0,
          notes: 'Wisata, makan bersama akhir tahun',
        ),
        ThrCategory(
          id: 'amal',
          name: 'Donasi & Persembahan',
          iconCode: Icons.volunteer_activism_rounded.codePoint,
          colorValue: 0xFF00BFA5,
          percentage: 10.0,
          notes: 'Persembahan gereja & donasi sosial',
        ),
        ThrCategory(
          id: 'savings',
          name: 'Tabungan Resolusi Tahun Baru',
          iconCode: Icons.savings_rounded.codePoint,
          colorValue: 0xFF4CAF50,
          percentage: 30.0,
          notes: 'Modal tabungan memulai target tahun depan',
        ),
        ThrCategory(
          id: 'emergency',
          name: 'Cadangan Awal Tahun',
          iconCode: Icons.shield_rounded.codePoint,
          colorValue: 0xFF795548,
          percentage: 10.0,
          notes: 'Biaya asuransi/pajak tahunan',
        ),
      ];
    } else {
      // Bonus Tahunan / Perusahaan / Kustom
      return [
        ThrCategory(
          id: 'investasi',
          name: 'Investasi & Saham/Reksadana',
          iconCode: Icons.trending_up_rounded.codePoint,
          colorValue: 0xFF00BFA5,
          percentage: 40.0,
          notes: 'Alokasi utama penambah aset kekayaan bersih',
        ),
        ThrCategory(
          id: 'pelunasan_hutang',
          name: 'Pelunasan Hutang / Cicilan',
          iconCode: Icons.money_off_rounded.codePoint,
          colorValue: 0xFFE53935,
          percentage: 20.0,
          notes: 'Percepat pelunasan utang/kredit konsumtif',
        ),
        ThrCategory(
          id: 'self_reward',
          name: 'Self Reward / Liburan',
          iconCode: Icons.celebration_rounded.codePoint,
          colorValue: 0xFFFF9800,
          percentage: 20.0,
          notes: 'Apresiasi kerja keras setahun penuh',
        ),
        ThrCategory(
          id: 'upgrade_skill',
          name: 'Upgrade Skill & Pendidikan',
          iconCode: Icons.school_rounded.codePoint,
          colorValue: 0xFF3F51B5,
          percentage: 10.0,
          notes: 'Buku, kursus sertifikasi, workshop',
        ),
        ThrCategory(
          id: 'emergency',
          name: 'Top-up Dana Darurat',
          iconCode: Icons.health_and_safety_rounded.codePoint,
          colorValue: 0xFF4CAF50,
          percentage: 10.0,
          notes: 'Mempertebal bantalan kas darurat 6-12 bulan',
        ),
      ];
    }
  }

  static ThrBonusModel createPreset(String eventType, double totalAmount) {
    return ThrBonusModel(
      totalThr: totalAmount,
      eventType: eventType,
      targetYear: DateTime.now().year,
      categories: _defaultCategoriesFor(eventType),
    );
  }
}
