/// Configuración central de endpoints y constantes de red.
class ApiConfig {
  ApiConfig._();

  /// URL base configurada por --dart-define o por defecto para el emulador Android.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // Endpoints del backend segun contrato OpenAPI
  static const String registerEndpoint = '/usuarios/';
  static const String loginEndpoint = '/usuarios/token';
  static const String meEndpoint = '/usuarios/me';
}
