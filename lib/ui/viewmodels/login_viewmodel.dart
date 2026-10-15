import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  LoginViewModel(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _rememberMe = false;
  bool get rememberMe => _rememberMe;

  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserModel? _user;
  UserModel? get user => _user;

  Future<bool> login(String username, String password) async {
    // Validación básica de UI
    if (username.isEmpty || password.isEmpty) {
      _errorMessage = 'Por favor, llena todos los campos';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Avisa a la vista que inicie la animación de carga

    try {
      _user = await _repository.login(username, password);
      _isLoading = false;
      notifyListeners();
      return true; // Login exitoso
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false; // Login fallido
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
