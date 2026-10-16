import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
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
    _usernameController.dispose();
    _passwordController.dispose();
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
            colors: [
              Color(0xFF121A27),
              AppColors.background,
            ],
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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

                          const Text('Iniciar sesión')
                              .textColor(AppColors.textPrimary)
                              .fontSize(28)
                              .fontWeight(FontWeight.bold)
                              .alignment(Alignment.center),

                        const SizedBox(height: 16),

                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
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
                          label: 'Usuario',
                          hint: 'Ingresa tu usuario',
                          controller: _usernameController,
                          validator: Validators.validateUsername,
                          keyboardType: TextInputType.text,
                          prefixIcon: Icons.person_outline,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_\-]')),
                            LengthLimitingTextInputFormatter(25),
                          ],
                        ),

                        CustomTextField(
                          label: 'Contraseña',
                          hint: '********',
                          controller: _passwordController,
                          validator: Validators.validatePassword,
                          isPassword: true,
                          prefixIcon: Icons.lock_outlined,
                        ),

                      ListenableBuilder(
                        listenable: _viewModel,
                        builder: (context, _) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Theme(
                                    data: ThemeData(
                                      unselectedWidgetColor: AppColors.textMuted,
                                    ),
                                    child: Checkbox(
                                      value: _viewModel.rememberMe,
                                      onChanged: _viewModel.toggleRememberMe,
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
                                  Flexible(
                                    child: const Text(
                                      'Recuérdame',
                                      overflow: TextOverflow.ellipsis,
                                    )
                                        .textColor(AppColors.textMuted)
                                        .fontSize(14),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: const Text(
                                '¿Olvidaste tu contraseña?',
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              )
                                  .textColor(AppColors.primary)
                                  .fontSize(14)
                                  .fontWeight(FontWeight.w500),
                            ),
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
                                    if (_formKey.currentState!.validate()) {
                                      final success = await _viewModel.login(
                                        _usernameController.text.trim(),
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
            ),
          );
        },
        ),
      ),
    ),
  );
}
}
