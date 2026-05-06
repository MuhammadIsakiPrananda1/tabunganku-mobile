import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    state = UserProfile(name: name, photoUrl: photoUrl);
  }

  Future<void> setName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    state = state.copyWith(name: name);
  }

  Future<String?> uploadAndSetPhoto(File file) async {
    // In a real app, this would upload to Firebase Storage
    // For now, we'll just save the local path
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_photo_url', file.path);
    state = state.copyWith(photoUrl: file.path);
    return file.path;
  }

  Future<void> deletePhoto() async {
    final prefs = await SharedPreferences.getInstance();
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
