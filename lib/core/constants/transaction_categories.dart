import 'package:flutter/material.dart';

class TransactionCategory {
  final String label;
  final IconData icon;
  final String group;
  final Color color;

  const TransactionCategory({
    required this.label,
    required this.icon,
    required this.group,
    required this.color,
  });
}

class AppCategories {
  static const String otherLabel = 'Kategori Lain';

  static const List<TransactionCategory> expenseCategories = [
    // --- SEKOLAH ---
    TransactionCategory(label: 'Iuran Kelas, Kas & OSIS', icon: Icons.groups_rounded, group: 'Sekolah', color: Color(0xFF1E88E5)),
    TransactionCategory(label: 'Buku Paket, LKS & Modul', icon: Icons.menu_book_rounded, group: 'Sekolah', color: Color(0xFF3F51B5)),
    TransactionCategory(label: 'Alat Tulis & Buku Tulis', icon: Icons.edit_rounded, group: 'Sekolah', color: Color(0xFF00ACC1)),
    TransactionCategory(label: 'Seragam, Sepatu & Atribut Sekolah', icon: Icons.checkroom_rounded, group: 'Sekolah', color: Color(0xFF0288D1)),
    TransactionCategory(label: 'Peralatan Praktikum & Lab Sekolah', icon: Icons.science_rounded, group: 'Sekolah', color: Color(0xFF0097A7)),
    TransactionCategory(label: 'Ekstrakurikuler, Pramuka & LDKS', icon: Icons.emoji_events_rounded, group: 'Sekolah', color: Color(0xFF1565C0)),
    TransactionCategory(label: 'Study Tour, Kunjungan & Transport Bis', icon: Icons.directions_bus_rounded, group: 'Sekolah', color: Color(0xFFFFB300)),
    TransactionCategory(label: 'Uang Jajan Kantin & Bekal Sekolah', icon: Icons.lunch_dining_rounded, group: 'Sekolah', color: Color(0xFFFF7043)),

    // --- KULIAH ---
    TransactionCategory(label: 'UKT & SPP Semesteran', icon: Icons.school_rounded, group: 'Kuliah', color: Color(0xFF5E35B1)),
    TransactionCategory(label: 'Buku Referensi, Jurnal & Fotokopi', icon: Icons.book_rounded, group: 'Kuliah', color: Color(0xFF673AB7)),
    TransactionCategory(label: 'Uang Kas Himpunan, BEM & UKM', icon: Icons.groups_rounded, group: 'Kuliah', color: Color(0xFFAB47BC)),
    TransactionCategory(label: 'Sertifikasi, Seminar & Workshop', icon: Icons.workspace_premium_rounded, group: 'Kuliah', color: Color(0xFF0288D1)),
    TransactionCategory(label: 'Kebutuhan KKN, Magang & PKL', icon: Icons.badge_rounded, group: 'Kuliah', color: Color(0xFF0277BD)),
    TransactionCategory(label: 'Print Tugas, Jilid Skripsi & Poster', icon: Icons.description_rounded, group: 'Kuliah', color: Color(0xFF78909C)),
    TransactionCategory(label: 'Sewa Kost, Kontrakan & Utilitas', icon: Icons.house_rounded, group: 'Kuliah', color: Color(0xFF43A047)),
    TransactionCategory(label: 'Penelitian, Kuesioner & Alat Lab', icon: Icons.biotech_rounded, group: 'Kuliah', color: Color(0xFFE91E63)),

    // --- KERJA ---
    TransactionCategory(label: 'Ongkos Commute (Bensin/MRT/KRL/Ojol)', icon: Icons.commute_rounded, group: 'Kerja', color: Color(0xFF00796B)),
    TransactionCategory(label: 'Makan Siang Kantor & Kopi Sore', icon: Icons.local_cafe_rounded, group: 'Kerja', color: Color(0xFF2E7D32)),
    TransactionCategory(label: 'Baju Kerja, Blazer, Batik & Sepatu', icon: Icons.checkroom_rounded, group: 'Kerja', color: Color(0xFF43A047)),
    TransactionCategory(label: 'Iuran Sosial, Uang Duka & Kas Divisi', icon: Icons.volunteer_activism_rounded, group: 'Kerja', color: Color(0xFFAD1457)),
    TransactionCategory(label: 'Peralatan Kerja (Mouse/Keyboard/Tas)', icon: Icons.laptop_mac_rounded, group: 'Kerja', color: Color(0xFF607D8B)),
    TransactionCategory(label: 'Langganan Software & Lisensi Kerja', icon: Icons.vpn_key_rounded, group: 'Kerja', color: Color(0xFF1565C0)),
    TransactionCategory(label: 'Sertifikasi Keahlian & Pelatihan', icon: Icons.workspace_premium_rounded, group: 'Kerja', color: Color(0xFF5E35B1)),
    TransactionCategory(label: 'Traktiran Tim & Makan-Makan Divisi', icon: Icons.restaurant_rounded, group: 'Kerja', color: Color(0xFFFF7043)),

    // --- USAHA ---
    TransactionCategory(label: 'Pembelian Stok, Bahan Baku & Barang', icon: Icons.inventory_2_rounded, group: 'Usaha', color: Color(0xFF0097A7)),
    TransactionCategory(label: 'Sewa Tempat Usaha & Gudang', icon: Icons.warehouse_rounded, group: 'Usaha', color: Color(0xFF455A64)),
    TransactionCategory(label: 'Operasional Toko (Listrik/Wifi/Air)', icon: Icons.business_center_rounded, group: 'Usaha', color: Color(0xFF546E7A)),
    TransactionCategory(label: 'Marketing, Iklan Sosmed & Ads', icon: Icons.campaign_rounded, group: 'Usaha', color: Color(0xFFC2185B)),
    TransactionCategory(label: 'Biaya Platform, Admin Shopee/Tiktok', icon: Icons.shopping_basket_rounded, group: 'Usaha', color: Color(0xFF00897B)),
    TransactionCategory(label: 'Gaji Karyawan, Bonus & Insentif Usaha', icon: Icons.badge_rounded, group: 'Usaha', color: Color(0xFF2E7D32)),
    TransactionCategory(label: 'Biaya Retur, Rusak & Ganti Rugi', icon: Icons.report_problem_rounded, group: 'Usaha', color: Color(0xFFD32F2F)),
    TransactionCategory(label: 'Kemasan, Label, Plastik & Kardus', icon: Icons.local_shipping_rounded, group: 'Usaha', color: Color(0xFF8D6E63)),

    // --- DIGITAL ---
    TransactionCategory(label: 'Langganan Netflix, Disney+, Spotify', icon: Icons.subscriptions_rounded, group: 'Digital', color: Color(0xFFE50914)),
    TransactionCategory(label: 'Top Up Game, Voucher & Diamond', icon: Icons.sports_esports_rounded, group: 'Digital', color: Color(0xFFAB47BC)),
    TransactionCategory(label: 'Cloud Storage (Google One/iCloud)', icon: Icons.cloud_rounded, group: 'Digital', color: Color(0xFF0288D1)),
    TransactionCategory(label: 'Domain, Hosting, Server & VPS', icon: Icons.dns_rounded, group: 'Digital', color: Color(0xFF5C6BC0)),
    TransactionCategory(label: 'Langganan Tools AI (ChatGPT/Claude Pro)', icon: Icons.psychology_rounded, group: 'Digital', color: Color(0xFF5E35B1)),
    TransactionCategory(label: 'Pulsa & Paket Data Seluler', icon: Icons.signal_cellular_alt_rounded, group: 'Digital', color: Color(0xFF8E24AA)),
    TransactionCategory(label: 'Keanggotaan Premium / VIP Member', icon: Icons.verified_user_rounded, group: 'Digital', color: Color(0xFF7B1FA2)),
    TransactionCategory(label: 'Lisensi Software & Tools Kreatif (Canva/Adobe)', icon: Icons.brush_rounded, group: 'Digital', color: Color(0xFF00ACC1)),
    TransactionCategory(label: 'E-Book, Audiobook & Komik Digital', icon: Icons.menu_book_rounded, group: 'Digital', color: Color(0xFF3F51B5)),
    TransactionCategory(label: 'Langganan Course & Kursus Online', icon: Icons.school_rounded, group: 'Digital', color: Color(0xFF1E88E5)),

    // --- KEBUTUHAN POKOK ---
    TransactionCategory(label: 'Makanan & Minuman Harian', icon: Icons.restaurant_rounded, group: 'Kebutuhan Pokok', color: Color(0xFF1E88E5)),
    TransactionCategory(label: 'Belanja Sembako & Bahan Pangan', icon: Icons.shopping_cart_rounded, group: 'Kebutuhan Pokok', color: Color(0xFF00ACC1)),
    TransactionCategory(label: 'Listrik, Air & Gas LPG', icon: Icons.electric_bolt_rounded, group: 'Kebutuhan Pokok', color: Color(0xFFFFB300)),
    TransactionCategory(label: 'Sewa / Kos / KPR', icon: Icons.house_rounded, group: 'Kebutuhan Pokok', color: Color(0xFF43A047)),
    TransactionCategory(label: 'Laundry & Kebersihan Rumah', icon: Icons.dry_cleaning_rounded, group: 'Kebutuhan Pokok', color: Color(0xFF42A5F5)),
    TransactionCategory(label: 'Peralatan & Perbaikan Rumah', icon: Icons.handyman_rounded, group: 'Kebutuhan Pokok', color: Color(0xFF795548)),
    TransactionCategory(label: 'Internet & TV Kabel Rumah', icon: Icons.live_tv_rounded, group: 'Kebutuhan Pokok', color: Color(0xFF1976D2)),
    TransactionCategory(label: 'Kebutuhan Bayi & Susu Formula', icon: Icons.child_friendly_rounded, group: 'Kebutuhan Pokok', color: Color(0xFFEC407A)),

    // --- GAYA HIDUP ---
    TransactionCategory(label: 'Belanja Fashion & Aksesoris', icon: Icons.shopping_bag_rounded, group: 'Gaya Hidup', color: Color(0xFFE91E63)),
    TransactionCategory(label: 'Hobi, Koleksi & Action Figure', icon: Icons.palette_rounded, group: 'Gaya Hidup', color: Color(0xFF673AB7)),
    TransactionCategory(label: 'Nongkrong, Cafe & Kuliner', icon: Icons.local_cafe_rounded, group: 'Gaya Hidup', color: Color(0xFF795548)),
    TransactionCategory(label: 'Traveling, Liburan & Camping', icon: Icons.luggage_rounded, group: 'Gaya Hidup', color: Color(0xFF0277BD)),
    TransactionCategory(label: 'Gym, Fitness & Olahraga', icon: Icons.fitness_center_rounded, group: 'Gaya Hidup', color: Color(0xFF43A047)),
    TransactionCategory(label: 'Salon, Kosmetik & Skincare', icon: Icons.face_retouching_natural_rounded, group: 'Gaya Hidup', color: Color(0xFFEC407A)),
    TransactionCategory(label: 'Konser, Bioskop & Event', icon: Icons.confirmation_number_rounded, group: 'Gaya Hidup', color: Color(0xFF9C27B0)),
    TransactionCategory(label: 'Hewan Peliharaan', icon: Icons.pets_rounded, group: 'Gaya Hidup', color: Color(0xFFFF8F00)),

    // --- JAJANAN & CEMILAN ---
    TransactionCategory(label: 'Cemilan, Gorengan & Jajanan Pasar', icon: Icons.cookie_rounded, group: 'Jajanan & Cemilan', color: Color(0xFF8D6E63)),
    TransactionCategory(label: 'Boba, Es Teh & Minuman Kekinian', icon: Icons.local_drink_rounded, group: 'Jajanan & Cemilan', color: Color(0xFF00ACC1)),
    TransactionCategory(label: 'Delivery Makanan (GoFood/GrabFood/ShopeeFood)', icon: Icons.delivery_dining_rounded, group: 'Jajanan & Cemilan', color: Color(0xFFFF7043)),
    TransactionCategory(label: 'Jajanan Minimarket (Kripik & Es Krim)', icon: Icons.icecream_rounded, group: 'Jajanan & Cemilan', color: Color(0xFFFFB300)),
    TransactionCategory(label: 'Bakso, Seblak & Street Food Lokal', icon: Icons.soup_kitchen_rounded, group: 'Jajanan & Cemilan', color: Color(0xFFE53935)),
    TransactionCategory(label: 'Dessert, Roti, Kue & Martabak', icon: Icons.cake_rounded, group: 'Jajanan & Cemilan', color: Color(0xFFAB47BC)),

    // --- TRANSPORTASI ---
    TransactionCategory(label: 'Bahan Bakar (BBM)', icon: Icons.local_gas_station_rounded, group: 'Transportasi', color: Color(0xFFE53935)),
    TransactionCategory(label: 'Ojek Online & Taksi', icon: Icons.moped_rounded, group: 'Transportasi', color: Color(0xFF43A047)),
    TransactionCategory(label: 'Servis, Cuci & Oli Kendaraan', icon: Icons.build_rounded, group: 'Transportasi', color: Color(0xFF455A64)),
    TransactionCategory(label: 'Tiket Kereta, Pesawat & Bus', icon: Icons.train_rounded, group: 'Transportasi', color: Color(0xFF1A237E)),
    TransactionCategory(label: 'Parkir, Tol & Denda E-TLE', icon: Icons.local_parking_rounded, group: 'Transportasi', color: Color(0xFFF4511E)),
    TransactionCategory(label: 'Top Up E-Money & Tiket Tol', icon: Icons.toll_rounded, group: 'Transportasi', color: Color(0xFFFFB300)),

    // --- KESEHATAN ---
    TransactionCategory(label: 'Dokter, Klinik & Rumah Sakit', icon: Icons.local_hospital_rounded, group: 'Kesehatan', color: Color(0xFFD32F2F)),
    TransactionCategory(label: 'Obat, Vitamin & Suplemen', icon: Icons.medication_rounded, group: 'Kesehatan', color: Color(0xFFEC407A)),
    TransactionCategory(label: 'BPJS & Asuransi Kesehatan', icon: Icons.admin_panel_settings_rounded, group: 'Kesehatan', color: Color(0xFF43A047)),
    TransactionCategory(label: 'Optik & Kacamata', icon: Icons.visibility_rounded, group: 'Kesehatan', color: Color(0xFF1E88E5)),
    TransactionCategory(label: 'Dental & Perawatan Gigi', icon: Icons.local_hospital_rounded, group: 'Kesehatan', color: Color(0xFF0288D1)),
    TransactionCategory(label: 'Cek Kesehatan & Lab', icon: Icons.biotech_rounded, group: 'Kesehatan', color: Color(0xFF43A047)),

    // --- KEUANGAN ---
    TransactionCategory(label: 'Biaya Admin Bank & Transfer', icon: Icons.account_balance_rounded, group: 'Keuangan', color: Color(0xFF607D8B)),
    TransactionCategory(label: 'Cicilan & Alokasi Investasi', icon: Icons.trending_up_rounded, group: 'Keuangan', color: Color(0xFF388E3C)),
    TransactionCategory(label: 'Asuransi Jiwa & Unit Link', icon: Icons.verified_user_rounded, group: 'Keuangan', color: Color(0xFF1565C0)),
    TransactionCategory(label: 'Pajak Pribadi & KPR', icon: Icons.request_quote_rounded, group: 'Keuangan', color: Color(0xFF455A64)),
    TransactionCategory(label: 'Top Up E-Wallet', icon: Icons.account_balance_wallet_rounded, group: 'Keuangan', color: Color(0xFF00BCD4)),
    TransactionCategory(label: 'Denda, Penalti & Bunga', icon: Icons.report_problem_rounded, group: 'Keuangan', color: Color(0xFFD32F2F)),

    // --- ANAK & KELUARGA ---
    TransactionCategory(label: 'Pendidikan & Mainan Anak', icon: Icons.toys_rounded, group: 'Anak & Keluarga', color: Color(0xFFAFB42B)),
    TransactionCategory(label: 'Uang Saku Anak', icon: Icons.savings_rounded, group: 'Anak & Keluarga', color: Color(0xFFFBC02D)),
    TransactionCategory(label: 'Kirim Orang Tua & Keluarga', icon: Icons.volunteer_activism_rounded, group: 'Anak & Keluarga', color: Color(0xFFE91E63)),
    TransactionCategory(label: 'Kado & Hadiah Keluarga', icon: Icons.card_giftcard_rounded, group: 'Anak & Keluarga', color: Color(0xFFFF7043)),
    TransactionCategory(label: 'Perayaan & Syukuran Keluarga', icon: Icons.celebration_rounded, group: 'Anak & Keluarga', color: Color(0xFFAD1457)),

    // --- SOSIAL & IBADAH ---
    TransactionCategory(label: 'Zakat, Infak & Sedekah', icon: Icons.spa_rounded, group: 'Sosial & Ibadah', color: Color(0xFF388E3C)),
    TransactionCategory(label: 'Donasi & Bantuan Kemanusiaan', icon: Icons.favorite_rounded, group: 'Sosial & Ibadah', color: Color(0xFFD32F2F)),
    TransactionCategory(label: 'Kondangan & Amplop Pernikahan', icon: Icons.card_giftcard_rounded, group: 'Sosial & Ibadah', color: Color(0xFFFF7043)),
    TransactionCategory(label: 'Iuran RT/RW & Kebersihan', icon: Icons.groups_rounded, group: 'Sosial & Ibadah', color: Color(0xFF455A64)),
    TransactionCategory(label: 'Qurban & Aqiqah', icon: Icons.mosque_rounded, group: 'Sosial & Ibadah', color: Color(0xFF388E3C)),

    // --- LAINNYA ---
    TransactionCategory(label: 'Belanja Online / Minimarket', icon: Icons.shopping_bag_rounded, group: 'Lainnya', color: Color(0xFFFF6D00)),
    TransactionCategory(label: 'Dana Darurat & Tak Terduga', icon: Icons.warning_amber_rounded, group: 'Lainnya', color: Color(0xFFF57C00)),
    TransactionCategory(label: 'Kehilangan & Musibah', icon: Icons.heart_broken_rounded, group: 'Lainnya', color: Color(0xFFD32F2F)),
    TransactionCategory(label: 'Biaya Pindahan & Pemakaman', icon: Icons.local_shipping_rounded, group: 'Lainnya', color: Color(0xFF8D6E63)),
    TransactionCategory(label: otherLabel, icon: Icons.more_horiz_rounded, group: 'Lainnya', color: Color(0xFF9E9E9E)),

    // --- HUTANG & PIUTANG ---
    TransactionCategory(label: 'Hutang', icon: Icons.call_made_rounded, group: 'Hutang & Piutang', color: Color(0xFFD32F2F)),
  ];

  static const List<TransactionCategory> incomeCategories = [
    // --- PEKERJAAN & GAJI ---
    TransactionCategory(label: 'Gaji Pokok', icon: Icons.payments_rounded, group: 'Pekerjaan & Gaji', color: Color(0xFF2E7D32)),
    TransactionCategory(label: 'Bonus, Insentif & Komisi', icon: Icons.stars_rounded, group: 'Pekerjaan & Gaji', color: Color(0xFFFFA000)),
    TransactionCategory(label: 'Uang Lembur / Overtime', icon: Icons.more_time_rounded, group: 'Pekerjaan & Gaji', color: Color(0xFF1976D2)),
    TransactionCategory(label: 'THR & Tunjangan Raya', icon: Icons.celebration_rounded, group: 'Pekerjaan & Gaji', color: Color(0xFFFBC02D)),
    TransactionCategory(label: 'Tunjangan Transport & Makan', icon: Icons.directions_car_rounded, group: 'Pekerjaan & Gaji', color: Color(0xFF43A047)),
    TransactionCategory(label: 'Tunjangan Kesehatan & Medis', icon: Icons.health_and_safety_rounded, group: 'Pekerjaan & Gaji', color: Color(0xFF2E7D32)),
    TransactionCategory(label: 'Gaji Magang / Internship', icon: Icons.badge_rounded, group: 'Pekerjaan & Gaji', color: Color(0xFF0288D1)),
    TransactionCategory(label: 'Reimbursement Kantor', icon: Icons.receipt_long_rounded, group: 'Pekerjaan & Gaji', color: Color(0xFF7B1FA2)),
    TransactionCategory(label: 'Pesangon & Pensiun', icon: Icons.elderly_rounded, group: 'Pekerjaan & Gaji', color: Color(0xFF795548)),
    TransactionCategory(label: 'Honorarium / Uang Lelah', icon: Icons.workspace_premium_rounded, group: 'Pekerjaan & Gaji', color: Color(0xFFFFA000)),

    // --- BISNIS & PENJUALAN ---
    TransactionCategory(label: 'Penjualan Produk (Toko/E-Commerce)', icon: Icons.storefront_rounded, group: 'Bisnis & Penjualan', color: Color(0xFF00796B)),
    TransactionCategory(label: 'Penjualan Jasa / Servis / Konsultasi', icon: Icons.support_agent_rounded, group: 'Bisnis & Penjualan', color: Color(0xFF00695C)),
    TransactionCategory(label: 'Omzet Jasa Titip (Jastip)', icon: Icons.shopping_bag_rounded, group: 'Bisnis & Penjualan', color: Color(0xFFE91E63)),
    TransactionCategory(label: 'Hasil Penjualan Franchise', icon: Icons.storefront_rounded, group: 'Bisnis & Penjualan', color: Color(0xFF00897B)),
    TransactionCategory(label: 'Hasil Ekspor Produk', icon: Icons.public_rounded, group: 'Bisnis & Penjualan', color: Color(0xFF2196F3)),
    TransactionCategory(label: 'Hasil Kemitraan & Kerja Sama B2B', icon: Icons.handshake_rounded, group: 'Bisnis & Penjualan', color: Color(0xFF3949AB)),

    // --- KERJA LEPAS & SAMPINGAN ---
    TransactionCategory(label: 'Proyek Freelance (Desain/IT/Konten)', icon: Icons.laptop_mac_rounded, group: 'Kerja Lepas & Sampingan', color: Color(0xFF5E35B1)),
    TransactionCategory(label: 'Freelance Internet / Online Global (Upwork/Fiverr/dll)', icon: Icons.public_rounded, group: 'Kerja Lepas & Sampingan', color: Color(0xFF0277BD)),
    TransactionCategory(label: 'Jasa Desain Grafis & Ilustrasi', icon: Icons.brush_rounded, group: 'Kerja Lepas & Sampingan', color: Color(0xFFE040FB)),
    TransactionCategory(label: 'Jasa Video Editing & Motion Graphics', icon: Icons.video_library_rounded, group: 'Kerja Lepas & Sampingan', color: Color(0xFFFF5722)),
    TransactionCategory(label: 'Jasa Voice Over & Dubbing', icon: Icons.mic_rounded, group: 'Kerja Lepas & Sampingan', color: Color(0xFF00ACC1)),
    TransactionCategory(label: 'Jasa Penerjemahan & Pembuatan Subtitle', icon: Icons.translate_rounded, group: 'Kerja Lepas & Sampingan', color: Color(0xFF3F51B5)),
    TransactionCategory(label: 'Jasa Copywriting & Content Writing', icon: Icons.edit_note_rounded, group: 'Kerja Lepas & Sampingan', color: Color(0xFF4CAF50)),
    TransactionCategory(label: 'Jasa Landing Page & Pembuatan Website', icon: Icons.web_rounded, group: 'Kerja Lepas & Sampingan', color: Color(0xFF00E676)),
    TransactionCategory(label: 'Jasa UI/UX Design & Mockup Figma', icon: Icons.view_quilt_rounded, group: 'Kerja Lepas & Sampingan', color: Color(0xFFD500F9)),
    TransactionCategory(label: 'Jasa Data Entry & Virtual Assistant', icon: Icons.keyboard_rounded, group: 'Kerja Lepas & Sampingan', color: Color(0xFF78909C)),
    TransactionCategory(label: 'Jasa Transkripsi Audio & Video', icon: Icons.audiotrack_rounded, group: 'Kerja Lepas & Sampingan', color: Color(0xFFFFB300)),
    TransactionCategory(label: 'Jasa SEO & Riset Keyword', icon: Icons.search_rounded, group: 'Kerja Lepas & Sampingan', color: Color(0xFF29B6F6)),
    TransactionCategory(label: 'Jasa Joki Game & Push Rank (ML/Genshin/dll)', icon: Icons.sports_esports_rounded, group: 'Kerja Lepas & Sampingan', color: Color(0xFF7E57C2)),
    TransactionCategory(label: 'Jasa Les Privat & Tutor Akademik', icon: Icons.school_rounded, group: 'Kerja Lepas & Sampingan', color: Color(0xFF2E7D32)),
    TransactionCategory(label: 'Jasa Fotografi & Dokumentasi Event', icon: Icons.photo_camera_rounded, group: 'Kerja Lepas & Sampingan', color: Color(0xFF3949AB)),
    TransactionCategory(label: 'Jasa Titip Beli (Jastip) Barang', icon: Icons.shopping_bag_rounded, group: 'Kerja Lepas & Sampingan', color: Color(0xFFE91E63)),
    TransactionCategory(label: 'Sewa & Sharing Akun Premium', icon: Icons.people_rounded, group: 'Kerja Lepas & Sampingan', color: Color(0xFF607D8B)),
    // --- JOKI TUGAS SMK ---
    // Rekayasa Perangkat Lunak (RPL)
    TransactionCategory(label: 'Joki Pemrograman & Coding (RPL)', icon: Icons.code_rounded, group: 'Joki Tugas SMK', color: Color(0xFFE53935)),
    TransactionCategory(label: 'Joki Pembuatan Web & Mobile App (RPL)', icon: Icons.web_rounded, group: 'Joki Tugas SMK', color: Color(0xFFD32F2F)),
    TransactionCategory(label: 'Joki Database & Query SQL (RPL)', icon: Icons.storage_rounded, group: 'Joki Tugas SMK', color: Color(0xFFC2185B)),
    
    // Teknik Komputer & Jaringan (TKJ)
    TransactionCategory(label: 'Joki Konfigurasi Mikrotik & Cisco (TKJ)', icon: Icons.settings_ethernet_rounded, group: 'Joki Tugas SMK', color: Color(0xFF1976D2)),
    TransactionCategory(label: 'Joki Setting Server & Jaringan (TKJ)', icon: Icons.dns_rounded, group: 'Joki Tugas SMK', color: Color(0xFF0288D1)),
    TransactionCategory(label: 'Joki Desain Topologi & Packet Tracer (TKJ)', icon: Icons.schema_rounded, group: 'Joki Tugas SMK', color: Color(0xFF0277BD)),
    
    // Desain Komunikasi Visual (DKV) & Multimedia
    TransactionCategory(label: 'Joki Desain Grafis, Banner & Logo (DKV)', icon: Icons.palette_rounded, group: 'Joki Tugas SMK', color: Color(0xFFFFA000)),
    TransactionCategory(label: 'Joki Video Editing & Animasi 3D (DKV)', icon: Icons.movie_rounded, group: 'Joki Tugas SMK', color: Color(0xFFF57C00)),
    
    // Teknik Elektronika Industri (TEI)
    TransactionCategory(label: 'Joki Desain PCB & Skema Proteus (TEI)', icon: Icons.developer_board_rounded, group: 'Joki Tugas SMK', color: Color(0xFF3F51B5)),
    TransactionCategory(label: 'Joki Teori PLC & Mikroprosesor (TEI)', icon: Icons.memory_rounded, group: 'Joki Tugas SMK', color: Color(0xFF2196F3)),
    
    // Teknik Instalasi Tenaga Listrik (TITL)
    TransactionCategory(label: 'Joki Gambar Rangkaian Listrik & Panel (TITL)', icon: Icons.bolt_rounded, group: 'Joki Tugas SMK', color: Color(0xFFFFC107)),
    TransactionCategory(label: 'Joki Teori Motor Listrik & PLC (TITL)', icon: Icons.settings_input_component_rounded, group: 'Joki Tugas SMK', color: Color(0xFFFF9800)),
    
    // Teknik Pemesinan (TP)
    TransactionCategory(label: 'Joki Gambar 2D/3D CAD & CAM (Pemesinan)', icon: Icons.precision_manufacturing_rounded, group: 'Joki Tugas SMK', color: Color(0xFF78909C)),
    TransactionCategory(label: 'Joki Teori Bubut, Frais & CNC (Pemesinan)', icon: Icons.construction_rounded, group: 'Joki Tugas SMK', color: Color(0xFF607D8B)),
    
    // Desain Pemodelan & Informasi Bangunan (DPIB)
    TransactionCategory(label: 'Joki Gambar Denah AutoCAD & SketchUp (DPIB)', icon: Icons.architecture_rounded, group: 'Joki Tugas SMK', color: Color(0xFF8D6E63)),
    TransactionCategory(label: 'Joki Perhitungan Rencana Anggaran Biaya (DPIB)', icon: Icons.calculate_rounded, group: 'Joki Tugas SMK', color: Color(0xFF5D4037)),
    
    // Akuntansi & Keuangan Lembaga (AKL)
    TransactionCategory(label: 'Joki Pembukuan & Laporan Keuangan (Akuntansi)', icon: Icons.calculate_rounded, group: 'Joki Tugas SMK', color: Color(0xFF2E7D32)),
    
    // Otomatisasi & Tata Kelola Perkantoran (OTKP)
    TransactionCategory(label: 'Joki Pengolahan Data Excel & Word (OTKP)', icon: Icons.description_rounded, group: 'Joki Tugas SMK', color: Color(0xFF43A047)),
    
    // Bisnis Daring & Pemasaran (BDP)
    TransactionCategory(label: 'Joki Rencana Bisnis & Pemasaran Digital (BDP)', icon: Icons.campaign_rounded, group: 'Joki Tugas SMK', color: Color(0xFFE91E63)),
    TransactionCategory(label: 'Joki Content Marketing, Copywriting & SEO (BDP)', icon: Icons.article_rounded, group: 'Joki Tugas SMK', color: Color(0xFF9C27B0)),
    
    // Teknik Kendaraan Ringan Otomotif (TKRO) & Teknik Bisnis Sepeda Motor (TBSM)
    TransactionCategory(label: 'Joki Laporan Tune-up & Overhaul (Otomotif)', icon: Icons.build_circle_rounded, group: 'Joki Tugas SMK', color: Color(0xFFE53935)),
    TransactionCategory(label: 'Joki Analisis Kelistrikan & Sasis (Otomotif)', icon: Icons.electric_car_rounded, group: 'Joki Tugas SMK', color: Color(0xFFC2185B)),
    TransactionCategory(label: 'Joki Soal Teori Kejuruan Mesin (Otomotif)', icon: Icons.settings_rounded, group: 'Joki Tugas SMK', color: Color(0xFFD32F2F)),
    
    // Perhotelan & Usaha Perjalanan Wisata (UPW)
    TransactionCategory(label: 'Joki SOP Front Office & Housekeeping (Perhotelan)', icon: Icons.hotel_rounded, group: 'Joki Tugas SMK', color: Color(0xFF009688)),
    TransactionCategory(label: 'Joki Penyusunan Paket Wisata & Itinerary (UPW)', icon: Icons.map_rounded, group: 'Joki Tugas SMK', color: Color(0xFF00ACC1)),
    
    // Tata Boga (Culinary)
    TransactionCategory(label: 'Joki Penyusunan Resep & Food Cost (Tata Boga)', icon: Icons.restaurant_rounded, group: 'Joki Tugas SMK', color: Color(0xFFFF9800)),
    TransactionCategory(label: 'Joki Laporan Praktik Kue & Pastry (Tata Boga)', icon: Icons.cake_rounded, group: 'Joki Tugas SMK', color: Color(0xFFFF7043)),
    
    // Tata Busana (Fashion)
    TransactionCategory(label: 'Joki Gambar Pola & Pecah Pola Busana', icon: Icons.straighten_rounded, group: 'Joki Tugas SMK', color: Color(0xFFE040FB)),
    TransactionCategory(label: 'Joki Laporan Pembuatan Busana / Desain Tekstil', icon: Icons.checkroom_rounded, group: 'Joki Tugas SMK', color: Color(0xFF9C27B0)),
    
    // Farmasi
    TransactionCategory(label: 'Joki Laporan Praktikum Jurnal Resep (Farmasi)', icon: Icons.medication_rounded, group: 'Joki Tugas SMK', color: Color(0xFFE91E63)),
    TransactionCategory(label: 'Joki Teori Dosis & Farmakognosi (Farmasi)', icon: Icons.science_rounded, group: 'Joki Tugas SMK', color: Color(0xFFEC407A)),
    
    // Keperawatan (Asisten Keperawatan)
    TransactionCategory(label: 'Joki Penyusunan Asuhan Keperawatan / Askep', icon: Icons.assignment_rounded, group: 'Joki Tugas SMK', color: Color(0xFFE53935)),
    TransactionCategory(label: 'Joki Teori Anatomi & Fisiologi (Keperawatan)', icon: Icons.favorite_rounded, group: 'Joki Tugas SMK', color: Color(0xFFD32F2F)),
    
    // Agribisnis Tanaman, Ternak & Perikanan
    TransactionCategory(label: 'Joki Laporan Pascapanen & Budidaya (Agribisnis)', icon: Icons.grass_rounded, group: 'Joki Tugas SMK', color: Color(0xFF4CAF50)),
    TransactionCategory(label: 'Joki Perhitungan Formulasi Pakan & Pupuk', icon: Icons.agriculture_rounded, group: 'Joki Tugas SMK', color: Color(0xFF2E7D32)),

    // --- KREATOR KONTEN & DIGITAL ---
    TransactionCategory(label: 'AdSense & Monetisasi Platform', icon: Icons.ads_click_rounded, group: 'Kreator Konten & Digital', color: Color(0xFF388E3C)),
    TransactionCategory(label: 'Sponsorship & Endorsement', icon: Icons.recommend_rounded, group: 'Kreator Konten & Digital', color: Color(0xFFC2185B)),
    TransactionCategory(label: 'Afiliasi & Referral (Shopee/Tiktok Affiliate)', icon: Icons.hub_rounded, group: 'Kreator Konten & Digital', color: Color(0xFFFF8F00)),
    TransactionCategory(label: 'Donasi Live Streaming (Saweria/Trakteer/Tiktok)', icon: Icons.video_camera_back_rounded, group: 'Kreator Konten & Digital', color: Color(0xFFEC407A)),
    TransactionCategory(label: 'Penjualan Karya Digital (Trakteer/KaryaKarsa/dll)', icon: Icons.favorite_rounded, group: 'Kreator Konten & Digital', color: Color(0xFFD32F2F)),
    TransactionCategory(label: 'Penjualan Template Canva & Aset 3D', icon: Icons.palette_rounded, group: 'Kreator Konten & Digital', color: Color(0xFFFFB300)),
    TransactionCategory(label: 'Penjualan Foto/Video Stock (Shutterstock/Freepik)', icon: Icons.camera_rounded, group: 'Kreator Konten & Digital', color: Color(0xFF00ACC1)),
    TransactionCategory(label: 'Penjualan Ebook & Kursus Online', icon: Icons.auto_stories_rounded, group: 'Kreator Konten & Digital', color: Color(0xFF7E57C2)),
    TransactionCategory(label: 'Royalti Karya & Lisensi Musik/Digital', icon: Icons.vpn_key_rounded, group: 'Kreator Konten & Digital', color: Color(0xFF7B1FA2)),

    // --- INVESTASI & ASET ---
    TransactionCategory(label: 'Profit Saham & Reksa Dana', icon: Icons.trending_up_rounded, group: 'Investasi & Aset', color: Color(0xFF2E7D32)),
    TransactionCategory(label: 'Profit Obligasi & Sukuk (SBN)', icon: Icons.payment_rounded, group: 'Investasi & Aset', color: Color(0xFF00ACC1)),
    TransactionCategory(label: 'Profit Crypto, Staking & Web3', icon: Icons.currency_bitcoin_rounded, group: 'Investasi & Aset', color: Color(0xFFFBC02D)),
    TransactionCategory(label: 'Airdrop Crypto Diterima', icon: Icons.toll_rounded, group: 'Investasi & Aset', color: Color(0xFFFF9800)),
    TransactionCategory(label: 'Hasil Penjualan Emas & Perhiasan', icon: Icons.diamond_rounded, group: 'Investasi & Aset', color: Color(0xFFFFD54F)),
    TransactionCategory(label: 'Hasil Jual Gadget & Elektronik Preloved', icon: Icons.phone_iphone_rounded, group: 'Investasi & Aset', color: Color(0xFF689F38)),
    TransactionCategory(label: 'Hasil Jual Aset Properti & Tanah', icon: Icons.landscape_rounded, group: 'Investasi & Aset', color: Color(0xFF4E342E)),
    TransactionCategory(label: 'Hasil Tukar Valas / Forex', icon: Icons.currency_exchange_rounded, group: 'Investasi & Aset', color: Color(0xFF1B5E20)),

    // --- PENDAPATAN PASIF & SEWA ---
    TransactionCategory(label: 'Sewa Properti (Kost/Rumah/Ruko)', icon: Icons.home_work_rounded, group: 'Pendapatan Pasif & Sewa', color: Color(0xFF00796B)),
    TransactionCategory(label: 'Sewa Kendaraan & Peralatan', icon: Icons.car_rental_rounded, group: 'Pendapatan Pasif & Sewa', color: Color(0xFF00695C)),
    TransactionCategory(label: 'Sewa Pasang Iklan (Baliho/Website)', icon: Icons.visibility_rounded, group: 'Pendapatan Pasif & Sewa', color: Color(0xFF1E88E5)),
    TransactionCategory(label: 'Hasil Mesin Otomatis (Vending/Laundromat)', icon: Icons.point_of_sale_rounded, group: 'Pendapatan Pasif & Sewa', color: Color(0xFF546E7A)),
    TransactionCategory(label: 'Bagi Hasil Kemitraan Pasif', icon: Icons.monetization_on_rounded, group: 'Pendapatan Pasif & Sewa', color: Color(0xFFF57C00)),

    // --- KEUANGAN & BANK ---
    TransactionCategory(label: 'Bunga Bank & Deposito', icon: Icons.account_balance_rounded, group: 'Keuangan & Bank', color: Color(0xFF1976D2)),
    TransactionCategory(label: 'Cashback, Diskon & Reward', icon: Icons.credit_score_rounded, group: 'Keuangan & Bank', color: Color(0xFF009688)),
    TransactionCategory(label: 'Refund / Pengembalian Dana', icon: Icons.replay_rounded, group: 'Keuangan & Bank', color: Color(0xFF546E7A)),
    TransactionCategory(label: 'Klaim Asuransi', icon: Icons.health_and_safety_rounded, group: 'Keuangan & Bank', color: Color(0xFF43A047)),
    TransactionCategory(label: 'Bunga Simpanan Koperasi', icon: Icons.people_rounded, group: 'Keuangan & Bank', color: Color(0xFFE53935)),
    TransactionCategory(label: 'Kompensasi / Ganti Rugi', icon: Icons.gavel_rounded, group: 'Keuangan & Bank', color: Color(0xFFD32F2F)),
    TransactionCategory(label: 'Transfer Masuk Bank Swasta (BCA/CIMB/dll)', icon: Icons.account_balance_rounded, group: 'Keuangan & Bank', color: Color(0xFF0288D1)),
    TransactionCategory(label: 'Transfer Masuk Bank BUMN (Mandiri/BRI/BNI)', icon: Icons.account_balance_rounded, group: 'Keuangan & Bank', color: Color(0xFF1565C0)),
    TransactionCategory(label: 'Transfer Masuk Bank Digital (Jago/SeaBank/Blu/Neo)', icon: Icons.phone_android_rounded, group: 'Keuangan & Bank', color: Color(0xFF00897B)),
    TransactionCategory(label: 'Transfer Masuk Bank Syariah (BSI/dll)', icon: Icons.mosque_rounded, group: 'Keuangan & Bank', color: Color(0xFF009688)),
    TransactionCategory(label: 'Saldo Masuk E-Wallet (GoPay/OVO/DANA/dll)', icon: Icons.wallet_rounded, group: 'Keuangan & Bank', color: Color(0xFF7B1FA2)),
    TransactionCategory(label: 'Penerimaan Dana Global (PayPal/Wise)', icon: Icons.public_rounded, group: 'Keuangan & Bank', color: Color(0xFF0277BD)),
    TransactionCategory(label: 'Hasil Pencairan Deposito Bank', icon: Icons.savings_rounded, group: 'Keuangan & Bank', color: Color(0xFF2E7D32)),

    // --- SOSIAL, HIBAH & UANG SAKU ---
    TransactionCategory(label: 'Kiriman Keluarga / Pasangan', icon: Icons.family_restroom_rounded, group: 'Sosial, Hibah & Uang Saku', color: Color(0xFFEC407A)),
    TransactionCategory(label: 'Uang Saku Sekolah / Kuliah', icon: Icons.backpack_rounded, group: 'Sosial, Hibah & Uang Saku', color: Color(0xFF1976D2)),
    TransactionCategory(label: 'Beasiswa Pendidikan & Hibah Riset', icon: Icons.workspace_premium_rounded, group: 'Sosial, Hibah & Uang Saku', color: Color(0xFF1A237E)),
    TransactionCategory(label: 'Angpao & Uang Lebaran / Hari Raya', icon: Icons.celebration_rounded, group: 'Sosial, Hibah & Uang Saku', color: Color(0xFFE91E63)),
    TransactionCategory(label: 'Kado & Hadiah Acara', icon: Icons.card_giftcard_rounded, group: 'Sosial, Hibah & Uang Saku', color: Color(0xFFFF7043)),
    TransactionCategory(label: 'Zakat, Infak & Sedekah Diterima', icon: Icons.spa_rounded, group: 'Sosial, Hibah & Uang Saku', color: Color(0xFF2E7D32)),
    TransactionCategory(label: 'Bansos & Subsidi Pemerintah', icon: Icons.assured_workload_rounded, group: 'Sosial, Hibah & Uang Saku', color: Color(0xFF3949AB)),
    TransactionCategory(label: 'Warisan & Hibah Harta', icon: Icons.real_estate_agent_rounded, group: 'Sosial, Hibah & Uang Saku', color: Color(0xFF795548)),
    TransactionCategory(label: 'Santunan / Sumbangan Duka', icon: Icons.volunteer_activism_rounded, group: 'Sosial, Hibah & Uang Saku', color: Color(0xFFE53935)),

    // --- PINJAMAN & TALANGAN ---
    TransactionCategory(label: 'Pengembalian Piutang (Tagihan)', icon: Icons.account_balance_wallet_rounded, group: 'Pinjaman & Talangan', color: Color(0xFF2E7D32)),
    TransactionCategory(label: 'Pencairan Pinjaman (Bank/KTA)', icon: Icons.account_balance_rounded, group: 'Pinjaman & Talangan', color: Color(0xFF5E35B1)),
    TransactionCategory(label: 'Dana Talangan & Arisan', icon: Icons.diversity_3_rounded, group: 'Pinjaman & Talangan', color: Color(0xFFC2185B)),
    TransactionCategory(label: 'Pengembalian Uang DP (Down Payment)', icon: Icons.replay_rounded, group: 'Pinjaman & Talangan', color: Color(0xFF546E7A)),
    TransactionCategory(label: 'Pencairan Pegadaian', icon: Icons.monetization_on_rounded, group: 'Pinjaman & Talangan', color: Color(0xFFFFB300)),

    // --- LAIN-LAIN ---
    TransactionCategory(label: 'Temuan Uang & Rezeki Nomplok', icon: Icons.savings_rounded, group: 'Lain-lain', color: Color(0xFFFBC02D)),
    TransactionCategory(label: 'Hadiah Kompetisi & Turnamen', icon: Icons.emoji_events_rounded, group: 'Lain-lain', color: Color(0xFFFFB300)),
    TransactionCategory(label: 'Hasil Daur Ulang & Jual Sampah', icon: Icons.recycling_rounded, group: 'Lain-lain', color: Color(0xFF43A047)),
    TransactionCategory(label: 'Hasil Lelang Barang Koleksi', icon: Icons.gavel_rounded, group: 'Lain-lain', color: Color(0xFF546E7A)),
    TransactionCategory(label: 'Piutang', icon: Icons.call_received_rounded, group: 'Lain-lain', color: Color(0xFF43A047)),
    TransactionCategory(label: otherLabel, icon: Icons.more_horiz_rounded, group: 'Lain-lain', color: Color(0xFF9E9E9E)),
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
