import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'register_view.dart';
import 'home_view.dart';
import '../../core/helpers/notification_helper.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/utils/validators.dart';
import '../viewmodels/login_viewmodel.dart';
import '../../data/datasources/remote/remote_auth_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../widgets/custom_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _rememberMe = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final remoteDataSource = RemoteAuthDataSource();
    final repository = AuthRepository(remoteDataSource);
    _viewModel = LoginViewModel(repository);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                  minHeight: constraints.maxHeight - 32, // Ocupar pantalla completa si es posible
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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

                      const Text('Iniciar sesión')
                          .textColor(AppColors.textPrimary)
                          .fontSize(28)
                          .fontWeight(FontWeight.bold)
                          .alignment(Alignment.center),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('¿No tienes una cuenta? ')
                              .textColor(AppColors.textMuted)
                              .fontSize(16),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterView(),
                                ),
                              );
                            },
                            child: const Text('Regístrate')
                                .textColor(AppColors.primary)
                                .fontSize(16)
                                .fontWeight(FontWeight.bold),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

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

                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Theme(
                                  data: ThemeData(
                                    unselectedWidgetColor: AppColors.textMuted,
                                  ),
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
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
                                const Text('Recuérdame')
                                    .textColor(AppColors.textMuted)
                                    .fontSize(14),
                              ],
                            ),
                          ),
                          const Text('¿Olvidaste tu contraseña?')
                              .textColor(AppColors.primary)
                              .fontSize(14)
                              .fontWeight(FontWeight.w500),
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
                                    if (_formKey.currentState!.validate()) {
                                      final success = await _viewModel.login(
                                        _emailController.text.trim(),
                                        _passwordController.text.trim(),
                                      );

                                      if (context.mounted) {
                                        if (success) {
                                          NotificationHelper.show(
                                            context,
                                            message:
                                                'Bienvenido ${_viewModel.user?.name}',
                                            type: NotificationType.success,
                                          );
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => HomeView(
                                                user: _viewModel.user!,
                                              ),
                                            ),
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
                                : const Text('Ingresar'),
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
