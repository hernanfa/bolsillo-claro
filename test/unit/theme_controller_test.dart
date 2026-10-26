import 'package:bolsillo_claro/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import '../mocks/mock_gastos_dependencies.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeSettingsStorageService fakeSettings;
  late ThemeController controller;

  setUp(() {
    Get.testMode = true;
    fakeSettings = FakeSettingsStorageService();
  });

  tearDown(() {
    Get.reset();
  });

  group('ThemeController - Persistencia de Preferencia de Tema', () {
    test('inicia en modo claro por defecto si no hay preferencia previa', () async {
      controller = ThemeController(settingsService: fakeSettings);
      await controller.loadThemeMode();

      expect(controller.themeMode.value, ThemeMode.light);
      expect(controller.isDarkMode, isFalse);
    });

    test('restaura modo oscuro si estaba previamente guardado en almacenamiento', () async {
      fakeSettings.savedThemeMode = 'dark';
      controller = ThemeController(settingsService: fakeSettings);
      await controller.loadThemeMode();

      expect(controller.themeMode.value, ThemeMode.dark);
      expect(controller.isDarkMode, isTrue);
    });

    test('toggleTheme alterna de claro a oscuro y persiste la preferencia', () async {
      controller = ThemeController(settingsService: fakeSettings);
      await controller.loadThemeMode();

      // Cambiar a oscuro
      await controller.toggleTheme();
      expect(controller.themeMode.value, ThemeMode.dark);
      expect(controller.isDarkMode, isTrue);
      expect(fakeSettings.savedThemeMode, 'dark');

      // Cambiar a claro
      await controller.toggleTheme();
      expect(controller.themeMode.value, ThemeMode.light);
      expect(controller.isDarkMode, isFalse);
      expect(fakeSettings.savedThemeMode, 'light');
    });
  });
}
