import 'package:bolsillo_claro/core/storage/storage_service.dart';
import 'package:bolsillo_claro/data/models/auth_token_model.dart';
import 'package:bolsillo_claro/data/models/user_model.dart';
import 'package:bolsillo_claro/data/repositories/auth_repository.dart';

/// Implementación en memoria de StorageService para pruebas sin plataforma nativa.
class FakeStorageService implements StorageService {
  final Map<String, String> _store = {};

  @override
  Future<void> saveToken(String token) async {
    _store['auth_token'] = token;
  }

  @override
  Future<String?> getToken() async {
    return _store['auth_token'];
  }

  @override
  Future<void> deleteToken() async {
    _store.remove('auth_token');
  }

  @override
  Future<void> saveUserEmail(String email) async {
    _store['user_email'] = email;
  }

  @override
  Future<String?> getUserEmail() async {
    return _store['user_email'];
  }

  @override
  Future<void> deleteUserEmail() async {
    _store.remove('user_email');
  }

  @override
  Future<void> clearAll() async {
    _store.clear();
  }
}

/// Mock configurable de AuthRepository para aislar las pruebas del backend real.
class MockAuthRepository implements AuthRepository {
  UserModel? userToReturn;
  AuthTokenModel? tokenToReturn;
  Exception? errorToThrow;

  int loginCallCount = 0;
  int registerCallCount = 0;
  int getCurrentUserCallCount = 0;

  String? lastLoginEmail;
  String? lastLoginPassword;
  String? lastRegisterEmail;
  String? lastRegisterPassword;
  String? lastTokenPassed;

  @override
  Future<UserModel> register({
    required String email,
    required String password,
  }) async {
    registerCallCount++;
    lastRegisterEmail = email;
    lastRegisterPassword = password;

    if (errorToThrow != null) {
      throw errorToThrow!;
    }

    return userToReturn ?? UserModel(id: 1, email: email);
  }

  @override
  Future<AuthTokenModel> login({
    required String email,
    required String password,
  }) async {
    loginCallCount++;
    lastLoginEmail = email;
    lastLoginPassword = password;

    if (errorToThrow != null) {
      throw errorToThrow!;
    }

    return tokenToReturn ??
        const AuthTokenModel(
          accessToken: 'fake_jwt_token_123',
          tokenType: 'bearer',
        );
  }

  @override
  Future<UserModel> getCurrentUser(String token) async {
    getCurrentUserCallCount++;
    lastTokenPassed = token;

    if (errorToThrow != null) {
      throw errorToThrow!;
    }

    return userToReturn ??
        const UserModel(id: 1, email: 'usuario@bolsilloclaro.com');
  }
}
