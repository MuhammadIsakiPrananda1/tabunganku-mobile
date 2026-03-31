import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _pinKey = 'user_pin';
  static const String _sessionIdKey = 'session_id';
  static const String _userIdKey = 'user_id';
  static const String _tokenExpiryKey = 'token_expiry';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // Token Management
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  // PIN Management (Encrypted)
  Future<void> savePinHash(String pinHash) async {
    await _storage.write(key: _pinKey, value: pinHash);
  }

  Future<String?> getPinHash() async {
    return await _storage.read(key: _pinKey);
  }

  Future<void> deletePinHash() async {
    await _storage.delete(key: _pinKey);
  }

  // Session Management
  Future<void> saveSessionId(String sessionId) async {
    await _storage.write(key: _sessionIdKey, value: sessionId);
  }

  Future<String?> getSessionId() async {
    return await _storage.read(key: _sessionIdKey);
  }

  Future<void> deleteSessionId() async {
    await _storage.delete(key: _sessionIdKey);
  }

  // User ID Storage
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  Future<void> deleteUserId() async {
    await _storage.delete(key: _userIdKey);
  }

  // Token Expiry
  Future<void> saveTokenExpiry(String expiry) async {
    await _storage.write(key: _tokenExpiryKey, value: expiry);
  }

  Future<String?> getTokenExpiry() async {
    return await _storage.read(key: _tokenExpiryKey);
  }

  // Clear all secure data
  Future<void> clearAll() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _sessionIdKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _tokenExpiryKey),
    ]);
  }

  // Clear auth data (but keep PIN for quick login)
  Future<void> clearAuthData() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _sessionIdKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _tokenExpiryKey),
    ]);
  }

  // Hard logout - clear everything including PIN
  Future<void> hardLogout() async {
    await clearAll();
    await _storage.delete(key: _pinKey);
  }
}
