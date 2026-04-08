import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api_endpoints.dart';

const _accessKey = 'access_token';
const _refreshKey = 'refresh_token';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required FlutterSecureStorage storage, required Dio dio})
      : _storage = storage,
        _dio = dio;

  final FlutterSecureStorage _storage;
  final Dio _dio;
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for public endpoints
    final publicPaths = {
      ApiEndpoints.login,
      ApiEndpoints.register,
      ApiEndpoints.refreshToken,
      ApiEndpoints.health,
    };
    if (!publicPaths.contains(options.path)) {
      final token = await _storage.read(key: _accessKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await _storage.read(key: _refreshKey);
        if (refreshToken == null) {
          await _clearTokens();
          handler.next(err);
          return;
        }

        final response = await _dio.post(
          ApiEndpoints.refreshToken,
          data: {'refresh_token': refreshToken},
          options: Options(headers: {'Authorization': null}),
        );

        final newAccess = response.data['access_token'] as String?;
        final newRefresh = response.data['refresh_token'] as String?;

        if (newAccess == null) {
          await _clearTokens();
          handler.next(err);
          return;
        }

        await _storage.write(key: _accessKey, value: newAccess);
        if (newRefresh != null) {
          await _storage.write(key: _refreshKey, value: newRefresh);
        }

        // Retry original request with new token
        final retryOptions = Options(
          method: err.requestOptions.method,
          headers: {
            ...err.requestOptions.headers,
            'Authorization': 'Bearer $newAccess',
          },
        );
        final retryResponse = await _dio.request(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: retryOptions,
        );
        handler.resolve(retryResponse);
      } catch (_) {
        await _clearTokens();
        handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
