import 'package:hive/hive.dart';

/// Contrato para el almacenamiento persistente de preferencias de usuario.
abstract class SettingsStorageService {
  Future<void> saveThemeMode(String mode);
  Future<String?> getThemeMode();
}

/// Implementación basada en Hive para persistir preferencias como el tema.
class HiveSettingsStorageService implements SettingsStorageService {
  static const String boxName = 'settings_box';
  static const String _keyThemeMode = 'theme_mode';

  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<dynamic>(boxName);
    }
    return await Hive.openBox<dynamic>(boxName);
  }

  @override
  Future<void> saveThemeMode(String mode) async {
    final box = await _openBox();
    await box.put(_keyThemeMode, mode);
  }

  @override
  Future<String?> getThemeMode() async {
    final box = await _openBox();
    return box.get(_keyThemeMode) as String?;
  }
}
