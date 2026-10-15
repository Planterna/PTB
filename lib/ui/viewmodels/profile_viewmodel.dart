import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/auth_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  UserModel _user;
  UserModel get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProfileViewModel({
    required this._userRepository,
    required this._authRepository,
    required UserModel initialUser,
  }) : _user = initialUser {
    loadProfile();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedUser = await _userRepository.getUserProfile();
      if (fetchedUser.name.isNotEmpty) {
        _user = fetchedUser;
      }
    } catch (e) {
      _errorMessage = 'Error al cargar perfil: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
  }) async {
    if (name.trim().isEmpty || email.trim().isEmpty) {
      _errorMessage = 'Los campos no pueden estar vacíos';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _userRepository.updateUserProfile(
        id: _user.id,
        name: name.trim(),
        email: email.trim(),
      );
      _user = updated;
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'No se pudo actualizar el perfil: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
  }
}
