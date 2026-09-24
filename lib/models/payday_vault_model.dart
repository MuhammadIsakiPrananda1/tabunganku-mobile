/// Model: PaydayVaultModel
//
// Merepresentasikan brankas gajian untuk alokasi otomatis.
/// Mendukung serialisasi JSON untuk penyimpanan di [SharedPreferences].
library;

import 'dart:convert';

class PaydayVaultModel {
  final double monthlySalary;
  final int? paydayDate;
  final double needsPercent;
  final double wantsPercent;
  final double savingsPercent;
  final bool isVaultLocked;
  final double lockedAmount;
  final DateTime? lockedUntil;
  final int lockDurationDays;
  final int unlockedCount;
  final String? lastEmergencyUnlockReason;

  PaydayVaultModel({
    this.monthlySalary = 0,
    this.paydayDate,
    this.needsPercent = 50.0,
    this.wantsPercent = 30.0,
    this.savingsPercent = 20.0,
    this.isVaultLocked = false,
    this.lockedAmount = 0,
    this.lockedUntil,
    this.lockDurationDays = 30,
    this.unlockedCount = 0,
    this.lastEmergencyUnlockReason,
  });

  double get needsAmount => monthlySalary * (needsPercent / 100);
  double get wantsAmount => monthlySalary * (wantsPercent / 100);
  double get savingsAmount => monthlySalary * (savingsPercent / 100);

  bool get isLockExpired {
    if (lockedUntil == null) return false;
    return DateTime.now().isAfter(lockedUntil!);
  }

  Duration get remainingTime {
    if (lockedUntil == null) return Duration.zero;
    final diff = lockedUntil!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  PaydayVaultModel copyWith({
    double? monthlySalary,
    int? paydayDate,
    double? needsPercent,
    double? wantsPercent,
    double? savingsPercent,
    bool? isVaultLocked,
    double? lockedAmount,
    DateTime? lockedUntil,
    int? lockDurationDays,
    int? unlockedCount,
    String? lastEmergencyUnlockReason,
  }) {
    return PaydayVaultModel(
      monthlySalary: monthlySalary ?? this.monthlySalary,
      paydayDate: paydayDate ?? this.paydayDate,
      needsPercent: needsPercent ?? this.needsPercent,
      wantsPercent: wantsPercent ?? this.wantsPercent,
      savingsPercent: savingsPercent ?? this.savingsPercent,
      isVaultLocked: isVaultLocked ?? this.isVaultLocked,
      lockedAmount: lockedAmount ?? this.lockedAmount,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      lockDurationDays: lockDurationDays ?? this.lockDurationDays,
      unlockedCount: unlockedCount ?? this.unlockedCount,
      lastEmergencyUnlockReason:
          lastEmergencyUnlockReason ?? this.lastEmergencyUnlockReason,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'monthlySalary': monthlySalary,
      'paydayDate': paydayDate,
      'needsPercent': needsPercent,
      'wantsPercent': wantsPercent,
      'savingsPercent': savingsPercent,
      'isVaultLocked': isVaultLocked,
      'lockedAmount': lockedAmount,
      'lockedUntil': lockedUntil?.toIso8601String(),
      'lockDurationDays': lockDurationDays,
      'unlockedCount': unlockedCount,
      'lastEmergencyUnlockReason': lastEmergencyUnlockReason,
    };
  }

  factory PaydayVaultModel.fromMap(Map<String, dynamic> map) {
    return PaydayVaultModel(
      monthlySalary: (map['monthlySalary'] as num?)?.toDouble() ?? 0,
      paydayDate: ((map['monthlySalary'] as num?)?.toDouble() ?? 0) <= 0 &&
              map['paydayDate'] == 25
          ? null
          : map['paydayDate'] as int?,
      needsPercent: (map['needsPercent'] as num?)?.toDouble() ?? 50.0,
      wantsPercent: (map['wantsPercent'] as num?)?.toDouble() ?? 30.0,
      savingsPercent: (map['savingsPercent'] as num?)?.toDouble() ?? 20.0,
      isVaultLocked: map['isVaultLocked'] as bool? ?? false,
      lockedAmount: (map['lockedAmount'] as num?)?.toDouble() ?? 0,
      lockedUntil: map['lockedUntil'] != null
          ? DateTime.tryParse(map['lockedUntil'] as String)
          : null,
      lockDurationDays: map['lockDurationDays'] as int? ?? 30,
      unlockedCount: map['unlockedCount'] as int? ?? 0,
      lastEmergencyUnlockReason: map['lastEmergencyUnlockReason'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory PaydayVaultModel.fromJson(String source) =>
      PaydayVaultModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
