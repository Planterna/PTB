import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';
import '../../models/card_model.dart';
import '../../models/transaction_model.dart';
import '../../models/account_model.dart';

class RemoteFinanceDataSource {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  String _parseBackendError(http.Response response, String defaultMessage) {
    try {
      final body = json.decode(response.body);
      return body['error'] ?? defaultMessage;
    } catch (_) {
      return defaultMessage;
    }
  }

  Future<List<CardModel>> getCardsForUser(String userId) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.cards}');

    try {
      final response = await http.get(
        url,
        headers: {
          ...ApiConstants.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map(
              (json) => CardModel(
                id: json['id_tarjeta'],
                idCuenta: json['id_cuenta'],
                cardName: json['nombre_tarjeta'],
                cardNumber: json['numero_tarjeta'],
                tipoTarjeta: json['tipo_tarjeta'],
              ),
            )
            .toList();
      } else {
        throw Exception(
          _parseBackendError(response, 'Fallo al cargar tarjetas'),
        );
      }
    } on SocketException {
      throw Exception('No es posible conectarse al servidor en estos momentos');
    } on http.ClientException {
      throw Exception('No es posible conectarse al servidor en estos momentos');
    }
  }

  Future<void> createCard({
    required String idCuenta,
    required String cardName,
    required String tipoTarjeta,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.cards}');

    try {
      final response = await http.post(
        url,
        headers: {
          ...ApiConstants.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'id_cuenta': idCuenta,
          'nombre_tarjeta': cardName,
          'tipo_tarjeta': tipoTarjeta,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception(_parseBackendError(response, 'Fallo al crear tarjeta'));
      }
    } on SocketException {
      throw Exception('No es posible conectarse al servidor en estos momentos');
    } on http.ClientException {
      throw Exception('No es posible conectarse al servidor en estos momentos');
    }
  }

  Future<List<TransactionModel>> getTransactionsForUser(String userId) async {
    final token = await _getToken();
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.transactions}',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          ...ApiConstants.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map(
              (json) => TransactionModel(
                id: json['id_movimiento'],
                name: json['nombre_movimiento'],
                value: (json['valor_movimiento'] ?? 0.0).toDouble(),
                date: _formatDate(json['fecha_movimiento']),
                type: _parseTransactionType(json['tipo_movimiento']),
              ),
            )
            .toList();
      } else {
        throw Exception(
          _parseBackendError(response, 'Fallo al cargar movimientos'),
        );
      }
    } on SocketException {
      throw Exception('No es posible conectarse al servidor en estos momentos');
    } on http.ClientException {
      throw Exception('No es posible conectarse al servidor en estos momentos');
    }
  }

  Future<List<AccountModel>> getAccountsForUser(String userId) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.accounts}');

    try {
      final response = await http.get(
        url,
        headers: {
          ...ApiConstants.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => AccountModel.fromJson(json)).toList();
      } else {
        throw Exception(
          _parseBackendError(response, 'Fallo al cargar cuentas'),
        );
      }
    } on SocketException {
      throw Exception('No es posible conectarse al servidor en estos momentos');
    } on http.ClientException {
      throw Exception('No es posible conectarse al servidor en estos momentos');
    }
  }

  Future<void> createAccount({
    required String tipoCuenta,
    required double saldoCuenta,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.accounts}');

    try {
      final response = await http.post(
        url,
        headers: {
          ...ApiConstants.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'tipo_cuenta': tipoCuenta,
          'saldo_cuenta': saldoCuenta,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception(_parseBackendError(response, 'Fallo al crear cuenta'));
      }
    } on SocketException {
      throw Exception('No es posible conectarse al servidor en estos momentos');
    } on http.ClientException {
      throw Exception('No es posible conectarse al servidor en estos momentos');
    }
  }


  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final date = DateTime.parse(isoString).toLocal();
      const weekdays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
      const months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
      
      final weekday = weekdays[date.weekday - 1];
      final month = months[date.month - 1];
      return '$weekday, ${date.day} de $month ${date.year}';
    } catch (_) {
      return isoString; // fallback
    }
  }

  TransactionType _parseTransactionType(String? type) {

    switch (type) {
      case 'purchase':
        return TransactionType.purchase;
      case 'deposit':
        return TransactionType.deposit;
      case 'subscription':
        return TransactionType.subscription;
      case 'transfer':
      default:
        return TransactionType.transfer;
    }
  }
}
