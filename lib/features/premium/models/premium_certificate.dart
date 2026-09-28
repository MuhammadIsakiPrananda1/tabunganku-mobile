/// Model: PremiumCertificate
///
/// Sertifikat digital hak akses VIP yang terikat secara kriptografis ke identitas pengguna
/// dan hardware Keystore perangkat.
library;

import 'dart:convert';
import 'package:tabunganku/core/security/crypto_sentinel.dart';

enum PremiumTier {
  free,
  oneDay,      // 1 Hari
  threeDays,   // 3 Hari
  sevenDays,   // 7 Hari
  oneMonth,    // 1 Bulan (30 Hari)
  vipLifetime, // Seumur Hidup
  vipTrial,    // Legacy alias
  vipAnnual,   // Legacy alias
}

extension PremiumTierExtension on PremiumTier {
  String get displayName {
    switch (this) {
      case PremiumTier.oneDay:
        return '1 Hari';
      case PremiumTier.threeDays:
        return '3 Hari';
      case PremiumTier.sevenDays:
        return '7 Hari';
      case PremiumTier.oneMonth:
        return '1 Bulan';
      case PremiumTier.vipLifetime:
        return 'Seumur Hidup';
      case PremiumTier.vipTrial:
        return 'Uji Coba';
      case PremiumTier.vipAnnual:
        return '1 Tahun';
      case PremiumTier.free:
        return 'Gratis';
    }
  }

  String get badge {
    switch (this) {
      case PremiumTier.oneDay:
        return 'Uji Coba';
      case PremiumTier.threeDays:
        return 'Hemat';
      case PremiumTier.sevenDays:
        return 'Fleksibel';
      case PremiumTier.oneMonth:
        return 'Populer';
      case PremiumTier.vipLifetime:
        return 'Best Value';
      default:
        return '';
    }
  }
}

class PremiumCertificate {
  final String certificateId;
  final String userId;
  final PremiumTier tier;
  final DateTime issuedAt;
  final DateTime? expiresAt;
  final String deviceFingerprint;
  final String? licenseKey;
  final String signature;

  const PremiumCertificate({
    required this.certificateId,
    required this.userId,
    required this.tier,
    required this.issuedAt,
    this.expiresAt,
    required this.deviceFingerprint,
    this.licenseKey,
    required this.signature,
  });

  bool get isLifetime => tier == PremiumTier.vipLifetime || expiresAt == null;

  bool get isExpired {
    if (isLifetime) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  String get packageLabel => tier.displayName;

  String get remainingTimeLabel {
    if (isLifetime) return 'Aktif Selamanya';
    if (expiresAt == null) return 'Aktif';
    final diff = expiresAt!.difference(DateTime.now());
    if (diff.isNegative) return 'Kedaluwarsa';
    if (diff.inDays > 0) {
      final hours = diff.inHours % 24;
      return hours > 0 ? '${diff.inDays} hari $hours jam' : '${diff.inDays} hari';
    }
    if (diff.inHours > 0) {
      final mins = diff.inMinutes % 60;
      return mins > 0 ? '${diff.inHours} jam $mins mnt' : '${diff.inHours} jam';
    }
    return '${diff.inMinutes} menit';
  }

  /// String kanonikal unik yang menjadi dasar pembentukan tanda tangan digital HMAC-SHA256
  String toCanonicalString() {
    final expEpoch = expiresAt?.millisecondsSinceEpoch ?? 0;
    final keyStr = licenseKey ?? 'DIRECT';
    return '$certificateId|$userId|${tier.name}|${issuedAt.millisecondsSinceEpoch}|$expEpoch|$deviceFingerprint|$keyStr';
  }

  /// Memvalidasi integritas kriptografis sertifikat terhadap fingerprint perangkat saat ini
  bool verifyIntegrity(String currentDeviceFingerprint) {
    // 1. Validasi device binding: sertifikat tidak boleh dipindahkan ke perangkat lain
    if (deviceFingerprint != currentDeviceFingerprint) {
      return false;
    }

    // 2. Validasi masa berlaku
    if (isExpired) {
      return false;
    }

    // 3. Validasi tanda tangan digital HMAC-SHA256
    final canonical = toCanonicalString();
    return CryptoSentinel.verifyHmacSignature(
      canonical,
      signature,
      customSalt: currentDeviceFingerprint,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'certificateId': certificateId,
      'userId': userId,
      'tier': tier.name,
      'issuedAt': issuedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'deviceFingerprint': deviceFingerprint,
      'licenseKey': licenseKey,
      'signature': signature,
    };
  }

  factory PremiumCertificate.fromJson(Map<String, dynamic> json) {
    PremiumTier parseTier(String? val) {
      switch (val) {
        case 'oneDay':
          return PremiumTier.oneDay;
        case 'threeDays':
          return PremiumTier.threeDays;
        case 'sevenDays':
          return PremiumTier.sevenDays;
        case 'oneMonth':
          return PremiumTier.oneMonth;
        case 'vipTrial':
          return PremiumTier.vipTrial;
        case 'vipAnnual':
          return PremiumTier.vipAnnual;
        case 'vipLifetime':
        default:
          return PremiumTier.vipLifetime;
      }
    }

    return PremiumCertificate(
      certificateId: json['certificateId'] as String,
      userId: json['userId'] as String,
      tier: parseTier(json['tier'] as String?),
      issuedAt: DateTime.parse(json['issuedAt'] as String),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt'] as String) : null,
      deviceFingerprint: json['deviceFingerprint'] as String,
      licenseKey: json['licenseKey'] as String?,
      signature: json['signature'] as String,
    );
  }

  String serialize() => jsonEncode(toJson());

  static PremiumCertificate? deserialize(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is Map<String, dynamic>) {
        return PremiumCertificate.fromJson(decoded);
      }
    } catch (_) {}
    return null;
  }
}
