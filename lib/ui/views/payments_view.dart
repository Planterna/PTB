import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
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

    final result = _paymentsViewModel.lastTransferResult;
    final isInterbank = !_paymentsViewModel.isSameBank;
    final fee = result?.comision ?? (isInterbank ? PaymentsViewModel.interbankFee : 0.0);
    final totalDebited = result?.totalDebitado ?? (amount + fee);
    final bankName = result?.bancoDestino ?? account.bankName;
    final now = result?.fecha ?? DateTime.now();
    final originAccountNum = widget.viewModel.accounts.isNotEmpty &&
            _paymentsViewModel.selectedOriginIndex < widget.viewModel.accounts.length
        ? widget.viewModel.accounts[_paymentsViewModel.selectedOriginIndex].numeroCuenta
        : '';

    final shareText = '''
╔══════════════════════════════════════╗
       PRESTIGE TRUST BANK
   COMPROBANTE DE TRANSFERENCIA
╚══════════════════════════════════════╝

ESTADO: EXITOSA
REFERENCIA: $ref
FECHA: ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}

MONTO ENVIADO: \$${amount.toStringAsFixed(2)}
COMISIÓN: \$${fee.toStringAsFixed(2)}${isInterbank ? ' (Interbancaria)' : ''}
TOTAL DEBITADO: \$${totalDebited.toStringAsFixed(2)}

--- DATOS DE LA TRANSFERENCIA ---
Beneficiario: ${account.ownerName}
Identificación: ${account.identification}
Banco Destino: $bankName
Cuenta Destino: ${account.accountNumber}
Cuenta Origen: $originAccountNum
Motivo: $concept

Gracias por confiar en Prestige Trust Bank.
''';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ícono de éxito con halo moderno
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent.withValues(alpha: 0.25),
                          AppColors.primary.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.accent,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    '¡Transferencia Exitosa!',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isInterbank
                        ? 'Transferencia Interbancaria Acreditada'
                        : 'Transferencia Directa Prestige Trust Bank',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 18),

                  // Monto destacado y desglose
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Monto Enviado',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${amount.toStringAsFixed(2)}',
                          style: AppTheme.amountStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                        if (isInterbank) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.softAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.receipt_long,
                                  size: 13,
                                  color: AppColors.softAccent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Comisión: \$0.45 • Total Debitado: \$${totalDebited.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tarjeta tipo comprobante / recibo
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      children: [
                        _receiptRow('Beneficiario', account.ownerName, isBold: true),
                        _receiptRow('Identificación', account.identification),
                        _receiptRow('Banco Destino', bankName),
                        _receiptRow('Cuenta Destino', account.accountNumber),
                        if (originAccountNum.isNotEmpty)
                          _receiptRow('Cuenta Origen', originAccountNum),
                        _receiptRow('Motivo', concept),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: Colors.white12, height: 1),
                        ),
                        _receiptRow(
                          'Comisión',
                          isInterbank ? '\$${fee.toStringAsFixed(2)}' : 'Gratis (\$0.00)',
                        ),
                        _receiptRow(
                          'Total debitado',
                          '\$${totalDebited.toStringAsFixed(2)}',
                          isBold: true,
                          highlightColor: AppColors.primary,
                        ),
                        _receiptRow(
                          'Fecha y hora',
                          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                        ),
                        _receiptRow('Referencia', ref, isCopyable: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // BOTÓN 1 (ARRIBA): COMPARTIR COMPROBANTE
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      minimumSize: const Size.fromHeight(48),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      // Copiar al portapapeles
                      await Clipboard.setData(ClipboardData(text: shareText));
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('Comprobante copiado al portapapeles'),
                            backgroundColor: AppColors.accent,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                      // Compartir nativamente con el sistema operativo
                      try {
                        await SharePlus.instance.share(
                          ShareParams(
                            text: shareText,
                            subject: 'Comprobante de Transferencia PTB - $ref',
                          ),
                        );
                      } catch (e) {
                        debugPrint('Error al compartir comprobante: $e');
                      }
                    },
                    icon: const Icon(Icons.share_outlined, size: 20),
                    label: const Text(
                      'Compartir Comprobante',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // BOTÓN 2 (ABAJO): REALIZAR OTRA TRANSFERENCIA
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      minimumSize: const Size.fromHeight(46),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _paymentsViewModel.resetFlow();
                      _accountController.clear();
                      _amountController.clear();
                      _conceptController.clear();
                    },
                    icon: const Icon(Icons.replay_rounded, size: 18),
                    label: const Text(
                      'Realizar otra transferencia',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    NotificationHelper.show(
      context,
      message: 'Transferencia por \$${amount.toStringAsFixed(2)} aprobada',
      type: NotificationType.success,
    );
  }

  Widget _receiptRow(
    String label,
    String value, {
    bool isBold = false,
    Color? highlightColor,
    bool isCopyable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: highlightColor ??
                          (isBold
                              ? AppColors.textPrimary
                              : AppColors.textPrimary.withValues(alpha: 0.85)),
                      fontSize: 12.5,
                      fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isCopyable) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$label copiado al portapapeles'),
                          duration: const Duration(seconds: 1),
                          backgroundColor: AppColors.accent,
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.copy_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
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

      if (!_paymentsViewModel.isSameBank) ...[
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.softAccent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.softAccent.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.accent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Comisión interbancaria: \$0.45',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tarifa estándar regulada para envíos a otros bancos.',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  '+\$0.45',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],

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
