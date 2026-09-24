/// Service: ImageUploadService
///
/// Pengelolaan upload gambar untuk TabunganKu yang terintegrasi dengan TabunganKu Secure Image API.
library;

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_image_service.dart';

final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  return ImageUploadService();
});

class ImageUploadService {
  /// Upload gambar ke server TabunganKu via ApiImageService
  Future<String?> uploadImage(File file) async {
    return ApiImageService.uploadImage(file);
  }

  /// Upload gambar dengan detail hasil respons
  Future<ApiUploadResult> uploadImageDetailed(File file) async {
    return ApiImageService.uploadImageDetailed(file);
  }

  /// Hapus gambar dari server TabunganKu via ApiImageService
  Future<bool> deleteImage(String filenameOrUrl) async {
    return ApiImageService.deleteImage(filenameOrUrl);
  }

  /// Cek kesehatan & latensi server
  Future<ServerHealthInfo> getHealthDetails() async {
    return ApiImageService.getHealthDetails();
  }

  /// Uji fungsionalitas upload langsung
  Future<ApiUploadResult> testUpload() async {
    return ApiImageService.testUpload();
  }

  /// Dapatkan Base URL aktif
  Future<String> getBaseUrl() async {
    return ApiImageService.getBaseUrl();
  }
}
