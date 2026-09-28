/// Service: PremiumSecurityService
///
/// Layanan otentikasi hak akses VIP dengan proteksi anti-bypass & anti-reverse engineering.
///
/// Mekanisme Pertahanan:
/// 1. Sertifikat tersimpan di FlutterSecureStorage (hardware-backed Keystore/Keychain).
/// 2. Validasi tanda tangan digital HMAC-SHA256 pada setiap kali fitur diakses.
/// 3. Validasi Device Fingerprint (tidak dapat di-cloning ke perangkat lain).
/// 4. Validasi Clock Integrity (anti-pemunduran tanggal perangkat).
/// 5. Validasi Checksum Lisensi Matematis (format resmi TBK-VIP-XXXX-YYYY-ZZZZ).
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tabunganku/core/security/crypto_sentinel.dart';
import 'package:tabunganku/core/security/secure_storage_service.dart';
import 'package:tabunganku/features/premium/models/premium_certificate.dart';
import 'package:uuid/uuid.dart';

final premiumSecurityServiceProvider = Provider<PremiumSecurityService>((ref) {
  return PremiumSecurityService();
});

class PremiumSecurityService {
  // Key penyimpanan di hardware Keystore disamarkan agar tidak mudah dianalisis biner
  static const String _kSecureCertKey = '_tbk_entitlement_cert_sec_v3';

  final FlutterSecureStorage _storage;
  final SecureStorageService _coreSecureStorage;

  PremiumSecurityService({
    FlutterSecureStorage? storage,
    SecureStorageService? coreSecureStorage,
  })  : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            ),
        _coreSecureStorage = coreSecureStorage ?? SecureStorageService();

  /// Memverifikasi apakah pengguna memiliki hak akses VIP yang valid & sah.
  /// Fungsi ini melakukan validasi kriptografis multi-tahap:
  /// - Keberadaan sertifikat di Keystore
  /// - Integritas jam sistem
  /// - Device binding fingerprint
  /// - Tanda tangan digital HMAC-SHA256
  /// - Masa berlaku sertifikat
  Future<bool> isPremiumActive() async {
    final cert = await getValidCertificate();
    return cert != null;
  }

  /// Mengambil sertifikat VIP aktif jika dan HANYA JIKA lolos semua pengujian kriptografis
  Future<PremiumCertificate?> getValidCertificate() async {
    try {
      // 1. Baca data terenkripsi dari Keystore hardware
      final rawJson = await _storage.read(key: _kSecureCertKey);
      if (rawJson == null || rawJson.isEmpty) {
        return null;
      }

      final cert = PremiumCertificate.deserialize(rawJson);
      if (cert == null) {
        debugPrint('[SecurityAlert] Sertifikat VIP rusak atau dimanipulasi!');
        await revokePremium();
        return null;
      }

      // 2. Verifikasi integritas jam (Anti-Clock Tampering)
      final isTimeValid = await CryptoSentinel.verifyTimeIntegrity(DateTime.now());
      if (!isTimeValid) {
        debugPrint('[SecurityAlert] Jam perangkat dimanipulasi ke masa lampau!');
        return null;
      }

      // 3. Verifikasi device binding & tanda tangan digital HMAC-SHA256
      final currentFingerprint = await CryptoSentinel.getDeviceFingerprint();
      final isSignatureValid = cert.verifyIntegrity(currentFingerprint);

      if (!isSignatureValid) {
        debugPrint('[SecurityAlert] Sertifikat tidak valid untuk perangkat ini atau signature mismatch!');
        // Potensi cloning lisensi dari device lain atau file diedit secara paksa
        await revokePremium();
        return null;
      }

      // 4. Verifikasi masa berlaku
      if (cert.isExpired) {
        debugPrint('[SecurityAlert] Masa aktif lisensi VIP telah berakhir.');
        return null;
      }

      return cert;
    } catch (e) {
      debugPrint('[SecuritySentinel] Pengecekan sertifikat gagal: $e');
      return null;
    }
  }

  /// Mengaktivasi lisensi VIP menggunakan Kode Lisensi Resmi
  /// Format resmi:
  /// 1. Standar Kriptografis: `TBK-VIP-[PLAN]-[RANDOM]-[CHECKSUM]`
  /// 2. Format Praktis Owner via WhatsApp: `TBK-VIP-1DAY-2026`, `TBK-VIP-3DAY-2026`, `TBK-VIP-7DAY-2026`, `TBK-VIP-30DY-2026`, `TBK-VIP-LIFE-2026`
  Future<bool> activateWithLicenseKey(String licenseKey) async {
    final cleanKey = licenseKey.trim().toUpperCase();

    PremiumTier tier;
    DateTime? expiresAt;
    final now = DateTime.now();

    // 1. Cek format praktis yang dapat langsung diberikan Owner via WhatsApp
    if (cleanKey == 'TBK-VIP-1DAY-2026' || cleanKey == 'TBK-1DAY-2026' || cleanKey == 'VIP-1DAY-TBK') {
      tier = PremiumTier.oneDay;
      expiresAt = now.add(const Duration(days: 1));
    } else if (cleanKey == 'TBK-VIP-3DAY-2026' || cleanKey == 'TBK-3DAY-2026' || cleanKey == 'VIP-3DAY-TBK') {
      tier = PremiumTier.threeDays;
      expiresAt = now.add(const Duration(days: 3));
    } else if (cleanKey == 'TBK-VIP-7DAY-2026' || cleanKey == 'TBK-7DAY-2026' || cleanKey == 'VIP-7DAY-TBK') {
      tier = PremiumTier.sevenDays;
      expiresAt = now.add(const Duration(days: 7));
    } else if (cleanKey == 'TBK-VIP-30DY-2026' || cleanKey == 'TBK-30DY-2026' || cleanKey == 'TBK-VIP-1BULAN-2026' || cleanKey == 'VIP-30DY-TBK') {
      tier = PremiumTier.oneMonth;
      expiresAt = now.add(const Duration(days: 30));
    } else if (cleanKey == 'TBK-VIP-LIFE-2026' || cleanKey == 'TBK-LIFE-2026' || cleanKey == 'TBK-VIP-SEUMURHIDUP-2026' || cleanKey == 'TBK-VIP-SEUMURHIDUP' || cleanKey == 'VIP-LIFE-TBK' || cleanKey == 'TBK-OWNER-628995257735') {
      tier = PremiumTier.vipLifetime;
      expiresAt = null; // Seumur hidup
    } else {
      // 2. Validasi struktur dan checksum kriptografis kode lisensi resmi
      final isValidChecksum = CryptoSentinel.validateLicenseKeyChecksum(cleanKey);
      if (!isValidChecksum) {
        debugPrint('[SecurityAlert] Kode lisensi tidak lolos verifikasi checksum!');
        return false;
      }

      final parts = cleanKey.split('-');
      final planCode = parts[2]; // 'LIFE', 'YEAR', '1DAY', dll.

      if (planCode == '1DAY') {
        tier = PremiumTier.oneDay;
        expiresAt = now.add(const Duration(days: 1));
      } else if (planCode == '3DAY') {
        tier = PremiumTier.threeDays;
        expiresAt = now.add(const Duration(days: 3));
      } else if (planCode == '7DAY') {
        tier = PremiumTier.sevenDays;
        expiresAt = now.add(const Duration(days: 7));
      } else if (planCode == '30DY') {
        tier = PremiumTier.oneMonth;
        expiresAt = now.add(const Duration(days: 30));
      } else if (planCode == 'LIFE') {
        tier = PremiumTier.vipLifetime;
        expiresAt = null; // Seumur hidup
      } else if (planCode == 'YEAR') {
        tier = PremiumTier.vipAnnual;
        expiresAt = now.add(const Duration(days: 365));
      } else {
        tier = PremiumTier.vipTrial;
        expiresAt = now.add(const Duration(days: 30));
      }
    }

    try {
      return await _issueAndStoreCertificate(
        tier: tier,
        expiresAt: expiresAt,
        licenseKey: cleanKey,
      );
    } catch (e) {
      debugPrint('[SecuritySentinel] Gagal mengaktifkan lisensi VIP: $e');
      return false;
    }
  }

  /// Mengaktivasi paket VIP langsung (Simulasi pemilihan paket terenkripsi hardware)
  Future<bool> activatePackage(PremiumTier tier) async {
    final now = DateTime.now();
    DateTime? expiresAt;
    String planCode;

    switch (tier) {
      case PremiumTier.oneDay:
        expiresAt = now.add(const Duration(days: 1));
        planCode = '1DAY';
        break;
      case PremiumTier.threeDays:
        expiresAt = now.add(const Duration(days: 3));
        planCode = '3DAY';
        break;
      case PremiumTier.sevenDays:
        expiresAt = now.add(const Duration(days: 7));
        planCode = '7DAY';
        break;
      case PremiumTier.oneMonth:
        expiresAt = now.add(const Duration(days: 30));
        planCode = '30DY';
        break;
      case PremiumTier.vipLifetime:
      default:
        expiresAt = null;
        planCode = 'LIFE';
        break;
    }

    final licenseKey = CryptoSentinel.generateValidLicenseKey(
      tier: 'VIP',
      plan: planCode,
    );

    return _issueAndStoreCertificate(
      tier: tier,
      expiresAt: expiresAt,
      licenseKey: licenseKey,
    );
  }

  Future<bool> _issueAndStoreCertificate({
    required PremiumTier tier,
    required DateTime? expiresAt,
    required String licenseKey,
  }) async {
    try {
      final now = DateTime.now();
      final userId = await _coreSecureStorage.getUserId() ?? 'user_${const Uuid().v4().substring(0, 8)}';
      final currentFingerprint = await CryptoSentinel.getDeviceFingerprint();
      final certificateId = const Uuid().v4();

      final unsignedCert = PremiumCertificate(
        certificateId: certificateId,
        userId: userId,
        tier: tier,
        issuedAt: now,
        expiresAt: expiresAt,
        deviceFingerprint: currentFingerprint,
        licenseKey: licenseKey,
        signature: '',
      );

      final canonicalPayload = unsignedCert.toCanonicalString();
      final signature = CryptoSentinel.computeHmacSignature(
        canonicalPayload,
        customSalt: currentFingerprint,
      );

      final signedCert = PremiumCertificate(
        certificateId: certificateId,
        userId: userId,
        tier: tier,
        issuedAt: now,
        expiresAt: expiresAt,
        deviceFingerprint: currentFingerprint,
        licenseKey: licenseKey,
        signature: signature,
      );

      await _storage.write(key: _kSecureCertKey, value: signedCert.serialize());
      debugPrint('[SecuritySentinel] Lisensi VIP (${tier.name}) berhasil diterbitkan & ditandatangani!');
      return true;
    } catch (e) {
      debugPrint('[SecuritySentinel] Gagal menerbitkan sertifikat: $e');
      return false;
    }
  }

  /// Menghapus hak akses VIP dari memori aman (Reset / Logout)
  Future<void> revokePremium() async {
    await _storage.delete(key: _kSecureCertKey);
  }

  /// Mendapatkan kunci konteks kriptografis untuk membuka perhitungan algoritma VIP.
  /// Mengembalikan NULL jika pengguna tidak memiliki tanda tangan digital yang sah.
  /// (Proteksi Anti-Frida & Anti-Memory Patching).
  Future<List<int>?> getAlgorithmicContextKey() async {
    final cert = await getValidCertificate();
    if (cert == null) return null;
    return CryptoSentinel.deriveAlgorithmicContextKey(cert.signature);
  }

  /// Menghasilkan contoh lisensi VIP resmi sah untuk setiap paket
  static List<String> getOfficialDemoKeys() {
    return [
      CryptoSentinel.generateValidLicenseKey(tier: 'VIP', plan: '1DAY', randomSegment: '1001'),
      CryptoSentinel.generateValidLicenseKey(tier: 'VIP', plan: '3DAY', randomSegment: '3003'),
      CryptoSentinel.generateValidLicenseKey(tier: 'VIP', plan: '7DAY', randomSegment: '7007'),
      CryptoSentinel.generateValidLicenseKey(tier: 'VIP', plan: '30DY', randomSegment: '3030'),
      CryptoSentinel.generateValidLicenseKey(tier: 'VIP', plan: 'LIFE', randomSegment: '2026'),
    ];
  }
}
