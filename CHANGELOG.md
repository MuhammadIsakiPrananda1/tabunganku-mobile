# 📝 Catatan Perubahan (Changelog) - TabunganKu

Seluruh evolusi, fitur, dan perbaikan aplikasi **TabunganKu** terdokumentasi secara lengkap di sini. Kami berkomitmen untuk terus berinovasi, menghadirkan solusi pengelolaan keuangan yang cerdas, aman, dan memiliki estetika premium bagi pengguna kami.

---

## 💎 [1.5.1] — 15 Juni 2026: New Horizons & Advanced Financial Tools
*Rilis v1.5.1 menghadirkan lompatan besar bagi ekosistem TabunganKu dengan integrasi sistem pencatatan terpadu, perombakan total fitur Arisan menjadi Nabung Bersama yang lebih andal, serta serangkaian kalkulator finansial tingkat lanjut.*

### 🆕 Fitur Yang Ditambah
*   **Note-Taking System**: Integrasi CRUD Catatan lengkap dan halaman detail khusus untuk mendokumentasikan rencana keuangan.
*   **Advanced Financial Calculators**: Serangkaian kalkulator baru untuk membimbing keputusan finansial (KPR, FIRE, Dana Darurat, Gaji Bersih, Aturan Anggaran 50/30/20, Rencana Pelunasan Utang & Skor Kesehatan Finansial).
*   **Specialized Planners**: Modul baru untuk mewujudkan rencana khusus seperti Wisata/Liburan, Dana Pendidikan (Kuliah), Anggaran Pernikahan, dan pelacakan cicilan Hutang Jariyah.
*   **Fitur Pendukung Baru**: Halaman layanan QRIS simulator, Halaman khusus Ramadan Mode, Brankas Finansial & Kontak Darurat, serta Premium Image Cropper untuk foto profil.

### 🛠️ Fitur Yang Diubah
*   **Arisan Migration**: Peningkatan dan migrasi total fitur Arisan menjadi "Nabung Bersama" dengan sinkronisasi database real-time dan UI yang dirancang ulang.
*   **Dashboard & Settings Overhaul**: Peningkatan performa render grafik dashboard, perbaikan setelan PIN keamanan, serta integrasi image upload service.
*   **Transactions Optimization**: Optimalisasi riwayat transaksi berulang (Recurring Transactions) dan modul pemindaian struk (Scan Receipt) agar lebih akurat.

### 🗑️ Fitur Yang Dihapus
*   **Arisan Page & Providers**: Penghapusan modul arisan lama karena telah sepenuhnya digantikan oleh fitur Nabung Bersama.
*   **Widget Test Cleanup**: Penghapusan file uji coba widget lama (`test/widget_test.dart`) untuk menjaga kebersihan repositori.

---

## 💎 [1.5.0] — 7 Mei 2026: Minimalist Aesthetics & Smart Projection
*Rilis ini menandai era baru desain TabunganKu dengan fokus pada kesederhanaan premium dan kecerdasan analisis prediktif.*

### 🆕 Fitur Yang Ditambah
*   **Smart Balance Projection**: Algoritma cerdas yang menganalisis tren pemasukan dan pengeluaran harian untuk memberikan estimasi saldo akhir bulan secara akurat.
*   **Dashboard Monthly Reset**: Sistem reset otomatis statistik setiap awal bulan untuk memastikan pemantauan keuangan tetap relevan dan fokus pada periode berjalan.
*   **Premium Success Feedback**: Standarisasi pesan sukses (*snackbars*) dengan desain yang lebih bersih, profesional, dan tidak mengganggu alur pengguna.

### 🛠️ Fitur Yang Diubah
*   **Minimalist Detail Overhaul**: Pembersihan seluruh lembar detail transaksi dan target dari penggunaan emotikon berlebih untuk mencapai tampilan yang lebih lega dan berkelas.
*   **Advanced Arisan Management**: Redesain total UI Arisan dengan sistem *checkbox* yang lebih bersih dan implementasi tombol "Tambah Peserta" bergaya *dashed border*.
*   **Compact UI Typography**: Penyesuaian ukuran font pada menu *Quick Actions* dan kartu target untuk memberikan keseimbangan visual yang lebih baik.

### 🗑️ Fitur Yang Dihapus
*   **Visual Clutter Elimination**: Penghapusan elemen dekoratif, bayangan berlebihan, dan garis pemisah yang tidak perlu pada lembar detail demi estetika minimalis.

---

## 💎 [1.4.9] — 30 April 2026: Security Modernization & Unified Aesthetics
*Fokus pada perlindungan data berlapis dan penyelarasan bahasa desain ke seluruh penjuru aplikasi.*

### 🆕 Fitur Yang Ditambah
*   **Financial Health Check**: Modul analisis kesehatan finansial instan yang memberikan skor dan rekomendasi berdasarkan rasio pengeluaran Anda.
*   **Real-time Gold Price Simulation**: Simulasi nilai investasi emas berdasarkan harga pasar terkini untuk membantu perencanaan aset masa depan.
*   **Security Modernization**: Implementasi *Security Overlay* yang melindungi kerahasiaan data saat aplikasi berada di latar belakang (mode *task switcher*).

### 🛠️ Fitur Yang Diubah
*   **Unified Finance Aesthetics**: Redesain total halaman *Challenge Menabung* dan *Simulasi* untuk menyelaraskan dengan bahasa desain premium TabunganKu.
*   **Shared Family Transparency**: Peningkatan sinkronisasi Firestore real-time yang memungkinkan seluruh anggota keluarga melihat riwayat transaksi grup secara instan.
*   **Enhanced Empty States**: Tampilan *placeholder* UI yang elegan pada bagian distribusi pengeluaran untuk menjaga estetika saat data masih kosong.
*   **Filled Input System**: Migrasi seluruh formulir input ke sistem *Filled Background* yang lebih taktil dan responsif.

### 🗑️ Fitur Yang Dihapus
*   **Legacy Input Style**: Pembersihan gaya input teks lama yang sudah tidak relevan dengan standar modern v1.4.9.
*   **Calculator Layout Fix**: Resolusi masalah *RenderFlex overflow* pada modul kalkulator di perangkat layar kecil.

---

## 🚀 [1.4.7] — 15 April 2026: Visual Perfection & Zero-Crash Stability
*Penyempurnaan stabilitas rendering dashboard dan optimalisasi akurasi grafik.*

### 🆕 Fitur Yang Ditambah
*   **Zero-Crash Dashboard**: Perbaikan tuntas pada pengecualian *"RenderBox was not laid out"* pada dashboard alokasi, menjamin kestabilan operasional 100%.
*   **Donut Chart Optimization**: Implementasi algoritma pencegahan tumpang tindih label pada grafik donat untuk keterbacaan data yang maksimal.

### 🛠️ Fitur Yang Diubah
*   **Badge Grid Fix**: Perbaikan sistem grid pada koleksi lencana agar tetap responsif dan sempurna di semua ukuran layar smartphone.

---

## 💎 [1.4.6] — 15 April 2026: Smart Income & Multi-Bank Interest
*Otomatisasi pencatatan pendapatan pasif dan peningkatan keamanan privasi.*

### 🆕 Fitur Yang Ditambah
*   **Multi-Bank Interest Quick-Fill**: Otomatisasi pengisian bunga tabungan dari 10+ bank besar untuk proses pencatatan pendapatan yang lebih praktis.
*   **Strict Permission Security**: Sistem dialog perizinan premium dengan efek *BackdropBlur* yang memberikan edukasi transparan mengenai akses privasi.

### 🛠️ Fitur Yang Diubah
*   **UI Restoration**: Pengembalian desain Target Tabungan ke versi *PageView Slider* yang interaktif dan sangat intuitif bagi pengguna.

---

## 💎 [1.4.5] — 11 April 2026: The Intelligence Hub & Spiritual Finance
*Integrasi fitur asisten cerdas dan kalkulator finansial spiritual.*

### 🆕 Fitur Yang Ditambah
*   **Premium Scan AI**: Fitur pemindaian struk dengan animasi *Laser AI* futuristik dan sistem *Smart Auto-fill* yang presisi.
*   **Zakat & Infaq Calculator**: Kalkulator zakat terpadu (Profesi, Maal, Fitrah) yang terintegrasi langsung dengan arus kas utama.
*   **Future Forecast**: Prediksi estimasi sisa saldo akhir bulan berdasarkan tren pengeluaran harian dan pola transaksi masa lalu.

---

## 🎨 [1.4.4] — 9 April 2026: Aesthetic Polish & Cinematic Dark Mode
*Penyempurnaan kenyamanan visual untuk penggunaan jangka panjang.*

### 🆕 Fitur Yang Ditambah
*   **Cinematic Dark Mode**: Kalibrasi ulang kontras warna gelap untuk kenyamanan mata maksimal di segala kondisi cahaya.

### 🛠️ Fitur Yang Diubah
*   **Challenge Page Overhaul**: Tata letak tantangan menabung yang lebih rapi, terstruktur, dan memberikan motivasi visual yang lebih kuat.

---

## 🎯 [1.4.3] — 7 April 2026: OCR Precision & Intelligent Merchant Detection
*Peningkatan kecerdasan buatan dalam mengenali detail struk fisik.*

### 🆕 Fitur Yang Ditambah
*   **Enhanced AI Merchant Detection**: Peningkatan akurasi deteksi struk dari provider besar seperti BCA, DANA, OVO, dan GoPay.
*   **Micro-Nominal Support**: Dukungan pemrosesan scan struk hingga nominal terkecil (**Rp 1**) dengan presisi tinggi.

---

## 🛡️ [1.4.2] — 6 April 2026: Proactive Budgeting & High-Fidelity Detail
*Kendali finansial proaktif dengan visualisasi detail transaksi yang mendalam.*

### 🆕 Fitur Yang Ditambah
*   **Proactive Budget Tracker**: Sistem peringatan otomatis saat pengeluaran mendekati batas anggaran bulanan (80% dan 90%).
*   **Fidelity Transaction Details**: Tampilan detail transaksi dengan desain kartu premium yang sangat terstruktur dan berkelas.

---

## 🔘 [1.4.1] — 4 April 2026: Tactile Navigation & Linked Intelligence
*Interaksi antarmuka yang lebih gegas dan sinkronisasi data yang cerdas.*

### 🆕 Fitur Yang Ditambah
*   **Pill-Button Navigation**: Sistem navigasi berbasis tombol *pill* baru di halaman riwayat untuk pengalaman penggunaan yang lebih taktil.
*   **Smart Linked Deletion**: Fitur penghapusan transaksi terkait secara otomatis saat menghapus data hutang atau belanja untuk menjaga integritas database.

---

## 🏗️ [1.4.0] — 3 April 2026: Structural Refinement & High-Efficiency
*Transisi ke arsitektur UI yang lebih lega dan pembersihan besar-besaran untuk efisiensi.*

### 🆕 Fitur Yang Ditambah
*   **Full-Page Shopping Notes**: Migrasi catatan belanja dari *BottomSheet* ke halaman penuh untuk kenyamanan manajemen daftar belanja yang maksimal.
*   **High-Priority Channels**: Implementasi saluran notifikasi prioritas tinggi agar pengingat penting tidak terhambat oleh optimasi sistem operasi.
*   **Enhanced Visibility**: Visualisasi daftar item yang lebih tajam dan tertata rapi.

### 🛠️ Fitur Yang Diubah
*   **Notification Engine v2**: Optimalisasi penjadwalan notifikasi yang 20% lebih hemat baterai dengan ketepatan waktu tinggi.
*   **Dependency Audit**: Pengoptimalan modul internal untuk booting aplikasi yang lebih stabil dan gegas.

### 🗑️ Fitur Yang Dihapus
*   **The Great Cleanup**: Penghapusan lebih dari 812 baris kode usang (*dead code*) untuk meringankan beban aplikasi secara signifikan.

---

## ⚙️ [1.3.9] — 1 April 2026: Infrastructure & ABI Optimization
*Infrastruktur modern untuk distribusi aplikasi yang lebih cepat.*

### 🆕 Fitur Yang Ditambah
*   **GitHub Actions Integration**: Implementasi rilis otomatis berbasis CI/CD untuk pengiriman pembaruan yang lebih stabil dan terjamin.
*   **Split APK (ABI)**: Optimasi varian APK untuk ukuran unduhan yang 40% lebih hemat bagi pengguna.

---

## 🎨 [1.3.0] — 1 April 2026: Visual Intelligence & Glassmorphism Evolution
*Evolusi visual besar-besaran dengan penguatan fondasi teknis.*

### 🆕 Fitur Yang Ditambah
*   **Interactive Financial Charts**: Visualisasi data keuangan interaktif menggunakan `fl_chart` dengan animasi halus dan respon sentuhan.
*   **Modern Documentation Engine**: Sistem bantuan internal baru berbasis Markdown untuk tampilan panduan pengguna yang lebih kaya.
*   **Premium Glassmorphism UI**: Desain dashboard dengan efek transparansi modern (*frosted glass*) untuk kesan mewah dan bersih.

### 🛠️ Fitur Yang Diubah
*   **Haptic Feedback Optimization**: Peningkatan respon getaran haptic untuk pengalaman pengguna yang lebih responsif.
*   **Adaptive Layout Engine**: Penyesuaian tata letak global yang presisi untuk konsistensi di berbagai ukuran layar smartphone.

---

## 🧊 [1.2.0] — 31 Maret 2026: Family Foundation & Personalization
*Kolaborasi keluarga dan personalisasi profil yang mendalam.*

### 🆕 Fitur Yang Ditambah
*   **Manajemen Tabungan Keluarga**: Sinkronisasi database real-time antar perangkat anggota keluarga untuk kolaborasi keuangan.
*   **Sistem Profil Modern**: Kustomisasi identitas pengguna dengan nickname dan pemilihan avatar secara permanen.
*   **Ink-Well Dashboard**: Efek visual premium (*Ink-Well*) pada interaksi kartu saldo untuk UX yang lebih responsif.
*   **Smart OCR Infrastructure**: Persiapan awal sistem deteksi nominal belanja dari foto struk fisik.

---

## 🐣 [1.0.0] — Februari 2026: The Birth of TabunganKu
*Kelahiran aplikasi pencatat keuangan yang aman, sederhana, dan terpercaya.*

### 🆕 Fitur Yang Ditambah
*   **Core Ledger Engine**: Sistem dasar pencatatan transaksi harian yang stabil dan mudah digunakan sebagai pondasi utama.
*   **Biometric Security**: Keamanan akses tingkat tinggi dengan dukungan Sidik Jari dan FaceID.

---
<p align="center">
  <b>TabunganKu - Solusi Finansial Modern di Genggaman Anda</b><br>
  © 2026 <b>Muhammad Isaki Prananda</b>. Dipersembahkan oleh <b>Neverland Studio</b>.
</p>
