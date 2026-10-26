import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

/// Implementación del repositorio de autenticación usando Dio y ApiClient.
class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;

  AuthRepositoryImpl({required this.apiClient});

  @override
  Future<UserModel> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.registerEndpoint,
        data: {'email': email.trim(), 'password': password},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return UserModel.fromJson(data);
      }
      throw const AppException('Respuesta inesperada al registrar usuario.');
    } on DioException catch (e) {
      throw parseDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error al registrar usuario: $e');
    }
  }

  @override
  Future<AuthTokenModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.loginEndpoint,
        data: {'username': email.trim(), 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return AuthTokenModel.fromJson(data);
      }
      throw const AppException('Respuesta inesperada al iniciar sesión.');
    } on DioException catch (e) {
      throw parseDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error al iniciar sesión: $e');
    }
  }

  @override
  Future<UserModel> getCurrentUser(String token) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.meEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return UserModel.fromJson(data);
      }
      throw const AppException('Respuesta inesperada al consultar usuario.');
    } on DioException catch (e) {
      throw parseDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error al consultar perfil: $e');
    }
  }
}
