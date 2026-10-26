import 'package:hive/hive.dart';

import '../../data/models/gasto_model.dart';

/// Contrato para el almacenamiento local y caché de gastos por usuario.
abstract class GastosCacheService {
  /// Guarda la lista de gastos y la marca de tiempo de sincronización para un usuario específico.
  Future<void> saveGastos({
    required int userId,
    required List<GastoModel> gastos,
  });

  /// Recupera los gastos almacenados en caché para el usuario.
  Future<List<GastoModel>> getGastos(int userId);

  /// Recupera la última fecha y hora de sincronización exitosa para el usuario.
  Future<DateTime?> getLastSync(int userId);

  /// Borra completamente la caja de caché asociada al usuario (ej. al cerrar sesión).
  Future<void> clearUserCache(int userId);

  /// Cierra conexiones y cajas abiertas.
  Future<void> close();
}

/// Implementación de caché local usando cajas de Hive separadas por usuario.
class HiveGastosCacheService implements GastosCacheService {
  static const String _keyGastos = 'cached_gastos';
  static const String _keyLastSync = 'cached_last_sync';

  String _boxNameForUser(int userId) => 'gastos_box_user_$userId';

  Future<Box<dynamic>> _openUserBox(int userId) async {
    final boxName = _boxNameForUser(userId);
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<dynamic>(boxName);
    }
    return await Hive.openBox<dynamic>(boxName);
  }

  @override
  Future<void> saveGastos({
    required int userId,
    required List<GastoModel> gastos,
  }) async {
    final box = await _openUserBox(userId);
    final rawList = gastos.map((g) => g.toJson()).toList();
    await box.put(_keyGastos, rawList);
    await box.put(_keyLastSync, DateTime.now().toIso8601String());
  }

  @override
  Future<List<GastoModel>> getGastos(int userId) async {
    final box = await _openUserBox(userId);
    final rawList = box.get(_keyGastos);
    if (rawList is List) {
      return rawList
          .map(
            (item) =>
                GastoModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    }
    return [];
  }

  @override
  Future<DateTime?> getLastSync(int userId) async {
    final box = await _openUserBox(userId);
    final rawTimestamp = box.get(_keyLastSync);
    if (rawTimestamp is String) {
      return DateTime.tryParse(rawTimestamp);
    }
    return null;
  }

  @override
  Future<void> clearUserCache(int userId) async {
    final boxName = _boxNameForUser(userId);
    if (Hive.isBoxOpen(boxName)) {
      final box = Hive.box<dynamic>(boxName);
      await box.clear();
      await box.close();
    } else {
      final box = await Hive.openBox<dynamic>(boxName);
      await box.clear();
      await box.close();
    }
    await Hive.deleteBoxFromDisk(boxName);
  }

  @override
  Future<void> close() async {
    // No cerramos todas las cajas globales para no interferir con settings
  }
}
