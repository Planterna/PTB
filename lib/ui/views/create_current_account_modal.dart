import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/account_model.dart';
import '../../data/repositories/finance_repository.dart';
import '../viewmodels/create_current_account_viewmodel.dart';

class CreateCurrentAccountModal extends StatefulWidget {
  final FinanceRepository repository;
  final List<AccountModel> userAccounts;
  final String defaultOwnerName;
  final VoidCallback? onSuccess;

  const CreateCurrentAccountModal({
    super.key,
    required this.repository,
    required this.userAccounts,
    required this.defaultOwnerName,
    this.onSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    required FinanceRepository repository,
    required List<AccountModel> userAccounts,
    required String defaultOwnerName,
    VoidCallback? onSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateCurrentAccountModal(
        repository: repository,
        userAccounts: userAccounts,
        defaultOwnerName: defaultOwnerName,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<CreateCurrentAccountModal> createState() =>
      _CreateCurrentAccountModalState();
}

class _CreateCurrentAccountModalState extends State<CreateCurrentAccountModal> {
  late CreateCurrentAccountViewModel _viewModel;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _viewModel = CreateCurrentAccountViewModel(
      repository: widget.repository,
      userAccounts: widget.userAccounts,
      defaultOwnerName: widget.defaultOwnerName,
    );
    _nameController = TextEditingController(text: widget.defaultOwnerName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final screenHeight = MediaQuery.of(context).size.height;
        return Container(
          height: screenHeight * 0.90,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    physics: const BouncingScrollPhysics(),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: _buildCurrentStepContent(),
                      ),
                    ),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final title = _viewModel.currentStep == 0
        ? ''
        : (_viewModel.currentStep == 1
            ? 'Chequera y Tarjeta'
            : 'Depósito de Apertura');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: AppColors.primary,
            onPressed: () {
              if (_viewModel.currentStep > 0) {
                _viewModel.prevStep();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 22),
            color: AppColors.textMuted,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_viewModel.currentStep) {
      case 0:
        return _buildStepMigratoryFiscal();
      case 1:
        return _buildStepCheckbookAndCard();
      case 2:
      default:
        return _buildStepPaymentAndDeposit();
    }
  }

  // ========================================================
  // PASO 1: INFORMACIÓN MIGRATORIA Y FISCAL (s1.jpeg)
  // ========================================================
  Widget _buildStepMigratoryFiscal() {
    return Column(
      children: [
        const SizedBox(height: 10),
        // Globo terráqueo azul circular
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Color(0xFF0D6EFD),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.public, color: Colors.white, size: 42),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Información\nmigratoria y fiscal',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Completa la siguiente información',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 28),

        // Tarjeta 1: ESTADO MIGRATORIO
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ESTADO MIGRATORIO',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '¿Tienes ciudadanía, nacionalidad o residencia en Estados Unidos y has estado allí más de 6 meses consecutivos en el último año?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildChoiceButton(
                      label: 'Sí tengo',
                      isSelected: _viewModel.tieneResidenciaUsa,
                      onTap: () => _viewModel.setTieneResidenciaUsa(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildChoiceButton(
                      label: 'No tengo',
                      isSelected: !_viewModel.tieneResidenciaUsa,
                      onTap: () => _viewModel.setTieneResidenciaUsa(false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tarjeta 2: RESIDENCIA FISCAL
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'RESIDENCIA FISCAL',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '¿Declaras o pagas impuestos en otro país, además de Ecuador?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildChoiceButton(
                      label: 'Sí declaro',
                      isSelected: _viewModel.declaraImpuestosOtroPais,
                      onTap: () => _viewModel.setDeclaraImpuestosOtroPais(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildChoiceButton(
                      label: 'No declaro',
                      isSelected: !_viewModel.declaraImpuestosOtroPais,
                      onTap: () => _viewModel.setDeclaraImpuestosOtroPais(false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ========================================================
  // PASO 2: CHEQUERA Y TARJETA (s.jpeg)
  // ========================================================
  Widget _buildStepCheckbookAndCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Elige el modelo cheques disponibles',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),

        // Modelo 1: Institucional
        _buildCheckModelCard(
          title: 'Institucional',
          subtitle: 'Diseño tradicional',
          isSelected: _viewModel.modeloChequera == 'Institucional',
          onTap: () => _viewModel.setModeloChequera('Institucional'),
        ),
        const SizedBox(height: 10),

        // Modelo 2: Institucional zurdo
        _buildCheckModelCard(
          title: 'Institucional zurdo',
          subtitle: 'Tradicional para clientes zurdos',
          isSelected: _viewModel.modeloChequera == 'Institucional zurdo',
          onTap: () => _viewModel.setModeloChequera('Institucional zurdo'),
        ),
        const SizedBox(height: 10),

        // Modelo 3: Ondas
        _buildCheckModelCard(
          title: 'Ondas',
          subtitle: 'Diseño renovado y colorido',
          isSelected: _viewModel.modeloChequera == 'Ondas',
          onTap: () => _viewModel.setModeloChequera('Ondas'),
        ),

        const SizedBox(height: 22),

        // Número de cheques
        const Text(
          'Número de cheques',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildChoiceButton(
                label: '20',
                isSelected: _viewModel.numeroCheques == 20,
                onTap: () => _viewModel.setNumeroCheques(20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildChoiceButton(
                label: '50',
                isSelected: _viewModel.numeroCheques == 50,
                onTap: () => _viewModel.setNumeroCheques(50),
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        // Tipo de chequera
        const Text(
          'Tipo de chequera',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildChoiceButton(
                label: 'Con talón',
                isSelected: _viewModel.tipoChequera == 'Con talón',
                onTap: () => _viewModel.setTipoChequera('Con talón'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildChoiceButton(
                label: 'Sin talón',
                isSelected: _viewModel.tipoChequera == 'Sin talón',
                onTap: () => _viewModel.setTipoChequera('Sin talón'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        // Nombre en documentos y Agencia
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              ListTile(
                title: const Text(
                  'Nombre en documentos',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _viewModel.nombreEnDocumentos,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.primary),
                onTap: _showEditNameDialog,
              ),
              Divider(
                height: 1,
                color: Colors.white.withValues(alpha: 0.08),
                indent: 16,
                endIndent: 16,
              ),
              ListTile(
                title: const Text(
                  'Agencia de retiro',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _viewModel.agenciaRetiro,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.primary),
                onTap: _showSelectAgencyDialog,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Mensaje informativo inferior
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.info, color: AppColors.primary, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Para tarifas asociadas a cuentas, tarjetas y servicios, consulta www.prestigetrustbank.com',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ========================================================
  // PASO 3: DEPÓSITO Y MÉTODO DE PAGO ($350.00)
  // ========================================================
  Widget _buildStepPaymentAndDeposit() {
    final savings = _viewModel.savingsAccount;
    final hasSavings = savings != null;
    final sufficient = _viewModel.hasSufficientSavings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado del paso
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.4),
              ),
            ),
            child: const Text(
              'DEPÓSITO INICIAL REQUERIDO',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Center(
          child: Text(
            '\$350.00',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Para emitir tu chequera y activar tu Cuenta Corriente, se requiere un depósito inicial de \$350.00.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),

        // Resumen de la cuenta de ahorros
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: sufficient
                  ? AppColors.accent.withValues(alpha: 0.4)
                  : AppColors.danger.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cuenta de Ahorros Origen',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    sufficient ? Icons.check_circle : Icons.warning_amber_rounded,
                    color: sufficient ? AppColors.accent : AppColors.danger,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                hasSavings
                    ? 'N° ${savings.numeroCuenta}'
                    : 'No tienes cuenta de ahorros registrada',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hasSavings
                    ? 'Saldo disponible: \$${savings.saldoCuenta.toStringAsFixed(2)}'
                    : 'Saldo no disponible',
                style: TextStyle(
                  color: sufficient ? AppColors.accent : AppColors.danger,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasSavings && !sufficient) ...[
                const SizedBox(height: 8),
                const Text(
                  'Saldo insuficiente para realizar el débito de \$350.00. Puedes elegir "Pagar en ventanilla".',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),
        const Text(
          'Selecciona la modalidad de pago:',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Opción 1: Transferir de cuenta de ahorro
        _buildPaymentOptionCard(
          title: 'Transferir de cuenta de ahorro',
          subtitle:
              'Se debitarán \$350.00 inmediatamente de tus ahorros y se acreditarán como saldo inicial en tu nueva cuenta corriente.',
          icon: Icons.account_balance_wallet_outlined,
          isSelected: _viewModel.metodoPago == 'DEBITO_AHORROS',
          enabled: sufficient,
          onTap: () {
            if (sufficient) {
              _viewModel.setMetodoPago('DEBITO_AHORROS');
            }
          },
        ),

        const SizedBox(height: 12),

        // Opción 2: Pagar en ventanilla
        _buildPaymentOptionCard(
          title: 'Pagar en ventanilla',
          subtitle:
              'Registra tu solicitud y acércate a una agencia física para realizar el depósito de \$350.00 y activar tu cuenta.',
          icon: Icons.storefront_outlined,
          isSelected: _viewModel.metodoPago == 'PAGO_VENTANILLA',
          enabled: true,
          onTap: () {
            _viewModel.setMetodoPago('PAGO_VENTANILLA');
          },
        ),

        const SizedBox(height: 20),

        if (_viewModel.errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.danger.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.danger, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _viewModel.errorMessage!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ========================================================
  // COMPONENTES REUTILIZABLES
  // ========================================================
  Widget _buildChoiceButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.18)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white12,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckModelCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white12,
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.45,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.white12,
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                size: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================================
  // BARRA INFERIOR (BOTÓN CONTINUAR / AUTORIZAR)
  // ========================================================
  Widget _buildBottomBar() {
    final isLastStep = _viewModel.currentStep == 2;
    final isVentanilla = _viewModel.metodoPago == 'PAGO_VENTANILLA';

    String buttonLabel;
    if (!isLastStep) {
      buttonLabel = 'Continuar';
    } else {
      buttonLabel = isVentanilla
          ? 'Registrar solicitud en ventanilla'
          : 'Transferir de cuenta de ahorro (\$350.00)';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D6EFD), // Azul botón como en s1.jpeg
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _viewModel.isSubmitting
                ? null
                : () async {
                    if (_viewModel.currentStep < 2) {
                      _viewModel.nextStep();
                    } else {
                      await _handleFinalSubmission();
                    }
                  },
            child: _viewModel.isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleFinalSubmission() async {
    final success = await _viewModel.submitRequest();
    if (!mounted) return;

    if (success) {
      final res = _viewModel.responseResult;
      final isVentanilla = res?.metodoPago == 'PAGO_VENTANILLA';

      if (isVentanilla) {
        // Mensaje requerido: "para que el proceso continue debe acercarse a un establecimiento fisico"
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: const [
                Icon(Icons.storefront, color: AppColors.primary, size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Solicitud Registrada',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              res?.mensaje ??
                  'Para que el proceso continúe y tu cuenta corriente sea activada, debes acercarte a un establecimiento físico o agencia de Prestige Trust Bank para realizar el depósito de apertura de \$350.00.',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop();
                  widget.onSuccess?.call();
                },
                child: const Text(
                  'Entendido',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        // Mensaje de éxito de cuenta creada y débito realizado
        final accNumber = res?.cuenta?['numero_cuenta'] ?? '';
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: const [
                Icon(Icons.check_circle, color: AppColors.accent, size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '¡Cuenta Corriente Creada!',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu nueva Cuenta Corriente N° $accNumber ha sido activada exitosamente.',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Monto debitado:',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 13)),
                          Text('-\$350.00',
                              style: TextStyle(
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Saldo inicial corriente:',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 13)),
                          Text('+\$350.00',
                              style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop();
                  widget.onSuccess?.call();
                },
                child: const Text(
                  'Finalizar',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showEditNameDialog() {
    _nameController.text = _viewModel.nombreEnDocumentos;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Nombre en documentos',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Nombre completo',
            hintStyle: TextStyle(color: AppColors.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              if (_nameController.text.trim().isNotEmpty) {
                _viewModel.setNombreEnDocumentos(_nameController.text.trim());
              }
              Navigator.of(dialogCtx).pop();
            },
            child: const Text('Guardar',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showSelectAgencyDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Selecciona agencia de retiro',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _viewModel.availableAgencies.length,
            itemBuilder: (ctx, index) {
              final agency = _viewModel.availableAgencies[index];
              final isSel = agency == _viewModel.agenciaRetiro;
              return ListTile(
                title: Text(
                  agency,
                  style: TextStyle(
                    color: isSel ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                trailing: isSel
                    ? const Icon(Icons.check, color: AppColors.primary, size: 18)
                    : null,
                onTap: () {
                  _viewModel.setAgenciaRetiro(agency);
                  Navigator.of(dialogCtx).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
