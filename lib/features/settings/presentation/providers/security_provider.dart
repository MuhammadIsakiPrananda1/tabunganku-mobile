import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

final securityProvider = StateNotifierProvider<SecurityNotifier, SecurityState>((ref) {
  return SecurityNotifier();
});

class SecurityState {
  final bool isBiometricEnabled;
  final bool hasPin;
  final bool isAuthenticating;
  final bool isInitialized;
  final String? error;
  final DateTime? lastAuthenticatedAt;
  final bool isAuthorized;

  SecurityState({
    this.isBiometricEnabled = false,
    this.hasPin = false,
    this.isAuthenticating = false,
    this.isInitialized = false,
    this.error,
    this.lastAuthenticatedAt,
    this.isAuthorized = false,
  });

  SecurityState copyWith({
    bool? isBiometricEnabled,
    bool? hasPin,
    bool? isAuthenticating,
    bool? isInitialized,
    String? error,
    DateTime? lastAuthenticatedAt,
    bool? isAuthorized,
  }) {
    return SecurityState(
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      hasPin: hasPin ?? this.hasPin,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error,
      lastAuthenticatedAt: lastAuthenticatedAt ?? this.lastAuthenticatedAt,
      isAuthorized: isAuthorized ?? this.isAuthorized,
    );
  }
}

class SecurityNotifier extends StateNotifier<SecurityState> {
  SecurityNotifier() : super(SecurityState()) {
    _loadSettings();
  }

  final LocalAuthentication _auth = LocalAuthentication();
  static const _biometricKey = 'biometric_enabled';
  static const _pinKey = 'user_pin_code';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_biometricKey) ?? false;
    final pin = prefs.getString(_pinKey);
    
    state = state.copyWith(
      isBiometricEnabled: isEnabled,
      hasPin: pin != null && pin.isNotEmpty,
      isInitialized: true,
    );
  }

  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } on PlatformException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      state = state.copyWith(isAuthenticating: true, error: null);
      final authenticated = await _auth.authenticate(
        localizedReason: 'Konfirmasi identitas kamu untuk melanjutkan',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      state = state.copyWith(isAuthenticating: false);
      if (authenticated) {
        recordSuccessAuth();
      }
      return authenticated;
    } on PlatformException catch (e) {
      state = state.copyWith(isAuthenticating: false, error: e.message);
      return false;
    }
  }

  void recordSuccessAuth() {
    state = state.copyWith(
      lastAuthenticatedAt: DateTime.now(),
      isAuthorized: true,
    );
  }

  void deauthorize() {
    state = state.copyWith(isAuthorized: false);
  }

  Future<void> toggleBiometric(bool value) async {
    if (value) {
      final authenticated = await authenticate();
      if (!authenticated) return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, value);
    state = state.copyWith(isBiometricEnabled: value);
  }

  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
    state = state.copyWith(hasPin: true);
  }

  Future<void> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
    await prefs.setBool(_biometricKey, false);
    state = state.copyWith(hasPin: false, isBiometricEnabled: false);
  }
  
  Future<bool> verifyPin(String inputPin) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString(_pinKey);
    return savedPin == inputPin;
  }
}
