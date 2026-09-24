/// Core: Services — Base Data Service
///
/// Mixin yang menyediakan boilerplate penyimpanan data lokal berbasis
/// [SharedPreferences] + [SecureStorageService].
///
/// Semua service lokal (`LocalXxxService`) meng-extend mixin ini untuk
/// menghindari duplikasi ~40 baris boilerplate per service.
///
/// ## Cara pakai
/// ```dart
/// class LocalBudgetService extends LocalDataMixin<BudgetModel>
///     implements BudgetService {
///   @override String get storagePrefix => 'budgets_user_';
///   @override BudgetModel itemFromJson(Map<String, dynamic> j) => BudgetModel.fromJson(j);
/// }
/// ```
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabunganku/core/security/secure_storage_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LocalDataMixin<T>
// ─────────────────────────────────────────────────────────────────────────────

/// Mixin generik untuk service yang menyimpan `List<T>` per user ke
/// [SharedPreferences].
///
/// Subclass **wajib** implement [storagePrefix] dan [itemFromJson].
/// Secara opsional dapat override [useSecureUserId] untuk menentukan apakah
/// userId diambil dari [SecureStorageService] (true, default) atau menggunakan
/// user tunggal 'default_user' (false).
mixin LocalDataMixin<T> {
  // ── Abstract members yang wajib diimplementasikan ─────────────────────────

  /// Prefix key SharedPreferences, e.g. `'budgets_user_'`.
  /// Key lengkap = `'$storagePrefix$userId'`.
  String get storagePrefix;

  /// Deserialize satu item dari JSON map.
  T itemFromJson(Map<String, dynamic> json);

  /// Serialize satu item ke JSON map.
  Map<String, dynamic> itemToJson(T item);

  // ── Konfigurasi ──────────────────────────────────────────────────────────

  /// Jika true, userId diambil dari [SecureStorageService].
  /// Jika false, selalu gunakan `'default_user'` (untuk service tanpa
  /// multi-user support).
  bool get useSecureUserId => true;

  // ── Internal state ────────────────────────────────────────────────────────

  static final SecureStorageService _secureStorage = SecureStorageService();
  static Future<SharedPreferences>? _prefsFuture;

  /// Cache data per userId. Key = userId, Value = list data.
  final Map<String, List<T>> _cache = {};

  /// Broadcast stream controller untuk reactive updates.
  final StreamController<List<T>> streamCtrl =
      StreamController<List<T>>.broadcast();

  // ── SharedPreferences lazy singleton ─────────────────────────────────────

  Future<SharedPreferences> getPrefs() {
    _prefsFuture ??= SharedPreferences.getInstance();
    return _prefsFuture!;
  }

  // ── User ID resolution ────────────────────────────────────────────────────

  /// Resolve userId aktif. Gunakan SecureStorage jika [useSecureUserId],
  /// fallback ke 'guest' jika tidak ditemukan.
  Future<String> getCurrentUserId() async {
    if (!useSecureUserId) return 'default_user';
    final id = await _secureStorage.getUserId();
    return (id == null || id.isEmpty) ? 'guest' : id;
  }

  // ── Cache loading ─────────────────────────────────────────────────────────

  /// Muat data dari SharedPreferences ke cache jika belum dimuat.
  Future<void> ensureLoaded(String userId) async {
    if (_cache.containsKey(userId)) return;

    final prefs = await getPrefs();
    final raw = prefs.getString('$storagePrefix$userId');

    if (raw == null || raw.isEmpty) {
      _cache[userId] = [];
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _cache[userId] = decoded
            .whereType<Map>()
            .map((e) => itemFromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        _cache[userId] = [];
      }
    } catch (e, st) {
      debugPrint('[LocalDataService] Error loading $storagePrefix: $e\n$st');
      _cache[userId] = [];
    }
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  /// Simpan cache ke SharedPreferences.
  Future<void> persist(String userId) async {
    final prefs = await getPrefs();
    final list = _cache[userId] ?? const [];
    final raw = jsonEncode(list.map(itemToJson).toList());
    await prefs.setString('$storagePrefix$userId', raw);
  }

  // ── Stream emission ───────────────────────────────────────────────────────

  /// Emit data terbaru ke stream subscriber.
  void emit(String userId) {
    final items = _cache[userId] ?? const [];
    streamCtrl.add(List.unmodifiable(items));
  }

  // ── Save + emit helper ────────────────────────────────────────────────────

  /// Persist ke disk dan emit ke stream dalam satu panggilan.
  Future<void> persistAndEmit(String userId) async {
    await persist(userId);
    emit(userId);
  }

  // ── Cache accessor ────────────────────────────────────────────────────────

  /// Ambil snapshot cache saat ini sebagai unmodifiable list.
  List<T> snapshot(String userId) {
    return List.unmodifiable(_cache[userId] ?? const []);
  }

  // ── Stream builder ────────────────────────────────────────────────────────

  /// Buat stream yang langsung emit data awal lalu mengikuti perubahan.
  Stream<List<T>> buildStream() {
    return Stream<List<T>>.multi((controller) {
      Future<void>(() async {
        final userId = await getCurrentUserId();
        await ensureLoaded(userId);
        controller.add(snapshot(userId));
      });
      final sub = streamCtrl.stream.listen(controller.add);
      controller.onCancel = sub.cancel;
    });
  }
}
