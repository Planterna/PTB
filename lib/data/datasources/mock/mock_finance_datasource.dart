import '../../models/card_model.dart';
import '../../models/transaction_model.dart';

class MockFinanceDataSource {
  static final Map<String, List<CardModel>> _userCards = {
    'loisbecket@gmail.com': [
      CardModel(
        id: 'c1',
        idCuenta: 'acc1',
        cardName: 'Prestige Visa',
        cardNumber: '**** 4022',
        tipoTarjeta: 'debito',
      ),
      CardModel(
        id: 'c2',
        idCuenta: 'acc1',
        cardName: 'Prestige Mastercard',
        cardNumber: '**** 8831',
        tipoTarjeta: 'credito',
      ),
    ],
  };

  static final Map<String, List<dynamic>> _userAccounts = {
    'loisbecket@gmail.com': [
      {
        'id_cuenta': 'acc1',
        'id_usuario': 'u1',
        'tipo_cuenta': 'ahorro',
        'numero_cuenta': '**** 1122',
        'saldo_cuenta': 25000.00,
      },
      {
        'id_cuenta': 'acc2',
        'id_usuario': 'u1',
        'tipo_cuenta': 'corriente',
        'numero_cuenta': '**** 3344',
        'saldo_cuenta': 8500.25,
      },
    ],
  };

  static final Map<String, List<TransactionModel>> _userTransactions = {
    'loisbecket@gmail.com': [
      TransactionModel(
        id: 't1',
        name: 'Transferencia a Juan',
        value: -150.00,
        date: 'Hoy',
        type: TransactionType.transfer,
      ),
      TransactionModel(
        id: 't2',
        name: 'Amazon.com',
        value: -45.99,
        date: 'Ayer',
        type: TransactionType.purchase,
      ),
      TransactionModel(
        id: 't3',
        name: 'Netflix',
        value: -15.99,
        date: 'Ayer',
        type: TransactionType.subscription,
      ),
      TransactionModel(
        id: 't4',
        name: 'Depósito Nómina',
        value: 2500.00,
        date: 'Hace 3 días',
        type: TransactionType.deposit,
      ),
    ],
  };

  Future<List<CardModel>> getCardsForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _userCards[userId] ??
        [
          CardModel(
            id: 'default_card',
            idCuenta: 'default_acc',
            cardName: 'Tarjeta Básica',
            cardNumber: '**** 0000',
            tipoTarjeta: "debito",
          ),
        ];
  }

  Future<List<TransactionModel>> getTransactionsForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _userTransactions[userId] ?? [];
  }

  Future<List<dynamic>> getAccountsForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _userAccounts[userId] ?? [];
  }
}
