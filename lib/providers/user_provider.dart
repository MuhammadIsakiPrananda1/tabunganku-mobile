/// Provider: UserProvider
///
/// Mengelola profil pengguna: nama, foto, dan timestamp pembuatan.
/// Data persisted di [SharedPreferences] menggunakan key dari [PrefsKeys].
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabunganku/core/constants/prefs_keys.dart';
import 'package:tabunganku/models/user_profile_model.dart';
import 'package:tabunganku/services/api_image_service.dart';
export 'package:tabunganku/models/user_profile_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});

/// Convenience provider — langsung baca nama pengguna tanpa subscribe ke
/// seluruh profil.
final userNameProvider = Provider<String>((ref) {
  return ref.watch(userProfileProvider).name;
});

// ─────────────────────────────────────────────────────────────────────────────
// UserProfileNotifier
// ─────────────────────────────────────────────────────────────────────────────

/// Notifier yang mengelola [UserProfile] dan sinkronisasi ke disk.
class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier()
      : super(UserProfile(name: 'user-0001', createdAt: DateTime.now())) {
    _loadProfile();
  }

  // ── Username generation ────────────────────────────────────────────────────

  /// Buat username default dengan format `user-XXXX` berdasarkan counter.
  static String generateDefaultUsername([int count = 1]) {
    return 'user-${count.toString().padLeft(4, '0')}';
  }

  /// Generate username urut berikutnya, persist counter ke SharedPreferences
  /// dan file counter sebagai backup.
  Future<String> _generateSequentialUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var counter = prefs.getInt(PrefsKeys.userCounter) ?? 1;

      // Backup counter di file (ambil nilai terbesar antara prefs & file)
      final appDir = await getApplicationDocumentsDirectory();
      final counterFile = File('${appDir.path}/user_counter.txt');
      if (await counterFile.exists()) {
        final content = await counterFile.readAsString();
        final fileCounter = int.tryParse(content.trim());
        if (fileCounter != null && fileCounter > counter) {
          counter = fileCounter;
        }
      }

      final username = generateDefaultUsername(counter);
      final nextCounter = counter + 1;
      await prefs.setInt(PrefsKeys.userCounter, nextCounter);
      try {
        await counterFile.writeAsString('$nextCounter');
      } catch (_) {}

      return username;
    } catch (_) {
      return 'user-0001';
    }
  }

  // ── Load from disk ─────────────────────────────────────────────────────────

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    // Buat atau ambil timestamp pembuatan akun
    var createdMs = prefs.getInt(PrefsKeys.userCreatedAt);
    if (createdMs == null) {
      createdMs = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(PrefsKeys.userCreatedAt, createdMs);
    }
    final createdAt = DateTime.fromMillisecondsSinceEpoch(createdMs);

    // Resolve nama — generate sequential jika default/kosong
    var name = prefs.getString(PrefsKeys.userName);
    if (name == null ||
        name.trim().isEmpty ||
        name == 'Pengguna TabunganKu' ||
        name == 'user-xxxx' ||
        name.startsWith('user ')) {
      name = await _generateSequentialUsername();
      await prefs.setString(PrefsKeys.userName, name);
    }

    // Validasi foto — hapus path jika file sudah tidak ada
    final photoUrl = prefs.getString(PrefsKeys.userPhotoUrl);
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (await File(photoUrl).exists()) {
        state = UserProfile(name: name, photoUrl: photoUrl, createdAt: createdAt);
        return;
      } else {
        debugPrint('[UserProfile] Foto tidak ditemukan, menghapus path lama.');
        await prefs.remove(PrefsKeys.userPhotoUrl);
      }
    }

    state = UserProfile(name: name, photoUrl: null, createdAt: createdAt);
  }

  // ── Mutations ──────────────────────────────────────────────────────────────

  /// Perbarui nama pengguna dan persist.
  Future<void> setName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.userName, name);
    state = state.copyWith(name: name);
  }

  /// Salin foto ke direktori permanent, unggah ke Cloud API jika online, dan persist.
  Future<String?> uploadAndSetPhoto(File file) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'profile_photo_${DateTime.now().millisecondsSinceEpoch}.png';
      final permanent = await file.copy('${appDir.path}/$fileName');

      // Hapus foto lama jika ada
      final oldPath = state.photoUrl;
      if (oldPath != null && oldPath.isNotEmpty) {
        try {
          if (oldPath.startsWith('http://') || oldPath.startsWith('https://')) {
            ApiImageService.deleteImage(oldPath);
          } else {
            final oldFile = File(oldPath);
            if (await oldFile.exists()) await oldFile.delete();
          }
        } catch (e) {
          debugPrint('[UserProfile] Gagal hapus foto lama: $e');
        }
      }

      // Coba upload ke Cloud API (dengan fallback otomatis ke local disk)
      String chosenUrl = permanent.path;
      try {
        final cloudResult = await ApiImageService.uploadImageDetailed(permanent);
        if (cloudResult.success && cloudResult.url != null && cloudResult.url!.isNotEmpty) {
          chosenUrl = cloudResult.url!;
          debugPrint('[UserProfile] Foto profil berhasil diunggah ke Cloud API: $chosenUrl');
        }
      } catch (e) {
        debugPrint('[UserProfile] Cloud API upload dilewati (offline/fallback): $e');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(PrefsKeys.userPhotoUrl, chosenUrl);
      state = state.copyWith(photoUrl: chosenUrl);
      return chosenUrl;
    } catch (e) {
      debugPrint('[UserProfile] Copy foto gagal, pakai path langsung: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(PrefsKeys.userPhotoUrl, file.path);
      state = state.copyWith(photoUrl: file.path);
      return file.path;
    }
  }

  /// Hapus foto profil dari disk/server dan dari state.
  Future<void> deletePhoto() async {
    final oldPath = state.photoUrl;
    if (oldPath != null && oldPath.isNotEmpty) {
      try {
        if (oldPath.startsWith('http://') || oldPath.startsWith('https://')) {
          await ApiImageService.deleteImage(oldPath);
        } else {
          final oldFile = File(oldPath);
          if (await oldFile.exists()) await oldFile.delete();
        }
      } catch (e) {
        debugPrint('[UserProfile] Gagal hapus foto: $e');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefsKeys.userPhotoUrl);
    state = state.copyWith(clearPhoto: true);
  }
}
