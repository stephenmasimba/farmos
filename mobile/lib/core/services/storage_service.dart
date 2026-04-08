import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _accessKey = 'access_token';
const _refreshKey = 'refresh_token';
const _userIdKey = 'user_id';
const _userRoleKey = 'user_role';
const _userEmailKey = 'user_email';
const _userNameKey = 'user_name';

class StorageService {
  const StorageService(this._secure);

  final FlutterSecureStorage _secure;

  Future<void> saveTokens({
    required String accessToken,
    required String? refreshToken,
  }) async {
    await _secure.write(key: _accessKey, value: accessToken);
    if (refreshToken != null) {
      await _secure.write(key: _refreshKey, value: refreshToken);
    }
  }

  Future<void> saveUserInfo({
    required int id,
    required String email,
    required String role,
    String? name,
  }) async {
    await _secure.write(key: _userIdKey, value: id.toString());
    await _secure.write(key: _userEmailKey, value: email);
    await _secure.write(key: _userRoleKey, value: role);
    if (name != null) await _secure.write(key: _userNameKey, value: name);
  }

  Future<String?> getAccessToken() => _secure.read(key: _accessKey);
  Future<String?> getRefreshToken() => _secure.read(key: _refreshKey);
  Future<String?> getUserRole() => _secure.read(key: _userRoleKey);
  Future<String?> getUserEmail() => _secure.read(key: _userEmailKey);
  Future<String?> getUserName() => _secure.read(key: _userNameKey);
  Future<int?> getUserId() async {
    final s = await _secure.read(key: _userIdKey);
    return s == null ? null : int.tryParse(s);
  }

  Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearSession() async {
    await _secure.deleteAll();
  }
}
