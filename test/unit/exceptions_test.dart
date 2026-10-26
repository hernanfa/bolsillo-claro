import 'package:bolsillo_claro/core/errors/exceptions.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Exceptions - parseDioError', () {
    test('procesa timeout de conexión adecuadamente', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      final appException = parseDioError(dioError);
      expect(appException, isA<NetworkException>());
      expect(
        appException.message,
        'El servidor tardó demasiado en responder. Revisa tu conexión.',
      );
    });

    test('procesa error de conexión del backend inactivo', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      final appException = parseDioError(dioError);
      expect(appException, isA<NetworkException>());
      expect(
        appException.message,
        'No se pudo conectar con el servidor. Verifica que el backend esté activo.',
      );
    });

    test('extrae mensaje de error string desde "detail"', () {
      final response = Response(
        requestOptions: RequestOptions(path: '/usuarios/token'),
        statusCode: 401,
        data: {'detail': 'Email o contraseña incorrectos'},
      );
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/usuarios/token'),
        response: response,
      );

      final appException = parseDioError(dioError);
      expect(appException, isA<AuthException>());
      expect(appException.message, 'Email o contraseña incorrectos');
      expect(appException.statusCode, 401);
    });

    test('extrae mensajes de validación Pydantic / 422 en formato legible', () {
      final response = Response(
        requestOptions: RequestOptions(path: '/usuarios/'),
        statusCode: 422,
        data: {
          'detail': [
            {
              'loc': ['body', 'password'],
              'msg': 'String should have at least 8 characters',
              'type': 'string_too_short',
            },
          ],
        },
      );
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/usuarios/'),
        response: response,
      );

      final appException = parseDioError(dioError);
      expect(
        appException.message,
        contains('password: String should have at least 8 characters'),
      );
      expect(appException.statusCode, 422);
    });
  });
}
