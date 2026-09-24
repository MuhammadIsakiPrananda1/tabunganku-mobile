/// Feature: Settings — Security Provider
///
/// Mengelola state keamanan aplikasi: autentikasi PIN, biometrik,
/// lockout, dan status autorisasi sesi aktif.
///
/// Storage strategy:
///   • PIN hash   → [FlutterSecureStorage] via [SecureStorageService]
///   • Lockout    → [SharedPreferences] (data non-sensitif, tidak perlu encrypt)
///   • Biometric  → [SharedPreferences] (flag on/off, bukan data sensitif)
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabunganku/core/security/secure_storage_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final securityProvider =
    StateNotifierProvider<SecurityNotifier, SecurityState>((ref) {
  return SecurityNotifier();
});

// ─────────────────────────────────────────────────────────────────────────────
// SecurityState
// ─────────────────────────────────────────────────────────────────────────────

/// Snapshot immutable dari seluruh state keamanan.
class SecurityState {
  const SecurityState({
    this.isBiometricEnabled = false,
    this.hasPin = false,
    this.isAuthenticating = false,
    this.isInitialized = false,
    this.error,
    this.lastAuthenticatedAt,
    this.isAuthorized = false,
    this.isExternalOperationInProgress = false,
    this.failedAttempts = 0,
    this.lockedUntil,
  });

  final bool isBiometricEnabled;
  final bool hasPin;
  final bool isAuthenticating;
  final bool isInitialized;

  /// Pesan error terakhir dari operasi autentikasi. Null berarti tidak ada error.
  final String? error;

  final DateTime? lastAuthenticatedAt;

  /// True jika sesi saat ini sudah terautentikasi (PIN/biometrik berhasil).
  final bool isAuthorized;

  /// Digunakan untuk mencegah lock-screen muncul ketika ada operasi eksternal
  /// (misal: dialog kamera/galeri) yang sedang berjalan.
  final bool isExternalOperationInProgress;

  final int failedAttempts;

  /// Waktu sampai lockout berakhir. Null berarti tidak dalam kondisi lockout.
  final DateTime? lockedUntil;

  // ── Computed ───────────────────────────────────────────────────────────────

  /// True jika masih dalam periode lockout.
  bool get isLockedOut {
    if (lockedUntil == null) return false;
    return DateTime.now().isBefore(lockedUntil!);
  }

  /// Sisa detik lockout. 0 jika tidak dalam lockout.
  int get remainingLockoutSeconds {
    if (lockedUntil == null) return 0;
    final diff = lockedUntil!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  // ── CopyWith ───────────────────────────────────────────────────────────────

  /// [clearLockout] set ke true untuk menghapus [lockedUntil].
  /// [clearError] set ke true untuk mengosongkan [error].
  SecurityState copyWith({
    bool? isBiometricEnabled,
    bool? hasPin,
    bool? isAuthenticating,
    bool? isInitialized,
    String? error,
    bool clearError = false,
    DateTime? lastAuthenticatedAt,
    bool? isAuthorized,
    bool? isExternalOperationInProgress,
    int? failedAttempts,
    DateTime? lockedUntil,
    bool clearLockout = false,
  }) {
    return SecurityState(
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      hasPin: hasPin ?? this.hasPin,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
      isInitialized: isInitialized ?? this.isInitialized,
      // Preserve error jika tidak ada value baru dan clearError = false
      error: clearError ? null : (error ?? this.error),
      lastAuthenticatedAt: lastAuthenticatedAt ?? this.lastAuthenticatedAt,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      isExternalOperationInProgress:
          isExternalOperationInProgress ?? this.isExternalOperationInProgress,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockedUntil: clearLockout ? null : (lockedUntil ?? this.lockedUntil),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SecurityNotifier
// ─────────────────────────────────────────────────────────────────────────────

/// Notifier yang mengelola semua operasi keamanan: PIN, biometrik, lockout.
class SecurityNotifier extends StateNotifier<SecurityState> {
  SecurityNotifier() : super(const SecurityState()) {
    _loadSettings();
  }

  // ── Dependencies ───────────────────────────────────────────────────────────

  final LocalAuthentication _localAuth = LocalAuthentication();
  final _storage = SecureStorageService();

  // ── SharedPreferences keys (data non-sensitif) ─────────────────────────────
  static const _kBiometricEnabled = 'biometric_enabled';
  static const _kFailedAttempts = 'security_failed_pin_attempts';
  static const _kLockoutUntil = 'security_lockout_until';

  // ── Initialization ─────────────────────────────────────────────────────────

  /// Muat pengaturan keamanan dari storage saat notifier pertama dibuat.
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final isBiometricEnabled = prefs.getBool(_kBiometricEnabled) ?? false;
    final attempts = prefs.getInt(_kFailedAttempts) ?? 0;

    // Cek apakah lockout masih aktif
    DateTime? lockedUntil;
    final lockoutMillis = prefs.getInt(_kLockoutUntil);
    if (lockoutMillis != null) {
      final dt = DateTime.fromMillisecondsSinceEpoch(lockoutMillis);
      if (dt.isAfter(DateTime.now())) {
        lockedUntil = dt;
      } else {
        // Lockout sudah berakhir — bersihkan dari prefs
        await prefs.remove(_kLockoutUntil);
      }
    }

    // Cek apakah PIN sudah tersimpan di SecureStorage
    final pinHash = await _storage.getPinHash();

    state = state.copyWith(
      isBiometricEnabled: isBiometricEnabled,
      hasPin: pinHash != null && pinHash.isNotEmpty,
      isInitialized: true,
      failedAttempts: attempts,
      lockedUntil: lockedUntil,
    );
  }

  // ── PIN utilities ──────────────────────────────────────────────────────────

  /// Hash PIN menggunakan SHA-256 sebelum disimpan/dibandingkan.
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  // ── Lockout logic ──────────────────────────────────────────────────────────

  /// Hitung durasi lockout (detik) berdasarkan jumlah percobaan gagal.
  ///
  /// | Gagal | Lockout  |
  /// |-------|----------|
  /// | < 3   | 0 detik  |
  /// | 3     | 30 detik |
  /// | 4     | 60 detik |
  /// | 5     | 120 detik|
  /// | 6+    | 300 detik|
  int _lockoutSecondsFor(int attempts) {
    if (attempts < 3) return 0;
    if (attempts == 3) return 30;
    if (attempts == 4) return 60;
    if (attempts == 5) return 120;
    return 300;
  }

  /// Catat percobaan PIN gagal dan terapkan lockout jika perlu.
  /// Mengembalikan durasi lockout (0 = tidak ada lockout).
  Future<int> recordFailedPin() async {
    final nextAttempts = state.failedAttempts + 1;
    final lockoutSeconds = _lockoutSecondsFor(nextAttempts);

    DateTime? lockedUntil;
    if (lockoutSeconds > 0) {
      lockedUntil = DateTime.now().add(Duration(seconds: lockoutSeconds));
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kFailedAttempts, nextAttempts);
    if (lockedUntil != null) {
      await prefs.setInt(_kLockoutUntil, lockedUntil.millisecondsSinceEpoch);
    }

    state = state.copyWith(
      failedAttempts: nextAttempts,
      lockedUntil: lockedUntil,
    );
    return lockoutSeconds;
  }

  /// Reset counter percobaan gagal dan hapus lockout.
  Future<void> resetFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kFailedAttempts);
    await prefs.remove(_kLockoutUntil);
    state = state.copyWith(failedAttempts: 0, clearLockout: true);
  }

  // ── Biometric ──────────────────────────────────────────────────────────────

  /// Cek apakah perangkat mendukung autentikasi biometrik.
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } on PlatformException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    }
  }

  /// Tampilkan prompt autentikasi biometrik/device. Mengembalikan true jika
  /// berhasil terautentikasi.
  Future<bool> authenticate() async {
    if (state.isLockedOut) return false;

    try {
      state = state.copyWith(isAuthenticating: true, clearError: true);
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Konfirmasi identitas kamu untuk melanjutkan',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      state = state.copyWith(isAuthenticating: false);
      if (authenticated) await recordSuccessAuth();
      return authenticated;
    } on PlatformException catch (e) {
      state = state.copyWith(isAuthenticating: false, error: e.message);
      return false;
    }
  }

  /// Toggle biometrik on/off. Jika diaktifkan, minta autentikasi terlebih dulu.
  Future<void> toggleBiometric(bool value) async {
    if (value) {
      final authenticated = await authenticate();
      if (!authenticated) return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBiometricEnabled, value);
    state = state.copyWith(isBiometricEnabled: value);
  }

  // ── PIN management ─────────────────────────────────────────────────────────

  /// Simpan PIN baru (di-hash SHA-256) ke SecureStorage dan reset counter.
  Future<void> setPin(String pin) async {
    await _storage.savePinHash(_hashPin(pin));
    await resetFailedAttempts();
    state = state.copyWith(
      hasPin: true,
      isAuthorized: true,
      lastAuthenticatedAt: DateTime.now(),
    );
  }

  /// Hapus PIN dan nonaktifkan biometrik. Dipanggil saat reset keamanan.
  Future<void> clearPin() async {
    await _storage.deletePinHash();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBiometricEnabled, false);
    await resetFailedAttempts();
    state = state.copyWith(hasPin: false, isBiometricEnabled: false);
  }

  /// Verifikasi input PIN pengguna terhadap hash yang tersimpan.
  ///
  /// [trackAttempts] — jika false, percobaan gagal tidak dicatat (dipakai
  /// saat verifikasi PIN lama di alur ganti PIN).
  Future<bool> verifyPin(String inputPin, {bool trackAttempts = true}) async {
    if (trackAttempts && state.isLockedOut) return false;

    final storedHash = await _storage.getPinHash();
    final isValid = storedHash != null && storedHash == _hashPin(inputPin);

    if (trackAttempts) {
      if (isValid) {
        await resetFailedAttempts();
      } else {
        await recordFailedPin();
      }
    }
    return isValid;
  }

  // ── Session management ─────────────────────────────────────────────────────

  /// Tandai sesi sebagai terautentikasi setelah verifikasi berhasil.
  Future<void> recordSuccessAuth() async {
    await resetFailedAttempts();
    state = state.copyWith(
      lastAuthenticatedAt: DateTime.now(),
      isAuthorized: true,
    );
  }

  /// Cabut otorisasi sesi (paksa tampil lock screen kembali).
  void deauthorize() {
    state = state.copyWith(isAuthorized: false);
  }

  /// Tandai bahwa operasi eksternal sedang berjalan (cegah lock-screen muncul).
  void setExternalOperation(bool value) {
    state = state.copyWith(isExternalOperationInProgress: value);
  }
}
