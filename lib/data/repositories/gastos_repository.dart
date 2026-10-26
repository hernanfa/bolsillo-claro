import '../models/categorias_response_model.dart';
import '../models/gasto_model.dart';
import '../models/resumen_gastos_model.dart';

/// Resultado enriquecido de la consulta de gastos, incluyendo datos de paginación y caché.
class GastosListResult {
  final List<GastoModel> gastos;
  final int totalCount;
  final bool fromCache;
  final DateTime? lastSync;

  const GastosListResult({
    required this.gastos,
    required this.totalCount,
    required this.fromCache,
    this.lastSync,
  });
}

/// Contrato del repositorio de gastos para operaciones de datos y caché.
abstract class GastosRepository {
  /// Obtiene la lista paginada de gastos para el usuario autenticado.
  Future<GastosListResult> getGastos({
    int skip = 0,
    int limit = 20,
    String? categoria,
    int? userId,
  });

  /// Obtiene el resumen consolidado de gastos directamente del backend.
  Future<ResumenGastosModel> getResumen({String? desde, String? hasta});

  /// Obtiene el catálogo de categorías y el límite configurado.
  Future<CategoriasResponseModel> getCategorias();

  /// Registra un nuevo gasto.
  Future<GastoModel> createGasto({
    required String descripcion,
    required double monto,
    required String categoria,
    String? fecha,
  });

  /// Actualiza completamente un gasto existente.
  Future<GastoModel> updateGasto({
    required int id,
    required String descripcion,
    required double monto,
    required String categoria,
    required String fecha,
  });

  /// Elimina un gasto existente.
  Future<void> deleteGasto(int id);

  /// Limpia la caché local de gastos para el usuario indicado.
  Future<void> clearUserCache(int userId);
}
