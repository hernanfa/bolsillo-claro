import 'package:get/get.dart';

import '../core/errors/exceptions.dart';
import '../data/models/resumen_gastos_model.dart';
import '../data/repositories/gastos_repository.dart';
import '../data/services/assistant_service.dart';

/// Controlador GetX para gestionar las consultas y recomendaciones del Asistente de IA.
class AssistantController extends GetxController {
  final AssistantService assistantService;
  final GastosRepository gastosRepository;

  AssistantController({
    required this.assistantService,
    required this.gastosRepository,
  });

  // Estado reactivo
  final RxString preguntaActual = ''.obs;
  final RxString ultimaPreguntaConsultada = ''.obs;
  final RxString respuesta = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Preguntas sugeridas sobre distribución de gastos y consejos de ahorro
  final List<String> preguntasSugeridas = const [
    '¿En qué categoría estoy gastando más dinero este mes?',
    '¿Cómo puedo optimizar y reducir mis gastos?',
    '¿Cuánto presupuesto disponible me queda en mis categorías?',
    '¿Qué recomendaciones de ahorro tienes según mis totales?',
  ];

  bool get isEmpty =>
      !isLoading.value && respuesta.isEmpty && errorMessage.isEmpty;
  bool get hasResponse => !isLoading.value && respuesta.isNotEmpty;
  bool get hasError => !isLoading.value && errorMessage.isNotEmpty;

  void limpiar() {
    preguntaActual.value = '';
    respuesta.value = '';
    errorMessage.value = '';
    ultimaPreguntaConsultada.value = '';
  }

  /// Realiza la consulta al proxy de IA evitando ejecuciones simultáneas.
  Future<void> consultar({String? preguntaPersonalizada}) async {
    // Prevención de consultas simultáneas
    if (isLoading.value) return;

    final texto = (preguntaPersonalizada ?? preguntaActual.value).trim();

    if (texto.isEmpty) {
      errorMessage.value =
          'Por favor escribe una pregunta para consultar al asistente.';
      return;
    }

    if (texto.length > 500) {
      errorMessage.value =
          'La pregunta supera el límite permitido de 500 caracteres.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    respuesta.value = '';
    ultimaPreguntaConsultada.value = texto;

    // 1. Obtener el resumen real y vigente del backend
    ResumenGastosModel resumenActual;
    try {
      resumenActual = await gastosRepository.getResumen();
    } catch (_) {
      errorMessage.value = 'No se pudo obtener el resumen actual de gastos del servidor. Verifica tu conexión y que el backend esté activo.';
      isLoading.value = false;
      return;
    }

    // 2. Enviar únicamente la pregunta y los totales consolidados por categoría
    try {
      final res = await assistantService.consultarAsistente(
        consulta: texto,
        resumen: resumenActual,
      );
      respuesta.value = res;
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value =
          'Ocurrió un error inesperado al procesar la respuesta de la IA.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Reintenta la última consulta efectuada.
  Future<void> reintentar() async {
    if (ultimaPreguntaConsultada.isNotEmpty) {
      await consultar(preguntaPersonalizada: ultimaPreguntaConsultada.value);
    }
  }

  /// Selecciona una pregunta sugerida y la ejecuta inmediatamente.
  Future<void> seleccionarSugerencia(String sugerencia) async {
    preguntaActual.value = sugerencia;
    await consultar(preguntaPersonalizada: sugerencia);
  }
}
