import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_config.dart';

/// Cliente HTTP unico del backend. Agrega el header Authorization con el
/// token de dispositivo en cada request salvo el registro inicial.
class ApiClient {
  ApiClient({TokenStorage? tokenStorage, Dio? dio})
    : _tokenStorage = tokenStorage ?? TokenStorage(),
      _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConfig.baseUrl)) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;

  Dio get dio => _dio;
}

/// Error de dominio mapeado desde el envelope estandar de la API
/// (docs/09_API_DESIGN.md seccion 2): {"error": {"code", "message"}}.
class ApiException implements Exception {
  ApiException({required this.code, required this.message, this.statusCode});

  factory ApiException.fromDioException(DioException exception) {
    final data = exception.response?.data;
    if (data is Map && data['error'] is Map) {
      final error = data['error'] as Map;
      return ApiException(
        code: error['code']?.toString() ?? 'unknown_error',
        message: error['message']?.toString() ?? 'Ocurrio un error inesperado.',
        statusCode: exception.response?.statusCode,
      );
    }
    return ApiException(
      code: 'network_error',
      message: 'No se pudo conectar con el servidor.',
      statusCode: exception.response?.statusCode,
    );
  }

  final String code;
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($code: $message)';
}
