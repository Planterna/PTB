import 'package:flutter_test/flutter_test.dart';
import 'package:prestige_trust_bank/data/datasources/remote/remote_finance_datasource.dart';
import 'package:prestige_trust_bank/data/models/account_model.dart';
import 'package:prestige_trust_bank/data/models/current_account_request_model.dart';
import 'package:prestige_trust_bank/data/repositories/finance_repository.dart';
import 'package:prestige_trust_bank/ui/viewmodels/create_current_account_viewmodel.dart';

class FakeFinanceDataSourceForCurrentAccount extends RemoteFinanceDataSource {
  @override
  Future<CurrentAccountResponseModel> createCurrentAccount(
    CurrentAccountRequestModel request,
  ) async {
    if (request.metodoPago == 'DEBITO_AHORROS') {
      return CurrentAccountResponseModel(
        exito: true,
        mensaje: 'Cuenta corriente creada exitosamente con débito de \$350.00',
        metodoPago: 'DEBITO_AHORROS',
        estado: 'APROBADA',
        cuenta: {
          'id_cuenta': 'acc-corr-1',
          'numero_cuenta': '2001234567',
          'saldo_cuenta': 350.0,
          'tipo_cuenta': 'Corriente',
        },
        solicitud: {
          'id_solicitud': 'sol-123',
          'estado': 'APROBADA',
          'metodo_pago': 'DEBITO_AHORROS',
          'monto_apertura': 350.0,
        },
      );
    } else {
      return CurrentAccountResponseModel(
        exito: true,
        mensaje: 'Solicitud registrada. Acércate a ventanilla para pagar \$350.00 y activar tu cuenta corriente.',
        metodoPago: 'PAGO_VENTANILLA',
        estado: 'PENDIENTE_VENTANILLA',
        cuenta: null,
        solicitud: {
          'id_solicitud': 'sol-456',
          'estado': 'PENDIENTE_VENTANILLA',
          'metodo_pago': 'PAGO_VENTANILLA',
          'monto_apertura': 350.0,
        },
      );
    }
  }
}

void main() {
  group('CreateCurrentAccountViewModel Tests', () {
    late FakeFinanceDataSourceForCurrentAccount fakeDataSource;
    late FinanceRepository repository;

    final lowBalanceSavings = AccountModel(
      idCuenta: 'acc-1',
      idUsuario: 'user-1',
      numeroCuenta: '1001111111',
      tipoCuenta: 'ahorros',
      saldoCuenta: 150.0,
    );

    final sufficientBalanceSavings = AccountModel(
      idCuenta: 'acc-2',
      idUsuario: 'user-1',
      numeroCuenta: '1002222222',
      tipoCuenta: 'ahorros',
      saldoCuenta: 500.0,
    );

    setUp(() {
      fakeDataSource = FakeFinanceDataSourceForCurrentAccount();
      repository = FinanceRepository(fakeDataSource);
    });

    test('Initial state has default form values and step 0', () {
      final vm = CreateCurrentAccountViewModel(
        repository: repository,
        userAccounts: [sufficientBalanceSavings],
        defaultOwnerName: 'Juan Pérez',
      );

      expect(vm.currentStep, 0);
      expect(vm.tieneResidenciaUsa, false);
      expect(vm.declaraImpuestosOtroPais, false);
      expect(vm.modeloChequera, 'Institucional');
      expect(vm.numeroCheques, 20);
      expect(vm.tipoChequera, 'Con talón');
      expect(vm.nombreEnDocumentos, 'Juan Pérez');
      expect(CreateCurrentAccountViewModel.requiredAmount, 350.0);
      expect(vm.savingsAccount?.idCuenta, 'acc-2');
      expect(vm.hasSufficientSavings, true);
    });

    test('Insufficient savings balance detects hasSufficientSavings is false', () {
      final vm = CreateCurrentAccountViewModel(
        repository: repository,
        userAccounts: [lowBalanceSavings],
        defaultOwnerName: 'Juan Pérez',
      );

      expect(vm.hasSufficientSavings, false);
      expect(vm.savingsAccount?.saldoCuenta, 150.0);
    });

    test('Step navigation functions correctly', () {
      final vm = CreateCurrentAccountViewModel(
        repository: repository,
        userAccounts: [sufficientBalanceSavings],
        defaultOwnerName: 'Juan Pérez',
      );

      expect(vm.currentStep, 0);
      vm.nextStep();
      expect(vm.currentStep, 1);
      vm.nextStep();
      expect(vm.currentStep, 2);
      vm.prevStep();
      expect(vm.currentStep, 1);
    });

    test('Submit with DEBITO_AHORROS creates account directly', () async {
      final vm = CreateCurrentAccountViewModel(
        repository: repository,
        userAccounts: [sufficientBalanceSavings],
        defaultOwnerName: 'Juan Pérez',
      );

      vm.setMetodoPago('DEBITO_AHORROS');
      final success = await vm.submitRequest();

      expect(success, true);
      expect(vm.responseResult, isNotNull);
      expect(vm.responseResult?.cuenta?['numero_cuenta'], '2001234567');
      expect(vm.responseResult?.cuenta?['saldo_cuenta'], 350.0);
      expect(vm.errorMessage, isNull);
    });

    test('Submit with PAGO_VENTANILLA indicates branch visit required without account yet', () async {
      final vm = CreateCurrentAccountViewModel(
        repository: repository,
        userAccounts: [lowBalanceSavings],
        defaultOwnerName: 'Juan Pérez',
      );

      vm.setMetodoPago('PAGO_VENTANILLA');
      final success = await vm.submitRequest();

      expect(success, true);
      expect(vm.responseResult, isNotNull);
      expect(vm.responseResult?.cuenta, isNull);
      expect(vm.responseResult?.solicitud?['estado'], 'PENDIENTE_VENTANILLA');
      expect(vm.errorMessage, isNull);
    });
  });
}
