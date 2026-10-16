import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../models/user_model.dart';

class RemoteAuthDataSource {
  final ApiClient _apiClient;

  RemoteAuthDataSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<UserModel> login(String username, String password) async {
    final cleanUsername = username.trim();
    final cleanPassword = password.trim();

    final data = await _apiClient.post(
      ApiConstants.login,
      body: {
        'usuario': cleanUsername,
        if (cleanUsername.contains('@')) 'email': cleanUsername,
        'password': cleanPassword,
      },
      requiresAuth: false,
    );

    final token = data['token']?.toString() ?? '';
    if (token.isNotEmpty) {
      await _apiClient.saveToken(token);
    }

    final prefs = await SharedPreferences.getInstance();
    final userMap = (data['user'] is Map) ? data['user'] as Map<String, dynamic> : <String, dynamic>{};
    final userId = userMap['id']?.toString() ?? userMap['id_usuario']?.toString() ?? '0';
    final userCedula = userMap['cedula']?.toString() ?? userMap['cedula_usuario']?.toString() ?? '';
    final userName = userMap['name']?.toString() ?? userMap['nombres']?.toString() ?? userMap['nombres_usuario']?.toString() ?? 'Usuario';
    final userUsername = userMap['usuario']?.toString() ?? userMap['username']?.toString() ?? cleanUsername;
    final userEmail = userMap['email']?.toString() ?? userMap['email_usuario']?.toString() ?? '';

    await prefs.setString('user_id', userId);
    await prefs.setString('user_cedula', userCedula);
    await prefs.setString('user_name', userName);
    await prefs.setString('user_username', userUsername);
    await prefs.setString('user_email', userEmail);

    return UserModel(
      id: userId,
      cedula: userCedula,
      name: userName,
      email: userEmail.isNotEmpty ? userEmail : userUsername,
      username: userUsername,
    );
  }

  Future<void> register(
    String cedula,
    String nombres,
    String email,
    String password, {
    String? username,
  }) async {
    await _apiClient.post(
      ApiConstants.register,
      body: {
        'cedula': cedula.trim(),
        'nombres': nombres.trim(),
        'usuario': (username ?? '').trim(),
        'email': email.trim(),
        'password': password,
      },
      requiresAuth: false,
    );
  }

  Future<void> logout() async {
    await _apiClient.clearAuthData();
  }
}
