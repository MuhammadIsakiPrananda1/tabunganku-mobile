/// Model: PremiumPackage
///
/// Definisi paket keanggotaan TabunganKu VIP mulai dari 1 hari hingga seumur hidup.
library;

import 'package:flutter/material.dart';
import 'package:tabunganku/features/premium/models/premium_certificate.dart';

class PremiumPackage {
  final String id;
  final PremiumTier tier;
  final Duration? duration;
  final String title;
  final String durationLabel;
  final String subtitle;
  final int price;
  final String priceFormatted;
  final String? pricePerDayNote;
  final String badge;
  final bool isPopular;
  final bool isLifetime;
  final String planCode;
  final IconData icon;

  const PremiumPackage({
    required this.id,
    required this.tier,
    this.duration,
    required this.title,
    required this.durationLabel,
    required this.subtitle,
    required this.price,
    required this.priceFormatted,
    this.pricePerDayNote,
    required this.badge,
    this.isPopular = false,
    this.isLifetime = false,
    required this.planCode,
    required this.icon,
  });

  /// Daftar paket resmi TabunganKu VIP
  static const List<PremiumPackage> all = [
    PremiumPackage(
      id: '1day',
      tier: PremiumTier.oneDay,
      duration: Duration(days: 1),
      title: 'Paket 1 Hari',
      durationLabel: '1 Hari',
      subtitle: 'Akses penuh 24 jam untuk eksplorasi',
      price: 2000,
      priceFormatted: 'Rp 2.000',
      pricePerDayNote: 'Rp 2.000/hari',
      badge: 'Uji Coba',
      planCode: '1DAY',
      icon: Icons.timer_outlined,
    ),
    PremiumPackage(
      id: '3days',
      tier: PremiumTier.threeDays,
      duration: Duration(days: 3),
      title: 'Paket 3 Hari',
      durationLabel: '3 Hari',
      subtitle: 'Ideal untuk evaluasi keuangan akhir pekan',
      price: 5000,
      priceFormatted: 'Rp 5.000',
      pricePerDayNote: 'Rp 1.666/hari',
      badge: 'Hemat',
      planCode: '3DAY',
      icon: Icons.weekend_outlined,
    ),
    PremiumPackage(
      id: '7days',
      tier: PremiumTier.sevenDays,
      duration: Duration(days: 7),
      title: 'Paket 7 Hari',
      durationLabel: '7 Hari (1 Minggu)',
      subtitle: 'Analisis mingguan & pemantauan finansial intensif',
      price: 10000,
      priceFormatted: 'Rp 10.000',
      pricePerDayNote: 'Rp 1.428/hari',
      badge: 'Fleksibel',
      planCode: '7DAY',
      icon: Icons.date_range_rounded,
    ),
    PremiumPackage(
      id: '1month',
      tier: PremiumTier.oneMonth,
      duration: Duration(days: 30),
      title: 'Paket 1 Bulan',
      durationLabel: '1 Bulan (30 Hari)',
      subtitle: 'Paket langganan rutin terlengkap setiap bulan',
      price: 25000,
      priceFormatted: 'Rp 25.000',
      pricePerDayNote: 'Rp 833/hari',
      badge: 'Paling Populer',
      isPopular: true,
      planCode: '30DY',
      icon: Icons.calendar_month_rounded,
    ),
    PremiumPackage(
      id: 'lifetime',
      tier: PremiumTier.vipLifetime,
      duration: null,
      title: 'Seumur Hidup',
      durationLabel: 'Permanen',
      subtitle: 'Sekali bayar, nikmati semua fitur VIP selamanya',
      price: 79000,
      priceFormatted: 'Rp 79.000',
      pricePerDayNote: 'Sekali bayar tanpa iuran',
      badge: 'Best Value',
      isPopular: false,
      isLifetime: true,
      planCode: 'LIFE',
      icon: Icons.workspace_premium_rounded,
    ),
  ];

  static PremiumPackage fromTier(PremiumTier tier) {
    return all.firstWhere(
      (p) => p.tier == tier,
      orElse: () => all.last,
    );
  }

  static PremiumPackage fromPlanCode(String planCode) {
    return all.firstWhere(
      (p) => p.planCode == planCode,
      orElse: () => all.last,
    );
  }
}
