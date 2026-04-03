# 💰 TabunganKu - Aplikasi Tabungan Keluarga Cerdas

![Banner Utama](assets/banner.png)

**TabunganKu** adalah ekosistem manajemen keuangan modern yang dirancang untuk menghadirkan transparansi dan kebiasaan menabung yang sehat bagi keluarga Indonesia. Dengan pendekatan **Premium UI/UX (Mint Fresh Design)** dan integrasi awan yang cerdas, kami mengubah cara Anda melihat uang Anda.

---

## 🚀 Perjalanan Evolusi (Roadmap & Versi)

Kami terus berinovasi untuk memberikan pengalaman terbaik. Berikut adalah kronologi perkembangan fitur utama dari awal hingga saat ini:

### **v1.4.0 - Premium Shopping & Smart Reminders (Current)**
*   **🎉 Migrasi Catatan Belanja**: Fitur "Belanja" kini memiliki halaman mandiri yang luas dan responsif, menggantikan model bottom sheet untuk pengelolaan item yang lebih leluasa.
*   **💡 Smart Daily Reminders**: Penjadwalan notifikasi jam 6 pagi yang lebih tangguh dengan sinkronisasi timezone otomatis (`Asia/Jakarta` fallback) dan prioritas sistem tertinggi.
*   **🔌 Auto-Reschedule**: Algoritma cerdas yang menjadwalkan ulang pengingat setiap kali aplikasi dibuka agar alarm sistem tetap sinkron.
*   **🧹 Code Cleanup**: Optimasi codebase dengan penghapusan 800+ baris kode redundan untuk performa lebih ringan.

### **v1.3.0 - Dashboard Optimization**
*   **📊 UI Dashboard v2**: Peningkatan visual pada kartu saldo dan grafik interaktif menggunakan `fl_chart`.
*   **📦 Gradle Sync**: Sinkronisasi sistem build Android Gradle ke standar 1.3.0 untuk stabilitas kompilasi yang lebih baik.

### **v1.2.0 - Advanced Features & OCR**
*   **📸 Scan Struk OCR**: Integrasi awal deteksi nominal belanja otomatis dari foto struk fisik.
*   **👤 Manajemen Profil**: Sistem identitas dengan pemilihan avatar premium dan penyimpanan nickname permanen.

### **v1.1.0 - Cloud Integration**
*   **🔥 Firebase Backend**: Implementasi awal Cloud Firestore untuk sinkronisasi data antar anggota keluarga secara real-time.
*   **🎯 Target Menabung**: Fitur penetapan impian keuangan dengan progres bar visual.

### **v1.0.0 - Initial Release**
*   **💎 Core Foundation**: Landasan aplikasi dengan pencatatan transaksi manual dan keamanan biometrik sederhana.

---

## ✨ Fitur Unggulan

- **📊 Dashboard Interaktif:** Pantau sisa saldo, pendapatan, dan pengeluaran harian dengan grafik elegan.
- **👨‍👩‍👧‍👦 Grup Keluarga:** Sinkronkan catatan tabungan dengan seluruh anggota keluarga secara instan.
- **🎯 Progres Target:** Visualisasikan seberapa dekat Anda dengan impian Anda (iPhone, Kendaraan, dll).
- **📈 Laporan PDF:** Ekspor riwayat transaksi ke format PDF yang rapi dengan satu klik.

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

## 📥 Cara Instalasi (Audit & Development)

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
