import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/errors/exceptions.dart';
import '../models/resumen_gastos_model.dart';

/// Contrato para el servicio cliente que interactúa con el proxy del asistente de IA.
abstract class AssistantService {
  /// Envía la pregunta del usuario junto al resumen de categorías al proxy de IA.
  Future<String> consultarAsistente({
    required String consulta,
    required ResumenGastosModel resumen,
  });
}

/// Implementación del servicio de asistente usando Dio.
class AssistantServiceImpl implements AssistantService {
  final Dio _dio;

  AssistantServiceImpl({Dio? customDio, String? baseUrl})
      : _dio = customDio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? ApiConfig.assistantBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 15),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

  @override
  Future<String> consultarAsistente({
    required String consulta,
    required ResumenGastosModel resumen,
  }) async {
    try {
      final payload = {
        'consulta': consulta.trim(),
        'resumen': resumen.toJson(),
      };

      final response = await _dio.post(
        ApiConfig.assistantEndpoint,
        data: payload,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('respuesta')) {
        return data['respuesta'] as String;
      }

      throw const AppException('Respuesta inválida del servidor proxy.');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException(
          'No se pudo conectar con el proxy del asistente. Verifica que el servidor proxy esté iniciado en el puerto 3000.',
        );
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const NetworkException(
          'El asistente de IA tardó demasiado en responder (tiempo límite agotado).',
        );
      }

      final response = e.response;
      if (response != null && response.data is Map<String, dynamic>) {
        final detail = response.data['detail'];
        if (detail is String) {
          throw AppException(detail, statusCode: response.statusCode);
        }
      }

      throw parseDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error inesperado al consultar al asistente: $e');
    }
  }
}
