import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'core/network/api_client.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Inyección de dependencias base
  final storageService = SecureStorageServiceImpl();
  final apiClient = ApiClient(storageService: storageService);
  final authRepository = AuthRepositoryImpl(apiClient: apiClient);

  Get.put<StorageService>(storageService);
  Get.put<ApiClient>(apiClient);
  Get.put<AuthRepository>(authRepository);
  Get.put<AuthController>(
    AuthController(
      authRepository: authRepository,
      storageService: storageService,
    ),
  );

  runApp(const BolsilloClaroApp());
}

/// Widget raíz de la aplicación Bolsillo Claro.
class BolsilloClaroApp extends StatelessWidget {
  const BolsilloClaroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Bolsillo Claro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
    );
  }
}
