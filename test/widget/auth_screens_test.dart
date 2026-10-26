import 'package:bolsillo_claro/controllers/assistant_controller.dart';
import 'package:bolsillo_claro/controllers/auth_controller.dart';
import 'package:bolsillo_claro/controllers/gastos_controller.dart';
import 'package:bolsillo_claro/core/theme/app_theme.dart';
import 'package:bolsillo_claro/core/theme/theme_controller.dart';
import 'package:bolsillo_claro/data/models/user_model.dart';
import 'package:bolsillo_claro/views/auth/login_screen.dart';
import 'package:bolsillo_claro/views/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import '../mocks/mock_assistant_dependencies.dart';
import '../mocks/mock_auth_dependencies.dart';
import '../mocks/mock_gastos_dependencies.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late FakeStorageService fakeStorageService;
  late MockGastosRepository mockGastosRepository;
  late FakeSettingsStorageService fakeSettingsStorageService;
  late MockAssistantService mockAssistantService;
  late AuthController controller;
  late GastosController gastosController;
  late ThemeController themeController;
  late AssistantController assistantController;

  setUp(() {
    Get.testMode = true;
    mockAuthRepository = MockAuthRepository();
    fakeStorageService = FakeStorageService();
    mockGastosRepository = MockGastosRepository();
    fakeSettingsStorageService = FakeSettingsStorageService();
    mockAssistantService = MockAssistantService();

    gastosController = GastosController(gastosRepository: mockGastosRepository);
    themeController = ThemeController(settingsService: fakeSettingsStorageService);
    assistantController = AssistantController(
      assistantService: mockAssistantService,
      gastosRepository: mockGastosRepository,
    );
    controller = AuthController(
      authRepository: mockAuthRepository,
      storageService: fakeStorageService,
      gastosRepository: mockGastosRepository,
    );

    Get.put<AuthController>(controller);
    Get.put<GastosController>(gastosController);
    Get.put<ThemeController>(themeController);
    Get.put<AssistantController>(assistantController);
  });

  tearDown(() {
    Get.reset();
  });

  Widget createTestWidget(Widget child) {
    return GetMaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
    );
  }

  group('Widget Tests - LoginScreen', () {
    testWidgets('renderiza campos de texto, botón y marca', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Bolsillo Claro'), findsOneWidget);
      expect(find.text('Correo electrónico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Iniciar Sesión'), findsOneWidget);
      expect(find.text('Regístrate aquí'), findsOneWidget);
    });

    testWidgets('muestra errores de validación si se envía formulario vacío', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      final loginButton = find.widgetWithText(ElevatedButton, 'Iniciar Sesión');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('El correo electrónico es requerido.'), findsOneWidget);
      expect(find.text('La contraseña es requerida.'), findsOneWidget);
      expect(mockAuthRepository.loginCallCount, 0);
    });

    testWidgets('muestra banner con mensaje legible si el controlador reporta error', (tester) async {
      controller.errorMessage.value = 'Email o contraseña incorrectos';

      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Email o contraseña incorrectos'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('alterna visibilidad de contraseña al pulsar ícono de ojo', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(controller.obscurePassword.value, isTrue);

      final eyeButton = find.byIcon(Icons.visibility_outlined);
      await tester.tap(eyeButton);
      await tester.pumpAndSettle();

      expect(controller.obscurePassword.value, isFalse);
    });
  });

  group('Widget Tests - HomeScreen', () {
    testWidgets('muestra correo del usuario y opción de cerrar sesión', (tester) async {
      controller.currentUser.value = const UserModel(
        id: 99,
        email: 'usuario.demo@bolsilloclaro.com',
      );

      await tester.pumpWidget(createTestWidget(const HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Bolsillo Claro'), findsOneWidget);
      expect(find.text('Control de Gastos'), findsOneWidget);
      expect(find.text('usuario.demo@bolsilloclaro.com'), findsOneWidget);
      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
      expect(find.text('Nuevo Gasto'), findsOneWidget);
    });
  });
}
