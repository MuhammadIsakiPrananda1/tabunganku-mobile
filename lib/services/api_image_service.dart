/// Service: ApiImageService
///
/// Layanan integrasi TabunganKu Secure Image API.
/// Menyediakan fungsi upload, sanitasi otomatis (WebP), pengecekan kesehatan server,
/// konfigurasi dinamis (Base URL & API Key), serta pengujian koneksi langsung.
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

final apiImageServiceProvider = Provider<ApiImageService>((ref) {
  return ApiImageService();
});

class ServerHealthInfo {
  final bool isHealthy;
  final String status;
  final String service;
  final String domain;
  final String uptime;
  final int latencyMs;
  final String? errorMessage;

  const ServerHealthInfo({
    required this.isHealthy,
    required this.status,
    required this.service,
    required this.domain,
    required this.uptime,
    required this.latencyMs,
    this.errorMessage,
  });
}

class ApiUploadResult {
  final bool success;
  final String? url;
  final String? filename;
  final String? errorMessage;
  final int? statusCode;
  final int? rateLimitRemaining;

  const ApiUploadResult({
    required this.success,
    this.url,
    this.filename,
    this.errorMessage,
    this.statusCode,
    this.rateLimitRemaining,
  });
}

class ApiImageService {
  // Domain resmi permanen TabunganKu Image API (tidak dapat diubah)
  static const String defaultBaseUrl = 'https://api.neverlandstudio.my.id';
  static const String defaultApiKey = 'tabunganku_secure_upload_key_2026';

  /// Getter sinkronus untuk backward compatibility
  static String get baseUrl => defaultBaseUrl;
  static String get apiKey => defaultApiKey;

  /// Sanitasi URL: bersihkan spasi, hilangkan trailing slash, pastikan memiliki skema
  static String sanitizeUrl(String url) {
    var cleaned = url.trim();
    while (cleaned.endsWith('/')) {
      cleaned = cleaned.substring(0, cleaned.length - 1).trim();
    }
    if (cleaned.isNotEmpty && !cleaned.startsWith('http://') && !cleaned.startsWith('https://')) {
      cleaned = 'https://$cleaned';
    }
    return cleaned;
  }

  /// Ambil Base URL aktif (permanen domain resmi)
  static Future<String> getBaseUrl() async => defaultBaseUrl;

  /// Ambil API Key aktif (permanen default resmi)
  static Future<String> getApiKey() async => defaultApiKey;


  /// Mendeteksi MediaType yang didukung server
  static MediaType _getMediaType(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    switch (ext) {
      case '.png':
        return MediaType('image', 'png');
      case '.webp':
        return MediaType('image', 'webp');
      case '.gif':
        return MediaType('image', 'gif');
      case '.jpg':
      case '.jpeg':
      default:
        return MediaType('image', 'jpeg');
    }
  }

  /// Cek kesehatan & status uptime server (boolean sederhana)
  static Future<bool> checkHealth() async {
    try {
      final currentBaseUrl = await getBaseUrl();
      final uri = Uri.parse('$currentBaseUrl/health');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiImageService] Health check failed: $e');
      return false;
    }
  }

  /// Cek kesehatan lengkap dan waktu respons latensi server
  static Future<ServerHealthInfo> getHealthDetails() async {
    final stopwatch = Stopwatch()..start();
    final currentBaseUrl = await getBaseUrl();
    try {
      final uri = Uri.parse('$currentBaseUrl/health');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      stopwatch.stop();

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ServerHealthInfo(
          isHealthy: true,
          status: data['status']?.toString() ?? 'healthy',
          service: data['service']?.toString() ?? 'tabunganku-image-api',
          domain: data['domain']?.toString() ?? currentBaseUrl,
          uptime: data['uptime']?.toString() ?? 'aktif',
          latencyMs: stopwatch.elapsedMilliseconds,
        );
      }

      return ServerHealthInfo(
        isHealthy: false,
        status: 'HTTP ${response.statusCode}',
        service: 'tabunganku-image-api',
        domain: currentBaseUrl,
        uptime: '-',
        latencyMs: stopwatch.elapsedMilliseconds,
        errorMessage: 'Server merespons dengan status ${response.statusCode}',
      );
    } catch (e) {
      stopwatch.stop();
      return ServerHealthInfo(
        isHealthy: false,
        status: 'offline',
        service: 'tabunganku-image-api',
        domain: currentBaseUrl,
        uptime: '-',
        latencyMs: stopwatch.elapsedMilliseconds,
        errorMessage: e.toString().contains('SocketException')
            ? 'Tidak dapat terhubung ke server. Periksa koneksi internet.'
            : e.toString(),
      );
    }
  }

  /// Upload gambar dengan laporan hasil terperinci (error message, status code, rate limit)
  static Future<ApiUploadResult> uploadImageDetailed(File file) async {
    try {
      if (!await file.exists()) {
        debugPrint('[ApiImageService] File tidak ditemukan: ${file.path}');
        return const ApiUploadResult(
          success: false,
          errorMessage: 'Berkas foto tidak ditemukan di memori perangkat.',
        );
      }

      // Validasi batas ukuran file 5 MB
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        final sizeMb = (fileSize / (1024 * 1024)).toStringAsFixed(2);
        debugPrint('[ApiImageService] File melebihi batas 5MB: ${sizeMb}MB');
        return ApiUploadResult(
          success: false,
          statusCode: 413,
          errorMessage: 'Ukuran foto ($sizeMb MB) melebihi batas maksimal 5 MB.',
        );
      }

      final currentBaseUrl = await getBaseUrl();
      final currentApiKey = await getApiKey();

      final uri = Uri.parse('$currentBaseUrl/api/upload');
      final request = http.MultipartRequest('POST', uri);

      // 1. Tambahkan API Key pada header
      request.headers['x-api-key'] = currentApiKey;

      // 2. Tentukan MediaType yang valid
      final mediaType = _getMediaType(file.path);
      var filename = path.basename(file.path);
      if (!filename.contains('.')) {
        filename = '$filename.jpg';
      }

      // 3. Lampirkan file pada field 'image'
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          file.path,
          filename: filename,
          contentType: mediaType,
        ),
      );

      // 4. Kirim request dengan timeout 25 detik
      final streamedResponse = await request.send().timeout(const Duration(seconds: 25));
      final response = await http.Response.fromStream(streamedResponse);

      final rateRemainingHeader = response.headers['ratelimit-remaining'];
      final rateRemaining = rateRemainingHeader != null ? int.tryParse(rateRemainingHeader) : null;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final imageUrl = (jsonResponse['url'] ?? jsonResponse['data']?['url']) as String?;
          final savedName = (jsonResponse['data']?['filename']) as String?;
          if (imageUrl != null && imageUrl.isNotEmpty) {
            debugPrint('[ApiImageService] Upload berhasil: $imageUrl');
            return ApiUploadResult(
              success: true,
              url: imageUrl,
              filename: savedName,
              statusCode: response.statusCode,
              rateLimitRemaining: rateRemaining,
            );
          }
        }
      }

      // Analisis kode error HTTP untuk pesan ramah pengguna
      String errorMsg = 'Upload gagal (Status ${response.statusCode})';
      try {
        final Map<String, dynamic> errJson = jsonDecode(response.body);
        if (errJson.containsKey('message')) {
          errorMsg = errJson['message'].toString();
        }
      } catch (_) {}

      if (response.statusCode == 401 || response.statusCode == 403) {
        errorMsg = 'Autentikasi gagal. Periksa kembali API Key Anda di Pengaturan.';
      } else if (response.statusCode == 413) {
        errorMsg = 'Ukuran foto melebihi kapasitas server (maksimal 5 MB).';
      } else if (response.statusCode == 429) {
        errorMsg = 'Batas upload tercapai (Rate limit). Mohon tunggu beberapa saat.';
      }

      debugPrint('[ApiImageService] Upload gagal [${response.statusCode}]: ${response.body}');
      return ApiUploadResult(
        success: false,
        statusCode: response.statusCode,
        errorMessage: errorMsg,
        rateLimitRemaining: rateRemaining,
      );
    } catch (e) {
      debugPrint('[ApiImageService] Error saat upload gambar: $e');
      final isConnectionIssue = e.toString().contains('SocketException') ||
          e.toString().contains('ClientException') ||
          e.toString().contains('TimeoutException');

      return ApiUploadResult(
        success: false,
        errorMessage: isConnectionIssue
            ? 'Tidak dapat terhubung ke server API. Periksa koneksi internet Anda.'
            : 'Terjadi kesalahan sistem saat mengunggah foto: $e',
      );
    }
  }

  /// Upload gambar ke server TabunganKu
  /// Mengembalikan URL publik gambar (contoh: https://api.neverlandstudio.my.id/uploads/<uuid>.webp)
  static Future<String?> uploadImage(File file) async {
    final result = await uploadImageDetailed(file);
    return result.success ? result.url : null;
  }

  /// Hapus gambar dari server berdasarkan filename atau URL lengkap
  static Future<bool> deleteImage(String filenameOrUrl) async {
    try {
      final trimmed = filenameOrUrl.trim();
      if (trimmed.isEmpty) return false;

      // Ambil nama file UUID WebP saja
      String filename;
      final uriParsed = Uri.tryParse(trimmed);
      if (uriParsed != null && uriParsed.pathSegments.isNotEmpty) {
        filename = uriParsed.pathSegments.last.trim();
      } else {
        filename = trimmed.split('/').last.trim();
      }

      if (filename.contains('?')) {
        filename = filename.split('?').first;
      }
      if (filename.contains('#')) {
        filename = filename.split('#').first;
      }

      if (filename.isEmpty) return false;

      final currentBaseUrl = await getBaseUrl();
      final currentApiKey = await getApiKey();

      final uri = Uri.parse('$currentBaseUrl/api/upload/$filename');
      final response = await http.delete(
        uri,
        headers: {
          'x-api-key': currentApiKey,
        },
      ).timeout(const Duration(seconds: 15));

      final success = response.statusCode >= 200 && response.statusCode < 300;
      if (success) {
        debugPrint('[ApiImageService] Hapus gambar berhasil: $filename');
      } else {
        debugPrint('[ApiImageService] Gagal menghapus gambar [$filename]: ${response.statusCode}');
      }
      return success;
    } catch (e) {
      debugPrint('[ApiImageService] Error saat menghapus gambar: $e');
      return false;
    }
  }

  /// Uji live upload: membuat gambar uji coba kecil (1x1 GIF), mengunggah ke server,
  /// lalu langsung menghapusnya kembali untuk memverifikasi jalur API 100% fungsional.
  static Future<ApiUploadResult> testUpload() async {
    File? tempFile;
    try {
      final tempDir = await getTemporaryDirectory();
      tempFile = File('${tempDir.path}/test_upload_${DateTime.now().millisecondsSinceEpoch}.png');

      // 1x1 Transparent PNG binary
      final pngBytes = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
      );
      await tempFile.writeAsBytes(pngBytes);

      final result = await uploadImageDetailed(tempFile);

      // Jika berhasil diunggah, bersihkan gambar uji dari server
      if (result.success && result.url != null) {
        await deleteImage(result.url!);
      }

      return result;
    } catch (e) {
      return ApiUploadResult(
        success: false,
        errorMessage: 'Gagal menjalankan uji upload: $e',
      );
    } finally {
      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
    }
  }

  // Instance method helpers untuk fleksibilitas Riverpod
  Future<String?> upload(File file) => uploadImage(file);
  Future<ApiUploadResult> uploadDetailed(File file) => uploadImageDetailed(file);
  Future<bool> delete(String filenameOrUrl) => deleteImage(filenameOrUrl);
  Future<bool> ping() => checkHealth();
  Future<ServerHealthInfo> details() => getHealthDetails();
  Future<ApiUploadResult> test() => testUpload();
}
