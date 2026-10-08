class Validators {
  static String? validateCedula(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa tu número de cédula';
    }
    if (value.length != 10) {
      return 'La cédula debe tener 10 dígitos';
    }
    return null;
  }

  static String? validateNames(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa tus nombres completos';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa tu correo electrónico';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un correo válido (ej. usuario@correo.com)';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa tu contraseña';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, confirma tu contraseña';
    }
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }
}
