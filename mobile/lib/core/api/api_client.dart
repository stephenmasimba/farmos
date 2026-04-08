import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';
import 'api_endpoints.dart';
import 'interceptors/auth_interceptor.dart';

class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => (statusCode ?? 0) >= 500;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient({required FlutterSecureStorage storage}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.base,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Auth interceptor for JWT + refresh
    _dio.interceptors.add(AuthInterceptor(storage: storage, dio: _dio));

    // Logging (debug only)
    assert(() {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => _log.d(obj.toString()),
      ));
      return true;
    }());
  }

  late final Dio _dio;
  final _log = Logger();

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    return _wrap(() => _dio.get(path, queryParameters: params));
  }

  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
  }) async {
    return _wrap(() => _dio.post(path, data: data));
  }

  Future<Map<String, dynamic>> put(
    String path, {
    dynamic data,
  }) async {
    return _wrap(() => _dio.put(path, data: data));
  }

  Future<Map<String, dynamic>> delete(String path) async {
    return _wrap(() => _dio.delete(path));
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    final response = await _wrapRaw(() => _dio.get(path, queryParameters: params));
    final data = response.data;
    if (data is List) return data;
    if (data is Map) {
      // Unwrap common pagination envelopes: { data: [...] }
      if (data['data'] is List) return data['data'] as List;
      if (data['items'] is List) return data['items'] as List;
    }
    return [];
  }

  Future<Map<String, dynamic>> _wrap(Future<Response> Function() call) async {
    final response = await _wrapRaw(call);
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    return {'result': data};
  }

  Future<Response> _wrapRaw(Future<Response> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      String message;
      if (e.response?.data is Map) {
        message = (e.response?.data as Map)['message'] as String? ??
            (e.response?.data as Map)['error'] as String? ??
            e.message ??
            'Request failed';
      } else {
        message = e.message ?? 'Network error';
      }
      throw ApiException(message: message, statusCode: code);
    }
  }
}
