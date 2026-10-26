import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Contrato para el almacenamiento seguro de credenciales y sesión.
abstract class StorageService {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();

  Future<void> saveUserEmail(String email);
  Future<String?> getUserEmail();
  Future<void> deleteUserEmail();

  Future<void> clearAll();
}

/// Implementación basada en flutter_secure_storage.
class SecureStorageServiceImpl implements StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUserEmail = 'user_email';

  final FlutterSecureStorage _storage;

  SecureStorageServiceImpl({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
            );

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  @override
  Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }

  @override
  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _keyUserEmail, value: email);
  }

  @override
  Future<String?> getUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }

  @override
  Future<void> deleteUserEmail() async {
    await _storage.delete(key: _keyUserEmail);
  }

  @override
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
