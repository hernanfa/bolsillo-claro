import 'package:bolsillo_claro/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators - Email', () {
    test('retorna error cuando el correo es nulo o vacío', () {
      expect(Validators.validateEmail(null), 'El correo electrónico es requerido.');
      expect(Validators.validateEmail(''), 'El correo electrónico es requerido.');
      expect(Validators.validateEmail('   '), 'El correo electrónico es requerido.');
    });

    test('retorna error cuando el formato de correo no es válido', () {
      expect(Validators.validateEmail('correo_sin_arroba.com'), 'Ingresa un correo electrónico válido.');
      expect(Validators.validateEmail('correo@dominio'), 'Ingresa un correo electrónico válido.');
      expect(Validators.validateEmail('@dominio.com'), 'Ingresa un correo electrónico válido.');
      expect(Validators.validateEmail('correo@.com'), 'Ingresa un correo electrónico válido.');
    });

    test('retorna null cuando el correo es válido', () {
      expect(Validators.validateEmail('usuario@empresa.com'), isNull);
      expect(Validators.validateEmail('test.usuario+1@sub.dominio.org'), isNull);
    });
  });

  group('Validators - Password', () {
    test('retorna error cuando la contraseña es nula o vacía', () {
      expect(Validators.validatePassword(null), 'La contraseña es requerida.');
      expect(Validators.validatePassword(''), 'La contraseña es requerida.');
    });

    test('retorna error cuando tiene menos de 8 caracteres', () {
      expect(
        Validators.validatePassword('1234567'),
        'La contraseña debe tener al menos 8 caracteres.',
      );
    });

    test('retorna error cuando excede 72 caracteres', () {
      final longPassword = 'a' * 73;
      expect(
        Validators.validatePassword(longPassword),
        'La contraseña no puede exceder 72 caracteres.',
      );
    });

    test('retorna null cuando la longitud está entre 8 y 72 caracteres', () {
      expect(Validators.validatePassword('12345678'), isNull);
      expect(Validators.validatePassword('PasswordSegura!123'), isNull);
      expect(Validators.validatePassword('a' * 72), isNull);
    });
  });

  group('Validators - Confirm Password', () {
    test('retorna error cuando el campo de confirmación está vacío', () {
      expect(
        Validators.validateConfirmPassword('', 'password123'),
        'Por favor confirma tu contraseña.',
      );
    });

    test('retorna error cuando las contraseñas no coinciden', () {
      expect(
        Validators.validateConfirmPassword('passA', 'passB'),
        'Las contraseñas no coinciden.',
      );
    });

    test('retorna null cuando las contraseñas coinciden exactamente', () {
      expect(
        Validators.validateConfirmPassword('miClaveSegura123', 'miClaveSegura123'),
        isNull,
      );
    });
  });
}
