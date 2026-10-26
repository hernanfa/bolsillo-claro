import 'package:bolsillo_claro/controllers/auth_controller.dart';
import 'package:bolsillo_claro/core/theme/app_theme.dart';
import 'package:bolsillo_claro/views/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import '../mocks/mock_auth_dependencies.dart';

void main() {
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
    Get.put<AuthController>(controller);
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

  group('Widget Tests - RegisterScreen', () {
    testWidgets('renderiza formulario de registro con campos y botón', (tester) async {
      await tester.pumpWidget(createTestWidget(const RegisterScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Crear Cuenta'), findsOneWidget);
      expect(find.text('Únete a Bolsillo Claro'), findsOneWidget);
      expect(find.text('Correo electrónico'), findsOneWidget);
      expect(find.text('Contraseña (mínimo 8 caracteres)'), findsOneWidget);
      expect(find.text('Confirmar contraseña'), findsOneWidget);
      expect(find.text('Registrarme'), findsOneWidget);
      expect(find.text('Inicia sesión'), findsOneWidget);
    });

    testWidgets('valida campos obligatorios y contraseñas no coincidentes', (tester) async {
      await tester.pumpWidget(createTestWidget(const RegisterScreen()));
      await tester.pumpAndSettle();

      final registerButton = find.widgetWithText(ElevatedButton, 'Registrarme');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text('El correo electrónico es requerido.'), findsOneWidget);
      expect(find.text('La contraseña es requerida.'), findsOneWidget);
      expect(find.text('Por favor confirma tu contraseña.'), findsOneWidget);
      expect(mockAuthRepository.registerCallCount, 0);
    });

    testWidgets('muestra mensaje de error cuando controller tiene errorMessage', (tester) async {
      controller.errorMessage.value = 'El email ya está registrado';

      await tester.pumpWidget(createTestWidget(const RegisterScreen()));
      await tester.pumpAndSettle();

      expect(find.text('El email ya está registrado'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });
  });
}
