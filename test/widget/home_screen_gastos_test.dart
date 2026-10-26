import 'package:bolsillo_claro/controllers/assistant_controller.dart';
import 'package:bolsillo_claro/controllers/auth_controller.dart';
import 'package:bolsillo_claro/controllers/gastos_controller.dart';
import 'package:bolsillo_claro/core/errors/exceptions.dart';
import 'package:bolsillo_claro/core/theme/app_theme.dart';
import 'package:bolsillo_claro/core/theme/theme_controller.dart';
import 'package:bolsillo_claro/data/models/gasto_model.dart';
import 'package:bolsillo_claro/data/models/resumen_gastos_model.dart';
import 'package:bolsillo_claro/data/models/user_model.dart';
import 'package:bolsillo_claro/views/home/home_screen.dart';
import 'package:bolsillo_claro/views/home/widgets/gasto_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../mocks/mock_assistant_dependencies.dart';
import '../mocks/mock_auth_dependencies.dart';
import '../mocks/mock_gastos_dependencies.dart';

void main() {
  late MockAuthRepository mockAuthRepo;
  late FakeStorageService fakeStorage;
  late MockGastosRepository mockGastosRepo;
  late FakeSettingsStorageService fakeSettings;
  late MockAssistantService mockAssistantService;
  late AuthController authController;
  late GastosController gastosController;
  late ThemeController themeController;
  late AssistantController assistantController;

  setUp(() {
    Get.testMode = true;
    mockAuthRepo = MockAuthRepository();
    fakeStorage = FakeStorageService();
    mockGastosRepo = MockGastosRepository();
    fakeSettings = FakeSettingsStorageService();
    mockAssistantService = MockAssistantService();

    gastosController = GastosController(gastosRepository: mockGastosRepo);
    themeController = ThemeController(settingsService: fakeSettings);
    assistantController = AssistantController(
      assistantService: mockAssistantService,
      gastosRepository: mockGastosRepo,
    );
    authController = AuthController(
      authRepository: mockAuthRepo,
      storageService: fakeStorage,
      gastosRepository: mockGastosRepo,
    );
    authController.currentUser.value = const UserModel(
      id: 1,
      email: 'usuario@prueba.com',
    );

    Get.put<AuthController>(authController);
    Get.put<GastosController>(gastosController);
    Get.put<ThemeController>(themeController);
    Get.put<AssistantController>(assistantController);
  });

  tearDown(() {
    Get.reset();
  });

  Widget createTestWidget() {
    return GetMaterialApp(theme: AppTheme.lightTheme, home: const HomeScreen());
  }

  group('HomeScreen - Estados de la Lista de Gastos', () {
    testWidgets('muestra estado vacío cuando no existen gastos registrados', (
      tester,
    ) async {
      mockGastosRepo.gastosToReturn = [];

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No tienes gastos registrados'), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Registrar Gasto'),
        findsOneWidget,
      );
    });

    testWidgets('muestra estado de error con opción de reintentar', (
      tester,
    ) async {
      mockGastosRepo.errorToThrow = const NetworkException(
        'Fallo al conectar con el servidor',
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Fallo al conectar con el servidor'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Reintentar'), findsOneWidget);
    });

    testWidgets('muestra lista de gastos, resumen y barra de categorías', (
      tester,
    ) async {
      mockGastosRepo.gastosToReturn = [
        const GastoModel(
          id: 1,
          descripcion: 'Café matutino',
          monto: 3.5,
          categoria: 'comida',
        ),
        const GastoModel(
          id: 2,
          descripcion: 'Gasolina',
          monto: 20.0,
          categoria: 'transporte',
        ),
      ];
      mockGastosRepo.totalCountToReturn = 2;
      mockGastosRepo.resumenToReturn = const ResumenGastosModel(
        totalGeneral: 23.5,
        categorias: [
          ResumenCategoriaModel(
            categoria: 'comida',
            total: 3.5,
            cantidad: 1,
            disponible: 496.5,
          ),
        ],
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verificar elementos de gasto
      expect(find.text('Café matutino'), findsOneWidget);
      expect(find.text('\$3.50'), findsOneWidget);
      expect(find.text('Gasolina'), findsOneWidget);
      expect(find.text('\$20.00'), findsOneWidget);

      // Verificar resumen
      expect(find.text('Total Acumulado'), findsOneWidget);
      expect(find.text('\$23.50'), findsOneWidget);

      // Verificar paginación tras desplazar la lista
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Mostrando 2 de 2 gastos'), findsOneWidget);
    });

    testWidgets('muestra aviso de datos en caché cuando isFromCache es true', (
      tester,
    ) async {
      mockGastosRepo.gastosToReturn = [
        const GastoModel(
          id: 1,
          descripcion: 'Gasto offline',
          monto: 15.0,
          categoria: 'otros',
        ),
      ];
      mockGastosRepo.fromCacheToReturn = true;
      mockGastosRepo.lastSyncToReturn = DateTime(2026, 10, 26, 10, 30);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Modo sin conexión • Datos en caché'), findsOneWidget);
      expect(
        find.textContaining('Última sincronización: 26/10/2026 10:30'),
        findsOneWidget,
      );
    });
  });

  group('GastoFormDialog - Validación y Creación', () {
    testWidgets(
      'muestra validaciones requeridas si se intenta enviar formulario vacío',
      (tester) async {
        await tester.pumpWidget(
          GetMaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: GastoFormDialog()),
          ),
        );
        await tester.pumpAndSettle();

        final submitBtn = find.widgetWithText(
          ElevatedButton,
          'Registrar Gasto',
        );
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        expect(find.text('La descripción es obligatoria.'), findsOneWidget);
        expect(find.text('El monto es obligatorio.'), findsOneWidget);
        expect(mockGastosRepo.createGastoCallCount, 0);
      },
    );

    testWidgets(
      'valida que el monto sea un número mayor a cero y con máx 2 decimales',
      (tester) async {
        await tester.pumpWidget(
          GetMaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: GastoFormDialog()),
          ),
        );
        await tester.pumpAndSettle();

        final montoField = find.widgetWithText(TextFormField, '0.00');
        await tester.enterText(montoField, '-5');

        final submitBtn = find.widgetWithText(
          ElevatedButton,
          'Registrar Gasto',
        );
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        expect(find.text('El monto debe ser mayor a cero.'), findsOneWidget);

        // Probar más de 2 decimales
        await tester.enterText(montoField, '10.555');
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        expect(
          find.text('El monto admite como máximo 2 decimales.'),
          findsOneWidget,
        );
      },
    );
  });
}
