# 💰 TabunganKu - Ekosistem Manajemen Keuangan Cerdas & Terintegrasi

<p align="center">
  <img src="assets/promo_banner.png" alt="TabunganKu Banner" width="100%" style="border-radius: 20px; box-shadow: 0 15px 40px rgba(0,0,0,0.15);">
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.0.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Versi Flutter"></a>
  <a href="https://riverpod.dev"><img src="https://img.shields.io/badge/State-Riverpod-764ABC?style=for-the-badge&logo=riverpod&logoColor=white" alt="Manajemen State"></a>
  <a href="https://firebase.google.com"><img src="https://img.shields.io/badge/Backend-Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Backend"></a>
  <img src="https://img.shields.io/badge/Lisensi-MIT-green.svg?style=for-the-badge" alt="Lisensi">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue?style=for-the-badge" alt="Platform Dukungan">
  <img src="https://img.shields.io/badge/Maintained%3F-yes-brightgreen.svg?style=for-the-badge" alt="Maintained">
</p>

---

## 📖 Deskripsi Proyek

**TabunganKu** adalah solusi finansial mutakhir yang menggabungkan kemudahan pencatatan harian dengan kekuatan teknologi cloud. Lahir dari kebutuhan akan transparansi keuangan dalam keluarga, aplikasi ini berevolusi menjadi asisten finansial pintar yang mampu membantu siapa saja—dari pelajar hingga kepala keluarga—untuk mencapai target keuangan mereka dengan cara yang menyenangkan dan terukur.

Kami percaya bahwa menabung seharusnya tidak terasa seperti beban. Melalui integrasi **Gamifikasi**, **AI OCR**, dan **Visualisasi Data**, TabunganKu mengubah angka-angka yang membosankan menjadi petualangan menuju impian Anda.

---

## ✨ Fitur Utama (Deep Dive)

### 📊 Dashboard & Analitik Eksklusif
*   **Stellar Insights**: Bukan sekadar angka, tapi pemahaman. Dashboard kami memberikan ringkasan saldo dengan animasi halus dan perubahan warna dinamis berdasarkan kondisi keuangan Anda.
*   **Analisis Pengeluaran Multi-Kategori**: Visualisasikan ke mana uang Anda pergi dengan grafik **FL Chart** yang mendukung interaksi *touch-to-view*.
*   **Laporan Periodik Otomatis**: Dapatkan ringkasan mingguan dan bulanan untuk membantu evaluasi pengeluaran tanpa perlu menghitung ulang.

### 👨‍👩‍👧‍👦 Kolaborasi Keluarga (The Harmony Feature)
*   **Family Sync 2.0**: Buat grup keluarga dan undang anggota melalui link atau kode unik. Setiap kontribusi tabungan akan memicu notifikasi real-time ke semua anggota.
*   **Target Bersama**: Bekerja sama untuk mencapai tujuan besar seperti DP Rumah, Pendidikan Anak, atau Liburan Keluarga.
*   **Role Management**: Pengaturan admin grup untuk mengelola anggota dan memvalidasi transaksi jika diperlukan.

### 🎮 Sistem Gamifikasi (Build the Habit)
*   **14+ Saving Challenges**: Mulai dari *Tantangan Kalender*, *Tantangan 52 Minggu*, hingga *Tantangan Tanpa Belanja*.
*   **Experience Points (XP) & Leveling**: Setiap kali Anda menabung atau menyelesaikan tantangan, Anda akan mendapatkan XP untuk menaikkan level akun Anda.
*   **Hall of Fame**: Lihat pencapaian terbaik Anda dan koleksi lencana (*badges*) yang telah didapatkan sebagai bukti kedisiplinan finansial.

### 🧠 Teknologi Pintar & Keamanan
*   **AI OCR Receipt Scanner**: Memanfaatkan **Google ML Kit** dengan akurasi tinggi untuk membaca struk belanja dan mengonversinya menjadi data transaksi digital dalam hitungan detik.
*   **Offline First Capabilities**: Aplikasi tetap dapat digunakan meski tanpa koneksi internet; data akan disinkronkan secara otomatis saat koneksi kembali tersedia (**Connectivity Plus**).
*   **Biometric Guard**: Keamanan lapis baja dengan integrasi **Fingerprint** dan **Face Unlock** untuk menjaga privasi data Anda.

---

## 🛠️ Arsitektur & Stack Teknologi Modern

Aplikasi ini dibangun dengan standar industri tinggi menggunakan pola **Clean Architecture** sederhana yang memastikan skalabilitas dan kemudahan pemeliharaan.

| Kategori | Teknologi | Kegunaan Utama |
| :--- | :--- | :--- |
| **Framework** | **Flutter SDK** | Membangun UI yang indah dan responsif untuk banyak platform. |
| **State Management** | **Riverpod (Generator)** | Menangani logika aplikasi dengan *dependency injection* yang aman. |
| **Database** | **Firestore NoSQL** | Sinkronisasi data real-time dengan latensi rendah. |
| **Authentication** | **Firebase Auth** | Sistem login yang aman (Email, Google, dll). |
| **Local Storage** | **Secure Storage** | Menyimpan kunci enkripsi dan data sensitif secara lokal. |
| **AI/ML** | **Google ML Kit** | Pemrosesan citra untuk fitur scan struk otomatis. |
| **Reporting** | **PDF & Intl** | Menghasilkan dokumen laporan dan formatting mata uang Rupiah. |

---

## 📁 Struktur Direktori & Pola Kode

```text
lib/
├── app/              # Konfigurasi aplikasi global (Themes, Routes)
├── features/         # Modul fitur (Dashboard, Savings, Profile, Family)
│   ├── data/         # Repositori dan Data Sources (Firebase/Local)
│   ├── domain/       # Entities dan Business Logic
│   └── presentation/ # Widgets, Screens, dan State Providers (Riverpod)
├── core/             # Utilitas, Ekstensi, dan Konstanta
└── main.dart         # Titik masuk aplikasi
```

---

## 🚀 Panduan Instalasi (Step-by-Step)

### 1. Persiapan Lingkungan
Pastikan perangkat Anda memenuhi spesifikasi berikut:
*   **Flutter SDK**: v3.x atau lebih tinggi.
*   **Java**: JDK 11 (direkomendasikan).
*   **Android Studio / VS Code**: Terinstal plugin Flutter & Dart.

### 2. Kloning & Dependensi
Buka terminal Anda dan jalankan perintah berikut:
```bash
# Clone proyek ke lokal
git clone https://github.com/MuhammadIsakiPrananda1/tabunganku-mobile.git

# Masuk ke direktori proyek
cd tabunganku-mobile

# Instal semua paket yang diperlukan
flutter pub get
```

### 3. Konfigurasi Backend (Firebase)
Tanpa langkah ini, fitur sinkronisasi cloud tidak akan berfungsi:
1.  Buka [Firebase Console](https://console.firebase.google.com/).
2.  Buat proyek baru dan tambahkan aplikasi Android/iOS.
3.  Unduh `google-services.json` (Android) ke `android/app/`.
4.  Unduh `GoogleService-Info.plist` (iOS) ke `ios/Runner/`.
5.  Pastikan **Firestore Index** sudah dibuat sesuai dengan kueri yang ada di kode.

### 4. Build Generation
Aplikasi ini menggunakan *code generation* untuk performa state management yang lebih baik:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 🏗️ Deployment & Distribusi

### Persiapan Rilis Android
1.  Pastikan `version` di `pubspec.yaml` sudah diperbarui.
2.  Jalankan perintah build:
```bash
# Build APK untuk pengujian manual
flutter build apk --release

# Build App Bundle untuk rilis Play Store
flutter build appbundle --release
```

### Persiapan Rilis iOS
1.  Buka `Runner.xcworkspace` di Xcode.
2.  Pilih *Signing & Capabilities* dan masukkan tim pengembang Anda.
3.  Jalankan: `flutter build ipa --release`

---

## 🌟 Roadmap Pengembangan
- [ ] Integrasi Notifikasi Push untuk pengingat menabung harian.
- [ ] Fitur Ekspor Laporan ke format Excel (.xlsx).
- [ ] Dark Mode yang lebih optimal.
- [ ] Integrasi dengan API Bank lokal (Tahap Riset).

---

## 📄 Lisensi & Kredit

Proyek ini berada di bawah lisensi **MIT**. Anda bebas menggunakan dan memodifikasi kode ini dengan tetap memberikan atribusi kepada penulis aslinya.

*   **Pembuat Utama**: [Muhammad Isaki Prananda](https://github.com/MuhammadIsakiPrananda1)
*   **Studio**: **Neverland Studio**
*   **Email Kontak**: [Arlianto032@gmail.com](mailto:Arlianto032@gmail.com)

---
<p align="center">
  <img src="https://forthebadge.com/images/badges/made-with-brave.svg" height="30">
  <img src="https://forthebadge.com/images/badges/built-with-love.svg" height="30">
  <img src="https://forthebadge.com/images/badges/built-with-fluent-interface.svg" height="30">
  <img src="https://forthebadge.com/images/badges/uses-badges.svg" height="30">
</p>

<p align="center">
  <b>TabunganKu - Solusi Finansial di Genggaman Anda</b><br>
  © 2026 <b>Muhammad Isaki Prananda</b>. Dipersembahkan oleh <b>Neverland Studio</b>.
</p>
