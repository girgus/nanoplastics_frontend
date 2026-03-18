/// Backend configuration for API endpoints
/// Build configuration:
/// - Production: https://api.nanosolve.org (default)
/// - Emulator: flutter run --dart-define=BACKEND_URL=http://10.0.2.2:3000
/// - Local: flutter run --dart-define=BACKEND_URL=http://localhost:3000
class BackendConfig {
  /// Backend URL - can be overridden via environment variable at build time
  ///
  /// Production default: https://api.nanosolve.org
  /// Local development can override with:
  ///   flutter run --dart-define=BACKEND_URL=http://10.0.2.2:3000 (emulator)
  ///   flutter run --dart-define=BACKEND_URL=http://localhost:3000 (local machine)
  static const String defaultBackendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://api.nanosolve.org',
  );

  /// Get the current backend base URL
  /// This can be customized at build time using:
  static String getBaseUrl() {
    return defaultBackendUrl;
  }

  /// Health check endpoint
  static String getHealthUrl() => '${getBaseUrl()}/health';

  /// Ideas API endpoint
  static String getIdeasUrl() => '${getBaseUrl()}/api/ideas';

  /// Solvers leaderboard endpoint
  static String getSolversUrl() => '${getBaseUrl()}/api/solvers';

  /// PDF metadata and download endpoint
  static String getPdfMetadataUrl(String language) =>
      '${getBaseUrl()}/api/pdfs/$language';

  /// Get human-readable environment name for logging
  static String getEnvironment() {
    final url = getBaseUrl();
    if (url.contains('10.0.2.2')) {
      return 'emulator';
    } else if (url.contains('localhost') || url.contains('127.0.0.1')) {
      return 'local';
    } else if (url.contains('37.27.247.129')) {
      return 'production-ip'; // legacy — prefer HTTPS domain
    }
    return 'production';
  }
}
