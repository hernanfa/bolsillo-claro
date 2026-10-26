import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/gasto_model.dart';

/// Tarjeta individual para mostrar un gasto con opciones de editar y eliminar.
class GastoCard extends StatelessWidget {
  final GastoModel gasto;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GastoCard({
    super.key,
    required this.gasto,
    required this.onEdit,
    required this.onDelete,
  });

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          children: [
            // Ícono de categoría
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkSurfaceGreen
                    : AppTheme.surfaceGreen,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Icon(
                _iconForCategory(gasto.categoria),
                color: isDark ? AppTheme.lightGreen : AppTheme.accentGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),

            // Descripción, categoría y fecha
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gasto.descripcion,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.primaryDarkBlue
                              : AppTheme.primaryDarkBlue.withValues(
                                  alpha: 0.08,
                                ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          gasto.categoria.capitalizeFirst ?? gasto.categoria,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppTheme.lightGreen
                                : AppTheme.primaryDarkBlue,
                          ),
                        ),
                      ),
                      if (gasto.fecha != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          gasto.fecha!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Monto formateado
            Text(
              '\$${gasto.monto.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.lightGreen : AppTheme.primaryDarkBlue,
              ),
            ),

            // Acciones: Editar y Eliminar
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
              onSelected: (action) {
                if (action == 'edit') {
                  onEdit();
                } else if (action == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppTheme.error,
                      ),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: AppTheme.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
