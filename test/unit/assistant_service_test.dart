import 'package:bolsillo_claro/core/errors/exceptions.dart';
import 'package:bolsillo_claro/data/models/resumen_gastos_model.dart';
import 'package:bolsillo_claro/data/services/assistant_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Dio fakeDio;
  late AssistantServiceImpl service;

  const testResumen = ResumenGastosModel(
    totalGeneral: 75.0,
    categorias: [
      ResumenCategoriaModel(
        categoria: 'comida',
        total: 50.0,
        cantidad: 2,
        disponible: 450.0,
      ),
      ResumenCategoriaModel(
        categoria: 'transporte',
        total: 25.0,
        cantidad: 1,
        disponible: 475.0,
      ),
    ],
  );

  setUp(() {
    fakeDio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
    service = AssistantServiceImpl(customDio: fakeDio);
  });

  group('AssistantServiceImpl - Comunicación con Proxy', () {
    test('procesa respuesta exitosa con texto generado por la IA', () async {
      fakeDio.interceptors.clear();
      fakeDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            // Verificar que solo se envían consulta y resumen
            final data = options.data as Map<String, dynamic>;
            expect(data.containsKey('consulta'), isTrue);
            expect(data.containsKey('resumen'), isTrue);
            expect(data.containsKey('token'), isFalse);
            expect(data.containsKey('email'), isFalse);

            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'respuesta':
                      'Tus gastos de transporte están bajo control este mes.',
                },
              ),
            );
          },
        ),
      );

      final result = await service.consultarAsistente(
        consulta: '¿Cómo voy en transporte?',
        resumen: testResumen,
      );

      expect(result, 'Tus gastos de transporte están bajo control este mes.');
    });

    test(
      'genera mensaje claro cuando el proxy está apagado (connectionError)',
      () async {
        fakeDio.interceptors.clear();
        fakeDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.connectionError,
                ),
              );
            },
          ),
        );

        expect(
          () => service.consultarAsistente(
            consulta: '¿En qué gasto más?',
            resumen: testResumen,
          ),
          throwsA(
            predicate(
              (e) =>
                  e is NetworkException &&
                  e.message.contains(
                    'No se pudo conectar con el proxy del asistente',
                  ),
            ),
          ),
        );
      },
    );

    test(
      'genera mensaje claro cuando el proxy excede el tiempo límite (timeout)',
      () async {
        fakeDio.interceptors.clear();
        fakeDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.receiveTimeout,
                ),
              );
            },
          ),
        );

        expect(
          () => service.consultarAsistente(
            consulta: '¿En qué gasto más?',
            resumen: testResumen,
          ),
          throwsA(
            predicate(
              (e) =>
                  e is NetworkException &&
                  e.message.contains(
                    'El asistente de IA tardó demasiado en responder',
                  ),
            ),
          ),
        );
      },
    );

    test(
      'extrae mensaje de error de configuración 503 cuando no hay clave',
      () async {
        fakeDio.interceptors.clear();
        fakeDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 503,
                    data: {
                      'detail': 'La clave GEMINI_API_KEY no está configurada en el servidor proxy.',
                    },
                  ),
                ),
              );
            },
          ),
        );

        expect(
          () => service.consultarAsistente(
            consulta: '¿Consejos?',
            resumen: testResumen,
          ),
          throwsA(
            predicate(
              (e) =>
                  e is AppException &&
                  e.statusCode == 503 &&
                  e.message.contains(
                    'La clave GEMINI_API_KEY no está configurada',
                  ),
            ),
          ),
        );
      },
    );
  });
}
