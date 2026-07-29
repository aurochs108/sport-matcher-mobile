final class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'AUTH_API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
  static const String profilesBaseUrl = String.fromEnvironment(
    'PROFILES_API_BASE_URL',
    defaultValue: 'http://localhost:8081',
  );
}
