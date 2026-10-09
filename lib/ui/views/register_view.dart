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
  bool _acceptTerms = false;

  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _namesController = TextEditingController();
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      SvgPicture.asset(
                        AppAssets.logoSmall,
                        height: 48,
                        width: 48,
                      )
                          .padding(all: 16)
                          .decorated(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                          )
                          .alignment(Alignment.center),

                      const SizedBox(height: 32),

                      const Text('Regístrate')
                          .textColor(AppColors.textPrimary)
                          .fontSize(28)
                          .fontWeight(FontWeight.bold)
                          .alignment(Alignment.center),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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

                      const SizedBox(height: 40),

                      CustomTextField(
                        label: 'N° Cédula',
                        hint: '0999999999',
                        controller: _cedulaController,
                        validator: Validators.validateCedula,
                        keyboardType: TextInputType.number,
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
                      ),
                      CustomTextField(
                        label: 'Correo electrónico',
                        hint: 'example@example.com',
                        controller: _emailController,
                        validator: Validators.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      CustomTextField(
                        label: 'Contraseña',
                        hint: '********',
                        controller: _passwordController,
                        validator: Validators.validatePassword,
                        isPassword: true,
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
                      ),

                      Row(
                        children: [
                          Theme(
                            data: ThemeData(
                              unselectedWidgetColor: AppColors.textMuted,
                            ),
                            child: Checkbox(
                              value: _acceptTerms,
                              onChanged: (value) {
                                setState(() {
                                  _acceptTerms = value ?? false;
                                });
                              },
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
                              .fontSize(14),
                        ],
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

                                    if (!_acceptTerms) {
                                      NotificationHelper.show(
                                        context,
                                        message: 'Debes aceptar los términos y condiciones',
                                        type: NotificationType.danger,
                                      );
                                      return;
                                    }

                                    final success = await _viewModel.register(
                                      _cedulaController.text.trim(),
                                      _namesController.text.trim(),
                                      _emailController.text.trim(),
                                      _passwordController.text,
                                      _acceptTerms,
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
            );
          },
        ),
      ),
    );
  }
}
