<p align="center">
  <a target="_blank" rel="noopener noreferrer nofollow" href="https://raw.githubusercontent.com/MuhammadIsakiPrananda1/tabunganku-mobile/main/assets/promo_banner.png"><img src="https://raw.githubusercontent.com/MuhammadIsakiPrananda1/tabunganku-mobile/main/assets/promo_banner.png" alt="TabunganKu Banner" width="100%" style="max-width: 100%;"></a>
</p>
<p align="center">
  <img src="https://img.shields.io/badge/Versi-1.3.9-blue?style=for-the-badge" alt="Versi">
  <img src="https://img.shields.io/badge/Flutter-3.0.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white" alt="CI/CD">
  <img src="https://img.shields.io/badge/Optimization-Split_APK_40%25-00C853?style=for-the-badge" alt="Split APK">
  <img src="https://img.shields.io/badge/Lisensi-MIT-orange?style=for-the-badge" alt="Lisensi">
</p>

---

# ⚙️ TabunganKu Versi 1.3.9

Pembaruan **v1.3.9** berfokus pada modernisasi infrastruktur deployment aplikasi dengan otomasi pipeline CI/CD GitHub Actions dan optimasi kompilasi Split APK per arsitektur ABI untuk memangkas ukuran unduhan aplikasi secara drastis.

---

### 🆕 Fitur Yang Ditambah (What's New)

#### 🚀 Pipeline GitHub Actions CI/CD
* **Otomasi Build & Release**: Kompilasi paket aplikasi produksi Android secara otomatis saat pembuatan tag rilis di GitHub.
* **Release Generator**: Penyusunan catatan rilis otomatis yang terhubung langsung dengan banner visual resmi.

#### 📦 Split APK per Arsitektur CPU (ABI)
* **Ukuran Aplikasi 40% Lebih Hemat**: Distribusi installer dipisahkan ke arsitektur `arm64-v8a`, `armeabi-v7a`, dan `x86_64`, sehingga pengguna hanya mengunduh binary yang sesuai dengan spesifikasi prosesor perangkat mereka.

---

### 🛠️ Fitur Yang Diubah & Ditingkatkan (Improvements)
* **Waktu Build Cepat**: Optimalisasi caching dependensi Gradle dan Flutter SDK di runner Linux.
* **Penyelarasan Repositori Aset**: Sentralisasi berkas banner rilis di direktori `assets/releases/`.

---

### ⚡ Detail Teknis Rilis
* **Build**: v1.3.9-stable
* **JDK Version**: OpenJDK 17
* **Android Target SDK**: API 34

---

### 📦 Unduhan Paket Aplikasi (APK Releases)
| Tipe Arsitektur | File APK | Rekomendasi Penggunaan |
| :--- | :--- | :--- |
| **ARM 64-bit** | `app-arm64-v8a-release.apk` | Ponsel Android modern 64-bit (Sangat disarankan) |
| **ARM 32-bit** | `app-armeabi-v7a-release.apk` | Ponsel Android 32-bit model lama |
| **x86 64-bit** | `app-x86_64-release.apk` | Emulator Android PC / Laptop |

---

**TabunganKu — Kelola Keuangan Lebih Mudah, Nyaman, dan Terencana!** 💰✨
