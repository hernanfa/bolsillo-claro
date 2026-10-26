import 'package:bolsillo_claro/core/storage/cache_service.dart';
import 'package:bolsillo_claro/core/storage/settings_service.dart';
import 'package:bolsillo_claro/data/models/categorias_response_model.dart';
import 'package:bolsillo_claro/data/models/gasto_model.dart';
import 'package:bolsillo_claro/data/models/resumen_gastos_model.dart';
import 'package:bolsillo_claro/data/repositories/gastos_repository.dart';

/// Implementación en memoria de GastosCacheService para pruebas unitarias de separación y caché.
class FakeGastosCacheService implements GastosCacheService {
  final Map<int, List<GastoModel>> _userBoxes = {};
  final Map<int, DateTime> _userSyncTimes = {};

  @override
  Future<void> saveGastos({
    required int userId,
    required List<GastoModel> gastos,
  }) async {
    _userBoxes[userId] = List<GastoModel>.from(gastos);
    _userSyncTimes[userId] = DateTime.now();
  }

  @override
  Future<List<GastoModel>> getGastos(int userId) async {
    return List<GastoModel>.from(_userBoxes[userId] ?? []);
  }

  @override
  Future<DateTime?> getLastSync(int userId) async {
    return _userSyncTimes[userId];
  }

  @override
  Future<void> clearUserCache(int userId) async {
    _userBoxes.remove(userId);
    _userSyncTimes.remove(userId);
  }

  @override
  Future<void> close() async {}
}

/// Implementación en memoria de SettingsStorageService para probar persistencia de tema.
class FakeSettingsStorageService implements SettingsStorageService {
  String? savedThemeMode;

  @override
  Future<void> saveThemeMode(String mode) async {
    savedThemeMode = mode;
  }

  @override
  Future<String?> getThemeMode() async {
    return savedThemeMode;
  }
}

/// Mock configurable de GastosRepository para aislar las pruebas de la red.
class MockGastosRepository implements GastosRepository {
  List<GastoModel> gastosToReturn = [];
  int totalCountToReturn = 0;
  bool fromCacheToReturn = false;
  DateTime? lastSyncToReturn;
  CategoriasResponseModel? categoriasToReturn;
  ResumenGastosModel? resumenToReturn;
  Exception? errorToThrow;

  int getGastosCallCount = 0;
  int createGastoCallCount = 0;
  int updateGastoCallCount = 0;
  int deleteGastoCallCount = 0;
  int clearCacheCallCount = 0;

  int? lastClearedUserId;
  String? lastCreatedDescripcion;
  double? lastCreatedMonto;
  String? lastCreatedCategoria;
  int? lastDeletedId;

  @override
  Future<GastosListResult> getGastos({
    int skip = 0,
    int limit = 20,
    String? categoria,
    int? userId,
  }) async {
    getGastosCallCount++;
    if (errorToThrow != null) throw errorToThrow!;

    var list = List<GastoModel>.from(gastosToReturn);
    if (categoria != null && categoria.isNotEmpty && categoria != 'Todos') {
      list = list
          .where((g) => g.categoria.toLowerCase() == categoria.toLowerCase())
          .toList();
    }

    return GastosListResult(
      gastos: list,
      totalCount: totalCountToReturn > 0 ? totalCountToReturn : list.length,
      fromCache: fromCacheToReturn,
      lastSync: lastSyncToReturn ?? (fromCacheToReturn ? DateTime.now() : null),
    );
  }

  @override
  Future<ResumenGastosModel> getResumen({String? desde, String? hasta}) async {
    if (errorToThrow != null) throw errorToThrow!;
    return resumenToReturn ??
        const ResumenGastosModel(
          totalGeneral: 150.0,
          categorias: [
            ResumenCategoriaModel(
              categoria: 'comida',
              total: 50.0,
              cantidad: 2,
              disponible: 450.0,
            ),
            ResumenCategoriaModel(
              categoria: 'transporte',
              total: 100.0,
              cantidad: 1,
              disponible: 400.0,
            ),
          ],
        );
  }

  @override
  Future<CategoriasResponseModel> getCategorias() async {
    if (errorToThrow != null) throw errorToThrow!;
    return categoriasToReturn ??
        const CategoriasResponseModel(
          categorias: ['comida', 'transporte', 'entretenimiento', 'otros'],
          limitePorCategoria: 500.0,
        );
  }

  @override
  Future<GastoModel> createGasto({
    required String descripcion,
    required double monto,
    required String categoria,
    String? fecha,
  }) async {
    createGastoCallCount++;
    lastCreatedDescripcion = descripcion;
    lastCreatedMonto = monto;
    lastCreatedCategoria = categoria;
    if (errorToThrow != null) throw errorToThrow!;

    return GastoModel(
      id: 101,
      descripcion: descripcion,
      monto: monto,
      categoria: categoria,
      fecha: fecha ?? '2026-10-26',
    );
  }

  @override
  Future<GastoModel> updateGasto({
    required int id,
    required String descripcion,
    required double monto,
    required String categoria,
    required String fecha,
  }) async {
    updateGastoCallCount++;
    if (errorToThrow != null) throw errorToThrow!;

    return GastoModel(
      id: id,
      descripcion: descripcion,
      monto: monto,
      categoria: categoria,
      fecha: fecha,
    );
  }

  @override
  Future<void> deleteGasto(int id) async {
    deleteGastoCallCount++;
    lastDeletedId = id;
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  Future<void> clearUserCache(int userId) async {
    clearCacheCallCount++;
    lastClearedUserId = userId;
  }
}
