# 🛡️ Kebijakan Keamanan (Security Policy)

Keamanan data finansial Anda adalah prioritas mutlak bagi kami di **Neverland Studio**. Kami berkomitmen untuk melindungi informasi sensitif pengguna **TabunganKu** melalui praktik pengembangan yang aman dan respon cepat terhadap setiap potensi ancaman keamanan.

---

## 🗓️ Versi yang Didukung Secara Aktif

Kami hanya memberikan pembaruan keamanan dan tambalan (*patch*) untuk versi aplikasi yang tercantum di bawah ini. Kami sangat menyarankan pengguna untuk selalu menggunakan versi terbaru demi perlindungan maksimal.

| Versi | Status Dukungan |
| :--- | :--- |
| **1.5.x** | ✅ **Aktif (Sangat Disarankan)** |
| **1.4.x** | ⚠️ Dukungan Terbatas |
| **< 1.4.0** | ❌ Tidak Didukung |

---

## 📩 Melaporkan Kerentanan (Vulnerability Reporting)

Jika Anda menemukan celah keamanan atau kerentanan dalam aplikasi **TabunganKu**, kami sangat menghargai jika Anda melaporkannya secara bertanggung jawab melalui jalur privat.

### Cara Melaporkan:
Mohon **JANGAN** mempublikasikan masalah keamanan melalui *Public Issue* di GitHub atau media sosial mana pun sebelum kami memiliki kesempatan untuk memperbaikinya.

Kirimkan laporan Anda secara privat melalui:
*   **Email**: [security@neverlandstudio.id](mailto:security@neverlandstudio.id)
*   **Subjek**: `[SECURITY BUG] - TabunganKu - <Nama Kerentanan>`
*   **Informasi yang Diperlukan**:
    1. Deskripsi mendetail tentang kerentanan yang ditemukan.
    2. Langkah-langkah untuk mereproduksi (Proof of Concept).
    3. Potensi dampak bagi pengguna atau sistem.
    4. Versi aplikasi dan sistem operasi yang digunakan saat penemuan.

---

## ⚙️ Proses Penanganan Kami

Setelah menerima laporan Anda, tim keamanan kami akan melakukan langkah-langkah berikut:

1.  **Konfirmasi**: Kami akan mengirimkan balasan tanda terima dalam waktu maksimal **24 jam**.
2.  **Validasi**: Tim kami akan melakukan verifikasi terhadap temuan tersebut.
3.  **Perbaikan**: Jika valid, kami akan mengerjakan tambalan (*patch*) keamanan secepat mungkin.
4.  **Pengungkapan (Disclosure)**: Setelah perbaikan dirilis, kami akan melakukan pengungkapan publik (jika diperlukan) dan memberikan penghargaan berupa penyebutan nama Anda di bagian kontributor khusus/CHANGELOG (dengan persetujuan Anda).

---

## 🔐 Standar Keamanan Data TabunganKu

Sebagai informasi, TabunganKu telah menerapkan standar keamanan dasar berikut:
*   **Firebase Security Rules**: Pengetatan akses database di tingkat cloud.
*   **Code Obfuscation**: Pengaburan kode sumber untuk mencegah rekayasa balik (*reverse engineering*).
*   **Local Encryption**: Enkripsi pada data sensitif yang disimpan di penyimpanan lokal (Hive).
*   **Biometric Authentication**: Dukungan integrasi sidik jari dan wajah untuk akses aplikasi.

---
Terima kasih telah membantu kami menjaga keamanan komunitas pengguna **TabunganKu**.

© 2026 **Neverland Studio** | Dipersembahkan oleh **Muhammad Isaki Prananda**
