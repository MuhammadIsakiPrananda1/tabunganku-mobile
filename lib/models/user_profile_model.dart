/// Model: UserProfile
///
/// Merepresentasikan profil pengguna lokal aplikasi TabunganKu.
/// Data disimpan di [SharedPreferences] menggunakan [PrefsKeys].
library;

// ─────────────────────────────────────────────────────────────────────────────
// UserProfile
// ─────────────────────────────────────────────────────────────────────────────

/// Data profil pengguna: nama, foto, dan waktu pembuatan akun.
class UserProfile {
  const UserProfile({
    required this.name,
    this.photoUrl,
    required this.createdAt,
  });

  final String name;

  /// Path lokal file foto profil, atau URL jika menggunakan remote. Null jika
  /// belum ada foto.
  final String? photoUrl;

  /// Waktu pertama kali profil dibuat (dipakai untuk cek status "new user").
  final DateTime createdAt;

  // ── Computed ────────────────────────────────────────────────────────────────

  /// True jika akun dibuat kurang dari 72 jam (3 hari) yang lalu.
  bool get isNewUser =>
      DateTime.now().difference(createdAt).inHours < 72;

  // ── CopyWith ────────────────────────────────────────────────────────────────

  /// Salin state dengan nilai baru. Gunakan [clearPhoto] = true untuk
  /// menghapus foto tanpa menyediakan foto baru.
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
