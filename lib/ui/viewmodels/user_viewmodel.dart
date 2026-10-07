import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

// El ViewModel usa ChangeNotifier para notificar a la View cuando los datos cambian
class UserViewModel extends ChangeNotifier {
  final UserRepository _repository;

  UserViewModel(this._repository);

  // Estados
  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Acción/Lógica de negocio
  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Avisa a la vista para que muestre un loader

    try {
      _user = await _repository.getUserProfile();
    } catch (e) {
      _errorMessage = 'Error al cargar el perfil: $e';
    } finally {
      _isLoading = false;
      notifyListeners(); // Avisa a la vista para que quite el loader y muestre los datos o error
    }
  }
}
