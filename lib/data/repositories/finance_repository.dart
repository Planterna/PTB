import '../datasources/remote/remote_finance_datasource.dart';
import '../models/card_model.dart';
import '../models/transaction_model.dart';
import '../models/account_model.dart';
import '../models/verified_account_model.dart';
import '../models/transfer_result_model.dart';

class FinanceRepository {
  final RemoteFinanceDataSource _remoteDataSource;

  FinanceRepository(this._remoteDataSource);

  Future<List<CardModel>> getUserCards(String userId) {
    return _remoteDataSource.getCardsForUser(userId);
  }

  Future<List<TransactionModel>> getUserTransactions(String userId) {
    return _remoteDataSource.getTransactionsForUser(userId);
  }

  Future<List<AccountModel>> getUserAccounts(String userId) {
    return _remoteDataSource.getAccountsForUser(userId);
  }

  Future<void> createCard({
    required String idCuenta,
    required String cardName,
    required String tipoTarjeta,
  }) {
    return _remoteDataSource.createCard(
      idCuenta: idCuenta,
      cardName: cardName,
      tipoTarjeta: tipoTarjeta,
    );
  }

  Future<void> createAccount({
    required String tipoCuenta,
    required double saldoCuenta,
  }) {
    return _remoteDataSource.createAccount(
      tipoCuenta: tipoCuenta,
      saldoCuenta: saldoCuenta,
    );
  }

  Future<VerifiedAccount> validateAccount(String accountNumber) {
    return _remoteDataSource.validateAccount(accountNumber);
  }

  Future<TransferResult> transfer({
    required String cuentaOrigen,
    required String cuentaDestino,
    required double monto,
    String? descripcion,
  }) {
    return _remoteDataSource.transfer(
      cuentaOrigen: cuentaOrigen,
      cuentaDestino: cuentaDestino,
      monto: monto,
      descripcion: descripcion,
    );
  }
}
