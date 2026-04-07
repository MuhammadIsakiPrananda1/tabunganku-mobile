# Catatan Perubahan (CHANGELOG)

Semua perubahan penting pada proyek **TabunganKu** akan didokumentasikan di file ini.

Format pengisian mengikuti [Keep a Changelog](https://keepachangelog.com/id/1.0.0/).

## [1.4.3] - 2026-04-07

### Diperbaiki

- **Akurasi OCR Struk:** Peningkatan signifikan pada deteksi nominal dari berbagai struk perbankan dan e-wallet (BCA, Mandiri, DANA, OVO, GoPay, ShopeePay).
- **Deteksi Nominal Kecil:** Mendukung pemindaian nominal transaksi mulai dari Rp 1.
- **Filter Biaya Siluman:** Secara cerdas mengabaikan biaya admin, biaya transaksi, dan pajak agar hanya jumlah transaksi riil yang tercatat.
- **Filtrasi Metadata:** Pembersihan otomatis data nomor HP dan ID transaksi dari hasil pemindaian struk.

## [1.4.2] - 2026-04-06

### Ditambahkan
- **Fitur Anggaran (Budgeting):** Pantau pengeluaran Anda dengan penetapan batas anggaran bulanan, beserta peringatan visual saat pengeluaran mendekati limit.
- **Detail Transaksi (Detail Sheet):** Tampilan baru yang lebih terstruktur dan premium saat melihat informasi detail sebuah transaksi.

### Diperbaiki
- **UI Overflow pada Form:** Menyelesaikan isu layar terpotong (overflow) pada halaman Tambah Barang agar responsif di seluruh ukuran layar perangkat.
- **Optimasi Dashboard & Notifikasi:** Penyempurnaan penyajian data sisa anggaran dan peningkatan stabilitas trigger notifikasi pengingat.

## [1.4.1] - 2026-04-04

### Ditambahkan

- **Modernisasi UI Riwayat:** Navigasi minimalis dropdown/pill yang elegan menggantikan TabBar lebar untuk pengalaman yang lebih bersih.
- **Sinkronisasi Penghapusan (2 Arah):** Menghapus catatan Hutang atau rencana Belanja kini otomatis menghapus transaksi terkait di Riwayat.
- **Interaktivitas Riwayat:** Seluruh item riwayat kini bisa diklik untuk melihat detail atau dihapus secara individual.
- **Perbaikan Bug & Ripple:** Perbaikan efek ripple pada filter dan penambahan logging untuk diagnosa upload foto profil.
- **Update UI Riwayat (Kategori):** Pemisahan riwayat menjadi kategori: "Pemasukan & Pengeluaran", "Hutang/Piutang", dan "Belanja".
- **Summary Bulanan Cerdas:** Header bulan tetap menghitung total "Masuk" & "Keluar" dari SEMUA jenis transaksi.
- **Custom Foto Profil:** Upload foto profil kustom melalui kamera atau galeri.
- **Sinkronisasi Foto Keluarga:** Sinkronisasi foto profil ke seluruh anggota grup secara real-time.
- **Automasi Transaksi:** Pencatatan otomatis untuk pelunasan hutang dan item belanja yang dibeli.

## [1.4.0] - 2026-04-03

### Ditambahkan

- **Migrasi Catatan Belanja:** Transisi fitur belanja dari model bottom sheet ke halaman mandiri yang lebih premium.
- **Peningkatan Pengingat Harian:** Sistem notifikasi yang lebih stabil dengan deteksi timezone otomatis dan prioritas tinggi (Max Importance).
- **Auto-Reschedule Notifikasi:** Pembaruan otomatis jadwal pengingat setiap kali aplikasi dibuka.

### Diperbaiki

- **Sinkronisasi Waktu:** Perbaikan bug pada penjadwalan notifikasi jam 6 pagi yang sebelumnya tidak muncul.
- **Pembersihan Kode:** Penghapusan 800+ baris kode legacy dan optimalisasi import pada dashboard.

### Diperbarui

- **Versi Aplikasi:** Pembaruan versi aplikasi ke 1.4.0.

## [1.3.0] - 2026-04-01

### Ditambahkan

- **Optimasi UI Dashboard:** Perbaikan visual pada kartu saldo dan grafik interaktif.
- **Pembaruan README:** Dokumentasi yang lebih modern dan informatif.

### Diperbarui
- **Sistem Gradle:** Penyesuaian konfigurasi Android Gradle ke versi 1.3.0 untuk stabilitas build.
- **Versi Aplikasi:** Sinkronisasi versi ke 1.3.0.

## [1.2.0] - 2026-03-31

### Ditambahkan

- **Fitur Scan Struk (OCR):** Deteksi otomatis nominal belanja dari foto struk fisik.
- **Sistem Profil:** Kustomisasi nickname dan pemilihan avatar secara permanen.
- **Ink-Well Dashboard:** Efek visual premium saat menyentuh kartu saldo.
- **Manajemen Tabungan Keluarga:** Sinkronisasi database antar perangkat anggota keluarga.

### Diperbaiki

- Sinkronisasi kustomisasi tema agar tidak kembali ke pengaturan awal saat aplikasi ditutup.
- Penanganan error saat akses pertama kali ke halaman grup keluarga.

## [1.1.0] - Mar 2026

### Ditambahkan

- Implementasi awal database Firebase Firestore.
- Dashboard utama dengan grafik pendapatan vs pengeluaran.
- Fitur target menabung (saving goals).

## [1.0.0] - Feb 2026

- Rilis awal aplikasi TabunganKu.
- Fitur pencatatan transaksi manual.
- Autentikasi lokal (biometrik sederhana).
