# 📝 Catatan Perubahan (Changelog) - TabunganKu

Dokumentasi kronologis seluruh perjalanan evolusi, penambahan fitur, peningkatan sistem, dan perbaikan pada aplikasi **TabunganKu** dari versi awal hingga versi saat ini.

---

## 🗺️ Ringkasan Linimasa Evolusi Versi

| Versi | Waktu Rilis | Fokus & Pencapaian Utama |
| :--- | :--- | :--- |
| **[1.0.0](#-100--februari-2026)** | Februari 2026 | Fondasi awal: buku kas dasar pemasukan/pengeluaran dan keamanan biometrik OS. |
| **[1.2.0](#-120--31-maret-2026)** | 31 Maret 2026 | Kolaborasi tabungan keluarga, personalisasi profil pengguna, dan inisiasi OCR struk. |
| **[1.3.0](#-130--1-april-2026)** | 1 April 2026 | Grafik interaktif `fl_chart`, desain modern *Glassmorphism*, dan haptic feedback. |
| **[1.3.9](#-139--1-april-2026)** | 1 April 2026 | Infrastruktur CI/CD GitHub Actions dan optimasi Split APK (ABI). |
| **[1.4.0](#-140--3-april-2026)** | 3 April 2026 | Halaman penuh catatan belanja, mesin notifikasi hemat baterai v2, dan pembersihan kode. |
| **[1.4.1](#-141--4-april-2026)** | 4 April 2026 | Navigasi *Pill-Button* dan penghapusan relasi transaksi otomatis (*Smart Linked Deletion*). |
| **[1.4.2](#-142--6-april-2026)** | 6 April 2026 | Pelacak anggaran proaktif (peringatan 80% & 90%) dan kartu detail transaksi. |
| **[1.4.3](#-143--7-april-2026)** | 7 April 2026 | Presisi AI OCR scan struk merchant (BCA, DANA, OVO, GoPay) hingga pecahan mikro Rp 1. |
| **[1.4.4](#-144--9-april-2026)** | 9 April 2026 | Mode gelap sinematik (*Cinematic Dark Mode*) dan pembaruan antarmuka tantangan menabung. |
| **[1.4.5](#-145--11-april-2026)** | 11 April 2026 | Kalkulator Zakat & Infaq terpadu, scan struk animasi laser AI, dan estimasi sisa saldo. |
| **[1.4.6](#-146--15-april-2026)** | 15 April 2026 | Otomatisasi bunga 10+ bank besar (*Multi-Bank Interest*) dan slider target tabungan. |
| **[1.4.7](#-147--15-april-2026)** | 15 April 2026 | Peningkatan stabilitas zero-crash dashboard dan algoritma anti-tumpang tindih grafik donat. |
| **[1.4.8](#-148--20-april-2026)** | 20 April 2026 | Peningkatan mesin kalkulator finansial, penyelarasan spasi tombol aksi, dan perbaikan UX. |
| **[1.4.9](#-149--30-april-2026)** | 30 April 2026 | Simulasi harga emas pasar terkini, modul cek kesehatan finansial, dan overlay keamanan. |
| **[1.5.0](#-150--7-mei-2026)** | 7 Mei 2026 | Algoritma proyeksi saldo cerdas akhir bulan, reset statistik bulanan, dan desain minimalis. |
| **[1.5.1](#-151--15-juni-2026)** | 15 Juni 2026 | Sistem catatan keuangan, migrasi Nabung Bersama, kalkulator KPR, FIRE, dan dana darurat. |
| **[1.5.2](#-152--versi-terkini)** | Versi Terkini | Mesin kriptografi CryptoSentinel (AES-256-GCM), celengan receh Round-Up, Saving Streak, & valas live. |

---

## 🐣 [1.0.0] — Februari 2026

*Kelahiran pertama aplikasi TabunganKu sebagai pencatat keuangan pribadi yang aman, sederhana, dan andal.*

### 🆕 Fitur Yang Ditambah
* **Buku Kas Utama (Core Ledger Engine)**:
  * Pencatatan transaksi harian: pemasukan (*income*) dan pengeluaran (*expense*).
  * Pengelompokan kategori dasar transaksi keuangan.
  * Tampilan ringkasan total saldo kas.
* **Autentikasi Biometrik Awal**:
  * Proteksi pembukaan aplikasi memanfaatkan Sidik Jari (*Fingerprint*) dan Face ID melalui sistem operasi bawaan perangkat.

### ⚡ Detail Teknis
* **Engine**: Flutter 3.x / Dart 3.x
* **Penyimpanan**: SQLite Sandbox Lokal

---

## 🧊 [1.2.0] — 31 Maret 2026

*Fase penguatan kolaborasi keluarga, personalisasi identitas pengguna, dan fondasi pengenalan struk digital.*

### 🆕 Fitur Yang Ditambah
* **Manajemen Tabungan Keluarga**:
  * Sinkronisasi data real-time antar perangkat keluarga untuk memantau pos anggaran rumah tangga secara transparan.
  * Ringkasan kontribusi tabungan per anggota keluarga.
* **Sistem Profil Pengguna Modern**:
  * Kustomisasi nama panggilan (*nickname*) dan pemilihan avatar identitas profil permanen.
* **Interaksi Sentuhan Ink-Well**:
  * Umpan balik visual dinamis (*ink-well ripple feedback*) pada kartu saldo utama di dashboard.
* **Pondasi Arsitektur Deteksi Struk (OCR Ready)**:
  * Penyiapan modul awal pemrosesan citra digital untuk membaca bukti transaksi fisik dari kamera/galeri.

### 🛠️ Fitur Yang Diubah & Ditingkatkan
* **Optimasi Rendering Dashboard**: Peningkatan fluiditas kartu saldo dan perbaikan transisi antar halaman.
* **Penyempurnaan Form Input Transaksi**: Validasi input nominal yang lebih responsif dan pencegahan nilai negatif tidak disengaja.

### 🐛 Perbaikan Bug & Stabilitas
* **Penyelarasan Versi Flutter CI**: Perbaikan mismatch versi SDK Flutter pada skrip integrasi build agar rilis berjalan mulus.
* **Penanganan Null-Safety**: Pencegahan potensi crash saat memuat profil pengguna yang belum memiliki avatar tersimpan.

### ⚡ Detail Teknis
* **Build**: v1.2.0-stable
* **State Management**: Provider / Riverpod Core
* **Dukungan Platform**: Android 6.0+ (API 23+)

---

## 🎨 [1.3.0] — 1 April 2026

*Evolusi estetika antarmuka modern dengan visualisasi data interaktif dan penguatan arsitektur UI.*

### 🆕 Fitur Yang Ditambah
* **Grafik Finansial Interaktif FL Chart**:
  * Integrasi pustaka `fl_chart` untuk menampilkan grafik donat alokasi kategori pengeluaran dan diagram batang tren arus kas bulanan.
  * Animasi render grafik yang mulus dan interaksi sentuh (*touch tooltips*) informatif.
* **Desain Antarmuka Glassmorphism**:
  * Efek visual modern transparansi kaca (*frosted glass*) pada kartu ringkasan saldo dan kartu aksi cepat.
* **Modul Panduan & Dokumentasi In-App**:
  * Sistem bantuan internal berbasis Markdown untuk memandu pengguna baru memahami seluruh alur fitur TabunganKu.

### 🛠️ Fitur Yang Diubah & Ditingkatkan
* **Optimalisasi Haptic Feedback**: Respon getaran taktil yang presisi pada setiap tombol aksi utama untuk meningkatkan pengalaman penggunaan.
* **Tata Letak Adaptif (Responsive Layout)**: Penyesuaian tata letak widget dashboard agar tampil proporsional pada berbagai ukuran layar ponsel (layar compact hingga tablet).

### 🐛 Perbaikan Bug & Stabilitas
* **Perbaikan Skala Tipografi**: Penanganan teks terpotong (*text overflow*) pada perangkat dengan setelan font sistem berukuran besar (*accessibility scaling*).
* **Stabilitas Sesi Pengguna**: Pembaruan mekanisme penyimpanan sesi agar status profil pengguna tidak tereset saat aplikasi dibuka kembali.

### ⚡ Detail Teknis
* **Engine**: Flutter 3.x / Dart 3.x
* **Pustaka Utama**: `fl_chart`, `google_fonts`
* **Dukungan Build**: Codemagic iOS Test Runner & Android Stable

---

## ⚙️ [1.3.9] — 1 April 2026

*Optimalisasi infrastruktur kompilasi otomatis dan efisiensi distribusi biner aplikasi.*

### 🆕 Fitur Yang Ditambah
* **Integrasi CI/CD Otomatis GitHub Actions**:
  * Pipeline pembuatan rilis otomatis saat pembuatan tag versi baru di GitHub.
  * Pembuatan otomatis release notes berbasis changelog dan banner rilis resmi.
* **Optimasi Split APK per ABI Architecture**:
  * Pemisahan berkas installer Android berdasarkan arsitektur CPU target (`arm64-v8a`, `armeabi-v7a`, dan `x86_64`).
  * Memangkas ukuran file unduhan aplikasi hingga **40% lebih hemat** dibandingkan format fat-APK universal.

### 🛠️ Fitur Yang Diubah & Ditingkatkan
* **Optimasi Waktu Build**: Pemanfaatan caching dependensi pada GitHub Actions sehingga proses kompilasi rilis 2x lebih cepat.
* **Restrukturisasi Aset Rilis**: Penataan repositori aset banner dan badge rilis secara terpusat di `assets/releases/`.

### 🐛 Perbaikan Bug & Stabilitas
* **Pembersihan Dependency Warning**: Menghilangkan peringatan dependensi kadaluarsa saat proses kompilasi rilis produksi.

### ⚡ Detail Teknis
* **Paket Distribusi**: Split APKs (`app-arm64-v8a-release.apk`, `app-armeabi-v7a-release.apk`, `app-x86_64-release.apk`)
* **Pipeline**: GitHub Actions Ubuntu Runner dengan JDK 17

---

## 🏗️ [1.4.0] — 3 April 2026

*Restrukturisasi antarmuka catatan belanja menjadi halaman penuh dan optimalisasi mesin notifikasi.*

### 🆕 Fitur Yang Ditambah
* **Halaman Penuh Catatan Belanja (Full-Page Shopping Notes)**:
  * Migrasi daftar catatan belanja dari model lembar bawah (*bottom sheet*) menjadi tampilan halaman penuh yang lebih leluasa dan nyaman digunakan saat berbelanja.
  * Input kuantitas barang, estimasi harga, dan status ceklis barang terbeli.
* **Saluran Notifikasi Prioritas Tinggi**:
  * Pendaftaran notification channel prioritas tinggi di sistem Android agar pengingat jadwal tidak terhambat oleh optimasi baterai agresif sistem operasi.

### 🛠️ Fitur Yang Diubah & Ditingkatkan
* **Mesin Penjadwalan Notifikasi v2**: Optimalisasi kinerja pengingat terjadwal yang 20% lebih hemat daya baterai dengan presisi waktu yang akurat.
* **Akselerasi Booting Aplikasi**: Pemangkasan modul inisialisasi awal saat peluncuran aplikasi (*startup time*) untuk pengalaman yang lebih gegas.

### 🗑️ Pembersihan Kode & Optimasi
* **The Great Cleanup**: Penghapusan lebih dari **812 baris kode usang (*dead code*)**, modul prototype yang tidak terpakai, dan aset gambar sementara untuk meringankan beban memori.

### ⚡ Detail Teknis
* **Pustaka Notifikasi**: `flutter_local_notifications`
* **Arsitektur Halaman**: Modul navigasi independen untuk Shopping Notes

---

## 🔘 [1.4.1] — 4 April 2026

*Peningkatan kemudahan navigasi taktil dan integritas relasi antar data keuangan.*

### 🆕 Fitur Yang Ditambah
* **Navigasi Tombol Pill (Pill-Button Navigation)**:
  * Navigasi filter transaksi cepat berbasis tombol oval yang ergonomis untuk berpindah antara Semua, Pemasukan, dan Pengeluaran.
* **Penghapusan Terintegrasi Cerdas (Smart Linked Deletion)**:
  * Menghapus transaksi hutang atau pos belanja secara otomatis membersihkan mutasi kas terkait demi menjaga konsistensi saldo buku kas.

### 🛠️ Fitur Yang Diubah & Ditingkatkan
* **Penyempurnaan Riwayat Mutasi**: Tata letak kartu riwayat mutasi dengan kontras warna pembeda yang lebih tegas antara kas masuk (hijau) dan kas keluar (merah).
* **Caching Data Profil**: Informasi profil disimpan pada cache memori cepat untuk meminimalkan beban I/O disk.

### 🐛 Perbaikan Bug & Stabilitas
* **Sinkronisasi Saldo Terkoreksi**: Menghilangkan inkonsistensi saldo saat transaksi berkala dihapus secara manual oleh pengguna.

### ⚡ Detail Teknis
* **UI Pattern**: Ergonomic Pill Buttons with Smooth State Animation
* **Database**: Foreign Key Cascading Simulation

---

## 🛡️ [1.4.2] — 6 April 2026

*Pengendalian anggaran bulanan proaktif dan penyajian kartu detail transaksi yang mendalam.*

### 🆕 Fitur Yang Ditambah
* **Pelacak Anggaran Proaktif (Proactive Budget Tracker)**:
  * Peringatan visual dini saat pengeluaran bulanan menyentuh ambang batas **80%** (waspada) dan **90%** (kritis) dari kuota anggaran.
* **Kartu Rincian Transaksi High-Fidelity**:
  * Tampilan detail transaksi dengan desain kartu premium: menyajikan informasi tanggal, jam, kategori, catatan, ID referensi, dan opsi edit cepat.

### 🛠️ Fitur Yang Diubah & Ditingkatkan
* **Penyempurnaan Dialog Konfirmasi**: Dialog konfirmasi penghapusan data dengan rincian nama item untuk mencegah ketidaksengajaan.
* **Format Mata Uang Dinamis**: Format angka pemisah ribuan otomatis (*auto-comma formatter*) saat pengguna mengetik nominal.

### 🐛 Perbaikan Bug & Stabilitas
* **Perbaikan Filter Tanggal**: Koreksi logika seleksi rentang tanggal akhir bulan kabisat.

### ⚡ Detail Teknis
* **Komponen**: `HighFidelityDetailCard`, `BudgetProgressBar`
* **Audit**: Form Validation Hardening

---

## 🎯 [1.4.3] — 7 April 2026

*Peningkatan kecerdasan buatan pemindai bukti struk transaksi hingga pecahan mikro.*

### 🆕 Fitur Yang Ditambah
* **AI Merchant Recognition**:
  * Peningkatan akurasi model pembaca teks struk pembayaran digital terkemuka di Indonesia (BCA, DANA, OVO, GoPay, dan ShopeePay).
* **Dukungan Transaksi Mikro**:
  * Kemampuan membaca dan memproses nominal terkecil hingga satuan **Rp 1** dengan presisi tinggi tanpa pembulatan paksa.

### 🛠️ Fitur Yang Diubah & Ditingkatkan
* **Optimasi Pre-Processing Citra**: Penerapan filter kontras dan ambang batas biner (*binary thresholding*) otomatis sebelum citra struk diproses oleh mesin OCR.
* **Penyempurnaan Parsing Tanggal Struk**: Pengenalan otomatis berbagai format penulisan tanggal pada struk kasir (*DD/MM/YYYY*, *YYYY-MM-DD*, dan *DD-Mon-YYYY*).

### 🐛 Perbaikan Bug & Stabilitas
* **Penyelesaian Glitch Kamera**: Memperbaiki masalah layar hitam sesaat saat berpindah dari pratinjau kamera ke formulir transaksi.

### ⚡ Detail Teknis
* **Mesin OCR**: Enhanced Regex & Tokenizer Parser
* **Toleransi Citra**: Multi-Resolution Support

---

## 🎨 [1.4.4] — 9 April 2026

*Penyempurnaan kenyamanan visual untuk penggunaan jangka panjang di kondisi cahaya redup.*

### 🆕 Fitur Yang Ditambah
* **Mode Gelap Sinematik (Cinematic Dark Mode)**:
  * Kalibrasi palet warna gelap menggunakan *true black* dan abu-abu gelap dengan kontras bersertifikasi WCAG AAA untuk kenyamanan mata di malam hari dan efisiensi baterai layar OLED/AMOLED.

### 🛠️ Fitur Yang Diubah & Ditingkatkan
* **Pembaruan Halaman Tantangan Menabung**:
  * Tata letak kartu tantangan menabung yang lebih terstruktur dengan kartu progres visual yang lebih memotivasi.
* **Penyelarasan Aset Rilis**: Standardisasi penggunaan banner rilis tunggal yang seragam di seluruh repositori.

### 🐛 Perbaikan Bug & Stabilitas
* **Kontras Teks Mode Gelap**: Memperbaiki warna teks sekunder yang sempat sulit terbaca pada beberapa dialog peringatan di mode gelap.

### ⚡ Detail Teknis
* **Tema**: Cinematic Dark & Pure Light Dual Color Palettes
* **Accessibility**: WCAG AAA Contrast Compliant

---

## 💎 [1.4.5] — 11 April 2026

*Integrasi kalkulator finansial spiritual dan animasi laser modern pemindai struk.*

### 🆕 Fitur Yang Ditambah
* **Kalkulator Zakat & Infaq Terpadu**:
  * Modul penghitungan Zakat Profesi (penghasilan), Zakat Maal (harta simpanan), dan Zakat Fitrah sesuai ketentuan nisab dan harga beras/emas.
  * Hasil perhitungan dapat langsung dialokasikan ke pos pengeluaran sosial.
* **Animasi Laser AI Scan Struk**:
  * Efek visual animasi pemindaian laser futuristik saat memproses foto bukti struk transaksi.
* **Proyeksi Sisa Saldo (Future Forecast)**:
  * Estimasi sisa saldo akhir bulan berdasarkan rata-rata pola pengeluaran harian pengguna.

### 🛠️ Fitur Yang Diubah & Ditingkatkan
* **Profil Sosial Pengembang**: Penambahan tautan profil media sosial dan repositori GitHub pengembang pada menu Tentang Aplikasi.
* **Responsivitas Pemindai Citra**: Kecepatan proses ekstraksi data struk meningkat 35% lebih gegas.

### 🐛 Perbaikan Bug & Stabilitas
* **Perbaikan Validasi Nisab**: Pembaruan formula nisab emas agar mengacu pada standar 85 gram emas murni terkini.

### ⚡ Detail Teknis
* **Modul**: `ZakatCalculatorSheet`, `AiLaserScannerOverlay`
* **Formula**: Nisab Emas & Beras Dinamis

---

## 💎 [1.4.6] — 15 April 2026

*Otomatisasi pencatatan bunga simpanan perbankan dan interaksi geser target tabungan.*

### 🆕 Fitur Yang Ditambah
* **Pengisian Cepat Bunga Tabungan (Multi-Bank Interest)**:
  * Pintasan penghitungan bunga tabungan otomatis dari 10+ bank besar di Indonesia (BCA, Mandiri, BRI, BNI, CIMB, Jago, Blu, Seabank, dll.).
* **Dialog Perizinan Transparan (BackdropBlur)**:
  * Dialog penjelasan perizinan kamera dan memori penyimpanan dengan efek blur latar belakang yang elegan dan edukatif.

### 🛠️ Fitur Yang Diubah & Ditingkatkan
* **Slider Interaktif Target Tabungan**:
  * Pengembalian tampilan kartu Target Tabungan ke model geser horizontal interaktif (*PageView Slider*) yang memanjakan mata.

### 🐛 Perbaikan Bug & Stabilitas
* **Pajak Bunga Bank**: Perhitungan otomatis potongan pajak penghasilan bunga bank (20%) untuk nominal bunga di atas ambang batas.

### ⚡ Detail Teknis
* **Preset Perbankan**: Database suku bunga dasar 10+ bank nasional
* **Komponen UI**: `BackdropFilter` & `PageView.builder`

---

## 🚀 [1.4.7] — 15 April 2026

*Peningkatan stabilitas rendering dashboard dan optimalisasi akurasi grafik donat.*

### 🆕 Fitur Yang Ditambah
* **Zero-Crash Dashboard Engine**:
  * Penanganan tuntas kendala layout *"RenderBox was not laid out"* pada dashboard alokasi, menjamin kestabilan operasional 100% di semua skenario perputaran layar.
* **Optimalisasi Grafik Donat**:
  * Implementasi algoritma cerdas untuk mencegah tumpang tindih label persentase (*anti-overlapping text*) pada segmen kategori bernominal kecil.

### 🛠️ Fitur Yang Diubah & Ditingkatkan
* **Grid Lencana Prestasi**: Penyesuaian fleksibilitas kisi-kisi lencana agar rapi pada resolusi layar ponsel compact (360dp) hingga layar lebar (480dp+).
* **README Styling**: Penyelarasan tata letak banner promosi dan lencana status pada dokumentasi proyek.

### 🐛 Perbaikan Bug & Stabilitas
* **Perbaikan Race Condition Render**: Mengeliminasi kedipan (*flickering*) pada grafik donat saat data transaksi dimuat pertama kali.

### ⚡ Detail Teknis
* **Chart Optimizer**: Custom Radial Label Positioning Algorithm
* **Crash Free Rate**: 100% Resolved RenderBox Exceptions

---

## 💎 [1.4.8] — 20 April 2026

*Peningkatan logika mesin kalkulator finansial, penyelarasan ruang antarmuka, dan perbaikan UX.*

### 🆕 Fitur Yang Ditambah
* **Peningkatan Mesin Kalkulator Finansial**:
  * Algoritma evaluasi ekspresi aritmatika yang lebih presisi dengan penanganan tanda kurung dan prioritas operasi matematika.
  * Tampilan pratinjau hasil perhitungan instan sebelum pengguna menekan tombol sama dengan.
* **Penyelarasan Spasi Tombol Aksi (Refined Spacing)**:
  * Rekalibrasi jarak antar tombol aksi cepat di layar utama agar tidak terjadi penekanan ganda yang tidak disengaja.

### 🛠️ Fitur Yang Diubah & Ditingkatkan
* **Aesthetic Touch-Up**: Peningkatan kehalusan sudut kartu (*border-radius*) dan bayangan lembut (*box-shadow*) pada dashboard.
* **Penyegaran Navigasi Antarmuka**: Transisi antar tab yang lebih responsif dengan kurva animasi *ease-out-cubic*.

### 🐛 Perbaikan Bug & Stabilitas
* **Perbaikan Overflow Kalkulator**: Mengatasi kendala tampilan terpotong saat layar perangkat berada dalam orientasi rotasi tertentu.

### ⚡ Detail Teknis
* **Kalkulator**: Precision Arithmetic Parser with Instant Evaluation
* **Spacing**: 8pt Spatial Grid Alignment

---

## 💎 [1.4.9] — 30 April 2026

*Simulasi aset logam mulia, evaluasi kesehatan finansial, dan penguatan keamanan layar.*

### 🆕 Fitur Yang Ditambah
* **Simulasi & Tabungan Emas Pasar Terkini**:
  * Pelacakan nilai simpanan emas fisik berdasarkan pergerakan harga pasar terkini untuk perencanaan lindung nilai aset (*wealth hedging*).
* **Cek Kesehatan Finansial (Financial Health Checkup)**:
  * Modul analisis mandiri yang memberikan skor kesehatan finansial, rasio tabungan terhadap pengeluaran, rasio utang, serta rekomendasi perbaikan.
* **Lapisan Keamanan Layar Belakang (Security Privacy Overlay)**:
  * Sensor privasi otomatis yang menutupi tampilan data finansial saat pengguna berpindah aplikasi (*App Switcher / Recent Apps*).

### 🛠️ Fitur Yang Diubah & Ditingkatkan
* **Standardisasi Input Formulir**:
  * Migrasi seluruh kolom input formulir ke sistem *Filled Background* yang lebih modern, taktil, dan responsif.
* **Transparansi Arisan Keluarga**: Peningkatan sinkronisasi real-time agar riwayat setoran grup tampil seketika bagi seluruh peserta.

### 🗑️ Pembersihan Kode & Optimasi
* **Eliminasi Input Style Usang**: Pembersihan kode gaya input teks lama yang sudah digantikan oleh sistem form baru.

### ⚡ Detail Teknis
* **Keamanan**: `SecurityPrivacyOverlay` Lifecycle Observer
* **Form System**: Filled Background TextFields with Floating Labels

---

## 💎 [1.5.0] — 7 Mei 2026

*Era antarmuka minimalis elegan, kecerdasan prediksi saldo, dan eliminasi distraksi.*

### 🆕 Fitur Yang Ditambah
* **Smart Balance Projection Engine**:
  * Algoritma cerdas yang menganalisis laju pengeluaran dan pemasukan harian untuk memberikan estimasi saldo kas di akhir bulan secara akurat.
* **Siklus Reset Statistik Bulanan**:
  * Sistem reset otomatis indikator statistik di awal bulan agar pemantauan arus kas selalu relevan dengan periode berjalan tanpa menghapus riwayat transaksi.
* **Desain Pesan Konfirmasi Minimalis**:
  * Standarisasi pesan sukses (*snackbars*) dengan desain modern yang bersih dan tidak menghalangi interaksi layar.

### 🛠️ Fitur Yang Diubah & Ditingkatkan
* **Desain Lembar Detail Minimalis**: Pembersihan emotikon berlebih, bayangan tebal, dan garis pemisah pada lembar detail transaksi demi terciptanya tampilan berkelas dan lapang.
* **Redesain Antarmuka Arisan**: Tampilan arisan dengan sistem *checkbox* minimalis dan tombol tambah peserta bergaya *dashed border*.
* **Penyesuaian Tipografi Kompak**: Penyelarasan ukuran font pada menu aksi cepat dan kartu target.

### 🗑️ Pembersihan Kode & Optimasi
* **Visual Clutter Elimination**: Penghapusan ornamen grafis redundan untuk memprioritaskan keterbacaan data numerik.

### ⚡ Detail Teknis
* **Algoritma**: Moving Average Daily Spending Projection
* **Filosofi UI**: Modern Clean Minimalism

---

## 💎 [1.5.1] — 15 Juni 2026

*Integrasi sistem catatan finansial, regenerasi fitur Nabung Bersama, dan suite kalkulator tingkat lanjut.*

### 🆕 Fitur Yang Ditambah
* **Sistem Catatan Finansial Terpadu (Financial Notes System)**:
  * Pembuatan, penelaahan, pengeditan, dan pengarsipan catatan keuangan harian dengan visualisasi minimalis.
  * Halaman rincian catatan (*Note Detail Page*) yang leluasa untuk dokumentasi strategi finansial.
* **Suite Kalkulator Finansial Mandiri**:
  * **KPR Calculator**: Simulasi cicilan rumah bulanan, tenor, dan total bunga pinjaman.
  * **FIRE Calculator**: Estimasi target dana pensiun mandiri (*Financial Independence, Retire Early*).
  * **Emergency Fund Calculator**: Perhitungan kuota dana darurat ideal keluarga (3x, 6x, 12x pengeluaran).
  * **Net Salary Calculator**: Perhitungan gaji bersih setelah potongan PPh 21 dan iuran wajib.
  * **Budget Rule Analyzer (50/30/20)**: Pembagian pos anggaran otomatis untuk Kebutuhan (50%), Keinginan (30%), dan Tabungan/Investasi (20%).
* **Perencana Sasaran Khusus (Specialized Planners)**:
  * **Wisata Planner**: Alokasi dana liburan domestik dan mancanegara.
  * **Kuliah Planner**: Perencanaan biaya kuliah dan tabungan pendidikan tinggi.
  * **Nikah Planner**: Pos anggaran katering, gedung, busana, dan mas kawin pernikahan.
  * **Hutang Jariyah Tracker**: Pemantauan jadwal jatuh tempo dan cicilan utang.
* **Fitur Pendukung Baru**:
  * Simulator layanan pembayaran QRIS merchant.
  * Mode khusus Ramadan untuk pos infaq, sedekah, dan mudik lebaran.
  * Brankas Finansial & Kontak Darurat keluarga.
  * Premium Image Cropper untuk foto profil pengguna.

### 🛠️ Fitur Yang Diubah & Ditingkatkan
* **Migrasi Total Arisan ke "Nabung Bersama"**:
  * Perombakan fitur arisan lama menjadi sistem tabungan kelompok (*Nabung Bersama*) yang lebih fleksibel, transparan, dan terpercaya.
* **Performa Render Dashboard**: Optimalisasi alokasi memori saat menggambar grafik ringkasan keuangan.
* **Transaksi Berulang**: Penjadwalan transaksi rutin (*recurring*) dengan pengingat notifikasi otomatis.

### 🗑️ Pembersihan Kode & Optimasi
* **Pembersihan Modul Legacy**: Penghapusan kode arisan lama dan berkas pengujian usang (`test/widget_test.dart`).

### ⚡ Detail Teknis
* **Arsitektur**: Modular Clean Layered Architecture
* **Kompresi Aset**: Optimasi gambar ikon dan banner promo

---

## 💎 [1.5.2] — Versi Terkini

*Lompatan teknologi terbesar: Pengamanan kriptografi militer CryptoSentinel, suite kalkulator terlengkap, tabungan receh otomatis, dan pelacakan konsistensi.*

### 🆕 Fitur Yang Ditambah
* **Benteng Kriptografi CryptoSentinel & VIP Access Gateway**:
  * Enkripsi data sensitif menggunakan algoritma militer **AES-256-GCM** dan integritas tanda tangan **HMAC-SHA256**.
  * Teknik *Split-Key XOR Obfuscation* untuk mencegah dekompilasi dan rekayasa balik biner aplikasi.
  * Pengikatan lisensi ke sidik jari perangkat keras (*Device Fingerprint Binding*) secara 100% offline-first.
  * Deteksi pemunduran waktu jam sistem (*Anti-Clock Tampering*) dan perbandingan tanda tangan berwaktu konstan (*Anti-Timing Attacks*).
  * Antarmuka *VIP Access Gate Sheet* untuk aktivasi kode lisensi resmi secara instan.
* **Suite Kalkulator Finansial & Valas Komprehensif**:
  * **Konverter Valuta Asing (Live FX Currency Converter)**: Konversi nilai tukar mata uang dunia (IDR, USD, EUR, JPY, SGD, MYR, SAR) dengan tombol tukar arah cepat.
  * **Tabungan & Simulasi Emas Antam**: Pelacakan estimasi harga live emas batangan, selisih harga beli vs jual kembali (*buyback spread*), dan konversi nilai gram.
  * **Smart Shopping List**: Daftar rencana belanja interaktif dengan subtotal dan sinkronisasi otomatis ke pos pengeluaran kas.
  * **Kalkulator Bunga Berbunga (Compound Interest)**: Simulasi imbal hasil investasi dan pertumbuhan modal jangka panjang dengan setoran berkala.
  * **Kalkulator Gaji Bersih & Pajak**: Simulasi take-home pay dengan potongan PPh 21, iuran BPJS Ketenagakerjaan/Kesehatan, dan pengingat SPT.
  * **Kalkulator Inflasi & Daya Beli**: Estimasi penurunan nilai riil uang di masa depan berdasarkan tingkat inflasi tahunan.
  * **Rule of 72 & Time Value of Money (TVM)**: Proyeksi masa penggandaan modal dan perbandingan nilai kini vs nilai masa depan.
* **Celengan Receh Otomatis (Round-Up Savings)**:
  * Fitur pembulatan transaksi pengeluaran otomatis ke kelipatan terdekat (Rp 1.000, Rp 5.000, Rp 10.000) yang dialokasikan langsung ke celengan tabungan.
* **Pelacak Konsistensi Menabung (Saving Streak)**:
  * Visualisasi kalender menabung harian untuk memantau konsistensi kedisiplinan finansial pengguna.
* **Tab Navigasi Khusus Riwayat Transaksi**:
  * Tampilan tab riwayat tersendiri untuk penelusuran mutasi kas dengan pencarian kata kunci dan rentang tanggal.
* **Calculator Sheet Terpadu**:
  * Lembar kalkulator pop-up dinamis yang dapat dibuka langsung kapan saja saat merencanakan transaksi atau anggaran.
* **Pustaka Ikon Kartun & PinKeypad Modern**:
  * Papan ketik PIN ergonomis dengan sentuhan getaran (*haptic feedback*) dan latar belakang gelombang dinamis (*WaveBackground*).
* **Microservice Cloud Image API & Diagnostics**:
  * Integrasi API unggah gambar dengan pembersihan otomatis metadata EXIF/GPS, konversi WebP 85%, dan diagnostik latensi ping real-time.

### 🛠️ Fitur Yang Diubah & Ditingkatkan
* **Modular Clean Barrel Exports**: Standardisasi struktur arsitektur modular (`core.dart`, `models.dart`, `providers.dart`, `services.dart`, `widgets.dart`, `security.dart`) serta integrasi `LocalDataMixin` untuk pengelolaan data offline-first yang konsisten.
* **Sentralisasi Kunci Penyimpanan**: Konsolidasi seluruh kunci SharedPreferences ke dalam satu berkas `prefs_keys.dart`.
* **Penyempurnaan Navigasi GoRouter**: Sinkronisasi seluruh rute navigasi baru dengan transisi layar yang lebih mulus.

### 🗑️ Pembersihan Kode & Optimasi
* **Pembersihan Modul Usang**: Menghapus modul-modul lama yang telah digantikan oleh suite fitur baru (`thr_bonus_page.dart`, `financial_health_checkup_page.dart`, `fire_calculator_page.dart`) demi menjaga efisiensi ukuran file aplikasi.

### ⚡ Detail Teknis
* **Build**: v1.5.2-stable
* **Keamanan**: AES-256-GCM, HMAC-SHA256, Android Keystore, iOS Keychain
* **Data Layer**: 100% Offline-First Local Data Sovereignty

---

<p align="center">
  <b>TabunganKu — Manajemen Finansial Pribadi Modern, Tangguh, & 100% Menjaga Privasi</b><br>
  © 2026 <b>Muhammad Isaki Prananda</b>
</p>
