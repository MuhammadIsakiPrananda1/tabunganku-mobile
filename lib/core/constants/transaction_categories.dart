import 'package:flutter/material.dart';

class TransactionCategory {
  final String label;
  final IconData icon;
  final String group;
  final Color color;

  const TransactionCategory({
    required this.label,
    required this.icon,
    required this.color,
    this.group = '',
  });
}

class AppCategories {
  // Constants for special categories
  static const String otherLabel = 'Lainnya';

  static const List<TransactionCategory> expenseCategories = [
    // --- KEBUTUHAN HARIAN & RUMAH TANGGA ---
    TransactionCategory(
      label: 'Makanan & Minuman',
      icon: Icons.restaurant_rounded,
      group: 'Kebutuhan Harian',
      color: Color(0xFF1E88E5), // Blue
    ),
    TransactionCategory(
      label: 'Belanja Sembako / Bulanan',
      icon: Icons.shopping_basket_rounded,
      group: 'Kebutuhan Harian',
      color: Color(0xFF00ACC1), // Cyan
    ),
    TransactionCategory(
      label: 'Token Listrik / Tagihan Listrik',
      icon: Icons.electric_bolt_rounded,
      group: 'Kebutuhan Harian',
      color: Color(0xFFFFB300), // Amber
    ),
    TransactionCategory(
      label: 'Tagihan Air (PDAM)',
      icon: Icons.water_drop_rounded,
      group: 'Kebutuhan Harian',
      color: Color(0xFF039BE5), // Light Blue
    ),
    TransactionCategory(
      label: 'Gas (LPG) & Air Galon',
      icon: Icons.propane_tank_rounded,
      group: 'Kebutuhan Harian',
      color: Color(0xFFFB8C00), // Orange
    ),
    TransactionCategory(
      label: 'Iuran Sampah & Keamanan (IPL)',
      icon: Icons.security_rounded,
      group: 'Kebutuhan Harian',
      color: Color(0xFF757575), // Grey
    ),
    TransactionCategory(
      label: 'Sewa Kos / Rumah / KPR',
      icon: Icons.house_rounded,
      group: 'Kebutuhan Harian',
      color: Color(0xFF43A047), // Green
    ),
    TransactionCategory(
      label: 'Arisan Bulanan',
      icon: Icons.groups_rounded,
      group: 'Kebutuhan Harian',
      color: Color(0xFFD81B60), // Pink
    ),

    // --- TRANSPORTASI ---
    TransactionCategory(
      label: 'Bahan Bakar (BBM)',
      icon: Icons.local_gas_station_rounded,
      group: 'Transportasi',
      color: Color(0xFFE53935), // Red
    ),
    TransactionCategory(
      label: 'Servis Kendaraan & Ganti Oli',
      icon: Icons.build_rounded,
      group: 'Transportasi',
      color: Color(0xFF546E7A), // Blue Grey
    ),
    TransactionCategory(
      label: 'Parkir & Tol',
      icon: Icons.local_parking_rounded,
      group: 'Transportasi',
      color: Color(0xFFF4511E), // Deep Orange
    ),
    TransactionCategory(
      label: 'Ojek / Taksi Online',
      icon: Icons.moped_rounded,
      group: 'Transportasi',
      color: Color(0xFFFDD835), // Yellow
    ),
    TransactionCategory(
      label: 'Tiket Pesawat / Kereta / Bus',
      icon: Icons.airplane_ticket_rounded,
      group: 'Transportasi',
      color: Color(0xFF3949AB), // Indigo
    ),
    TransactionCategory(
      label: 'Pajak Kendaraan (STNK)',
      icon: Icons.description_rounded,
      group: 'Transportasi',
      color: Color(0xFF5E35B1), // Deep Purple
    ),

    // --- KOMUNIKASI & TEKNOLOGI ---
    TransactionCategory(
      label: 'Pulsa, Data & Internet Seluler',
      icon: Icons.signal_cellular_alt_rounded,
      group: 'Teknologi',
      color: Color(0xFF8E24AA), // Purple
    ),
    TransactionCategory(
      label: 'WiFi / Internet Rumah',
      icon: Icons.wifi_rounded,
      group: 'Teknologi',
      color: Color(0xFF1E88E5), // Blue
    ),
    TransactionCategory(
      label: 'Langganan Digital (Netflix, Spotify, dll)',
      icon: Icons.subscriptions_rounded,
      group: 'Teknologi',
      color: Color(0xFF00897B), // Teal
    ),
    TransactionCategory(
      label: 'Servis Gadget / Pembelian Aksesoris',
      icon: Icons.devices_other_rounded,
      group: 'Teknologi',
      color: Color(0xFF455A64), // Blue Grey
    ),

    // --- PENDIDIKAN & PELAJAR ---
    TransactionCategory(
      label: 'SPP / UKT / Uang Sekolah',
      icon: Icons.school_rounded,
      group: 'Pendidikan',
      color: Color(0xFF3949AB), // Indigo
    ),
    TransactionCategory(
      label: 'Buku & Alat Tulis',
      icon: Icons.book_rounded,
      group: 'Pendidikan',
      color: Color(0xFF673AB7), // Deep Purple
    ),
    TransactionCategory(
      label: 'Kursus / Les / Pelatihan',
      icon: Icons.psychology_rounded,
      group: 'Pendidikan',
      color: Color(0xFF512DA8), // Deep Purple
    ),
    TransactionCategory(
      label: 'Uang Kas & Organisasi / Ekskul',
      icon: Icons.account_balance_wallet_rounded,
      group: 'Pendidikan',
      color: Color(0xFF303F9F), // Indigo
    ),
    TransactionCategory(
      label: 'Fotokopi, Jilid & Cetak Tugas',
      icon: Icons.print_rounded,
      group: 'Pendidikan',
      color: Color(0xFF1976D2), // Blue
    ),
    TransactionCategory(
      label: 'Bahan Prakarya / Kerajinan',
      icon: Icons.palette_rounded,
      group: 'Pendidikan',
      color: Color(0xFF8E24AA), // Purple
    ),
    TransactionCategory(
      label: 'Wisuda & Seragam Sekolah',
      icon: Icons.workspace_premium_rounded,
      group: 'Pendidikan',
      color: Color(0xFFC2185B), // Pink
    ),
    TransactionCategory(
      label: 'Jajan Kantin / Cemilan Sekolah',
      icon: Icons.cookie_rounded,
      group: 'Pendidikan',
      color: Color(0xFFFBC02D), // Yellow
    ),
    TransactionCategory(
      label: 'Bus Sekolah / Angkutan / Jemputan',
      icon: Icons.directions_bus_rounded,
      group: 'Pendidikan',
      color: Color(0xFFFF7043), // Deep Orange
    ),

    // --- KESEHATAN ---
    TransactionCategory(
      label: 'Obat, Vitamin & Suplemen',
      icon: Icons.medication_rounded,
      group: 'Kesehatan',
      color: Color(0xFFEC407A), // Light Pink
    ),
    TransactionCategory(
      label: 'Dokter, Klinik & Cek Lab',
      icon: Icons.medical_services_rounded,
      group: 'Kesehatan',
      color: Color(0xFF7CB342), // Light Green
    ),
    TransactionCategory(
      label: 'BPJS Kesehatan / Ketenagakerjaan',
      icon: Icons.admin_panel_settings_rounded,
      group: 'Kesehatan',
      color: Color(0xFF43A047), // Green
    ),
    TransactionCategory(
      label: 'Premi Asuransi Swasta',
      icon: Icons.health_and_safety_rounded,
      group: 'Kesehatan',
      color: Color(0xFF2E7D32), // Dark Green
    ),

    // --- GAYA HIDUP & HIBURAN ---
    TransactionCategory(
      label: 'Nongkrong & Coffee Shop',
      icon: Icons.coffee_rounded,
      group: 'Gaya Hidup',
      color: Color(0xFF795548), // Brown
    ),
    TransactionCategory(
      label: 'Nonton Bioskop & Event Hiburan',
      icon: Icons.confirmation_number_rounded,
      group: 'Gaya Hidup',
      color: Color(0xFF673AB7), // Deep Purple
    ),
    TransactionCategory(
      label: 'Fashion, Skincare & Grooming',
      icon: Icons.face_retouching_natural_rounded,
      group: 'Gaya Hidup',
      color: Color(0xFF009688), // Teal
    ),
    TransactionCategory(
      label: 'Traveling & Staycation',
      icon: Icons.luggage_rounded,
      group: 'Gaya Hidup',
      color: Color(0xFF0277BD), // Light Blue
    ),
    TransactionCategory(
      label: 'Olahraga & Gym',
      icon: Icons.fitness_center_rounded,
      group: 'Gaya Hidup',
      color: Color(0xFF558B2F), // Light Green
    ),
    TransactionCategory(
      label: 'Hobi, Games & Koleksi',
      icon: Icons.videogame_asset_rounded,
      group: 'Gaya Hidup',
      color: Color(0xFFAD1457), // Pink
    ),

    // --- KELUARGA & ANAK ---
    TransactionCategory(
      label: 'Susu, Diapers & Kebutuhan Bayi',
      icon: Icons.child_friendly_rounded,
      group: 'Keluarga',
      color: Color(0xFFF06292), // Pink
    ),
    TransactionCategory(
      label: 'Mainan & Rekreasi Anak',
      icon: Icons.toys_rounded,
      group: 'Keluarga',
      color: Color(0xFFAFB42B), // Lime
    ),
    TransactionCategory(
      label: 'Uang Saku Anak',
      icon: Icons.savings_rounded,
      group: 'Keluarga',
      color: Color(0xFFFBC02D), // Yellow
    ),
    TransactionCategory(
      label: 'Kirim ke Orang Tua / Keluarga',
      icon: Icons.volunteer_activism_rounded,
      group: 'Keluarga',
      color: Color(0xFFE91E63), // Pink
    ),
    TransactionCategory(
      label: 'Hewan Peliharaan (Pets)',
      icon: Icons.pets_rounded,
      group: 'Keluarga',
      color: Color(0xFF8D6E63), // Brown
    ),

    // --- SOSIAL & IBADAH ---
    TransactionCategory(
      label: 'Zakat, Infak & Sedekah',
      icon: Icons.spa_rounded,
      group: 'Sosial & Ibadah',
      color: Color(0xFF388E3C), // Green
    ),
    TransactionCategory(
      label: 'Perpuluhan / Iuran Tempat Ibadah',
      icon: Icons.church_rounded,
      group: 'Sosial & Ibadah',
      color: Color(0xFF5C6BC0), // Indigo
    ),
    TransactionCategory(
      label: 'Kondangan (Sumbangan Pernikahan)',
      icon: Icons.card_giftcard_rounded,
      group: 'Sosial & Ibadah',
      color: Color(0xFFFF7043), // Deep Orange
    ),
    TransactionCategory(
      label: 'Kado / Hadiah untuk Teman',
      icon: Icons.celebration_rounded,
      group: 'Sosial & Ibadah',
      color: Color(0xFFF06292), // Pink
    ),

    // --- KEUANGAN & BIAYA ADMIN ---
    TransactionCategory(
      label: 'Biaya Admin Bank',
      icon: Icons.account_balance_rounded,
      group: 'Keuangan',
      color: Color(0xFF607D8B), // Blue Grey
    ),
    TransactionCategory(
      label: 'Biaya Admin Aplikasi / Top Up',
      icon: Icons.account_balance_wallet_rounded,
      group: 'Keuangan',
      color: Color(0xFF455A64), // Blue Grey
    ),
    TransactionCategory(
      label: 'Bayar Hutang / Cicilan Pinjol',
      icon: Icons.money_off_rounded,
      group: 'Keuangan',
      color: Color(0xFFD32F2F), // Red
    ),
    TransactionCategory(
      label: 'Cicilan Kendaraan / Elektronik',
      icon: Icons.credit_card_rounded,
      group: 'Keuangan',
      color: Color(0xFF1976D2), // Blue
    ),
    TransactionCategory(
      label: 'Investasi (Emas, Saham, dll)',
      icon: Icons.trending_up_rounded,
      group: 'Keuangan',
      color: Color(0xFF388E3C), // Green
    ),
    TransactionCategory(
      label: 'Pajak Penghasilan (PPh / PBB)',
      icon: Icons.request_quote_rounded,
      group: 'Keuangan',
      color: Color(0xFF455A64), // Blue Grey
    ),
    TransactionCategory(
      label: 'Dana Darurat (Alokasi)',
      icon: Icons.warning_amber_rounded,
      group: 'Keuangan',
      color: Color(0xFFF57C00), // Orange
    ),

    // --- BISNIS & USAHA ---
    TransactionCategory(
      label: 'Pembelian Stok Barang / Bahan',
      icon: Icons.inventory_2_rounded,
      group: 'Bisnis',
      color: Color(0xFF0097A7), // Cyan
    ),
    TransactionCategory(
      label: 'Gaji Karyawan / Helper',
      icon: Icons.badge_rounded,
      group: 'Bisnis',
      color: Color(0xFF2E7D32), // Dark Green
    ),
    TransactionCategory(
      label: 'Sewa Tempat / Gudang Bisnis',
      icon: Icons.storefront_rounded,
      group: 'Bisnis',
      color: Color(0xFF00796B), // Teal
    ),
    TransactionCategory(
      label: 'Biaya Iklan & Promosi Sosial Media',
      icon: Icons.campaign_rounded,
      group: 'Bisnis',
      color: Color(0xFFC2185B), // Pink
    ),
    TransactionCategory(
      label: 'Biaya Operasional & Alat Kerja',
      icon: Icons.handyman_rounded,
      group: 'Bisnis',
      color: Color(0xFF616161), // Grey
    ),

    TransactionCategory(
      label: otherLabel,
      icon: Icons.more_horiz_rounded,
      group: 'Lainnya',
      color: Color(0xFF9E9E9E), // Light Grey
    ),
  ];

  static const List<TransactionCategory> incomeCategories = [
    // --- PEKERJAAN (Karyawan / Profesional) ---
    TransactionCategory(
      label: 'Gaji Pokok',
      icon: Icons.payments_rounded,
      group: 'Pekerjaan',
      color: Color(0xFF2E7D32), // Dark Green
    ),
    TransactionCategory(
      label: 'Rapel Gaji / Kekurangan Gaji',
      icon: Icons.history_rounded,
      group: 'Pekerjaan',
      color: Color(0xFF1B5E20), // Darker Green
    ),
    TransactionCategory(
      label: 'Tunjangan Jabatan / Profesi',
      icon: Icons.badge_rounded,
      group: 'Pekerjaan',
      color: Color(0xFF388E3C), // Green
    ),
    TransactionCategory(
      label: 'THR (Tunjangan Hari Raya)',
      icon: Icons.celebration_rounded,
      group: 'Pekerjaan',
      color: Color(0xFFFBC02D), // Yellow
    ),
    TransactionCategory(
      label: 'Bonus Tahunan / Performa',
      icon: Icons.stars_rounded,
      group: 'Pekerjaan',
      color: Color(0xFFFFA000), // Amber
    ),
    TransactionCategory(
      label: 'Lembur (Overtime)',
      icon: Icons.more_time_rounded,
      group: 'Pekerjaan',
      color: Color(0xFF1976D2), // Blue
    ),
    TransactionCategory(
      label: 'Komisi Penjualan',
      icon: Icons.add_moderator_rounded,
      group: 'Pekerjaan',
      color: Color(0xFF43A047), // Green
    ),
    TransactionCategory(
      label: 'Insentif & Tips',
      icon: Icons.volunteer_activism_rounded,
      group: 'Pekerjaan',
      color: Color(0xFF00ACC1), // Cyan
    ),
    TransactionCategory(
      label: 'Tunjangan Makan & Transp.',
      icon: Icons.commute_rounded,
      group: 'Pekerjaan',
      color: Color(0xFF0288D1), // Light Blue
    ),
    TransactionCategory(
      label: 'Reimbursement Kantor',
      icon: Icons.receipt_long_rounded,
      group: 'Pekerjaan',
      color: Color(0xFF7B1FA2), // Purple
    ),
    TransactionCategory(
      label: 'Uang Pesangon / Klaim JHT',
      icon: Icons.work_history_rounded,
      group: 'Pekerjaan',
      color: Color(0xFFD32F2F), // Red
    ),

    // --- BISNIS, FREELANCE & KONTEN ---
    TransactionCategory(
      label: 'Hasil Jualan / Omzet Produk',
      icon: Icons.storefront_rounded,
      group: 'Bisnis & Digital',
      color: Color(0xFF00796B), // Teal
    ),
    TransactionCategory(
      label: 'Fee Jasa / Proyek Freelance',
      icon: Icons.laptop_mac_rounded,
      group: 'Bisnis & Digital',
      color: Color(0xFF5E35B1), // Deep Purple
    ),
    TransactionCategory(
      label: 'Jasa Kreatif (Desain/Writing/Coding)',
      icon: Icons.brush_rounded,
      group: 'Bisnis & Digital',
      color: Color(0xFF673AB7), // Deep Purple
    ),
    TransactionCategory(
      label: 'Monetisasi Konten / Fans (Tip/Sawer)',
      icon: Icons.favorite_rounded,
      group: 'Bisnis & Digital',
      color: Color(0xFFD81B60), // Pink
    ),
    TransactionCategory(
      label: 'Jual Produk Digital (Ebook/Kursus)',
      icon: Icons.auto_stories_rounded,
      group: 'Bisnis & Digital',
      color: Color(0xFF8E24AA), // Purple
    ),
    TransactionCategory(
      label: 'Konsultasi & Pengajaran',
      icon: Icons.school_rounded,
      group: 'Bisnis & Digital',
      color: Color(0xFF455A64), // Blue Grey
    ),
    TransactionCategory(
      label: 'Sharing Profit / Keuntungan Usaha',
      icon: Icons.monetization_on_rounded,
      group: 'Bisnis & Digital',
      color: Color(0xFFF57C00), // Orange
    ),
    TransactionCategory(
      label: 'Affiliate & Dropship',
      icon: Icons.hub_rounded,
      group: 'Bisnis & Digital',
      color: Color(0xFFC2185B), // Pink
    ),
    TransactionCategory(
      label: 'AdSense & Endorsement',
      icon: Icons.campaign_rounded,
      group: 'Bisnis & Digital',
      color: Color(0xFFE91E63), // Pink 500
    ),

    // --- INVESTASI & PASIF ---
    TransactionCategory(
      label: 'Dividen Saham',
      icon: Icons.trending_up_rounded,
      group: 'Investasi & Pasif',
      color: Color(0xFF1B5E20), // Darker Green
    ),
    TransactionCategory(
      label: 'Profit Trading (Crypto/Saham/Forex)',
      icon: Icons.currency_exchange_rounded,
      group: 'Investasi & Pasif',
      color: Color(0xFF2E7D32), // Green
    ),
    TransactionCategory(
      label: 'Staking / Yield Farming',
      icon: Icons.account_balance_wallet_rounded,
      group: 'Investasi & Pasif',
      color: Color(0xFF009688), // Teal
    ),
    TransactionCategory(
      label: 'Bunga Deposito / Tabungan',
      icon: Icons.account_balance_rounded,
      group: 'Investasi & Pasif',
      color: Color(0xFF0D47A1), // Darker Blue
    ),
    TransactionCategory(
      label: 'Kupon Obligasi / SBN',
      icon: Icons.description_rounded,
      group: 'Investasi & Pasif',
      color: Color(0xFF00838F), // Dark Cyan
    ),
    TransactionCategory(
      label: 'Sewa Properti (Kost/Rumah)',
      icon: Icons.home_work_rounded,
      group: 'Investasi & Pasif',
      color: Color(0xFF6D4C41), // Brown
    ),
    TransactionCategory(
      label: 'Sewa Kendaraan',
      icon: Icons.directions_car_rounded,
      group: 'Investasi & Pasif',
      color: Color(0xFF455A64), // Blue Grey
    ),
    TransactionCategory(
      label: 'Profit Reksadana / Emas',
      icon: Icons.savings_rounded,
      group: 'Investasi & Pasif',
      color: Color(0xFFF9A825), // Yellow 800
    ),
    TransactionCategory(
      label: 'Capital Gain / Jual Aset',
      icon: Icons.sell_rounded,
      group: 'Investasi & Pasif',
      color: Color(0xFFE65100), // Deep Orange 900
    ),
    TransactionCategory(
      label: 'Royalti Karya / Hak Cipta',
      icon: Icons.auto_stories_rounded,
      group: 'Investasi & Pasif',
      color: Color(0xFFAD1457), // Pink 800
    ),

    // --- SOSIAL, HADIAH & HIBAH ---
    TransactionCategory(
      label: 'Pengembalian Hutang (Teman Bayar)',
      icon: Icons.handshake_rounded,
      group: 'Sosial & Hadiah',
      color: Color(0xFF2E7D32), // Green
    ),
    TransactionCategory(
      label: 'Uang Jajan Harian (Sekolah)',
      icon: Icons.payments_rounded,
      group: 'Sosial & Hadiah',
      color: Color(0xFF43A047), // Green
    ),
    TransactionCategory(
      label: 'Uang Saku Mingguan / Bulanan',
      icon: Icons.account_balance_wallet_rounded,
      group: 'Sosial & Hadiah',
      color: Color(0xFF00ACC1), // Cyan
    ),
    TransactionCategory(
      label: 'Hadiah Prestasi (Nilai / Ranking)',
      icon: Icons.stars_rounded,
      group: 'Sosial & Hadiah',
      color: Color(0xFFFBC02D), // Yellow
    ),
    TransactionCategory(
      label: 'Pemberian Orang Tua / Keluarga',
      icon: Icons.family_restroom_rounded,
      group: 'Sosial & Hadiah',
      color: Color(0xFFF06292), // Light Pink
    ),
    TransactionCategory(
      label: 'Beasiswa (Scholarship)',
      icon: Icons.workspace_premium_rounded,
      group: 'Sosial & Hadiah',
      color: Color(0xFF7986CB), // Indigo 300
    ),
    TransactionCategory(
      label: 'Kado / Hadiah Uang',
      icon: Icons.card_giftcard_rounded,
      group: 'Sosial & Hadiah',
      color: Color(0xFFFF8A65), // Deep Orange 300
    ),
    TransactionCategory(
      label: 'Angpao / Salam Tempel',
      icon: Icons.mail_rounded,
      group: 'Sosial & Hadiah',
      color: Color(0xFFE53935), // Red 600
    ),
    TransactionCategory(
      label: 'Menang Lomba / Giveaway',
      icon: Icons.emoji_events_rounded,
      group: 'Sosial & Hadiah',
      color: Color(0xFFFFD54F), // Amber 300
    ),
    TransactionCategory(
      label: 'Santunan / Donasi Diterima',
      icon: Icons.volunteer_activism_rounded,
      group: 'Sosial & Hadiah',
      color: Color(0xFF009688), // Teal
    ),
    TransactionCategory(
      label: 'Warisan / Hibah / Santunan',
      icon: Icons.handshake_rounded,
      group: 'Sosial & Hadiah',
      color: Color(0xFF8D6E63), // Brown 400
    ),
    TransactionCategory(
      label: 'Uang Temuan (Rejeki Nomplok)',
      icon: Icons.savings_rounded,
      group: 'Sosial & Hadiah',
      color: Color(0xFFFBC02D), // Yellow
    ),

    // --- LAIN-LAIN & REFUND ---
    TransactionCategory(
      label: 'Cashback e-Wallet / Belanja',
      icon: Icons.account_balance_wallet_rounded,
      group: 'Lainnya',
      color: Color(0xFF00897B), // Teal 600
    ),
    TransactionCategory(
      label: 'Refund (Pengembalian Dana)',
      icon: Icons.replay_rounded,
      group: 'Lainnya',
      color: Color(0xFF546E7A), // Blue Grey 600
    ),
    TransactionCategory(
      label: 'Jual Barang Bekas (Preloved)',
      icon: Icons.shopping_bag_rounded,
      group: 'Lainnya',
      color: Color(0xFF7CB342), // Light Green 600
    ),
    TransactionCategory(
      label: 'Jual Sampah / Daur Ulang',
      icon: Icons.recycling_rounded,
      group: 'Lainnya',
      color: Color(0xFF388E3C), // Green
    ),
    TransactionCategory(
      label: 'Klaim Asuransi / BPJS',
      icon: Icons.health_and_safety_rounded,
      group: 'Lainnya',
      color: Color(0xFF43A047), // Green 600
    ),
    TransactionCategory(
      label: 'Subsidi / Tunjangan Pemerintah',
      icon: Icons.gavel_rounded,
      group: 'Lainnya',
      color: Color(0xFF3949AB), // Indigo 600
    ),
    TransactionCategory(
      label: 'Pinjaman Diterima',
      icon: Icons.request_quote_rounded,
      group: 'Lainnya',
      color: Color(0xFF5E35B1), // Deep Purple 600
    ),
    TransactionCategory(
      label: 'Hadiah Undian / Jackpot',
      icon: Icons.workspace_premium_rounded,
      group: 'Lainnya',
      color: Color(0xFFFFA000), // Amber
    ),
    TransactionCategory(
      label: 'Kompensasi / Ganti Rugi',
      icon: Icons.gavel_rounded,
      group: 'Lainnya',
      color: Color(0xFF455A64), // Blue Grey
    ),
    TransactionCategory(
      label: 'Bonus Referral / Sign-up',
      icon: Icons.add_reaction_rounded,
      group: 'Lainnya',
      color: Color(0xFFD81B60), // Pink
    ),
    TransactionCategory(
      label: otherLabel,
      icon: Icons.more_horiz_rounded,
      group: 'Lainnya',
      color: Color(0xFF9E9E9E), // Grey
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

  static Color getColorForCategory(String categoryName) {
    final allCategories = [...expenseCategories, ...incomeCategories];
    try {
      return allCategories.firstWhere((c) => c.label == categoryName).color;
    } catch (_) {
      return Colors.grey;
    }
  }
}
