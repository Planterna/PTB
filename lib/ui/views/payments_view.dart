import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../core/constants/app_colors.dart';
import '../../core/helpers/notification_helper.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/payments_viewmodel.dart';

class PaymentsView extends StatefulWidget {
  final HomeViewModel viewModel;

  const PaymentsView({super.key, required this.viewModel});

  @override
  State<PaymentsView> createState() => _PaymentsViewState();
}

class _PaymentsViewState extends State<PaymentsView> {
  late PaymentsViewModel _paymentsViewModel;

  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _conceptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _paymentsViewModel = PaymentsViewModel();
  }

  @override
  void dispose() {
    _paymentsViewModel.dispose();
    _accountController.dispose();
    _amountController.dispose();
    _conceptController.dispose();
    super.dispose();
  }

  Future<void> _verifyAccount() async {
    FocusScope.of(context).unfocus();
    final success = await _paymentsViewModel.verifyAccount(_accountController.text);
    if (!mounted) return;

    if (success) {
      NotificationHelper.show(
        context,
        message: 'Cuenta validada: ${_paymentsViewModel.verifiedAccount?.ownerName}',
        type: NotificationType.success,
      );
    } else {
      NotificationHelper.show(
        context,
        message: _paymentsViewModel.accountError ?? 'Ingresa un número de cuenta válido de 10 dígitos',
        type: NotificationType.danger,
      );
    }
  }

  Future<void> _applyQuickAccount(String number, bool sameBank, String bank, String type) async {
    _accountController.text = number;
    final success = await _paymentsViewModel.applyQuickAccount(number, sameBank, bank, type);
    if (!mounted) return;

    if (success) {
      NotificationHelper.show(
        context,
        message: 'Cuenta validada: ${_paymentsViewModel.verifiedAccount?.ownerName}',
        type: NotificationType.success,
      );
    }
  }

  void _executePayment() async {
    final amountText = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(amountText);

    final error = _paymentsViewModel.validatePaymentAmount(
      amount,
      widget.viewModel.accounts,
    );

    if (error != null) {
      NotificationHelper.show(
        context,
        message: error,
        type: NotificationType.danger,
      );
      return;
    }

    final concept = _conceptController.text.trim().isNotEmpty
        ? _conceptController.text.trim()
        : 'Transferencia bancaria';

    if (widget.viewModel.accounts.isEmpty) {
      NotificationHelper.show(
        context,
        message: 'No tienes cuentas de origen disponibles para transferir',
        type: NotificationType.danger,
      );
      return;
    }

    final originAccount =
        widget.viewModel.accounts[_paymentsViewModel.selectedOriginIndex];

    final ref = await _paymentsViewModel.executePayment(
      cuentaOrigen: originAccount.numeroCuenta,
      monto: amount!,
      descripcion: concept,
    );
    if (!mounted) return;

    if (ref != null) {
      _showReceiptDialog(amount, concept, ref);
      widget.viewModel.loadData();
    } else {
      NotificationHelper.show(
        context,
        message: _paymentsViewModel.errorMessage ??
            'Error al procesar la transferencia',
        type: NotificationType.danger,
      );
    }
  }

  void _showReceiptDialog(double amount, String concept, String ref) {
    final account = _paymentsViewModel.verifiedAccount;
    if (account == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          content: <Widget>[
            const Icon(Icons.check, color: AppColors.accent, size: 36)
                .padding(all: 12)
                .decorated(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
            const SizedBox(height: 12),
            const Text('Transferencia Exitosa')
                .textColor(AppColors.textPrimary)
                .fontSize(18)
                .bold(),
            const SizedBox(height: 4),
            Text('Ref: $ref')
                .textColor(AppColors.textMuted)
                .fontSize(12),
            const SizedBox(height: 16),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: AppTheme.amountStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 16),
            <Widget>[
              _receiptRow('Beneficiario', account.ownerName, isBold: true),
              _receiptRow('Banco', account.bankName),
              _receiptRow('Cuenta', account.accountNumber),
              _receiptRow('Motivo', concept),
            ]
                .toColumn()
                .padding(all: 12)
                .decorated(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
          ].toColumn(mainAxisSize: MainAxisSize.min),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _paymentsViewModel.resetFlow();
                _accountController.clear();
                _amountController.clear();
                _conceptController.clear();
              },
              child: const Text('Realizar otra transferencia'),
            ),
          ],
        );
      },
    );

    NotificationHelper.show(
      context,
      message: 'Transferencia por \$${amount.toStringAsFixed(2)} aprobada',
      type: NotificationType.success,
    );
  }

  Widget _receiptRow(String label, String value, {bool isBold = false}) {
    return <Widget>[
      Text(label).textColor(AppColors.textMuted).fontSize(11),
      const SizedBox(width: 8),
      Text(
        value,
        overflow: TextOverflow.ellipsis,
      )
          .textColor(AppColors.textPrimary)
          .fontSize(12)
          .fontWeight(isBold ? FontWeight.bold : FontWeight.w500)
          .textAlignment(TextAlign.right)
          .flexible(),
    ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween).padding(vertical: 2.5);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: ListenableBuilder(
            listenable: _paymentsViewModel,
            builder: (context, _) {
              return AnimatedCrossFade(
                duration: const Duration(milliseconds: 220),
                crossFadeState: _paymentsViewModel.currentStep == 0
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: _buildStepValidation(),
                secondChild: _buildStepPayment(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStepValidation() {
    final hasTen = _accountController.text.trim().length == 10;
    final verified = _paymentsViewModel.verifiedAccount;

    return <Widget>[
      const Text('Transferencias')
          .textColor(AppColors.textPrimary)
          .fontSize(24)
          .bold(),
      const SizedBox(height: 4),
      const Text('Valida la cuenta antes de enviar dinero')
          .textColor(AppColors.textMuted)
          .fontSize(13),
      const SizedBox(height: 24),

      // 1. Selector de Banco
      <Widget>[
        _buildBankSegment(
          label: 'Prestige Bank',
          icon: Icons.account_balance,
          isSelected: _paymentsViewModel.isSameBank,
          onTap: () => _paymentsViewModel.setSameBank(true),
        ).expanded(),
        _buildBankSegment(
          label: 'Otro Banco',
          icon: Icons.public,
          isSelected: !_paymentsViewModel.isSameBank,
          onTap: () => _paymentsViewModel.setSameBank(false),
        ).expanded(),
      ]
          .toRow()
          .padding(all: 4)
          .decorated(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),

      if (!_paymentsViewModel.isSameBank) ...[
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _paymentsViewModel.selectedOtherBank,
          dropdownColor: AppColors.surface,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
          decoration: _cleanDecoration(hint: 'Banco destino', prefixIcon: Icons.account_balance),
          items: _paymentsViewModel.otherBanks.map((b) {
            return DropdownMenuItem(
              value: b,
              child: Text(b, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
            );
          }).toList(),
          onChanged: (b) {
            if (b != null) _paymentsViewModel.setSelectedOtherBank(b);
          },
        ),
      ],

      const SizedBox(height: 16),

      // 2. Tipo de Cuenta
      <Widget>[
        const Text('Tipo de cuenta:')
            .textColor(AppColors.textMuted)
            .fontSize(13)
            .fontWeight(FontWeight.w600),
        <Widget>[
          _buildTypeChip(
            'Ahorros',
            _paymentsViewModel.selectedAccountType == 'Ahorros',
            () => _paymentsViewModel.setSelectedAccountType('Ahorros'),
          ),
          _buildTypeChip(
            'Corriente',
            _paymentsViewModel.selectedAccountType == 'Corriente',
            () => _paymentsViewModel.setSelectedAccountType('Corriente'),
          ),
        ]
            .toRow(mainAxisSize: MainAxisSize.min)
            .padding(all: 3)
            .decorated(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
      ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween),

      const SizedBox(height: 16),

      // 3. Input de Cuenta
      TextFormField(
        controller: _accountController,
        keyboardType: TextInputType.number,
        maxLength: 10,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
        decoration: _cleanDecoration(
          hint: 'Número de cuenta (10 dígitos)',
          prefixIcon: Icons.tag,
          errorText: _paymentsViewModel.accountError,
          suffixIcon: hasTen
              ? const Icon(Icons.check_circle, color: AppColors.accent, size: 20)
              : null,
        ),
        onChanged: (text) => _paymentsViewModel.onAccountNumberChanged(text),
      ),

      const SizedBox(height: 14),

      // 4. Cuentas rápidas de prueba
      <Widget>[
        <Widget>[
          const Icon(Icons.flash_on, size: 14, color: AppColors.accent),
          const SizedBox(width: 4),
          const Text('Prueba rápida:')
              .textColor(AppColors.textMuted)
              .fontSize(11)
              .fontWeight(FontWeight.w500),
        ].toRow(),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: <Widget>[
            _buildQuickFilterPill('1002345678', 'Carlos M. (PTB)', true, 'Prestige Trust Bank', 'Ahorros'),
            const SizedBox(width: 8),
            _buildQuickFilterPill('1009876543', 'María R. (PTB)', true, 'Prestige Trust Bank', 'Corriente'),
            const SizedBox(width: 8),
            _buildQuickFilterPill('2204567891', 'Esteban M. (Pichincha)', false, 'Banco Pichincha', 'Ahorros'),
            const SizedBox(width: 8),
            _buildQuickFilterPill('2401234567', 'Diana V. (Guayaquil)', false, 'Banco Guayaquil', 'Ahorros'),
          ].toRow(),
        ),
      ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),

      const SizedBox(height: 24),

      // 5. Botón Validar Cuenta
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: hasTen ? AppColors.primary : AppColors.surfaceLight,
          foregroundColor: hasTen ? AppColors.background : AppColors.textMuted,
          minimumSize: const Size.fromHeight(50),
          elevation: hasTen ? 2 : 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: (hasTen && !_paymentsViewModel.isVerifying) ? _verifyAccount : null,
        child: _paymentsViewModel.isVerifying
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
              )
            : const Text('Validar Cuenta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ),

      // Resultado de validación
      if (verified != null) ...[
        const SizedBox(height: 20),
        <Widget>[
          <Widget>[
            const Icon(Icons.check_circle, color: AppColors.accent, size: 18),
            const SizedBox(width: 8),
            Text(verified.ownerName)
                .textColor(AppColors.textPrimary)
                .fontSize(15)
                .bold(),
          ].toRow(),
          const SizedBox(height: 4),
          Text('${verified.bankName} • ${verified.accountType} (${verified.accountNumber})')
              .textColor(AppColors.textMuted)
              .fontSize(12),
          const SizedBox(height: 14),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _paymentsViewModel.setStep(1),
            child: const Text('Continuar al Pago', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ]
            .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
            .padding(all: 16)
            .decorated(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
            ),
      ],
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  Widget _buildStepPayment() {
    final verified = _paymentsViewModel.verifiedAccount;
    if (verified == null) return const SizedBox.shrink();

    final accounts = widget.viewModel.accounts;

    return <Widget>[
      <Widget>[
        IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => _paymentsViewModel.setStep(0),
        ),
        const Text('Realizar Pago')
            .textColor(AppColors.textPrimary)
            .fontSize(20)
            .bold(),
      ].toRow(),
      const SizedBox(height: 12),

      // Destinatario
      <Widget>[
        const Icon(Icons.person, color: AppColors.accent, size: 18)
            .padding(all: 8)
            .decorated(
              color: AppColors.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
        const SizedBox(width: 12),
        <Widget>[
          Text(verified.ownerName)
              .textColor(AppColors.textPrimary)
              .fontSize(14)
              .bold(),
          Text('${verified.bankName} • N° ${verified.accountNumber}')
              .textColor(AppColors.textMuted)
              .fontSize(12),
        ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).expanded(),
      ]
          .toRow()
          .padding(horizontal: 14, vertical: 12)
          .decorated(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(14),
          ),

      const SizedBox(height: 20),

      const Text('Desde:')
          .textColor(AppColors.textMuted)
          .fontSize(12)
          .fontWeight(FontWeight.w600),
      const SizedBox(height: 6),
      if (accounts.isEmpty)
        const Text('Cuenta Principal PTB (Saldo: \$2,450.00)')
            .textColor(AppColors.textPrimary)
            .fontSize(13)
            .padding(all: 14)
            .decorated(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
            )
      else
        DropdownButtonFormField<int>(
          initialValue: _paymentsViewModel.selectedOriginIndex < accounts.length
              ? _paymentsViewModel.selectedOriginIndex
              : 0,
          dropdownColor: AppColors.surface,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
          decoration: _cleanDecoration(hint: 'Cuenta débito', prefixIcon: Icons.account_balance_wallet),
          items: List.generate(accounts.length, (idx) {
            final a = accounts[idx];
            return DropdownMenuItem(
              value: idx,
              child: Text(
                '${a.tipoCuenta.toUpperCase()} **** ${a.numeroCuenta.length > 4 ? a.numeroCuenta.substring(a.numeroCuenta.length - 4) : a.numeroCuenta} (\$${a.saldoCuenta.toStringAsFixed(2)})',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              ),
            );
          }),
          onChanged: (val) {
            if (val != null) _paymentsViewModel.setSelectedOriginIndex(val);
          },
        ),

      const SizedBox(height: 20),

      const Text('Monto:')
          .textColor(AppColors.textMuted)
          .fontSize(12)
          .fontWeight(FontWeight.w600),
      const SizedBox(height: 6),

      TextFormField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlignVertical: TextAlignVertical.center,
        style: AppTheme.amountStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surfaceLight,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 18, right: 10),
            child: Text(
              '\$',
              style: AppTheme.amountStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          hintText: '0.00',
          hintStyle: AppTheme.amountStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted.withValues(alpha: 0.35),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.danger, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
          ),
        ),
      ),

      const SizedBox(height: 12),

      // Chips rápidos de monto
      Row(
        children: ['10', '25', '50', '100'].map((val) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceLight,
                  foregroundColor: AppColors.accent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: AppColors.accent.withValues(alpha: 0.2)),
                  ),
                ),
                onPressed: () {
                  final curr = double.tryParse(_amountController.text.trim()) ?? 0.0;
                  final add = double.tryParse(val) ?? 0.0;
                  setState(() => _amountController.text = (curr + add).toStringAsFixed(2));
                },
                child: Text('+\$$val', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          );
        }).toList(),
      ),

      const SizedBox(height: 20),

      const Text('Motivo (opcional):')
          .textColor(AppColors.textMuted)
          .fontSize(12)
          .fontWeight(FontWeight.w600),
      const SizedBox(height: 6),
      TextFormField(
        controller: _conceptController,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: _cleanDecoration(
          hint: 'Ej. Almuerzo, Cuota arriendo',
          prefixIcon: Icons.edit_note,
        ),
      ),

      const SizedBox(height: 24),

      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: _paymentsViewModel.isProcessing ? null : _executePayment,
        child: _paymentsViewModel.isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
              )
            : const Text('Confirmar y Transferir', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  Widget _buildBankSegment({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: <Widget>[
          Icon(
            icon,
            size: 16,
            color: isSelected ? AppColors.background : AppColors.textMuted,
          ),
          const SizedBox(width: 6),
          Text(label)
              .textColor(isSelected ? AppColors.background : AppColors.textMuted)
              .fontSize(12)
              .fontWeight(isSelected ? FontWeight.bold : FontWeight.w500),
        ].toRow(mainAxisAlignment: MainAxisAlignment.center),
      ),
    );
  }

  Widget _buildTypeChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(label)
          .textColor(isSelected ? AppColors.textPrimary : AppColors.textMuted)
          .fontSize(12)
          .fontWeight(isSelected ? FontWeight.bold : FontWeight.normal)
          .padding(horizontal: 14, vertical: 6)
          .decorated(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1)
                : null,
          ),
    );
  }

  Widget _buildQuickFilterPill(
    String number,
    String label,
    bool sameBank,
    String bankName,
    String type,
  ) {
    final isSelected = _paymentsViewModel.accountNumber == number;
    return GestureDetector(
      onTap: () => _applyQuickAccount(number, sameBank, bankName, type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withValues(alpha: 0.2) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: <Widget>[
          Icon(
            Icons.flash_on,
            size: 12,
            color: isSelected ? AppColors.accent : AppColors.textMuted,
          ),
          const SizedBox(width: 4),
          Text(label)
              .textColor(isSelected ? AppColors.accent : AppColors.textPrimary)
              .fontSize(11)
              .fontWeight(isSelected ? FontWeight.bold : FontWeight.w500),
        ].toRow(mainAxisSize: MainAxisSize.min),
      ),
    );
  }

  InputDecoration _cleanDecoration({
    required String hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.surfaceLight,
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.primary, size: 20) : null,
      suffixIcon: suffixIcon,
      errorText: errorText,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
    );
  }
}
