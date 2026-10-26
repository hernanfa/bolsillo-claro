import 'package:bolsillo_claro/controllers/auth_controller.dart';
import 'package:bolsillo_claro/core/theme/app_theme.dart';
import 'package:bolsillo_claro/views/splash/splash_screen.dart';
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

  testWidgets('SplashScreen renderiza logotipo y título de Bolsillo Claro', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.lightTheme, home: const SplashScreen()),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Bolsillo Claro'), findsOneWidget);
    expect(find.text('Controla tus gastos de forma sencilla'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
