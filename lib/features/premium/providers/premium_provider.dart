/// Provider: PremiumProvider
///
/// Pengelola state reaktif status VIP/Premium di seluruh antarmuka aplikasi.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/features/premium/models/premium_certificate.dart';
import 'package:tabunganku/features/premium/services/premium_security_service.dart';

class PremiumState {
  final bool isVip;
  final PremiumCertificate? certificate;
  final bool isLoading;
  final String? errorMessage;

  const PremiumState({
    required this.isVip,
    this.certificate,
    this.isLoading = false,
    this.errorMessage,
  });

  PremiumState copyWith({
    bool? isVip,
    PremiumCertificate? certificate,
    bool clearCertificate = false,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PremiumState(
      isVip: isVip ?? this.isVip,
      certificate: clearCertificate ? null : (certificate ?? this.certificate),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class PremiumNotifier extends StateNotifier<PremiumState> {
  final PremiumSecurityService _securityService;

  PremiumNotifier(this._securityService)
      : super(const PremiumState(isVip: false, isLoading: true)) {
    checkStatus();
  }

  /// Memeriksa status VIP dengan verifikasi kriptografis
  Future<void> checkStatus() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final cert = await _securityService.getValidCertificate();
      state = PremiumState(
        isVip: cert != null,
        certificate: cert,
        isLoading: false,
      );
    } catch (e) {
      state = PremiumState(
        isVip: false,
        isLoading: false,
        errorMessage: 'Gagal memverifikasi status keamanan VIP: $e',
      );
    }
  }

  /// Mengaktivasi kode lisensi resmi
  Future<bool> activateLicenseKey(String licenseKey) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final success = await _securityService.activateWithLicenseKey(licenseKey);
      if (success) {
        final cert = await _securityService.getValidCertificate();
        state = PremiumState(
          isVip: true,
          certificate: cert,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Kode lisensi tidak valid atau tidak cocok dengan perangkat ini.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan saat memproses aktivasi: $e',
      );
      return false;
    }
  }

  /// Mengaktivasi paket VIP langsung (Simulasi pembelian paket)
  Future<bool> activatePackage(PremiumTier tier) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final success = await _securityService.activatePackage(tier);
      if (success) {
        final cert = await _securityService.getValidCertificate();
        state = PremiumState(
          isVip: true,
          certificate: cert,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Gagal mengaktifkan paket.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan saat memproses aktivasi paket: $e',
      );
      return false;
    }
  }

  /// Membatalkan / logout hak akses VIP
  Future<void> revokeLicense() async {
    await _securityService.revokePremium();
    state = const PremiumState(isVip: false, isLoading: false);
  }
}

final premiumProvider = StateNotifierProvider<PremiumNotifier, PremiumState>((ref) {
  final service = ref.watch(premiumSecurityServiceProvider);
  return PremiumNotifier(service);
});
