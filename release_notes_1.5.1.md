<p align="center">
  <a target="_blank" rel="noopener noreferrer nofollow" href="https://raw.githubusercontent.com/MuhammadIsakiPrananda1/tabunganku-mobile/main/assets/promo_banner.png"><img src="https://raw.githubusercontent.com/MuhammadIsakiPrananda1/tabunganku-mobile/main/assets/promo_banner.png" alt="TabunganKu Banner" width="100%" style="max-width: 100%;"></a>
</p>
<p align="center">
  <a target="_blank" rel="noopener noreferrer nofollow" href="https://img.shields.io/badge/Versi-1.5.1-blue?style=for-the-badge"><img src="https://img.shields.io/badge/Versi-1.5.1-blue?style=for-the-badge" alt="Versi" style="max-width: 100%;"></a>
  <a target="_blank" rel="noopener noreferrer nofollow" href="https://img.shields.io/badge/Flutter-3.0.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white"><img src="https://img.shields.io/badge/Flutter-3.0.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" style="max-width: 100%;"></a>
  <a target="_blank" rel="noopener noreferrer nofollow" href="https://img.shields.io/badge/State-Riverpod-764ABC?style=for-the-badge&logo=riverpod&logoColor=white"><img src="https://img.shields.io/badge/State-Riverpod-764ABC?style=for-the-badge&logo=riverpod&logoColor=white" alt="Riverpod" style="max-width: 100%;"></a>
  <a target="_blank" rel="noopener noreferrer nofollow" href="https://img.shields.io/badge/Backend-Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black"><img src="https://img.shields.io/badge/Backend-Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Backend" style="max-width: 100%;"></a>
  <a target="_blank" rel="noopener noreferrer nofollow" href="https://img.shields.io/badge/Lisensi-MIT-green?style=for-the-badge"><img src="https://img.shields.io/badge/Lisensi-MIT-green?style=for-the-badge" alt="Lisensi" style="max-width: 100%;"></a>
</p>

---

# 💎 TabunganKu Versi 1.5.1: New Horizons & Advanced Financial Tools

Rilis v1.5.1 menghadirkan lompatan besar bagi ekosistem TabunganKu. Kami memperkenalkan modul pencatatan catatan terpadu (*Note-Taking System*), perombakan total fitur Arisan menjadi *Nabung Bersama* yang lebih andal, serta serangkaian kalkulator finansial tingkat lanjut (*KPR, FIRE, Gaji Bersih, Dana Darurat*) untuk memperkuat kendali keuangan Anda secara menyeluruh.

---

### 🆕 Fitur Yang Ditambah

#### 📝 Note-Taking System (Catatan Finansial Terpadu)
Integrasi sistem manajemen catatan lengkap di dalam aplikasi untuk mendokumentasikan rencana keuangan Anda.
*   **CRUD Notes**: Buat, baca, perbarui, dan hapus catatan harian atau memo keuangan secara langsung.
*   **Note Details View**: Halaman detail khusus untuk membaca catatan panjang secara nyaman dengan visualisasi minimalis.

#### 🧮 Advanced Financial Calculators (Kalkulator Keuangan Mandiri)
Serangkaian kalkulator baru untuk membimbing keputusan finansial masa depan Anda:
*   **KPR Calculator**: Hitung estimasi cicilan bulanan rumah, tenor pinjaman, dan rincian total bunga secara ringkas.
*   **FIRE Calculator**: Rencanakan masa pensiun dini Anda dengan menghitung target akumulasi dana pensiun (*Financial Independence, Retire Early*).
*   **Emergency Fund Calculator**: Tentukan target dana darurat ideal berdasarkan kebutuhan pengeluaran bulanan Anda.
*   **Net Salary Calculator**: Hitung gaji bersih Anda setelah dihitung dengan pajak penghasilan dan potongan wajib lainnya.
*   **Budget Rule Analyzer (50/30/20)**: Modul pembagi pos keuangan otomatis berdasarkan aturan anggaran populer (Kebutuhan, Keinginan, Tabungan).

#### 🧳 Specialized Financial Planners (Perencana Rencana Khusus)
Modul baru untuk merencanakan sasaran finansial jangka panjang:
*   **Wisata Planner**: Kelola alokasi dana liburan impian domestik atau internasional dengan lebih tertarget.
*   **Kuliah Planner**: Perencana anggaran biaya pendidikan tinggi per semester secara aman.
*   **Nikah Planner**: Rincian pengeluaran pos gedung, katering, undangan, dan mas kawin pernikahan dalam satu dashboard terpusat.
*   **Hutang Jariyah Tracker**: Kelola data utang piutang dengan pelacakan cicilan dan waktu jatuh tempo.

#### 📲 Fitur Pendukung Lainnya
*   **QRIS Services Page**: Layanan transaksi simulator QRIS merchant dengan aset visual pendukung.
*   **Ramadan Mode Page**: Mode khusus ramadan untuk membantu alokasi pengeluaran ibadah, takjil, zakat, infaq, dan mudik lebaran.
*   **Brankas Finansial & Kontak Darurat**: Penyimpanan aman info aset berharga serta daftar kontak darurat finansial keluarga Anda.
*   **Premium Image Cropper**: Modul pangkas foto profil pengguna agar pas dengan rasio lingkaran profil secara presisi.

---

### 🛠️ Fitur Yang Diubah

#### 👥 Migrasi Arisan ke Nabung Bersama
*   Fitur **Arisan** lama kini ditingkatkan dan diubah menjadi **Nabung Bersama** dengan sinkronisasi database cloud Firestore real-time yang lebih andal, alur kolaborasi anggota grup yang lebih transparan, serta antarmuka yang dirancang ulang.

#### 📊 Dashboard & Settings Overhaul
*   **Dashboard Page**: Peningkatan kecepatan render grafik keuangan (*chart rendering*) dan restrukturisasi layout ringkasan pos anggaran agar lebih lega.
*   **Settings Page**: Optimalisasi tata letak menu setelan, perbaikan alur pengaturan PIN keamanan, serta integrasi image upload service.
*   **Transactions Optimization**: Pembaruan sistem riwayat transaksi berulang (*Recurring Transactions*) dan modul pemindaian struk (*Scan Receipt*) agar berjalan lebih responsif.

---

### 🗑️ Fitur Yang Dihapus

#### 🚫 Modul Legacy & Widget Test
*   **Arisan Page & Providers**: Penghapusan modul arisan lama karena telah digantikan oleh fitur *Nabung Bersama*.
*   **Widget Test Cleanup**: Penghapusan file uji coba widget lama (`test/widget_test.dart`) untuk menjaga kebersihan struktur repositori.

---

### ⚡ Detail Teknis & Performa
*   **Architecture Refinement**: Pemisahan module logic ke dalam clean architecture layer untuk performa loading dashboard yang lebih optimal.
*   **Asset Compression**: Penambahan aset visual (`icon_compressed.png`, `promo_banner.png`) dengan kompresi optimal untuk menghemat ruang unduhan APK.

---

Terima kasih telah menemani perjalanan evolusi TabunganKu hingga versi 1.5.1. Kami berkomitmen untuk selalu mendampingi perencanaan finansial Anda dengan teknologi cerdas dan estetika premium.

**Kendali Penuh Keuangan, Masa Depan Cemerlang!** 💰✨
