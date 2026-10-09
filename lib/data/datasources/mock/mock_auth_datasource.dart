import '../../models/user_model.dart';

class MockAuthDataSource {
  // Simulamos una base de datos en memoria para guardar los usuarios registrados
  static final Map<String, Map<String, dynamic>> _mockDatabase = {
    // Usuario por defecto para pruebas rápidas
    'loisbecket@gmail.com': {
      'user': UserModel(
        id: '1',
        cedula: '0123456789',
        name: 'Lois Becket',
        email: 'loisbecket@gmail.com',
      ),
      'password': 'password123',
    }
  };

  Future<UserModel> login(String email, String password) async {
    // Simular retardo de red
    await Future.delayed(const Duration(seconds: 2));

    if (_mockDatabase.containsKey(email)) {
      final record = _mockDatabase[email]!;
      if (record['password'] == password) {
        return record['user'] as UserModel;
      } else {
        throw Exception('Contraseña incorrecta');
      }
    } else {
      throw Exception('Usuario no encontrado');
    }
  }

  Future<UserModel> register(String idCard, String name, String email, String password) async {
    // Simular retardo de red
    await Future.delayed(const Duration(seconds: 2));

    if (_mockDatabase.containsKey(email)) {
      throw Exception('El correo electrónico ya está registrado');
    }

    // Crear nuevo usuario
    final newUser = UserModel(
      id: idCard, // Usamos la cédula como ID simulado
      cedula: idCard,
      name: name,
      email: email,
    );

    // Guardar en la "base de datos"
    _mockDatabase[email] = {
      'user': newUser,
      'password': password,
    };

    return newUser;
  }
}
