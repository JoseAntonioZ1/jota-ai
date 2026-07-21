/// docs/06_SYSTEM_ARCHITECTURE.md seccion 3: la app habla con el backend
/// via HTTPS REST /api/v1. En desarrollo local se usa HTTP sin TLS.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'JOTA_API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );
}
