import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';
  static const _roleKey = 'role';
  static const _userIdKey = 'userId';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String role,
    required String userId,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _roleKey, value: role);
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getAccessToken() async => await _storage.read(key: _accessTokenKey);
  Future<String?> getRefreshToken() async => await _storage.read(key: _refreshTokenKey);
  Future<String?> getRole() async => await _storage.read(key: _roleKey);
  Future<String?> getUserId() async => await _storage.read(key: _userIdKey);

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
