/// Build-time configuration via --dart-define.
abstract final class EnvConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );

  /// When true (default), driver endpoints are served by [MockApiInterceptor].
  static const bool useMockDriverApi = bool.fromEnvironment(
    'USE_MOCK_DRIVER_API',
    defaultValue: true,
  );

  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: true,
  );

  static const String nominatimBaseUrl = String.fromEnvironment(
    'NOMINATIM_BASE_URL',
    defaultValue: 'https://nominatim.openstreetmap.org',
  );
}
