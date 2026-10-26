import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';

/// Pantalla principal posterior a la autenticación del usuario.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showLogoutDialog(BuildContext context, AuthController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas salir de Bolsillo Claro?'),
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

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bolsillo Claro'),
        actions: [
          IconButton(
            tooltip: 'Cerrar Sesión',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _showLogoutDialog(context, controller),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tarjeta de perfil del usuario autenticado
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.accentGreen, width: 2),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppTheme.accentGreen,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      const Text(
                        '¡Bienvenido!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDarkBlue,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Obx(() {
                        final email = controller.currentUser.value?.email ?? 'Cargando...';
                        return Text(
                          email,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        );
                      }),
                      const SizedBox(height: AppTheme.spacingMd),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceGreen,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.accentGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Sesión activa',
                              style: TextStyle(
                                color: AppTheme.accentGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // Tarjeta informativa de la etapa
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryDarkBlue.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: const Icon(
                              Icons.verified_user_rounded,
                              color: AppTheme.primaryDarkBlue,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingSm),
                          const Text(
                            'Estado del Sistema',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryDarkBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      const Text(
                        'Autenticación completada con éxito. Tu token se encuentra almacenado de forma segura.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacingXl),

              // Botón de cierre de sesión
              OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Cerrar Sesión'),
                onPressed: () => _showLogoutDialog(context, controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
