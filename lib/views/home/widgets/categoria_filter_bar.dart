import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/gastos_controller.dart';
import '../../../core/theme/app_theme.dart';

/// Barra horizontal de filtros por categoría.
class CategoriaFilterBar extends StatelessWidget {
  const CategoriaFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final gastosController = Get.find<GastosController>();
    final authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final categories = gastosController.categorias;
      final selected = gastosController.selectedCategoria.value;

      return SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          itemCount: categories.length,
          separatorBuilder: (context, index) => const SizedBox(width: AppTheme.spacingSm),
          itemBuilder: (context, index) {
            final cat = categories[index];
            final isSelected = cat == selected;

            return ChoiceChip(
              label: Text(
                cat.capitalizeFirst ?? cat,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              selectedColor: isDark ? AppTheme.accentGreen : AppTheme.primaryDarkBlue,
              backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              side: BorderSide(
                color: isSelected
                    ? Colors.transparent
                    : (isDark ? AppTheme.cardBorderDark : AppTheme.cardBorderLight),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (_) {
                final userId = authController.currentUser.value?.id;
                gastosController.setCategoriaFilter(cat, userId);
              },
            );
          },
        ),
      );
    });
  }
}
