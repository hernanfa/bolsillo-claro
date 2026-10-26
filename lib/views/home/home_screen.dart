import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/gastos_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';
import '../../data/models/gasto_model.dart';
import '../assistant/assistant_view.dart';
import 'widgets/categoria_filter_bar.dart';
import 'widgets/gasto_card.dart';
import 'widgets/gasto_form_dialog.dart';
import 'widgets/gastos_resumen_card.dart';

/// Pantalla principal que integra la lista paginada de gastos, filtros, resumen y persistencia.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Get.find<AuthController>();
      final gastosController = Get.find<GastosController>();
      final userId = authController.currentUser.value?.id;
      gastosController.init(userId);
    });
  }

  void _showLogoutDialog(BuildContext context, AuthController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text(
          '¿Estás seguro de que deseas salir? Tus datos locales se limpiarán por seguridad.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(100, 42),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.logout();
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, GastoModel gasto) {
    final gastosController = Get.find<GastosController>();
    final authController = Get.find<AuthController>();
    final userId = authController.currentUser.value?.id;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Gasto'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${gasto.descripcion}" por \$${gasto.monto.toStringAsFixed(2)}?',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(100, 42),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              gastosController.deleteGasto(id: gasto.id, userId: userId);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final gastosController = Get.find<GastosController>();
    final themeController = Get.find<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTab == 0 ? 'Bolsillo Claro' : 'Asistente IA'),
        actions: [
          // Alternar tema claro / oscuro
          Obx(
            () => IconButton(
              tooltip: themeController.isDarkMode
                  ? 'Modo Claro'
                  : 'Modo Oscuro',
              icon: Icon(
                themeController.isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
              onPressed: themeController.toggleTheme,
            ),
          ),
          // Cerrar sesión
          IconButton(
            tooltip: 'Cerrar Sesión',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _showLogoutDialog(context, authController),
          ),
        ],
      ),
      floatingActionButton: _currentTab == 0
          ? FloatingActionButton.extended(
              backgroundColor: isDark
                  ? AppTheme.lightGreen
                  : AppTheme.accentGreen,
              foregroundColor: isDark ? const Color(0xFF0A192F) : Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Nuevo Gasto',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => GastoFormDialog.show(context),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (idx) {
          setState(() {
            _currentTab = idx;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Gastos',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome_rounded),
            label: 'Asistente IA',
          ),
        ],
      ),
      body: SafeArea(
        child: _currentTab == 0
            ? RefreshIndicator(
                color: AppTheme.accentGreen,
                onRefresh: () async {
                  final userId = authController.currentUser.value?.id;
                  await Future.wait([
                    gastosController.fetchGastos(refresh: true, userId: userId),
                    gastosController.fetchResumen(),
                  ]);
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Encabezado con correo del usuario
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppTheme.spacingLg,
                          AppTheme.spacingMd,
                          AppTheme.spacingLg,
                          AppTheme.spacingSm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Control de Gastos',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Obx(() {
                                  final email =
                                      authController.currentUser.value?.email ??
                                      '';
                                  return Text(
                                    email,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? AppTheme.textSecondaryDark
                                          : AppTheme.textSecondaryLight,
                                    ),
                                  );
                                }),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.darkSurfaceGreen
                                    : AppTheme.surfaceGreen,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppTheme.lightGreen
                                          : AppTheme.accentGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Activo',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppTheme.lightGreen
                                          : AppTheme.accentGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Aviso de datos en caché / última sincronización
                    SliverToBoxAdapter(
                      child: Obx(() {
                        if (!gastosController.isFromCache.value) {
                          return const SizedBox.shrink();
                        }
                        final syncDate = gastosController.lastSync.value;
                        final formattedDate = syncDate != null
                            ? _formatDateTime(syncDate)
                            : 'Reciente';

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingLg,
                            vertical: AppTheme.spacingSm,
                          ),
                          padding: const EdgeInsets.all(AppTheme.spacingMd),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF3B2807)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMd,
                            ),
                            border: Border.all(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.cloud_off_rounded,
                                color: Color(0xFFD97706),
                                size: 22,
                              ),
                              const SizedBox(width: AppTheme.spacingSm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Modo sin conexión • Datos en caché',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFB45309),
                                      ),
                                    ),
                                    Text(
                                      'Última sincronización: $formattedDate',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF92400E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),

                    // Resumen Consolidado (/gastos/resumen)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingLg,
                          vertical: AppTheme.spacingSm,
                        ),
                        child: GastosResumenCard(),
                      ),
                    ),

                    // Barra de filtros por categoría
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppTheme.spacingSm,
                        ),
                        child: CategoriaFilterBar(),
                      ),
                    ),

                    // Estados principales de la lista: Carga, Error, Vacío o Lista con Paginación
                    Obx(() {
                      final userId = authController.currentUser.value?.id;

                      // 1. Estado de carga inicial
                      if (gastosController.isLoading.value) {
                        return const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      // 2. Estado de error
                      if (gastosController.hasError) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppTheme.spacingLg),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppTheme.errorBackgroundDark
                                          : AppTheme.errorBackground,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.error_outline_rounded,
                                      color: AppTheme.error,
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingMd),
                                  Text(
                                    gastosController.errorMessage.value,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.error,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingLg),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(160, 44),
                                    ),
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: const Text('Reintentar'),
                                    onPressed: () {
                                      gastosController.fetchGastos(
                                        refresh: true,
                                        userId: userId,
                                      );
                                      gastosController.fetchResumen();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      // 3. Estado vacío
                      if (gastosController.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppTheme.spacingLg),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.savings_outlined,
                                    size: 64,
                                    color: isDark
                                        ? AppTheme.textSecondaryDark
                                        : AppTheme.textSecondaryLight,
                                  ),
                                  const SizedBox(height: AppTheme.spacingMd),
                                  const Text(
                                    'No tienes gastos registrados',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingXs),
                                  Text(
                                    gastosController.selectedCategoria.value ==
                                            'Todos'
                                        ? 'Comienza a organizar tus finanzas registrando tu primer gasto.'
                                        : 'No hay gastos para la categoría "${gastosController.selectedCategoria.value}".',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? AppTheme.textSecondaryDark
                                          : AppTheme.textSecondaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingLg),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(180, 44),
                                    ),
                                    icon: const Icon(Icons.add_rounded),
                                    label: const Text('Registrar Gasto'),
                                    onPressed: () =>
                                        GastoFormDialog.show(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      // 4. Lista de gastos con paginación
                      final gastosList = gastosController.gastos;

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingLg,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            // Elementos de la lista
                            if (index < gastosList.length) {
                              final gasto = gastosList[index];
                              return GastoCard(
                                gasto: gasto,
                                onEdit: () =>
                                    GastoFormDialog.show(context, gasto: gasto),
                                onDelete: () => _confirmDelete(context, gasto),
                              );
                            }

                            // Pie de lista con paginación
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppTheme.spacingLg,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    gastosController.paginationLabel,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppTheme.textSecondaryDark
                                          : AppTheme.textSecondaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingSm),
                                  if (gastosController.hasMoreItems)
                                    Obx(
                                      () => gastosController.isLoadingMore.value
                                          ? const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : OutlinedButton.icon(
                                              icon: const Icon(
                                                Icons.expand_more_rounded,
                                              ),
                                              label: const Text(
                                                'Cargar más gastos',
                                              ),
                                              onPressed: () => gastosController
                                                  .loadMoreGastos(userId),
                                            ),
                                    ),
                                  const SizedBox(
                                    height: 60,
                                  ), // Margen para el FAB
                                ],
                              ),
                            );
                          }, childCount: gastosList.length + 1),
                        ),
                      );
                    }),
                  ],
                ),
              )
            : const AssistantView(),
      ),
    );
  }
}
