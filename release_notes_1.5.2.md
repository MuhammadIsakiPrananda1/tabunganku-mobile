<p align="center">
  <a target="_blank" rel="noopener noreferrer nofollow" href="https://raw.githubusercontent.com/MuhammadIsakiPrananda1/tabunganku-mobile/main/assets/promo_banner.png"><img src="https://raw.githubusercontent.com/MuhammadIsakiPrananda1/tabunganku-mobile/main/assets/promo_banner.png" alt="TabunganKu Banner" width="100%" style="max-width: 100%;"></a>
</p>
<p align="center">
  <a target="_blank" rel="noopener noreferrer nofollow" href="https://img.shields.io/badge/Versi-1.5.2-blue?style=for-the-badge"><img src="https://img.shields.io/badge/Versi-1.5.2-blue?style=for-the-badge" alt="Versi" style="max-width: 100%;"></a>
  <a target="_blank" rel="noopener noreferrer nofollow" href="https://img.shields.io/badge/Flutter-3.0.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white"><img src="https://img.shields.io/badge/Flutter-3.0.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" style="max-width: 100%;"></a>
  <a target="_blank" rel="noopener noreferrer nofollow" href="https://img.shields.io/badge/State-Riverpod-764ABC?style=for-the-badge&logo=riverpod&logoColor=white"><img src="https://img.shields.io/badge/State-Riverpod-764ABC?style=for-the-badge&logo=riverpod&logoColor=white" alt="Riverpod" style="max-width: 100%;"></a>
  <a target="_blank" rel="noopener noreferrer nofollow" href="https://img.shields.io/badge/Image_API-Cloud_Native-00C853?style=for-the-badge"><img src="https://img.shields.io/badge/Image_API-Cloud_Native-00C853?style=for-the-badge" alt="Image API" style="max-width: 100%;"></a>
  <a target="_blank" rel="noopener noreferrer nofollow" href="https://img.shields.io/badge/Lisensi-MIT-green?style=for-the-badge"><img src="https://img.shields.io/badge/Lisensi-MIT-green?style=for-the-badge" alt="Lisensi" style="max-width: 100%;"></a>
</p>

---

# 💎 TabunganKu Versi 1.5.2 — Stellar Sky & Cloud Native Ecosystem

Pembaruan rilis **v1.5.2** menghadirkan evolusi mutakhir pada ekosistem aplikasi **TabunganKu**. Pembaruan ini mengintegrasikan layanan microservice **TabunganKu Cloud Image API**, fitur gamifikasi menabung **Saving Streak**, inovasi tabungan receh otomatis **Round-Up Savings**, tab **Riwayat Transaksi Dedikasi**, perombakan arsitektur modular yang lebih bersih dan terstandarisasi, serta refaktorisasi menyeluruh pada modul finansial dan keamanan.

---

### 🆕 Fitur Baru (What's New)

#### ☁️ TabunganKu Cloud Image API & Diagnostics Center
* **Integrasi Microservice Cloud Image**: Dukungan API endpoint mandiri (`https://api.neverlandstudio.my.id`) untuk upload, sanitasi otomatis (konversi WebP 85%, kompresi adaptif), dan penghapusan otomatis metadata EXIF demi privasi dan keamanan pengguna.
* **Diagnostik & Kontrol API In-App**: Pengguna dapat memantau uptime dan latensi server secara real-time, melakukan uji ping, menjalankan live upload test dengan auto-cleanup, serta mengonfigurasi Base URL dan API Key secara dinamis dari menu Pengaturan maupun menu Belanja.
* **Dokumentasi API Lengkap**: Panduan teknis lengkap integrasi REST API di dokumentasi `API_DOCUMENTATION.md`.

#### 🪙 Round-Up Savings (Nabung Receh Otomatis)
* Modul cerdas untuk membulatkan setiap transaksi pengeluaran belanja ke kelipatan nominal terdekat (Rp 1.000, Rp 5.000, Rp 10.000) dan secara otomatis mengalokasikan selisih recehnya ke dalam kantong tabungan tanpa membebani keuangan harian.

#### 🔥 Saving Streak & Konsistensi Finansial
* Fitur pelacakan konsistensi menabung harian dengan kalender streak, visualisasi pencapaian beruntun, serta pemicu motivasi untuk membangun kebiasaan menabung rutin setiap hari.

#### 📜 History Tab View & Quick Calculator Sheet
* **Tab Riwayat Transaksi Dedikasi**: Akses cepat penelusuran seluruh riwayat mutasi transaksi keuangan dengan filter tanggal, pencarian instan, dan kategorisasi yang lebih rapi.
* **Calculator Sheet Terpadu**: Bottom sheet kalkulator dinamis yang dapat dibuka kapan saja untuk mempermudah perhitungan cepat sebelum menyimpan transaksi atau alokasi anggaran.

#### 🛡️ Modern UI Components & Profile Architecture
* **PinKeypad Reusable Component**: Komponen keypad numerik kustom yang responsif, ergonomis, dengan feedback interaktif untuk perlindungan keamanan aplikasi.
* **WaveBackground Widget**: Komponen estetika grafis gelombang modern untuk latar belakang layar otentikasi, splash, dan profil.
* **Struktur User Profile Terstandarisasi**: Model data profil pengguna baru yang mendukung sinkronisasi foto profil cloud dan preferensi lokal yang konsisten.

---

### 🛠️ Fitur Yang Diubah & Ditingkatkan (Improvements)

#### 🏗️ Modular Architecture & Clean Barrel Exports
* Restrukturisasi arsitektur kode dengan pola modular: `lib/core/core.dart`, `lib/models/models.dart`, `lib/providers/providers.dart`, `lib/services/services.dart`, `lib/core/widgets/widgets.dart`, dan `lib/core/security/security.dart`.
* Penerapan `LocalDataMixin` untuk standardisasi penyimpanan lokal dan penanganan data offline-first yang lebih tangguh dan konsisten.
* Sentralisasi key SharedPreferences pada `prefs_keys.dart`.

#### 🧭 App Router & Deep Linking Alignment
* Sinkronisasi route GoRouter untuk seluruh feature area baru (Round-Up Savings, Saving Streak, Image API settings, History Tab, dsb.).

#### 🎨 Desain & Responsivitas Antarmuka
* Penyelarasan skema warna, margin, tipografi Inter & Plus Jakarta Sans, serta feedback sentuhan di seluruh halaman.
* Optimalisasi performa rendering kartu dashboard dan widget ringkasan saldo.

---

### 🗑️ Fitur Yang Dihapus & Pembersihan Modul (Cleanup)

#### 🧹 Deprecated Modules Cleanup
* Menghapus halaman dan provider yang telah usang atau digantikan oleh modul baru:
  - `thr_bonus_page.dart`, `thr_bonus_model.dart`, `thr_bonus_provider.dart`
  - `financial_health_checkup_page.dart`
  - `fire_calculator_page.dart`
* Pembersihan referensi impor yang sudah tidak digunakan di seluruh codebase.

---

### ⚡ Detail Teknis & Performa
* **Versi Rilis**: v1.5.2-stable (Build 152)
* **SDK Flutter**: Flutter 3.x (Dart 3.x)
* **Manajemen State**: Flutter Riverpod 2.x
* **Penyimpanan Lokal**: Shared Preferences & Secure Storage dengan LocalDataMixin
* **Image Cloud Engine**: TabunganKu Secure Image API (WebP Converter & EXIF Sanitizer)
* **Target Platform**: Android (arm64-v8a, armeabi-v7a, x86_64)

---

Terima kasih telah menemani perjalanan evolusi TabunganKu hingga versi 1.5.2. Kami berkomitmen untuk selalu mendampingi perencanaan finansial Anda dengan teknologi cerdas dan estetika premium.

**TabunganKu — Kelola Keuangan Lebih Mudah, Nyaman, dan Terencana!** 💰✨
