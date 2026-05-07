# 🚀 Panduan Kontribusi TabunganKu

Terima kasih telah meluangkan waktu untuk berkontribusi! **TabunganKu** adalah proyek terbuka yang dibangun dengan semangat kolaborasi. Kami sangat menghargai kontribusi dalam bentuk apa pun, mulai dari perbaikan bug, penambahan fitur, hingga penyempurnaan dokumentasi.

---

## 🧭 Peta Jalan Kontribusi

### 1. Persiapan Awal
Sebelum mulai menulis kode, pastikan Anda telah menyiapkan lingkungan pengembangan:
*   **Flutter SDK**: Versi terbaru (Stable Channel).
*   **IDE**: VS Code atau Android Studio dengan ekstensi Dart & Flutter terpasang.
*   **Git**: Terinstal di sistem Anda.

### 2. Alur Kerja Git (Git Flow)
Kami menggunakan alur kerja yang terstruktur untuk menjaga kebersihan repositori:

1.  **Fork**: Salin repositori ini ke akun GitHub Anda.
2.  **Clone**: Unduh hasil fork ke mesin lokal Anda.
    ```bash
    git clone https://github.com/MuhammadIsakiPrananda1/tabunganku-mobile.git
    ```
3.  **Branching**: Buat branch baru untuk tugas spesifik Anda.
    *   Fitur baru: `feat/nama-fitur`
    *   Perbaikan bug: `fix/nama-bug`
    *   Dokumentasi: `docs/nama-dokumen`
    *   Refactor: `refactor/nama-modul`
4.  **Development**: Lakukan perubahan kode.
5.  **Sync**: Pastikan branch Anda tetap mutakhir dengan branch `main` repositori pusat.

### 3. Standar Pesan Commit
Kami mengikuti standar **Conventional Commits** untuk memudahkan pelacakan perubahan:

*   `feat`: Fitur baru untuk pengguna.
*   `fix`: Perbaikan bug.
*   `docs`: Perubahan pada dokumentasi.
*   `style`: Perubahan format (whitespace, semi-colon, dll).
*   `refactor`: Perubahan kode yang tidak memperbaiki bug maupun menambah fitur.
*   `chore`: Pembaruan tugas build, paket dependensi, dll.

**Contoh**: `feat(ocr): menambahkan animasi laser pada scan struk`

---

## 🛠️ Standar Teknis & Arsitektur

### Arsitektur Proyek
TabunganKu menggunakan arsitektur berbasis **MVVM (Model-View-ViewModel)** dengan **Riverpod** sebagai mesin manajemen *state*.
*   **Models**: Representasi data (JSON mapping).
*   **Views/Screens**: Antarmuka pengguna (Widget).
*   **Providers/ViewModels**: Logika bisnis dan pengelolaan data.

### Pedoman Kode
*   **Linting**: Gunakan `flutter_lints` dan pastikan tidak ada peringatan (*warnings*) sebelum melakukan commit.
*   **Clean Code**: Gunakan nama variabel yang deskriptif dan fungsi yang fokus pada satu tugas.
*   **Dokumentasi**: Tambahkan komentar pada logika yang kompleks menggunakan standar docstring Dart (`///`).

---

## 📮 Mengajukan Pull Request (PR)

Saat Anda siap mengirimkan perubahan, ikuti checklist berikut:
- [ ] Kode sudah dites dan berjalan dengan baik di emulator/perangkat fisik.
- [ ] Tidak ada konflik dengan branch `main`.
- [ ] Pesan commit mengikuti standar yang telah ditetapkan.
- [ ] Sertakan screenshot atau rekaman layar jika terdapat perubahan pada antarmuka (UI).

Setiap PR akan ditinjau oleh pemelihara proyek. Kami mungkin memberikan saran atau meminta perubahan sebelum PR disetujui dan digabungkan.

---

## 🐞 Melaporkan Masalah (Issue)

Jika Anda menemukan bug atau memiliki ide fitur, silakan buka **Issue** dengan detail berikut:
1.  **Judul**: Singkat dan jelas.
2.  **Deskripsi**: Apa yang terjadi vs apa yang diharapkan.
3.  **Langkah Reproduksi**: 1, 2, 3...
4.  **Lingkungan**: Versi Flutter, OS (Android/iOS), dan model perangkat.

---

## 🤝 Kode Etik

Kami berkomitmen untuk menciptakan lingkungan yang inklusif dan bebas pelecehan. Kami mengharapkan semua kontributor untuk berkomunikasi secara profesional dan saling menghormati pendapat satu sama lain.

---
Mari kita bangun **TabunganKu** menjadi aplikasi pengelolaan keuangan terbaik dan paling elegan bersama-sama! 💰✨

© 2026 **Neverland Studio** | Dipersembahkan oleh **Muhammad Isaki Prananda**
