import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../storage/settings_service.dart';

/// Controlador reactivo para alternar y persistir la preferencia de tema claro/oscuro.
class ThemeController extends GetxController {
  final SettingsStorageService settingsService;

  ThemeController({required this.settingsService});

  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  @override
  void onInit() {
    super.onInit();
    loadThemeMode();
  }

  /// Carga la preferencia de tema desde el almacenamiento persistente.
  Future<void> loadThemeMode() async {
    try {
      final savedMode = await settingsService.getThemeMode();
      if (savedMode == 'dark') {
        themeMode.value = ThemeMode.dark;
      } else {
        themeMode.value = ThemeMode.light;
      }
    } catch (_) {
      themeMode.value = ThemeMode.light;
    }
  }

  /// Alterna entre modo claro y modo oscuro guardando la preferencia.
  Future<void> toggleTheme() async {
    if (isDarkMode) {
      themeMode.value = ThemeMode.light;
      await settingsService.saveThemeMode('light');
    } else {
      themeMode.value = ThemeMode.dark;
      await settingsService.saveThemeMode('dark');
    }
    Get.changeThemeMode(themeMode.value);
  }
}
