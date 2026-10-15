import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  RegisterViewModel(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _acceptTerms = false;
  bool get acceptTerms => _acceptTerms;

  void toggleAcceptTerms(bool? value) {
    _acceptTerms = value ?? false;
    notifyListeners();
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserModel? _user;
  UserModel? get user => _user;

  Future<bool> register(
    String idCard,
    String name,
    String email,
    String password,
    bool acceptTerms, {
    String? username,
  }) async {
    // Validaciones de negocio antes de intentar enviar a base de datos
    if (idCard.isEmpty ||
        name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        (username != null && username.trim().isEmpty)) {
      _errorMessage = 'Todos los campos son obligatorios';
      notifyListeners();
      return false;
    }
    
    if (!acceptTerms) {
      _errorMessage = 'Debes aceptar los términos y condiciones';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Inicia carga

    try {
      await _repository.register(
        idCard,
        name,
        email,
        password,
        username: username,
      );
      // Tras registrarse con éxito, intentamos hacer login para obtener el JWT y el usuario
      _user = await _repository.login(username ?? email, password);
      _isLoading = false;
      notifyListeners();
      return true; // Registro exitoso
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false; // Error en registro
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
