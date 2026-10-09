import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';
import '../../models/user_model.dart';

class RemoteAuthDataSource {
  String _parseBackendError(http.Response response, String defaultMessage) {
    try {
      final body = json.decode(response.body);
      return body['error'] ?? defaultMessage;
    } catch (_) {
      return defaultMessage;
    }
  }

  Future<UserModel> login(String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');

    try {
      final response = await http.post(
        url,
        headers: ApiConstants.defaultHeaders,
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final token = body['token'] as String;

        // Guardar el token en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        return UserModel(
          id: body['user']?['id'] ?? '0',
          cedula: body['user']?['cedula'] ?? '',
          name: body['user']?['nombres'] ?? 'Usuario',
          email: email,
        );
      } else {
        throw Exception(_parseBackendError(response, 'Credenciales inválidas'));
      }
    } on SocketException {
      throw Exception('No es posible conectarse al servidor en estos momentos');
    } on http.ClientException {
      throw Exception('No es posible conectarse al servidor en estos momentos');
    }
  }

  Future<void> register(
    String cedula,
    String nombres,
    String email,
    String password,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}');

    try {
      final response = await http.post(
        url,
        headers: ApiConstants.defaultHeaders,
        body: json.encode({
          'cedula': cedula,
          'nombres': nombres,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception(
          _parseBackendError(
            response,
            'Error en el registro. Verifique sus datos.',
          ),
        );
      }
    } on SocketException {
      throw Exception('No es posible conectarse al servidor en estos momentos');
    } on http.ClientException {
      throw Exception('No es posible conectarse al servidor en estos momentos');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }
}
