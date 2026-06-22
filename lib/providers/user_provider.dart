import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class UserProfile {
  final String name;
  final String? photoUrl;

  UserProfile({
    required this.name,
    this.photoUrl,
  });

  UserProfile copyWith({
    String? name,
    String? photoUrl,
    bool clearPhoto = false,
  }) {
    return UserProfile(
      name: name ?? this.name,
      photoUrl: clearPhoto ? null : (photoUrl ?? this.photoUrl),
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(UserProfile(name: '')) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    final photoUrl = prefs.getString('user_photo_url');

if (photoUrl != null && photoUrl.isNotEmpty) {
      if (await File(photoUrl).exists()) {
        state = UserProfile(name: name, photoUrl: photoUrl);
        return;
      } else {

        await prefs.remove('user_photo_url');
      }
    }
    
    state = UserProfile(name: name, photoUrl: null);
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
