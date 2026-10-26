import 'package:bolsillo_claro/controllers/auth_controller.dart';
import 'package:bolsillo_claro/core/errors/exceptions.dart';
import 'package:bolsillo_claro/data/models/auth_token_model.dart';
import 'package:bolsillo_claro/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import '../mocks/mock_auth_dependencies.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepository;
  late FakeStorageService fakeStorageService;
  late AuthController controller;

  setUp(() {
    Get.testMode = true;
    mockAuthRepository = MockAuthRepository();
    fakeStorageService = FakeStorageService();
    controller = AuthController(
      authRepository: mockAuthRepository,
      storageService: fakeStorageService,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('AuthController - Login', () {
    test('login exitoso guarda token y actualiza el usuario actual', () async {
      mockAuthRepository.tokenToReturn = const AuthTokenModel(
        accessToken: 'valid_token_xyz',
        tokenType: 'bearer',
      );
      mockAuthRepository.userToReturn = const UserModel(
        id: 42,
        email: 'usuario@prueba.com',
      );

      final success = await controller.login(
        email: 'usuario@prueba.com',
        password: 'password123',
      );

      expect(success, isTrue);
      expect(controller.isLoading.value, isFalse);
      expect(controller.errorMessage.value, isEmpty);
      expect(controller.currentUser.value?.id, 42);
      expect(controller.currentUser.value?.email, 'usuario@prueba.com');
      expect(controller.isAuthenticated, isTrue);
      expect(await fakeStorageService.getToken(), 'valid_token_xyz');
      expect(await fakeStorageService.getUserEmail(), 'usuario@prueba.com');
    });

    test('login con credenciales incorrectas registra mensaje legible', () async {
      mockAuthRepository.errorToThrow = const AuthException(
        'Email o contraseña incorrectos',
        statusCode: 401,
      );

      final success = await controller.login(
        email: 'usuario@prueba.com',
        password: 'wrongpassword',
      );

      expect(success, isFalse);
      expect(controller.isLoading.value, isFalse);
      expect(controller.errorMessage.value, 'Email o contraseña incorrectos');
      expect(controller.currentUser.value, isNull);
      expect(controller.isAuthenticated, isFalse);
      expect(await fakeStorageService.getToken(), isNull);
    });
  });

  group('AuthController - Registro', () {
    test('registro exitoso da de alta e inicia sesión automáticamente', () async {
      mockAuthRepository.userToReturn = const UserModel(
        id: 10,
        email: 'nuevo@prueba.com',
      );
      mockAuthRepository.tokenToReturn = const AuthTokenModel(
        accessToken: 'token_nuevo_usuario',
        tokenType: 'bearer',
      );

      final success = await controller.register(
        email: 'nuevo@prueba.com',
        password: 'passwordSegura8',
      );

      expect(success, isTrue);
      expect(controller.isLoading.value, isFalse);
      expect(controller.errorMessage.value, isEmpty);
      expect(controller.currentUser.value?.email, 'nuevo@prueba.com');
      expect(controller.isAuthenticated, isTrue);
      expect(await fakeStorageService.getToken(), 'token_nuevo_usuario');
    });

    test('registro con email duplicado refleja mensaje de error', () async {
      mockAuthRepository.errorToThrow = const AppException(
        'El email ya está registrado',
        statusCode: 400,
      );

      final success = await controller.register(
        email: 'duplicado@prueba.com',
        password: 'passwordSegura8',
      );

      expect(success, isFalse);
      expect(controller.isLoading.value, isFalse);
      expect(controller.errorMessage.value, 'El email ya está registrado');
      expect(controller.currentUser.value, isNull);
      expect(controller.isAuthenticated, isFalse);
    });
  });

  group('AuthController - Restauración y Cierre de Sesión', () {
    test('restoreSession restaura el usuario si existe token previo válido', () async {
      await fakeStorageService.saveToken('token_persistido');
      mockAuthRepository.userToReturn = const UserModel(
        id: 7,
        email: 'sesion@activa.com',
      );

      final success = await controller.restoreSession();

      expect(success, isTrue);
      expect(controller.currentUser.value?.email, 'sesion@activa.com');
      expect(controller.isAuthenticated, isTrue);
      expect(mockAuthRepository.lastTokenPassed, 'token_persistido');
    });

    test('restoreSession falla limpiamente si no hay token guardado', () async {
      final success = await controller.restoreSession();

      expect(success, isFalse);
      expect(controller.currentUser.value, isNull);
      expect(controller.isAuthenticated, isFalse);
      expect(mockAuthRepository.getCurrentUserCallCount, 0);
    });

    test('restoreSession limpia almacenamiento si el token fue revocado o expiró', () async {
      await fakeStorageService.saveToken('token_invalido');
      mockAuthRepository.errorToThrow = const AuthException('Token expirado', statusCode: 401);

      final success = await controller.restoreSession();

      expect(success, isFalse);
      expect(controller.currentUser.value, isNull);
      expect(await fakeStorageService.getToken(), isNull);
    });

    test('logout elimina credenciales y limpia el estado de sesión', () async {
      await fakeStorageService.saveToken('token_a_borrar');
      await fakeStorageService.saveUserEmail('usuario@borrar.com');
      controller.currentUser.value = const UserModel(id: 1, email: 'usuario@borrar.com');

      await controller.logout();

      expect(controller.currentUser.value, isNull);
      expect(controller.isAuthenticated, isFalse);
      expect(await fakeStorageService.getToken(), isNull);
      expect(await fakeStorageService.getUserEmail(), isNull);
    });
  });

  group('AuthController - Utilidades UI', () {
    test('alterna la visibilidad de contraseña', () {
      expect(controller.obscurePassword.value, isTrue);
      controller.togglePasswordVisibility();
      expect(controller.obscurePassword.value, isFalse);
      controller.togglePasswordVisibility();
      expect(controller.obscurePassword.value, isTrue);
    });

    test('alterna la visibilidad de confirmación de contraseña', () {
      expect(controller.obscureConfirmPassword.value, isTrue);
      controller.toggleConfirmPasswordVisibility();
      expect(controller.obscureConfirmPassword.value, isFalse);
      controller.toggleConfirmPasswordVisibility();
      expect(controller.obscureConfirmPassword.value, isTrue);
    });

    test('limpia mensajes de error', () {
      controller.errorMessage.value = 'Un error previo';
      controller.clearError();
      expect(controller.errorMessage.value, isEmpty);
    });
  });
}
