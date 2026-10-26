import 'package:bolsillo_claro/core/errors/exceptions.dart';
import 'package:bolsillo_claro/core/network/api_client.dart';
import 'package:bolsillo_claro/data/models/gasto_model.dart';
import 'package:bolsillo_claro/data/repositories/gastos_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import '../mocks/mock_gastos_dependencies.dart';

void main() {
  late FakeGastosCacheService fakeCache;
  late Dio fakeDio;
  late ApiClient apiClient;
  late GastosRepositoryImpl repository;

  setUp(() {
    fakeCache = FakeGastosCacheService();
    fakeDio = Dio();
    apiClient = ApiClient(customDio: fakeDio);
    repository = GastosRepositoryImpl(
      apiClient: apiClient,
      cacheService: fakeCache,
    );
  });

  group('GastosCacheService - Separación de datos por ID de usuario', () {
    test('la caché del usuario 1 está completamente aislada de la del usuario 2', () async {
      final gastosUser1 = [
        const GastoModel(id: 1, descripcion: 'Gasto U1', monto: 10.0, categoria: 'comida'),
      ];
      final gastosUser2 = [
        const GastoModel(id: 2, descripcion: 'Gasto U2', monto: 25.0, categoria: 'transporte'),
      ];

      await fakeCache.saveGastos(userId: 1, gastos: gastosUser1);
      await fakeCache.saveGastos(userId: 2, gastos: gastosUser2);

      final cachedU1 = await fakeCache.getGastos(1);
      final cachedU2 = await fakeCache.getGastos(2);

      expect(cachedU1.length, 1);
      expect(cachedU1.first.descripcion, 'Gasto U1');

      expect(cachedU2.length, 1);
      expect(cachedU2.first.descripcion, 'Gasto U2');
    });

    test('clearUserCache limpia la caja del usuario sin afectar a otros usuarios', () async {
      await fakeCache.saveGastos(
        userId: 1,
        gastos: [const GastoModel(id: 1, descripcion: 'U1', monto: 10.0, categoria: 'comida')],
      );
      await fakeCache.saveGastos(
        userId: 2,
        gastos: [const GastoModel(id: 2, descripcion: 'U2', monto: 20.0, categoria: 'otros')],
      );

      await repository.clearUserCache(1);

      expect(await fakeCache.getGastos(1), isEmpty);
      expect(await fakeCache.getLastSync(1), isNull);

      final cachedU2 = await fakeCache.getGastos(2);
      expect(cachedU2.length, 1);
      expect(cachedU2.first.descripcion, 'U2');
    });
  });

  group('GastosRepositoryImpl - Políticas de Fallback y Respaldo de Caché', () {
    test('usa datos de caché cuando ocurre un error de red (NetworkException)', () async {
      // Poblar caché previamente para el usuario 10
      await fakeCache.saveGastos(
        userId: 10,
        gastos: [
          const GastoModel(id: 99, descripcion: 'Guardado previo', monto: 30.0, categoria: 'comida'),
        ],
      );

      // Configurar interceptor para simular fallo de conexión
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

      final result = await repository.getGastos(userId: 10);

      expect(result.fromCache, isTrue);
      expect(result.gastos.length, 1);
      expect(result.gastos.first.descripcion, 'Guardado previo');
      expect(result.lastSync, isNotNull);
    });

    test('usa datos de caché cuando el servidor responde con error 500 (5xx)', () async {
      await fakeCache.saveGastos(
        userId: 10,
        gastos: [
          const GastoModel(id: 77, descripcion: 'Gasto antes de caída', monto: 15.0, categoria: 'otros'),
        ],
      );

      fakeDio.interceptors.clear();
      fakeDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 500,
                  data: {'detail': 'Internal Server Error'},
                ),
              ),
            );
          },
        ),
      );

      final result = await repository.getGastos(userId: 10);

      expect(result.fromCache, isTrue);
      expect(result.gastos.first.id, 77);
    });

    test('NO usa caché para ocultar un error 401 de sesión expirada', () async {
      await fakeCache.saveGastos(
        userId: 10,
        gastos: [
          const GastoModel(id: 99, descripcion: 'Gasto no visible', monto: 50.0, categoria: 'comida'),
        ],
      );

      fakeDio.interceptors.clear();
      fakeDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                  data: {'detail': 'Token expirado o inválido'},
                ),
              ),
            );
          },
        ),
      );

      // Debe relanzar AuthException y no devolver los datos cacheados
      expect(
        () => repository.getGastos(userId: 10),
        throwsA(isA<AuthException>()),
      );
    });

    test('sin conexión, las operaciones de escritura NO simulan éxito y lanzan error', () async {
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

      // 1. Crear sin conexión falla honestamente
      expect(
        () => repository.createGasto(
          descripcion: 'Gasto offline',
          monto: 20.0,
          categoria: 'comida',
        ),
        throwsA(isA<NetworkException>()),
      );

      // 2. Editar sin conexión falla honestamente
      expect(
        () => repository.updateGasto(
          id: 1,
          descripcion: 'Gasto editado offline',
          monto: 20.0,
          categoria: 'comida',
          fecha: '2026-10-26',
        ),
        throwsA(isA<NetworkException>()),
      );

      // 3. Eliminar sin conexión falla honestamente
      expect(
        () => repository.deleteGasto(1),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
