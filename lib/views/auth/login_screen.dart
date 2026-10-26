import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../routes/app_routes.dart';

/// Pantalla de inicio de sesión de Bolsillo Claro.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final controller = Get.find<AuthController>();
    controller.clearError();
    if (_formKey.currentState?.validate() ?? false) {
      controller.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Encabezado e ícono
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryDarkBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppTheme.accentGreen,
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    const Text(
                      'Bolsillo Claro',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDarkBlue,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    const Text(
                      'Ingresa tus credenciales para continuar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Mensaje de error legible del servidor
                    Obx(() {
                      final error = controller.errorMessage.value;
                      if (error.isEmpty) return const SizedBox.shrink();

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        decoration: BoxDecoration(
                          color: AppTheme.errorBackground,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppTheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: AppTheme.spacingSm),
                            Expanded(
                              child: Text(
                                error,
                                style: const TextStyle(
                                  color: AppTheme.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Campo de correo
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.validateEmail,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        hintText: 'ejemplo@correo.com',
                        prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),

                    // Campo de contraseña
                    Obx(
                      () => TextFormField(
                        controller: _passwordController,
                        obscureText: controller.obscurePassword.value,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        validator: Validators.validatePassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscurePassword.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppTheme.textSecondary,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Botón de iniciar sesión
                    Obx(() {
                      final isLoading = controller.isLoading.value;
                      return ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Iniciar Sesión'),
                      );
                    }),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Enlace a registro
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          '¿No tienes una cuenta?',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.clearError();
                            Get.toNamed(AppRoutes.register);
                          },
                          child: const Text('Regístrate aquí'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
