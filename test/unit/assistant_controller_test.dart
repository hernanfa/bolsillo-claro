import 'package:bolsillo_claro/controllers/assistant_controller.dart';
import 'package:bolsillo_claro/core/errors/exceptions.dart';
import 'package:bolsillo_claro/data/models/resumen_gastos_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import '../mocks/mock_assistant_dependencies.dart';
import '../mocks/mock_gastos_dependencies.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAssistantService mockAssistantService;
  late MockGastosRepository mockGastosRepository;
  late AssistantController controller;

  setUp(() {
    Get.testMode = true;
    mockAssistantService = MockAssistantService();
    mockGastosRepository = MockGastosRepository();
    controller = AssistantController(
      assistantService: mockAssistantService,
      gastosRepository: mockGastosRepository,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('AssistantController - Validaciones y Prevención de Concurrencia', () {
    test('rechaza preguntas vacías sin llamar al servicio', () async {
      await controller.consultar(preguntaPersonalizada: '   ');

      expect(
        controller.errorMessage.value,
        'Por favor escribe una pregunta para consultar al asistente.',
      );
      expect(mockAssistantService.callCount, 0);
      expect(controller.isLoading.value, isFalse);
    });

    test('rechaza preguntas que superen los 500 caracteres', () async {
      final longQuery = 'x' * 501;
      await controller.consultar(preguntaPersonalizada: longQuery);

      expect(
        controller.errorMessage.value,
        'La pregunta supera el límite permitido de 500 caracteres.',
      );
      expect(mockAssistantService.callCount, 0);
    });

    test('previene llamadas simultáneas mientras isLoading está activo', () async {
      controller.isLoading.value = true;

      await controller.consultar(preguntaPersonalizada: '¿Cómo puedo ahorrar?');

      // No debe hacer la llamada porque ya había una consulta en curso
      expect(mockAssistantService.callCount, 0);
    });
  });

  group('AssistantController - Dependencia del Resumen Vigente', () {
    test('informa error y no inventa datos si el resumen no puede obtenerse del backend', () async {
      mockGastosRepository.errorToThrow = const NetworkException('Fallo al consultar resumen');

      await controller.consultar(preguntaPersonalizada: '¿En qué gasto más?');

      expect(
        controller.errorMessage.value,
        contains('No se pudo obtener el resumen actual de gastos del servidor'),
      );
      expect(mockAssistantService.callCount, 0);
      expect(controller.respuesta.value, isEmpty);
      expect(controller.isLoading.value, isFalse);
    });
  });

  group('AssistantController - Consulta Exitosa y Errores', () {
    test('envía pregunta y resumen vigente y actualiza la respuesta de la IA', () async {
      mockGastosRepository.resumenToReturn = const ResumenGastosModel(
        totalGeneral: 180.0,
        categorias: [
          ResumenCategoriaModel(categoria: 'comida', total: 120.0, cantidad: 4, disponible: 380.0),
          ResumenCategoriaModel(categoria: 'transporte', total: 60.0, cantidad: 2, disponible: 440.0),
        ],
      );

      mockAssistantService.respuestaToReturn =
          'Tu mayor gasto es comida (\$120.00). Podrías ahorrar preparando viandas.';

      await controller.consultar(preguntaPersonalizada: '¿En qué categoría gasto más?');

      expect(controller.isLoading.value, isFalse);
      expect(controller.errorMessage.value, isEmpty);
      expect(
        controller.respuesta.value,
        'Tu mayor gasto es comida (\$120.00). Podrías ahorrar preparando viandas.',
      );
      expect(mockAssistantService.lastConsulta, '¿En qué categoría gasto más?');
      expect(mockAssistantService.lastResumen?.totalGeneral, 180.0);
    });

    test('captura errores legibles devueltos por el proxy (ej. cuota o clave)', () async {
      mockAssistantService.errorToThrow = const AppException(
        'Se ha alcanzado la cuota de consultas gratuitas de IA. Inténtalo más tarde.',
        statusCode: 429,
      );

      await controller.consultar(preguntaPersonalizada: '¿Consejos para ahorrar?');

      expect(controller.isLoading.value, isFalse);
      expect(
        controller.errorMessage.value,
        'Se ha alcanzado la cuota de consultas gratuitas de IA. Inténtalo más tarde.',
      );
      expect(controller.respuesta.value, isEmpty);
    });

    test('seleccionarSugerencia ejecuta la pregunta elegida', () async {
      const sugerencia = '¿Cómo puedo optimizar y reducir mis gastos?';
      await controller.seleccionarSugerencia(sugerencia);

      expect(controller.preguntaActual.value, sugerencia);
      expect(mockAssistantService.lastConsulta, sugerencia);
    });

    test('reintentar vuelve a ejecutar la última consulta enviada', () async {
      // 1. Primer intento falla
      mockAssistantService.errorToThrow = const NetworkException('Proxy apagado');
      await controller.consultar(preguntaPersonalizada: '¿Cómo recortar gastos?');
      expect(controller.errorMessage.value, 'Proxy apagado');

      // 2. Resolver error y reintentar
      mockAssistantService.errorToThrow = null;
      mockAssistantService.respuestaToReturn = 'Recomendación de ahorro tras reintentar.';

      await controller.reintentar();

      expect(controller.errorMessage.value, isEmpty);
      expect(controller.respuesta.value, 'Recomendación de ahorro tras reintentar.');
    });
  });
}
