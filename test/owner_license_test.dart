import 'package:flutter_test/flutter_test.dart';
import 'package:tabunganku/core/security/crypto_sentinel.dart';
import 'package:tabunganku/features/premium/models/premium_certificate.dart';

void main() {
  group('Owner License Verification Tests', () {
    test('Official Cryptographic VIP Lifetime key passes checksum', () {
      final key = CryptoSentinel.generateValidLicenseKey(
        tier: 'VIP',
        plan: 'LIFE',
        randomSegment: '2026',
      );
      expect(key, 'TBK-VIP-LIFE-2026-99C2');
      expect(CryptoSentinel.validateLicenseKeyChecksum(key), isTrue);
    });

    test('Owner certificate properties reflect permanent owner status', () {
      final cert = PremiumCertificate(
        certificateId: 'CERT-OWNER-001',
        userId: 'USER-OWNER',
        tier: PremiumTier.vipLifetime,
        issuedAt: DateTime.now(),
        expiresAt: null,
        deviceFingerprint: 'DEV-FINGERPRINT-TEST',
        licenseKey: 'TBK-OWNER-PERMANENT',
        signature: 'SIG-TEST',
      );

      expect(cert.isLifetime, isTrue);
      expect(cert.isOwner, isTrue);
      expect(cert.isExpired, isFalse);
      expect(cert.packageLabel, 'Owner VIP');
      expect(cert.remainingTimeLabel, 'Aktif Selamanya (Owner)');
    });
  });
}
