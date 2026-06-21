import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();

  factory SecureStorageService() => _instance;

  SecureStorageService._internal();

  // Storage
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> write({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      log('Write error: $e');
    }
  }

  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      log('Read error: $e');
      return null;
    }
  }

  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      log('Delete error: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      log('Clear error: $e');
    }
  }

  static const String _accessKey = 'accessToken';
  static const String _refreshKey = 'refreshToken';
  static const String _roleKey = 'userRole';
  static const String _localeKey = 'localeCode';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? role,
  }) async {
    await write(key: _accessKey, value: accessToken);
    await write(key: _refreshKey, value: refreshToken);
    if (role != null && role.isNotEmpty) {
      await write(key: _roleKey, value: role);
    }
    log('Tokens saved');
  }

  Future<String?> getAccessToken() async {
    return await read(_accessKey);
  }

  Future<String?> getRefreshToken() async {
    return await read(_refreshKey);
  }

  Future<String?> getUserRole() async {
    return await read(_roleKey);
  }

  Future<void> saveUserRole(String role) async {
    await write(key: _roleKey, value: role);
  }

  Future<String?> getLocaleCode() async {
    return await read(_localeKey);
  }

  Future<void> saveLocaleCode(String code) async {
    await write(key: _localeKey, value: code);
  }

  Future<void> clearTokens() async {
    await delete(_accessKey);
    await delete(_refreshKey);
    await delete(_roleKey);
    log('Tokens cleared');
  }
}
