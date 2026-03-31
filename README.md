# 💰 TabunganKu - Aplikasi Tabungan Keluarga Cerdas

![Banner Utama](assets/banner.png)

**TabunganKu** adalah aplikasi manajemen keuangan modern yang dirancang khusus untuk membantu Anda dan keluarga dalam mengelola tabungan secara efektif, transparan, dan otomatis. Dengan integrasi **Real-time Database** dan **Teknologi OCR**, mencatat transaksi kini semudah mengambil foto.

---

## ✨ Fitur Utama

- **📊 Dashboard Real-time:** Pantau sisa saldo, total pendapatan, dan pengeluaran harian dengan grafik interaktif yang memanjakan mata.
- **👨‍👩‍👧‍👦 Grup Keluarga:** Sinkronkan catatan tabungan dengan seluruh anggota keluarga dalam satu database yang sama.
- ~~**📸 Scan Struk OCR:** Tidak perlu mengetik manual! Cukup foto struk belanja Anda, dan aplikasi akan mendeteksi nominalnya secara otomatis.~~
- **👤 Kustomisasi Profil:** Pilih avatar premium dan ganti nickname sesuai keinginan Anda dengan penyimpanan permanen.
- **🎯 Target Menabung:** Buat rencana keuangan untuk masa depan dan pantau progresnya hingga tercapai.
- **📈 Laporan PDF:** Ekspor riwayat transaksi Anda ke dalam format PDF yang rapi untuk keperluan administrasi.

---

## 🛠️ Teknologi yang Digunakan

| Komponen | Teknologi |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) (Dart) |
| **State Management** | [Riverpod](https://riverpod.dev) |
| **Database** | [Cloud Firestore](https://firebase.google.com/docs/firestore) |
| **Navigation** | [Go Router](https://pub.dev/packages/go_router) |
| **Design System** | Custom Vanilla CSS & Google Fonts (Poppins) |
| **Local Storage** | Shared Preferences & Flutter Secure Storage |

---

## 🚀 Cara Instalasi

### Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.0.0 ke atas)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / Xcode (untuk simulator)

### Langkah-langkah
1. **Clone repository:**
   ```bash
   git clone https://github.com/username/tabunganku.git
   cd tabunganku
   ```
2. **Instal dependensi:**
   ```bash
   flutter pub get
   ```
3. **Konfigurasi Firebase:**
   - Tambahkan file `google-services.json` (untuk Android) ke `android/app/`.
   - Tambahkan file `GoogleService-Info.plist` (untuk iOS) ke `ios/Runner/`.
4. **Jalankan aplikasi:**
   ```bash
   flutter run
   ```

---

## 🏗️ Cara Build Aplikasi

### Android (APK)
Untuk membuat file installer Android:
```bash
flutter build apk --release
```
File APK akan tersedia di: `build/app/outputs/flutter-apk/app-release.apk`

### iOS (IPA)
*Catatan: Membutuhkan macOS dan Xcode.*
```bash
flutter build ipa --release
```

---

## 🛡️ Keamanan & Kontribusi
Silakan lihat dokumen berikut untuk informasi lebih lanjut:
- [PANDUAN KEAMANAN (SECURITY.md)](SECURITY.md)
- [PANDUAN KONTRIBUSI (CONTRIBUTING.md)](CONTRIBUTING.md)
- [CATATAN PERUBAHAN (CHANGELOG.md)](CHANGELOG.md)

---

### 📄 Lisensi
Didistribusikan di bawah **MIT License**. Lihat [LICENSE](LICENSE) untuk informasi lebih lanjut.

---
**Dibuat dengan ❤️ oleh [Neverland Studio](https://github.com/neverlandstudio)**
