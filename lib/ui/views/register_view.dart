import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/helpers/notification_helper.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/utils/validators.dart';
import '../viewmodels/register_viewmodel.dart';
import '../../data/datasources/remote/remote_auth_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../widgets/custom_text_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {

  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _namesController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late RegisterViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final remoteDataSource = RemoteAuthDataSource();
    final repository = AuthRepository(remoteDataSource);
    _viewModel = RegisterViewModel(repository);
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _namesController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.6),
            radius: 1.2,
            colors: [Color(0xFF121A27), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
              final screenHeight = constraints.maxHeight;

              // Dimensiones responsivas para el icono y espaciado
              final double iconSize = isKeyboardOpen
                  ? 42.0
                  : (screenHeight * 0.085).clamp(52.0, 76.0);
              final double iconPadding = (iconSize * 0.22).clamp(10.0, 16.0);
              final double topSpacing = isKeyboardOpen ? 6.0 : (screenHeight * 0.02).clamp(8.0, 22.0);
              final double bottomSpacing = isKeyboardOpen ? 12.0 : (screenHeight * 0.03).clamp(14.0, 28.0);
              final double borderRadius = (iconPadding + 4.0).clamp(12.0, 18.0);

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 500,
                      minHeight: constraints.maxHeight - 32,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: topSpacing),
                          Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              padding: EdgeInsets.all(iconPadding),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(borderRadius),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: SvgPicture.asset(
                                AppAssets.logoSymbol,
                                height: iconSize,
                                width: iconSize,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          SizedBox(height: bottomSpacing),

                          const Text('Regístrate')
                              .textColor(AppColors.textPrimary)
                              .fontSize(28)
                              .fontWeight(FontWeight.bold)
                              .alignment(Alignment.center),

                        const SizedBox(height: 16),

                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text('¿Tienes una cuenta? ')
                                .textColor(AppColors.textMuted)
                                .fontSize(16),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text('Inicia Sesión')
                                  .textColor(AppColors.primary)
                                  .fontSize(16)
                                  .fontWeight(FontWeight.bold),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Sección 1: Datos Personales
                        <Widget>[
                          const Icon(
                            Icons.badge_outlined,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text('1. Datos Personales')
                              .textColor(AppColors.primary)
                              .fontSize(15)
                              .fontWeight(FontWeight.bold),
                        ].toRow(),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'N° Cédula',
                          hint: '0999999999',
                          controller: _cedulaController,
                          validator: Validators.validateCedula,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.badge_outlined,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                        ),
                        CustomTextField(
                          label: 'Nombres',
                          hint: 'Juan Marcelo',
                          controller: _namesController,
                          validator: Validators.validateNames,
                          keyboardType: TextInputType.name,
                          prefixIcon: Icons.person_outline,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Sección 2: Credenciales de Acceso
                        <Widget>[
                          const Icon(
                            Icons.lock_outline,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text('2. Credenciales de Acceso')
                              .textColor(AppColors.primary)
                              .fontSize(15)
                              .fontWeight(FontWeight.bold),
                        ].toRow(),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'Usuario',
                          hint: 'ej. juan_marcelo-99',
                          controller: _usernameController,
                          validator: Validators.validateUsername,
                          keyboardType: TextInputType.text,
                          prefixIcon: Icons.alternate_email,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9_\-]'),
                            ),
                            LengthLimitingTextInputFormatter(25),
                          ],
                        ),

                        CustomTextField(
                          label: 'Correo electrónico',
                          hint: 'example@example.com',
                          controller: _emailController,
                          validator: Validators.validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                        ),
                        CustomTextField(
                          label: 'Contraseña',
                          hint: '********',
                          controller: _passwordController,
                          validator: Validators.validatePassword,
                          isPassword: true,
                          prefixIcon: Icons.lock_outlined,
                        ),
                        CustomTextField(
                          label: 'Confirmar Contraseña',
                          hint: '********',
                          controller: _confirmPasswordController,
                          validator: (value) =>
                              Validators.validateConfirmPassword(
                                value,
                                _passwordController.text,
                              ),
                          isPassword: true,
                          prefixIcon: Icons.lock_clock_outlined,
                        ),

                        ListenableBuilder(
                          listenable: _viewModel,
                          builder: (context, _) => Row(
                            children: [
                              Theme(
                                data: ThemeData(
                                  unselectedWidgetColor: AppColors.textMuted,
                                ),
                                child: Checkbox(
                                  value: _viewModel.acceptTerms,
                                  onChanged: _viewModel.toggleAcceptTerms,
                                  checkColor: AppColors.background,
                                  activeColor: AppColors.primary,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: const VisualDensity(
                                    horizontal: -4,
                                    vertical: -4,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Acepto los Términos y Condiciones')
                                  .textColor(AppColors.textMuted)
                                  .fontSize(14)
                                  .expanded(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        ListenableBuilder(
                          listenable: _viewModel,
                          builder: (context, _) {
                            return ElevatedButton(
                              onPressed: _viewModel.isLoading
                                  ? null
                                  : () async {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }

                                      final success = await _viewModel.register(
                                        _cedulaController.text.trim(),
                                        _namesController.text.trim(),
                                        _emailController.text.trim(),
                                        _passwordController.text,
                                        _viewModel.acceptTerms,
                                        username: _usernameController.text.trim(),
                                      );

                                      if (context.mounted) {
                                        if (success) {
                                          NotificationHelper.show(
                                            context,
                                            message: 'Se ha registrado el usuario correctamente',
                                            type: NotificationType.success,
                                          );

                                          Future.delayed(
                                            const Duration(milliseconds: 2500),
                                            () {
                                              if (context.mounted) {
                                                Navigator.pop(context);
                                              }
                                            },
                                          );
                                        } else {
                                          NotificationHelper.show(
                                            context,
                                            message:
                                                _viewModel.errorMessage ??
                                                'Error desconocido',
                                            type: NotificationType.danger,
                                          );
                                        }
                                      }
                                    },
                              child: _viewModel.isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.background,
                                      ),
                                    )
                                  : const Text('Registrar'),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          ),
        ),
      ),
    );
  }
}
