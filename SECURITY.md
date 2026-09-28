# 🛡️ Kebijakan Keamanan (Security Policy)

Keamanan data finansial dan privasi Anda adalah prioritas mutlak bagi kami. Kami berkomitmen untuk melindungi informasi sensitif pengguna **TabunganKu** melalui praktik pengembangan yang aman, arsitektur offline-first, dan respons cepat terhadap setiap potensi ancaman keamanan.

---

## 🗓️ Versi yang Didukung Secara Aktif

Kami hanya memberikan pembaruan keamanan dan tambalan (*patch*) untuk versi aplikasi yang tercantum di bawah ini. Kami sangat menyarankan pengguna untuk selalu menggunakan versi terbaru demi perlindungan maksimal.

| Versi | Status Dukungan |
| :--- | :--- |
| **1.5.x** | ✅ **Aktif (Sangat Disarankan)** |
| **1.4.x** | ⚠️ Dukungan Terbatas |
| **< 1.4.0** | ❌ Tidak Didukung |

---

## 🔐 Standar Arsitektur Keamanan TabunganKu

TabunganKu menerapkan standar keamanan tingkat tinggi yang dirancang khusus untuk audit publik:

1. **Hardware-Backed Encryption (`FlutterSecureStorage`)**:
   - Kredensial sensitif (hash PIN, token otentikasi, ID sesi) disimpan menggunakan enkripsi berbasis perangkat keras (Android Keystore pada Android, iOS Keychain pada iOS) dengan AES-256 & RSA.
   
2. **Kedaulatan Data Lokal (Zero Cloud Financial Storage)**:
   - Seluruh data transaksi, mutasi, anggaran, target tabungan, catatan hutang piutang, dan saldo tersimpan **100% secara lokal** di dalam sandbox aplikasi pada perangkat pengguna.
   - Tidak ada data transaksi yang dikirimkan ke cloud atau server pihak ketiga mana pun tanpa persetujuan eksplisit pengguna.

3. **Otentikasi Biometrik Aman**:
   - Pemanfaatan API otentikasi biometrik standar sistem operasi (`local_auth` / Android BiometricPrompt) untuk pemindaian sidik jari dan Face ID. Aplikasi tidak pernah mengakses atau menyimpan data biometrik mentah pengguna.

4. **Sanitasi Metadata Media (EXIF Stripping)**:
   - Setiap berkas gambar yang diproses atau diunggah ke microservice Cloud Image API otomatis dikonversi ke WebP dan dibersihkan dari metadata EXIF sensitif (koordinat GPS lokasi, merek perangkat, serial kamera).

5. **Proteksi Jaringan & TLS**:
   - Komunikasi HTTP dilindungi oleh TLS/SSL standar. Pengecualian sertifikat dibatasi secara ketat hanya pada mode pengembangan lokal (`kDebugMode`) untuk localhost/emulator.

---

## 📩 Melaporkan Kerentanan (Vulnerability Reporting)

Jika Anda menemukan celah keamanan, kelemahan logika otentikasi, atau anomali privasi dalam aplikasi **TabunganKu**, kami sangat menghargai jika Anda melaporkannya secara bertanggung jawab melalui jalur privat.

### Cara Melaporkan:
Mohon **JANGAN** mempublikasikan masalah keamanan melalui *Public Issue* di GitHub atau media sosial sebelum kami memiliki kesempatan untuk memperbaikinya.

Kirimkan laporan Anda secara privat melalui:
*   **Email**: [Arlianto032@gmail.com](mailto:Arlianto032@gmail.com)
*   **GitHub Security Advisory**: Buat laporan privat melalui fitur *Security Advisory* di repositori resmi.
*   **Subjek Email**: `[SECURITY BUG] - TabunganKu - <Nama Kerentanan>`
*   **Informasi yang Diperlukan**:
    1. Deskripsi mendetail tentang kerentanan yang ditemukan.
    2. Langkah-langkah untuk mereproduksi (Proof of Concept).
    3. Potensi dampak bagi pengguna atau integritas data lokal.
    4. Versi aplikasi, model perangkat, dan versi sistem operasi (Android/iOS).

---

## ⚙️ Proses Penanganan & Respons

Setelah menerima laporan Anda, tim kami akan melakukan langkah-langkah berikut:

1.  **Konfirmasi**: Balasan tanda terima akan dikirimkan dalam waktu maksimal **24 jam**.
2.  **Validasi**: Verifikasi terhadap temuan Proof of Concept.
3.  **Perbaikan**: Pengembangan tambalan (*hotfix/patch*) keamanan prioritas.
4.  **Pengungkapan Bertanggung Jawab (Responsible Disclosure)**: Setelah pembaruan dirilis ke publik, detail perbaikan dapat diumumkan bersama pengakuan kontribusi (*acknowledgement*) di CHANGELOG dan Hall of Fame (dengan persetujuan pelapor).

---

Untuk panduan lengkap mengenai audit kode sumber dan transparansi data, silakan baca [AUDIT.md](file:///c:/Users/LOQ%2015IRX9/Documents/Folder%20Semua%20Aplikasi/Aplikasi%20TabunganKu/AUDIT.md).

© 2026 **Muhammad Isaki Prananda** | TabunganKu — Aman, Transparan, dan Terpercaya.
