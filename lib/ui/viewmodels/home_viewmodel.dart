import 'package:flutter/foundation.dart';
import '../../data/models/card_model.dart';
import '../../data/models/transaction_model.dart';
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

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

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

      final results = await Future.wait([cardsFuture, transactionsFuture]);
      
      _cards = results[0] as List<CardModel>;
      _transactions = results[1] as List<TransactionModel>;
    } catch (e) {
      _errorMessage = 'Error loading data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
