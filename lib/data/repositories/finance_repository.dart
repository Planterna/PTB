import '../datasources/mock/mock_finance_datasource.dart';
import '../models/card_model.dart';
import '../models/transaction_model.dart';

class FinanceRepository {
  final MockFinanceDataSource _dataSource;

  FinanceRepository(this._dataSource);

  Future<List<CardModel>> getUserCards(String userId) {
    return _dataSource.getCardsForUser(userId);
  }

  Future<List<TransactionModel>> getUserTransactions(String userId) {
    return _dataSource.getTransactionsForUser(userId);
  }
}
