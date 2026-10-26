/// Validaciones para formularios de autenticación.
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
}
