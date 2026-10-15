import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/helpers/notification_helper.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/account_model.dart';
import '../viewmodels/home_viewmodel.dart';

/// Modelo de cuenta verificada para el flujo quemado
class VerifiedAccount {
  final String accountNumber;
  final String ownerName;
  final String identification;
  final String bankName;
  final String accountType;

  const VerifiedAccount({
    required this.accountNumber,
    required this.ownerName,
    required this.identification,
    required this.bankName,
    required this.accountType,
  });
}

class PaymentsView extends StatefulWidget {
  final HomeViewModel viewModel;

  const PaymentsView({super.key, required this.viewModel});

  @override
  State<PaymentsView> createState() => _PaymentsViewState();
}

class _PaymentsViewState extends State<PaymentsView> {
  // 0: Validar cuenta | 1: Ingresar monto y transferir
  int _currentStep = 0;

  // Paso 1: Validación
  final TextEditingController _accountController = TextEditingController();
  bool _isSameBank = true;
  String _selectedOtherBank = 'Banco Pichincha';
  String _selectedAccountType = 'Ahorros';
  bool _isVerifying = false;
  String? _accountError;
  VerifiedAccount? _verifiedAccount;

  final List<String> _otherBanks = [
    'Banco Pichincha',
    'Banco Guayaquil',
    'Produbanco',
    'Banco del Pacífico',
    'Banco Bolivariano',
    'Cooperativa JEP',
  ];

  // Paso 2: Pago
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _conceptController = TextEditingController();
  int _selectedOriginIndex = 0;
  bool _isProcessing = false;

  // Cuentas quemadas de prueba
  final Map<String, VerifiedAccount> _mockDatabase = {
    '1002345678': const VerifiedAccount(
      accountNumber: '1002345678',
      ownerName: 'Carlos Andrés Mendoza',
      identification: '1723456789',
      bankName: 'Prestige Trust Bank',
      accountType: 'Ahorros',
    ),
    '1009876543': const VerifiedAccount(
      accountNumber: '1009876543',
      ownerName: 'María Elena Rodríguez',
      identification: '0918765432',
      bankName: 'Prestige Trust Bank',
      accountType: 'Corriente',
    ),
    '2204567891': const VerifiedAccount(
      accountNumber: '2204567891',
      ownerName: 'Esteban Gabriel Morales',
      identification: '1102938475',
      bankName: 'Banco Pichincha',
      accountType: 'Ahorros',
    ),
    '2401234567': const VerifiedAccount(
      accountNumber: '2401234567',
      ownerName: 'Diana Sofía Viteri',
      identification: '1719283746',
      bankName: 'Banco Guayaquil',
      accountType: 'Ahorros',
    ),
  };

  @override
  void dispose() {
    _accountController.dispose();
    _amountController.dispose();
    _conceptController.dispose();
    super.dispose();
  }

  // =========================================================================
  // LÓGICA DE VALIDACIÓN (QUEMADA)
  // =========================================================================
  Future<void> _verifyAccount() async {
    FocusScope.of(context).unfocus();
    final acc = _accountController.text.trim();

    if (acc.length != 10) {
      setState(() {
        _accountError = 'El número debe tener exactamente 10 dígitos.';
        _verifiedAccount = null;
      });
      NotificationHelper.show(
        context,
        message: 'Ingresa un número de cuenta válido de 10 dígitos',
        type: NotificationType.danger,
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _accountError = null;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final targetBank = _isSameBank ? 'Prestige Trust Bank' : _selectedOtherBank;

    VerifiedAccount resolved;
    if (_mockDatabase.containsKey(acc)) {
      final base = _mockDatabase[acc]!;
      resolved = VerifiedAccount(
        accountNumber: acc,
        ownerName: base.ownerName,
        identification: base.identification,
        bankName: _isSameBank ? 'Prestige Trust Bank' : targetBank,
        accountType: _selectedAccountType,
      );
    } else {
      resolved = VerifiedAccount(
        accountNumber: acc,
        ownerName: 'Titular Verificado PTB #${acc.substring(6)}',
        identification: '17${acc.substring(2)}',
        bankName: targetBank,
        accountType: _selectedAccountType,
      );
    }

    setState(() {
      _isVerifying = false;
      _verifiedAccount = resolved;
    });

    NotificationHelper.show(
      context,
      message: 'Cuenta validada: ${resolved.ownerName}',
      type: NotificationType.success,
    );
  }

  void _applyQuickAccount(String number, bool sameBank, String bank, String type) {
    setState(() {
      _accountController.text = number;
      _isSameBank = sameBank;
      if (!sameBank) _selectedOtherBank = bank;
      _selectedAccountType = type;
      _accountError = null;
    });
    _verifyAccount();
  }

  void _executePayment() {
    final amountText = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      NotificationHelper.show(
        context,
        message: 'Ingresa un monto válido mayor a \$0.00',
        type: NotificationType.danger,
      );
      return;
    }

    final accounts = widget.viewModel.accounts;
    AccountModel? origin;
    if (accounts.isNotEmpty && _selectedOriginIndex < accounts.length) {
      origin = accounts[_selectedOriginIndex];
      if (amount > origin.saldoCuenta) {
        NotificationHelper.show(
          context,
          message: 'Saldo insuficiente en tu cuenta de origen',
          type: NotificationType.danger,
        );
        return;
      }
    }

    final concept = _conceptController.text.trim().isNotEmpty
        ? _conceptController.text.trim()
        : 'Transferencia bancaria';

    _showReceipt(amount, concept);
  }

  Future<void> _showReceipt(double amount, String concept) async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() => _isProcessing = false);

    final ref = 'PTB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppColors.accent, size: 36),
              ),
              const SizedBox(height: 12),
              const Text(
                'Transferencia Exitosa',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ref: $ref',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _receiptRow('Beneficiario', _verifiedAccount!.ownerName, isBold: true),
                    _receiptRow('Banco', _verifiedAccount!.bankName),
                    _receiptRow('Cuenta', _verifiedAccount!.accountNumber),
                    _receiptRow('Motivo', concept),
                  ],
                ),
              ),
            ],
          ),
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
                setState(() {
                  _currentStep = 0;
                  _verifiedAccount = null;
                  _accountController.clear();
                  _amountController.clear();
                  _conceptController.clear();
                });
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // VISTA PRINCIPAL
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _currentStep == 0
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _buildStepValidation(),
            secondChild: _buildStepPayment(),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // PASO 1: VALIDACIÓN MINIMALISTA CON CLARA JERARQUÍA VISUAL
  // =========================================================================
  Widget _buildStepValidation() {
    final hasTen = _accountController.text.trim().length == 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Transferencias',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Valida la cuenta antes de enviar dinero',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 24),

        // 1. SELECTOR DE BANCO: Segmented control moderno (fondo contenedor + pestaña activa clara)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildBankSegment(
                  label: 'Prestige Bank',
                  icon: Icons.account_balance,
                  isSelected: _isSameBank,
                  onTap: () => setState(() {
                    _isSameBank = true;
                    _verifiedAccount = null;
                  }),
                ),
              ),
              Expanded(
                child: _buildBankSegment(
                  label: 'Otro Banco',
                  icon: Icons.public,
                  isSelected: !_isSameBank,
                  onTap: () => setState(() {
                    _isSameBank = false;
                    _verifiedAccount = null;
                  }),
                ),
              ),
            ],
          ),
        ),

        // Dropdown de banco destino (si es otro banco)
        if (!_isSameBank) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedOtherBank,
            dropdownColor: AppColors.surface,
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
            decoration: _cleanDecoration(hint: 'Banco destino', prefixIcon: Icons.account_balance),
            items: _otherBanks.map((b) {
              return DropdownMenuItem(
                value: b,
                child: Text(b, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
              );
            }).toList(),
            onChanged: (b) {
              if (b != null) {
                setState(() {
                  _selectedOtherBank = b;
                  _verifiedAccount = null;
                });
              }
            },
          ),
        ],

        const SizedBox(height: 16),

        // 2. TIPO DE CUENTA: Selector compacto estilizado
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tipo de cuenta:',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTypeChip('Ahorros', _selectedAccountType == 'Ahorros', () {
                    setState(() {
                      _selectedAccountType = 'Ahorros';
                      _verifiedAccount = null;
                    });
                  }),
                  _buildTypeChip('Corriente', _selectedAccountType == 'Corriente', () {
                    setState(() {
                      _selectedAccountType = 'Corriente';
                      _verifiedAccount = null;
                    });
                  }),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 3. INPUT DE CUENTA: 10 dígitos limpios
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
            errorText: _accountError,
            suffixIcon: hasTen
                ? const Icon(Icons.check_circle, color: AppColors.accent, size: 20)
                : null,
          ),
          onChanged: (t) {
            setState(() {
              _accountError = null;
              if (_verifiedAccount != null && _verifiedAccount!.accountNumber != t) {
                _verifiedAccount = null;
              }
            });
          },
        ),

        const SizedBox(height: 14),

        // 4. CUENTAS RÁPIDAS DE PRUEBA COMO FILTROS (PEQUEÑAS, TIPO CAPSULA / FILTER CHIPS)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.flash_on, size: 14, color: AppColors.accent),
                SizedBox(width: 4),
                Text(
                  'Prueba rápida:',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildQuickFilterPill('1002345678', 'Carlos M. (PTB)', true, 'Prestige Trust Bank', 'Ahorros'),
                  const SizedBox(width: 8),
                  _buildQuickFilterPill('1009876543', 'María R. (PTB)', true, 'Prestige Trust Bank', 'Corriente'),
                  const SizedBox(width: 8),
                  _buildQuickFilterPill('2204567891', 'Esteban M. (Pichincha)', false, 'Banco Pichincha', 'Ahorros'),
                  const SizedBox(width: 8),
                  _buildQuickFilterPill('2401234567', 'Diana V. (Guayaquil)', false, 'Banco Guayaquil', 'Ahorros'),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 5. BOTÓN PRINCIPAL "VALIDAR CUENTA" (Destacado y claramente diferenciado de los selectores)
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: hasTen ? AppColors.primary : AppColors.surfaceLight,
            foregroundColor: hasTen ? AppColors.background : AppColors.textMuted,
            minimumSize: const Size.fromHeight(50),
            elevation: hasTen ? 2 : 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: (hasTen && !_isVerifying) ? _verifyAccount : null,
          child: _isVerifying
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                )
              : const Text('Validar Cuenta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ),

        // Resultado de validación limpio
        if (_verifiedAccount != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.accent, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _verifiedAccount!.ownerName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_verifiedAccount!.bankName} • ${_verifiedAccount!.accountType} (${_verifiedAccount!.accountNumber})',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.background,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => setState(() => _currentStep = 1),
                  child: const Text('Continuar al Pago', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // =========================================================================
  // PASO 2: INGRESO DE MONTO Y PAGO MINIMALISTA
  // =========================================================================
  Widget _buildStepPayment() {
    if (_verifiedAccount == null) return const SizedBox.shrink();

    final accounts = widget.viewModel.accounts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Encabezado con botón para volver
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => setState(() => _currentStep = 0),
            ),
            const Text(
              'Realizar Pago',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Destinatario fijado
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: AppColors.accent, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _verifiedAccount!.ownerName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_verifiedAccount!.bankName} • N° ${_verifiedAccount!.accountNumber}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Cuenta Origen
        const Text(
          'Desde:',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        if (accounts.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Cuenta Principal PTB (Saldo: \$2,450.00)',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
          )
        else
          DropdownButtonFormField<int>(
            initialValue: _selectedOriginIndex < accounts.length ? _selectedOriginIndex : 0,
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
              if (val != null) setState(() => _selectedOriginIndex = val);
            },
          ),

        const SizedBox(height: 20),

        // Monto
        const Text(
          'Monto:',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),

        // INPUT DE MONTO PERFECTAMENTE ALINEADO CON EL SÍMBOLO $ Y MISMO TAMAÑO DE TIPOGRAFÍA
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

        // Chips rápidos de monto (4 columnas simétricas de igual tamaño)
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

        // Concepto
        const Text(
          'Motivo (opcional):',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
        ),
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

        // Botón Confirmar
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _isProcessing ? null : _executePayment,
          child: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                )
              : const Text('Confirmar y Transferir', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // =========================================================================
  // COMPONENTES AUXILIARES CON DISTINCIÓN VISUAL CLARA
  // =========================================================================

  /// Pestaña de segmento bancario (estilo segmented control)
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.background : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.background : AppColors.textMuted,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Toggle compacto de tipo de cuenta
  Widget _buildTypeChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// Filtro pill pequeño y elegante para cuentas rápidas de prueba
  Widget _buildQuickFilterPill(
    String number,
    String label,
    bool sameBank,
    String bankName,
    String type,
  ) {
    final isSelected = _accountController.text == number;
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.flash_on,
              size: 12,
              color: isSelected ? AppColors.accent : AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.accent : AppColors.textPrimary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
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
