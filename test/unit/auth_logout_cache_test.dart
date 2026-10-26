import 'package:bolsillo_claro/controllers/auth_controller.dart';
import 'package:bolsillo_claro/controllers/gastos_controller.dart';
import 'package:bolsillo_claro/data/models/gasto_model.dart';
import 'package:bolsillo_claro/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import '../mocks/mock_auth_dependencies.dart';
import '../mocks/mock_gastos_dependencies.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepo;
  late FakeStorageService fakeStorage;
  late MockGastosRepository mockGastosRepo;
  late GastosController gastosController;
  late AuthController authController;

  setUp(() {
    Get.testMode = true;
    mockAuthRepo = MockAuthRepository();
    fakeStorage = FakeStorageService();
    mockGastosRepo = MockGastosRepository();

    gastosController = GastosController(gastosRepository: mockGastosRepo);
    Get.put<GastosController>(gastosController);

    authController = AuthController(
      authRepository: mockAuthRepo,
      storageService: fakeStorage,
      gastosRepository: mockGastosRepo,
    );
    Get.put<AuthController>(authController);
  });

  tearDown(() {
    Get.reset();
  });

  test('logout borra la caja de caché del usuario y limpia el estado de gastos', () async {
    // Configurar usuario activo y datos en controller
    authController.currentUser.value = const UserModel(id: 42, email: 'user42@test.com');
    await fakeStorage.saveToken('token42');
    gastosController.gastos.add(
      const GastoModel(id: 1, descripcion: 'Gasto prueba', monto: 10.0, categoria: 'comida'),
    );
    gastosController.totalCount.value = 1;

    // Ejecutar cierre de sesión
    await authController.logout();

    // 1. Verificamos que se llamó al repositorio para limpiar la caja del usuario 42
    expect(mockGastosRepo.clearCacheCallCount, 1);
    expect(mockGastosRepo.lastClearedUserId, 42);

    // 2. Verificamos que el estado reactivo del controlador se limpió
    expect(gastosController.gastos, isEmpty);
    expect(gastosController.totalCount.value, 0);

    // 3. Verificamos que los tokens y usuario fueron removidos
    expect(authController.currentUser.value, isNull);
    expect(await fakeStorage.getToken(), isNull);
  });
}
