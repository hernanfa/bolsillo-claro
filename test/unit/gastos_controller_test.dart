import 'package:bolsillo_claro/controllers/gastos_controller.dart';
import 'package:bolsillo_claro/core/errors/exceptions.dart';
import 'package:bolsillo_claro/data/models/gasto_model.dart';
import 'package:bolsillo_claro/data/models/resumen_gastos_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import '../mocks/mock_gastos_dependencies.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGastosRepository mockRepository;
  late GastosController controller;

  setUp(() {
    Get.testMode = true;
    mockRepository = MockGastosRepository();
    controller = GastosController(gastosRepository: mockRepository);
  });

  tearDown(() {
    Get.reset();
  });

  group('GastosController - Consulta y Paginación', () {
    test('fetchGastos carga la lista y actualiza totalCount y estados', () async {
      mockRepository.gastosToReturn = [
        const GastoModel(id: 1, descripcion: 'Almuerzo', monto: 12.5, categoria: 'comida'),
        const GastoModel(id: 2, descripcion: 'Taxi', monto: 5.0, categoria: 'transporte'),
      ];
      mockRepository.totalCountToReturn = 10;

      await controller.fetchGastos(refresh: true, userId: 1);

      expect(controller.gastos.length, 2);
      expect(controller.totalCount.value, 10);
      expect(controller.hasMoreItems, isTrue);
      expect(controller.isLoading.value, isFalse);
      expect(controller.errorMessage.value, isEmpty);
      expect(controller.isFromCache.value, isFalse);
    });

    test('loadMoreGastos agrega la siguiente página de gastos sin duplicados', () async {
      controller.gastos.value = [
        const GastoModel(id: 1, descripcion: 'Almuerzo', monto: 12.5, categoria: 'comida'),
      ];
      controller.totalCount.value = 3;

      mockRepository.gastosToReturn = [
        const GastoModel(id: 1, descripcion: 'Almuerzo', monto: 12.5, categoria: 'comida'), // duplicado
        const GastoModel(id: 2, descripcion: 'Cine', monto: 8.0, categoria: 'entretenimiento'),
      ];

      await controller.loadMoreGastos(1);

      expect(controller.gastos.length, 2);
      expect(controller.gastos.map((g) => g.id), containsAll([1, 2]));
    });

    test('refleja estado de error si la consulta falla', () async {
      mockRepository.errorToThrow = const NetworkException('Error de conexión');

      await controller.fetchGastos(refresh: true, userId: 1);

      expect(controller.gastos, isEmpty);
      expect(controller.hasError, isTrue);
      expect(controller.errorMessage.value, 'Error de conexión');
    });

    test('refleja estado de caché y fecha cuando proviene de almacenamiento local', () async {
      final syncTime = DateTime(2026, 10, 26, 12, 0);
      mockRepository.gastosToReturn = [
        const GastoModel(id: 1, descripcion: 'En caché', monto: 10.0, categoria: 'otros'),
      ];
      mockRepository.fromCacheToReturn = true;
      mockRepository.lastSyncToReturn = syncTime;

      await controller.fetchGastos(refresh: true, userId: 1);

      expect(controller.isFromCache.value, isTrue);
      expect(controller.lastSync.value, syncTime);
    });
  });

  group('GastosController - Filtros y Categorías', () {
    test('fetchCategorias incluye opción Todos y límite por categoría', () async {
      await controller.fetchCategorias();

      expect(controller.categorias, containsAll(['Todos', 'comida', 'transporte']));
      expect(controller.limitePorCategoria.value, 500.0);
    });

    test('setCategoriaFilter actualiza la categoría seleccionada y refresca', () {
      controller.setCategoriaFilter('comida', 1);

      expect(controller.selectedCategoria.value, 'comida');
      expect(mockRepository.getGastosCallCount, 1);
    });
  });

  group('GastosController - Resumen', () {
    test('fetchResumen carga datos oficiales sin calcular sobre lista parcial', () async {
      mockRepository.resumenToReturn = const ResumenGastosModel(
        totalGeneral: 250.0,
        categorias: [
          ResumenCategoriaModel(
            categoria: 'comida',
            total: 100.0,
            cantidad: 4,
            disponible: 400.0,
          ),
        ],
      );

      await controller.fetchResumen();

      expect(controller.resumen.value?.totalGeneral, 250.0);
      expect(controller.resumen.value?.categorias.first.disponible, 400.0);
    });
  });

  group('GastosController - Crear, Editar y Eliminar', () {
    test('createGasto exitoso actualiza lista y resumen y evita envíos duplicados', () async {
      final success = await controller.createGasto(
        descripcion: 'Cafetería',
        monto: 4.5,
        categoria: 'comida',
        userId: 1,
      );

      expect(success, isTrue);
      expect(mockRepository.createGastoCallCount, 1);
      expect(mockRepository.lastCreatedDescripcion, 'Cafetería');
      expect(mockRepository.lastCreatedMonto, 4.5);
      expect(controller.isSaving.value, isFalse);
    });

    test('createGasto muestra mensaje del servidor cuando se supera el límite', () async {
      mockRepository.errorToThrow = const AppException(
        "Este gasto supera el límite de 500.0 para la categoría 'comida'",
        statusCode: 400,
      );

      final success = await controller.createGasto(
        descripcion: 'Cena de lujo',
        monto: 600.0,
        categoria: 'comida',
        userId: 1,
      );

      expect(success, isFalse);
      expect(
        controller.errorMessage.value,
        "Este gasto supera el límite de 500.0 para la categoría 'comida'",
      );
    });

    test('updateGasto actualiza el registro existente', () async {
      final success = await controller.updateGasto(
        id: 10,
        descripcion: 'Supermercado',
        monto: 35.0,
        categoria: 'comida',
        fecha: '2026-10-26',
        userId: 1,
      );

      expect(success, isTrue);
      expect(mockRepository.updateGastoCallCount, 1);
    });

    test('deleteGasto elimina el registro y refresca los datos', () async {
      final success = await controller.deleteGasto(id: 15, userId: 1);

      expect(success, isTrue);
      expect(mockRepository.deleteGastoCallCount, 1);
      expect(mockRepository.lastDeletedId, 15);
    });

    test('clearLocalState reinicia todos los datos', () {
      controller.gastos.add(
        const GastoModel(id: 1, descripcion: 'Prueba', monto: 1.0, categoria: 'otros'),
      );
      controller.totalCount.value = 1;
      controller.isFromCache.value = true;

      controller.clearLocalState();

      expect(controller.gastos, isEmpty);
      expect(controller.totalCount.value, 0);
      expect(controller.isFromCache.value, isFalse);
    });
  });
}
