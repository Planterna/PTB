import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../models/user_model.dart';

class RemoteUserDataSource {
  final ApiClient _apiClient;

  RemoteUserDataSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<UserModel> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedId = prefs.getString('user_id') ?? '';
    final cachedCedula = prefs.getString('user_cedula') ?? '';
    final cachedName = prefs.getString('user_name') ?? 'Usuario';
    final cachedUsername = prefs.getString('user_username') ?? '';
    final cachedEmail = prefs.getString('user_email') ?? '';

    try {
      final dynamic body = await _apiClient.get(ApiConstants.profile);

      if (body != null) {
        final userData = (body is Map<String, dynamic> && body['user'] is Map)
            ? body['user'] as Map<String, dynamic>
            : (body is Map<String, dynamic> ? body : <String, dynamic>{});

        final updatedUser = UserModel(
          id: userData['id']?.toString() ?? userData['id_usuario']?.toString() ?? cachedId,
          cedula: userData['cedula']?.toString() ?? userData['cedula_usuario']?.toString() ?? cachedCedula,
          name: userData['name']?.toString() ?? userData['nombres']?.toString() ?? userData['nombres_usuario']?.toString() ?? cachedName,
          email: userData['email']?.toString() ?? userData['email_usuario']?.toString() ?? cachedEmail,
          username: userData['usuario']?.toString() ?? userData['username']?.toString() ?? cachedUsername,
        );

        await prefs.setString('user_id', updatedUser.id);
        await prefs.setString('user_cedula', updatedUser.cedula);
        await prefs.setString('user_name', updatedUser.name);
        await prefs.setString('user_email', updatedUser.email);
        if (updatedUser.username != null) {
          await prefs.setString('user_username', updatedUser.username!);
        }

        return updatedUser;
      }
    } catch (_) {
      // Fallback a los datos de sesión local
    }

    return UserModel(
      id: cachedId,
      cedula: cachedCedula,
      name: cachedName,
      email: cachedEmail,
      username: cachedUsername,
    );
  }

  Future<UserModel> updateUserProfile({
    required String id,
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final dynamic body = await _apiClient.put(
        ApiConstants.profile,
        body: {
          'nombres': name,
          'email': email,
        },
      );

      if (body != null) {
        final userData = (body is Map<String, dynamic> && body['user'] is Map)
            ? body['user'] as Map<String, dynamic>
            : (body is Map<String, dynamic> ? body : <String, dynamic>{});

        final updated = UserModel(
          id: userData['id']?.toString() ?? userData['id_usuario']?.toString() ?? id,
          cedula: userData['cedula']?.toString() ?? userData['cedula_usuario']?.toString() ?? (prefs.getString('user_cedula') ?? ''),
          name: userData['name']?.toString() ?? userData['nombres']?.toString() ?? userData['nombres_usuario']?.toString() ?? name,
          email: userData['email']?.toString() ?? userData['email_usuario']?.toString() ?? email,
          username: userData['usuario']?.toString() ?? userData['username']?.toString() ?? prefs.getString('user_username'),
        );

        await prefs.setString('user_name', updated.name);
        await prefs.setString('user_email', updated.email);
        return updated;
      }
    } catch (_) {
      // Fallback a persistencia local
    }

    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);

    return UserModel(
      id: id,
      cedula: prefs.getString('user_cedula') ?? '',
      name: name,
      email: email,
      username: prefs.getString('user_username'),
    );
  }
}
