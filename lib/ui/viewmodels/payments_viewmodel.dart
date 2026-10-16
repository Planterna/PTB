import 'package:flutter/foundation.dart';
import '../../data/datasources/remote/remote_finance_datasource.dart';
import '../../data/models/account_model.dart';
import '../../data/models/transfer_result_model.dart';
import '../../data/models/verified_account_model.dart';
import '../../data/repositories/finance_repository.dart';

class PaymentsViewModel extends ChangeNotifier {
  final FinanceRepository _repository;

  PaymentsViewModel({FinanceRepository? repository})
      : _repository = repository ?? FinanceRepository(RemoteFinanceDataSource());

  // 0: Validar cuenta | 1: Ingresar monto y transferir
  int _currentStep = 0;
  int get currentStep => _currentStep;

  // Paso 1: Selección y Validación
  String _accountNumber = '';
  String get accountNumber => _accountNumber;

  bool _isSameBank = true;
  bool get isSameBank => _isSameBank;

  String _selectedOtherBank = 'Banco Pichincha';
  String get selectedOtherBank => _selectedOtherBank;

  String _selectedAccountType = 'Ahorros';
  String get selectedAccountType => _selectedAccountType;

  bool _isVerifying = false;
  bool get isVerifying => _isVerifying;

  String? _accountError;
  String? get accountError => _accountError;

  VerifiedAccount? _verifiedAccount;
  VerifiedAccount? get verifiedAccount => _verifiedAccount;

  final List<String> otherBanks = const [
    'Banco Pichincha',
    'Banco Guayaquil',
    'Produbanco',
    'Banco del Pacífico',
    'Banco Bolivariano',
    'Cooperativa JEP',
  ];

  // Paso 2: Pago
  int _selectedOriginIndex = 0;
  int get selectedOriginIndex => _selectedOriginIndex;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  TransferResult? _lastTransferResult;
  TransferResult? get lastTransferResult => _lastTransferResult;

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void setSameBank(bool same) {
    _isSameBank = same;
    _verifiedAccount = null;
    _accountError = null;
    notifyListeners();
  }

  void setSelectedOtherBank(String bank) {
    _selectedOtherBank = bank;
    _verifiedAccount = null;
    _accountError = null;
    notifyListeners();
  }

  void setSelectedAccountType(String type) {
    _selectedAccountType = type;
    _verifiedAccount = null;
    _accountError = null;
    notifyListeners();
  }

  void setSelectedOriginIndex(int index) {
    _selectedOriginIndex = index;
    notifyListeners();
  }

  void onAccountNumberChanged(String value) {
    _accountNumber = value.trim();
    _accountError = null;
    if (_verifiedAccount != null && _verifiedAccount!.accountNumber != _accountNumber) {
      _verifiedAccount = null;
    }
    notifyListeners();
  }

  Future<bool> verifyAccount(String inputNumber) async {
    final acc = inputNumber.trim();
    _accountNumber = acc;

    if (acc.length != 10 || !RegExp(r'^\d{10}$').hasMatch(acc)) {
      _accountError = 'El número debe tener exactamente 10 dígitos numéricos.';
      _verifiedAccount = null;
      notifyListeners();
      return false;
    }

    _isVerifying = true;
    _accountError = null;
    notifyListeners();

    try {
      if (_isSameBank) {
        // Consultar al backend real (/api/cuentas/validar)
        final account = await _repository.validateAccount(acc);
        _verifiedAccount = account;
      } else {
        // Consultar al backend real (/api/cuentas/validar-interbancaria)
        final account = await _repository.validateInterbankAccount(
          acc,
          bank: _selectedOtherBank,
        );
        _verifiedAccount = account;
      }
      _isVerifying = false;
      _accountError = null;
      notifyListeners();
      return true;
    } catch (e) {
      _isVerifying = false;
      _accountError = e.toString().replaceAll('Exception: ', '');
      _verifiedAccount = null;
      notifyListeners();
      return false;
    }
  }

  Future<bool> applyQuickAccount(
    String number,
    bool sameBank,
    String bank,
    String type,
  ) async {
    _accountNumber = number;
    _isSameBank = sameBank;
    if (!sameBank) _selectedOtherBank = bank;
    _selectedAccountType = type;
    _accountError = null;
    notifyListeners();
    return await verifyAccount(number);
  }

  static const double interbankFee = 0.45;
  double get currentFee => _isSameBank ? 0.0 : interbankFee;

  String? validatePaymentAmount(double? amount, List<AccountModel> accounts) {
    if (amount == null || amount <= 0) {
      return 'Ingresa un monto válido mayor a \$0.00';
    }

    final totalRequired = amount + currentFee;
    if (accounts.isNotEmpty && _selectedOriginIndex < accounts.length) {
      final origin = accounts[_selectedOriginIndex];
      if (totalRequired > origin.saldoCuenta) {
        if (_isSameBank) {
          return 'Saldo insuficiente en tu cuenta de origen';
        } else {
          return 'Saldo insuficiente. Requiere \$${amount.toStringAsFixed(2)} + \$${interbankFee.toStringAsFixed(2)} comisión = \$${totalRequired.toStringAsFixed(2)}. Saldo: \$${origin.saldoCuenta.toStringAsFixed(2)}';
        }
      }
    }
    return null;
  }

  Future<String?> executePayment({
    required String cuentaOrigen,
    required double monto,
    String? descripcion,
  }) async {
    if (_verifiedAccount == null) {
      _errorMessage = 'Debes validar una cuenta de destino primero.';
      notifyListeners();
      return null;
    }

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final TransferResult result;
      if (_isSameBank) {
        result = await _repository.transfer(
          cuentaOrigen: cuentaOrigen,
          cuentaDestino: _verifiedAccount!.accountNumber,
          monto: monto,
          descripcion: descripcion,
        );
      } else {
        result = await _repository.transferInterbank(
          cuentaOrigen: cuentaOrigen,
          cuentaDestino: _verifiedAccount!.accountNumber,
          banco: _verifiedAccount!.bankName,
          monto: monto,
          descripcion: descripcion,
        );
      }

      _lastTransferResult = result;
      _isProcessing = false;
      notifyListeners();
      return result.referencia;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  void resetFlow() {
    _currentStep = 0;
    _verifiedAccount = null;
    _accountNumber = '';
    _accountError = null;
    _errorMessage = null;
    _lastTransferResult = null;
    notifyListeners();
  }
}
