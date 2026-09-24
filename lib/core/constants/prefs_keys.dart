/// Core: Constants — SharedPreferences Keys
///
/// Semua string key [SharedPreferences] terpusat di sini.
/// Gunakan class ini untuk menghindari magic strings yang tersebar
/// di seluruh codebase.
///
/// ## Pengelompokan
/// Key dikelompokkan berdasarkan domain (User, Balance, Security, dll).
library;

// ─────────────────────────────────────────────────────────────────────────────
// PrefsKeys
// ─────────────────────────────────────────────────────────────────────────────

/// Kumpulan key [SharedPreferences] yang dipakai aplikasi.
///
/// Semua key bersifat `static const String` untuk zero runtime overhead.
abstract final class PrefsKeys {
  PrefsKeys._();

  // ── User profile ───────────────────────────────────────────────────────────

  /// Nama tampilan pengguna.
  static const String userName = 'user_name';

  /// Path lokal foto profil pengguna.
  static const String userPhotoUrl = 'user_photo_url';

  /// Timestamp (millisecondsSinceEpoch) saat akun pertama dibuat.
  static const String userCreatedAt = 'user_created_at';

  /// Counter urutan untuk generate username default (`user-0001`, dll).
  static const String userCounter = 'user_counter';

  // ── Balance & UI preferences ───────────────────────────────────────────────

  /// Preferensi apakah saldo ditampilkan atau disembunyikan.
  static const String showBalance = 'pref_show_balance';

  // ── Security (non-sensitive, OK di SharedPreferences) ─────────────────────

  /// Flag biometrik aktif/nonaktif.
  static const String biometricEnabled = 'biometric_enabled';

  /// Jumlah percobaan PIN yang gagal.
  static const String failedPinAttempts = 'security_failed_pin_attempts';

  /// Timestamp (millisecondsSinceEpoch) lockout berakhir.
  static const String lockoutUntil = 'security_lockout_until';

}

