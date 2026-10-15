import 'package:flutter_test/flutter_test.dart';
import 'package:prestige_trust_bank/data/datasources/remote/remote_finance_datasource.dart';
import 'package:prestige_trust_bank/data/models/account_model.dart';
import 'package:prestige_trust_bank/data/models/transfer_result_model.dart';
import 'package:prestige_trust_bank/data/models/verified_account_model.dart';
import 'package:prestige_trust_bank/data/repositories/finance_repository.dart';
import 'package:prestige_trust_bank/ui/viewmodels/payments_viewmodel.dart';

class FakeRemoteFinanceDataSource extends RemoteFinanceDataSource {
  @override
  Future<VerifiedAccount> validateAccount(String accountNumber) async {
    if (accountNumber == '1002345678') {
      return const VerifiedAccount(
        accountNumber: '1002345678',
        ownerName: 'Carlos Andrés Mendoza',
        identification: '1723456789',
        bankName: 'Prestige Trust Bank',
        accountType: 'Ahorros',
      );
    }
    throw Exception('La cuenta no existe');
  }

  @override
  Future<TransferResult> transfer({
    required String cuentaOrigen,
    required String cuentaDestino,
    required double monto,
    String? descripcion,
  }) async {
    return TransferResult(
      referencia: 'PTB-1234567',
      mensaje: 'Transferencia realizada exitosamente',
      cuentaOrigen: cuentaOrigen,
      cuentaDestino: cuentaDestino,
      titularOrigen: 'Emisor',
      titularDestino: 'Carlos Andrés Mendoza',
      monto: monto,
      descripcion: descripcion,
    );
  }
}

void main() {
  group('PaymentsViewModel Tests', () {
    late PaymentsViewModel viewModel;

    setUp(() {
      viewModel = PaymentsViewModel(
        repository: FinanceRepository(FakeRemoteFinanceDataSource()),
      );
    });

    test('Initial state is correct', () {
      expect(viewModel.currentStep, 0);
      expect(viewModel.isSameBank, true);
      expect(viewModel.selectedAccountType, 'Ahorros');
      expect(viewModel.verifiedAccount, isNull);
    });

    test('verifyAccount fails with invalid account length', () async {
      final success = await viewModel.verifyAccount('12345');
      expect(success, false);
      expect(viewModel.accountError, isNotNull);
      expect(viewModel.verifiedAccount, isNull);
    });

    test('verifyAccount succeeds with valid 10 digits account', () async {
      final success = await viewModel.verifyAccount('1002345678');
      expect(success, true);
      expect(viewModel.accountError, isNull);
      expect(viewModel.verifiedAccount, isNotNull);
      expect(viewModel.verifiedAccount!.ownerName, 'Carlos Andrés Mendoza');
    });

    test('validatePaymentAmount validates zero, negative or insufficient funds', () {
      final testAccount = AccountModel(
        idCuenta: '1',
        idUsuario: '1',
        tipoCuenta: 'ahorro',
        numeroCuenta: '1002345678',
        saldoCuenta: 100.0,
      );

      // Null or 0
      expect(viewModel.validatePaymentAmount(0, [testAccount]), isNotNull);
      expect(viewModel.validatePaymentAmount(-5, [testAccount]), isNotNull);

      // Exceeds balance
      expect(viewModel.validatePaymentAmount(150, [testAccount]), isNotNull);

      // Valid amount
      expect(viewModel.validatePaymentAmount(50, [testAccount]), isNull);
    });

    test('executePayment generates transaction reference code', () async {
      await viewModel.verifyAccount('1002345678');
      final ref = await viewModel.executePayment(
        cuentaOrigen: '1001111111',
        monto: 25.0,
        descripcion: 'Pago almuerzo',
      );
      expect(ref, isNotNull);
      expect(ref!.startsWith('PTB-'), true);
      expect(viewModel.isProcessing, false);
      expect(viewModel.lastTransferResult, isNotNull);
      expect(viewModel.lastTransferResult!.referencia, equals('PTB-1234567'));
    });

    test('resetFlow resets step and verification state', () async {
      await viewModel.verifyAccount('1002345678');
      viewModel.setStep(1);
      expect(viewModel.currentStep, 1);
      expect(viewModel.verifiedAccount, isNotNull);

      viewModel.resetFlow();
      expect(viewModel.currentStep, 0);
      expect(viewModel.verifiedAccount, isNull);
    });
  });
}
