# 📖 Dokumentasi & Tata Cara Penggunaan API TabunganKu

Panduan lengkap integrasi dan tata cara penggunaan **TabunganKu Secure Image API**. Layanan microservice ini digunakan untuk upload, sanitasi otomatis (konversi WebP & penghapusan metadata sensitif EXIF), penyimpanan aman, dan penyajian gambar publik.

---

## 📌 Informasi Dasar

| Parameter | Nilai / Keterangan |
|---|---|
| **Base URL (Production)** | `https://api.neverlandstudio.my.id` |
| **Base URL (Lokal / Dev)** | `http://localhost:8089` |
| **Format Gambar Output** | Otomatis dikonversi ke `.webp` (kualitas 85%, max dimensi 2560x2560) |
| **Format Input yang Didukung** | `.jpg`, `.jpeg`, `.png`, `.webp`, `.gif` |
| **Maksimal Ukuran File** | `5 MB` (default) |
| **Rate Limit Upload & Delete** | Maksimal 30 request / 15 menit per IP |
| **Rate Limit Global** | Maksimal 120 request / 1 menit per IP |
| **Proteksi Brute-Force Auth** | Blokir IP setelah 10 kali gagal auth dalam 15 menit |

---

## 🔑 Autentikasi

Semua endpoint untuk **Upload** dan **Hapus** gambar mewajibkan autentikasi API Key. Endpoint pembacaan gambar (`/uploads/...`) dan cek status (`/health`) bersifat **publik**.

API Key dapat dikirimkan melalui salah satu dari 2 opsi header berikut:

### Opsi 1: Custom Header (Direkomendasikan)
```http
x-api-key: YOUR_API_KEY
```

### Opsi 2: Bearer Token
```http
Authorization: Bearer YOUR_API_KEY
```

> ⚠️ **Catatan**: Ganti `YOUR_API_KEY` dengan kunci rahasia yang terpasang pada environment server (misal: `tabunganku_secure_upload_key_2026`). Jangan bagikan API Key ini ke publik.

---

## 📱 Pengaturan API Langsung di Aplikasi TabunganKu

Pengguna dapat memeriksa status, melakukan uji koneksi (ping), menguji upload gambar secara live, serta mengubah Base URL dan API Key secara dinamis langsung dari dalam aplikasi TabunganKu:

1. Buka menu **Pengaturan** (`Settings`) pada bilah navigasi bawah.
2. Pilih menu **Koneksi & Cloud Image API**.
3. Dari jendela pop-up yang muncul, Anda dapat:
   - **Melihat Status Server**: ONLINE / OFFLINE secara real-time beserta waktu respons latensi (ms).
   - **Uji Koneksi**: Mengetes jangkauan koneksi internet ke endpoint `/health`.
   - **Uji Upload**: Mengunggah berkas gambar uji coba secara live dan otomatis membersihkannya kembali untuk memastikan hak akses upload bekerja 100%.
   - **Konfigurasi Endpoint**: Buka *Konfigurasi Endpoint & API Key* untuk beralih antara **Produksi Cloud** (`https://api.neverlandstudio.my.id`) atau **Lokal / Dev** (`http://localhost:8089`), serta memperbarui API Key rahasia Anda.
   - **Reset Default**: Mengembalikan seluruh konfigurasi ke nilai bawaan resmi dengan satu ketukan.

*(Catatan: Anda juga dapat mengakses jendela yang sama melalui tombol ikon awan di pojok kanan atas halaman **Daftar Belanja**).*

---

## 🛣️ Daftar Endpoint

| Method | Endpoint | Auth? | Deskripsi |
|---|---|:---:|---|
| `GET` | `/health` | ❌ | Cek kesehatan & status uptime server |
| `GET` | `/` | ❌ | Informasi ringkas server & daftar endpoint |
| `POST` | `/api/upload` *(atau `/upload`)* | ✅ | Upload dan sanitasi gambar |
| `GET` | `/uploads/:filename` | ❌ | Mengakses / menampilkan gambar publik |
| `DELETE` | `/api/upload/:filename` | ✅ | Menghapus file gambar tertentu |

---

## 1. Cek Status Server (Health Check)

Digunakan untuk memeriksa apakah server aktif dan dapat menerima koneksi.

- **Method**: `GET`
- **URL**: `/health`
- **Headers**: Tidak ada

### Contoh Request (cURL)
```bash
curl -X GET https://api.neverlandstudio.my.id/health
```

### Contoh Response Berhasil (`200 OK`)
```json
{
  "status": "healthy",
  "service": "tabunganku-image-api",
  "domain": "https://api.neverlandstudio.my.id",
  "timestamp": "2026-09-22T05:20:00.000Z",
  "uptime": "3600 seconds"
}
```

---

## 2. Upload Gambar

Mengunggah file gambar ke server. Gambar yang diunggah akan otomatis:
1. Divalidasi tipe file aslinya (*magic bytes*).
2. Diberi nama baru acak (UUID v4) untuk mencegah tabrakan nama dan serangan *path traversal*.
3. Dikonversi menjadi format `.webp` yang ringan dengan kualitas optimal.
4. Seluruh metadata berbahaya (EXIF, lokasi GPS, kamera, dll.) dibersihkan.

- **Method**: `POST`
- **URL**: `/api/upload` (alias: `/upload`)
- **Content-Type**: `multipart/form-data`
- **Headers**:
  - `x-api-key: YOUR_API_KEY` (atau `Authorization: Bearer YOUR_API_KEY`)
- **Body Form-Data**:
  - Field name yang didukung: `image`, `file`, atau `photo`
  - Tipe data: File Binary

### Contoh Request (cURL)
```bash
curl -X POST https://api.neverlandstudio.my.id/api/upload \
  -H "x-api-key: tabunganku_secure_upload_key_2026" \
  -F "image=@/path/to/foto_struk.jpg"
```

### Contoh Response Berhasil (`200 OK`)
```json
{
  "success": true,
  "message": "Image uploaded and sanitized successfully.",
  "url": "https://api.neverlandstudio.my.id/uploads/9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d.webp",
  "data": {
    "filename": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d.webp",
    "url": "https://api.neverlandstudio.my.id/uploads/9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d.webp",
    "size": 75432,
    "width": 1280,
    "height": 720,
    "format": "webp",
    "mimetype": "image/webp",
    "originalName": "foto_struk.jpg"
  }
}
```

### Response Error yang Mungkin Terjadi:
- **`400 Bad Request`**: Tidak ada file yang dikirim, ekstensi tidak didukung, atau file rusak.
  ```json
  {
    "success": false,
    "error": "BadRequest",
    "message": "No image file uploaded. Use form-data field name \"image\", \"file\", or \"photo\"."
  }
  ```
- **`401 Unauthorized`**: Header API Key tidak disertakan.
  ```json
  {
    "success": false,
    "error": "Unauthorized",
    "message": "Missing API Key. Please provide the \"x-api-key\" header."
  }
  ```
- **`403 Forbidden`**: Nilai API Key salah.
  ```json
  {
    "success": false,
    "error": "Forbidden",
    "message": "Invalid API Key."
  }
  ```
- **`413 Payload Too Large`**: Ukuran file melebihi batas (default 5MB).
  ```json
  {
    "success": false,
    "error": "PayloadTooLarge",
    "message": "File size exceeds the maximum limit of 5MB."
  }
  ```
- **`429 Too Many Requests`**: Melebihi kuota upload dalam jendela waktu 15 menit.
  ```json
  {
    "success": false,
    "error": "TooManyRequests",
    "message": "Too many upload requests from this IP, please try again later."
  }
  ```

---

## 3. Menampilkan / Mengakses Gambar Publik

Gambar yang telah tersimpan dapat diakses langsung secara publik tanpa API Key.

- **Method**: `GET`
- **URL**: `https://api.neverlandstudio.my.id/uploads/:filename`
- **Contoh URL**: `https://api.neverlandstudio.my.id/uploads/9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d.webp`

### Karakteristik & Header Keamanan:
- Caching browser/CDN otomatis hingga 1 tahun (`Cache-Control: public, max-age=31536000, immutable`).
- Proteksi Anti-XSS Sandbox (`Content-Security-Policy: default-src 'none'; sandbox`).
- Proteksi MIME sniffing (`X-Content-Type-Options: nosniff`).

---

## 4. Menghapus Gambar

Menghapus file gambar yang tersimpan di server berdasarkan nama filenya.

- **Method**: `DELETE`
- **URL**: `/api/upload/:filename`
- **Headers**:
  - `x-api-key: YOUR_API_KEY` (atau `Authorization: Bearer YOUR_API_KEY`)
- **Params**:
  - `:filename` = Nama file UUID WebP (contoh: `9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d.webp`)

### Contoh Request (cURL)
```bash
curl -X DELETE https://api.neverlandstudio.my.id/api/upload/9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d.webp \
  -H "x-api-key: tabunganku_secure_upload_key_2026"
```

### Contoh Response Berhasil (`200 OK`)
```json
{
  "success": true,
  "message": "Image \"9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d.webp\" deleted successfully."
}
```

### Response Error yang Mungkin Terjadi:
- **`400 Bad Request`**: Format nama file bukan UUID v4 `.webp` yang valid.
  ```json
  {
    "success": false,
    "error": "InvalidFilename",
    "message": "Invalid filename format. Must be a valid UUID v4 .webp filename."
  }
  ```
- **`404 Not Found`**: File gambar tidak ditemukan di server.
  ```json
  {
    "success": false,
    "error": "NotFound",
    "message": "Image file not found."
  }
  ```

---

## 💻 Contoh Implementasi Kode

Berikut adalah contoh cara memanggil API dari berbagai bahasa pemrograman dan framework:

### 1. Flutter / Dart (Aplikasi TabunganKu)

```dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class ApiImageService {
  static const String baseUrl = 'https://api.neverlandstudio.my.id';
  static const String apiKey = 'tabunganku_secure_upload_key_2026';

  /// Upload gambar ke server TabunganKu
  static Future<String?> uploadImage(File file) async {
    try {
      final uri = Uri.parse('$baseUrl/api/upload');
      final request = http.MultipartRequest('POST', uri);

      // 1. Tambahkan API Key pada header
      request.headers['x-api-key'] = apiKey;

      // 2. Lampirkan file pada field 'image'
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          file.path,
          filename: path.basename(file.path),
        ),
      );

      // 3. Kirim request dengan batas waktu (timeout)
      final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          // Kembalikan URL publik gambar
          return jsonResponse['url'] as String;
        }
      } else {
        print('Upload failed [${response.statusCode}]: ${response.body}');
      }
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Hapus gambar dari server
  static Future<bool> deleteImage(String filenameOrUrl) async {
    try {
      // Ambil nama file saja jika input berupa full URL
      final filename = filenameOrUrl.split('/').last;
      final uri = Uri.parse('$baseUrl/api/upload/$filename');

      final response = await http.delete(
        uri,
        headers: {
          'x-api-key': apiKey,
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
}
```

---

### 2. JavaScript / TypeScript (Fetch API / Browser / React Native)

```javascript
const BASE_URL = 'https://api.neverlandstudio.my.id';
const API_KEY = 'tabunganku_secure_upload_key_2026';

/**
 * Upload gambar menggunakan Fetch API
 * @param {File|Blob} file - Objek file dari <input type="file">
 */
async function uploadImage(file) {
  const formData = new FormData();
  formData.append('image', file);

  const response = await fetch(`${BASE_URL}/api/upload`, {
    method: 'POST',
    headers: {
      'x-api-key': API_KEY
      // Jangan set 'Content-Type': browser akan otomatis menambahkan multipart boundary
    },
    body: formData
  });

  const data = await response.json();
  if (!response.ok) {
    throw new Error(data.message || 'Upload gagal');
  }

  return data.url; // Contoh: https://api.neverlandstudio.my.id/uploads/...webp
}

/**
 * Hapus gambar berdasarkan nama file
 * @param {string} filename 
 */
async function deleteImage(filename) {
  const response = await fetch(`${BASE_URL}/api/upload/${filename}`, {
    method: 'DELETE',
    headers: {
      'x-api-key': API_KEY
    }
  });

  const data = await response.json();
  return data.success;
}
```

---

### 3. Node.js (Axios)

```javascript
const axios = require('axios');
const fs = require('fs');
const FormData = require('form-data');

const BASE_URL = 'https://api.neverlandstudio.my.id';
const API_KEY = 'tabunganku_secure_upload_key_2026';

async function uploadLocalImage(filePath) {
  const form = new FormData();
  form.append('image', fs.createReadStream(filePath));

  try {
    const response = await axios.post(`${BASE_URL}/api/upload`, form, {
      headers: {
        ...form.getHeaders(),
        'x-api-key': API_KEY
      }
    });

    console.log('Gambar berhasil diunggah:', response.data.url);
    return response.data;
  } catch (error) {
    console.error('Upload error:', error.response?.data || error.message);
    throw error;
  }
}
```

---

### 4. PHP / Laravel (HTTP Client)

```php
use Illuminate\Support\Facades\Http;

class ImageService
{
    protected string $baseUrl = 'https://api.neverlandstudio.my.id';
    protected string $apiKey = 'tabunganku_secure_upload_key_2026';

    public function uploadImage($file)
    {
        $response = Http::withHeaders([
            'x-api-key' => $this->apiKey,
        ])->attach(
            'image', 
            file_get_contents($file->getRealPath()), 
            $file->getClientOriginalName()
        )->post("{$this->baseUrl}/api/upload");

        if ($response->successful()) {
            return $response->json('url');
        }

        return null;
    }

    public function deleteImage(string $filename)
    {
        $response = Http::withHeaders([
            'x-api-key' => $this->apiKey,
        ])->delete("{$this->baseUrl}/api/upload/{$filename}");

        return $response->successful();
    }
}
```

---

### 5. Python (Requests)

```python
import requests

BASE_URL = 'https://api.neverlandstudio.my.id'
API_KEY = 'tabunganku_secure_upload_key_2026'

def upload_image(file_path: str):
    headers = {
        'x-api-key': API_KEY
    }
    with open(file_path, 'rb') as f:
        files = {'image': f}
        response = requests.post(f"{BASE_URL}/api/upload", headers=headers, files=files)
    
    if response.status_code == 200:
        return response.json()['url']
    else:
        raise Exception(f"Upload error: {response.text}")

def delete_image(filename: str):
    headers = {
        'x-api-key': API_KEY
    }
    response = requests.delete(f"{BASE_URL}/api/upload/{filename}", headers=headers)
    return response.status_code == 200
```

---

## 🛡️ Ringkasan Status & Error Code HTTP

| Status Code | Tipe Error | Solusi / Tindakan |
|:---:|---|---|
| `200` | **OK** | Request berhasil diproses. |
| `400` | **Bad Request** | Pastikan field name berupa `image`, `file`, atau `photo`. Pastikan format file berupa JPG, PNG, WEBP, atau GIF asli. |
| `401` | **Unauthorized** | Header `x-api-key` atau `Authorization: Bearer` belum disertakan. |
| `403` | **Forbidden** | API Key yang dikirim salah. Periksa kembali API Key Anda. |
| `404` | **Not Found** | Endpoint tidak ditemukan atau file yang ingin dihapus tidak ada di server. |
| `413` | **Payload Too Large** | Ukuran gambar melebihi batas 5MB. Kompresi gambar di sisi klien sebelum dikirim. |
| `429` | **Too Many Requests** | Terlalu banyak request. Tunggu beberapa menit sebelum mencoba kembali. |
| `500` | **Internal Server Error** | Terjadi kesalahan pada server saat memproses gambar. |

---

## 💡 Tips & Rekomendasi Integrasi Klien

1. **Kompresi di Sisi Client (Opsional tapi Direkomendasikan)**:
   Meskipun server otomatis mengompresi gambar ke format WebP (kualitas 85), melakukan *downscaling* resolusi di aplikasi mobile sebelum upload akan menghemat kuota pengguna dan mempercepat proses kirim data.
2. **Simpan URL Lengkap di Database**:
   Saat menyimpan data transaksi di aplikasi TabunganKu, simpan langsung string `url` yang dikembalikan API (misal `https://api.neverlandstudio.my.id/uploads/<uuid>.webp`).
3. **Caching**:
   Gambar yang tersimpan bersifat permanen (immutable). Gunakan library image caching di Flutter (seperti `cached_network_image`) agar gambar tidak diunduh berulang kali.
