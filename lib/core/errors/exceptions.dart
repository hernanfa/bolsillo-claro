import 'package:dio/dio.dart';

/// Excepción base de la aplicación.
class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  /// Determina si este error califica para mostrar datos de respaldo en caché:
  /// Solo errores de red o errores internos del servidor (5xx).
  /// Jamás para errores de autenticación (401), validación (422) o de negocio (400).
  bool get isCacheFallbackEligible =>
      this is NetworkException || (statusCode != null && statusCode! >= 500);

  @override
  String toString() => message;
}

/// Excepción específica para errores de autenticación o sesión.
class AuthException extends AppException {
  const AuthException(super.message, {super.statusCode});
}

/// Excepción para errores de red o conectividad.
class NetworkException extends AppException {
  const NetworkException(super.message, {super.statusCode});
}

/// Extrae mensajes legibles en español a partir de una DioException del backend.
AppException parseDioError(DioException error) {
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout) {
    return const NetworkException(
      'El servidor tardó demasiado en responder. Revisa tu conexión.',
    );
  }

  if (error.type == DioExceptionType.connectionError) {
    return const NetworkException(
      'No se pudo conectar con el servidor. Verifica que el backend esté activo.',
    );
  }

  final response = error.response;
  if (response != null) {
    final status = response.statusCode;
    final dynamic data = response.data;

    String readableMessage = 'Ocurrió un error en el servidor.';

    if (data is Map<String, dynamic> && data.containsKey('detail')) {
      final detail = data['detail'];
      if (detail is String) {
        readableMessage = detail;
      } else if (detail is List && detail.isNotEmpty) {
        // Errores de validación Pydantic / FastAPI
        final errors = detail.map((e) {
          if (e is Map<String, dynamic>) {
            final msg = e['msg']?.toString() ?? 'Dato inválido';
            final loc = (e['loc'] as List?)?.last?.toString();
            if (loc != null && loc != 'body') {
              return '$loc: $msg';
            }
            return msg;
          }
          return e.toString();
        }).toList();
        readableMessage = errors.join('\n');
      }
    } else if (status == 401) {
      readableMessage = 'Credenciales inválidas o sesión expirada.';
    } else if (status == 403) {
      readableMessage = 'No tienes permiso para realizar esta acción.';
    } else if (status == 404) {
      readableMessage = 'El recurso solicitado no fue encontrado.';
    } else if (status != null && status >= 500) {
      readableMessage = 'Error interno del servidor. Inténtalo más tarde.';
    }

    if (status == 401 || status == 403) {
      return AuthException(readableMessage, statusCode: status);
    }
    return AppException(readableMessage, statusCode: status);
  }

  return AppException(error.message ?? 'Error inesperado de comunicación.');
}
