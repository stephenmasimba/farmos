/// Central configuration for FarmOS Mobile.
/// Change [baseUrl] to match your server's IP when running on a real device.
class AppConfig {
  AppConfig._();

  /// Android emulator → 10.0.2.2 maps to host machine's localhost.
  /// Real device on the same Wi-Fi → use your machine's LAN IP, e.g. 192.168.1.x
  static const String baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8081');

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// JWT access token lifetime in seconds (mirrors backend: 3600 s)
  static const int accessTokenTtlSeconds = 3600;

  /// Pagination default
  static const int defaultPageSize = 20;
}
