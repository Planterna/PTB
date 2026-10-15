import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const Duration defaultTimeout = Duration(seconds: 15);

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_id');
    await prefs.remove('user_cedula');
    await prefs.remove('user_name');
    await prefs.remove('user_username');
    await prefs.remove('user_email');
  }

  Future<Map<String, String>> _buildHeaders({
    Map<String, String>? customHeaders,
    bool requiresAuth = true,
  }) async {
    final headers = <String, String>{
      ...ApiConstants.defaultHeaders,
      ...?customHeaders,
    };

    if (requiresAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final base = ApiConstants.baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final fullUrl = '$base$normalizedPath';
    final uri = Uri.parse(fullUrl);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParameters.map(
          (k, v) => MapEntry(k, v.toString()),
        ),
      );
    }
    return uri;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final finalHeaders = await _buildHeaders(
      customHeaders: headers,
      requiresAuth: requiresAuth,
    );

    try {
      final response = await _client.get(uri, headers: finalHeaders).timeout(defaultTimeout);
      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException('El servidor tardó demasiado en responder');
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(path);
    final finalHeaders = await _buildHeaders(
      customHeaders: headers,
      requiresAuth: requiresAuth,
    );

    try {
      final response = await _client
          .post(
            uri,
            headers: finalHeaders,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(defaultTimeout);
      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException('El servidor tardó demasiado en responder');
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(path);
    final finalHeaders = await _buildHeaders(
      customHeaders: headers,
      requiresAuth: requiresAuth,
    );

    try {
      final response = await _client
          .put(
            uri,
            headers: finalHeaders,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(defaultTimeout);
      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException('El servidor tardó demasiado en responder');
    }
  }

  Future<dynamic> delete(
    String path, {
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(path);
    final finalHeaders = await _buildHeaders(
      customHeaders: headers,
      requiresAuth: requiresAuth,
    );

    try {
      final response = await _client
          .delete(uri, headers: finalHeaders)
          .timeout(defaultTimeout);
      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException('El servidor tardó demasiado en responder');
    }
  }

  dynamic _processResponse(http.Response response) {
    dynamic decoded;
    try {
      decoded = json.decode(response.body);
    } catch (_) {
      decoded = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final message = (decoded is Map<String, dynamic>)
        ? (decoded['error'] ?? decoded['message'] ?? 'Error en la solicitud')
        : 'Error en la solicitud (${response.statusCode})';

    if (response.statusCode == 401) {
      throw UnauthorizedException(message.toString());
    }

    throw ApiException(
      message.toString(),
      statusCode: response.statusCode,
      details: decoded is Map ? decoded['details'] : null,
    );
  }
}
