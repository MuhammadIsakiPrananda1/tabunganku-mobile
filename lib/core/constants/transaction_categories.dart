import 'package:flutter/material.dart';

class TransactionCategory {
  final String label;
  final IconData icon;
  final String group;

  const TransactionCategory({
    required this.label,
    required this.icon,
    this.group = '',
  });
}

class AppCategories {
  // Constants for special categories
  static const String otherLabel = 'Lainnya';

  static const List<TransactionCategory> expenseCategories = [
    // --- KEBUTUHAN POKOK ---
    TransactionCategory(
      label: 'Makanan & Minuman',
      icon: Icons.restaurant_rounded,
      group: 'Kebutuhan Pokok',
    ),
    TransactionCategory(
      label: 'Belanja Bulanan (Pasar/Supermarket)',
      icon: Icons.shopping_basket_rounded,
      group: 'Kebutuhan Pokok',
    ),
    TransactionCategory(
      label: 'Transportasi & Bensin',
      icon: Icons.local_gas_station_rounded,
      group: 'Kebutuhan Pokok',
    ),
    TransactionCategory(
      label: 'Tagihan Listrik / Air',
      icon: Icons.receipt_long_rounded,
      group: 'Kebutuhan Pokok',
    ),
    TransactionCategory(
      label: 'Pulsa & Internet',
      icon: Icons.wifi_tethering_rounded,
      group: 'Kebutuhan Pokok',
    ),
    TransactionCategory(
      label: 'Sewa Kos / Kontrakan / KPR',
      icon: Icons.house_rounded,
      group: 'Kebutuhan Pokok',
    ),
    TransactionCategory(
      label: 'Cicilan Kendaraan',
      icon: Icons.credit_score_rounded,
      group: 'Kebutuhan Pokok',
    ),

    // --- ANAK MUDA & GAYA HIDUP ---
    TransactionCategory(
      label: 'Nongkrong & Cafe',
      icon: Icons.coffee_rounded,
      group: 'Anak Muda & Gaya Hidup',
    ),
    TransactionCategory(
      label: 'Langganan (Netflix, Spotify, dll)',
      icon: Icons.smart_display_rounded,
      group: 'Anak Muda & Gaya Hidup',
    ),
    TransactionCategory(
      label: 'Top-up Games & Aplikasi',
      icon: Icons.sports_esports_rounded,
      group: 'Anak Muda & Gaya Hidup',
    ),
    TransactionCategory(
      label: 'Fashion, Skincare & Salon',
      icon: Icons.face_retouching_natural_rounded,
      group: 'Anak Muda & Gaya Hidup',
    ),
    TransactionCategory(
      label: 'Bioskop, Nonton & Konser',
      icon: Icons.confirmation_number_rounded,
      group: 'Anak Muda & Gaya Hidup',
    ),
    TransactionCategory(
      label: 'Gym & Olahraga',
      icon: Icons.fitness_center_rounded,
      group: 'Anak Muda & Gaya Hidup',
    ),
    TransactionCategory(
      label: 'Traveling & Staycation',
      icon: Icons.luggage_rounded,
      group: 'Anak Muda & Gaya Hidup',
    ),
    TransactionCategory(
      label: 'Hobi & Koleksi',
      icon: Icons.videogame_asset_rounded,
      group: 'Anak Muda & Gaya Hidup',
    ),
    TransactionCategory(
      label: 'Dating / Sosial',
      icon: Icons.favorite_rounded,
      group: 'Anak Muda & Gaya Hidup',
    ),

    // --- KEBUTUHAN ANAK ---
    TransactionCategory(
      label: 'Susu & Kebutuhan Bayi (Diapers)',
      icon: Icons.child_friendly_rounded,
      group: 'Kebutuhan Anak',
    ),
    TransactionCategory(
      label: 'Uang Saku / Jajan Anak',
      icon: Icons.savings_rounded,
      group: 'Kebutuhan Anak',
    ),
    TransactionCategory(
      label: 'Biaya Sekolah & SPP',
      icon: Icons.school_rounded,
      group: 'Kebutuhan Anak',
    ),
    TransactionCategory(
      label: 'Buku & Alat Tulis',
      icon: Icons.menu_book_rounded,
      group: 'Kebutuhan Anak',
    ),
    TransactionCategory(
      label: 'Mainan & Hiburan Anak',
      icon: Icons.toys_rounded,
      group: 'Kebutuhan Anak',
    ),
    TransactionCategory(
      label: 'Pakaian & Sepatu Anak',
      icon: Icons.checkroom_rounded,
      group: 'Kebutuhan Anak',
    ),
    TransactionCategory(
      label: 'Les / Kursus Tambahan',
      icon: Icons.local_library_rounded,
      group: 'Kebutuhan Anak',
    ),

    // --- ORANG TUA & LANSIA ---
    TransactionCategory(
      label: 'Uang Bulanan untuk Orang Tua',
      icon: Icons.volunteer_activism_rounded,
      group: 'Orang Tua & Lansia',
    ),
    TransactionCategory(
      label: 'Obat & Vitamin Rutin',
      icon: Icons.medication_rounded,
      group: 'Orang Tua & Lansia',
    ),
    TransactionCategory(
      label: 'Pemeriksaan Kesehatan / RS',
      icon: Icons.monitor_heart_rounded,
      group: 'Orang Tua & Lansia',
    ),
    TransactionCategory(
      label: 'Perlengkapan Lansia (Alat Bantu dll)',
      icon: Icons.accessibility_new_rounded,
      group: 'Orang Tua & Lansia',
    ),
    TransactionCategory(
      label: 'Asuransi Kesehatan / BPJS',
      icon: Icons.health_and_safety_rounded,
      group: 'Orang Tua & Lansia',
    ),
    TransactionCategory(
      label: 'Reuni & Kumpul Keluarga',
      icon: Icons.groups_rounded,
      group: 'Orang Tua & Lansia',
    ),

    // --- RUMAH TANGGA & SOSIAL ---
    TransactionCategory(
      label: 'Perbaikan / Renovasi Rumah',
      icon: Icons.home_repair_service_rounded,
      group: 'Rumah Tangga & Sosial',
    ),
    TransactionCategory(
      label: 'Perabotan / Elektronik',
      icon: Icons.kitchen_rounded,
      group: 'Rumah Tangga & Sosial',
    ),
    TransactionCategory(
      label: 'ART / Laundry / Kebersihan',
      icon: Icons.cleaning_services_rounded,
      group: 'Rumah Tangga & Sosial',
    ),
    TransactionCategory(
      label: 'Iuran RT, Keamanan & Sampah',
      icon: Icons.shield_rounded,
      group: 'Rumah Tangga & Sosial',
    ),
    TransactionCategory(
      label: 'Sumbangan, Zakat & Sedekah',
      icon: Icons.spa_rounded,
      group: 'Rumah Tangga & Sosial',
    ),
    TransactionCategory(
      label: 'Kondangan & Kado',
      icon: Icons.card_giftcard_rounded,
      group: 'Rumah Tangga & Sosial',
    ),

    // --- SIMPANAN & LAINNYA ---
    TransactionCategory(
      label: 'Tabungan & Dana Darurat',
      icon: Icons.account_balance_wallet_rounded,
      group: 'Simpanan & Lainnya',
    ),
    TransactionCategory(
      label: 'Investasi (Saham, Reksadana)',
      icon: Icons.trending_up_rounded,
      group: 'Simpanan & Lainnya',
    ),
    TransactionCategory(
      label: 'Pajak Kendaraan / PBB',
      icon: Icons.request_quote_rounded,
      group: 'Simpanan & Lainnya',
    ),
    TransactionCategory(
      label: otherLabel,
      icon: Icons.more_horiz_rounded,
      group: 'Simpanan & Lainnya',
    ),
  ];

  static const List<TransactionCategory> incomeCategories = [
    // --- PEKERJAAN & PROFESIONAL ---
    TransactionCategory(
      label: 'Gaji & Upah',
      icon: Icons.payments_rounded,
      group: 'Pekerjaan & Profesional',
    ),
    TransactionCategory(
      label: 'Bonus & Komisi',
      icon: Icons.stars_rounded,
      group: 'Pekerjaan & Profesional',
    ),
    TransactionCategory(
      label: 'Tunjangan (Allowance)',
      icon: Icons.add_moderator_rounded,
      group: 'Pekerjaan & Profesional',
    ),
    TransactionCategory(
      label: 'Freelance / Sampingan',
      icon: Icons.laptop_mac_rounded,
      group: 'Pekerjaan & Profesional',
    ),

    // --- BISNIS & DAGANG ---
    TransactionCategory(
      label: 'Hasil Jualan Produk',
      icon: Icons.storefront_rounded,
      group: 'Bisnis & Dagang',
    ),
    TransactionCategory(
      label: 'Hasil Jasa (Fee)',
      icon: Icons.handyman_rounded,
      group: 'Bisnis & Dagang',
    ),
    TransactionCategory(
      label: 'Keuntungan Bisnis',
      icon: Icons.monetization_on_rounded,
      group: 'Bisnis & Dagang',
    ),

    // --- INVESTASI & PASIF ---
    TransactionCategory(
      label: 'Dividen / Saham',
      icon: Icons.trending_up_rounded,
      group: 'Investasi & Pasif',
    ),
    TransactionCategory(
      label: 'Bunga Tabungan / Deposito',
      icon: Icons.account_balance_rounded,
      group: 'Investasi & Pasif',
    ),
    TransactionCategory(
      label: 'Sewa Properti / Kost',
      icon: Icons.apartment_rounded,
      group: 'Investasi & Pasif',
    ),
    TransactionCategory(
      label: 'Royalty',
      icon: Icons.copyright_rounded,
      group: 'Investasi & Pasif',
    ),

    // --- PELAJAR & PENDIDIKAN ---
    TransactionCategory(
      label: 'Uang Saku / Jajan',
      icon: Icons.school_rounded,
      group: 'Pelajar & Pendidikan',
    ),
    TransactionCategory(
      label: 'Beasiswa',
      icon: Icons.workspace_premium_rounded,
      group: 'Pelajar & Pendidikan',
    ),
    TransactionCategory(
      label: 'Hadiah Prestasi',
      icon: Icons.emoji_events_rounded,
      group: 'Pelajar & Pendidikan',
    ),

    // --- KELUARGA & SOSIAL ---
    TransactionCategory(
      label: 'Nafkah / Uang Belanja',
      icon: Icons.family_restroom_rounded,
      group: 'Keluarga & Sosial',
    ),
    TransactionCategory(
      label: 'Pemberian Keluarga',
      icon: Icons.volunteer_activism_rounded,
      group: 'Keluarga & Sosial',
    ),
    TransactionCategory(
      label: 'Warisan',
      icon: Icons.history_edu_rounded,
      group: 'Keluarga & Sosial',
    ),
    TransactionCategory(
      label: 'Dana Bantuan (Bansos)',
      icon: Icons.volunteer_activism_rounded,
      group: 'Keluarga & Sosial',
    ),

    // --- PENJUALAN ASET ---
    TransactionCategory(
      label: 'Jual Barang Bekas',
      icon: Icons.shopping_bag_rounded,
      group: 'Penjualan Aset',
    ),
    TransactionCategory(
      label: 'Jual Kendaraan',
      icon: Icons.directions_car_rounded,
      group: 'Penjualan Aset',
    ),
    TransactionCategory(
      label: 'Jual Emas / Perhiasan',
      icon: Icons.diamond_rounded,
      group: 'Penjualan Aset',
    ),

    // --- LAIN-LAIN & TAK TERDUGA ---
    TransactionCategory(
      label: 'Hadiah / Give Away',
      icon: Icons.card_giftcard_rounded,
      group: 'Lain-lain & Tak Terduga',
    ),
    TransactionCategory(
      label: 'Cashback & Reward',
      icon: Icons.loyalty_rounded,
      group: 'Lain-lain & Tak Terduga',
    ),
    TransactionCategory(
      label: 'Pengembalian (Refund)',
      icon: Icons.replay_rounded,
      group: 'Lain-lain & Tak Terduga',
    ),
    TransactionCategory(
      label: 'Menang Lomba / Undian',
      icon: Icons.confirmation_number_rounded,
      group: 'Lain-lain & Tak Terduga',
    ),
    TransactionCategory(
      label: 'Klaim Asuransi',
      icon: Icons.health_and_safety_rounded,
      group: 'Lain-lain & Tak Terduga',
    ),
    TransactionCategory(
      label: otherLabel,
      icon: Icons.more_horiz_rounded,
      group: 'Lain-lain & Tak Terduga',
    ),
  ];

  static IconData getIconForCategory(String categoryName) {
    final allCategories = [...expenseCategories, ...incomeCategories];
    try {
      return allCategories.firstWhere((c) => c.label == categoryName).icon;
    } catch (_) {
      return Icons.help_outline_rounded;
    }
  }
}
