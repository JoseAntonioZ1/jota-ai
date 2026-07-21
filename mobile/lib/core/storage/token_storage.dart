import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda el token de dispositivo (docs/06_SYSTEM_ARCHITECTURE.md seccion 4.6).
/// El token se emite una sola vez en POST /devices y se persiste solo aqui.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'device_token';

  final FlutterSecureStorage _storage;

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<void> clear() => _storage.delete(key: _tokenKey);
}
