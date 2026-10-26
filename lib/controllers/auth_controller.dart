import 'package:get/get.dart';
import '../core/errors/exceptions.dart';
import '../core/storage/storage_service.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/gastos_repository.dart';
import '../routes/app_routes.dart';
import 'gastos_controller.dart';

/// Controlador GetX responsable de la sesión y autenticación del usuario.
class AuthController extends GetxController {
  final AuthRepository authRepository;
  final StorageService storageService;
  final GastosRepository? gastosRepository;

  AuthController({
    required this.authRepository,
    required this.storageService,
    this.gastosRepository,
  });

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  bool get isAuthenticated => currentUser.value != null;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void clearError() {
    errorMessage.value = '';
  }

  void _navigate(String route) {
    try {
      Get.offAllNamed(route);
    } catch (_) {
      // Ignorar excepciones de navegación en contextos de pruebas unitarias sin navegador
    }
  }

  /// Restaura la sesión existente a partir del token persistido de forma segura.
  Future<bool> restoreSession() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = await storageService.getToken();
      if (token == null || token.isEmpty) {
        isLoading.value = false;
        _navigate(AppRoutes.login);
        return false;
      }

      final user = await authRepository.getCurrentUser(token);
      currentUser.value = user;
      await storageService.saveUserEmail(user.email);
      isLoading.value = false;
      _navigate(AppRoutes.home);
      return true;
    } on AppException catch (e) {
      // Si el token expiró o falló la verificación, limpiar y enviar a login
      await storageService.clearAll();
      currentUser.value = null;
      errorMessage.value = e.message;
      isLoading.value = false;
      _navigate(AppRoutes.login);
      return false;
    } catch (_) {
      await storageService.clearAll();
      currentUser.value = null;
      isLoading.value = false;
      _navigate(AppRoutes.login);
      return false;
    }
  }

  /// Inicia sesión con el correo y contraseña provistos.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = await authRepository.login(
        email: email,
        password: password,
      );

      await storageService.saveToken(token.accessToken);

      final user = await authRepository.getCurrentUser(token.accessToken);
      currentUser.value = user;
      await storageService.saveUserEmail(user.email);

      isLoading.value = false;
      _navigate(AppRoutes.home);
      return true;
    } on AppException catch (e) {
      errorMessage.value = e.message;
      isLoading.value = false;
      return false;
    } catch (e) {
      errorMessage.value = 'Ocurrió un error inesperado al iniciar sesión.';
      isLoading.value = false;
      return false;
    }
  }

  /// Registra una nueva cuenta y autentica de inmediato al usuario.
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // 1. Registrar usuario
      await authRepository.register(
        email: email,
        password: password,
      );

      // 2. Iniciar sesión automáticamente
      final token = await authRepository.login(
        email: email,
        password: password,
      );

      await storageService.saveToken(token.accessToken);

      final user = await authRepository.getCurrentUser(token.accessToken);
      currentUser.value = user;
      await storageService.saveUserEmail(user.email);

      isLoading.value = false;
      _navigate(AppRoutes.home);
      return true;
    } on AppException catch (e) {
      errorMessage.value = e.message;
      isLoading.value = false;
      return false;
    } catch (e) {
      errorMessage.value = 'Ocurrió un error inesperado al crear la cuenta.';
      isLoading.value = false;
      return false;
    }
  }

  /// Cierra la sesión activa, borra la caja de caché del usuario y elimina las credenciales locales.
  Future<void> logout() async {
    try {
      final userId = currentUser.value?.id;
      if (userId != null) {
        if (gastosRepository != null) {
          await gastosRepository!.clearUserCache(userId);
        } else if (Get.isRegistered<GastosRepository>()) {
          await Get.find<GastosRepository>().clearUserCache(userId);
        }
      }
      if (Get.isRegistered<GastosController>()) {
        Get.find<GastosController>().clearLocalState();
      }
      await storageService.clearAll();
    } catch (_) {
      // Ignorar fallas de borrado local al salir
    } finally {
      currentUser.value = null;
      errorMessage.value = '';
      _navigate(AppRoutes.login);
    }
  }
}
