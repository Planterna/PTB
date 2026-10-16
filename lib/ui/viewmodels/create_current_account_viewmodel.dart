import 'package:flutter/foundation.dart';
import '../../data/models/account_model.dart';
import '../../data/models/current_account_request_model.dart';
import '../../data/repositories/finance_repository.dart';

class CreateCurrentAccountViewModel extends ChangeNotifier {
  final FinanceRepository repository;
  final List<AccountModel> userAccounts;
  final String defaultOwnerName;

  int _currentStep = 0;
  int get currentStep => _currentStep;

  // Paso 1: Información migratoria y fiscal (s1.jpeg)
  bool _tieneResidenciaUsa = false;
  bool get tieneResidenciaUsa => _tieneResidenciaUsa;

  bool _declaraImpuestosOtroPais = false;
  bool get declaraImpuestosOtroPais => _declaraImpuestosOtroPais;

  // Paso 2: Chequera y Tarjeta (s.jpeg)
  String _modeloChequera = 'Institucional';
  String get modeloChequera => _modeloChequera;

  int _numeroCheques = 20;
  int get numeroCheques => _numeroCheques;

  String _tipoChequera = 'Con talón';
  String get tipoChequera => _tipoChequera;

  late String _nombreEnDocumentos;
  String get nombreEnDocumentos => _nombreEnDocumentos;

  String _agenciaRetiro = 'Agencia Principal - Centro';
  String get agenciaRetiro => _agenciaRetiro;

  // Paso 3: Método de pago ($350.00)
  String _metodoPago = 'DEBITO_AHORROS'; // 'DEBITO_AHORROS' | 'PAGO_VENTANILLA'
  String get metodoPago => _metodoPago;

  static const double requiredAmount = 350.0;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CurrentAccountResponseModel? _responseResult;
  CurrentAccountResponseModel? get responseResult => _responseResult;

  final List<String> availableAgencies = const [
    'Agencia Principal - Centro',
    'Agencia Mall del Sol',
    'Agencia San Marino Shopping',
    'Agencia Quito Norte - Naciones Unidas',
    'Agencia C.C. El Recreo',
    'Agencia Cuenca Centro',
  ];

  CreateCurrentAccountViewModel({
    required this.repository,
    required this.userAccounts,
    required this.defaultOwnerName,
  }) : _nombreEnDocumentos = defaultOwnerName;

  AccountModel? get savingsAccount {
    try {
      return userAccounts.firstWhere(
        (a) => a.tipoCuenta.toLowerCase().contains('ahorro'),
      );
    } catch (_) {
      return null;
    }
  }

  bool get hasSufficientSavings {
    final acc = savingsAccount;
    if (acc == null) return false;
    return acc.saldoCuenta >= requiredAmount;
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 2) {
      _currentStep++;
      notifyListeners();
    }
  }

  void prevStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void setTieneResidenciaUsa(bool val) {
    _tieneResidenciaUsa = val;
    notifyListeners();
  }

  void setDeclaraImpuestosOtroPais(bool val) {
    _declaraImpuestosOtroPais = val;
    notifyListeners();
  }

  void setModeloChequera(String val) {
    _modeloChequera = val;
    notifyListeners();
  }

  void setNumeroCheques(int val) {
    _numeroCheques = val;
    notifyListeners();
  }

  void setTipoChequera(String val) {
    _tipoChequera = val;
    notifyListeners();
  }

  void setNombreEnDocumentos(String val) {
    _nombreEnDocumentos = val;
    notifyListeners();
  }

  void setAgenciaRetiro(String val) {
    _agenciaRetiro = val;
    notifyListeners();
  }

  void setMetodoPago(String val) {
    _metodoPago = val;
    notifyListeners();
  }

  Future<bool> submitRequest() async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final originAccount = savingsAccount;

      final request = CurrentAccountRequestModel(
        tieneResidenciaUsa: _tieneResidenciaUsa,
        declaraImpuestosOtroPais: _declaraImpuestosOtroPais,
        modeloChequera: _modeloChequera,
        numeroCheques: _numeroCheques,
        tipoChequera: _tipoChequera,
        nombreEnDocumentos: _nombreEnDocumentos.trim().isNotEmpty
            ? _nombreEnDocumentos.trim()
            : defaultOwnerName,
        agenciaRetiro: _agenciaRetiro,
        metodoPago: _metodoPago,
        idCuentaOrigen: originAccount?.idCuenta,
        numeroCuentaOrigen: originAccount?.numeroCuenta,
      );

      final result = await repository.createCurrentAccount(request);
      _responseResult = result;
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
