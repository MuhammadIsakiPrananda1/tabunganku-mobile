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
    TransactionCategory(
        label: 'Iuran Kelas, Kas & OSIS',
        icon: Icons.groups_rounded,
        group: 'Sekolah',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Buku Paket, LKS & Modul',
        icon: Icons.menu_book_rounded,
        group: 'Sekolah',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Alat Tulis & Buku Tulis',
        icon: Icons.edit_rounded,
        group: 'Sekolah',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Seragam & Atribut Sekolah',
        icon: Icons.checkroom_rounded,
        group: 'Sekolah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Peralatan Praktikum & Lab Sekolah',
        icon: Icons.science_rounded,
        group: 'Sekolah',
        color: Color(0xFF0097A7)),
    TransactionCategory(
        label: 'Ekstrakurikuler, Pramuka & LDKS',
        icon: Icons.emoji_events_rounded,
        group: 'Sekolah',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Study Tour, Kunjungan & Transport Bis',
        icon: Icons.directions_bus_rounded,
        group: 'Sekolah',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Uang Jajan Kantin & Bekal Sekolah',
        icon: Icons.lunch_dining_rounded,
        group: 'Sekolah',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'SPP Bulanan Sekolah',
        icon: Icons.calendar_month_rounded,
        group: 'Sekolah',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Pendaftaran Ulang / Iuran Komite',
        icon: Icons.assignment_turned_in_rounded,
        group: 'Sekolah',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Les Matematika / Sains / Bahasa',
        icon: Icons.menu_book_rounded,
        group: 'Sekolah',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Bimbingan Belajar (Bimbel) UTBK / Ujian',
        icon: Icons.school_rounded,
        group: 'Sekolah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Kegiatan Seni & Kreativitas',
        icon: Icons.checkroom_rounded,
        group: 'Sekolah',
        color: Color(0xFF0097A7)),
    TransactionCategory(
        label: 'Kertas Ujian, Lembar Jawab & Map',
        icon: Icons.description_rounded,
        group: 'Sekolah',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Les Bimbel Mata Pelajaran Bulanan',
        icon: Icons.school_rounded,
        group: 'Sekolah',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Tabungan Wajib / Sukarela Siswa',
        icon: Icons.savings_rounded,
        group: 'Sekolah',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Transportasi Harian Sekolah (Angkot/Ojek/Jemputan)',
        icon: Icons.directions_bus_rounded,
        group: 'Sekolah',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Biaya Uang Pangkal Sekolah Baru',
        icon: Icons.assignment_turned_in_rounded,
        group: 'Sekolah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Les Menggambar & Mewarnai Anak',
        icon: Icons.brush_rounded,
        group: 'Sekolah',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Biaya Sewa Loker & Keamanan Sekolah',
        icon: Icons.lock_rounded,
        group: 'Sekolah',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Iuran Kelas Sosial / Dana Kepedulian Teman Sakit',
        icon: Icons.volunteer_activism_rounded,
        group: 'Sekolah',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Sewa Sepeda / Transport Harian Anak Sekolah',
        icon: Icons.electric_bike_rounded,
        group: 'Sekolah',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Biaya Pembuatan Pas foto & Cetak Foto Ujian',
        icon: Icons.portrait_rounded,
        group: 'Sekolah',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Pembelian Badge & Logo Bordir Sekolah',
        icon: Icons.badge_rounded,
        group: 'Sekolah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Jasa Jilid Spiral, Hardcover & Laminating',
        icon: Icons.print_rounded,
        group: 'Sekolah',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Biaya Ujian Remedial / Ujian Perbaikan Nilai',
        icon: Icons.assignment_turned_in_rounded,
        group: 'Sekolah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Patungan Kado Ulang Tahun Wali Kelas / Dosen',
        icon: Icons.card_giftcard_rounded,
        group: 'Sekolah',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Sumbangan Kas Ikatan Alumni Sekolah / Kampus',
        icon: Icons.school_rounded,
        group: 'Sekolah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Biaya Pembuatan Jaket Angkatan / Jaket Kelas',
        icon: Icons.checkroom_rounded,
        group: 'Sekolah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Sewa Kamar Kost / Kontrakan Pelajar Harian',
        icon: Icons.roofing_rounded,
        group: 'Sekolah',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Buku LKS (Lembar Kerja Siswa) Eceran',
        icon: Icons.menu_book_rounded,
        group: 'Sekolah',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Iuran Patungan Beli Kado Kelompok untuk Teman',
        icon: Icons.card_giftcard_rounded,
        group: 'Sekolah',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Beli Sepatu Sekolah Hitam Standar Sekolah',
        icon: Icons.shopping_bag_rounded,
        group: 'Sekolah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Beli Tas Ransel Sekolah anti Air',
        icon: Icons.shopping_bag_rounded,
        group: 'Sekolah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Beli Kaos Kaki Putih & Hitam Sekolah',
        icon: Icons.checkroom_rounded,
        group: 'Sekolah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Beli Gesper & Ikat Pinggang Logo Sekolah',
        icon: Icons.badge_rounded,
        group: 'Sekolah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Beli Topi & Dasi Seragam Sekolah OSIS',
        icon: Icons.badge_rounded,
        group: 'Sekolah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Iuran Kelas Bulanan Kas Kelas',
        icon: Icons.groups_rounded,
        group: 'Sekolah',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Iuran Lomba Class Meeting Akhir Semester',
        icon: Icons.emoji_events_rounded,
        group: 'Sekolah',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Beli Buku Gambar A3 & Pensil Warna',
        icon: Icons.brush_rounded,
        group: 'Sekolah',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Beli Jangka, Penggaris & Busur Derajat',
        icon: Icons.edit_rounded,
        group: 'Sekolah',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Map Plastik Laporan Tugas Kelompok',
        icon: Icons.description_rounded,
        group: 'Sekolah',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Beli Kertas HVS F4 & Map Snelhester',
        icon: Icons.description_rounded,
        group: 'Sekolah',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Iuran Kegiatan Pramuka Sabtu Minggu',
        icon: Icons.groups_rounded,
        group: 'Sekolah',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Iuran Seragam Olahraga Sekolah Baru',
        icon: Icons.checkroom_rounded,
        group: 'Sekolah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Beli Buku Paket Agama & Budi Pekerti',
        icon: Icons.menu_book_rounded,
        group: 'Sekolah',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Beli Buku LKS Bahasa Jawa / Daerah',
        icon: Icons.menu_book_rounded,
        group: 'Sekolah',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Beli Baju Batik Sekolah Hari Kamis',
        icon: Icons.checkroom_rounded,
        group: 'Sekolah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Beli Baju Pramuka Lengkap Atribut Bordir',
        icon: Icons.checkroom_rounded,
        group: 'Sekolah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Iuran Foto Copy Bahan Ujian Akhir',
        icon: Icons.print_rounded,
        group: 'Sekolah',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Beli Pulpen Gel Hitam & Pensil 2B',
        icon: Icons.edit_rounded,
        group: 'Sekolah',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Penghapus, Rautan & Kotak Pensil',
        icon: Icons.edit_rounded,
        group: 'Sekolah',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Sewa Kostum Tari Tradisional Pentas Seni',
        icon: Icons.checkroom_rounded,
        group: 'Sekolah',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Beli Kertas Karton & Styrofoam Tugas Mading',
        icon: Icons.description_rounded,
        group: 'Sekolah',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Iuran Study Tour ke Candi Borobudur',
        icon: Icons.directions_bus_rounded,
        group: 'Sekolah',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Beli Kemeja Putih Seragam Sekolah Baru',
        icon: Icons.checkroom_rounded,
        group: 'Sekolah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Beli Celana Panjang Merah SD Baru',
        icon: Icons.checkroom_rounded,
        group: 'Sekolah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Beli Celana Panjang Biru SMP Baru',
        icon: Icons.checkroom_rounded,
        group: 'Sekolah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Beli Celana Panjang Abu-Abu SMA Baru',
        icon: Icons.checkroom_rounded,
        group: 'Sekolah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Beli Sepatu Olahraga Sekolah Baru',
        icon: Icons.shopping_bag_rounded,
        group: 'Sekolah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'UKT & SPP Semesteran',
        icon: Icons.school_rounded,
        group: 'Kuliah',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Buku Referensi, Jurnal & Fotokopi',
        icon: Icons.book_rounded,
        group: 'Kuliah',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Uang Kas Himpunan, BEM & UKM',
        icon: Icons.groups_rounded,
        group: 'Kuliah',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Sertifikasi, Seminar & Workshop',
        icon: Icons.workspace_premium_rounded,
        group: 'Kuliah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Kebutuhan KKN, Magang & PKL',
        icon: Icons.badge_rounded,
        group: 'Kuliah',
        color: Color(0xFF0277BD)),
    TransactionCategory(
        label: 'Print Tugas, Jilid Skripsi & Poster',
        icon: Icons.description_rounded,
        group: 'Kuliah',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Sewa Kost, Kontrakan & Utilitas',
        icon: Icons.house_rounded,
        group: 'Kuliah',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Penelitian, Kuesioner & Alat Lab',
        icon: Icons.biotech_rounded,
        group: 'Kuliah',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Sertifikasi Kompetensi Mahasiswa',
        icon: Icons.workspace_premium_rounded,
        group: 'Kuliah',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Ujian Sidang Skripsi & Her',
        icon: Icons.gavel_rounded,
        group: 'Kuliah',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Biaya Wisuda (Toga, Foto & Wisudawan)',
        icon: Icons.school_rounded,
        group: 'Kuliah',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Sewa Laboratorium / Studio Musik',
        icon: Icons.science_rounded,
        group: 'Kuliah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Aplikasi Pendukung Kuliah (Turnitin/EndNote/Mendeley)',
        icon: Icons.laptop_mac_rounded,
        group: 'Kuliah',
        color: Color(0xFF0277BD)),
    TransactionCategory(
        label: 'Kunjungan Industri & Studi Banding',
        icon: Icons.directions_bus_rounded,
        group: 'Kuliah',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Buku Elektronik (E-Textbook) Kuliah',
        icon: Icons.menu_book_rounded,
        group: 'Kuliah',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Akses E-Journal & Database Ilmiah Premium',
        icon: Icons.menu_book_rounded,
        group: 'Kuliah',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Uang Saku Hidup selama KKN / Magang',
        icon: Icons.badge_rounded,
        group: 'Kuliah',
        color: Color(0xFF0277BD)),
    TransactionCategory(
        label: 'Biaya Cetak Jilid Hardcover Skripsi / Thesis',
        icon: Icons.description_rounded,
        group: 'Kuliah',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Sewa Lapangan Olahraga / Studio Seni Kampus',
        icon: Icons.sports_tennis_rounded,
        group: 'Kuliah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Iuran Kepanitiaan & Event Organisasi Kampus',
        icon: Icons.groups_rounded,
        group: 'Kuliah',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Sewa Jas / Kebaya & Rias Wajah Wisuda',
        icon: Icons.face_retouching_natural_rounded,
        group: 'Kuliah',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Lisensi Software Riset (SPSS/SmartPLS/NVivo)',
        icon: Icons.laptop_mac_rounded,
        group: 'Kuliah',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Transkrip Nilai & Legalisir Ijazah',
        icon: Icons.assignment_turned_in_rounded,
        group: 'Kuliah',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Langganan Mendeley & Zotero Premium',
        icon: Icons.laptop_mac_rounded,
        group: 'Kuliah',
        color: Color(0xFF0277BD)),
    TransactionCategory(
        label: 'Sewa Laboratorium & Alat Penelitian',
        icon: Icons.science_rounded,
        group: 'Kuliah',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Pembelian Kertas Logbook & Binder Kuliah',
        icon: Icons.book_rounded,
        group: 'Kuliah',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Biaya Sewa Loker Kampus / Penyimpanan Barang',
        icon: Icons.lock_rounded,
        group: 'Kuliah',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Pembelian Almamater & Atribut Kelulusan',
        icon: Icons.checkroom_rounded,
        group: 'Kuliah',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Bayar UKT Semesteran Kuliah S1',
        icon: Icons.school_rounded,
        group: 'Kuliah',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Bayar UKT Semesteran Kuliah D3',
        icon: Icons.school_rounded,
        group: 'Kuliah',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Beli Buku Paket Kuliah Teknik/Ekonomi',
        icon: Icons.book_rounded,
        group: 'Kuliah',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Beli Jurnal Ilmiah / Akses Premium',
        icon: Icons.menu_book_rounded,
        group: 'Kuliah',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Biaya Foto Copy Diktat & Catatan',
        icon: Icons.description_rounded,
        group: 'Kuliah',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Biaya Print Tugas & Laporan Kuliah',
        icon: Icons.description_rounded,
        group: 'Kuliah',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Biaya Jilid Hardcover Laporan Magang',
        icon: Icons.description_rounded,
        group: 'Kuliah',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Biaya Jilid Spiral Skripsi Draf',
        icon: Icons.description_rounded,
        group: 'Kuliah',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Biaya Ujian Sidang Skripsi Kampus',
        icon: Icons.gavel_rounded,
        group: 'Kuliah',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Biaya Her Ujian / Remedial Nilai',
        icon: Icons.assignment_turned_in_rounded,
        group: 'Kuliah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Biaya Wisuda Toga & Map Kelulusan',
        icon: Icons.school_rounded,
        group: 'Kuliah',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Biaya Foto Wisuda Studio Bersama',
        icon: Icons.camera_rounded,
        group: 'Kuliah',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Sewa Kost Bulanan Mahasiswa Kampus',
        icon: Icons.house_rounded,
        group: 'Kuliah',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Bayar Listrik & Air Kost bulanan',
        icon: Icons.bolt_rounded,
        group: 'Kuliah',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Beli Token Listrik Kost Kamar Kost',
        icon: Icons.bolt_rounded,
        group: 'Kuliah',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Iuran Kas Himpunan Mahasiswa Jurusan',
        icon: Icons.groups_rounded,
        group: 'Kuliah',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Iuran Kas Unit Kegiatan Mahasiswa UKM',
        icon: Icons.groups_rounded,
        group: 'Kuliah',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Biaya Pendaftaran Seminar Nasional Kampus',
        icon: Icons.workspace_premium_rounded,
        group: 'Kuliah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Biaya Pendaftaran Workshop Kompetensi Kampus',
        icon: Icons.workspace_premium_rounded,
        group: 'Kuliah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Sewa Jas Almamater Kampus Wisuda',
        icon: Icons.checkroom_rounded,
        group: 'Kuliah',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Sewa Kebaya / Jas Kelulusan Wisuda',
        icon: Icons.checkroom_rounded,
        group: 'Kuliah',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Rias Wajah / Make Up Wisuda',
        icon: Icons.face_retouching_natural_rounded,
        group: 'Kuliah',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Uang Kas KKN Kelompok Desa',
        icon: Icons.groups_rounded,
        group: 'Kuliah',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Uang Makan Harian Selama PKL/Magang',
        icon: Icons.restaurant_rounded,
        group: 'Kuliah',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Beli Binder Kuliah & Kertas Loose Leaf',
        icon: Icons.book_rounded,
        group: 'Kuliah',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Beli Pulpen Standard & Stabilo Pen',
        icon: Icons.edit_rounded,
        group: 'Kuliah',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Sewa Laboratorium Kampus Alat Riset',
        icon: Icons.science_rounded,
        group: 'Kuliah',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Sewa Studio Seni / Musik Kampus',
        icon: Icons.science_rounded,
        group: 'Kuliah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Sewa Lapangan Olahraga Kampus Futsal',
        icon: Icons.sports_tennis_rounded,
        group: 'Kuliah',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Beli Lisensi Software SPSS Olah Data',
        icon: Icons.laptop_mac_rounded,
        group: 'Kuliah',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Beli Lisensi Software Mendeley Premium',
        icon: Icons.laptop_mac_rounded,
        group: 'Kuliah',
        color: Color(0xFF0277BD)),
    TransactionCategory(
        label: 'Beli Buku Laporan Praktikum Lab',
        icon: Icons.book_rounded,
        group: 'Kuliah',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Ongkos Commute (Bensin/MRT/KRL/Ojol)',
        icon: Icons.commute_rounded,
        group: 'Kerja',
        color: Color(0xFF00796B)),
    TransactionCategory(
        label: 'Makan Siang Kantor & Kopi Sore',
        icon: Icons.local_cafe_rounded,
        group: 'Kerja',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Baju Kerja, Blazer, Batik & Sepatu',
        icon: Icons.checkroom_rounded,
        group: 'Kerja',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Iuran Sosial & Kas Divisi',
        icon: Icons.volunteer_activism_rounded,
        group: 'Kerja',
        color: Color(0xFFAD1457)),
    TransactionCategory(
        label: 'Peralatan & Tas Kerja',
        icon: Icons.laptop_mac_rounded,
        group: 'Kerja',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Langganan Software & Lisensi Kerja',
        icon: Icons.vpn_key_rounded,
        group: 'Kerja',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Pelatihan, Seminar & Sertifikasi',
        icon: Icons.workspace_premium_rounded,
        group: 'Kerja',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Gathering & Sosial Kantor',
        icon: Icons.restaurant_rounded,
        group: 'Kerja',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Parkir Langganan Kantor / Gedung',
        icon: Icons.local_parking_rounded,
        group: 'Kerja',
        color: Color(0xFF00796B)),
    TransactionCategory(
        label: 'Iuran Dana Sosial & Ultah Rekan Kerja',
        icon: Icons.cake_rounded,
        group: 'Kerja',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Laundry Pakaian Kerja / Dry Clean Jas',
        icon: Icons.dry_cleaning_rounded,
        group: 'Kerja',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Peralatan Ergonomis (Cushion/Wrist Rest)',
        icon: Icons.chair_rounded,
        group: 'Kerja',
        color: Color(0xFFAD1457)),
    TransactionCategory(
        label: 'Kacamata Anti Radiasi Komputer',
        icon: Icons.visibility_rounded,
        group: 'Kerja',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Kopi, Snack & Coffee Break Kantor',
        icon: Icons.local_cafe_rounded,
        group: 'Kerja',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Biaya Ongkos Kirim Dokumen Kerja',
        icon: Icons.mail_rounded,
        group: 'Kerja',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Pembelian Kemeja & Celana Bahan Kerja',
        icon: Icons.checkroom_rounded,
        group: 'Kerja',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Pembelian Sepatu Kerja Pantofel / Heels',
        icon: Icons.shopping_bag_rounded,
        group: 'Kerja',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Biaya Parkir Harian Non-Langganan Kantor',
        icon: Icons.local_parking_rounded,
        group: 'Kerja',
        color: Color(0xFF00796B)),
    TransactionCategory(
        label: 'Biaya Kontrak Rumah / Kos Dekat Area Kantor',
        icon: Icons.house_rounded,
        group: 'Kerja',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Laundry Sepatu & Tas Kerja (Deep Clean)',
        icon: Icons.dry_cleaning_rounded,
        group: 'Kerja',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Biaya Keanggotaan Asosiasi Profesi Bulanan',
        icon: Icons.workspace_premium_rounded,
        group: 'Kerja',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Hadiah / Uang Kas Syukuran Kenaikan Pangkat',
        icon: Icons.celebration_rounded,
        group: 'Kerja',
        color: Color(0xFFAD1457)),
    TransactionCategory(
        label: 'Biaya Parkir Berlangganan / Member Bulanan Kantor',
        icon: Icons.local_parking_rounded,
        group: 'Kerja',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Biaya Makan Lembur & Jajan Malam Proyek',
        icon: Icons.coffee_rounded,
        group: 'Kerja',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Biaya Jahit Seragam Kerja / Batik Kantor',
        icon: Icons.checkroom_rounded,
        group: 'Kerja',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Sumbangan Kado Pernikahan & Lahiran Teman Kerja',
        icon: Icons.card_giftcard_rounded,
        group: 'Kerja',
        color: Color(0xFFAD1457)),
    TransactionCategory(
        label: 'Iuran Makan Siang Kantor Hari Jumat',
        icon: Icons.restaurant_rounded,
        group: 'Kerja',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Sumbangan Bencana Alam / Bakti Sosial Kantor',
        icon: Icons.volunteer_activism_rounded,
        group: 'Kerja',
        color: Color(0xFFAD1457)),
    TransactionCategory(
        label: 'Biaya Sewa Loker Bulanan Karyawan',
        icon: Icons.lock_rounded,
        group: 'Kerja',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Hadiah Farewell Teman Resign & Pensiun',
        icon: Icons.card_giftcard_rounded,
        group: 'Kerja',
        color: Color(0xFFAD1457)),
    TransactionCategory(
        label: 'Iuran Kas Olahraga Kantor (Futsal/Badminton)',
        icon: Icons.sports_soccer_rounded,
        group: 'Kerja',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Langganan Lisensi Software Desain & Dev Kantor',
        icon: Icons.laptop_mac_rounded,
        group: 'Kerja',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Beli Kemeja Batik Kerja Lengan Panjang',
        icon: Icons.checkroom_rounded,
        group: 'Kerja',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Beli Celana Bahan Hitam Formal',
        icon: Icons.checkroom_rounded,
        group: 'Kerja',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Beli Sepatu Pantofel Kulit Hitam Pria',
        icon: Icons.shopping_bag_rounded,
        group: 'Kerja',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Beli Sepatu Flat Shoes Hitam Wanita',
        icon: Icons.shopping_bag_rounded,
        group: 'Kerja',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Beli Blazer Kerja Formal Wanita',
        icon: Icons.checkroom_rounded,
        group: 'Kerja',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Beli Tas Kerja Laptop Selempang',
        icon: Icons.laptop_mac_rounded,
        group: 'Kerja',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Beli Mouse Wireless Ergonomis Logitech',
        icon: Icons.laptop_mac_rounded,
        group: 'Kerja',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Beli Keyboard Wireless Silent Key',
        icon: Icons.laptop_mac_rounded,
        group: 'Kerja',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Beli Headset Microphone Noise Cancelling',
        icon: Icons.laptop_mac_rounded,
        group: 'Kerja',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Beli Tumbler Air Minum Stainless Kantor',
        icon: Icons.coffee_rounded,
        group: 'Kerja',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Beli Bantal Sandaran Kursi Kantor (Lumbar)',
        icon: Icons.chair_rounded,
        group: 'Kerja',
        color: Color(0xFFAD1457)),
    TransactionCategory(
        label: 'Beli Kacamata Lensa Anti Blue Light',
        icon: Icons.visibility_rounded,
        group: 'Kerja',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Laundry Dry Clean Kemeja & Jas Kantor',
        icon: Icons.dry_cleaning_rounded,
        group: 'Kerja',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Iuran Dana Duka Cita Rekan Kerja',
        icon: Icons.volunteer_activism_rounded,
        group: 'Kerja',
        color: Color(0xFFAD1457)),
    TransactionCategory(
        label: 'Iuran Kado Pernikahan Rekan Divisi',
        icon: Icons.card_giftcard_rounded,
        group: 'Kerja',
        color: Color(0xFFAD1457)),
    TransactionCategory(
        label: 'Iuran Kado Melahirkan Rekan Kantor',
        icon: Icons.card_giftcard_rounded,
        group: 'Kerja',
        color: Color(0xFFAD1457)),
    TransactionCategory(
        label: 'Iuran Syukuran Promosi Jabatan Teman',
        icon: Icons.celebration_rounded,
        group: 'Kerja',
        color: Color(0xFFAD1457)),
    TransactionCategory(
        label: 'Iuran Kas Makan Siang Bareng Hari Jumat',
        icon: Icons.restaurant_rounded,
        group: 'Kerja',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Beli Kopi Susu Gula Aren Kopi Kenangan',
        icon: Icons.local_cafe_rounded,
        group: 'Kerja',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Beli Kopi Hitam Americano Kopi Janji Jiwa',
        icon: Icons.local_cafe_rounded,
        group: 'Kerja',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Beli Roti O / Roti Boy di Stasiun Kerja',
        icon: Icons.local_cafe_rounded,
        group: 'Kerja',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Bayar Parkir Langganan Motor Bulanan',
        icon: Icons.local_parking_rounded,
        group: 'Kerja',
        color: Color(0xFF00796B)),
    TransactionCategory(
        label: 'Bayar Parkir Langganan Mobil Bulanan',
        icon: Icons.local_parking_rounded,
        group: 'Kerja',
        color: Color(0xFF00796B)),
    TransactionCategory(
        label: 'Ongkos Kirim Dokumen Penting via JNE',
        icon: Icons.mail_rounded,
        group: 'Kerja',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Beli Map Kulit Agenda Pertemuan',
        icon: Icons.description_rounded,
        group: 'Kerja',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Iuran Kas Badminton Kantor Bulanan',
        icon: Icons.sports_soccer_rounded,
        group: 'Kerja',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Iuran Kas Futsal Kantor Mingguan',
        icon: Icons.sports_soccer_rounded,
        group: 'Kerja',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Beli Jaket Hoodie Kantor Bahan Fleece',
        icon: Icons.checkroom_rounded,
        group: 'Kerja',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Pembelian Stok, Bahan Baku & Barang',
        icon: Icons.inventory_2_rounded,
        group: 'Usaha',
        color: Color(0xFF0097A7)),
    TransactionCategory(
        label: 'Sewa Tempat Usaha & Gudang',
        icon: Icons.warehouse_rounded,
        group: 'Usaha',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Operasional Toko (Listrik/Wifi/Air)',
        icon: Icons.business_center_rounded,
        group: 'Usaha',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Marketing, Iklan Sosmed & Ads',
        icon: Icons.campaign_rounded,
        group: 'Usaha',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Biaya Platform, Admin Shopee/Tiktok',
        icon: Icons.shopping_basket_rounded,
        group: 'Usaha',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Gaji Karyawan, Bonus & Insentif Usaha',
        icon: Icons.badge_rounded,
        group: 'Usaha',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Kerugian Aset & Retur Usaha',
        icon: Icons.report_problem_rounded,
        group: 'Usaha',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Kemasan, Label, Plastik & Kardus',
        icon: Icons.local_shipping_rounded,
        group: 'Usaha',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Biaya Maintenance Website Toko / Domain',
        icon: Icons.web_rounded,
        group: 'Usaha',
        color: Color(0xFF0097A7)),
    TransactionCategory(
        label: 'Peralatan & Kardus Packing Usaha',
        icon: Icons.inventory_2_rounded,
        group: 'Usaha',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Biaya Audit Keuangan / Konsultan Pajak',
        icon: Icons.calculate_rounded,
        group: 'Usaha',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Biaya Izin Usaha / Sertifikasi Halal',
        icon: Icons.verified_user_rounded,
        group: 'Usaha',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Sponsorship & Hadiah Give-away Toko',
        icon: Icons.card_giftcard_rounded,
        group: 'Usaha',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Bunga Pinjaman Modal Usaha',
        icon: Icons.trending_up_rounded,
        group: 'Usaha',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Biaya Ekspedisi / Kirim Barang ke Gudang',
        icon: Icons.local_shipping_rounded,
        group: 'Usaha',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Jasa Endorsement / Influencer Marketing Usaha',
        icon: Icons.campaign_rounded,
        group: 'Usaha',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Cetak Sticker, Label & Hangtag Brand Usaha',
        icon: Icons.local_shipping_rounded,
        group: 'Usaha',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Biaya Pendaftaran Paten Merek Dagang / HKI',
        icon: Icons.verified_user_rounded,
        group: 'Usaha',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Ongkos Kirim Paket Pesanan ke Pelanggan (COD)',
        icon: Icons.local_shipping_rounded,
        group: 'Usaha',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Biaya Retribusi Sampah & Keamanan Lapak/Toko',
        icon: Icons.delete_rounded,
        group: 'Usaha',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Biaya Cetak Nota, Kwitansi, Stempel & Kartu Nama Bisnis',
        icon: Icons.print_rounded,
        group: 'Usaha',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Biaya Lisensi Aplikasi Kasir & POS Bulanan (Moka/Majoo)',
        icon: Icons.point_of_sale_rounded,
        group: 'Usaha',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Biaya Listrik, Air & Wifi Khusus Tempat Usaha',
        icon: Icons.bolt_rounded,
        group: 'Usaha',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Biaya Sewa Domain & Hosting Website Bisnis',
        icon: Icons.web_rounded,
        group: 'Usaha',
        color: Color(0xFF0097A7)),
    TransactionCategory(
        label: 'Pembelian Timbangan Barang & Meteran Paket',
        icon: Icons.inventory_2_rounded,
        group: 'Usaha',
        color: Color(0xFF0097A7)),
    TransactionCategory(
        label: 'Biaya Pembuatan Neon Box / Spanduk Lapak',
        icon: Icons.campaign_rounded,
        group: 'Usaha',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Biaya Langganan Domain Email Bisnis Premium',
        icon: Icons.web_rounded,
        group: 'Usaha',
        color: Color(0xFF0097A7)),
    TransactionCategory(
        label: 'Biaya Langganan Software Pembukuan (Jurnal/Accurate)',
        icon: Icons.calculate_rounded,
        group: 'Usaha',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Biaya Pembuatan Seragam Karyawan / Kaos Toko',
        icon: Icons.checkroom_rounded,
        group: 'Usaha',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Biaya Pendaftaran QRIS & Merchant Fee',
        icon: Icons.point_of_sale_rounded,
        group: 'Usaha',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Biaya Maintenance AC / Kulkas Display Toko',
        icon: Icons.handyman_rounded,
        group: 'Usaha',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Biaya Cetak Spanduk, Banner & Baliho Promo',
        icon: Icons.campaign_rounded,
        group: 'Usaha',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Beli Stok Bahan Baku Tepung Terigu',
        icon: Icons.inventory_2_rounded,
        group: 'Usaha',
        color: Color(0xFF0097A7)),
    TransactionCategory(
        label: 'Beli Stok Bahan Baku Minyak Goreng',
        icon: Icons.inventory_2_rounded,
        group: 'Usaha',
        color: Color(0xFF0097A7)),
    TransactionCategory(
        label: 'Beli Stok Bahan Baku Gula Pasir',
        icon: Icons.inventory_2_rounded,
        group: 'Usaha',
        color: Color(0xFF0097A7)),
    TransactionCategory(
        label: 'Beli Kemasan Kantong Plastik Opp Transparan',
        icon: Icons.local_shipping_rounded,
        group: 'Usaha',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Beli Kemasan Kardus Box Custom Logo',
        icon: Icons.local_shipping_rounded,
        group: 'Usaha',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Beli Bubble Wrap Packing Paket Gulungan',
        icon: Icons.inventory_2_rounded,
        group: 'Usaha',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Beli Lakban Coklat & Bening Packing',
        icon: Icons.inventory_2_rounded,
        group: 'Usaha',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Bayar Ongkos Kirim J&T Pengiriman Barang',
        icon: Icons.local_shipping_rounded,
        group: 'Usaha',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Bayar Biaya Platform Merchant Shopee Food',
        icon: Icons.shopping_basket_rounded,
        group: 'Usaha',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Bayar Biaya Platform Merchant Grab Food',
        icon: Icons.shopping_basket_rounded,
        group: 'Usaha',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Bayar Biaya Platform Merchant Go Food',
        icon: Icons.shopping_basket_rounded,
        group: 'Usaha',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Bayar Gaji Bulanan Karyawan Toko',
        icon: Icons.badge_rounded,
        group: 'Usaha',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Bayar Gaji Harian Karyawan Gudang',
        icon: Icons.badge_rounded,
        group: 'Usaha',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Bayar Bonus Target Penjualan Staf Marketing',
        icon: Icons.campaign_rounded,
        group: 'Usaha',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Sewa Tempat Lapak Jualan Kaki Lima',
        icon: Icons.warehouse_rounded,
        group: 'Usaha',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Sewa Toko / Ruko Bulanan Strategis',
        icon: Icons.warehouse_rounded,
        group: 'Usaha',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Bayar Listrik PLN Tempat Usaha Toko',
        icon: Icons.bolt_rounded,
        group: 'Usaha',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Bayar Wifi Internet Indihome Usaha',
        icon: Icons.business_center_rounded,
        group: 'Usaha',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Bayar Retribusi Sampah Pasar & Keamanan',
        icon: Icons.delete_rounded,
        group: 'Usaha',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Beli Timbangan Digital Paket 30Kg',
        icon: Icons.inventory_2_rounded,
        group: 'Usaha',
        color: Color(0xFF0097A7)),
    TransactionCategory(
        label: 'Beli Printer Thermal Bluetooth Kasir',
        icon: Icons.point_of_sale_rounded,
        group: 'Usaha',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Beli Kertas Roll Thermal Kasir',
        icon: Icons.print_rounded,
        group: 'Usaha',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Bayar Iklan Instagram Ads Promosi Toko',
        icon: Icons.campaign_rounded,
        group: 'Usaha',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Bayar Iklan Facebook Ads Promosi Produk',
        icon: Icons.campaign_rounded,
        group: 'Usaha',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Bayar Jasa Desain Logo & Banner Toko',
        icon: Icons.campaign_rounded,
        group: 'Usaha',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Bayar Jasa Endorsement Selebgram Lokal',
        icon: Icons.campaign_rounded,
        group: 'Usaha',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Bayar Pajak Usaha PPh Final 0.5%',
        icon: Icons.calculate_rounded,
        group: 'Usaha',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Bayar Biaya Izin Usaha NIB Nomer Induk',
        icon: Icons.verified_user_rounded,
        group: 'Usaha',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Langganan Netflix, Disney+, Spotify',
        icon: Icons.subscriptions_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFFE50914)),
    TransactionCategory(
        label: 'Top Up Game, Voucher & Diamond',
        icon: Icons.sports_esports_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Cloud Storage (Google One/iCloud)',
        icon: Icons.cloud_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Domain, Hosting, Server & VPS',
        icon: Icons.dns_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF5C6BC0)),
    TransactionCategory(
        label: 'Pulsa & Paket Data Seluler',
        icon: Icons.signal_cellular_alt_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF8E24AA)),
    TransactionCategory(
        label: 'Keanggotaan Premium / VIP Member',
        icon: Icons.verified_user_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Lisensi Software & Tools Kreatif (Canva/Adobe)',
        icon: Icons.brush_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Langganan Course & Kursus Online',
        icon: Icons.school_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Langganan Netflix Premium Ultra HD',
        icon: Icons.movie_filter_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFFE50914)),
    TransactionCategory(
        label: 'Langganan Disney+ Hotstar Bulanan',
        icon: Icons.play_arrow_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Langganan Amazon Prime Video & HBO',
        icon: Icons.video_library_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF0D47A1)),
    TransactionCategory(
        label: 'Langganan Spotify Premium Individual',
        icon: Icons.music_note_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF1DB954)),
    TransactionCategory(
        label: 'Langganan YouTube Premium / Music',
        icon: Icons.queue_music_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Pembelian Game PC / Steam / PlayStation Store',
        icon: Icons.sports_esports_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Langganan ChatGPT Plus / Claude Pro Personal',
        icon: Icons.chat_bubble_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Langganan Midjourney / Canva Pro Freelance',
        icon: Icons.palette_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Pembelian Domain & Hosting Website Baru',
        icon: Icons.language_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF5C6BC0)),
    TransactionCategory(
        label: 'Biaya Langganan VPS / AWS / Cloud Server',
        icon: Icons.dns_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Pembelian Aset Digital & Lisensi Font/Vektor',
        icon: Icons.cloud_download_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Top Up Saldo E-Wallet & Biaya Admin Merchant',
        icon: Icons.wallet_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF00BCD4)),
    TransactionCategory(
        label: 'Pembelian E-Book / Novel / Komik Digital',
        icon: Icons.book_online_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Langganan GitHub Copilot / Cursor AI Pro Editor',
        icon: Icons.code_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Langganan Google One Storage 2TB Bulanan',
        icon: Icons.cloud_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Langganan Adobe Creative Cloud All Apps Bulanan',
        icon: Icons.brush_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Biaya Admin Top Up GoPay / ShopeePay / DANA',
        icon: Icons.wallet_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF00BCD4)),
    TransactionCategory(
        label: 'Pembelian Tema, Font & Widget HP Estetik',
        icon: Icons.palette_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Pembelian Koin / Voucher Webtoon & Baca Novel Online',
        icon: Icons.book_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Pembelian Lisensi Font Premium & Desain Grafis',
        icon: Icons.font_download_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Langganan Hosting & Penyimpanan File Premium',
        icon: Icons.cloud_queue_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF5C6BC0)),
    TransactionCategory(
        label: 'Top Up Koin / Token Platform Chatting & Media Sosial',
        icon: Icons.monetization_on_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF8E24AA)),
    TransactionCategory(
        label: 'Langganan Penyimpanan OneDrive / Dropbox Premium',
        icon: Icons.cloud_queue_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF5C6BC0)),
    TransactionCategory(
        label: 'Beli Voucher Wifi.id / Hotspot Kampus',
        icon: Icons.wifi_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Langganan Server Game Private (Minecraft/Palworld)',
        icon: Icons.sports_esports_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Langganan Microsoft 365 Family / Personal',
        icon: Icons.description_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF5C6BC0)),
    TransactionCategory(
        label: 'Beli Koin / Token Kunci Baca Novel Premium',
        icon: Icons.book_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Langganan Google Play Pass / Apple Arcade',
        icon: Icons.sports_esports_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Biaya Transfer Antar Bank',
        icon: Icons.wallet_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF00BCD4)),
    TransactionCategory(
        label: 'Langganan Google Workspace Business Starter',
        icon: Icons.cloud_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Pembelian Template Video CapCut Pro',
        icon: Icons.movie_filter_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Langganan Lisensi Zoom Meeting Pro 100 Peserta',
        icon: Icons.videocam_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Langganan Spotify Premium Family bulanan',
        icon: Icons.music_note_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF1DB954)),
    TransactionCategory(
        label: 'Langganan Disney+ Hotstar Paket Premium',
        icon: Icons.play_arrow_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Beli Coin Webtoon Premium untuk Baca Episode Baru',
        icon: Icons.book_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Langganan iCloud Storage 50GB bulanan',
        icon: Icons.cloud_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Langganan Google One Storage 100GB bulanan',
        icon: Icons.cloud_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Pembelian Aset Font Premium di Creative Market',
        icon: Icons.font_download_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Pembelian Template Slide Keynote Mac',
        icon: Icons.slideshow_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Pembelian Domain Website .id Indonesia',
        icon: Icons.language_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF5C6BC0)),
    TransactionCategory(
        label: 'Langganan VPN Premium (NordVPN / ExpressVPN)',
        icon: Icons.vpn_key_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Top Up Saldo LinkAja / Sakuku Bank',
        icon: Icons.wallet_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF00BCD4)),
    TransactionCategory(
        label: 'Top Up Saldo E-Toll via Mobile Banking',
        icon: Icons.wallet_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF00BCD4)),
    TransactionCategory(
        label: 'Beli Voucher Google Play Store Gift Card',
        icon: Icons.card_membership_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Beli Game Nintendo Switch eShop Digital',
        icon: Icons.sports_esports_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Langganan Apple Music Individual bulanan',
        icon: Icons.music_note_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Langganan Course Coding Premium di Dicoding',
        icon: Icons.school_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Langganan Course UI/UX Design di BuildWithAngga',
        icon: Icons.school_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Langganan Canva Pro bulanan Edu/Teams',
        icon: Icons.palette_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Langganan ChatGPT Plus bulanan Personal',
        icon: Icons.chat_bubble_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Langganan Github Copilot Pro bulanan',
        icon: Icons.code_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Pembelian E-Book Panduan Investasi Saham',
        icon: Icons.book_online_rounded,
        group: 'Pengeluaran Digital',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Makanan & Minuman Harian',
        icon: Icons.restaurant_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Nongkrong, Kafe & Kuliner',
        icon: Icons.local_cafe_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Cemilan, Gorengan & Jajanan Pasar',
        icon: Icons.cookie_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Boba, Es Teh & Minuman Kekinian',
        icon: Icons.local_drink_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Delivery Makanan (GoFood/GrabFood/ShopeeFood)',
        icon: Icons.delivery_dining_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Jajanan Minimarket (Kripip & Es Krim)',
        icon: Icons.icecream_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Bakso, Seblak & Street Food Lokal',
        icon: Icons.soup_kitchen_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Dessert, Roti, Kue & Martabak',
        icon: Icons.cake_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Makan Pagi / Bubur & Nasi Uduk Sarapan',
        icon: Icons.restaurant_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Makan Malam / Seafood & Sate Kaki Lima',
        icon: Icons.dinner_dining_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Makan Mewah / Dine-in Restoran Keluarga',
        icon: Icons.restaurant_menu_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFFBF360C)),
    TransactionCategory(
        label: 'Makan Siang Prasmanan / Warteg Harian',
        icon: Icons.restaurant_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Beli Susu Kotak, Yoghurt & Minuman Kesehatan',
        icon: Icons.local_drink_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Pembelian Air Galon Mineral & Isi Ulang Bulanan',
        icon: Icons.water_drop_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Beli Buah-Buahan Segar & Salad Sehat',
        icon: Icons.apple_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Minuman Kopi Susu Botolan & Es Teh Manis',
        icon: Icons.local_cafe_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Beli Minuman Jamu Tradisional / Jamu Gendong',
        icon: Icons.local_drink_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Air Mineral Kemasan Dus untuk Tamu',
        icon: Icons.water_drop_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Makan Malam Angkringan / Nasi Kucing',
        icon: Icons.restaurant_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Beli Es Blender Sachet (Pop Ice / Jasjus)',
        icon: Icons.local_drink_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Minuman Energi & Soda (Panther / Kuku Bima)',
        icon: Icons.bolt_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Beli Wafer & Biskuit Ringan (Nabati / Roma)',
        icon: Icons.cookie_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Beli Es Kelapa Muda & Es Degan Segar',
        icon: Icons.local_drink_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Makan Siang Soto Ayam, Soto Daging & Nasi',
        icon: Icons.restaurant_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Beli Roti Bakar Bandung & Martabak Manis',
        icon: Icons.bakery_dining_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Beli Siomay, Batagor & Cilok Pinggir Jalan',
        icon: Icons.cookie_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Makan Pagi Bubur Ayam Cirebon',
        icon: Icons.restaurant_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Makan Pagi Nasi Uduk Betawi',
        icon: Icons.restaurant_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Makan Siang Prasmanan Warteg Bahari',
        icon: Icons.restaurant_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Makan Siang Soto Ayam & Nasi',
        icon: Icons.restaurant_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Makan Siang Bakso Sapi Wonogiri',
        icon: Icons.soup_kitchen_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Makan Siang Mie Ayam Ceker',
        icon: Icons.restaurant_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Makan Malam Pecel Lele Lamongan',
        icon: Icons.restaurant_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Makan Malam Nasi Goreng Jawa Gila',
        icon: Icons.restaurant_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Makan Malam Seafood Kaki Lima Kepiting',
        icon: Icons.dinner_dining_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Makan Malam Sate Ayam Madura',
        icon: Icons.restaurant_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Makan Malam Angkringan Nasi Kucing',
        icon: Icons.restaurant_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Dine In Restoran Mewah Solaria Mall',
        icon: Icons.restaurant_menu_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFFBF360C)),
    TransactionCategory(
        label: 'Dine In Restoran Keluarga Bakmi GM',
        icon: Icons.restaurant_menu_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFFBF360C)),
    TransactionCategory(
        label: 'Beli Cemilan Gorengan Tempe & Tahu',
        icon: Icons.cookie_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Beli Jajanan Pasar Kue Cucur & Pastel',
        icon: Icons.cookie_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Beli Cemilan Minimarket Keripik Chitato',
        icon: Icons.cookie_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Beli Cemilan Minimarket Es Krim Walls',
        icon: Icons.icecream_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Beli Minuman Boba Chatime Brown Sugar',
        icon: Icons.local_drink_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Minuman Es Teh Solo Kekinian',
        icon: Icons.local_drink_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Minuman Kopi Susu Aren Kenangan',
        icon: Icons.local_cafe_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Beli Minuman Susu Kotak Ultra Milk',
        icon: Icons.local_drink_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Minuman Yoghurt Cimory Squeeze',
        icon: Icons.local_drink_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Air Galon Aqua Galon Asli',
        icon: Icons.water_drop_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Beli Air Galon Refill Isi Ulang',
        icon: Icons.water_drop_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Beli Buah Buahan Segar Pisang & Apel',
        icon: Icons.apple_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Salad Buah Segar Dapur Keju',
        icon: Icons.apple_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Minuman Jamu Kunyit Asam Gendong',
        icon: Icons.local_drink_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Minuman Energi Kuku Bima Energi',
        icon: Icons.bolt_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Beli Minuman Soda Coca Cola / Fanta',
        icon: Icons.local_drink_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Biskuit Roma Kelapa Renceng',
        icon: Icons.cookie_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Beli Wafer Nabati Keju Renceng',
        icon: Icons.cookie_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Beli Roti Bakar Bandung Coklat Keju',
        icon: Icons.bakery_dining_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Beli Jajanan Siomay Batagor Kaki Lima',
        icon: Icons.cookie_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Order GrabFood Delivery Makan Siang',
        icon: Icons.delivery_dining_rounded,
        group: 'Makanan & Minuman',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Belanja Sembako & Bahan Pangan',
        icon: Icons.shopping_cart_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Laundry & Kebersihan Rumah',
        icon: Icons.dry_cleaning_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF42A5F5)),
    TransactionCategory(
        label: 'Belanja Bulanan Supermarket / Hypermarket',
        icon: Icons.local_grocery_store_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Belanja Mingguan Sayur & Lauk Pasar Tradisional',
        icon: Icons.shopping_basket_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Pembelian Sabun, Sampo, Sikat Gigi & Odol',
        icon: Icons.clean_hands_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Pembelian Deterjen, Pewangi & Sabun Cuci Piring',
        icon: Icons.dry_cleaning_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Laundry Kiloan Cuci Setrika Harian',
        icon: Icons.dry_cleaning_outlined,
        group: 'Belanja & Sembako',
        color: Color(0xFF42A5F5)),
    TransactionCategory(
        label: 'Sabun Cuci Piring, Sikat & Kain Pel Dapur',
        icon: Icons.clean_hands_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Pembelian Tisu Wajah, Tisu Toilet & Kapas Kosmetik',
        icon: Icons.clean_hands_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Kantong Sampah, Plastik Kiloan & Karet Gelang',
        icon: Icons.shopping_bag_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Belanja Beras, Minyak Goreng & Gula Bulanan',
        icon: Icons.shopping_cart_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Bumbu Dapur Instan & Rempah-Rempah Masak',
        icon: Icons.restaurant_menu_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Pembelian Garam, Saus, Kecap & Penyedap Rasa',
        icon: Icons.kitchen_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Belanja Harian di Toko Kelontong Madura 24 Jam',
        icon: Icons.storefront_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Pembelian Baterai Jam Dinding & Baterai Remote',
        icon: Icons.battery_charging_full_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Beli Bohlam Lampu Rumah & Fitting Lampu',
        icon: Icons.lightbulb_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Beli Kamper/Kapur Barus Lemari Pakaian',
        icon: Icons.clean_hands_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Pembelian Galon Kosong / Botol Air Besar Baru',
        icon: Icons.water_drop_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Beli Sabun Cuci Tangan & Hand Wash Refill',
        icon: Icons.clean_hands_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Sikat Gigi, Sikat WC & Sapu Ijuk Baru',
        icon: Icons.clean_hands_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Beli Tissue Basah Antiseptik & Hand Sanitizer',
        icon: Icons.clean_hands_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Kapur Barus Wangi & Kamper Anti Kecoak',
        icon: Icons.clean_hands_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Beras Pandan Wangi Karung 5Kg',
        icon: Icons.shopping_cart_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Beras Setra Ramos Karung 10Kg',
        icon: Icons.shopping_cart_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Minyak Goreng Filma Pouch 2L',
        icon: Icons.shopping_cart_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Minyak Goreng Bimoli Pouch 2L',
        icon: Icons.shopping_cart_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Gula Pasir Gulaku Bungkus 1Kg',
        icon: Icons.shopping_cart_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Telur Ayam Negeri Kiloan 1Kg',
        icon: Icons.shopping_cart_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Mie Instan Indomie Goreng Dus',
        icon: Icons.shopping_cart_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Sayur Sayuran Hijau Pasar Pagi',
        icon: Icons.shopping_basket_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Beli Lauk Pauk Ayam Potong Pasar',
        icon: Icons.shopping_basket_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Beli Lauk Pauk Daging Sapi Pasar',
        icon: Icons.shopping_basket_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Beli Lauk Pauk Ikan Kembung Pasar',
        icon: Icons.shopping_basket_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Beli Sabun Mandi Batang Lifebuoy',
        icon: Icons.clean_hands_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Sabun Mandi Cair Dettol Pouch',
        icon: Icons.clean_hands_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Shampo Clear Anti Dandruff Botol',
        icon: Icons.clean_hands_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Pasta Gigi Pepsodent Pencegah Gigi',
        icon: Icons.clean_hands_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Sikat Gigi Formula Double Action',
        icon: Icons.clean_hands_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Deterjen Bubuk Rinso Molto Bag',
        icon: Icons.clean_hands_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Deterjen Cair Soklin Liquid Pouch',
        icon: Icons.dry_cleaning_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Beli Pewangi Pakaian Downy Mistique',
        icon: Icons.dry_cleaning_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Beli Sabun Cuci Piring Sunlight Pouch',
        icon: Icons.clean_hands_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Beli Tisu Wajah Paseo Softpack 250s',
        icon: Icons.clean_hands_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Tisu Toilet Paseo Roll 4s',
        icon: Icons.clean_hands_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Kapas Kecantikan Sariayu Bag',
        icon: Icons.clean_hands_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Kantong Sampah Plastik Hitam',
        icon: Icons.shopping_bag_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Beli Karet Gelang & Kantong Plastik',
        icon: Icons.shopping_bag_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Beli Bumbu Dapur Racik Sayur Asem',
        icon: Icons.restaurant_menu_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Bumbu Rempah Jahe Kunyit Pasar',
        icon: Icons.restaurant_menu_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Garam Dapur Beriodium Kapal',
        icon: Icons.restaurant_menu_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Saus Sambal ABC Botol Asli',
        icon: Icons.restaurant_menu_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Kecap Manis Bango Botol Sedang',
        icon: Icons.restaurant_menu_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Penyedap Rasa Royco Sachet',
        icon: Icons.restaurant_menu_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beli Baterai Alkaline AA Isi 4',
        icon: Icons.battery_charging_full_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Beli Baterai ABC Carbon AAA Isi 4',
        icon: Icons.battery_charging_full_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Beli Bohlam Lampu LED Philips 10W',
        icon: Icons.lightbulb_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Beli Fitting Lampu Gantung Broco',
        icon: Icons.lightbulb_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Beli Kamper Bagus Anti Kecoak Lemari',
        icon: Icons.clean_hands_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Pengharum Lemari Glade Hanger',
        icon: Icons.clean_hands_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Sikat Cuci Piring & Kain Lap',
        icon: Icons.clean_hands_rounded,
        group: 'Belanja & Sembako',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Listrik, Air & Gas LPG',
        icon: Icons.electric_bolt_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Sewa / Kos / KPR',
        icon: Icons.house_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Peralatan & Perbaikan Rumah',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Internet & TV Kabel Rumah',
        icon: Icons.live_tv_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Beli Air Minum Galon / Isi Ulang & Gas',
        icon: Icons.water_drop_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Biaya Token Listrik PLN & Tagihan Bulanan',
        icon: Icons.electric_bolt_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Tagihan Air PDAM & Iuran Keamanan Perumahan',
        icon: Icons.water_damage_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF0097A7)),
    TransactionCategory(
        label: 'Servis AC Rumah & Tambah Freon Berkala',
        icon: Icons.ac_unit_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Iuran RT/RW & Kebersihan Komplek',
        icon: Icons.groups_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Iuran Pengelolaan Lingkungan (IPL) & Kebersihan Komplek',
        icon: Icons.groups_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Biaya Maintenance Pompa Air & Filter Air Bersih',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Biaya Servis Genset / Emergency Power Cadangan',
        icon: Icons.bolt_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Iuran TV Berlangganan & Streaming Keluarga',
        icon: Icons.live_tv_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Iuran Air Bersih Swadaya Warga',
        icon: Icons.water_drop_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Biaya Sedot Lumpur / Saluran Got Tersumbat',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Iuran Bulanan Kas RT / Dana Sosial Warga',
        icon: Icons.groups_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Biaya Servis Kunci Pintu Rumah & Duplikat Kunci',
        icon: Icons.vpn_key_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Biaya Perbaikan Genteng Bocor / Waterproofing',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Iuran Kas Keamanan Malam Kompleks (Siskamling)',
        icon: Icons.security_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Bayar Token Listrik PLN Pra Bayar',
        icon: Icons.electric_bolt_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Bayar Tagihan Listrik PLN Pasca Bayar',
        icon: Icons.electric_bolt_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Bayar Tagihan Air PDAM Perumahan',
        icon: Icons.water_damage_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF0097A7)),
    TransactionCategory(
        label: 'Bayar Iuran RT bulanan Keamanan',
        icon: Icons.groups_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Bayar Iuran RT bulanan Sampah',
        icon: Icons.groups_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Bayar Iuran Pengelolaan Lingkungan IPL',
        icon: Icons.groups_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Bayar Internet Wifi Indihome Bulanan',
        icon: Icons.live_tv_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Bayar Internet Wifi Biznet Bulanan',
        icon: Icons.live_tv_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Bayar Internet Wifi First Media',
        icon: Icons.live_tv_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Bayar TV Kabel Transvision Bulanan',
        icon: Icons.live_tv_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Servis AC Rumah Cuci AC Berkala',
        icon: Icons.ac_unit_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Isi Ulang Freon AC Rumah Bocor',
        icon: Icons.ac_unit_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Servis Pompa Air Sanyo Mati Total',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Ganti Filter Air Bersih Rumah Tangga',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Servis Genset Rumah Tangga Cadangan',
        icon: Icons.bolt_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Iuran TV Berlangganan Netflix Family',
        icon: Icons.live_tv_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Iuran TV Berlangganan Disney Premium',
        icon: Icons.live_tv_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Bayar Sedot WC WC Penuh Panggilan',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Bayar Servis Pintu Pagar Besi Macet',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Duplikat Kunci Pintu Rumah Utama',
        icon: Icons.vpn_key_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Bayar Perbaikan Genteng Rumah Bocor',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Bayar Cat Ulang Dinding Rumah Luar',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Bayar Iuran Keamanan Malam Siskamling',
        icon: Icons.security_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Bayar Iuran Kas Warga Komplek Sosial',
        icon: Icons.groups_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Bayar Tagihan Gas Alam PGN bulanan',
        icon: Icons.electric_bolt_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Beli Tabung Gas Elpiji Pertamina 12Kg',
        icon: Icons.water_drop_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Beli Tabung Gas Bright Gas 5.5Kg',
        icon: Icons.water_drop_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Bayar Biaya Sedot Lumpur Got Rumah',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Bayar Biaya Tebas Rumput Liar Taman',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Bayar Biaya Pangkas Dahan Pohon Depan',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Bayar Perbaikan Pompa Pendorong Air',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Bayar Perbaikan Keran Air Wastafel Bocor',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Bayar Perbaikan Saluran Pembuangan Mampet',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Bayar Perbaikan Saklar Lampu Rusak',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Bayar Perbaikan Sekring Listrik Rumah',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Bayar Perbaikan Pintu Kamar Mandi',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Bayar Perbaikan Engsel Jendela Rusak',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Bayar Perbaikan Atap Plafon Rumah Jebol',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Bayar Perbaikan Tangki Air Toren Bocor',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Bayar Biaya Pasang Penangkal Petir',
        icon: Icons.handyman_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Bayar Iuran Kebersihan Warga RT RW',
        icon: Icons.groups_rounded,
        group: 'Tagihan & Utilitas',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Belanja Fashion & Aksesoris',
        icon: Icons.shopping_bag_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Hobi, Koleksi & Action Figure',
        icon: Icons.palette_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Traveling, Liburan & Camping',
        icon: Icons.luggage_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF0277BD)),
    TransactionCategory(
        label: 'Gym, Fitness & Olahraga',
        icon: Icons.fitness_center_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Salon, Kosmetik & Skincare',
        icon: Icons.face_retouching_natural_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Konser, Bioskop & Event',
        icon: Icons.confirmation_number_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF9C27B0)),
    TransactionCategory(
        label: 'Pakaian Casual, Kaos, Celana & Jaket Baru',
        icon: Icons.checkroom_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Sepatu Sneakers, Sandal & Tas Real Life',
        icon: Icons.shopping_bag_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFFAD1457)),
    TransactionCategory(
        label: 'Potong Rambut / Barbershop & Hair Treatment',
        icon: Icons.content_cut_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Skincare Harian, Sunscreen & Serum Wajah',
        icon: Icons.face_retouching_natural_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Tiket Bioskop XXI / CGV Premier Weekend',
        icon: Icons.movie_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF9C27B0)),
    TransactionCategory(
        label: 'Tiket Konser Musik / Festival & Exhibition',
        icon: Icons.confirmation_number_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Koleksi Buku Fisik / Novel & Manga Populer',
        icon: Icons.book_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Tanaman Hias, Pupuk & Peralatan Kebun',
        icon: Icons.yard_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF558B2F)),
    TransactionCategory(
        label: 'Sewa Lapangan Badminton / Futsal & Alat',
        icon: Icons.sports_tennis_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Iuran Bulanan Gym / Fitness Center Club',
        icon: Icons.fitness_center_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Staycation Hotel / Villa & Tiket Wisata',
        icon: Icons.hotel_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Tiket Masuk Kolam Renang, Waterboom & Wahana Air',
        icon: Icons.local_play_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF9C27B0)),
    TransactionCategory(
        label: 'Beli Kosmetik, Make-up & Skincare Daily',
        icon: Icons.face_retouching_natural_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Gantungan Kunci Lucu, Stiker & Pernak-pernik Hobi',
        icon: Icons.palette_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Beli Lilin Aromaterapi & Pengharum Ruangan',
        icon: Icons.spa_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Biaya Sewa Studio Foto & Cetak Album Polaroid',
        icon: Icons.image_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Tiket Nonton Bioskop & Jajan Popcorn',
        icon: Icons.confirmation_number_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF9C27B0)),
    TransactionCategory(
        label: 'Beli Rokok, Tembakau & Korek Api',
        icon: Icons.smoking_rooms_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Beli Pewangi Mobil & Aksesoris Dashboard',
        icon: Icons.palette_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Tiket Masuk Kebun Binatang & Taman Kota',
        icon: Icons.local_play_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF9C27B0)),
    TransactionCategory(
        label: 'Beli Hiasan Dinding & Frame Foto Pajangan',
        icon: Icons.image_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Pewangi Kopi / Parfum Gantungan Mobil',
        icon: Icons.spa_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Tiket Masuk Wahana Kebun Binatang & Taman Satwa',
        icon: Icons.local_play_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF9C27B0)),
    TransactionCategory(
        label: 'Beli Frame Foto, Pigura & Hiasan Dinding',
        icon: Icons.image_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Action Figure, Gundam & Mainan Koleksi',
        icon: Icons.toys_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Tiket Nonton Konser Musik Indie & Standup Comedy',
        icon: Icons.confirmation_number_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF9C27B0)),
    TransactionCategory(
        label: 'Beli Tiket Nonton Bioskop XXI Premier',
        icon: Icons.movie_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF9C27B0)),
    TransactionCategory(
        label: 'Beli Jajan Popcorn & Soda Bioskop',
        icon: Icons.confirmation_number_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF9C27B0)),
    TransactionCategory(
        label: 'Beli Tiket Konser Musik Indie Lokal',
        icon: Icons.confirmation_number_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Beli Tiket Stand Up Comedy Show',
        icon: Icons.confirmation_number_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF9C27B0)),
    TransactionCategory(
        label: 'Beli Action Figure Gundam Bandai',
        icon: Icons.toys_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Beli Buku Novel Terjemahan Gramedia',
        icon: Icons.book_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Beli Komik Manga Jepang Gramedia',
        icon: Icons.book_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Beli Tanaman Hias Aglonema & Pot Gantung',
        icon: Icons.yard_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF558B2F)),
    TransactionCategory(
        label: 'Beli Pupuk Organik & Obat Tanaman Hias',
        icon: Icons.yard_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF558B2F)),
    TransactionCategory(
        label: 'Bayar Iuran Bulanan Member Gym / Fitness',
        icon: Icons.fitness_center_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Sewa Lapangan Badminton bulanan Warga',
        icon: Icons.sports_tennis_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Sewa Lapangan Futsal Akhir Pekan',
        icon: Icons.sports_tennis_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Staycation Hotel Bintang 3 Malam Minggu',
        icon: Icons.hotel_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Staycation Villa Puncak Akhir Pekan',
        icon: Icons.hotel_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Beli Tiket Masuk Kebun Binatang Ragunan',
        icon: Icons.local_play_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF9C27B0)),
    TransactionCategory(
        label: 'Beli Tiket Masuk Taman Mini Indonesia',
        icon: Icons.local_play_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF9C27B0)),
    TransactionCategory(
        label: 'Beli Tiket Masuk Ancol / Dufan Jakarta',
        icon: Icons.local_play_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF9C27B0)),
    TransactionCategory(
        label: 'Potong Rambut di Barbershop Modern',
        icon: Icons.content_cut_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Perawatan Rambut Cream Bath di Salon',
        icon: Icons.face_retouching_natural_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Skincare Sunscreen Wardah Daily',
        icon: Icons.face_retouching_natural_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Skincare Serum Somethinc Daily',
        icon: Icons.face_retouching_natural_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Kosmetik Lipcream Maybelline',
        icon: Icons.face_retouching_natural_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Gantungan Kunci Anime Jepang',
        icon: Icons.palette_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Beli Lilin Aromaterapi Wangi Lavender',
        icon: Icons.spa_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Beli Pewangi Mobil Parfum Kopi Bali',
        icon: Icons.spa_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Beli Hiasan Bingkai Foto Dinding',
        icon: Icons.image_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Rokok Sampoerna Mild / Gudang Garam',
        icon: Icons.smoking_rooms_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Beli Korek Api Gas Tokai Eceran',
        icon: Icons.smoking_rooms_rounded,
        group: 'Gaya Hidup & Hiburan',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Bahan Bakar (BBM)',
        icon: Icons.local_gas_station_rounded,
        group: 'Transportasi',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Ojek Online & Taksi',
        icon: Icons.moped_rounded,
        group: 'Transportasi',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Servis, Cuci & Oli Kendaraan',
        icon: Icons.build_rounded,
        group: 'Transportasi',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Tiket Kereta, Pesawat & Bus',
        icon: Icons.train_rounded,
        group: 'Transportasi',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Parkir, Tol & Denda E-TLE',
        icon: Icons.local_parking_rounded,
        group: 'Transportasi',
        color: Color(0xFFF4511E)),
    TransactionCategory(
        label: 'Top Up E-Money & Tiket Tol',
        icon: Icons.toll_rounded,
        group: 'Transportasi',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Bensin Motor / Pertalite Harian Commute',
        icon: Icons.moped_rounded,
        group: 'Transportasi',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Bensin Mobil / Pertamax / Shell Perjalanan',
        icon: Icons.directions_car_rounded,
        group: 'Transportasi',
        color: Color(0xFFD84315)),
    TransactionCategory(
        label: 'Sewa Parkir Harian / Bulanan Gedung & Mall',
        icon: Icons.local_parking_rounded,
        group: 'Transportasi',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Tarif Tol Trans Jawa / Dalam Kota Tap E-Toll',
        icon: Icons.toll_rounded,
        group: 'Transportasi',
        color: Color(0xFFFF9800)),
    TransactionCategory(
        label: 'Tiket Ojek Online (GoRide/GrabRide) Kerja',
        icon: Icons.directions_run_rounded,
        group: 'Transportasi',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Tiket Taksi Online (GoCar/GrabCar) Bandara',
        icon: Icons.local_taxi_rounded,
        group: 'Transportasi',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Servis Ringan Motor / Ganti Oli Rutin',
        icon: Icons.build_rounded,
        group: 'Transportasi',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Biaya Uji Emisi & Kir Kendaraan Bermotor',
        icon: Icons.build_rounded,
        group: 'Transportasi',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Sewa Sepeda Listrik / Skuter Harian di Area Wisata',
        icon: Icons.electric_moped_rounded,
        group: 'Transportasi',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Biaya Parkir Valet & Tip Driver Valet',
        icon: Icons.toll_rounded,
        group: 'Transportasi',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Denda Tilang Lalu Lintas & Biaya Sidang',
        icon: Icons.gavel_rounded,
        group: 'Transportasi',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Biaya Derek & Evakuasi Darurat Kendaraan',
        icon: Icons.local_shipping_rounded,
        group: 'Transportasi',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Uang Tips Kenek & Jasa Bongkar Muat Barang',
        icon: Icons.toll_rounded,
        group: 'Transportasi',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Uang Tiket Penyeberangan Kapal Feri Merak-Bakauheni',
        icon: Icons.directions_boat_rounded,
        group: 'Transportasi',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Sewa Jas Hujan Eceran saat Terjebak Hujan',
        icon: Icons.umbrella_rounded,
        group: 'Transportasi',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Uang Tips Driver Travel & Jasa Angkut Barang',
        icon: Icons.toll_rounded,
        group: 'Transportasi',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Biaya Tambal Ban Tubeless & Isi Nitrogen Ban',
        icon: Icons.build_rounded,
        group: 'Transportasi',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Biaya Cuci Steam Salju Motor / Mobil',
        icon: Icons.build_rounded,
        group: 'Transportasi',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Bayar Ojek Online GoRide Kerja',
        icon: Icons.directions_run_rounded,
        group: 'Transportasi',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Bayar Taksi Online GoCar Perjalanan',
        icon: Icons.local_taxi_rounded,
        group: 'Transportasi',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Bayar Ojek Online GrabRide Kerja',
        icon: Icons.directions_run_rounded,
        group: 'Transportasi',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Bayar Taksi Online GrabCar Bandara',
        icon: Icons.local_taxi_rounded,
        group: 'Transportasi',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Tiket KRL Commuter Line Jabodetabek',
        icon: Icons.train_rounded,
        group: 'Transportasi',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Tiket MRT Jakarta Bundaran HI',
        icon: Icons.train_rounded,
        group: 'Transportasi',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Tiket LRT Jakarta Kelapa Gading',
        icon: Icons.train_rounded,
        group: 'Transportasi',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Tiket Bus Transjakarta Busway Harian',
        icon: Icons.directions_bus_rounded,
        group: 'Transportasi',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Tiket Bus Antar Kota Damri Lampung',
        icon: Icons.directions_bus_rounded,
        group: 'Transportasi',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Tiket Kereta Api Eksekutif Argo Bromo',
        icon: Icons.train_rounded,
        group: 'Transportasi',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Tiket Pesawat Garuda Jakarta Bali',
        icon: Icons.train_rounded,
        group: 'Transportasi',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Servis Ringan Motor Matic Honda Beat',
        icon: Icons.build_rounded,
        group: 'Transportasi',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Ganti Oli Mesin Motor Shell Advance',
        icon: Icons.build_rounded,
        group: 'Transportasi',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Servis Besar Mobil Toyota Avanza',
        icon: Icons.build_rounded,
        group: 'Transportasi',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Ganti Oli Mesin Mobil Castrol Magnatec',
        icon: Icons.build_rounded,
        group: 'Transportasi',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Cuci Steam Salju Motor Berkala',
        icon: Icons.build_rounded,
        group: 'Transportasi',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Cuci Steam Salju Mobil Berkala',
        icon: Icons.build_rounded,
        group: 'Transportasi',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Top Up E-Money Mandiri Mandiri Toll',
        icon: Icons.toll_rounded,
        group: 'Transportasi',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Top Up Flazz BCA Perjalanan KRL',
        icon: Icons.toll_rounded,
        group: 'Transportasi',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Bayar Tol Trans Jawa Tap E-Toll',
        icon: Icons.toll_rounded,
        group: 'Transportasi',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Bayar Tol Dalam Kota Tap E-Toll',
        icon: Icons.toll_rounded,
        group: 'Transportasi',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Bayar Parkir Harian Motor Mall',
        icon: Icons.local_parking_rounded,
        group: 'Transportasi',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Bayar Parkir Harian Mobil Kantor',
        icon: Icons.local_parking_rounded,
        group: 'Transportasi',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Bayar Parkir Valet Mall Akhir Pekan',
        icon: Icons.toll_rounded,
        group: 'Transportasi',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Bayar Denda Tilang Lalu Lintas Polisi',
        icon: Icons.gavel_rounded,
        group: 'Transportasi',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Bayar Denda E-TLE Tilang Elektronik',
        icon: Icons.gavel_rounded,
        group: 'Transportasi',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Bayar Biaya Uji Emisi Kendaraan',
        icon: Icons.build_rounded,
        group: 'Transportasi',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Bayar Biaya Kir Uji Kendaraan Truk',
        icon: Icons.build_rounded,
        group: 'Transportasi',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Sewa Sepeda Listrik Beam Area Wisata',
        icon: Icons.electric_moped_rounded,
        group: 'Transportasi',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Sewa Skuter Listrik GrabWheels Wisata',
        icon: Icons.electric_moped_rounded,
        group: 'Transportasi',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Beli Jas Hujan Plastik Sekali Pakai',
        icon: Icons.umbrella_rounded,
        group: 'Transportasi',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Beli Jas Hujan Setelan Karet Axio',
        icon: Icons.umbrella_rounded,
        group: 'Transportasi',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Tips Tukang Parkir Liar Minimarket',
        icon: Icons.toll_rounded,
        group: 'Transportasi',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Beli Wiper Kaca Mobil Baru',
        icon: Icons.build_rounded,
        group: 'Transportasi',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Bayar Jasa Sopir Harian Mudik Lebaran',
        icon: Icons.directions_car_rounded,
        group: 'Transportasi',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Tiket Penyeberangan Kapal Feri Merak Eksekutif',
        icon: Icons.directions_boat_rounded,
        group: 'Transportasi',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Hewan Peliharaan',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Makanan Kucing / Anjing & Pasir Pet Grooming',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Obat Kutu, Obat Cacing & Salep Jamur Hewan',
        icon: Icons.medication_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Serokan Pasir & Tempat Buang Air Kucing',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Pembelian Mainan Gigit & Tali Tuntun Hewan',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Shampoo & Sabun Khusus Hewan Bulu',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Jasa Pemakaman & Kremasi Hewan Peliharaan',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Jasa Pacak / Perkawinan Hewan Peliharaan',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Susu Khusus Anak Kucing / Anak Anjing',
        icon: Icons.local_drink_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Biaya Sisir & Sikat Bulu Hewan',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Jasa Kawin / Pacak Kucing & Anjing Peliharaan',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Susu Khusus Anak Kucing & Puppy Wet Food',
        icon: Icons.local_drink_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Biaya Sisir Bulu, Gunting Kuku & Grooming Kucing',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Pembelian Obat Cacing & Obat Kutu Hewan Berkala',
        icon: Icons.medication_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Pasir Kucing Wangi / Cat Litter Refill',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Dry Food Kucing Whiskas Bag 1Kg',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Wet Food Kucing Whiskas Can 400g',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Dry Food Anjing Royal Canin Bag',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Pasir Kucing Wangi Bentonite 10L',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Pasir Kucing Gumpal Clumping 5L',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Obat Kutu Kucing Revolution Tube',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Obat Cacing Kucing Drontal Tablet',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Salep Jamur Kulit Hewan Scabies',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Serokan Pasir Kucing Plastik',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Bak Pasir Tempat Buang Air Kucing',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Tali Tuntun Harness Anjing Medium',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Mainan Gigit Anjing Bahan Karet',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Shampo Kucing Anti Kutu Dettol',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Sabun Mandi Anjing Wangi Fresh',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Jasa Pemakaman Kucing Mati Klinik',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Jasa Kremasi Anjing Mati Layanan',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Jasa Pacak Perkawinan Kucing Anggora',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Jasa Pacak Perkawinan Anjing Pomeranian',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Susu Formula Anak Kucing Kitten',
        icon: Icons.local_drink_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Susu Formula Anak Anjing Puppy',
        icon: Icons.local_drink_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Wet Food Anak Kucing Royal Canin',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Wet Food Anak Anjing Pedigree Can',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Grooming Kucing Mandi Sehat Petshop',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Grooming Anjing Mandi Kutu Petshop',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Sisir Bulu Kucing Kawat Halus',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Gunting Kuku Kucing & Anjing',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Vitamin Bulu Kucing Fish Oil',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Vitamin Nafsu Makan Hewan Nutriplus',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Biaya Dokter Hewan Klinik Cat & Dog',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Biaya Vaksinasi Kucing F3 Tricat',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Biaya Vaksinasi Anjing Rabies Berkala',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Biaya Sterilisasi Kebiri Kucing Jantan',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Biaya Sterilisasi Ovario Kucing Betina',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Kandang Besi Lipat Kucing Size L',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Pet Cargo Tas Gendong Kucing',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Tempat Makan & Minum Gantung',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Botol Minum Jepit Anjing Kandang',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Snack Kucing Temptations Bag',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Snack Anjing JerHigh Stick Bag',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Catnip Mainan Kucing Mabuk',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Scratch Post Garukan Kuku Kucing',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Baju Kucing Karakter Lucu Size S',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Beli Kalung Kucing Bell Lonceng Kecil',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Tips Groomer Mandi Hewan Peliharaan',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Biaya Rawat Inap Kucing Sakit Klinik',
        icon: Icons.pets_rounded,
        group: 'Hewan Peliharaan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Dokter, Klinik & Rumah Sakit',
        icon: Icons.local_hospital_rounded,
        group: 'Kesehatan',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Obat, Vitamin & Suplemen',
        icon: Icons.medication_rounded,
        group: 'Kesehatan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'BPJS & Asuransi Kesehatan',
        icon: Icons.admin_panel_settings_rounded,
        group: 'Kesehatan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Optik & Kacamata',
        icon: Icons.visibility_rounded,
        group: 'Kesehatan',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Dental & Perawatan Gigi',
        icon: Icons.local_hospital_rounded,
        group: 'Kesehatan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Cek Kesehatan & Lab',
        icon: Icons.biotech_rounded,
        group: 'Kesehatan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Biaya Tes Darah & Rontgen Lab',
        icon: Icons.biotech_rounded,
        group: 'Kesehatan',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Scaling & Pembersihan Karang Gigi',
        icon: Icons.face_retouching_natural_rounded,
        group: 'Kesehatan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Pembelian Masker, Handsanitizer & P3K',
        icon: Icons.medical_services_rounded,
        group: 'Kesehatan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Konseling Psikolog / Terapi Kesehatan',
        icon: Icons.psychology_rounded,
        group: 'Kesehatan',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Pembelian Kacamata Minus / Softlens',
        icon: Icons.remove_red_eye_rounded,
        group: 'Kesehatan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Sewa Alat Medis (Tabung Oksigen/dll)',
        icon: Icons.home_repair_service_rounded,
        group: 'Kesehatan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Pasang Behel / Tambal Gigi Estetis Klinik Gigi',
        icon: Icons.face_rounded,
        group: 'Kesehatan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Biaya Swab Test Antigen / PCR Berkala',
        icon: Icons.biotech_rounded,
        group: 'Kesehatan',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Pembelian Termometer / Alat Tensi Darah Digital',
        icon: Icons.medical_services_rounded,
        group: 'Kesehatan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Konseling Kesehatan Mental Platform Online (Halodoc/dll)',
        icon: Icons.psychology_rounded,
        group: 'Kesehatan',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Sewa Kursi Roda / Tempat Tidur Medis Harian',
        icon: Icons.home_repair_service_rounded,
        group: 'Kesehatan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Biaya Fisioterapi / Pijat Terapi Pasca Cedera',
        icon: Icons.self_improvement_rounded,
        group: 'Kesehatan',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Biaya Cabut Gigi & Tambal Gigi Berlubang',
        icon: Icons.face_rounded,
        group: 'Kesehatan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Pembelian Cairan Softlens, Tetes Mata & Tempat Lensa',
        icon: Icons.visibility_rounded,
        group: 'Kesehatan',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Pembelian Obat P3K & Perban Luka Ringan',
        icon: Icons.medication_rounded,
        group: 'Kesehatan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Biaya Cek Asam Urat, Kolesterol & Gula Darah',
        icon: Icons.biotech_rounded,
        group: 'Kesehatan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Pembelian Masker Medis & Hand Sanitizer Daily',
        icon: Icons.clean_hands_rounded,
        group: 'Kesehatan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Pembelian Obat Gosok, Salep & Plester Hangat',
        icon: Icons.medication_rounded,
        group: 'Kesehatan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Pembelian Tisu Wajah Antiseptik & Alkohol Medis',
        icon: Icons.clean_hands_rounded,
        group: 'Kesehatan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Pembelian Obat Gosok, Salep Hangat & Salonpas',
        icon: Icons.medication_rounded,
        group: 'Kesehatan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Pembelian Obat Flu, Batuk & Demam Eceran',
        icon: Icons.medication_rounded,
        group: 'Kesehatan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Biaya Konsultasi Dokter Umum Klinik Swasta',
        icon: Icons.favorite_rounded,
        group: 'Kesehatan',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Biaya Pembelian Masker Medis 3-Ply & KN95',
        icon: Icons.clean_hands_rounded,
        group: 'Kesehatan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Biaya Dokter Umum Klinik Pratama',
        icon: Icons.local_hospital_rounded,
        group: 'Kesehatan',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Biaya Dokter Gigi Tambal Gigi',
        icon: Icons.local_hospital_rounded,
        group: 'Kesehatan',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Biaya Dokter Gigi Cabut Gigi',
        icon: Icons.local_hospital_rounded,
        group: 'Kesehatan',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Biaya Dokter Spesialis Anak Konsultasi',
        icon: Icons.local_hospital_rounded,
        group: 'Kesehatan',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Beli Obat Flu, Batuk & Demam Apotik',
        icon: Icons.medication_rounded,
        group: 'Kesehatan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Obat Antibiotik & Resep Dokter',
        icon: Icons.medication_rounded,
        group: 'Kesehatan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Vitamin C & Suplemen Daya Tahan',
        icon: Icons.medication_rounded,
        group: 'Kesehatan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Minyak Gosok Kayu Putih Cap Lang',
        icon: Icons.medication_rounded,
        group: 'Kesehatan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Salep Obat Gatal & Jamur Kulit',
        icon: Icons.medication_rounded,
        group: 'Kesehatan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Plester Luka Hansaplast Kertas',
        icon: Icons.medication_rounded,
        group: 'Kesehatan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Kasa Steril, Betadine & Alkohol',
        icon: Icons.medication_rounded,
        group: 'Kesehatan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Masker Medis 3-Ply Sensi Box',
        icon: Icons.medical_services_rounded,
        group: 'Kesehatan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Beli Hand Sanitizer Dettol Botol',
        icon: Icons.clean_hands_rounded,
        group: 'Kesehatan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Bayar Iuran Bulanan BPJS Kesehatan Kelas 1',
        icon: Icons.admin_panel_settings_rounded,
        group: 'Kesehatan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Bayar Iuran Bulanan BPJS Kesehatan Kelas 2',
        icon: Icons.admin_panel_settings_rounded,
        group: 'Kesehatan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Bayar Iuran Bulanan BPJS Kesehatan Kelas 3',
        icon: Icons.admin_panel_settings_rounded,
        group: 'Kesehatan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Bayar Asuransi Kesehatan Tambahan Kantor',
        icon: Icons.admin_panel_settings_rounded,
        group: 'Kesehatan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Biaya Cek Asam Urat & Kolesterol Apotek',
        icon: Icons.biotech_rounded,
        group: 'Kesehatan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Biaya Cek Gula Darah Rutin Apotek',
        icon: Icons.biotech_rounded,
        group: 'Kesehatan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Biaya Tes Swab Antigen Mandiri',
        icon: Icons.biotech_rounded,
        group: 'Kesehatan',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Biaya Cek Laboratorium Darah Lengkap',
        icon: Icons.biotech_rounded,
        group: 'Kesehatan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Biaya Rontgen Dada Lab Radiologi',
        icon: Icons.biotech_rounded,
        group: 'Kesehatan',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Fisioterapi Pasca Cedera Otot',
        icon: Icons.self_improvement_rounded,
        group: 'Kesehatan',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Bayar Konseling Psikolog Klinis Personal',
        icon: Icons.psychology_rounded,
        group: 'Kesehatan',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Biaya scaling gigi di klinik dental',
        icon: Icons.face_rounded,
        group: 'Kesehatan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Beli Kacamata Minus Baru Optik Melawai',
        icon: Icons.visibility_rounded,
        group: 'Kesehatan',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Beli Softlens bulanan & Cairan Pencuci',
        icon: Icons.remove_red_eye_rounded,
        group: 'Kesehatan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Sewa Tabung Oksigen Medis Harian',
        icon: Icons.home_repair_service_rounded,
        group: 'Kesehatan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Sewa Kursi Roda Lipat Harian Pasien',
        icon: Icons.home_repair_service_rounded,
        group: 'Kesehatan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Sewa Kasur Medis Rumah Harian',
        icon: Icons.home_repair_service_rounded,
        group: 'Kesehatan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Beli Termometer Digital & Tensimeter Omron',
        icon: Icons.medical_services_rounded,
        group: 'Kesehatan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Biaya Admin Bank & Pemeliharaan Rekening',
        icon: Icons.account_balance_rounded,
        group: 'Keuangan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Cicilan & Alokasi Investasi',
        icon: Icons.trending_up_rounded,
        group: 'Keuangan',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Asuransi Jiwa & Unit Link',
        icon: Icons.verified_user_rounded,
        group: 'Keuangan',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Pajak Pribadi & KPR',
        icon: Icons.request_quote_rounded,
        group: 'Keuangan',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Top Up E-Wallet',
        icon: Icons.account_balance_wallet_rounded,
        group: 'Keuangan',
        color: Color(0xFF00BCD4)),
    TransactionCategory(
        label: 'Denda, Penalti & Bunga',
        icon: Icons.report_problem_rounded,
        group: 'Keuangan',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Biaya Penalti Pembayaran Terlambat',
        icon: Icons.report_problem_rounded,
        group: 'Keuangan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Biaya Admin E-Wallet / Top Up Merchant',
        icon: Icons.wallet_rounded,
        group: 'Keuangan',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Investasi Saham & Pasar Modal',
        icon: Icons.trending_up_rounded,
        group: 'Keuangan',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Investasi Emas Batangan / Logam Mulia',
        icon: Icons.diamond_rounded,
        group: 'Keuangan',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Cicilan Kredit Tanpa Agunan (KTA)',
        icon: Icons.credit_card_rounded,
        group: 'Keuangan',
        color: Color(0xFF00BCD4)),
    TransactionCategory(
        label: 'Biaya Pialang / Fee Transaksi Sekuritas',
        icon: Icons.receipt_long_rounded,
        group: 'Keuangan',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Alokasi Reksa Dana Pasar Uang Bulanan',
        icon: Icons.trending_up_rounded,
        group: 'Keuangan',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Iuran Asuransi Jiwa Murni Non-Investasi',
        icon: Icons.verified_user_rounded,
        group: 'Keuangan',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Pajak Surat Tanda Nomor Kendaraan (STNK) Tahunan',
        icon: Icons.request_quote_rounded,
        group: 'Keuangan',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Denda Keterlambatan Pembayaran Tagihan Kartu Kredit',
        icon: Icons.report_problem_rounded,
        group: 'Keuangan',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Fee Beli / Jual Aset Kripto di Exchange',
        icon: Icons.receipt_long_rounded,
        group: 'Keuangan',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Tabungan Emas Digital Pegadaian / Tokopedia',
        icon: Icons.diamond_rounded,
        group: 'Keuangan',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Cicilan Layanan SPayLater / GoPayLater Bulanan',
        icon: Icons.wallet_rounded,
        group: 'Keuangan',
        color: Color(0xFF00BCD4)),
    TransactionCategory(
        label: 'Biaya Admin Penarikan Tunai E-Wallet di ATM',
        icon: Icons.wallet_rounded,
        group: 'Keuangan',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Pembayaran Pajak Bumi & Bangunan (PBB) Rumah Tinggal',
        icon: Icons.request_quote_rounded,
        group: 'Keuangan',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Pembayaran Pajak Kendaraan Bermotor (STNK) Tahunan',
        icon: Icons.request_quote_rounded,
        group: 'Keuangan',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Pembelian Materai Tempel & Bea Meterai Fisik',
        icon: Icons.assignment_turned_in_rounded,
        group: 'Keuangan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Biaya Fee Transaksi & Komisi Aplikasi Investasi',
        icon: Icons.receipt_long_rounded,
        group: 'Keuangan',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Biaya Denda Telat Bayar Pajak / Sanksi Administrasi',
        icon: Icons.report_problem_rounded,
        group: 'Keuangan',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Biaya Pembuatan NPWP & Konsultasi SPT Tahunan',
        icon: Icons.assignment_turned_in_rounded,
        group: 'Keuangan',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Biaya Admin Cicilan Kredivo / Akulaku / Shopee',
        icon: Icons.credit_card_rounded,
        group: 'Keuangan',
        color: Color(0xFF00BCD4)),
    TransactionCategory(
        label: 'Biaya Konsultasi & Pengurusan SPT Tahunan / NPWP',
        icon: Icons.assignment_turned_in_rounded,
        group: 'Keuangan',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Biaya Bunga & Admin Cicilan Paylater Shopee/Kredivo',
        icon: Icons.credit_card_rounded,
        group: 'Keuangan',
        color: Color(0xFF00BCD4)),
    TransactionCategory(
        label: 'Biaya Pembelian Meterai Fisik Tempel (Rp 10.000)',
        icon: Icons.assignment_turned_in_rounded,
        group: 'Keuangan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Bayar Pajak Bumi & Bangunan PBB',
        icon: Icons.request_quote_rounded,
        group: 'Keuangan',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Bayar Pajak Kendaraan Motor STNK',
        icon: Icons.request_quote_rounded,
        group: 'Keuangan',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Bayar Pajak Kendaraan Mobil STNK',
        icon: Icons.request_quote_rounded,
        group: 'Keuangan',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Bayar Biaya Admin Bank Mandiri Bulanan',
        icon: Icons.account_balance_rounded,
        group: 'Keuangan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Bayar Biaya Admin Bank BCA Bulanan',
        icon: Icons.account_balance_rounded,
        group: 'Keuangan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Bayar Biaya Admin Bank BRI Bulanan',
        icon: Icons.account_balance_rounded,
        group: 'Keuangan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Bayar Biaya Transfer Antar Bank Swasta',
        icon: Icons.account_balance_rounded,
        group: 'Keuangan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Bayar Biaya Admin Top Up E-Wallet DANA',
        icon: Icons.wallet_rounded,
        group: 'Keuangan',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Bayar Biaya Admin Top Up GoPay',
        icon: Icons.wallet_rounded,
        group: 'Keuangan',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Bayar Biaya Admin Top Up ShopeePay',
        icon: Icons.wallet_rounded,
        group: 'Keuangan',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Beli Emas Logam Mulia Antam Pecahan 1Gram',
        icon: Icons.diamond_rounded,
        group: 'Keuangan',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Top Up Tabungan Emas Pegadaian Digital',
        icon: Icons.diamond_rounded,
        group: 'Keuangan',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Beli Saham Bluechip Sektor Perbankan',
        icon: Icons.trending_up_rounded,
        group: 'Keuangan',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Beli Saham Bluechip Sektor Telekomunikasi',
        icon: Icons.trending_up_rounded,
        group: 'Keuangan',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Alokasi Investasi Reksadana Pasar Uang Bibit',
        icon: Icons.trending_up_rounded,
        group: 'Keuangan',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Alokasi Investasi Reksadana Saham Bibit',
        icon: Icons.trending_up_rounded,
        group: 'Keuangan',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Alokasi Investasi Obligasi Negara ORI/SBR',
        icon: Icons.workspace_premium_rounded,
        group: 'Keuangan',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Bayar Cicilan Kredit Tanpa Agunan KTA',
        icon: Icons.credit_card_rounded,
        group: 'Keuangan',
        color: Color(0xFF00BCD4)),
    TransactionCategory(
        label: 'Bayar Cicilan Kredit Pemilikan Rumah KPR',
        icon: Icons.house_rounded,
        group: 'Keuangan',
        color: Color(0xFF00BCD4)),
    TransactionCategory(
        label: 'Bayar Cicilan Shopee Paylater Bulanan',
        icon: Icons.wallet_rounded,
        group: 'Keuangan',
        color: Color(0xFF00BCD4)),
    TransactionCategory(
        label: 'Bayar Cicilan Kredivo bulanan Belanja',
        icon: Icons.credit_card_rounded,
        group: 'Keuangan',
        color: Color(0xFF00BCD4)),
    TransactionCategory(
        label: 'Bayar Cicilan Akulaku bulanan Belanja',
        icon: Icons.credit_card_rounded,
        group: 'Keuangan',
        color: Color(0xFF00BCD4)),
    TransactionCategory(
        label: 'Bayar Denda Telat Bayar Pajak Kendaraan',
        icon: Icons.report_problem_rounded,
        group: 'Keuangan',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Denda Telat Bayar Tagihan Listrik',
        icon: Icons.report_problem_rounded,
        group: 'Keuangan',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Denda Telat Bayar Kartu Kredit',
        icon: Icons.report_problem_rounded,
        group: 'Keuangan',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Biaya Admin Penarikan Tunai ATM Bersama',
        icon: Icons.account_balance_rounded,
        group: 'Keuangan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Bayar Premi Asuransi Kesehatan BPJS bulanan',
        icon: Icons.verified_user_rounded,
        group: 'Keuangan',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Bayar Premi Asuransi Kesehatan Swasta Allianz',
        icon: Icons.verified_user_rounded,
        group: 'Keuangan',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Bayar Premi Asuransi Kesehatan Swasta Prudential',
        icon: Icons.verified_user_rounded,
        group: 'Keuangan',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Bayar Premi Asuransi Jiwa Unit Link',
        icon: Icons.verified_user_rounded,
        group: 'Keuangan',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Kondangan / Amplop Nikahan Teman & Saudara',
        icon: Icons.celebration_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Kotak Amal, Sedekah & Zakat Masjid',
        icon: Icons.volunteer_activism_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Kas Karang Taruna & Kegiatan Pemuda Komplek',
        icon: Icons.groups_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Sewa Perlengkapan Hajatan (Tenda, Sound & Kursi)',
        icon: Icons.groups_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Pembelian Hewan Kurban & Biaya Penyaluran Daging',
        icon: Icons.mosque_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Iuran Dana Kematian & Santunan Warga',
        icon: Icons.volunteer_activism_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Sumbangan Pembangunan Sarana Ibadah Komplek',
        icon: Icons.mosque_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Iuran Kegiatan 17 Agustus & Hari Kemerdekaan',
        icon: Icons.groups_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Sumbangan Pembangunan Pos Ronda Kompleks',
        icon: Icons.groups_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Sumbangan Panti Jompo & Lansia',
        icon: Icons.volunteer_activism_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Dana Takziah & Karangan Bunga Papan Duka',
        icon: Icons.card_giftcard_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Donasi Sosial Panti Asuhan & Yayasan Lansia',
        icon: Icons.volunteer_activism_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Iuran Bulanan Arisan Keluarga / Arisan RT',
        icon: Icons.groups_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Zakat, Infak & Sedekah',
        icon: Icons.spa_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Qurban & Aqiqah',
        icon: Icons.mosque_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Iuran Pemakaman Komplek / Rukun Kematian',
        icon: Icons.domain_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Sedekah Anak Yatim & Panti Asuhan',
        icon: Icons.volunteer_activism_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Sumbangan Pembangunan Masjid / Rumah Ibadah',
        icon: Icons.mosque_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Donasi Bencana Alam & Kemanusiaan',
        icon: Icons.favorite_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Sedekah Jumat Berkah & Nasi Kotak',
        icon: Icons.restaurant_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Pembayaran Zakat Fitrah H-1 Idul Fitri',
        icon: Icons.spa_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Santunan Yatim Piatu Rutin Bulanan',
        icon: Icons.volunteer_activism_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Donasi Aksi Sosial Peduli Palestina / Global',
        icon: Icons.favorite_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Iuran Sukarela Pembangunan Fasum RT',
        icon: Icons.groups_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Kado Pernikahan Sahabat Karat / Hampers Wedding',
        icon: Icons.card_giftcard_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Wakaf Tanah / Bahan Bangunan Masjid Baru',
        icon: Icons.mosque_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Tabungan Qurban Kambing Tahunan',
        icon: Icons.mosque_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Iuran Kas Kematian Rukun Tetangga (RT)',
        icon: Icons.domain_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bantuan Dana Sosial untuk Tetangga Sakit / Kena Musibah',
        icon: Icons.volunteer_activism_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Bayar Zakat Fitrah Menjelang Lebaran',
        icon: Icons.spa_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Bayar Zakat Mal Pendapatan Bulanan',
        icon: Icons.spa_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Sedekah Anak Yatim Panti Asuhan',
        icon: Icons.volunteer_activism_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Sedekah Masjid Kotak Amal Jumat',
        icon: Icons.volunteer_activism_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Sumbangan Pembangunan Rumah Ibadah',
        icon: Icons.mosque_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Donasi Bencana Alam Gempa / Banjir',
        icon: Icons.favorite_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Sumbangan Sosial Warga Sakit / Duka',
        icon: Icons.volunteer_activism_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Iuran Rukun Kematian Kompleks Perumahan',
        icon: Icons.domain_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Iuran Kas Paguyuban RT Bulanan',
        icon: Icons.groups_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Iuran Kegiatan HUT RI 17 Agustus Komplek',
        icon: Icons.groups_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Patungan Qurban Sapi Patungan 7 Orang',
        icon: Icons.mosque_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Beli Kambing Qurban Idul Adha Standar',
        icon: Icons.mosque_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Kado Pernikahan Amplop Kondangan Teman',
        icon: Icons.card_giftcard_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Kado Pernikahan Hampers Wedding Sahabat',
        icon: Icons.card_giftcard_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Sewa Tenda & Sound System Hajatan',
        icon: Icons.groups_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Sumbangan Panti Jompo Lansia Terlantar',
        icon: Icons.volunteer_activism_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Sedekah Jumat Berkah Nasi Kotak Masjid',
        icon: Icons.restaurant_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Sumbangan Sosial Peduli Kemanusiaan Global',
        icon: Icons.favorite_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Iuran Pemakaman Warga Kompleks',
        icon: Icons.domain_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Wakaf Al-Quran untuk TPA/TPQ Masjid',
        icon: Icons.mosque_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Wakaf Sajadah & Karpet Sholat Masjid',
        icon: Icons.mosque_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Sumbangan Renovasi Gapura Komplek RT',
        icon: Icons.groups_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Iuran Kas Keamanan Malam Komplek RT',
        icon: Icons.groups_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Kado Syukuran Rumah Baru Tetangga',
        icon: Icons.card_giftcard_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Kado Melahirkan Anak Tetangga Baru',
        icon: Icons.card_giftcard_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Sumbangan Acara Khitanan Anak Saudara',
        icon: Icons.card_giftcard_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Bantuan Sembako untuk Korban Kebakaran',
        icon: Icons.volunteer_activism_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Iuran Bulanan Arisan RT Komplek Ibu',
        icon: Icons.groups_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Zakat Profesi Potongan Gaji Bulanan',
        icon: Icons.spa_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Donasi Kampanye Kemanusiaan Kitabisa',
        icon: Icons.favorite_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Sumbangan Karangan Bunga Duka Cita',
        icon: Icons.card_giftcard_rounded,
        group: 'Sosial & Ibadah',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Susu Formula & Kebutuhan Bayi',
        icon: Icons.child_friendly_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Hadiah Ulang Tahun / Kado untuk Teman',
        icon: Icons.card_giftcard_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFFF5722)),
    TransactionCategory(
        label: 'Uang Saku Anak Sekolah',
        icon: Icons.child_care_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFFBC02D)),
    TransactionCategory(
        label: 'Uang Belanja Bulanan Istri & Rumah Tangga',
        icon: Icons.savings_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Uang Saku Pengasuh Anak (Babysitter) / ART Harian',
        icon: Icons.payments_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Pembelian Kasur Bayi, Kelambu & Bantal Anti Peyang',
        icon: Icons.child_friendly_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Biaya Les Renang & Olahraga Anak',
        icon: Icons.sports_soccer_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFAFB42B)),
    TransactionCategory(
        label: 'Biaya Sewa Mainan Anak / Playground Bulanan',
        icon: Icons.toys_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFAFB42B)),
    TransactionCategory(
        label: 'Pembelian Buku Cerita Bergambar & Dongeng Anak',
        icon: Icons.book_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFAFB42B)),
    TransactionCategory(
        label: 'Mainan & Edukasi Anak',
        icon: Icons.toys_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFAFB42B)),
    TransactionCategory(
        label: 'Sewa Kolam Pompa & Pompa Anak',
        icon: Icons.child_care_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFFBC02D)),
    TransactionCategory(
        label: 'Perlengkapan Mandi & Perawatan Kulit Bayi',
        icon: Icons.clean_hands_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Kaos Kaki, Sepatu Lucu & Sandal Bayi',
        icon: Icons.checkroom_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Pendidikan & Mainan Anak',
        icon: Icons.toys_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFAFB42B)),
    TransactionCategory(
        label: 'Kirim Orang Tua & Keluarga',
        icon: Icons.volunteer_activism_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Kado & Hadiah Keluarga',
        icon: Icons.card_giftcard_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Perayaan & Syukuran Keluarga',
        icon: Icons.celebration_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFAD1457)),
    TransactionCategory(
        label: 'Pembelian Diapers / Popok Bayi Harian',
        icon: Icons.child_friendly_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFAFB42B)),
    TransactionCategory(
        label: 'Baju & Sepatu Anak Baru',
        icon: Icons.checkroom_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Iuran Kelas Ibu & Anak / Senam Hamil',
        icon: Icons.favorite_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Pembelian Bubur Tim & Snack Bayi Harian',
        icon: Icons.baby_changing_station_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFFBC02D)),
    TransactionCategory(
        label: 'Pembelian Tisu Basah & Tisu Kering Bayi Bundling',
        icon: Icons.clean_hands_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFAD1457)),
    TransactionCategory(
        label: 'Uang Belanja Harian Bahan Lauk Pauk Dapur',
        icon: Icons.wallet_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Kirim Paket Sembako Bulanan untuk Orang Tua',
        icon: Icons.volunteer_activism_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Biaya Konsultasi Dokter Anak Spesialis Rutin',
        icon: Icons.favorite_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Pembelian Minyak Telon & Bedak Bayi Rutin',
        icon: Icons.clean_hands_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFAD1457)),
    TransactionCategory(
        label: 'Biaya Kado Syukuran Khitanan Anak Saudara',
        icon: Icons.card_giftcard_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Beli Susu Formula SGM / Chil Kid',
        icon: Icons.child_friendly_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Susu Formula Morinaga / Pediasure',
        icon: Icons.child_friendly_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Makanan Pendamping ASI MPASI Bayi',
        icon: Icons.child_friendly_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Bubur Bayi Instan Cerelac',
        icon: Icons.baby_changing_station_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFFBC02D)),
    TransactionCategory(
        label: 'Beli Diapers Pampers MamyPoko Pants Bag',
        icon: Icons.child_friendly_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Diapers Baby Happy Pants Bag',
        icon: Icons.child_friendly_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Tisu Basah Bayi Cussons Baby',
        icon: Icons.clean_hands_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFAD1457)),
    TransactionCategory(
        label: 'Beli Tisu Kering Bayi Paseo Baby',
        icon: Icons.clean_hands_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFAD1457)),
    TransactionCategory(
        label: 'Beli Sabun & Shampo Bayi Zwitsal',
        icon: Icons.clean_hands_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFAD1457)),
    TransactionCategory(
        label: 'Beli Minyak Telon Konicare Botol',
        icon: Icons.clean_hands_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFAD1457)),
    TransactionCategory(
        label: 'Beli Bedak Bayi My Baby Botol',
        icon: Icons.clean_hands_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFAD1457)),
    TransactionCategory(
        label: 'Beli Pakaian Bayi Baju Kodok Baru',
        icon: Icons.checkroom_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Beli Sepatu Bayi Lucu Bunyi Cit',
        icon: Icons.shopping_bag_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Mainan Edukasi Bayi Rattle',
        icon: Icons.toys_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFAFB42B)),
    TransactionCategory(
        label: 'Beli Buku Cerita Dongeng Bergambar Anak',
        icon: Icons.book_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFAFB42B)),
    TransactionCategory(
        label: 'Bayar Uang Jajan Anak Sekolah Harian',
        icon: Icons.child_care_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFFBC02D)),
    TransactionCategory(
        label: 'Bayar Uang Belanja Ijalan Dapur',
        icon: Icons.wallet_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Bayar Uang Belanja Istri Bulanan Rumah',
        icon: Icons.savings_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Bayar Gaji Pengasuh Anak Babysitter',
        icon: Icons.payments_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Bayar Gaji ART Asisten Rumah Tangga',
        icon: Icons.payments_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Sewa Kolam Pompa Anak & Pompa Listrik',
        icon: Icons.child_care_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFFBC02D)),
    TransactionCategory(
        label: 'Sewa Mainan Anak Playground Bulanan',
        icon: Icons.toys_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFAFB42B)),
    TransactionCategory(
        label: 'Kirim Uang Bulanan Orang Tua Kampung',
        icon: Icons.volunteer_activism_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Kirim Paket Sembako Bulanan Orang Tua',
        icon: Icons.volunteer_activism_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Kado Ulang Tahun Anak Mainan Mobil',
        icon: Icons.toys_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFAFB42B)),
    TransactionCategory(
        label: 'Kado Syukuran Khitanan Anak Saudara',
        icon: Icons.card_giftcard_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Iuran Kelas Ibu & Anak Puskesmas',
        icon: Icons.favorite_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Iuran Senam Hamil Ibu Hamil',
        icon: Icons.favorite_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Beli Kasur Bayi & Kelambu Nyamuk',
        icon: Icons.child_friendly_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Stroller Kereta Dorong Bayi',
        icon: Icons.child_friendly_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Beli Car Seat Kursi Mobil Bayi',
        icon: Icons.child_friendly_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Biaya Les Renang Anak Harian',
        icon: Icons.sports_soccer_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFFAFB42B)),
    TransactionCategory(
        label: 'Biaya Les Menggambar Mewarnai Anak',
        icon: Icons.brush_rounded,
        group: 'Anak & Keluarga',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Belanja Online / Minimarket',
        icon: Icons.shopping_bag_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Dana Darurat & Tak Terduga',
        icon: Icons.warning_amber_rounded,
        group: 'Lainnya',
        color: Color(0xFFF57C00)),
    TransactionCategory(
        label: 'Kehilangan & Musibah',
        icon: Icons.heart_broken_rounded,
        group: 'Lainnya',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Biaya Pindahan & Pemakaman',
        icon: Icons.local_shipping_rounded,
        group: 'Lainnya',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Biaya Pengurusan Surat / KTP / SIM',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Ganti Rugi Kerusakan Barang Orang Lain',
        icon: Icons.handyman_rounded,
        group: 'Lainnya',
        color: Color(0xFFF57C00)),
    TransactionCategory(
        label: 'Biaya Materai & Legalisir Dokumen',
        icon: Icons.assignment_turned_in_rounded,
        group: 'Lainnya',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Biaya Tips Driver / Kurir / Juru Parkir',
        icon: Icons.moped_rounded,
        group: 'Lainnya',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Kategori Lain',
        icon: Icons.more_horiz_rounded,
        group: 'Lainnya',
        color: Color(0xFF9E9E9E)),
    TransactionCategory(
        label: 'Dana Darurat Musibah Kebanjiran Rumah',
        icon: Icons.warning_amber_rounded,
        group: 'Lainnya',
        color: Color(0xFFF57C00)),
    TransactionCategory(
        label: 'Dana Darurat Perbaikan HP Masuk Air',
        icon: Icons.warning_amber_rounded,
        group: 'Lainnya',
        color: Color(0xFFF57C00)),
    TransactionCategory(
        label: 'Dana Darurat Kehilangan Dompet Jalan',
        icon: Icons.warning_amber_rounded,
        group: 'Lainnya',
        color: Color(0xFFF57C00)),
    TransactionCategory(
        label: 'Dana Darurat Santunan Duka Cita Warga',
        icon: Icons.warning_amber_rounded,
        group: 'Lainnya',
        color: Color(0xFFF57C00)),
    TransactionCategory(
        label: 'Biaya Pindahan Kost Angkut Barang',
        icon: Icons.local_shipping_rounded,
        group: 'Lainnya',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Biaya Sewa Truk Box Pindahan Rumah',
        icon: Icons.local_shipping_rounded,
        group: 'Lainnya',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Biaya Pengurusan E-KTP Baru Rusak',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Biaya Pembuatan Kartu Keluarga Baru',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Biaya Perpanjangan SIM A Drive Thru',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Biaya Perpanjangan SIM C Drive Thru',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Biaya Perpanjangan STNK Kendaraan',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Biaya Ganti Plat Nomor Kendaraan 5Thn',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Ganti Rugi Pecah Gelas Cafe Orang',
        icon: Icons.handyman_rounded,
        group: 'Lainnya',
        color: Color(0xFFF57C00)),
    TransactionCategory(
        label: 'Ganti Rugi Nabrak Pagar Tetangga',
        icon: Icons.handyman_rounded,
        group: 'Lainnya',
        color: Color(0xFFF57C00)),
    TransactionCategory(
        label: 'Ganti Rugi Rusak Buku Pinjam Teman',
        icon: Icons.handyman_rounded,
        group: 'Lainnya',
        color: Color(0xFFF57C00)),
    TransactionCategory(
        label: 'Biaya Pembelian Materai Tempel 10000',
        icon: Icons.assignment_turned_in_rounded,
        group: 'Lainnya',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Biaya Legalisir Dokumen Ijazah Kampus',
        icon: Icons.assignment_turned_in_rounded,
        group: 'Lainnya',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Biaya Legalisir Transkrip Nilai Sekolah',
        icon: Icons.assignment_turned_in_rounded,
        group: 'Lainnya',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Tips Supir Grab Kirim Paket Express',
        icon: Icons.moped_rounded,
        group: 'Lainnya',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Tips Kurir Shopee Antar Paket Cepat',
        icon: Icons.moped_rounded,
        group: 'Lainnya',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Tips Tukang Parkir Minimarket Alfamart',
        icon: Icons.moped_rounded,
        group: 'Lainnya',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Tips Supir Angkot Ongkos Sisa',
        icon: Icons.moped_rounded,
        group: 'Lainnya',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Pengeluaran Mendadak Tidak Terencana',
        icon: Icons.more_horiz_rounded,
        group: 'Lainnya',
        color: Color(0xFF9E9E9E)),
    TransactionCategory(
        label: 'Biaya Materai Tempel Lembar Dokumen',
        icon: Icons.assignment_turned_in_rounded,
        group: 'Lainnya',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Biaya Pembuatan Paspor Baru Kantor Imigrasi',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Biaya Pembuatan Visa Kunjungan Wisata',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Biaya Notaris Pengurusan Dokumen Tanah',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Biaya Pembuatan Akta Kelahiran Baru',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Biaya Pembuatan Akta Kematian Keluarga',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Biaya Fotocopy Berkas KTP Legal',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Biaya Kirim Surat Pos Indonesia Kilat',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Biaya Kirim Paket JNE Reguler Paket',
        icon: Icons.local_shipping_rounded,
        group: 'Lainnya',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Biaya Kirim Paket J&T Express Paket',
        icon: Icons.local_shipping_rounded,
        group: 'Lainnya',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Biaya Kirim Paket Sicepat Halu Paket',
        icon: Icons.local_shipping_rounded,
        group: 'Lainnya',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Uang Keamanan Hansip Bulanan Perumahan',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Tips Porter Bandara Soekarno Hatta',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Tips Porter Stasiun Gambir Jakarta',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Tips Supir Taksi Uang Kembalian Sisa',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Tips Driver GoCar Uang Kembalian Sisa',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Tips Driver GrabCar Uang Kembalian Sisa',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Tips Kurir Tokopedia GoSend Instant',
        icon: Icons.moped_rounded,
        group: 'Lainnya',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Tips Kurir GrabExpress Instant Antar',
        icon: Icons.moped_rounded,
        group: 'Lainnya',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Bayar Kerusakan Sewa Kamera Lensa',
        icon: Icons.handyman_rounded,
        group: 'Lainnya',
        color: Color(0xFFF57C00)),
    TransactionCategory(
        label: 'Bayar Kerusakan Sewa PS5 Joystick',
        icon: Icons.handyman_rounded,
        group: 'Lainnya',
        color: Color(0xFFF57C00)),
    TransactionCategory(
        label: 'Bayar Denda Telat Balikin Buku Perpus',
        icon: Icons.handyman_rounded,
        group: 'Lainnya',
        color: Color(0xFFF57C00)),
    TransactionCategory(
        label: 'Bayar Denda Telat Balikin DVD Film',
        icon: Icons.handyman_rounded,
        group: 'Lainnya',
        color: Color(0xFFF57C00)),
    TransactionCategory(
        label: 'Beli Payung Lipat Darurat Hujan Jalan',
        icon: Icons.umbrella_rounded,
        group: 'Lainnya',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Beli Jas Hujan Plastik Darurat Hujan',
        icon: Icons.umbrella_rounded,
        group: 'Lainnya',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Beli Kipas Angin Genggam Charger Portable',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Beli Powerbank Darurat HP Lowbat',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Beli Senter Kecil Emergency Mati Lampu',
        icon: Icons.description_rounded,
        group: 'Lainnya',
        color: Color(0xFFFF6D00)),
    TransactionCategory(
        label: 'Hutang',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Teman Kuliah Pinjaman',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Teman Kantor Pinjaman',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Keluarga Dekat Pinjaman',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Cicilan Hutang Bank BCA',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Cicilan Hutang Bank Mandiri',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Cicilan Hutang Bank BRI',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Cicilan Hutang Pinjol OJK',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Cicilan Hutang Paylater Tokopedia',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Cicilan Hutang Paylater Shopee',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Cicilan Hutang Paylater Kredivo',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Cicilan Hutang Paylater Akulaku',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Berikan Pinjaman Uang Teman Kuliah',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Berikan Pinjaman Uang Teman Kerja',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Berikan Pinjaman Uang Keluarga Dekat',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Berikan Pinjaman Uang Tetangga Rumah',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Kartu Kredit Bank BCA',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Kartu Kredit Bank Mandiri',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Kartu Kredit Bank BNI',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Kartu Kredit Bank BRI',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Kartu Kredit Bank HSBC',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Kartu Kredit Bank Mega',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Kartu Kredit Bank CIMB',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Kartu Kredit Bank Citibank',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Cicilan Kredit Pemilikan Rumah',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Cicilan Kredit Kendaraan Motor',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Cicilan Kredit Kendaraan Mobil',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Berikan Pinjaman Uang Sahabat Dekat',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Berikan Pinjaman Uang Rekan Bisnis',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Pembelian Barang Dagang',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Biaya Sewa Ruko Toko',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Laptop Kerja',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan HP Kerja',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Kamera Kerja',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Mesin Usaha',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Motor Usaha',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Mobil Usaha',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Tanah Usaha',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Bangunan Usaha',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Peralatan Kantor',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Furnitur Kantor',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan AC Kantor',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Listrik Kantor',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Wifi Kantor',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Air Kantor',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Sampah Kantor',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Pajak Kantor',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Izin Kantor',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Notaris Kantor',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Audit Kantor',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Konsultan Kantor',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Pengacara Kantor',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Asuransi Kantor',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Bank Swasta',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Bank BUMN',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Bank Syariah',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Bank Digital',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Koperasi Karyawan',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Koperasi Warga',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bayar Hutang Cicilan Pinjaman Lunak',
        icon: Icons.call_made_rounded,
        group: 'Hutang & Piutang',
        color: Color(0xFFD32F2F)),
  ];

  static const List<TransactionCategory> incomeCategories = [
    TransactionCategory(
        label: 'Gaji Pokok & Upah',
        icon: Icons.payments_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Bonus, Insentif & Komisi',
        icon: Icons.stars_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFFFFA000)),
    TransactionCategory(
        label: 'Uang Lembur / Overtime',
        icon: Icons.more_time_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'THR & Tunjangan Raya',
        icon: Icons.celebration_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFFFBC02D)),
    TransactionCategory(
        label: 'Tunjangan Transport & Makan',
        icon: Icons.directions_car_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Tunjangan Kesehatan & Medis',
        icon: Icons.health_and_safety_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Gaji Magang / Internship',
        icon: Icons.badge_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Reimbursement Kantor',
        icon: Icons.receipt_long_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Pesangon & Pensiun',
        icon: Icons.elderly_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Honorarium / Uang Lelah',
        icon: Icons.workspace_premium_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFFFFA000)),
    TransactionCategory(
        label: 'Gaji Ke-13 & Rapelan',
        icon: Icons.payments_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Tunjangan Jabatan & Struktural',
        icon: Icons.military_tech_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Tunjangan Keluarga & Anak',
        icon: Icons.family_restroom_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Tunjangan Perumahan & Kost',
        icon: Icons.home_work_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF00796B)),
    TransactionCategory(
        label: 'Tunjangan Pulsa, Internet & Listrik',
        icon: Icons.settings_cell_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Uang Harian Dinas & Perjalanan Dinas',
        icon: Icons.card_travel_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFFF57C00)),
    TransactionCategory(
        label: 'Bonus Kinerja & Akhir Tahun',
        icon: Icons.workspace_premium_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Tunjangan Kehadiran / Uang Presensi',
        icon: Icons.co_present_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Komisi Penjualan Marketing',
        icon: Icons.monetization_on_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Tunjangan Hari Tua (THT) / JHT BPJS',
        icon: Icons.elderly_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Uang Representasi / Uang Saku Rapat',
        icon: Icons.co_present_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Upah Harian Lepas',
        icon: Icons.payments_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Insentif Karyawan Terbaik',
        icon: Icons.emoji_events_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFFFFA000)),
    TransactionCategory(
        label: 'Insentif Referral Rekrutmen (Employee Referral)',
        icon: Icons.group_add_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Pemberian THR Keagamaan (Idul Fitri/Natal/Imlek/Nyepi)',
        icon: Icons.celebration_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFFFBC02D)),
    TransactionCategory(
        label: 'Bonus Tahunan & Retensi Karyawan',
        icon: Icons.stars_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFFFFA000)),
    TransactionCategory(
        label: 'Tunjangan Hari Raya Keagamaan Khusus',
        icon: Icons.church_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Uang Makan Harian & Uang Transport Lembur',
        icon: Icons.local_dining_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Insentif KPI Bulanan / Target Kuartal',
        icon: Icons.speed_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Gaji Pengajar / Dosen Luar Biasa / Dosen Tamu',
        icon: Icons.school_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Uang Saku Magang BUMN (FHCI)',
        icon: Icons.badge_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Gaji Kontrak Swasta Harian',
        icon: Icons.payments_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Gaji Pegawai Negeri Sipil (PNS)',
        icon: Icons.assured_workload_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Gaji PPPK (Pegawai Pemerintah Perjanjian Kerja)',
        icon: Icons.badge_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Tunjangan Kinerja Daerah (TKD) PNS',
        icon: Icons.account_balance_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Insentif Proyek Internal Kantor',
        icon: Icons.construction_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Pembayaran Klaim Cuti Tahunan (Leave Cashout)',
        icon: Icons.event_available_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Uang Duka Wafat Anggota Keluarga Kantor',
        icon: Icons.volunteer_activism_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Tunjangan Kemahalan / Penempatan Daerah Terpencil',
        icon: Icons.public_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFFF57C00)),
    TransactionCategory(
        label: 'Rapelan Kenaikan Pangkat Gaji',
        icon: Icons.trending_up_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Bonus Loyalitas Masa Kerja (Service Award)',
        icon: Icons.workspace_premium_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Tunjangan Anak / Beasiswa Anak dari Kantor',
        icon: Icons.school_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Insentif Lembur Akhir Pekan (Weekend Overtime)',
        icon: Icons.more_time_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Gaji Guru Honorer Sekolah Swasta',
        icon: Icons.school_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Gaji Karyawan Toko / Retail Bulanan',
        icon: Icons.storefront_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Uang Saku Pelatihan Kerja BLK',
        icon: Icons.badge_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Gaji Security / Satpam Komplek Perumahan',
        icon: Icons.security_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Gaji Cleaning Service Kantor Swasta',
        icon: Icons.clean_hands_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Gaji Barista Coffee Shop Paruh Waktu',
        icon: Icons.coffee_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Gaji Kasir Minimarket Shift Malam',
        icon: Icons.point_of_sale_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Gaji Staf Administrasi Kantor Bulanan',
        icon: Icons.assignment_ind_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Gaji Customer Service Call Center',
        icon: Icons.support_agent_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Gaji Resepsionis Hotel / Kantor',
        icon: Icons.room_service_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Gaji Operator Mesin Pabrik Industri',
        icon: Icons.precision_manufacturing_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Gaji Kurir Logistik Internal Kantor',
        icon: Icons.local_shipping_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Gaji Driver Operasional Direksi',
        icon: Icons.directions_car_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Gaji Helper Gudang & Bongkar Muat',
        icon: Icons.inventory_2_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Gaji Staf Gudang / Inventory Control',
        icon: Icons.warehouse_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Gaji Sales Lapangan (Door to Door)',
        icon: Icons.campaign_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Gaji SPG / SPB Event Pameran Mall',
        icon: Icons.stars_rounded,
        group: 'Pekerjaan & Gaji',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Penjualan Produk (Toko/E-Commerce)',
        icon: Icons.storefront_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF00796B)),
    TransactionCategory(
        label: 'Penjualan Jasa / Servis / Konsultasi',
        icon: Icons.support_agent_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF00695C)),
    TransactionCategory(
        label: 'Omzet Jasa Titip (Jastip)',
        icon: Icons.shopping_bag_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Hasil Penjualan Franchise',
        icon: Icons.storefront_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Hasil Ekspor Produk',
        icon: Icons.public_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF2196F3)),
    TransactionCategory(
        label: 'Hasil Kemitraan & Kerja Sama B2B',
        icon: Icons.handshake_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF3949AB)),
    TransactionCategory(
        label: 'Penjualan Grosir / Partai Besar',
        icon: Icons.local_shipping_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF0097A7)),
    TransactionCategory(
        label: 'Penjualan Eceran / Retail Toko',
        icon: Icons.storefront_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF00796B)),
    TransactionCategory(
        label: 'Penjualan Dropship & Reseller',
        icon: Icons.shopping_bag_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Hasil Penjualan Bazaar, Event & Festival',
        icon: Icons.celebration_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Pendapatan Waralaba / Franchise Royalty',
        icon: Icons.business_center_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Keuntungan Konsinyasi Barang',
        icon: Icons.assignment_turned_in_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Penjualan Lisensi Produk & Hak Cipta',
        icon: Icons.copyright_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Hasil Penjualan Custom Order / PO',
        icon: Icons.add_shopping_cart_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFFF9800)),
    TransactionCategory(
        label: 'Penjualan Paket Hampers & Souvenir',
        icon: Icons.card_giftcard_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Pendapatan Catering / Pesanan Makanan',
        icon: Icons.restaurant_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Hasil Penjualan Barang Bekas / Garage Sale',
        icon: Icons.sell_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Komisi Agen Properti / Makelar Tanah',
        icon: Icons.home_work_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF00796B)),
    TransactionCategory(
        label: 'Komisi Makelar Kendaraan (Mobil/Motor)',
        icon: Icons.directions_car_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFD84315)),
    TransactionCategory(
        label: 'Pendapatan Kemitraan UMKM / Profit Sharing',
        icon: Icons.handshake_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF3949AB)),
    TransactionCategory(
        label: 'Hasil Penjualan Camilan & Makanan Ringan Rumahan',
        icon: Icons.bakery_dining_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Komisi Reseller Pulsa & Token Listrik',
        icon: Icons.bolt_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Hasil Kebun Hidroponik & Penjualan Sayur Organik',
        icon: Icons.yard_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Hasil Penjualan Pakaian & Fashion Thrifting',
        icon: Icons.checkroom_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Hasil Penjualan Sepatu & Sneakers Original/Preloved',
        icon: Icons.shopping_bag_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFAD1457)),
    TransactionCategory(
        label: 'Pendapatan Warung Kelontong / Toko Sembako',
        icon: Icons.storefront_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF00796B)),
    TransactionCategory(
        label: 'Hasil Penjualan Kosmetik & Skincare',
        icon: Icons.face_retouching_natural_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Hasil Penjualan Furniture & Dekorasi Rumah',
        icon: Icons.chair_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Hasil Penjualan Hewan Qurban (Sapi/Kambing)',
        icon: Icons.pets_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Hasil Penjualan Toko Mainan / Hobi',
        icon: Icons.storefront_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Penjualan Hijab & Busana Muslimah',
        icon: Icons.checkroom_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Pendapatan Agen BRILink / Agen Pos',
        icon: Icons.assured_workload_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Penjualan Mainan Anak & Diecast',
        icon: Icons.toys_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFAFB42B)),
    TransactionCategory(
        label: 'Penjualan Tas Wanita & Dompet Lokal',
        icon: Icons.shopping_bag_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFAD1457)),
    TransactionCategory(
        label: 'Penjualan Obat-obatan / Herbal & Jamu',
        icon: Icons.science_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Penjualan Aksesoris Gadget & Casing HP',
        icon: Icons.phone_android_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF00BCD4)),
    TransactionCategory(
        label: 'Hasil Penjualan Tanaman Hias & Bibit Bunga',
        icon: Icons.yard_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Penjualan Alat Tulis & Perlengkapan Kantor (ATK)',
        icon: Icons.edit_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Hasil Penjualan Buku Bekas & Novel',
        icon: Icons.menu_book_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Penjualan Sparepart Motor / Mobil',
        icon: Icons.settings_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Omzet Warung Kopi / Angkringan',
        icon: Icons.local_cafe_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Hasil Jual Minyak Wangi / Parfum Refill',
        icon: Icons.science_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Penjualan Alat Olahraga & Jersey Bola',
        icon: Icons.fitness_center_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Hasil Penjualan Pulsa & Token Listrik',
        icon: Icons.bolt_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Hasil Penjualan Aksesoris HP / Casing Custom',
        icon: Icons.phone_android_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Hasil Penjualan Pakaian Thrifting / Preloved',
        icon: Icons.checkroom_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Hasil Penjualan Hijab & Busana Muslimah',
        icon: Icons.checkroom_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Hasil Penjualan Kosmetik & Skincare Lokal',
        icon: Icons.face_retouching_natural_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Hasil Penjualan Perlengkapan Bayi & Balita',
        icon: Icons.child_friendly_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Hasil Penjualan Sepatu & Sandal Murah',
        icon: Icons.shopping_bag_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Hasil Penjualan Tas & Dompet Lokal',
        icon: Icons.shopping_bag_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF5D4037)),
    TransactionCategory(
        label: 'Hasil Penjualan Alat Tulis & Kantor (ATK)',
        icon: Icons.edit_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Hasil Penjualan Perabotan Rumah Tangga',
        icon: Icons.chair_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Hasil Penjualan Barang Elektronik Bekas',
        icon: Icons.electric_moped_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Hasil Penjualan Mainan Anak & Edukasi',
        icon: Icons.toys_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFAFB42B)),
    TransactionCategory(
        label: 'Hasil Penjualan Pakan & Obat Hewan Ternak',
        icon: Icons.pets_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Hasil Penjualan Suku Cadang / Sparepart Motor',
        icon: Icons.settings_suggest_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Hasil Penjualan Helm & Aksesoris Berkendara',
        icon: Icons.motorcycle_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFFD84315)),
    TransactionCategory(
        label: 'Hasil Penjualan Bahan Bangunan & Semen',
        icon: Icons.construction_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Hasil Penjualan Pupuk & Bibit Pertanian',
        icon: Icons.yard_rounded,
        group: 'Bisnis & Penjualan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Proyek Freelance (Desain/IT/Konten)',
        icon: Icons.laptop_mac_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Freelance Internet / Online Global (Upwork/Fiverr/dll)',
        icon: Icons.public_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF0277BD)),
    TransactionCategory(
        label: 'Jasa Desain Grafis & Ilustrasi',
        icon: Icons.brush_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFFE040FB)),
    TransactionCategory(
        label: 'Jasa Video Editing & Motion Graphics',
        icon: Icons.video_library_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFFFF5722)),
    TransactionCategory(
        label: 'Jasa Voice Over & Dubbing',
        icon: Icons.mic_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Jasa Penerjemahan & Pembuatan Subtitle',
        icon: Icons.translate_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Jasa Copywriting & Content Writing',
        icon: Icons.edit_note_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Jasa Landing Page & Pembuatan Website',
        icon: Icons.web_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF00E676)),
    TransactionCategory(
        label: 'Jasa UI/UX Design & Mockup Figma',
        icon: Icons.view_quilt_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFFD500F9)),
    TransactionCategory(
        label: 'Jasa Data Entry & Virtual Assistant',
        icon: Icons.keyboard_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Jasa Transkripsi Audio & Video',
        icon: Icons.audiotrack_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Jasa SEO & Riset Keyword',
        icon: Icons.search_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF29B6F6)),
    TransactionCategory(
        label: 'Jasa Les Privat & Tutor Akademik',
        icon: Icons.school_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Jasa Fotografi & Dokumentasi Event',
        icon: Icons.photo_camera_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF3949AB)),
    TransactionCategory(
        label: 'Jasa Titip Beli (Jastip) Barang',
        icon: Icons.shopping_bag_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Sewa & Sharing Akun Premium',
        icon: Icons.people_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Jasa Service & Perbaikan Komputer/Laptop',
        icon: Icons.computer_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Jasa Instalasi OS & Software',
        icon: Icons.install_desktop_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Jasa Service HP & Gadget',
        icon: Icons.phone_android_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Jasa Managed Service & Maintenance Server IT',
        icon: Icons.dns_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Jasa Managed Social Media (Admin Instagram/TikTok)',
        icon: Icons.photo_camera_back_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Jasa Content Creator (Pembuatan Video TikTok/Reels)',
        icon: Icons.video_call_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFFFF5722)),
    TransactionCategory(
        label: 'Jasa Desain Website (Web Design & WordPress)',
        icon: Icons.web_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF00E676)),
    TransactionCategory(
        label: 'Jasa Pembuatan Aplikasi Excel & Automasi Makro',
        icon: Icons.table_view_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Jasa Pengisian Kuesioner & Paid Survey',
        icon: Icons.assignment_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Jasa Les Privat Musik (Gitar/Piano/dll)',
        icon: Icons.music_note_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF673AB7)),
    TransactionCategory(
        label: 'Jasa Les Privat Bahasa Asing (Inggris/Jepang/dll)',
        icon: Icons.translate_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Jasa Makeup Artist (MUA) & Styling',
        icon: Icons.face_retouching_natural_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Jasa MC & Host Event',
        icon: Icons.mic_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Jasa Sewa Kostum Cosplay & Pakaian Adat',
        icon: Icons.checkroom_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFFD500F9)),
    TransactionCategory(
        label: 'Jasa Pembuatan CV, Resume & Portofolio',
        icon: Icons.contact_page_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Jasa Penulisan Skripsi, Thesis & Jurnal Ilmiah',
        icon: Icons.menu_book_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Jasa Pembuatan Kerajinan Tangan & Rajutan (Handmade)',
        icon: Icons.brush_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFFE040FB)),
    TransactionCategory(
        label: 'Jasa Dekorasi Event & Photobooth',
        icon: Icons.camera_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Jasa Pindahan Barang & Driver Panggilan',
        icon: Icons.local_shipping_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Jasa Penitipan & Perawatan Hewan',
        icon: Icons.pets_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Jasa Desain Interior & Arsitek',
        icon: Icons.architecture_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Jasa Copywriting Iklan / Ad Copy',
        icon: Icons.campaign_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Jasa Ghost Writer / Penulisan Artikel',
        icon: Icons.edit_note_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Jasa Pembuatan Bot Discord / Telegram',
        icon: Icons.smart_toy_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Jasa Live Streaming Host (TikTok/Shopee)',
        icon: Icons.live_tv_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Jasa Admin Online Shop (Customer Service/Upload)',
        icon: Icons.support_agent_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Jasa Pembuatan Undangan Pernikahan Digital',
        icon: Icons.celebration_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Jasa Edit Foto Lightroom & Photoshop Pro',
        icon: Icons.photo_filter_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Jasa Ketik Cepat & Salin Dokumen',
        icon: Icons.description_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Jasa Edit Video Undangan Digital & Slide Presentasi',
        icon: Icons.slideshow_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFFFF5722)),
    TransactionCategory(
        label: 'Jasa Service AC & Cuci AC Rumah Panggilan',
        icon: Icons.ac_unit_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Jasa Perbaikan Instalasi Listrik Rumah',
        icon: Icons.bolt_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Jasa Bersih Rumah Panggilan',
        icon: Icons.clean_hands_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Jasa Setup Internet Rumah & Wifi',
        icon: Icons.wifi_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Jasa Ghost Writer Penulisan Novel',
        icon: Icons.edit_note_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Jasa Setup Jaringan Wifi / Mikrotik Kantor',
        icon: Icons.settings_ethernet_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Jasa Edit Foto Photoshop Wisuda / Wedding',
        icon: Icons.photo_filter_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Jasa Terjemahan Jurnal / Abstrak Inggris-Indo',
        icon: Icons.translate_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Jasa Les Privat Matematika / Fisika SMA',
        icon: Icons.school_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Jasa Pelatih Futsal / Sepakbola Anak',
        icon: Icons.sports_soccer_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Jasa Pijat Bayi & Spa Ibu Hamil Panggilan',
        icon: Icons.self_improvement_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Jasa Driver Panggilan Harian / Antar Kota',
        icon: Icons.directions_car_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Jasa Penulisan CV & Portofolio Kerja ATS',
        icon: Icons.contact_page_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Jasa Kebun & Pangkas Pohon Halaman',
        icon: Icons.yard_rounded,
        group: 'Kerja Lepas & Sampingan',
        color: Color(0xFF558B2F)),
    TransactionCategory(
        label: 'Joki Pemrograman & Coding (RPL)',
        icon: Icons.code_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Joki Pembuatan Web & Mobile App (RPL)',
        icon: Icons.web_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Joki Database & Query SQL (RPL)',
        icon: Icons.storage_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Joki Konfigurasi Mikrotik & Cisco (TKJ)',
        icon: Icons.settings_ethernet_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Joki Setting Server & Jaringan (TKJ)',
        icon: Icons.dns_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Joki Desain Topologi & Packet Tracer (TKJ)',
        icon: Icons.schema_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF0277BD)),
    TransactionCategory(
        label: 'Joki Desain Grafis & Logo',
        icon: Icons.palette_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFFFA000)),
    TransactionCategory(
        label: 'Joki Video Editing & Animasi 3D (DKV)',
        icon: Icons.movie_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFF57C00)),
    TransactionCategory(
        label: 'Joki Desain PCB & Skema Proteus (TEI)',
        icon: Icons.developer_board_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Joki Teori PLC & Mikroprosesor (TEI)',
        icon: Icons.memory_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF2196F3)),
    TransactionCategory(
        label: 'Joki Gambar Rangkaian Listrik & Panel (TITL)',
        icon: Icons.bolt_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFFFC107)),
    TransactionCategory(
        label: 'Joki Teori Motor Listrik & PLC (TITL)',
        icon: Icons.settings_input_component_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFFF9800)),
    TransactionCategory(
        label: 'Joki Gambar 2D/3D CAD & CAM (Pemesinan)',
        icon: Icons.precision_manufacturing_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Joki Teori Bubut, Frais & CNC (Pemesinan)',
        icon: Icons.construction_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Joki Gambar Denah AutoCAD & SketchUp (DPIB)',
        icon: Icons.architecture_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Joki Perhitungan Rencana Anggaran Biaya (DPIB)',
        icon: Icons.calculate_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF5D4037)),
    TransactionCategory(
        label: 'Joki Pembukuan & Laporan Keuangan (Akuntansi)',
        icon: Icons.calculate_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Joki Pengolahan Data Excel & Word (OTKP)',
        icon: Icons.description_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Joki Rencana Bisnis & Pemasaran Digital (BDP)',
        icon: Icons.campaign_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Joki Content Marketing, Copywriting & SEO (BDP)',
        icon: Icons.article_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF9C27B0)),
    TransactionCategory(
        label: 'Joki Laporan Tune-up & Overhaul (Otomotif)',
        icon: Icons.build_circle_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Joki Analisis Kelistrikan & Sasis (Otomotif)',
        icon: Icons.electric_car_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Joki Soal Teori Kejuruan Mesin (Otomotif)',
        icon: Icons.settings_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Joki SOP Front Office & Housekeeping (Perhotelan)',
        icon: Icons.hotel_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Joki Penyusunan Paket Wisata & Itinerary (UPW)',
        icon: Icons.map_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Joki Penyusunan Resep & Food Cost (Tata Boga)',
        icon: Icons.restaurant_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFFF9800)),
    TransactionCategory(
        label: 'Joki Laporan Praktik Kue & Pastry (Tata Boga)',
        icon: Icons.cake_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Joki Gambar Pola & Pecah Pola Busana',
        icon: Icons.straighten_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFE040FB)),
    TransactionCategory(
        label: 'Joki Laporan Pembuatan Busana / Desain Tekstil',
        icon: Icons.checkroom_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF9C27B0)),
    TransactionCategory(
        label: 'Joki Laporan Praktikum Jurnal Resep (Farmasi)',
        icon: Icons.medication_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Joki Teori Dosis & Farmakognosi (Farmasi)',
        icon: Icons.science_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Joki Penyusunan Asuhan Keperawatan / Askep',
        icon: Icons.assignment_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Joki Teori Anatomi & Fisiologi (Keperawatan)',
        icon: Icons.favorite_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Joki Laporan Pascapanen & Budidaya (Agribisnis)',
        icon: Icons.grass_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Joki Perhitungan Formulasi Pakan & Pupuk',
        icon: Icons.agriculture_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Joki Tugas Pemrograman Web (HTML/CSS/JS)',
        icon: Icons.code_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Joki Laporan Praktik Kerja Industri (Prakerin)',
        icon: Icons.assignment_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Joki Tugas Pembuatan Database MySQL/Oracle',
        icon: Icons.storage_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Joki Tugas Gambar AutoCAD Denah Rumah 2D',
        icon: Icons.architecture_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Joki Tugas Animasi 2D/3D Blender & Maya',
        icon: Icons.movie_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFF57C00)),
    TransactionCategory(
        label: 'Joki Tugas Perakitan PC & Instalasi Windows',
        icon: Icons.computer_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Joki Analisis Data SPSS Kuliah (Skripsi)',
        icon: Icons.calculate_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Joki Olah Data SmartPLS & AMOS Kuliah',
        icon: Icons.schema_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Joki Terjemahan Jurnal Ilmiah Internasional',
        icon: Icons.translate_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Joki Resume & Review Jurnal Kedokteran/Hukum',
        icon: Icons.book_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Joki Koding Python / Machine Learning Skripsi',
        icon: Icons.code_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Joki Pembuatan Slide PPT Sidang Skripsi',
        icon: Icons.slideshow_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFFF5722)),
    TransactionCategory(
        label: 'Joki Laporan Praktikum Kimia / Fisika Kuliah',
        icon: Icons.science_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Joki Tugas Akuntansi Excel (Jurnal Penyesuaian)',
        icon: Icons.calculate_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Joki Tugas Desain Poster Promosi SMK',
        icon: Icons.palette_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Joki Pembuatan Slide PPT Presentasi Sidang SMK',
        icon: Icons.description_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Joki Penyusunan Laporan PKL & Magang SMK',
        icon: Icons.school_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Joki Tugas Pemrograman Web HTML & CSS SMK',
        icon: Icons.code_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Joki Coding Java & Python Dasar Lab SMK',
        icon: Icons.laptop_mac_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Joki Praktek Perakitan PC & Instalasi OS SMK',
        icon: Icons.build_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Joki Pembuatan Database SQL & MySQL SMK',
        icon: Icons.dns_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Joki Gambar AutoCAD Arsitektur Rumah SMK',
        icon: Icons.architecture_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Joki Desain Rangkaian Listrik Proteus SMK',
        icon: Icons.bolt_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Joki Analisis Laporan Keuangan Sederhana SMK',
        icon: Icons.calculate_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Joki Input Data Excel Rumus VLOOKUP SMK',
        icon: Icons.table_view_rounded,
        group: 'Joki Tugas SMK',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Joki Game Roblox (Adopt Me / Blox Fruits / Pet Sim)',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFFBF360C)),
    TransactionCategory(
        label: 'Joki Push Rank PUBG Mobile (Conqueror / Ace / KD)',
        icon: Icons.military_tech_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF1B5E20)),
    TransactionCategory(
        label: 'Joki Push Rank Mobile Legends (Mythic / Glory / Immortal)',
        icon: Icons.stars_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Joki Push Rank Free Fire (Grandmaster / Heroic)',
        icon: Icons.local_fire_department_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFFE65100)),
    TransactionCategory(
        label: 'Joki Game Genshin Impact',
        icon: Icons.auto_awesome_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Joki Game Honkai Star Rail',
        icon: Icons.train_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Joki Push Rank Valorant',
        icon: Icons.videogame_asset_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFFB71C1C)),
    TransactionCategory(
        label: 'Joki Game Point Blank',
        icon: Icons.gps_fixed_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF37474F)),
    TransactionCategory(
        label: 'Joki Push Rank Call of Duty: Mobile (Legendary)',
        icon: Icons.star_half_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF4E342E)),
    TransactionCategory(
        label: 'Joki Push Rank Apex Legends (Predator / Master)',
        icon: Icons.trending_up_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFFD84315)),
    TransactionCategory(
        label: 'Joki Squad Building EA Sports FC Mobile',
        icon: Icons.sports_soccer_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Joki Push Rank eFootball Mobile',
        icon: Icons.sports_soccer_outlined,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Joki Profit Growtopia (BGL / Diamond Lock / Leveling)',
        icon: Icons.monetization_on_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Joki Minecraft (Farming Resource / Survival Build)',
        icon: Icons.landscape_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF33691E)),
    TransactionCategory(
        label: 'Joki GTA V Online (Money / Roleplay Leveling)',
        icon: Icons.directions_car_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Joki Push Rank League of Legends: Wild Rift (Challenger)',
        icon: Icons.shield_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Joki Push Rank Arena of Valor (AoV Conqueror)',
        icon: Icons.workspace_premium_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Farming Clash of Clans (Clan Games / War / Trophy)',
        icon: Icons.home_work_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF5D4037)),
    TransactionCategory(
        label: 'Joki Push Trophy Clash Royale (Grand Challenge)',
        icon: Icons.star_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Joki Push Rank Farlight 84 (Legend / Gladiator)',
        icon: Icons.rocket_launch_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Joki Wuthering Waves (Explore / Quest / Leveling)',
        icon: Icons.blur_on_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF6A1B9A)),
    TransactionCategory(
        label: 'Joki Farming Event Fate/Grand Order (FGO)',
        icon: Icons.auto_stories_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Joki Blue Archive (Daily AP / Story / Raid Clear)',
        icon: Icons.school_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF039BE5)),
    TransactionCategory(
        label: 'Joki Arknights (Event Clearing / Trust Farming)',
        icon: Icons.explore_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Joki Push Rank Solo Leveling',
        icon: Icons.auto_awesome_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF6A1B9A)),
    TransactionCategory(
        label: 'Joki Game Roblox Blox Fruits',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFFBF360C)),
    TransactionCategory(
        label: 'Joki Push Rank Counter-Strike 2 (Premier/Faceit)',
        icon: Icons.gps_fixed_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF37474F)),
    TransactionCategory(
        label: 'Joki Push Rank Arena Breakout',
        icon: Icons.warning_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFFB71C1C)),
    TransactionCategory(
        label: 'Joki Game League of Legends PC (Ranked)',
        icon: Icons.shield_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Joki Pembuatan Akun Starter (Reroll Account ML/Genshin/WuWa)',
        icon: Icons.manage_accounts_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Joki Push Rank Dota 2',
        icon: Icons.games_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Joki Push Rank Chess.com (Rating Elo)',
        icon: Icons.casino_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Joki Push Rank Honor of Kings (HoK Grandmaster)',
        icon: Icons.shield_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Joki Temani Main (Co-Play / Teman Mabar) Per Jam',
        icon: Icons.people_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Joki Push Rank FC Mobile (FIFA Champion)',
        icon: Icons.sports_soccer_outlined,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Joki Gacha Pull Service Akun Game Gacha',
        icon: Icons.casino_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Joki Profit Growtopia (BGL & DL Farming)',
        icon: Icons.monetization_on_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Joki CoC (Clash of Clans) Push Trophy Legends',
        icon: Icons.home_work_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF5D4037)),
    TransactionCategory(
        label: 'Joki Reroll Akun Starter Gacha Baru (WuWa/StarRail)',
        icon: Icons.manage_accounts_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Joki Push Rank Mobile Legends Mythic',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Joki Push Rank PUBG Mobile Ace/Conqueror',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF8E24AA)),
    TransactionCategory(
        label: 'Joki Push Rank Free Fire Grandmaster',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Joki Akun Genshin Impact Leveling & Quest',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Joki Leveling Honkai Star Rail Trailblaze',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Joki Push Rank Valorant Radiant/Immortal',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Joki Farming Roblox Blox Fruits Level/Beli',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Joki Farming Point Blank PB Cash/Exp',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Joki Matchmaking Dota 2 MMR Booster',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Joki Push Rank Arena Breakout Legend',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Joki Farming Solo Leveling Arise Gold',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Joki Push Rank Call of Duty Mobile Legendary',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Joki Farming Minecraft Material & Build',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF5D4037)),
    TransactionCategory(
        label: 'Joki Farming Growtopia World Lock (WL)',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFFD84315)),
    TransactionCategory(
        label: 'Joki Push Rank League of Legends Wild Rift',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Joki Quest & Boss Fight Black Desert Online',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Joki Leveling Ragnarok Origin Base/Job Exp',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Joki Farming Fate/Grand Order Event/FQP',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Joki Farming Wuthering Waves Echoes/Shell',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Joki Leveling Toram Online Spina/Exp',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Joki Quest Blue Archive Pyroxene Farm',
        icon: Icons.sports_esports_rounded,
        group: 'Joki Game & Push Rank',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'AdSense & Monetisasi Platform',
        icon: Icons.ads_click_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Sponsorship & Endorsement',
        icon: Icons.recommend_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Afiliasi & Referral (Shopee/Tiktok Affiliate)',
        icon: Icons.hub_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Donasi Live Streaming (Saweria/Trakteer/Tiktok)',
        icon: Icons.video_camera_back_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Penjualan Karya Digital (Trakteer/KaryaKarsa/dll)',
        icon: Icons.favorite_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Penjualan Template Canva & Aset 3D',
        icon: Icons.palette_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Penjualan Foto/Video Stock (Shutterstock/Freepik)',
        icon: Icons.camera_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Penjualan Ebook & Kursus Online',
        icon: Icons.auto_stories_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF7E57C2)),
    TransactionCategory(
        label: 'Royalti Karya & Lisensi Musik/Digital',
        icon: Icons.vpn_key_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Penjualan Merchandise / Merchandise Sales',
        icon: Icons.shopping_bag_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Royalti Penulisan Buku / Novel / Ebook',
        icon: Icons.book_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Hasil Penjualan Kursus Online (Self-Hosted/Udemy)',
        icon: Icons.school_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Biaya Pendaftaran Webinar / Workshop Digital',
        icon: Icons.co_present_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Langganan Membership Platform (Patreon/Substack)',
        icon: Icons.loyalty_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFE50914)),
    TransactionCategory(
        label: 'Hasil Penjualan Plugin, Source Code & API',
        icon: Icons.code_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Pendapatan Jasa Endorsement Micro-Influencer',
        icon: Icons.star_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Hasil Penjualan Preset Lightroom / LUTS Video',
        icon: Icons.filter_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Pendapatan AdSense YouTube & TikTok Creator Fund',
        icon: Icons.play_circle_fill_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Royalti Streaming Musik (Spotify/Apple Music Artist)',
        icon: Icons.music_video_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF1DB954)),
    TransactionCategory(
        label: 'Penjualan Template Notion & productivity tools',
        icon: Icons.task_alt_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Pendapatan Substack / Buletin Berbayar',
        icon: Icons.rss_feed_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Pendapatan Live TikTok (Gift/Mawar/Singa)',
        icon: Icons.live_tv_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Pendapatan Podcaster / Anchor Sponsorship',
        icon: Icons.podcasts_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Royalti Penulisan Musik Digital (Bandcamp/Soundcloud)',
        icon: Icons.music_note_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF1DB954)),
    TransactionCategory(
        label: 'Hasil Google AdSense Blog & Website Pribadi',
        icon: Icons.web_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Royalti Penulisan Novel Digital (Wattpad/Webnovel)',
        icon: Icons.book_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Hasil Penjualan Filter Instagram & Tiktok AR',
        icon: Icons.face_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Pendapatan Saweria Live Streaming Game',
        icon: Icons.video_camera_back_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Hasil Komisi Shopee Affiliate Harian',
        icon: Icons.hub_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Hasil Komisi TikTok Shop Affiliate Bulanan',
        icon: Icons.recommend_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Hasil Komisi Tokopedia Affiliate Program',
        icon: Icons.shopping_bag_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Gaji Kontrak MCN (Multi-Channel Network) Tiktok',
        icon: Icons.badge_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Penjualan Novel Digital KaryaKarsa / Joylada',
        icon: Icons.book_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Penjualan Komik Digital Webtoon / Tapas',
        icon: Icons.art_track_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Penjualan Aset Game 3D Unity / Unreal Engine',
        icon: Icons.view_in_ar_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Penjualan Filter Kamera AR Spark AR (IG/Tiktok)',
        icon: Icons.face_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Uang Hadiah Turnamen E-Sports Komunitas/Lokal',
        icon: Icons.emoji_events_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Sponsorship Video Review Gadget Youtube',
        icon: Icons.phone_iphone_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF689F38)),
    TransactionCategory(
        label: 'Royalti Streaming Lagu Spotify Artist',
        icon: Icons.music_note_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF1DB954)),
    TransactionCategory(
        label: 'Penjualan Template Notion Produktivitas',
        icon: Icons.task_alt_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Penjualan Preset Foto Lightroom / LUTS Video',
        icon: Icons.filter_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Pendapatan Google AdSense Web Iklan',
        icon: Icons.language_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Hasil Penjualan Template Desain PowerPoint',
        icon: Icons.slideshow_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Hasil Penjualan E-Book Panduan Bisnis',
        icon: Icons.menu_book_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF5C6BC0)),
    TransactionCategory(
        label: 'Hasil Penjualan Lightroom Presets Mobile',
        icon: Icons.palette_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Hasil Penjualan Stock Footage Video B-Roll',
        icon: Icons.video_camera_back_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Hasil Penjualan Efek Suara (Sound Effects) SFX',
        icon: Icons.volume_up_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Royalti Penjualan Beat / Instrumental Rap',
        icon: Icons.music_note_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Hasil Penjualan Font Tulisan Tangan Custom',
        icon: Icons.font_download_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF8E24AA)),
    TransactionCategory(
        label: 'Hasil Penjualan UI Kit Web & Mobile App',
        icon: Icons.phone_android_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Hasil Penjualan Model 3D Blender/Objek',
        icon: Icons.view_in_ar_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Pendapatan Jasa Ghostwriting Artikel Blog',
        icon: Icons.article_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Pendapatan Jasa Copywriting Landing Page',
        icon: Icons.description_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Hasil Penjualan Newsletter Berbayar bulanan',
        icon: Icons.mail_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Pendapatan Donasi Kreator KaryaKarsa',
        icon: Icons.favorite_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Pendapatan Brand Deal Sponsor Instagram',
        icon: Icons.campaign_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Pendapatan Afiliasi Link Tokopedia / Shopee',
        icon: Icons.link_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Pendapatan Jasa Penerjemah Subtitle Video',
        icon: Icons.subtitles_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF5C6BC0)),
    TransactionCategory(
        label: 'Hasil Penjualan Brush Procreate & Photoshop',
        icon: Icons.brush_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Pendapatan Membership VIP Grup Telegram',
        icon: Icons.telegram_rounded,
        group: 'Kreator Konten & Digital',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Bunga Bank & Deposito',
        icon: Icons.account_balance_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Cashback, Diskon & Reward',
        icon: Icons.credit_score_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Refund / Pengembalian Dana',
        icon: Icons.replay_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Klaim Asuransi',
        icon: Icons.health_and_safety_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Bunga Simpanan Koperasi',
        icon: Icons.people_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Kompensasi / Ganti Rugi',
        icon: Icons.gavel_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Transfer Masuk Bank Swasta (BCA/CIMB/dll)',
        icon: Icons.account_balance_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Transfer Masuk Bank BUMN (Mandiri/BRI/BNI)',
        icon: Icons.account_balance_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Transfer Masuk Bank Digital (Jago/SeaBank/Blu/Neo)',
        icon: Icons.phone_android_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Transfer Masuk Bank Syariah (BSI/dll)',
        icon: Icons.mosque_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Saldo Masuk E-Wallet (GoPay/OVO/DANA/dll)',
        icon: Icons.wallet_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Penerimaan Dana Global (PayPal/Wise)',
        icon: Icons.public_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF0277BD)),
    TransactionCategory(
        label: 'Hasil Pencairan Deposito Bank',
        icon: Icons.savings_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Bunga Deposito Mudharabah Syariah',
        icon: Icons.mosque_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Hadiah Undian & Doorprize Tabungan Bank',
        icon: Icons.card_giftcard_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Cashback Belanja Online / E-Wallet Portal',
        icon: Icons.wallet_giftcard_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Refund Pembatalan Tiket Pesawat / Kereta',
        icon: Icons.flight_land_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Klaim Asuransi Jiwa & Unit Link',
        icon: Icons.verified_user_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Pencairan Limit Paylater / Gestun',
        icon: Icons.monetization_on_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Imbalan Loyalti Poin Kartu Kredit / Bank',
        icon: Icons.credit_card_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Hadiah Buka Rekening Baru (Referral Bank)',
        icon: Icons.card_giftcard_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Cashback Promo Kartu Kredit',
        icon: Icons.credit_card_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Bunga Rekening Valas (Foreign Currency Account)',
        icon: Icons.currency_exchange_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF1B5E20)),
    TransactionCategory(
        label: 'Hadiah Referral Pembukaan Akun Broker Saham',
        icon: Icons.card_giftcard_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Pencairan Dana JHT (Jaminan Hari Tua) BPJS',
        icon: Icons.savings_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Bunga Tabungan Simpedes / Britama BRI',
        icon: Icons.account_balance_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Cashback Transaksi Merchant QRIS',
        icon: Icons.qr_code_scanner_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Pencairan Jaminan Kehilangan Pekerjaan (JKP) BPJS',
        icon: Icons.work_history_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Imbalan Loyalti Poin Telkomsel / Indosat Red',
        icon: Icons.stars_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bunga Rekening Jenius / Blu Digital Saver',
        icon: Icons.phone_android_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Bunga Tabungan Tahapan BCA / Britama BRI',
        icon: Icons.account_balance_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Cashback Belanja Pakai OVO / GoPay Coins',
        icon: Icons.wallet_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Imbalan Poin Telkomsel Red / Indosat Poin',
        icon: Icons.stars_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Bunga Simpanan Berjangka Koperasi Karyawan',
        icon: Icons.people_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Bunga Rekening Bank Digital Seabank / Jago',
        icon: Icons.phone_android_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Bunga Tabungan Simpedes BRI Bulanan',
        icon: Icons.account_balance_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Bunga Tabungan Tahapan BCA Bulanan',
        icon: Icons.account_balance_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Bunga Tabungan Britama BRI Bulanan',
        icon: Icons.account_balance_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Bunga Tabungan Tapres BCA Bulanan',
        icon: Icons.account_balance_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Bunga Tabungan Mandiri Rupiah Bulanan',
        icon: Icons.account_balance_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF0D47A1)),
    TransactionCategory(
        label: 'Bunga Tabungan BNI Taplus Bulanan',
        icon: Icons.account_balance_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Bunga Deposito Bank Mandiri Bulanan',
        icon: Icons.savings_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Bunga Deposito Bank BRI Bulanan',
        icon: Icons.savings_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Bunga Deposito Bank BCA Bulanan',
        icon: Icons.savings_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Bunga Deposito Bank BNI Bulanan',
        icon: Icons.savings_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Bunga Tabungan Bank Jago Digital Saver',
        icon: Icons.phone_android_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Bunga Tabungan Bank SeaBank Digital High Yield',
        icon: Icons.phone_android_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Bunga Tabungan Bank Blu by BCA Digital',
        icon: Icons.phone_android_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Bunga Tabungan Bank Neo Commerce Bulanan',
        icon: Icons.phone_android_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Bunga Simpanan Sukarela Koperasi Bulanan',
        icon: Icons.people_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Bunga Simpanan Berjangka Koperasi Bulanan',
        icon: Icons.people_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Cashback Transaksi Merchant ShopeePay QRIS',
        icon: Icons.wallet_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFFE65100)),
    TransactionCategory(
        label: 'Cashback Transaksi Merchant GoPay Coins',
        icon: Icons.wallet_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Cashback Transaksi Merchant OVO Cash',
        icon: Icons.wallet_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Cashback Transaksi Merchant DANA Kaget',
        icon: Icons.wallet_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Refund Pembatalan Tiket Kereta Api KAI',
        icon: Icons.train_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Refund Pembatalan Kamar Hotel Traveloka',
        icon: Icons.hotel_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF5C6BC0)),
    TransactionCategory(
        label: 'Klaim Asuransi Rawat Inap Swasta',
        icon: Icons.health_and_safety_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Klaim Asuransi Kendaraan Motor / Mobil',
        icon: Icons.build_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Klaim Asuransi Jiwa & Unit Link Bulanan',
        icon: Icons.verified_user_rounded,
        group: 'Keuangan & Bank',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Profit Saham & Reksa Dana',
        icon: Icons.trending_up_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Profit Obligasi & Sukuk (SBN)',
        icon: Icons.payment_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Profit Crypto, Staking & Web3',
        icon: Icons.currency_bitcoin_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFFFBC02D)),
    TransactionCategory(
        label: 'Airdrop Crypto Diterima',
        icon: Icons.toll_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFFFF9800)),
    TransactionCategory(
        label: 'Hasil Penjualan Emas & Perhiasan',
        icon: Icons.diamond_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFFFFD54F)),
    TransactionCategory(
        label: 'Hasil Jual Gadget & Elektronik Preloved',
        icon: Icons.phone_iphone_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF689F38)),
    TransactionCategory(
        label: 'Hasil Jual Aset Properti & Tanah',
        icon: Icons.landscape_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF4E342E)),
    TransactionCategory(
        label: 'Hasil Tukar Valas / Forex',
        icon: Icons.currency_exchange_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF1B5E20)),
    TransactionCategory(
        label: 'Dividen Saham Rutin',
        icon: Icons.receipt_long_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Bunga & Kupon SBN / Obligasi Negara',
        icon: Icons.payments_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Profit Trading Futures & Forex',
        icon: Icons.trending_up_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFFFBC02D)),
    TransactionCategory(
        label: 'Dividen Reksa Dana Terdistribusi',
        icon: Icons.stars_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Hasil Penjualan Koleksi Hypebeast / Sneakers',
        icon: Icons.checkroom_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Hasil Penjualan Mobil / Motor Bekas (Preloved)',
        icon: Icons.directions_car_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Profit P2P Lending (Bunga Pendanaan)',
        icon: Icons.handshake_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Hasil Imbal Jasa Sewa Aset Lahan / Kebun',
        icon: Icons.landscape_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Kupon Sukuk Ritel (SR) / Sukuk Tabungan (ST)',
        icon: Icons.card_membership_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Yield Farming / DeFi Liquidity Provision',
        icon: Icons.currency_exchange_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Hasil Gadai Logam Mulia / Perhiasan Emas',
        icon: Icons.account_balance_wallet_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFFFFD54F)),
    TransactionCategory(
        label: 'Hasil Penjualan Saham (Capital Gain)',
        icon: Icons.trending_up_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Profit Arbitrase Aset Kripto & USDT',
        icon: Icons.currency_exchange_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFFFFA000)),
    TransactionCategory(
        label: 'Dividen Saham Emiten LQ45 Pilihan',
        icon: Icons.stars_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Profit Penjualan Reksadana Saham',
        icon: Icons.trending_up_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Deviden Tunai Saham LQ45',
        icon: Icons.account_balance_wallet_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Profit Jual Beli Koin Kripto (Scalping)',
        icon: Icons.currency_exchange_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Hasil Penjualan Obligasi Negara Ritel (ORI/SBR)',
        icon: Icons.workspace_premium_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Profit Trading Emas Online',
        icon: Icons.diamond_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Capital Gain Likuidasi Aset Properti',
        icon: Icons.real_estate_agent_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Profit Penjualan Reksadana Saham Bulanan',
        icon: Icons.trending_up_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Hasil Penjualan Obligasi Negara Ritel (SBR/ORI)',
        icon: Icons.workspace_premium_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Profit Trading Emas Online Pegadaian',
        icon: Icons.diamond_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Dividen Saham Blue Chip BUMN (BBRI/TLKM)',
        icon: Icons.payments_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Profit Trading Forex & Valuta Asing',
        icon: Icons.currency_exchange_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Capital Gain Likuidasi Properti Tanah',
        icon: Icons.real_estate_agent_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Profit Jual Beli Koin Kripto (Scalping Daily)',
        icon: Icons.currency_exchange_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Bagi Hasil Sukuk Ritel Negara (SR)',
        icon: Icons.mosque_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Dividen Saham Kategori Consumer Goods',
        icon: Icons.payments_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Profit Trading Saham Harian (Day Trading)',
        icon: Icons.trending_up_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Bagi Hasil Sukuk Tabungan Negara (ST)',
        icon: Icons.mosque_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Profit Pendapatan P2P Lending Syariah',
        icon: Icons.people_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Profit Jual Beli Aset Kripto Spot',
        icon: Icons.currency_exchange_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Bagi Hasil Reksa Dana Syariah Campuran',
        icon: Icons.trending_up_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Profit Jual Beli Reksadana Pendapatan Tetap',
        icon: Icons.trending_up_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Bagi Hasil Pendapatan Sukuk Wakaf',
        icon: Icons.mosque_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Profit Penjualan Logam Mulia Emas Antam',
        icon: Icons.diamond_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Dividen Saham Sektor Perbankan (BBCA)',
        icon: Icons.payments_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Dividen Saham Sektor Tambang (PTBA)',
        icon: Icons.payments_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF5D4037)),
    TransactionCategory(
        label: 'Dividen Saham Sektor Infrastruktur (TLKM)',
        icon: Icons.payments_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Bagi Hasil Investasi P2P Lending Produktif',
        icon: Icons.groups_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Profit Trading Kripto Futures Leverage',
        icon: Icons.trending_up_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Profit Arbitrase Harga Kripto Antar Exchange',
        icon: Icons.currency_exchange_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Dividen Saham Sektor Industri Semen (SMGR)',
        icon: Icons.payments_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Dividen Saham Sektor Otomotif (ASII)',
        icon: Icons.payments_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Bagi Hasil Investasi Saham Syariah',
        icon: Icons.mosque_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Profit Trading Saham Swing Trading',
        icon: Icons.trending_up_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Profit Penjualan Reksadana Indeks',
        icon: Icons.trending_up_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Bagi Hasil Investasi Crowdfunding Properti',
        icon: Icons.real_estate_agent_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Profit Penjualan Surat Berharga Negara (SBN)',
        icon: Icons.workspace_premium_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Dividen Saham Emiten Properti & Real Estate',
        icon: Icons.payments_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Bagi Hasil Deposito Berjangka Bank Syariah',
        icon: Icons.mosque_rounded,
        group: 'Investasi & Aset',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Sewa Properti (Kost/Rumah/Ruko)',
        icon: Icons.home_work_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF00796B)),
    TransactionCategory(
        label: 'Sewa Kendaraan & Peralatan',
        icon: Icons.car_rental_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF00695C)),
    TransactionCategory(
        label: 'Sewa Pasang Iklan (Baliho/Website)',
        icon: Icons.visibility_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Hasil Mesin Otomatis (Vending/Laundromat)',
        icon: Icons.point_of_sale_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Bagi Hasil Kemitraan Pasif',
        icon: Icons.monetization_on_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFFF57C00)),
    TransactionCategory(
        label: 'Sewa Alat Fotografi, Kamera & Lensa',
        icon: Icons.photo_camera_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Sewa PlayStation & Konsol Game Harian',
        icon: Icons.sports_esports_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Sewa Pakaian Adat, Jas & Gaun Pernikahan',
        icon: Icons.checkroom_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Sewa Lahan Parkir & Garasi Mobil Harian/Bulanan',
        icon: Icons.local_parking_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Sewa Mainan Anak & Stroller Balita',
        icon: Icons.child_friendly_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Sewa Tenda & Peralatan Camping/Outdoor',
        icon: Icons.forest_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Sewa Buku, Novel & Komik Fisik',
        icon: Icons.book_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Hasil Sharing Server VPS / Resource Storage',
        icon: Icons.cloud_queue_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Sewa Kamera Drone & Gopro Harian',
        icon: Icons.photo_camera_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Sewa Nintendo Switch & Konsol Game',
        icon: Icons.sports_esports_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Sewa Akun Canva Pro / Zoom Premium',
        icon: Icons.people_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Sewa Alat Pesta (Sound System/Tenda/Kursi)',
        icon: Icons.volume_up_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Sewa Kamar Kost Harian & Guest House',
        icon: Icons.bed_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF00796B)),
    TransactionCategory(
        label: 'Sewa Perlengkapan Bayi (Car Seat/Box Bayi/Stroller)',
        icon: Icons.baby_changing_station_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Sewa Mobil Lepas Kunci Harian',
        icon: Icons.directions_car_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF00796B)),
    TransactionCategory(
        label: 'Sewa Motor Harian untuk Wisatawan',
        icon: Icons.moped_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Sewa Apartemen Bulanan / Tahunan',
        icon: Icons.apartment_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Hasil Sewa Lapangan Futsal / Bulutangkis Swasta',
        icon: Icons.sports_soccer_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Hasil Sewa Kost Eksklusif Kamar Mandi Dalam',
        icon: Icons.house_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Hasil Sewa Ruko / Kios Tempat Usaha',
        icon: Icons.storefront_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF00796B)),
    TransactionCategory(
        label: 'Sewa Alat Sound System & Panggung Hajatan',
        icon: Icons.volume_up_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Sewa Baju Adat Anak & Pakaian Karnaval',
        icon: Icons.checkroom_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Hasil Sewa Lapangan Futsal Harian / Member',
        icon: Icons.sports_soccer_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Hasil Sewa Ruko / Kios Tempat Jualan',
        icon: Icons.storefront_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF00796B)),
    TransactionCategory(
        label: 'Sewa Apartemen Bulanan / Tahunan Keluarga',
        icon: Icons.apartment_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Sewa Baju Adat & Pakaian Karnaval Anak',
        icon: Icons.checkroom_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Sewa Kamera DSLR & Lensa Tele Harian',
        icon: Icons.camera_alt_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Sewa Tenda & Alat Camping Gunung Lengkap',
        icon: Icons.terrain_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Sewa Akun Zoom Premium / Canva Pro Bulanan',
        icon: Icons.computer_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Sewa Kamar Kost Eksklusif Kamar Mandi Dalam',
        icon: Icons.house_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Sewa Mesin Cuci Koin (Laundromat) / Vending Machine',
        icon: Icons.local_laundry_service_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Hasil Sewa Laptop Kantor Karyawan',
        icon: Icons.computer_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Hasil Sewa Mesin Cuci Steam Motor',
        icon: Icons.moped_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Hasil Sewa Sound System Event Pernikahan',
        icon: Icons.volume_up_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Hasil Sewa Tenda Pernikahan & Dekorasi',
        icon: Icons.home_work_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Hasil Sewa Kursi & Meja Pesta Hajatan',
        icon: Icons.chair_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Hasil Sewa Pakaian Pengantin & Rias Pengantin',
        icon: Icons.checkroom_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Hasil Sewa Gaun Prewedding & Jas Pria',
        icon: Icons.checkroom_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Hasil Sewa Baju Kebaya Wisuda Modern',
        icon: Icons.checkroom_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Hasil Sewa Mobil Avanza / Xenia Lepas Kunci',
        icon: Icons.directions_car_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Hasil Sewa Mobil Innova Reborn Harian',
        icon: Icons.directions_car_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Hasil Sewa Motor NMAX Harian Wisatawan',
        icon: Icons.moped_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFFD84315)),
    TransactionCategory(
        label: 'Hasil Sewa Motor Beat Harian Mahasiswa',
        icon: Icons.moped_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Hasil Sewa PlayStation 5 (PS5) Harian',
        icon: Icons.sports_esports_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Hasil Sewa PlayStation 4 (PS4) Mingguan',
        icon: Icons.sports_esports_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF8E24AA)),
    TransactionCategory(
        label: 'Hasil Sewa Nintendo Switch & Kaset Game',
        icon: Icons.sports_esports_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Hasil Sewa Kamera Mirrorless Sony A7III',
        icon: Icons.camera_alt_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Hasil Sewa Kamera Lensa Canon Tele',
        icon: Icons.camera_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Hasil Sewa Drone DJI Mavic Pro 2 Harian',
        icon: Icons.view_in_ar_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Hasil Sewa Tenda Dome Camping 4 Orang',
        icon: Icons.terrain_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Hasil Sewa Carrier / Tas Gunung Osprey',
        icon: Icons.backpack_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Hasil Sewa Buku Paket Sekolah & Novel',
        icon: Icons.book_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Hasil Sewa Kamar Kost Putri Bulanan',
        icon: Icons.house_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Hasil Sewa Kamar Kost Putra Bulanan',
        icon: Icons.house_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Hasil Sewa Guest House Harian Keluarga',
        icon: Icons.hotel_rounded,
        group: 'Pendapatan Pasif & Sewa',
        color: Color(0xFF5C6BC0)),
    TransactionCategory(
        label: 'Kiriman Keluarga / Pasangan',
        icon: Icons.family_restroom_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Uang Saku Sekolah / Kuliah',
        icon: Icons.backpack_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Beasiswa Pendidikan & Hibah Riset',
        icon: Icons.workspace_premium_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Angpao & Uang Lebaran / Hari Raya',
        icon: Icons.celebration_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Kado & Hadiah Acara',
        icon: Icons.card_giftcard_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Zakat, Infak & Sedekah Diterima',
        icon: Icons.spa_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Bansos & Subsidi Pemerintah',
        icon: Icons.assured_workload_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF3949AB)),
    TransactionCategory(
        label: 'Warisan & Hibah Harta',
        icon: Icons.real_estate_agent_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Santunan / Sumbangan Duka',
        icon: Icons.volunteer_activism_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Uang Bulanan dari Anak / Bakti Orang Tua',
        icon: Icons.volunteer_activism_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Santunan Beasiswa Yayasan Sosial',
        icon: Icons.workspace_premium_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Dana Hibah Organisasi, LSM & Komunitas',
        icon: Icons.groups_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Sumbangan Masuk Acara Hajatan / Pernikahan',
        icon: Icons.celebration_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Hadiah Give-away Media Sosial / Brand Promo',
        icon: Icons.card_giftcard_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Uang Jajan dari Kakek / Nenek / Paman',
        icon: Icons.family_restroom_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Dana Hibah Program Kreativitas Mahasiswa (PKM)',
        icon: Icons.school_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Sumbangan Kas Paguyuban / Rukun Tetangga',
        icon: Icons.groups_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Uang Saku Lebaran dari Paman / Tante',
        icon: Icons.celebration_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Bantuan Dana Korban Musibah / Kebakaran',
        icon: Icons.volunteer_activism_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Santunan Anak Yatim Hari Raya Keagamaan',
        icon: Icons.spa_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF388E3C)),
    TransactionCategory(
        label: 'Pemberian Sukarela Teman untuk Ongkos / Bensin',
        icon: Icons.clean_hands_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Uang Lebaran dari Kakek & Nenek',
        icon: Icons.celebration_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Santunan Duka Cita untuk Keluarga Musibah',
        icon: Icons.volunteer_activism_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Dana Subsidi Token Listrik Warga Kurang Mampu',
        icon: Icons.bolt_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Sumbangan Masuk Syukuran Aqiqah Anak',
        icon: Icons.child_care_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Uang Jajan dari Paman saat Liburan',
        icon: Icons.family_restroom_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Beasiswa Pendidikan Berprestasi dari Yayasan',
        icon: Icons.workspace_premium_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Donasi Sukarela Pengunjung Masjid',
        icon: Icons.mosque_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Pemberian Orang Tua untuk Tambahan Modal Usaha',
        icon: Icons.payments_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Uang Lebaran Hari Raya Idul Fitri',
        icon: Icons.celebration_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Uang Natal Hari Raya Natal Keluarga',
        icon: Icons.celebration_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Santunan Duka Cita Rukun Tetangga (RT)',
        icon: Icons.volunteer_activism_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Santunan Duka Cita Kantor Karyawan',
        icon: Icons.volunteer_activism_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Dana Subsidi Token Listrik Warga miskin',
        icon: Icons.bolt_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Dana Subsidi Sembako Murah Kelurahan',
        icon: Icons.storefront_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF00796B)),
    TransactionCategory(
        label: 'Sumbangan Masuk Syukuran Aqiqah Bayi',
        icon: Icons.child_care_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Sumbangan Masuk Syukuran Khitanan Anak',
        icon: Icons.child_care_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFFBC02D)),
    TransactionCategory(
        label: 'Uang Jajan dari Paman saat Libur Sekolah',
        icon: Icons.family_restroom_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Uang Jajan dari Tante saat Libur Sekolah',
        icon: Icons.family_restroom_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Beasiswa Pendidikan Jalur Prestasi Yayasan',
        icon: Icons.workspace_premium_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Beasiswa Pendidikan Jalur Kurang Mampu',
        icon: Icons.school_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Donasi Sukarela Pengunjung Masjid Jami',
        icon: Icons.mosque_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Donasi Sukarela Pengunjung Mushola Al-Ikhlas',
        icon: Icons.mosque_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Pemberian Orang Tua untuk Beli Motor Baru',
        icon: Icons.payments_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Pemberian Orang Tua untuk Tambahan Kost',
        icon: Icons.house_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Angpao Tahun Baru Imlek dari Keluarga',
        icon: Icons.celebration_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFD84315)),
    TransactionCategory(
        label: 'Uang Jajan Hari Raya Nyepi dari Keluarga',
        icon: Icons.celebration_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFFF9800)),
    TransactionCategory(
        label: 'Uang Jajan Hari Raya Waisak dari Keluarga',
        icon: Icons.celebration_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Bansos Program Keluarga Harapan (PKH)',
        icon: Icons.assured_workload_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Bansos Bantuan Pangan Non-Tunai (BPNT)',
        icon: Icons.shopping_basket_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Beasiswa Prestasi Akademik Kampus Bulanan',
        icon: Icons.workspace_premium_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Dana Hibah Riset Penelitian Kemendikbud',
        icon: Icons.science_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Hadiah Giveaway Follower Tiktok Kuis',
        icon: Icons.card_giftcard_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Hadiah Giveaway Channel Youtube Kuis',
        icon: Icons.card_giftcard_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFFF5722)),
    TransactionCategory(
        label: 'Uang Jajan dari Kakek saat Berkunjung',
        icon: Icons.family_restroom_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Uang Jajan dari Nenek saat Berkunjung',
        icon: Icons.family_restroom_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Dana Hibah Program Kreativitas Mahasiswa',
        icon: Icons.school_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Sumbangan Masuk Acara Khitanan Anak',
        icon: Icons.celebration_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Uang Bulanan dari Anak Kerja di Kota',
        icon: Icons.volunteer_activism_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Kiriman Bulanan dari Suami Kerja di Rantau',
        icon: Icons.volunteer_activism_rounded,
        group: 'Sosial, Hibah & Uang Saku',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Hasil Penjualan Padi / Beras',
        icon: Icons.grass_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Hasil Panen Sayur Harian',
        icon: Icons.yard_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Hasil Penjualan Buah-buahan Kebun',
        icon: Icons.apple_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Hasil Ternak Sapi Potong / Perah',
        icon: Icons.pets_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Hasil Ternak Kambing / Domba Hias',
        icon: Icons.pets_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Hasil Ternak Ayam Petelur & Jual Telur',
        icon: Icons.egg_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Hasil Ternak Ayam Potong Broiler',
        icon: Icons.bakery_dining_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFFFFA000)),
    TransactionCategory(
        label: 'Hasil Kolam Budidaya Ikan Lele',
        icon: Icons.water_drop_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF0097A7)),
    TransactionCategory(
        label: 'Hasil Kolam Budidaya Ikan Nila / Mas',
        icon: Icons.water_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Hasil Panen Tambak Udang / Bandeng',
        icon: Icons.waves_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Hasil Panen Madu Lebah Alami',
        icon: Icons.hive_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Penjualan Pupuk Kandang / Kompos',
        icon: Icons.agriculture_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF5D4037)),
    TransactionCategory(
        label: 'Hasil Kebun Kelapa Sawit',
        icon: Icons.forest_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Hasil Kebun Kopi / Cengkeh / Karet',
        icon: Icons.local_cafe_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Hasil Ternak Burung Kicau (Murai Batu/Lovebird)',
        icon: Icons.pets_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Hasil Penjualan Bibit Tanaman Hias & Anggrek',
        icon: Icons.yard_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Hasil Ternak Kelinci Hias & Kelinci Pedaging',
        icon: Icons.pets_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Hasil Panen Kebun Kelapa / Nira Gula Jawa',
        icon: Icons.yard_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Hasil Budidaya Jamur Tiram / Jamur Kuping',
        icon: Icons.grass_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Hasil Panen Kebun Pisang & Pepaya California',
        icon: Icons.yard_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Hasil Ternak Bebek Petelur & Jual Telur Asin',
        icon: Icons.pets_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Hasil Budidaya Ikan Gurame / Ikan Patin',
        icon: Icons.water_drop_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Hasil Panen Cabe Rawit & Bawang Merah',
        icon: Icons.grass_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Hasil Penjualan Rumput Pakan Ternak / Rumput Gajah',
        icon: Icons.grass_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Hasil Ternak Jangkrik & Ulat Hongkong Pakan Burung',
        icon: Icons.pets_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Hasil Penjualan Bibit Sayur & Media Tanam',
        icon: Icons.yard_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Hasil Panen Kebun Pisang & Pepaya Harian',
        icon: Icons.yard_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Hasil Panen Cabe Rawit & Tomat Kebun',
        icon: Icons.grass_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Hasil Budidaya Jamur Tiram / Kuping Bulanan',
        icon: Icons.grass_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Hasil Penjualan Bibit Sayur & Tanaman Herbal',
        icon: Icons.yard_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Hasil Panen Kebun Singkong & Ubi Jalar',
        icon: Icons.grass_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF558B2F)),
    TransactionCategory(
        label: 'Hasil Ternak Burung Murai Batu & Lovebird',
        icon: Icons.pets_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Hasil Panen Tambak Udang Windu & Vaname',
        icon: Icons.water_drop_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Hasil Ternak Kambing PE & Jual Susu Kambing',
        icon: Icons.pets_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Hasil Panen Cabe Merah Besar Kebun',
        icon: Icons.grass_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Hasil Panen Cabe Rawit Setan Merah',
        icon: Icons.grass_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFFD84315)),
    TransactionCategory(
        label: 'Hasil Panen Cabe Hijau Keriting Kebun',
        icon: Icons.grass_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Hasil Panen Bawang Merah Kering Sawah',
        icon: Icons.grass_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Hasil Panen Bawang Putih Kering Sawah',
        icon: Icons.grass_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Hasil Panen Kebun Pisang Kepok & Raja',
        icon: Icons.yard_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Hasil Panen Kebun Pepaya California Manis',
        icon: Icons.yard_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF8BC34A)),
    TransactionCategory(
        label: 'Hasil Panen Kebun Mangga Harum Manis',
        icon: Icons.yard_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFFFBC02D)),
    TransactionCategory(
        label: 'Hasil Panen Kebun Singkong Gajah Harian',
        icon: Icons.grass_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF558B2F)),
    TransactionCategory(
        label: 'Hasil Panen Kebun Ubi Jalar Madu Cilembu',
        icon: Icons.grass_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Hasil Budidaya Jamur Tiram Putih Bersih',
        icon: Icons.grass_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Hasil Budidaya Jamur Kuping Hitam Sawah',
        icon: Icons.grass_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Hasil Ternak Ayam Kampung Jual Telur',
        icon: Icons.pets_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Hasil Ternak Ayam Broiler Pedaging Potong',
        icon: Icons.pets_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Hasil Ternak Bebek Peking Jual Telur',
        icon: Icons.pets_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Hasil Ternak Bebek Lokal Jual Telur Asin',
        icon: Icons.pets_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Hasil Ternak Kambing Jawa Randu Pedaging',
        icon: Icons.pets_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Hasil Ternak Kambing Etawa Susu Murni',
        icon: Icons.pets_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFFFF8F00)),
    TransactionCategory(
        label: 'Hasil Ternak Kelinci Hias Anggora/Rex',
        icon: Icons.pets_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Hasil Ternak Kelinci Pedaging Bulanan',
        icon: Icons.pets_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Hasil Ternak Burung Murai Batu Kicau',
        icon: Icons.pets_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Hasil Ternak Burung Lovebird Warna Warni',
        icon: Icons.pets_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Hasil Budidaya Ikan Gurame Kolam Terpal',
        icon: Icons.water_drop_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Hasil Budidaya Ikan Patin Kolam Tanah',
        icon: Icons.water_drop_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF0D47A1)),
    TransactionCategory(
        label: 'Hasil Penjualan Rumput Gajah Pakan Sapi',
        icon: Icons.grass_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Hasil Penjualan Rumput Odot Pakan Kambing',
        icon: Icons.grass_rounded,
        group: 'Pertanian & Peternakan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Jasa Tukang Bangunan / Renovasi',
        icon: Icons.handyman_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Jasa Kelistrikan & Pasang Lampu Rumah',
        icon: Icons.bolt_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Jasa Tukang Kayu / Pembuatan Mebel',
        icon: Icons.construction_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Jasa Tukang Las / Pagar / Kanopi',
        icon: Icons.hardware_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Jasa Service Mesin Cuci / Kulkas',
        icon: Icons.settings_suggest_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Jasa Service AC Panggilan',
        icon: Icons.ac_unit_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Jasa Sumur Bor & Perbaikan Pompa Air',
        icon: Icons.water_drop_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Jasa Bersih Taman & Potong Rumput',
        icon: Icons.yard_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Jasa Cuci Sepatu & Tas Profesional',
        icon: Icons.clean_hands_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Jasa Pijat Urut / Refleksi Panggilan',
        icon: Icons.self_improvement_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Jasa Sol Sepatu Keliling',
        icon: Icons.construction_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF5D4037)),
    TransactionCategory(
        label: 'Jasa Asah Pisau / Gunting Panggilan',
        icon: Icons.build_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Jasa Pasang Wallpaper & Cat Dinding Interior',
        icon: Icons.format_paint_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF00BCD4)),
    TransactionCategory(
        label: 'Jasa Duplikat Kunci & Panggilan Rumah',
        icon: Icons.vpn_key_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Jasa Cuci Karpet & Sofa Rumah Panggilan',
        icon: Icons.clean_hands_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Jasa Pasang & Service Parabola / CCTV',
        icon: Icons.videocam_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Jasa Service Kompor Gas & Oven Panggilan',
        icon: Icons.local_fire_department_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFFFF9800)),
    TransactionCategory(
        label: 'Jasa Asah Gergaji & Alat Pertukangan',
        icon: Icons.build_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Jasa Pasang & Reparasi AC Panggilan',
        icon: Icons.ac_unit_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Jasa Service Pompa Air & Sumur Bor',
        icon: Icons.plumbing_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Jasa Pembersih Kaca Gedung Bertingkat',
        icon: Icons.clean_hands_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Jasa Penebangan Pohon & Pemangkasan Dahan',
        icon: Icons.grass_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Jasa Sedot WC & Pembersihan Saluran Mampet',
        icon: Icons.handyman_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Jasa Pasang Baja Ringan & Kanopi Rumah',
        icon: Icons.construction_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Jasa Service Kulkas & Mesin Cuci Panggilan',
        icon: Icons.build_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Jasa Service Mesin Cuci Panggilan',
        icon: Icons.settings_suggest_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Jasa Pasang Kanopi & Pagar Besi Rumah',
        icon: Icons.construction_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Jasa Penebangan Pohon Pekarangan Rumah',
        icon: Icons.grass_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Jasa Sol Sepatu & Sandal Keliling',
        icon: Icons.build_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Jasa Sedot WC & Perbaikan Got Tersumbat',
        icon: Icons.handyman_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Jasa Duplikat Kunci Pintu & Motor',
        icon: Icons.vpn_key_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Jasa Cuci Karpet & Sofa Panggilan',
        icon: Icons.clean_hands_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Jasa Reparasi Kursi Sofa & Kasur Busa',
        icon: Icons.chair_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Jasa Pengecatan Dinding & Plafon Rumah',
        icon: Icons.format_paint_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF00BCD4)),
    TransactionCategory(
        label: 'Jasa Pasang & Service Pompa Air Jet Pump',
        icon: Icons.plumbing_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Jasa Cuci Karpet Masjid & Mushola',
        icon: Icons.clean_hands_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Jasa Cuci Sofa Kain & Sofa Kulit',
        icon: Icons.clean_hands_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Jasa Cuci Kasur Springbed Panggilan',
        icon: Icons.clean_hands_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Jasa Sedot WC Penuh & Got Mampet',
        icon: Icons.handyman_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Jasa Service AC Split & AC Standing',
        icon: Icons.ac_unit_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Jasa Service Pompa Air Jet Pump Sanyo',
        icon: Icons.plumbing_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Jasa Service Sumur Bor & Pengeboran',
        icon: Icons.plumbing_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Jasa Service Kompor Gas & Oven Quantum',
        icon: Icons.local_fire_department_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFFFF9800)),
    TransactionCategory(
        label: 'Jasa Service Kulkas Dua Pintu Panggilan',
        icon: Icons.build_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Jasa Service Mesin Cuci Front Load',
        icon: Icons.settings_suggest_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Jasa Pasang Wallpaper Dinding Rumah',
        icon: Icons.format_paint_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF00BCD4)),
    TransactionCategory(
        label: 'Jasa Pengecatan Interior & Eksterior',
        icon: Icons.format_paint_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF00796B)),
    TransactionCategory(
        label: 'Jasa Pasang Baja Ringan Atap Rumah',
        icon: Icons.construction_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Jasa Pasang Kanopi Minimalis Depan Rumah',
        icon: Icons.construction_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Jasa Tukang Las Pagar & Teralis Jendela',
        icon: Icons.hardware_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Jasa Tukang Kayu Pembuatan Lemari Custom',
        icon: Icons.construction_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Jasa Tukang Bangunan Borongan Rumah',
        icon: Icons.handyman_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Jasa Pasang Instalasi Listrik Baru',
        icon: Icons.bolt_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Jasa Pasang Lampu Hias & Fitting Baru',
        icon: Icons.lightbulb_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Jasa Pembersih Kaca Gedung Ruko Tinggi',
        icon: Icons.clean_hands_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Jasa Penebangan Pohon Halaman Rumah',
        icon: Icons.grass_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Jasa Pemangkasan Dahan Pohon Rindang',
        icon: Icons.grass_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Jasa Bersih Taman & Penataan Rumput',
        icon: Icons.yard_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Jasa Potong Rumput Halaman Lapangan',
        icon: Icons.yard_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFF558B2F)),
    TransactionCategory(
        label: 'Jasa Cuci Sepatu & Sandal Deep Clean',
        icon: Icons.clean_hands_rounded,
        group: 'Jasa & Pertukangan',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Penjualan Bubur Ayam / Nasi Uduk Sarapan',
        icon: Icons.restaurant_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Penjualan Bakso / Mie Ayam Keliling',
        icon: Icons.dinner_dining_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Penjualan Gorengan & Jajanan Pasar Sore',
        icon: Icons.cookie_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Penjualan Es Teh Solo / Boba Kekinian',
        icon: Icons.local_drink_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Jasa Catering Prasmanan Event / Pernikahan',
        icon: Icons.flatware_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Penjualan Kue Ulang Tahun & Custom Cake',
        icon: Icons.cake_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Hasil Penjualan Lauk Matang Harian',
        icon: Icons.lunch_dining_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Pendapatan Warung Makan / Tegal (Warteg)',
        icon: Icons.storefront_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Penjualan Martabak Manis & Telur Malam',
        icon: Icons.cake_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFFF9800)),
    TransactionCategory(
        label: 'Penjualan Keripik & Camilan Kiloan',
        icon: Icons.bakery_dining_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Penjualan Nasi Goreng & Bakmi Jawa Malam',
        icon: Icons.restaurant_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Penjualan Seblak & Bakso Aci Pedas',
        icon: Icons.restaurant_menu_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Penjualan Kopi Susu Gula Aren Botolan',
        icon: Icons.coffee_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Penjualan Roti & Kue Kering Lebaran',
        icon: Icons.bakery_dining_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Penjualan Jus Buah & Sop Buah Segar',
        icon: Icons.local_drink_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Omzet Waralaba Fried Chicken Lokal',
        icon: Icons.restaurant_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Penjualan Pecel Lele & Nasi Uduk Malam',
        icon: Icons.restaurant_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Penjualan Siomay & Batagor Khas Bandung',
        icon: Icons.soup_kitchen_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Penjualan Kue Basah & Snack Box Rapat',
        icon: Icons.cake_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Penjualan Es Kelapa Muda & Es Degan Segar',
        icon: Icons.local_drink_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Pendapatan Jual Jamu Gendong Tradisional',
        icon: Icons.local_drink_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Penjualan Angkringan Nasi Kucing & Wedang',
        icon: Icons.coffee_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Penjualan Kerupuk & Kripik Kampung Kiloan',
        icon: Icons.bakery_dining_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Penjualan Nasi Uduk & Bubur Ayam Sarapan',
        icon: Icons.restaurant_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Penjualan Sate Ayam & Sate Kambing Madura',
        icon: Icons.flatware_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Penjualan Ketoprak & Gado-Gado Khas Jakarta',
        icon: Icons.soup_kitchen_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Penjualan Es Kelapa Muda & Sop Buah Segar',
        icon: Icons.local_drink_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Penjualan Kue Basah & Jajanan Pasar Tradisional',
        icon: Icons.cake_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Penjualan Keripik Singkong & Pisang Kiloan',
        icon: Icons.bakery_dining_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Jasa Katering Harian Kantoran & Pabrik',
        icon: Icons.lunch_dining_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Penjualan Pempek Palembang & Tekwan',
        icon: Icons.dinner_dining_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Penjualan Roti Bakar Bandung & Pisang Keju',
        icon: Icons.cake_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFFF9800)),
    TransactionCategory(
        label: 'Penjualan Jus Buah Segar & Salad Buah',
        icon: Icons.local_drink_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Penjualan Bubur Ayam Kuning Cirebon',
        icon: Icons.restaurant_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Penjualan Bubur Kacang Hijau & Ketan Hitam',
        icon: Icons.restaurant_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Penjualan Nasi Uduk Betawi Lauk Komplit',
        icon: Icons.restaurant_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF00796B)),
    TransactionCategory(
        label: 'Penjualan Nasi Goreng Gila & Nasi Gila',
        icon: Icons.restaurant_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Penjualan Mie Ayam Bakso Wonogiri',
        icon: Icons.restaurant_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Penjualan Bakso Sapi Solo & Bakso Urat',
        icon: Icons.restaurant_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Penjualan Pecel Lele Lamongan & Bebek',
        icon: Icons.restaurant_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFFF9800)),
    TransactionCategory(
        label: 'Penjualan Sate Ayam Madura Bumbu Kacang',
        icon: Icons.restaurant_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Penjualan Sate Kambing Solo Bumbu Kecap',
        icon: Icons.restaurant_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF5D4037)),
    TransactionCategory(
        label: 'Penjualan Gado-Gado Betawi Ulek Kacang',
        icon: Icons.restaurant_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Penjualan Ketoprak Cirebon Bumbu Kacang',
        icon: Icons.restaurant_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Penjualan Kue Basah Tradisional Nasi Box',
        icon: Icons.cake_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Penjualan Kue Kering Nastar & Kastengel',
        icon: Icons.cake_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Penjualan Roti Manis & Roti Tawar Bakery',
        icon: Icons.bakery_dining_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Penjualan Es Kelapa Muda Gula Aren',
        icon: Icons.local_drink_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Penjualan Sop Buah & Es Campur Segar',
        icon: Icons.local_drink_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Penjualan Jus Alpukat & Jus Mangga Sehat',
        icon: Icons.local_drink_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Penjualan Kripik Singkong Balado Kiloan',
        icon: Icons.bakery_dining_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Penjualan Kripik Tempe Renyah Kiloan',
        icon: Icons.bakery_dining_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Penjualan Kerupuk Udang & Kerupuk Kampung',
        icon: Icons.bakery_dining_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Penjualan Pempek Palembang Kapal Selam',
        icon: Icons.dinner_dining_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Penjualan Tekwan Khas Palembang Segar',
        icon: Icons.dinner_dining_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Penjualan Siomay Bandung Bumbu Kacang',
        icon: Icons.soup_kitchen_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Penjualan Batagor Bandung Renyah Gurih',
        icon: Icons.soup_kitchen_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFD84315)),
    TransactionCategory(
        label: 'Penjualan Angkringan Sego Kucing Jogja',
        icon: Icons.restaurant_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Penjualan Angkringan Wedang Jahe Susu',
        icon: Icons.local_cafe_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Penjualan Fried Chicken Lokal Krispi Tepung',
        icon: Icons.restaurant_rounded,
        group: 'Kuliner & Makanan',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Pendapatan Ojek Online (GoRide/GrabRide)',
        icon: Icons.moped_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Pendapatan Taksi Online (GoCar/GrabCar)',
        icon: Icons.local_taxi_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Pendapatan Driver Delivery Makanan (GoFood/GrabFood)',
        icon: Icons.delivery_dining_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Pendapatan Kurir Ekspedisi (J&T/JNE/Sicepat)',
        icon: Icons.local_shipping_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Pendapatan Sopir Truk / Angkutan Logistik',
        icon: Icons.local_shipping_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Hasil Sewa Mobil / Rental Harian',
        icon: Icons.car_rental_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Jasa Antar Jemput Anak Sekolah',
        icon: Icons.directions_bus_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Jasa Antar Jemput Karyawan Kantor',
        icon: Icons.directions_car_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Hasil Tarik Angkot / Minibus Umum',
        icon: Icons.directions_bus_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFFE65100)),
    TransactionCategory(
        label: 'Jasa Angkut Barang Pick-Up Pindahan',
        icon: Icons.local_shipping_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Hasil Sewa Motor Matic Harian / Mingguan',
        icon: Icons.moped_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFFD84315)),
    TransactionCategory(
        label: 'Pendapatan Driver Deliveree / Lalamove Cargo',
        icon: Icons.local_shipping_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Jasa Ojek Langganan Pengantaran Karyawan',
        icon: Icons.moped_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Jasa Angkut Pasir & Bahan Bangunan Truk',
        icon: Icons.local_shipping_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Hasil Sewa Sepeda Motor Listrik Harian',
        icon: Icons.electric_moped_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Jasa Jemput Bandara / Stasiun Private',
        icon: Icons.local_taxi_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Pendapatan Sewa Truk Fuso / Truk Engkel Logistik',
        icon: Icons.local_shipping_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Jasa Kurir Panggilan Khusus Dokumen Rahasia',
        icon: Icons.mail_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Pendapatan Sopir Cadangan Perjalanan Luar Kota',
        icon: Icons.directions_car_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Sewa Parkir Bus Pariwisata / Truk Kontainer',
        icon: Icons.local_parking_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Hasil Tarik Taksi Bandara Premium',
        icon: Icons.local_taxi_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF0D47A1)),
    TransactionCategory(
        label: 'Jasa Antar Jemput Anak Sekolah TK & SD',
        icon: Icons.school_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Jasa Kurir Panggilan Antar Makanan Rumah',
        icon: Icons.delivery_dining_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Jasa Driver Pengganti Perjalanan Luar Kota',
        icon: Icons.directions_car_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Hasil Sewa Truk Colt Diesel Muatan Material',
        icon: Icons.local_shipping_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Jasa Ojek Motor Khusus Pengantaran Barang Pasar',
        icon: Icons.moped_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Sewa Parkir Bulanan Mobil Tetangga di Garasi',
        icon: Icons.local_parking_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Jasa Pindahan Rumah Sewa Truk & Tenaga Angkut',
        icon: Icons.local_shipping_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Pendapatan Sopir Truk Tangki Air Bersih',
        icon: Icons.water_drop_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Jasa Derek Motor Mogok Panggilan Harian',
        icon: Icons.moped_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Hasil Tarik Taksi Blue Bird Bandara',
        icon: Icons.local_taxi_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Hasil Tarik Taksi Express Bandara',
        icon: Icons.local_taxi_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Jasa Antar Jemput Anak Sekolah TK Swasta',
        icon: Icons.school_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Jasa Antar Jemput Anak Sekolah SD Swasta',
        icon: Icons.school_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Jasa Kurir Panggilan Antar Makanan Ojol',
        icon: Icons.delivery_dining_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFFFF5722)),
    TransactionCategory(
        label: 'Jasa Kurir Panggilan Antar Dokumen Instant',
        icon: Icons.mail_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Jasa Driver Pengganti Perjalanan Malam',
        icon: Icons.directions_car_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Hasil Sewa Truk Colt Diesel Engkel',
        icon: Icons.local_shipping_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Hasil Sewa Truk Colt Diesel Double',
        icon: Icons.local_shipping_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Jasa Ojek Motor Khusus Pengantaran Barang',
        icon: Icons.moped_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Jasa Ojek Motor Khusus Belanjaan Pasar',
        icon: Icons.moped_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF558B2F)),
    TransactionCategory(
        label: 'Sewa Parkir Mobil Tetangga di Garasi',
        icon: Icons.local_parking_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Sewa Parkir Motor Bulanan Kos Mahasiswa',
        icon: Icons.local_parking_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Jasa Pindahan Kost Truk Box Engkel',
        icon: Icons.local_shipping_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Jasa Pindahan Kantor Truk Fuso Box',
        icon: Icons.local_shipping_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF5D4037)),
    TransactionCategory(
        label: 'Jasa Sopir Truk Tangki Air Bersih Perumahan',
        icon: Icons.water_drop_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Jasa Sopir Truk Tangki BBM Pertamina',
        icon: Icons.local_gas_station_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Jasa Derek Motor Mogok Panggilan Malam',
        icon: Icons.moped_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFFD84315)),
    TransactionCategory(
        label: 'Jasa Derek Mobil Mogok Panggilan Tol',
        icon: Icons.local_shipping_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Jasa Sewa Sepeda Motor Listrik Harian Wisata',
        icon: Icons.electric_moped_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Jasa Sewa Sepeda Motor Listrik Mingguan Kurir',
        icon: Icons.electric_moped_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Jasa Jemput Stasiun Gambir Private Car',
        icon: Icons.directions_car_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Jasa Jemput Stasiun Senen Private Car',
        icon: Icons.directions_car_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Pendapatan Driver Deliveree Cargo L300',
        icon: Icons.local_shipping_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Pendapatan Driver Lalamove Cargo GranMax',
        icon: Icons.local_shipping_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Jasa Ojek Langganan Pengantaran Ibu Guru',
        icon: Icons.moped_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Jasa Ojek Langganan Pengantaran Karyawan Pabrik',
        icon: Icons.moped_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Jasa Angkut Pasir Truk Double Engkel',
        icon: Icons.local_shipping_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Jasa Angkut Batu Truk Double Engkel',
        icon: Icons.local_shipping_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFF455A64)),
    TransactionCategory(
        label: 'Sewa Parkir Bus Pariwisata Bulanan Lapangan',
        icon: Icons.local_parking_rounded,
        group: 'Transportasi & Logistik',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Insentif Penulisan Buku Ajar / Buku Referensi',
        icon: Icons.book_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Royalti Penjualan Hak Paten Ilmiah Dosen',
        icon: Icons.copyright_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Bantuan Dana Program Indonesia Pintar (PIP)',
        icon: Icons.school_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Honor Korektor Ujian & Asisten Dosen',
        icon: Icons.school_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Honor Pemateri Seminar / Talkshow Kampus',
        icon: Icons.record_voice_over_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Hasil Terjemahan Jurnal & Artikel Ilmiah',
        icon: Icons.translate_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Dana Penelitian Hibah Kemendikbud / Ristek',
        icon: Icons.science_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Pendapatan Jasa Edit & Proofreading Skripsi',
        icon: Icons.rate_review_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Insentif Publikasi Jurnal Terakreditasi SINTA / Scopus',
        icon: Icons.workspace_premium_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Honor Instruktur Bimbel / Tryout UTBK',
        icon: Icons.school_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Honor Narasumber Talkshow Pendidikan',
        icon: Icons.record_voice_over_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Honor Mentor Bootcamp Coding / Desain',
        icon: Icons.computer_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Hasil Penjualan Ringkasan Materi & Flashcard',
        icon: Icons.note_alt_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Honor Juri Lomba Karya Tulis Ilmiah',
        icon: Icons.gavel_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Hasil Translate Jurnal Bahasa Inggris - Indonesia',
        icon: Icons.translate_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Honor Pembimbing KKN / Skripsi Mahasiswa',
        icon: Icons.school_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Insentif Hibah Pengabdian Masyarakat Dosen',
        icon: Icons.groups_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Honor Pembuat Soal Ujian / Try Out Bimbel',
        icon: Icons.description_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Royalti Buku Pelajaran Kurikulum Merdeka',
        icon: Icons.menu_book_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Honor Pengawas Ujian Nasional / UTBK',
        icon: Icons.assignment_ind_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Honor Narasumber Talkshow Pendidikan Nasional',
        icon: Icons.record_voice_over_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Honor Narasumber Seminar Literasi Digital',
        icon: Icons.record_voice_over_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Honor Mentor Bootcamp Frontend Developer',
        icon: Icons.computer_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Honor Mentor Bootcamp Product Manager',
        icon: Icons.computer_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Hasil Penjualan Ringkasan Catatan Kuliah',
        icon: Icons.note_alt_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Hasil Penjualan Flashcard Kosa Kata Inggris',
        icon: Icons.note_alt_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Honor Juri Lomba Essai Ilmiah Nasional',
        icon: Icons.gavel_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Honor Juri Olimpiade Sains Tingkat Kota',
        icon: Icons.gavel_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Hasil Translate Jurnal Kedokteran Inggris',
        icon: Icons.translate_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Hasil Translate Dokumen Hukum Resmi',
        icon: Icons.translate_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF0D47A1)),
    TransactionCategory(
        label: 'Honor Pembimbing Skripsi Mahasiswa Akhir',
        icon: Icons.school_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Honor Pembimbing Laporan PKL SMK',
        icon: Icons.school_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Insentif Hibah Penelitian Terapan Dosen',
        icon: Icons.science_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Insentif Hibah Publikasi Internasional Scopus',
        icon: Icons.workspace_premium_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Honor Pembuat Soyout UTBK Bimbel',
        icon: Icons.description_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Honor Pembuat Kunci Jawaban Soal Ujian',
        icon: Icons.description_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Royalti Buku Pelajaran Matematika SMK',
        icon: Icons.menu_book_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Royalti Buku Pelajaran Bahasa Inggris SD',
        icon: Icons.menu_book_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Honor Pengawas Ujian Mandiri Kampus',
        icon: Icons.assignment_ind_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Honor Pengawas Ujian TOEFL/IELTS',
        icon: Icons.assignment_ind_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Honor Asisten Laboratorium Fisika Dasar',
        icon: Icons.science_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Honor Asisten Praktikum Kimia Organik',
        icon: Icons.science_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Honor Korektor LJK Ujian Sekolah',
        icon: Icons.check_circle_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Honor Korektor Tugas Kuliah Mahasiswa',
        icon: Icons.check_circle_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Honor Instruktur Bimbel Matematika SMA',
        icon: Icons.school_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Honor Instruktur Bimbel Fisika SMA',
        icon: Icons.school_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Hasil Jasa Edit Jurnal Ilmiah SINTA',
        icon: Icons.rate_review_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Hasil Jasa Proofreading Essay Beasiswa',
        icon: Icons.rate_review_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Dana Penelitian Hibah Ristekdikti Nasional',
        icon: Icons.science_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Dana Pengabdian Masyarakat Hibah Kampus',
        icon: Icons.groups_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Bantuan Dana Program Indonesia Pintar SD',
        icon: Icons.school_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Bantuan Dana Program Indonesia Pintar SMP',
        icon: Icons.school_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Bantuan Dana Program Indonesia Pintar SMA',
        icon: Icons.school_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Dana Hibah Program Kreativitas Mahasiswa PKM-K',
        icon: Icons.workspace_premium_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Dana Hibah Program Kreativitas Mahasiswa PKM-RE',
        icon: Icons.workspace_premium_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Honor Pembicara Webinar Upgrade Skill',
        icon: Icons.record_voice_over_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Honor Pembicara Workshop Desain Grafis',
        icon: Icons.record_voice_over_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Hasil Jasa Terjemahan Abstrak Skripsi',
        icon: Icons.translate_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Hasil Jasa Olah Data Statistik SPSS Client',
        icon: Icons.calculate_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Hasil Jasa Olah Data SmartPLS Tugas Akhir',
        icon: Icons.calculate_rounded,
        group: 'Pendidikan & Riset',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Pengembalian Piutang (Tagihan)',
        icon: Icons.account_balance_wallet_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Pencairan Pinjaman (Bank/KTA)',
        icon: Icons.account_balance_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF5E35B1)),
    TransactionCategory(
        label: 'Dana Talangan & Arisan',
        icon: Icons.diversity_3_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Pengembalian Uang DP (Down Payment)',
        icon: Icons.replay_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Pencairan Pegadaian',
        icon: Icons.monetization_on_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Pinjaman Tanpa Bunga dari Teman / Kerabat',
        icon: Icons.handshake_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Penerimaan Uang Arisan Bulanan Komplek / Kerja',
        icon: Icons.diversity_3_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Pencairan Kredit Usaha Rakyat (KUR) Mikro',
        icon: Icons.account_balance_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Talangan Pembelian Barang Rekan Kerja',
        icon: Icons.shopping_cart_checkout_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Penerimaan Uang Arisan Keluarga Bulanan',
        icon: Icons.diversity_3_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Dana Pinjaman Online Berizin OJK',
        icon: Icons.phone_android_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Pencairan Gadai Emas / Logam Mulia',
        icon: Icons.diamond_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Pengembalian Uang Jaminan Sewa (Refundable Deposit)',
        icon: Icons.replay_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Talangan Bensin & Toll Perjalanan Bersama',
        icon: Icons.local_gas_station_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Pencairan Pinjaman Koperasi Karyawan',
        icon: Icons.people_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Pencairan Limit Paylater Jadi Uang Tunai (Gestun)',
        icon: Icons.monetization_on_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Penerimaan Uang Arisan RT Bulanan Ibu-Ibu',
        icon: Icons.diversity_3_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Dana Talangan Tiket Mudik Lebaran Keluarga',
        icon: Icons.commute_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Pengembalian Uang Pinjaman Teman Kuliah',
        icon: Icons.handshake_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Talangan Pembayaran Tagihan Wifi Komplek',
        icon: Icons.wifi_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Talangan Belanja Sembako Acara Hajatan Tetangga',
        icon: Icons.shopping_cart_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF0097A7)),
    TransactionCategory(
        label: 'Penerimaan Pinjaman Lunak Tanpa Bunga Kerabat',
        icon: Icons.handshake_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Pencairan Pinjaman Koperasi Karyawan Swasta',
        icon: Icons.people_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Pencairan Pinjaman Koperasi Warga Sejahtera',
        icon: Icons.people_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Pencairan Limit Shopee Paylater Jadi Tunai',
        icon: Icons.monetization_on_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFFE65100)),
    TransactionCategory(
        label: 'Pencairan Limit GoPay Later Jadi Tunai',
        icon: Icons.monetization_on_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Penerimaan Uang Arisan RT Bulanan Ibu',
        icon: Icons.diversity_3_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Penerimaan Uang Arisan PKK Bulanan Ibu',
        icon: Icons.diversity_3_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFFAB47BC)),
    TransactionCategory(
        label: 'Dana Talangan Tiket Mudik Kereta Api',
        icon: Icons.train_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Dana Talangan Tiket Mudik Pesawat Udara',
        icon: Icons.flight_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF0D47A1)),
    TransactionCategory(
        label: 'Pengembalian Uang Pinjaman Teman Kuliah Dulu',
        icon: Icons.handshake_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Pengembalian Uang Pinjaman Teman Kerja Dulu',
        icon: Icons.handshake_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF00897B)),
    TransactionCategory(
        label: 'Talangan Pembayaran Wifi Indihome Bulanan',
        icon: Icons.wifi_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF1976D2)),
    TransactionCategory(
        label: 'Talangan Pembayaran Listrik PLN Pascabayar',
        icon: Icons.bolt_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Talangan Belanja Sembako Acara Khitanan Tetangga',
        icon: Icons.shopping_cart_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF0097A7)),
    TransactionCategory(
        label: 'Talangan Belanja Sembako Acara Tahlilan Tetangga',
        icon: Icons.shopping_cart_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF00796B)),
    TransactionCategory(
        label: 'Penerimaan Pinjaman Lunak Keluarga Tanpa Bunga',
        icon: Icons.handshake_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Penerimaan Pinjaman Lunak Kerabat Tanpa Bunga',
        icon: Icons.handshake_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF1E88E5)),
    TransactionCategory(
        label: 'Pencairan Pinjaman Bank Mandiri KTA',
        icon: Icons.account_balance_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF0D47A1)),
    TransactionCategory(
        label: 'Pencairan Pinjaman Bank BRI Kupedes',
        icon: Icons.account_balance_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Pencairan Pinjaman Bank BNI Griya',
        icon: Icons.account_balance_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF1A237E)),
    TransactionCategory(
        label: 'Pencairan Gadai Emas Pegadaian Kantor Cabang',
        icon: Icons.diamond_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Pencairan Gadai BPKB Motor Pegadaian Cabang',
        icon: Icons.motorcycle_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFFD84315)),
    TransactionCategory(
        label: 'Penerimaan Uang Arisan Bulanan Komplek Indah',
        icon: Icons.diversity_3_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFFC2185B)),
    TransactionCategory(
        label: 'Penerimaan Uang Arisan Bulanan Kantor Divisi',
        icon: Icons.diversity_3_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Pencairan Kredit Usaha Rakyat KUR Mandiri',
        icon: Icons.account_balance_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF0D47A1)),
    TransactionCategory(
        label: 'Pencairan Kredit Usaha Rakyat KUR BRI',
        icon: Icons.account_balance_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Talangan Pembelian Makan Siang Kantor Teman',
        icon: Icons.flatware_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Talangan Pembelian Kopi Sore Kantor Teman',
        icon: Icons.coffee_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Talangan Pembelian Kado Pernikahan Sahabat',
        icon: Icons.card_giftcard_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Talangan Pembelian Hampers Lebaran Sahabat',
        icon: Icons.card_giftcard_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Pengembalian Uang DP Kost Batal Masuk',
        icon: Icons.replay_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Pengembalian Uang DP Motor Batal Beli',
        icon: Icons.replay_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Talangan Tiket Nonton Konser Musik Bersama',
        icon: Icons.confirmation_number_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF9C27B0)),
    TransactionCategory(
        label: 'Talangan Tiket Nonton Bioskop XXI Bersama',
        icon: Icons.movie_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Pinjaman Modal Usaha Tanpa Jaminan Kerabat',
        icon: Icons.handshake_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Pencairan Gadai Laptop Asus Pegadaian',
        icon: Icons.computer_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Pencairan Gadai Kamera Canon Pegadaian',
        icon: Icons.camera_alt_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Pencairan Pinjaman Online Kredivo Berizin OJK',
        icon: Icons.phone_android_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFFD32F2F)),
    TransactionCategory(
        label: 'Pencairan Pinjaman Online Akulaku Berizin OJK',
        icon: Icons.phone_android_rounded,
        group: 'Pinjaman & Talangan',
        color: Color(0xFFE53935)),
    TransactionCategory(
        label: 'Temuan Uang & Rezeki Nomplok',
        icon: Icons.savings_rounded,
        group: 'Lain-lain',
        color: Color(0xFFFBC02D)),
    TransactionCategory(
        label: 'Hadiah Kompetisi & Turnamen',
        icon: Icons.emoji_events_rounded,
        group: 'Lain-lain',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Hasil Daur Ulang & Jual Sampah',
        icon: Icons.recycling_rounded,
        group: 'Lain-lain',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Hasil Lelang Barang Koleksi',
        icon: Icons.gavel_rounded,
        group: 'Lain-lain',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Piutang',
        icon: Icons.call_received_rounded,
        group: 'Lain-lain',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Kategori Lain',
        icon: Icons.more_horiz_rounded,
        group: 'Lain-lain',
        color: Color(0xFF9E9E9E)),
    TransactionCategory(
        label: 'Uang Temuan Dompet / Uang Jalan Tanpa Pemilik',
        icon: Icons.search_rounded,
        group: 'Lain-lain',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Pencairan Hasil Celengan Bambu / Tanah Liat',
        icon: Icons.savings_rounded,
        group: 'Lain-lain',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Hasil Penjualan Barang Kuno / Antik',
        icon: Icons.gavel_rounded,
        group: 'Lain-lain',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Kembalian Belanja / Uang Receh Sisa Transaksi',
        icon: Icons.monetization_on_rounded,
        group: 'Lain-lain',
        color: Color(0xFFFBC02D)),
    TransactionCategory(
        label: 'Klaim Refund Tiket Event / Konser Musik',
        icon: Icons.confirmation_number_rounded,
        group: 'Lain-lain',
        color: Color(0xFF9C27B0)),
    TransactionCategory(
        label: 'Hadiah Undian Bungkus Produk / Kuis SMS',
        icon: Icons.card_giftcard_rounded,
        group: 'Lain-lain',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Pemberian Sukarela Uang Tips dari Orang Asing',
        icon: Icons.clean_hands_rounded,
        group: 'Lain-lain',
        color: Color(0xFF00BCD4)),
    TransactionCategory(
        label: 'Pencairan Klaim Jaminan Kesehatan Swasta',
        icon: Icons.health_and_safety_rounded,
        group: 'Lain-lain',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Hasil Penjualan Koran & Kardus Bekas',
        icon: Icons.recycling_rounded,
        group: 'Lain-lain',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Hasil Tukar Tambah HP / Gadget Lama',
        icon: Icons.phone_android_rounded,
        group: 'Lain-lain',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Uang Kembalian Sisa Ongkir Kirim Paket',
        icon: Icons.replay_rounded,
        group: 'Lain-lain',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Klaim Santunan Keterlambatan Penerbangan',
        icon: Icons.flight_land_rounded,
        group: 'Lain-lain',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Hadiah Undian Tiket Masuk Bioskop / Event',
        icon: Icons.confirmation_number_rounded,
        group: 'Lain-lain',
        color: Color(0xFF9C27B0)),
    TransactionCategory(
        label: 'Hadiah Giveaway Follower Instagram / Tiktok',
        icon: Icons.card_giftcard_rounded,
        group: 'Lain-lain',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Bagi Hasil Temuan Barang Hilang (Reward)',
        icon: Icons.stars_rounded,
        group: 'Lain-lain',
        color: Color(0xFFFFA000)),
    TransactionCategory(
        label: 'Hasil Tukar Poin Reward Minimarket Jadi Sembako',
        icon: Icons.storefront_rounded,
        group: 'Lain-lain',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Klaim Refund Pembatalan Sewa Hotel',
        icon: Icons.hotel_rounded,
        group: 'Lain-lain',
        color: Color(0xFF5C6BC0)),
    TransactionCategory(
        label: 'Pencairan Klaim Jaminan Kesehatan Swasta Prudential',
        icon: Icons.health_and_safety_rounded,
        group: 'Lain-lain',
        color: Color(0xFF43A047)),
    TransactionCategory(
        label: 'Pencairan Klaim Jaminan Kesehatan Swasta Allianz',
        icon: Icons.health_and_safety_rounded,
        group: 'Lain-lain',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Hasil Penjualan Koran Bekas & Majalah',
        icon: Icons.recycling_rounded,
        group: 'Lain-lain',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Hasil Penjualan Kardus Bekas Packing',
        icon: Icons.recycling_rounded,
        group: 'Lain-lain',
        color: Color(0xFF5D4037)),
    TransactionCategory(
        label: 'Hasil Tukar Tambah HP Samsung Lama',
        icon: Icons.phone_android_rounded,
        group: 'Lain-lain',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Hasil Tukar Tambah HP iPhone Lama',
        icon: Icons.phone_android_rounded,
        group: 'Lain-lain',
        color: Color(0xFF00ACC1)),
    TransactionCategory(
        label: 'Uang Kembalian Sisa Ongkir Shopee',
        icon: Icons.replay_rounded,
        group: 'Lain-lain',
        color: Color(0xFF546E7A)),
    TransactionCategory(
        label: 'Uang Kembalian Sisa Ongkir Tokopedia',
        icon: Icons.replay_rounded,
        group: 'Lain-lain',
        color: Color(0xFF78909C)),
    TransactionCategory(
        label: 'Klaim Santunan Delay Penerbangan Lion Air',
        icon: Icons.flight_land_rounded,
        group: 'Lain-lain',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Klaim Santunan Delay Penerbangan Garuda',
        icon: Icons.flight_land_rounded,
        group: 'Lain-lain',
        color: Color(0xFF0D47A1)),
    TransactionCategory(
        label: 'Hadiah Undian Tiket Nonton Bioskop XXI',
        icon: Icons.confirmation_number_rounded,
        group: 'Lain-lain',
        color: Color(0xFF9C27B0)),
    TransactionCategory(
        label: 'Hadiah Undian Tiket Nonton Konser Musik',
        icon: Icons.confirmation_number_rounded,
        group: 'Lain-lain',
        color: Color(0xFF7B1FA2)),
    TransactionCategory(
        label: 'Hadiah Giveaway Akun Instagram Dagelan',
        icon: Icons.card_giftcard_rounded,
        group: 'Lain-lain',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Hadiah Giveaway Akun Tiktok Akun Lucu',
        icon: Icons.card_giftcard_rounded,
        group: 'Lain-lain',
        color: Color(0xFFFF5722)),
    TransactionCategory(
        label: 'Bagi Hasil Temuan Dompet Hilang',
        icon: Icons.stars_rounded,
        group: 'Lain-lain',
        color: Color(0xFFFFA000)),
    TransactionCategory(
        label: 'Bagi Hasil Temuan HP Hilang',
        icon: Icons.stars_rounded,
        group: 'Lain-lain',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Hasil Tukar Poin Reward Indomaret Sembako',
        icon: Icons.storefront_rounded,
        group: 'Lain-lain',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Hasil Tukar Poin Reward Alfamart Sembako',
        icon: Icons.storefront_rounded,
        group: 'Lain-lain',
        color: Color(0xFF2E7D32)),
    TransactionCategory(
        label: 'Klaim Refund Tiket Kereta Api Batal',
        icon: Icons.train_rounded,
        group: 'Lain-lain',
        color: Color(0xFF1565C0)),
    TransactionCategory(
        label: 'Klaim Refund Kamar Hotel Batal',
        icon: Icons.hotel_rounded,
        group: 'Lain-lain',
        color: Color(0xFF5C6BC0)),
    TransactionCategory(
        label: 'Hasil Penjualan Botol Plastik Bekas',
        icon: Icons.recycling_rounded,
        group: 'Lain-lain',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Hasil Penjualan Kaleng Aluminium Bekas',
        icon: Icons.recycling_rounded,
        group: 'Lain-lain',
        color: Color(0xFF009688)),
    TransactionCategory(
        label: 'Uang Jalan Sisa Dinas Luar Kota',
        icon: Icons.monetization_on_rounded,
        group: 'Lain-lain',
        color: Color(0xFFFBC02D)),
    TransactionCategory(
        label: 'Uang Makan Sisa Kegiatan Panitia',
        icon: Icons.restaurant_rounded,
        group: 'Lain-lain',
        color: Color(0xFFFF7043)),
    TransactionCategory(
        label: 'Hadiah Undian Sabun Mandi Lifebuoy',
        icon: Icons.card_giftcard_rounded,
        group: 'Lain-lain',
        color: Color(0xFFEC407A)),
    TransactionCategory(
        label: 'Hadiah Undian Deterjen Rinso Mobil',
        icon: Icons.card_giftcard_rounded,
        group: 'Lain-lain',
        color: Color(0xFF00BCD4)),
    TransactionCategory(
        label: 'Hasil Tukar Tambah Laptop Asus Lama',
        icon: Icons.computer_rounded,
        group: 'Lain-lain',
        color: Color(0xFF607D8B)),
    TransactionCategory(
        label: 'Hasil Tukar Tambah Kamera Canon Lama',
        icon: Icons.camera_alt_rounded,
        group: 'Lain-lain',
        color: Color(0xFF0288D1)),
    TransactionCategory(
        label: 'Klaim Refund Pembelian Baju Salah Ukuran',
        icon: Icons.shopping_bag_rounded,
        group: 'Lain-lain',
        color: Color(0xFF8D6E63)),
    TransactionCategory(
        label: 'Klaim Refund Pembelian Sepatu Kebesaran',
        icon: Icons.shopping_bag_rounded,
        group: 'Lain-lain',
        color: Color(0xFF5D4037)),
    TransactionCategory(
        label: 'Uang Saku Sisa Perjalanan Dinas Kantor',
        icon: Icons.wallet_rounded,
        group: 'Lain-lain',
        color: Color(0xFF4CAF50)),
    TransactionCategory(
        label: 'Hadiah Doorprize Acara Jalan Sehat RT',
        icon: Icons.emoji_events_rounded,
        group: 'Lain-lain',
        color: Color(0xFFFFB300)),
    TransactionCategory(
        label: 'Hadiah Doorprize Acara HUT RI Kompleks',
        icon: Icons.celebration_rounded,
        group: 'Lain-lain',
        color: Color(0xFFE91E63)),
    TransactionCategory(
        label: 'Hasil Jual Pakaian Layak Pakai Bekas',
        icon: Icons.checkroom_rounded,
        group: 'Lain-lain',
        color: Color(0xFF8E24AA)),
    TransactionCategory(
        label: 'Hasil Jual Lemari Kayu Bekas Pindahan',
        icon: Icons.chair_rounded,
        group: 'Lain-lain',
        color: Color(0xFF795548)),
    TransactionCategory(
        label: 'Hasil Jual Kasur Busa Bekas Pindahan',
        icon: Icons.bed_rounded,
        group: 'Lain-lain',
        color: Color(0xFF3F51B5)),
    TransactionCategory(
        label: 'Uang Saku Sisa KKN / Magang Kampus',
        icon: Icons.school_rounded,
        group: 'Lain-lain',
        color: Color(0xFF1E88E5)),
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
