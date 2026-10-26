import 'package:get/get.dart';
import '../core/errors/exceptions.dart';
import '../data/models/gasto_model.dart';
import '../data/models/resumen_gastos_model.dart';
import '../data/repositories/gastos_repository.dart';

/// Controlador GetX que gestiona la lista de gastos, paginación, filtros, resumen y caché.
class GastosController extends GetxController {
  final GastosRepository gastosRepository;

  GastosController({required this.gastosRepository});

  static const int pageSize = 20;

  // Estado de la lista de gastos
  final RxList<GastoModel> gastos = <GastoModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString errorMessage = ''.obs;

  // Estado de caché y sincronización
  final RxBool isFromCache = false.obs;
  final Rx<DateTime?> lastSync = Rx<DateTime?>(null);

  // Paginación
  final RxInt totalCount = 0.obs;

  // Filtros y categorías
  final RxString selectedCategoria = 'Todos'.obs;
  final RxList<String> categorias = <String>['Todos'].obs;
  final RxDouble limitePorCategoria = 500.0.obs;

  // Resumen del backend
  final Rx<ResumenGastosModel?> resumen = Rx<ResumenGastosModel?>(null);
  final RxBool isLoadingResumen = false.obs;

  bool get isEmpty => !isLoading.value && gastos.isEmpty && errorMessage.isEmpty;
  bool get hasError => errorMessage.isNotEmpty && gastos.isEmpty;
  bool get hasMoreItems => gastos.length < totalCount.value;
  String get paginationLabel => 'Mostrando ${gastos.length} de ${totalCount.value} gastos';

  void clearError() {
    errorMessage.value = '';
  }

  /// Inicializa los datos del usuario cargando categorías, resumen y primera página.
  Future<void> init(int? userId) async {
    await fetchCategorias();
    await Future.wait([
      fetchGastos(refresh: true, userId: userId),
      fetchResumen(),
    ]);
  }

  /// Carga el catálogo de categorías y su límite desde el backend.
  Future<void> fetchCategorias() async {
    try {
      final result = await gastosRepository.getCategorias();
      final list = <String>['Todos', ...result.categorias];
      categorias.value = list;
      limitePorCategoria.value = result.limitePorCategoria;
    } catch (_) {
      // Si falla, conservar valores por defecto seguros
    }
  }

  /// Consulta el resumen oficial de gastos calculado por el backend.
  Future<void> fetchResumen() async {
    isLoadingResumen.value = true;
    try {
      final res = await gastosRepository.getResumen();
      resumen.value = res;
    } catch (_) {
      // En modo sin conexión o error, el resumen puede no estar disponible
    } finally {
      isLoadingResumen.value = false;
    }
  }

  /// Carga o refresca la primera página de gastos del usuario.
  Future<void> fetchGastos({bool refresh = false, int? userId}) async {
    if (refresh) {
      isLoading.value = true;
      errorMessage.value = '';
    } else if (gastos.isEmpty) {
      isLoading.value = true;
      errorMessage.value = '';
    }

    try {
      final result = await gastosRepository.getGastos(
        skip: 0,
        limit: pageSize,
        categoria: selectedCategoria.value == 'Todos' ? null : selectedCategoria.value,
        userId: userId,
      );

      gastos.value = result.gastos;
      totalCount.value = result.totalCount;
      isFromCache.value = result.fromCache;
      lastSync.value = result.lastSync;
      errorMessage.value = '';
    } on AppException catch (e) {
      errorMessage.value = e.message;
      isFromCache.value = false;
    } catch (e) {
      errorMessage.value = 'Ocurrió un error inesperado al cargar los gastos.';
      isFromCache.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Carga la siguiente página de gastos respetando la paginación del servidor.
  Future<void> loadMoreGastos(int? userId) async {
    if (isLoadingMore.value || isLoading.value || !hasMoreItems) return;

    isLoadingMore.value = true;
    final nextSkip = gastos.length;

    try {
      final result = await gastosRepository.getGastos(
        skip: nextSkip,
        limit: pageSize,
        categoria: selectedCategoria.value == 'Todos' ? null : selectedCategoria.value,
        userId: userId,
      );

      // Evitar duplicados por id
      final existingIds = gastos.map((g) => g.id).toSet();
      final newItems = result.gastos.where((g) => !existingIds.contains(g.id)).toList();
      gastos.addAll(newItems);
      totalCount.value = result.totalCount;
    } on AppException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar más gastos.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Aplica el filtro por categoría seleccionada y refresca la lista.
  void setCategoriaFilter(String categoria, int? userId) {
    if (selectedCategoria.value == categoria) return;
    selectedCategoria.value = categoria;
    fetchGastos(refresh: true, userId: userId);
  }

  /// Crea un nuevo gasto y refresca la lista y el resumen si fue exitoso.
  /// Previene envíos duplicados mientras isSaving está activo.
  Future<bool> createGasto({
    required String descripcion,
    required double monto,
    required String categoria,
    String? fecha,
    int? userId,
  }) async {
    if (isSaving.value) return false;

    isSaving.value = true;
    errorMessage.value = '';

    try {
      await gastosRepository.createGasto(
        descripcion: descripcion,
        monto: monto,
        categoria: categoria,
        fecha: fecha,
      );

      // Actualizar lista y resumen tras creación exitosa
      await Future.wait([
        fetchGastos(refresh: true, userId: userId),
        fetchResumen(),
      ]);
      return true;
    } on AppException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Error inesperado al guardar el gasto.';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Edita un gasto existente y actualiza la lista y el resumen.
  Future<bool> updateGasto({
    required int id,
    required String descripcion,
    required double monto,
    required String categoria,
    required String fecha,
    int? userId,
  }) async {
    if (isSaving.value) return false;

    isSaving.value = true;
    errorMessage.value = '';

    try {
      await gastosRepository.updateGasto(
        id: id,
        descripcion: descripcion,
        monto: monto,
        categoria: categoria,
        fecha: fecha,
      );

      await Future.wait([
        fetchGastos(refresh: true, userId: userId),
        fetchResumen(),
      ]);
      return true;
    } on AppException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Error inesperado al actualizar el gasto.';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Elimina un gasto y refresca la lista y el resumen.
  Future<bool> deleteGasto({
    required int id,
    int? userId,
  }) async {
    if (isDeleting.value) return false;

    isDeleting.value = true;
    errorMessage.value = '';

    try {
      await gastosRepository.deleteGasto(id);

      await Future.wait([
        fetchGastos(refresh: true, userId: userId),
        fetchResumen(),
      ]);
      return true;
    } on AppException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Error inesperado al eliminar el gasto.';
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  /// Limpia el estado reactivo local (por ejemplo al cerrar sesión).
  void clearLocalState() {
    gastos.clear();
    totalCount.value = 0;
    isFromCache.value = false;
    lastSync.value = null;
    errorMessage.value = '';
    resumen.value = null;
    selectedCategoria.value = 'Todos';
  }
}
