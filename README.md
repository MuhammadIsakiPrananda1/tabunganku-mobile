# 💰 TabunganKu - Aplikasi Tabungan Keluarga Cerdas

![Banner Utama](file:///C:/Users/Neverland%20Studio/.gemini/antigravity/brain/2d7b6fe8-97c8-486a-9926-54f72e00aecd/tabunganku_release_v120_banner_1775704460241.png)

**TabunganKu** adalah ekosistem manajemen keuangan modern yang dirancang untuk menghadirkan transparansi dan kebiasaan menabung yang sehat bagi keluarga Indonesia. Dengan pendekatan **Premium UI/UX (Mint Fresh Design)** dan integrasi awan yang cerdas, kami mengubah cara Anda melihat uang Anda.

---

## ✨ Fitur Unggulan

- **📊 Dashboard Interaktif:** Pantau sisa saldo, pendapatan, dan pengeluaran harian dengan grafik elegan.
- **🎯 Challenge Menabung:** Sistem gamifikasi dengan 14 challenge templates, badge collection, dan streak counter.
- **⏱️ Custom Duration:** Kini kamu bisa menentukan sendiri durasi tantangan (Setup hari) sesuai keinginanmu! (NEW)
- **👨‍👩‍👧‍👦 Grup Keluarga:** Sinkronkan catatan tabungan dengan seluruh anggota keluarga secara instan.
- **⚡ Real-time Sync:** Sinkronisasi cerdas antara transaksi dan progres tantangan secara otomatis. (NEW)
- **🏆 Achievement System:** Kumpulkan badge dan poin melalui berbagai pencapaian dalam menyelesaikan challenge.
- **📈 Progres Target:** Visualisasikan seberapa dekat Anda dengan impian Anda (iPhone, Kendaraan, dll).
- **📄 Laporan PDF:** Ekspor riwayat transaksi ke format PDF yang rapi dengan satu klik.
- **🔥 Streak Tracker:** Hitung berapa hari berturut-turut Anda konsisten menyelesaikan challenge.

### 🆕 Versi Terbaru (v1.2.0)
Lihat catatan rilis lengkap kami di sini: [GitHub Release v1.2.0](https://github.com/MuhammadIsakiPrananda1/tabunganku-mobile/releases/tag/v1.2.0)

---

## 🛠️ Stack Teknologi

| Layer | Teknologi |
| :--- | :--- |
| **Core Framework** | [Flutter](https://flutter.dev) (Dart SDK 3.0.0+) |
| **State Management** | [Riverpod](https://riverpod.dev) |
| **Backend & Sync** | [Google Firebase](https://firebase.google.com) (Firestore & Auth) |
| **Notifications** | [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications) |
| **UI/UX Design** | Custom Mint Fresh Aesthetic (Vanilla CSS + Poppins Fonts) |
| **Charts** | [FL Chart](https://pub.dev/packages/fl_chart) |

---

## 📥 Cara Instalasi (Tutorial Development)

### Prasyarat
- Flutter SDK (versi 3.0.0 atau lebih tinggi)
- Android Studio / VS Code dengan plugin Flutter
- Koneksi internet untuk sinkronisasi Firebase

### Langkah Development
1.  **Clone Repository**
    ```bash
    git clone https://github.com/MuhammadIsakiPrananda1/tabunganku-mobile.git
    cd tabunganku-mobile
    ```
2.  **Konfigurasi Dependensi**
    ```bash
    flutter pub get
    ```
3.  **Setup Firebase Artifacts**
    - Simpan `google-services.json` (Android) di `android/app/`.
    - Simpan `GoogleService-Info.plist` (iOS) di `ios/Runner/`.
4.  **Running Device**
    ```bash
    flutter run
    ```

---

## 🏗️ Build & Deployment

### Android
Untuk mendapatkan APK dengan arsitektur spesifik:
```bash
flutter build apk --split-per-abi
```
File hasil build akan berada di `build/app/outputs/flutter-apk/`.

### iOS
```bash
flutter build ipa --release
```

---

## 📄 Lisensi & Kredit
Proyek ini dikembangkan oleh **Muhammad Isaki Prananda** dan didistribusikan di bawah **MIT License**.

**Dibuat dengan ❤️ oleh [Muhammad Isaki Prananda](https://github.com/MuhammadIsakiPrananda1)**
