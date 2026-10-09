import 'package:flutter/foundation.dart';

import '../../data/models/card_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/account_model.dart';
import '../../data/repositories/finance_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final FinanceRepository _repository;
  final String userId;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CardModel> _cards = [];
  List<CardModel> get cards => _cards;

  List<AccountModel> _accounts = [];
  List<AccountModel> get accounts => _accounts;

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  // Filtro de transacciones
  String _filterValue = 'Todos';
  String get filterValue => _filterValue;

  List<TransactionModel> get filteredTransactions {
    return _transactions.where((t) {
      if (_filterValue == 'Ingresos') return t.value >= 0;
      if (_filterValue == 'Egresos') return t.value < 0;
      return true;
    }).toList();
  }

  void setFilter(String value) {
    _filterValue = value;
    notifyListeners();
  }

  HomeViewModel({required FinanceRepository repository, required this.userId})
    : _repository = repository {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cardsFuture = _repository.getUserCards(userId);
      final transactionsFuture = _repository.getUserTransactions(userId);
      final accountsFuture = _repository.getUserAccounts(userId);

      final results = await Future.wait([
        cardsFuture,
        transactionsFuture,
        accountsFuture,
      ]);

      _cards = results[0] as List<CardModel>;
      _transactions = results[1] as List<TransactionModel>;
      _accounts = results[2] as List<AccountModel>;
    } catch (e) {
      _errorMessage = 'Error al cargar datos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> requestCreditCard(String accountId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.createCard(
        idCuenta: accountId,
        cardName: 'Prestige Credit',
        tipoTarjeta: 'credito',
      );
      await loadData();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Fallo al solicitar tarjeta de crédito: $e';
    }
  }

  Future<String?> createAccount({required String tipoCuenta}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.createAccount(
        tipoCuenta: tipoCuenta, 
        saldoCuenta: 0.0, 
      );
      await loadData();
      return null; 
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Fallo al crear cuenta: $e';
    }
  }
}
