/// Validaciones para formularios de autenticación y gestión de gastos.
class Validators {
  Validators._();

  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  /// Valida el campo de correo electrónico.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es requerido.';
    }
    final cleanEmail = value.trim();
    if (!_emailRegExp.hasMatch(cleanEmail)) {
      return 'Ingresa un correo electrónico válido.';
    }
    return null;
  }

  /// Valida el campo de contraseña según requisitos del backend (mínimo 8, máximo 72).
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida.';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }
    if (value.length > 72) {
      return 'La contraseña no puede exceder 72 caracteres.';
    }
    return null;
  }

  /// Valida que la confirmación coincida con la contraseña original.
  static String? validateConfirmPassword(String? confirm, String? original) {
    if (confirm == null || confirm.isEmpty) {
      return 'Por favor confirma tu contraseña.';
    }
    if (confirm != original) {
      return 'Las contraseñas no coinciden.';
    }
    return null;
  }

  /// Valida la descripción del gasto (no vacía, máximo 200 caracteres).
  static String? validateGastoDescripcion(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La descripción es obligatoria.';
    }
    if (value.trim().length > 200) {
      return 'La descripción no puede exceder 200 caracteres.';
    }
    return null;
  }

  /// Valida el monto del gasto (> 0, número válido, máx 2 decimales, máx 1,000,000).
  static String? validateGastoMonto(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El monto es obligatorio.';
    }
    final cleanValue = value.trim().replaceAll(',', '.');
    final parsed = double.tryParse(cleanValue);
    if (parsed == null) {
      return 'Ingresa un número válido.';
    }
    if (parsed <= 0) {
      return 'El monto debe ser mayor a cero.';
    }
    if (parsed > 1000000) {
      return 'El monto no puede exceder 1,000,000.';
    }
    // Validar máximo 2 decimales
    final parts = cleanValue.split('.');
    if (parts.length > 1 && parts[1].length > 2) {
      return 'El monto admite como máximo 2 decimales.';
    }
    return null;
  }

  /// Valida que se haya seleccionado una categoría válida.
  static String? validateGastoCategoria(String? value) {
    if (value == null || value.trim().isEmpty || value == 'Todos') {
      return 'Selecciona una categoría válida.';
    }
    return null;
  }

  /// Valida que la fecha no sea futura y tenga formato válido YYYY-MM-DD.
  static String? validateGastoFecha(DateTime? date) {
    if (date == null) {
      return 'La fecha es obligatoria.';
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);
    if (selected.isAfter(today)) {
      return 'La fecha no puede ser futura.';
    }
    return null;
  }
}
