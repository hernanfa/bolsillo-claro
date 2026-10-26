import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/assistant_controller.dart';
import '../../core/theme/app_theme.dart';

/// Sección del Asistente de IA para consultar análisis y recomendaciones de ahorro.
class AssistantView extends StatefulWidget {
  const AssistantView({super.key});

  @override
  State<AssistantView> createState() => _AssistantViewState();
}

class _AssistantViewState extends State<AssistantView> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _enviarConsulta(AssistantController controller) {
    final query = _textController.text.trim();
    if (query.isNotEmpty) {
      controller.consultar(preguntaPersonalizada: query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AssistantController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Aviso regulatorio y de transparencia de IA
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F2B48) : const Color(0xFFEBF5FF),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: isDark
                    ? AppTheme.accentGreen.withValues(alpha: 0.3)
                    : const Color(0xFF93C5FD),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: isDark
                      ? AppTheme.lightGreen
                      : AppTheme.secondaryDarkBlue,
                  size: 22,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Text(
                    'Aviso: Las respuestas y sugerencias son generadas por Inteligencia Artificial con fines informativos y de orientación personal.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFF1E3A8A),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingLg),

          // Campo de pregunta del usuario
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '¿En qué te puedo orientar hoy?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppTheme.lightGreen
                          : AppTheme.primaryDarkBlue,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  TextFormField(
                    controller: _textController,
                    maxLength: 500,
                    maxLines: 3,
                    minLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu pregunta sobre tus gastos, categorías o cómo ahorrar...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _textController.clear();
                          controller.limpiar();
                        },
                        child: const Text('Limpiar'),
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Obx(() {
                        final isLoading = controller.isLoading.value;
                        return ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(140, 46),
                          ),
                          onPressed: isLoading
                              ? null
                              : () => _enviarConsulta(controller),
                          icon: isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.send_rounded, size: 18),
                          label: const Text('Consultar'),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingLg),

          // Preguntas sugeridas
          Text(
            'Preguntas Sugeridas',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.preguntasSugeridas.map((sug) {
              return ActionChip(
                backgroundColor: isDark
                    ? AppTheme.surfaceDark
                    : AppTheme.surfaceLight,
                side: BorderSide(
                  color: isDark
                      ? AppTheme.cardBorderDark
                      : AppTheme.cardBorderLight,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                avatar: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 16,
                  color: AppTheme.accentGreen,
                ),
                label: Text(
                  sug,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
                ),
                onPressed: () {
                  _textController.text = sug;
                  controller.seleccionarSugerencia(sug);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: AppTheme.spacingXl),

          // Estados: Carga, Error, Vacío, Respuesta
          Obx(() {
            // 1. Estado de Carga
            if (controller.isLoading.value) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingXl),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(strokeWidth: 2.5),
                      const SizedBox(height: AppTheme.spacingMd),
                      const Text(
                        'Analizando tus totales de gastos...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Generando recomendaciones de ahorro personalizadas.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // 2. Estado de Error
            if (controller.hasError) {
              return Card(
                color: isDark
                    ? AppTheme.errorBackgroundDark
                    : AppTheme.errorBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  side: BorderSide(
                    color: AppTheme.error.withValues(alpha: 0.4),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppTheme.error,
                        size: 36,
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.error,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(140, 40),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Reintentar'),
                        onPressed: controller.reintentar,
                      ),
                    ],
                  ),
                ),
              );
            }

            // 3. Estado con Respuesta
            if (controller.hasResponse) {
              return Card(
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
                              color: isDark
                                  ? AppTheme.darkSurfaceGreen
                                  : AppTheme.surfaceGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.psychology_rounded,
                              color: AppTheme.accentGreen,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingSm),
                          const Text(
                            'Recomendación del Asistente',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      SelectableText(
                        controller.respuesta.value,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ],
                  ),
                ),
              );
            }

            // 4. Estado Vacío
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingXl),
                child: Column(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 48,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    const Text(
                      'Tu Asistente Financiero',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pregunta cómo optimizar tus finanzas o selecciona una de las sugerencias anteriores.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
