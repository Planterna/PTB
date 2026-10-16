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
    final nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Los nombres no deben contener números ni caracteres especiales';
    }
    if (value.trim().length < 2) {
      return 'Ingresa un nombre válido de al menos 2 letras';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa un nombre de usuario';
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_\-]+$');
    if (!usernameRegex.hasMatch(value.trim())) {
      return 'Solo se permiten letras, números, guion bajo (_) y guion alto (-)';
    }
    if (value.trim().length < 3) {
      return 'El usuario debe tener al menos 3 caracteres';
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
