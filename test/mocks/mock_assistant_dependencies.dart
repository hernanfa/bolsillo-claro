import 'package:bolsillo_claro/data/models/resumen_gastos_model.dart';
import 'package:bolsillo_claro/data/services/assistant_service.dart';

/// Mock de AssistantService para pruebas unitarias sin conexión de red.
class MockAssistantService implements AssistantService {
  String respuestaToReturn =
      'De acuerdo con tus gastos, tu mayor egreso está en comida. Te sugiero preparar un menú semanal para ahorrar.';
  Exception? errorToThrow;

  int callCount = 0;
  String? lastConsulta;
  ResumenGastosModel? lastResumen;

  @override
  Future<String> consultarAsistente({
    required String consulta,
    required ResumenGastosModel resumen,
  }) async {
    callCount++;
    lastConsulta = consulta;
    lastResumen = resumen;

    if (errorToThrow != null) {
      throw errorToThrow!;
    }

    return respuestaToReturn;
  }
}
