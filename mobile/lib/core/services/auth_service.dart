import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/user.dart';
import 'storage_service.dart';

class AuthService {
  const AuthService({
    required ApiClient apiClient,
    required StorageService storage,
  })  : _api = apiClient,
        _storage = storage;

  final ApiClient _api;
  final StorageService _storage;

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.post(ApiEndpoints.login, data: {
      'email': email.trim(),
      'password': password,
    });
    await _persistSession(data);
    try {
      return await getMe();
    } catch (_) {
      return User.fromJson((data['user'] as Map<String, dynamic>?) ?? const {});
    }
  }

  Future<User> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    final data = await _api.post(ApiEndpoints.register, data: {
      'email': email.trim(),
      'password': password,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
    });
    await _persistSession(data);
    try {
      return await getMe();
    } catch (_) {
      return User.fromJson((data['user'] as Map<String, dynamic>?) ?? const {});
    }
  }

  Future<User> getMe() async {
    final data = await _api.get(ApiEndpoints.me);
    final userJson = data['user'] as Map<String, dynamic>? ?? data;
    return User.fromJson(userJson);
  }

  Future<void> logout() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken != null) {
      try {
        await _api.post(ApiEndpoints.logout, data: {'refresh_token': refreshToken});
      } catch (_) {
        // Ignore API errors on logout — clear locally regardless
      }
    }
    await _storage.clearSession();
  }

  Future<void> _persistSession(Map<String, dynamic> data) async {
    final accessToken = data['access_token'] as String?;
    final refreshToken = data['refresh_token'] as String?;
    if (accessToken == null) {
      throw const ApiException(message: 'No access token in response');
    }

    final userJson = data['user'] as Map<String, dynamic>? ?? {};
    final userId = (userJson['id'] as int?) ?? 0;
    final userEmail = userJson['email'] as String? ?? '';
    final userRole = userJson['role'] as String? ?? 'user';
    final userName = userJson['name'] as String?;

    await _storage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await _storage.saveUserInfo(
      id: userId,
      email: userEmail,
      role: userRole,
      name: userName,
    );
  }
}
