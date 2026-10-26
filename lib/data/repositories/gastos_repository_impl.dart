import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/cache_service.dart';
import '../models/categorias_response_model.dart';
import '../models/gasto_model.dart';
import '../models/resumen_gastos_model.dart';
import 'gastos_repository.dart';

/// Implementación del repositorio de gastos integrando backend Dio y caché local Hive.
class GastosRepositoryImpl implements GastosRepository {
  final ApiClient apiClient;
  final GastosCacheService cacheService;

  GastosRepositoryImpl({required this.apiClient, required this.cacheService});

  @override
  Future<GastosListResult> getGastos({
    int skip = 0,
    int limit = 20,
    String? categoria,
    int? userId,
  }) async {
    try {
      final queryParams = <String, dynamic>{'skip': skip, 'limit': limit};
      if (categoria != null && categoria.isNotEmpty && categoria != 'Todos') {
        queryParams['categoria'] = categoria;
      }

      final response = await apiClient.dio.get(
        ApiConfig.gastosEndpoint,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is List) {
        final list = data
            .map((item) => GastoModel.fromJson(item as Map<String, dynamic>))
            .toList();

        // Extraer X-Total-Count del encabezado HTTP si está presente
        final headerCount = response.headers.value('x-total-count');
        final totalCount =
            int.tryParse(headerCount ?? '') ?? (skip + list.length);

        // Guardar en caché si es la primera página general
        if (userId != null &&
            skip == 0 &&
            (categoria == null || categoria == 'Todos')) {
          await cacheService.saveGastos(userId: userId, gastos: list);
        }

        return GastosListResult(
          gastos: list,
          totalCount: totalCount,
          fromCache: false,
          lastSync: DateTime.now(),
        );
      }

      throw const AppException(
        'Formato inesperado al obtener lista de gastos.',
      );
    } on DioException catch (e) {
      final appException = parseDioError(e);

      // Usar caché ante errores de conexión, timeout o 5xx; jamás ante 401 o errores de auth
      if (appException.isCacheFallbackEligible && userId != null) {
        final cached = await cacheService.getGastos(userId);
        final lastSync = await cacheService.getLastSync(userId);
        if (cached.isNotEmpty) {
          final filtered =
              (categoria != null &&
                  categoria.isNotEmpty &&
                  categoria != 'Todos')
              ? cached
                    .where(
                      (g) =>
                          g.categoria.toLowerCase() == categoria.toLowerCase(),
                    )
                    .toList()
              : cached;

          return GastosListResult(
            gastos: filtered,
            totalCount: filtered.length,
            fromCache: true,
            lastSync: lastSync,
          );
        }
      }

      throw appException;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error al consultar gastos: $e');
    }
  }

  @override
  Future<ResumenGastosModel> getResumen({String? desde, String? hasta}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (desde != null) queryParams['desde'] = desde;
      if (hasta != null) queryParams['hasta'] = hasta;

      final response = await apiClient.dio.get(
        ApiConfig.gastosResumenEndpoint,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ResumenGastosModel.fromJson(data);
      }
      throw const AppException(
        'Respuesta inesperada al obtener resumen de gastos.',
      );
    } on DioException catch (e) {
      throw parseDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error al consultar resumen: $e');
    }
  }

  @override
  Future<CategoriasResponseModel> getCategorias() async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.gastosCategoriasEndpoint,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return CategoriasResponseModel.fromJson(data);
      }
      throw const AppException('Respuesta inesperada al obtener categorías.');
    } on DioException catch (e) {
      throw parseDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error al consultar categorías: $e');
    }
  }

  @override
  Future<GastoModel> createGasto({
    required String descripcion,
    required double monto,
    required String categoria,
    String? fecha,
  }) async {
    try {
      final payload = <String, dynamic>{
        'descripcion': descripcion.trim(),
        'monto': monto,
        'categoria': categoria,
      };
      if (fecha != null && fecha.isNotEmpty) {
        payload['fecha'] = fecha;
      }

      final response = await apiClient.dio.post(
        ApiConfig.gastosEndpoint,
        data: payload,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return GastoModel.fromJson(data);
      }
      throw const AppException('Respuesta inesperada al crear gasto.');
    } on DioException catch (e) {
      throw parseDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error al crear gasto: $e');
    }
  }

  @override
  Future<GastoModel> updateGasto({
    required int id,
    required String descripcion,
    required double monto,
    required String categoria,
    required String fecha,
  }) async {
    try {
      final payload = <String, dynamic>{
        'descripcion': descripcion.trim(),
        'monto': monto,
        'categoria': categoria,
        'fecha': fecha,
      };

      final response = await apiClient.dio.put(
        ApiConfig.gastoDetailEndpoint(id),
        data: payload,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return GastoModel.fromJson(data);
      }
      throw const AppException('Respuesta inesperada al actualizar gasto.');
    } on DioException catch (e) {
      throw parseDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error al actualizar gasto: $e');
    }
  }

  @override
  Future<void> deleteGasto(int id) async {
    try {
      await apiClient.dio.delete(ApiConfig.gastoDetailEndpoint(id));
    } on DioException catch (e) {
      throw parseDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error al eliminar gasto: $e');
    }
  }

  @override
  Future<void> clearUserCache(int userId) async {
    await cacheService.clearUserCache(userId);
  }
}
