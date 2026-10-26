import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/gastos_controller.dart';
import '../../../core/theme/app_theme.dart';

/// Tarjeta de resumen consolidado obtenido del endpoint /gastos/resumen del backend.
class GastosResumenCard extends StatelessWidget {
  const GastosResumenCard({super.key});

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'comida':
        return Icons.restaurant_rounded;
      case 'transporte':
        return Icons.directions_bus_rounded;
      case 'entretenimiento':
        return Icons.movie_filter_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GastosController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.isLoadingResumen.value) {
        return Card(
          child: Container(
            height: 120,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(strokeWidth: 2.5),
          ),
        );
      }

      final resumen = controller.resumen.value;
      if (resumen == null) {
        return const SizedBox.shrink();
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Acumulado',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${resumen.totalGeneral.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppTheme.lightGreen
                              : AppTheme.primaryDarkBlue,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkSurfaceGreen
                          : AppTheme.surfaceGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.insights_rounded,
                      color: isDark
                          ? AppTheme.lightGreen
                          : AppTheme.accentGreen,
                      size: 26,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                'Distribución por Categoría',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: resumen.categorias.map((catResumen) {
                    return Container(
                      margin: const EdgeInsets.only(right: AppTheme.spacingSm),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.backgroundDark.withValues(alpha: 0.5)
                            : AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.cardBorderDark
                              : AppTheme.cardBorderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _iconForCategory(catResumen.categoria),
                            size: 18,
                            color: isDark
                                ? AppTheme.lightGreen
                                : AppTheme.accentGreen,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                catResumen.categoria.capitalizeFirst ??
                                    catResumen.categoria,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '\$${catResumen.total.toStringAsFixed(2)} (${catResumen.cantidad})',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppTheme.textSecondaryDark
                                      : AppTheme.textSecondaryLight,
                                ),
                              ),
                              Text(
                                'Disp: \$${catResumen.disponible.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: catResumen.disponible > 50
                                      ? (isDark
                                            ? AppTheme.lightGreen
                                            : AppTheme.accentGreen)
                                      : AppTheme.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
