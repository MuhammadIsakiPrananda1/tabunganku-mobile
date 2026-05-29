import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  return ImageUploadService();
});

class ImageUploadService {
  // URL Server VPS permanen
  static const String _serverUrl = 'http://103.165.209.246:8089/upload';

  /// Mendapatkan URL server penampung gambar secara permanen.
  Future<String> getServerUrl() async {
    return _serverUrl;
  }

  /// Mengunggah gambar ke server VPS permanen.
  /// Mengembalikan URL gambar di server jika berhasil, atau null jika offline/gagal.
  Future<String?> uploadImage(File file) async {
    try {
      debugPrint('[ImageUploadService] Mengunggah gambar ke VPS: $_serverUrl');
      final uri = Uri.parse(_serverUrl);
      
      final request = http.MultipartRequest('POST', uri);
      
      // Tambahkan file gambar
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();
      
      final multipartFile = http.MultipartFile(
        'image', // Field name di backend (multer 'image')
        stream,
        length,
        filename: p.basename(file.path),
      );
      
      request.files.add(multipartFile);

      // Kirim request dengan timeout agar tidak menggantung jika VPS offline
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true && data['url'] != null) {
          final uploadedUrl = data['url'] as String;
          debugPrint('[ImageUploadService] Upload sukses: $uploadedUrl');
          return uploadedUrl;
        } else if (data['url'] != null) {
          return data['url'] as String;
        }
      }
      
      debugPrint('[ImageUploadService] Gagal upload. Status: ${response.statusCode}, Body: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('[ImageUploadService] Koneksi VPS gagal atau offline (Fallback ke lokal): $e');
      return null;
    }
  }
}
