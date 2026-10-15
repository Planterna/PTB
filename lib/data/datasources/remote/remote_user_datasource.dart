import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../../models/user_model.dart';

class RemoteUserDataSource {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<UserModel> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedId = prefs.getString('user_id') ?? '';
    final cachedCedula = prefs.getString('user_cedula') ?? '';
    final cachedName = prefs.getString('user_name') ?? 'Usuario';
    final cachedEmail = prefs.getString('user_email') ?? '';

    final token = await _getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}');

    try {
      final response = await http.get(
        url,
        headers: {
          ...ApiConstants.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final userData = body['user'] ?? body;
        final updatedUser = UserModel(
          id: userData['id']?.toString() ?? userData['id_usuario']?.toString() ?? cachedId,
          cedula: userData['cedula'] ?? userData['cedula_usuario'] ?? cachedCedula,
          name: userData['name'] ?? userData['nombres'] ?? userData['nombres_usuario'] ?? cachedName,
          email: userData['email'] ?? userData['email_usuario'] ?? cachedEmail,
        );

        await prefs.setString('user_id', updatedUser.id);
        await prefs.setString('user_cedula', updatedUser.cedula);
        await prefs.setString('user_name', updatedUser.name);
        await prefs.setString('user_email', updatedUser.email);

        return updatedUser;
      }
    } catch (_) {
      // Si la API remota no responde o el endpoint está pendiente,
      // se utiliza la información persistida en la sesión activa real
    }

    return UserModel(
      id: cachedId,
      cedula: cachedCedula,
      name: cachedName,
      email: cachedEmail,
    );
  }

  Future<UserModel> updateUserProfile({
    required String id,
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = await _getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}');

    try {
      final response = await http.put(
        url,
        headers: {
          ...ApiConstants.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'nombres': name,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final userData = body['user'] ?? body;
        final updated = UserModel(
          id: userData['id']?.toString() ?? userData['id_usuario']?.toString() ?? id,
          cedula: userData['cedula'] ?? userData['cedula_usuario'] ?? (prefs.getString('user_cedula') ?? ''),
          name: userData['name'] ?? userData['nombres'] ?? userData['nombres_usuario'] ?? name,
          email: userData['email'] ?? userData['email_usuario'] ?? email,
        );

        await prefs.setString('user_name', updated.name);
        await prefs.setString('user_email', updated.email);
        return updated;
      }
    } catch (_) {
      // Fallback a persistencia local si no hay conectividad con el endpoint
    }

    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);

    return UserModel(
      id: id,
      cedula: prefs.getString('user_cedula') ?? '',
      name: name,
      email: email,
    );
  }
}
