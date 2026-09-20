import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class UserProfile {
  final String name;
  final String? photoUrl;
  final DateTime createdAt;

  UserProfile({
    required this.name,
    this.photoUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isNewUser {
    final difference = DateTime.now().difference(createdAt);
    return difference.inHours < 72; // 3 hari (72 jam)
  }

  UserProfile copyWith({
    String? name,
    String? photoUrl,
    DateTime? createdAt,
    bool clearPhoto = false,
  }) {
    return UserProfile(
      name: name ?? this.name,
      photoUrl: clearPhoto ? null : (photoUrl ?? this.photoUrl),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(UserProfile(name: 'user-0001')) {
    _loadProfile();
  }

  static String generateDefaultUsername([int count = 1]) {
    final paddedNum = count.toString().padLeft(4, '0');
    return 'user-$paddedNum';
  }

  Future<String> _generateSequentialUsername() async {
    int counter = 1;
    try {
      final prefs = await SharedPreferences.getInstance();
      counter = prefs.getInt('user_counter') ?? 1;

      final appDir = await getApplicationDocumentsDirectory();
      final counterFile = File('${appDir.path}/user_counter.txt');
      if (await counterFile.exists()) {
        final content = await counterFile.readAsString();
        final fileCounter = int.tryParse(content.trim());
        if (fileCounter != null && fileCounter > counter) {
          counter = fileCounter;
        }
      }

      final paddedNum = counter.toString().padLeft(4, '0');
      final username = 'user-$paddedNum';

      final nextCounter = counter + 1;
      await prefs.setInt('user_counter', nextCounter);
      try {
        await counterFile.writeAsString('$nextCounter');
      } catch (_) {}

      return username;
    } catch (_) {
      return 'user-0001';
    }
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    var createdMs = prefs.getInt('user_created_at');
    if (createdMs == null) {
      createdMs = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt('user_created_at', createdMs);
    }
    final createdAt = DateTime.fromMillisecondsSinceEpoch(createdMs);

    var name = prefs.getString('user_name');

    if (name == null ||
        name.trim().isEmpty ||
        name == 'Pengguna TabunganKu' ||
        name == 'user-xxxx' ||
        name.startsWith('user ')) {
      name = await _generateSequentialUsername();
      await prefs.setString('user_name', name);
    }

    final photoUrl = prefs.getString('user_photo_url');

    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (await File(photoUrl).exists()) {
        state = UserProfile(name: name, photoUrl: photoUrl, createdAt: createdAt);
        return;
      } else {

        await prefs.remove('user_photo_url');
      }
    }
    
    state = UserProfile(name: name, photoUrl: null, createdAt: createdAt);
  }

  Future<void> setName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    state = state.copyWith(name: name);
  }

  Future<String?> uploadAndSetPhoto(File file) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'profile_photo_${DateTime.now().millisecondsSinceEpoch}.png';
      final permanentFile = await file.copy('${appDir.path}/$fileName');

final oldPath = state.photoUrl;
      if (oldPath != null && oldPath.isNotEmpty) {
        final oldFile = File(oldPath);
        if (await oldFile.exists()) {
          try {
            await oldFile.delete();
          } catch (e) {

          }
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_photo_url', permanentFile.path);
      state = state.copyWith(photoUrl: permanentFile.path);
      return permanentFile.path;
    } catch (e) {

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_photo_url', file.path);
      state = state.copyWith(photoUrl: file.path);
      return file.path;
    }
  }

  Future<void> deletePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final oldPath = state.photoUrl;
    if (oldPath != null && oldPath.isNotEmpty) {
      final oldFile = File(oldPath);
      if (await oldFile.exists()) {
        try {
          await oldFile.delete();
        } catch (e) {

        }
      }
    }
    await prefs.remove('user_photo_url');
    state = state.copyWith(clearPhoto: true);
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});

final userNameProvider = Provider<String>((ref) {
  return ref.watch(userProfileProvider).name;
});
