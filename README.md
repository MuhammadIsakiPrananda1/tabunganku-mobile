# 💰 TabunganKu

<p align="center">
  <img src="assets/promo_banner.png" alt="TabunganKu Banner" width="100%" style="border-radius: 12px; border: 1px solid #e1e4e8; box-shadow: 0 8px 24px rgba(149, 157, 165, 0.2);">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Versi-1.5.2-blue?style=for-the-badge" alt="Versi">
  <img src="https://img.shields.io/badge/Flutter-3.0.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/State-Riverpod-764ABC?style=for-the-badge&logo=riverpod&logoColor=white" alt="Riverpod">
  <img src="https://img.shields.io/badge/Privacy-Offline_First-00C853?style=for-the-badge" alt="Privacy First">
  <img src="https://img.shields.io/badge/Security-Keystore_AES256-6200EA?style=for-the-badge" alt="Security">
  <img src="https://img.shields.io/badge/Lisensi-MIT-green?style=for-the-badge" alt="Lisensi">
</p>

---

## 🌟 Ikhtisar

**TabunganKu** adalah aplikasi manajemen keuangan pribadi yang modern, komprehensif, dan **100% berorientasi privasi (Offline-First)**. Dibangun menggunakan **Flutter** dan **Riverpod**, aplikasi ini memberikan pengalaman yang mulus, aman, dan elegan untuk melacak mutasi kas, merencanakan anggaran, memupuk kebiasaan menabung rutin, dan mengelola portofolio aset tanpa ketergantungan pada server pihak ketiga.

> "Mengelola uang seharusnya bukan menjadi beban, melainkan perjalanan yang memberdayakan menuju kebebasan finansial dengan privasi penuh."

---

## 🔍 Transparansi & Kesiapan Audit Publik

TabunganKu menjunjung tinggi transparansi kode sumber terbuka:
*   🔒 **Kedaulatan Data Penuh**: Seluruh data transaksi finansial, target, dan catatan Anda tersimpan secara lokal di memori perangkat. Tidak ada pelacakan analitik (*zero telemetry*).
*   🛡️ **Keamanan Perangkat Keras**: Kredensial sensitif dan hash PIN dilindungi oleh Android Keystore / iOS Keychain via `flutter_secure_storage`.
*   📖 **Panduan Audit Lengkap**: Pelajari pemetaan data, audit jaringan, dan perizinan pada [AUDIT.md](AUDIT.md).
*   🛡️ **Kebijakan Keamanan**: Lihat [SECURITY.md](SECURITY.md) untuk rincian kebijakan keamanan dan pelaporan celah.
*   📡 **Dokumentasi API**: Baca panduan integrasi microservice gambar pada [API_DOCUMENTATION.md](API_DOCUMENTATION.md).

---

## ✨ Fitur Unggulan (Kemampuan Aplikasi)

### 🧠 Manajemen Keuangan & Otomatisasi Cerdas
*   **Pencatatan Multi-Kategori**: Akses ribuan kategori transaksi pengeluaran dan pemasukan dengan pencarian instan dan performa O(1) cache.
*   **Riwayat Dedikasi & Filter Lanjutan**: Penelusuran mutasi transaksi keuangan berdasarkan rentang tanggal, jenis, dan kata kunci.
*   **Kelola Tagihan & Langganan Rutin**: Pantau tagihan bulanan wajib dan pengeluaran berkala agar terhindar dari denda keterlambatan.
*   **Analitik FL Chart**: Visualisasi arus kas masuk dan keluar melalui grafik interaktif yang mendukung mode gelap (*dark mode*) dan terang.

### 🪙 Tabungan Receh & Gamifikasi
*   **Round-Up Savings (Nabung Receh Otomatis)**: Membulatkan transaksi pengeluaran ke kelipatan terdekat (Rp 1.000, Rp 5.000, Rp 10.000) dan mengalokasikan selisihnya ke tabungan.
*   **Saving Streak**: Pelacakan konsistensi menabung harian dengan kalender streak dan motivasi visual.
*   **Dana Rencana (Saving Goals)**: Tetapkan target dana masa depan dengan simulasi proyeksi waktu dan setoran berkala.
*   **14+ Tantangan Finansial**: Tantangan seru seperti *Tantangan 52 Minggu*, *Daily Saving*, hingga *Zero Expense Day*.
*   **Hall of Fame & Lencana XP**: Koleksi lencana prestasi kedisiplinan finansial untuk memupuk kebiasaan hemat yang berkelanjutan.

### 💼 Portofolio & Aset Modern
*   **Simpanan Emas**: Catat kepemilikan aset emas (gram dan nilai beli) sebagai instrumen lindung nilai.
*   **Portofolio Investasi**: Pantau valuasi instrumen investasi (Saham, Reksadana, Obligasi) dan estimasi *profit/loss*.
*   **Catatan Hutang & Piutang**: Pengelolaan daftar hutang/piutang dengan status pelunasan yang transparan.

### 🛠️ Utilitas Finansial & Kalkulator Cerdas
*   **Kalkulator Bunga Majemuk (*Compounding Interest*)**: Simulasi pertumbuhan aset jangka panjang berdasarkan return tahunan.
*   **Simulasi Tabungan & Kalkulator Inflasi**: Hitung dampak penurunan daya beli uang di masa mendatang.
*   **Konverter Valas Real-time**: Konversi kurs mata uang asing akurat untuk perencanaan keuangan global.
*   **Kalkulator Zakat & Ibadah**: Perhitungan Zakat Maal, Profesi, dan Fitrah sesuai kaidah, serta perencanaan Haji & Umrah.
*   **Ekspor Data Terpadu**: Unduh laporan mutasi dalam format PDF profesional dan tabel CSV.

---

## 🛠️ Stack Teknologi

- **Frontend Framework**: Flutter SDK 3.x (Dart 3.x)
- **State Management**: Flutter Riverpod 2.x
- **Navigasi & Perutean**: GoRouter (Declarative Routing)
- **Keamanan & Kredensial**: `flutter_secure_storage` (Hardware Keystore / Keychain), `local_auth` (Biometrik Sidik Jari & Wajah)
- **Persistensi Data**: `shared_preferences` dengan arsitektur `LocalDataMixin`
- **Cloud Image Microservice**: TabunganKu Secure Image API (WebP 85% Auto-Convert & EXIF Sanitizer)
- **Visualisasi & Grafik**: `fl_chart`
- **Pelaporan & Ekspor**: `pdf`, `open_filex`, `share_plus`
- **Typography & Desain**: Google Fonts (Inter, Quicksand, Plus Jakarta Sans — preloaded lokal)

---

## 🚀 Panduan Memulai Cepat

Ikuti langkah-langkah berikut untuk menjalankan proyek secara lokal:

### 1. Klon Repositori
```bash
git clone https://github.com/MuhammadIsakiPrananda1/tabunganku-mobile.git
cd tabunganku-mobile
```

### 2. Instal Dependensi
```bash
flutter pub get
```

### 3. Jalankan Validasi Kode (Audit)
```bash
flutter analyze
```

### 4. Jalankan Aplikasi
```bash
flutter run
```

---

## 📄 Lisensi & Kontributor

Didistribusikan di bawah **Lisensi MIT**. Lihat [LICENSE](LICENSE) untuk informasi lebih lanjut.

<p align="center">
  <b>Muhammad Isaki Prananda</b><br>
  Solusi teknologi finansial yang aman, transparan, dan berorientasi privasi pengguna.
</p>

<p align="center">
  <a href="mailto:Arlianto032@gmail.com">
    <img src="https://img.shields.io/badge/Email-Arlianto032%40gmail.com-EA4335?style=for-the-badge&logo=gmail&logoColor=white" alt="Email">
  </a>
  <a href="https://github.com/MuhammadIsakiPrananda1">
    <img src="https://img.shields.io/badge/GitHub-MuhammadIsakiPrananda1-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub">
  </a>
</p>
