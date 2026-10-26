import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/gastos_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/gasto_model.dart';

/// Modal para registrar o editar un gasto con validaciones completas.
class GastoFormDialog extends StatefulWidget {
  final GastoModel? initialGasto;

  const GastoFormDialog({super.key, this.initialGasto});

  static Future<void> show(BuildContext context, {GastoModel? gasto}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GastoFormDialog(initialGasto: gasto),
    );
  }

  @override
  State<GastoFormDialog> createState() => _GastoFormDialogState();
}

class _GastoFormDialogState extends State<GastoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descripcionController;
  late TextEditingController _montoController;
  late String _selectedCategoria;
  late DateTime _selectedDate;

  bool get _isEditing => widget.initialGasto != null;

  @override
  void initState() {
    super.initState();
    final gastosController = Get.find<GastosController>();
    final initial = widget.initialGasto;

    _descripcionController = TextEditingController(text: initial?.descripcion ?? '');
    _montoController = TextEditingController(
      text: initial != null ? initial.monto.toStringAsFixed(2) : '',
    );

    // Lista de categorías sin 'Todos'
    final validCategories = gastosController.categorias.where((c) => c != 'Todos').toList();
    if (initial != null && validCategories.contains(initial.categoria)) {
      _selectedCategoria = initial.categoria;
    } else if (validCategories.isNotEmpty) {
      _selectedCategoria = validCategories.first;
    } else {
      _selectedCategoria = 'otros';
    }

    if (initial?.fecha != null) {
      _selectedDate = DateTime.tryParse(initial!.fecha!) ?? DateTime.now();
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Seleccionar fecha del gasto',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _submit() async {
    final gastosController = Get.find<GastosController>();
    final authController = Get.find<AuthController>();
    final userId = authController.currentUser.value?.id;

    gastosController.clearError();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final descripcion = _descripcionController.text.trim();
    final cleanMonto = _montoController.text.trim().replaceAll(',', '.');
    final monto = double.parse(cleanMonto);
    final fechaStr = _formatDate(_selectedDate);

    bool success = false;
    if (_isEditing) {
      success = await gastosController.updateGasto(
        id: widget.initialGasto!.id,
        descripcion: descripcion,
        monto: monto,
        categoria: _selectedCategoria,
        fecha: fechaStr,
        userId: userId,
      );
    } else {
      success = await gastosController.createGasto(
        descripcion: descripcion,
        monto: monto,
        categoria: _selectedCategoria,
        fecha: fechaStr,
        userId: userId,
      );
    }

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gastosController = Get.find<GastosController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final validCategories = gastosController.categorias.where((c) => c != 'Todos').toList();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isEditing ? 'Editar Gasto' : 'Nuevo Gasto',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.lightGreen : AppTheme.primaryDarkBlue,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          gastosController.clearError();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  // Mensaje de error legible del servidor (ej. límite excedido)
                  Obx(() {
                    final err = gastosController.errorMessage.value;
                    if (err.isEmpty) return const SizedBox.shrink();

                    return Container(
                      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.errorBackgroundDark : AppTheme.errorBackground,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: AppTheme.error.withValues(alpha: 0.4)),
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
                              err,
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

                  // Campo de descripción
                  TextFormField(
                    controller: _descripcionController,
                    validator: Validators.validateGastoDescripcion,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Ej. Almuerzo de trabajo',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  // Campo de monto
                  TextFormField(
                    controller: _montoController,
                    validator: Validators.validateGastoMonto,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Monto (\$) *',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.attach_money_rounded),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  // Selector de categoría con límite informativo
                  DropdownButtonFormField<String>(
                    initialValue: validCategories.contains(_selectedCategoria)
                        ? _selectedCategoria
                        : (validCategories.isNotEmpty ? validCategories.first : null),
                    validator: Validators.validateGastoCategoria,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      helperText: 'Límite por categoría: \$${gastosController.limitePorCategoria.value.toStringAsFixed(0)}',
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    items: validCategories.map((c) {
                      return DropdownMenuItem<String>(
                        value: c,
                        child: Text(c.capitalizeFirst ?? c),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCategoria = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  // Selector de fecha
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      child: Text(
                        _formatDate(_selectedDate),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  // Botón de guardar con prevención de doble envío
                  Obx(() {
                    final isSaving = gastosController.isSaving.value;
                    return ElevatedButton(
                      onPressed: isSaving ? null : _submit,
                      child: isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(_isEditing ? 'Guardar Cambios' : 'Registrar Gasto'),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
