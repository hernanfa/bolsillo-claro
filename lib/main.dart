import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'controllers/auth_controller.dart';
import 'controllers/gastos_controller.dart';
import 'core/network/api_client.dart';
import 'core/storage/cache_service.dart';
import 'core/storage/settings_service.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/gastos_repository.dart';
import 'data/repositories/gastos_repository_impl.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de persistencia Hive
  await Hive.initFlutter();

  // Servicios de almacenamiento
  final settingsService = HiveSettingsStorageService();
  final cacheService = HiveGastosCacheService();
  final storageService = SecureStorageServiceImpl();

  // Cliente HTTP y repositorios
  final apiClient = ApiClient(storageService: storageService);
  final authRepository = AuthRepositoryImpl(apiClient: apiClient);
  final gastosRepository = GastosRepositoryImpl(
    apiClient: apiClient,
    cacheService: cacheService,
  );

  // Registro de dependencias en GetX
  Get.put<SettingsStorageService>(settingsService);
  Get.put<GastosCacheService>(cacheService);
  Get.put<StorageService>(storageService);
  Get.put<ApiClient>(apiClient);
  Get.put<AuthRepository>(authRepository);
  Get.put<GastosRepository>(gastosRepository);

  final themeController = ThemeController(settingsService: settingsService);
  Get.put<ThemeController>(themeController);
  await themeController.loadThemeMode();

  Get.put<GastosController>(
    GastosController(gastosRepository: gastosRepository),
  );

  Get.put<AuthController>(
    AuthController(
      authRepository: authRepository,
      storageService: storageService,
      gastosRepository: gastosRepository,
    ),
  );

  runApp(const BolsilloClaroApp());
}

/// Widget raíz de la aplicación Bolsillo Claro.
class BolsilloClaroApp extends StatelessWidget {
  const BolsilloClaroApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'Bolsillo Claro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode.value,
        initialRoute: AppRoutes.splash,
        getPages: AppRoutes.pages,
      ),
    );
  }
}
