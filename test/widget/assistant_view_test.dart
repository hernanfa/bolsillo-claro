import 'package:bolsillo_claro/controllers/assistant_controller.dart';
import 'package:bolsillo_claro/core/theme/app_theme.dart';
import 'package:bolsillo_claro/views/assistant/assistant_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import '../mocks/mock_assistant_dependencies.dart';
import '../mocks/mock_gastos_dependencies.dart';

void main() {
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
    Get.put<AssistantController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  Widget createTestWidget() {
    return GetMaterialApp(
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: AssistantView(),
      ),
    );
  }

  group('Widget Tests - AssistantView', () {
    testWidgets('renderiza aviso de IA, campo de texto, botón y sugerencias', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Aviso: Las respuestas y sugerencias son generadas por Inteligencia Artificial'), findsOneWidget);
      expect(find.text('¿En qué te puedo orientar hoy?'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Consultar'), findsOneWidget);
      expect(find.text('Preguntas Sugeridas'), findsOneWidget);
      expect(find.text('Tu Asistente Financiero'), findsOneWidget);
    });

    testWidgets('muestra estado de carga mientras se procesa la consulta', (tester) async {
      controller.isLoading.value = true;

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Analizando tus totales de gastos...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('muestra recomendación cuando se recibe la respuesta de la IA', (tester) async {
      controller.respuesta.value = 'Te sugiero fijar un presupuesto semanal de \$30.00 en comida.';

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Recomendación del Asistente'), findsOneWidget);
      expect(find.text('Te sugiero fijar un presupuesto semanal de \$30.00 en comida.'), findsOneWidget);
    });

    testWidgets('muestra estado de error con botón de reintentar', (tester) async {
      controller.errorMessage.value = 'No se pudo conectar con el proxy del asistente.';
      controller.ultimaPreguntaConsultada.value = '¿Cómo ahorro?';

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No se pudo conectar con el proxy del asistente.'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Reintentar'), findsOneWidget);
    });
  });
}
