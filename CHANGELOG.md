# 📝 Catatan Perubahan TabunganKu

Seluruh evolusi, fitur, dan perbaikan aplikasi **TabunganKu** terdokumentasi secara lengkap dan detail di sini. Kami terus berinovasi untuk membantu Anda mengelola masa depan finansial yang lebih cerah.

---

## 💎 [1.4.8] — 19–20 April 2026: The Security & Transparency Revolution

Rilis ini menghadirkan perombakan total pada sistem keamanan dan transparansi keluarga. Kami memperkenalkan sinkronisasi awan (cloud sync) yang lebih cerdas untuk memastikan seluruh anggota keluarga memiliki pandangan yang sama terhadap keuangan bersama.

### 🚀 Tambah Fitur (New Features)
- **Shared Family Transparency (Real-Sync)** — Implementasi sinkronisasi Firestore real-time. Kini setiap anggota keluarga bisa melihat seluruh riwayat transaksi grup secara instan saat ada perubahan 👨‍👩‍👧‍👦.
- **Joint Account Management** — Memberikan akses penuh bagi seluruh anggota grup untuk mengedit atau menghapus catatan apa pun dalam buku kas keluarga (Shared Responsibility).
- **Accurate Member Contribution** — Sistem pelacakan saldo individu yang kini lebih akurat, memastikan kontribusi tiap orang dihitung dan ditampilkan dengan benar di semua perangkat.
- **Security Modernization** — Alur startup baru yang lebih aman (`Splash -> Lock Screen -> Dashboard`) dan implementasi *Security Overlay* saat aplikasi dibuka kembali dari background 🛡️.
- **Ultra-Legible UI Upgrade** — Peningkatan keterbacaan signifikan dengan avatar anggota yang lebih besar (72px), badge pembuat transaksi yang lebih tegas ("Oleh Anda" vs "Oleh Nama"), dan font yang lebih besar.
- **Haptic Interaction Feedback** — Penambahan getaran halus (Haptic Feedback) saat menyalin kode grup untuk pengalaman navigasi yang lebih taktil dan premium.

### 🗑️ Hapus Fitur (Removed Features)
- **Individual Ownership Lock** — Menghapus pembatasan kelola transaksi. Kini tidak ada lagi blokir "Hanya pembuat yang bisa mengedit", demi transparansi penuh antar anggota keluarga.
- **Floating "Kode Disalin" SnackBar** — Menghapus bar hitam yang sering menutupi UI saat menyalin kode grup, digantikan dengan respon getaran yang lebih elegan dan bersih 🧹.

### 🛠️ Technical Improvements
- **Hybrid Stream Logic** — Optimalisasi stream data yang menggabungkan penyimpanan lokal dan cloud secara otomatis tanpa jeda.
- **RenderFlex Error Fix** — Memperbaiki error "Layout Overflow" pada daftar anggota keluarga dengan penyesuaian tinggi kontainer yang lebih proporsional (140px).
- **Transaction Creator Badging** — Implementasi logic badge cerdas untuk membedakan catatan pribadi dan catatan yang dibuat oleh anggota keluarga lain secara visual.

---

---

## 🚀 [1.4.7] — 15 April 2026: Layanan Tanpa Batas & Visual Sempurna

Pembaruan v1.4.7 adalah rilis pemeliharaan dan polesan visual yang memastikan aplikasi berjalan tanpa hambatan teknis. Fokus utama adalah pada perbaikan stabilitas rendering dan sinkronisasi versi sistem.

### 🛠️ Perbaikan Layout Kritis (Critical UI Fixes)
- **Zero-Crash Dashboard** — Memperbaiki pengecualian *"RenderBox was not laid out"* pada dashboard alokasi, memastikan transisi data yang mulus tanpa crash mendadak 🛡️.
- **Donut Chart Optimization** — Menghilangkan tumpang tindih label pada grafik donat. Kini persentase diletakkan lebih jauh ke luar (outside labels) untuk keterbacaan yang jauh lebih baik 📊.
- **Badge Grid Fix** — Memperbaiki masalah *overflow* sistem pada koleksi lencana (Badge Collection). Kini tampilan lencana tertata rapi dan responsif di semua ukuran layar smartphone.

### ⚡ Stabilitas & Performa
- **Constraint Polishing** — Optimalisasi batasan lebar (constraints) pada berbagai widget utama untuk mencegah kesalahan render (Pixel Overflow) di masa mendatang ⚡.
- **System Integrity** — Penyelarasan versi build di seluruh file konfigurasi internal untuk konsistensi sistem antara backend dan internal constants.
- **Production Infrastructure** — Integrasi build produksi yang lebih stabil melalui sistem CI/CD GitHub Actions.

---

## 💎 [1.4.6] — 14–15 April 2026: Stability, Performance & Smart Income

Penyempurnaan performa, stabilitas sistem, dan penambahan fitur keuangan cerdas untuk pengalaman yang lebih mulus dan lengkap.

### 🏦 Fitur Baru: Bunga Tabungan Multi-Bank (CEPAT)
- **Multi-Bank Interest Quick-Fill** — Fitur pengisian cepat bunga tabungan dari berbagai bank langsung dari form **Tambah Pemasukan** 💚.
  - Mendukung **10 pilihan bank** sekaligus dalam satu dropdown terintegrasi:
    - 🟢 **SeaBank (Premium)** — 7,4% p.a. untuk saldo ≥ Rp 1 juta (dikreditkan harian)
    - 🔵 **SeaBank (Standar)** — 4% p.a. untuk semua saldo (dikreditkan harian)
    - ⚡ **Bank Neo Commerce** — Bunga cair harian
    - 🟠 **Bank Jago** — Bunga cair bulanan
    - 💧 **Blu by BCA Digital** — Bunga cair bulanan
    - 🔷 **Bank BRI, BCA, Mandiri, BNI** — Bunga tabungan bulanan konvensional
    - ⚫ **Bank Lainnya** — Untuk bank digital/konvensional lainnya
  - Nama transaksi terisi otomatis cerdas: *"Bunga [Nama Bank] [Bulan] [Tahun]"*.
  - Kategori otomatis terpilih: **Bunga Tabungan**.
  - Info card dinamis menampilkan penjelasan rate sesuai bank yang dipilih.
- **Kategori Pemasukan Baru: Bunga Tabungan** — Kategori khusus untuk mencatat pendapatan bunga dari rekening tabungan 🏦.

### 🛠️ Detail Perubahan Lainnya
- **UI Architecture Fix** — Memperbaiki masalah clipping pada kartu saldo utama agar dekorasi tidak bocor keluar sudut 💎.
- **UI Restoration & Perfection** — Mengembalikan ikon lonceng notifikasi dan merestorasi desain **Target Tabungan** ke versi PageView slider yang interaktif 🔔.
- **Premium Style Matching** — Menyelaraskan seksi **Alokasi Keuangan** agar persis dengan desain premium (Comic Neue Italic & Teal Accent shades) sesuai referensi visual 🎨.
- **Enhanced Data Visualization** — Optimalisasi **Pie Chart** dengan tampilan persentase di luar segmen untuk keterbacaan maksimal, informasi total di tengah grafik, dan ketebalan proporsional (standard thickness) 📊.
- **Strict Permission Security** — Implementasi sistem perizinan ketat dengan dialog edukasi premium (*BackdropBlur*) sebelum akses kamera/galeri untuk privasi maksimal 🛡️.
- **High-Priority Notifications** — Upgrade sistem notifikasi ke mode **Heads-up (Banner)** dengan dukungan suara dan getaran sesuai preferensi sistem untuk peringatan yang lebih sigap 🔊.
- **Permission & Privacy Optimization** — Menghapus permintaan izin "Alarm & Reminder" (Exact Alarm) yang redundan untuk privasi yang lebih baik 🛡️.
- **System Stability Enhancement** — Perbaikan bug minor dan optimalisasi penggunaan memori untuk performa yang lebih gegas 🚀.

---

## 💎 [1.4.5] — 11 April 2026: The Intelligence & Finalization
Visi kami untuk asisten finansial yang cerdas dan premium kini telah lengkap.

### 🚀 Highlight Utama
- **Intelligence Hub: Premium Scan AI** — Pengalaman scan struk futuristik dengan animasi Laser AI dan *Smart Auto-fill* merchant & nominal otomatis 📸.
- **Spiritual Finance: Zakat & Infaq** — Kalkulator Zakat (Profesi, Maal, Fitrah) yang terhubung langsung dengan arus kas Anda ✨.
- **Future Forecast: Estimasi Akhir Bulan** — Prediksi sisa saldo Anda di akhir bulan berdasarkan tren pengeluaran harian.
- **Smart Allocation Planner** — Kalkulator alokasi pintar (50/30/20) otomatis setiap kali Anda mencatat pemasukan.

### 📊 Detail & UX
- **Subscription Monitor** — Pantau biaya rutin (Netflix, Spotify, tagihan) secara otomatis agar tidak ada "biaya siluman".
- **Premium Data Export** — Generate laporan bulanan instan ke format PDF atau Text untuk dibagikan.
- **Advanced Search & Filter** — Temukan transaksi history secepat kilat dengan filter kategori yang responsif 🔍.
- **Quick Admin Buttons** — Pilihan biaya admin top-up (Bank, E-Wallet) dengan satu klik.

### 🛠️ Under the Hood
- **Theme Persistence fix** — Pilihan tema kini tidak akan pernah reset.
- **Router Refinement** — Perbaikan error dependensi Riverpod dan stabilitas routing dashboard.

---

## 🎨 [1.4.4] — 9 April 2026: The Aesthetic Polish Era
Penyempurnaan visual dan kenyamanan mata menjadi prioritas utama rilis ini.

- **Cinematic Dark Mode** — Kontras warna yang dikalibrasi ulang untuk kenyamanan mata maksimal di malam hari 🌌.
- **Typography Masterclass** — Penyesuaian *letter-spacing* dan hierarki teks untuk keterbacaan instan.
- **Challenge Page Overhaul** — Layout tantangan menabung yang lebih rapi, proporsional, dan memotivasi 🏆.

---

## 🎯 [1.4.3] — 7 April 2026: The OCR Precision Era
Kecerdasan buatan kini jauh lebih peka terhadap detail keuangan terkecil.

- **Enhanced AI Merchant Detection** — Deteksi struk provider besar (BCA, DANA, OVO) dengan akurasi 95%+ 🧠.
- **Micro-Nominal Support** — Kini mendukung scan nominal hingga **Rp 1**, memastikan tidak ada perak yang tertinggal.
- **Smart Admin Filter** — Otomatis mengabaikan biaya admin atau pajak transaksi yang tidak perlu dicatat 🧼.

---

## 🛡️ [1.4.2] — 6 April 2026: The Budgeting & Structure
Membawa kontrol finansial Anda ke level proaktif.

- **Proactive Budget Tracker** — Berkelanjutan dengan peringatan otomatis saat mendekati batas anggaran bulanan 🛡️.
- **Fidelity Transaction Details** — Tampilan detail transaksi dengan kartu premium yang sangat terstruktur 💎.
- **Responsive Form Architecture** — Seluruh form input kini bebas bug *overflow* di semua ukuran layar 📱.

---

## 🔘 [1.4.1] — 4 April 2026: Modernization & Linked Sync
Antarmuka yang lebih gegas dan sistem manajemen data yang lebih cerdas.

- **Pill-Button Navigation** — Sistem navigasi baru di Riwayat untuk pengalaman yang lebih taktil 🔘.
- **Smart Linked Deletion** — Menghapus hutang/belanja otomatis menghapus transaksi terkait di riwayat utama 🔗.
- **Profile Identity 2.0** — Unggah foto profil asli dari Galeri/Kamera dengan sinkronisasi grup keluarga 📸.

---

## 🏗️ [1.4.0] — 3 April 2026: Productivity & Resilience
Fokus pada kelegaan ruang kerja dan ketepatan waktu pengingat.

- **Full-Page Shopping Center** — Migrasi catatan belanja dari BottomSheet ke halaman penuh yang lega 🏗️.
- **Smart Reminder Engine** — Pengingat cerdas yang mendeteksi timezone dan melakukan *auto-reschedule* otomatis 🕒.
- **Major Code Cleanup** — Penghapusan 800+ baris kode redundan untuk performa yang lebih ringan.

---

## 🎨 [1.3.0] — 1 April 2026: The Visual & Stability Polish
Penyegaran visual pertama untuk dashboard interaktif.

- **Glassmorphism Dashboard** — Desain kartu saldo transparan yang modern ✨.
- **README 2.0 Infrastructure** — Dokumentasi proyek yang kini tampil lebih profesional 📖.
- **Gradle Version Sync** — Optimalisasi build system untuk stabilitas Android modern.

---

## ⚙️ [1.3.9] — 1 April 2026: The Infrastructure Overhaul
Fondasi masa depan untuk distribusi aplikasi yang lebih cepat.

- **GitHub Actions Integration** — Implementasi sistem build & rilis otomatis berbasis CI/CD 🚀.
- **Split APK (ABI)** — Pembagian varian APK (arm64, v7a, x86) untuk ukuran download 40% lebih hemat 📦.

---

## 🧊 [1.2.0] — 31 Maret 2026: Intelligence & Community
Tonggak sejarah dengan diperkenalkannya AI dan kolaborasi grup.

- **OCR Smart Scan (Beta)** — Lahirnya fitur scan struk otomatis untuk pertama kalinya 📸.
- **Family Group Sync** — Kolaborasi finansial keluarga secara real-time via Cloud Database 👨‍👩‍👧‍👦.
- **Profile & Avatar System** — Sistem identitas pengguna dengan pustaka avatar lucu 👤.

---

## 🌟 [1.1.0] — Maret 2026: The Cloud Foundation
Evolusi dari catatan lokal menuju sinkronisasi awan.

- **Firebase Firestore Integration** — Implementasi sinkronisasi data antar perangkat ☁️.
- **Dashboard Interaktiv** — Pengenalan grafik pendapatan vs pengeluaran untuk pertama kali.
- **Saving Target Goals** — Fitur pembuatan target menabung dan pelacak progres visual.

---

## 🐣 [1.0.0] — Februari 2026: The Birth of TabunganKu
Kelahiran aplikasi pencatat keuangan yang aman dan sederhana.

- **Core Ledger Engine** — Sistem dasar pencatatan transaksi pemasukan dan pengeluaran 🐣.
- **Biometric Security** — Keamanan akses aplikasi dengan Sidik Jari dan Pengenalan Wajah.
- **Local Persistence** — Penyimpanan data lokal yang cepat dan andal menggunakan SQLite.

---
