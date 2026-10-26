import '../models/auth_token_model.dart';
import '../models/user_model.dart';

/// Contrato para el repositorio de autenticación y gestión de usuario.
abstract class AuthRepository {
  /// Registra un nuevo usuario en el backend.
  Future<UserModel> register({required String email, required String password});

  /// Inicia sesión enviando credenciales como formulario x-www-form-urlencoded.
  Future<AuthTokenModel> login({
    required String email,
    required String password,
  });

  /// Obtiene el perfil del usuario autenticado actual.
  Future<UserModel> getCurrentUser(String token);
}
