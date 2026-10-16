import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../models/card_model.dart';
import '../../models/transaction_model.dart';
import '../../models/account_model.dart';
import '../../models/verified_account_model.dart';
import '../../models/transfer_result_model.dart';
import '../../models/current_account_request_model.dart';

class RemoteFinanceDataSource {
  final ApiClient _apiClient;

  RemoteFinanceDataSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<CardModel>> getCardsForUser(String userId) async {
    final dynamic data = await _apiClient.get(ApiConstants.cards);
    if (data is List) {
      return data
          .map(
            (json) => CardModel(
              id: json['id_tarjeta']?.toString() ?? '',
              idCuenta: json['id_cuenta']?.toString() ?? '',
              cardName: json['nombre_tarjeta']?.toString() ?? '',
              cardNumber: json['numero_tarjeta']?.toString() ?? '',
              tipoTarjeta: json['tipo_tarjeta']?.toString() ?? '',
            ),
          )
          .toList();
    }
    return [];
  }

  Future<void> createCard({
    required String idCuenta,
    required String cardName,
    required String tipoTarjeta,
  }) async {
    await _apiClient.post(
      ApiConstants.cards,
      body: {
        'id_cuenta': idCuenta,
        'nombre_tarjeta': cardName,
        'tipo_tarjeta': tipoTarjeta,
      },
    );
  }

  Future<List<TransactionModel>> getTransactionsForUser(String userId) async {
    final dynamic data = await _apiClient.get(ApiConstants.transactions);
    if (data is List) {
      return data
          .map(
            (json) => TransactionModel(
              id: json['id_movimiento']?.toString() ?? '',
              name: json['nombre_movimiento']?.toString() ?? '',
              value: (json['valor_movimiento'] ?? 0.0).toDouble(),
              date: _formatDate(json['fecha_movimiento']?.toString()),
              type: _parseTransactionType(json['tipo_movimiento']?.toString()),
            ),
          )
          .toList();
    }
    return [];
  }

  Future<List<AccountModel>> getAccountsForUser(String userId) async {
    final dynamic data = await _apiClient.get(ApiConstants.accounts);
    if (data is List) {
      return data
          .map((json) => AccountModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> createAccount({
    required String tipoCuenta,
    required double saldoCuenta,
  }) async {
    await _apiClient.post(
      ApiConstants.accounts,
      body: {
        'tipo_cuenta': tipoCuenta,
        'saldo_cuenta': saldoCuenta,
      },
    );
  }

  Future<CurrentAccountResponseModel> createCurrentAccount(
    CurrentAccountRequestModel request,
  ) async {
    final dynamic data = await _apiClient.post(
      ApiConstants.currentAccount,
      body: request.toJson(),
    );

    if (data is Map<String, dynamic>) {
      return CurrentAccountResponseModel.fromJson(data);
    }
    throw Exception('Respuesta inválida al procesar la solicitud de cuenta corriente');
  }

  Future<VerifiedAccount> validateAccount(String accountNumber) async {
    final dynamic data = await _apiClient.post(
      ApiConstants.validateAccount,
      body: {'numero_cuenta': accountNumber.trim()},
    );

    if (data is Map<String, dynamic>) {
      return VerifiedAccount.fromJson(data);
    }
    throw Exception('Respuesta inválida al validar cuenta');
  }

  Future<VerifiedAccount> validateInterbankAccount(
    String accountNumber, {
    String? bank,
  }) async {
    final dynamic data = await _apiClient.post(
      ApiConstants.validateInterbankAccount,
      body: {
        'numero_cuenta': accountNumber.trim(),
        if (bank != null && bank.isNotEmpty) 'banco': bank.trim(),
      },
    );

    if (data is Map<String, dynamic>) {
      return VerifiedAccount.fromJson(data);
    }
    throw Exception('Respuesta inválida al validar cuenta interbancaria');
  }

  Future<TransferResult> transfer({
    required String cuentaOrigen,
    required String cuentaDestino,
    required double monto,
    String? descripcion,
  }) async {
    final dynamic data = await _apiClient.post(
      ApiConstants.transfer,
      body: {
        'cuenta_origen': cuentaOrigen.trim(),
        'cuenta_destino': cuentaDestino.trim(),
        'monto': monto,
        if (descripcion != null && descripcion.isNotEmpty)
          'descripcion': descripcion.trim(),
      },
    );

    if (data is Map<String, dynamic>) {
      return TransferResult.fromJson(data);
    }
    throw Exception('Respuesta inválida al procesar la transferencia');
  }

  Future<TransferResult> transferInterbank({
    required String cuentaOrigen,
    required String cuentaDestino,
    required double monto,
    String? banco,
    String? descripcion,
  }) async {
    final dynamic data = await _apiClient.post(
      ApiConstants.transferInterbank,
      body: {
        'cuenta_origen': cuentaOrigen.trim(),
        'numero_cuenta_destino': cuentaDestino.trim(),
        'monto': monto,
        if (banco != null && banco.isNotEmpty) 'nombre_banco': banco.trim(),
        if (descripcion != null && descripcion.isNotEmpty)
          'descripcion': descripcion.trim(),
      },
    );

    if (data is Map<String, dynamic>) {
      return TransferResult.fromJson(data);
    }
    throw Exception('Respuesta inválida al procesar la transferencia interbancaria');
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
      return isoString;
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
