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
import '../../data/datasources/mock/mock_auth_datasource.dart';
import '../../data/repositories/auth_repository.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _rememberMe = false;
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final mockDataSource = MockAuthDataSource();
    final repository = AuthRepository(mockDataSource);
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
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: <Widget>[
              const SizedBox(height: 80),

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

              <Widget>[
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
                      .textColor(AppColors.transfer)
                      .fontSize(16)
                      .fontWeight(FontWeight.bold),
                ),
              ].toRow(mainAxisAlignment: MainAxisAlignment.center),

              const SizedBox(height: 40),

              const Text('Correo electrónico')
                  .textColor(AppColors.textMuted)
                  .fontSize(14)
                  .padding(bottom: 8),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'ejemplo@correo.com',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  errorStyle: const TextStyle(color: AppColors.error),
                ),
              ),

              const SizedBox(height: 24),

              const Text('Contraseña')
                  .textColor(AppColors.textMuted)
                  .fontSize(14)
                  .padding(bottom: 8),

              TextFormField(
                controller: _passwordController,
                validator: Validators.validatePassword,
                obscureText: _obscurePassword,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                decoration: InputDecoration(
                  hintText: '********',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  errorStyle: const TextStyle(color: AppColors.error),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textMuted,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              <Widget>[
                <Widget>[
                  Theme(
                    data: ThemeData(unselectedWidgetColor: AppColors.textMuted),
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      checkColor: AppColors.background,
                      activeColor: AppColors.transfer, 
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                ].toRow().expanded(),

                const Text('¿Olvidaste tu contraseña?')
                    .textColor(AppColors.transfer)
                    .fontSize(14)
                    .fontWeight(FontWeight.w500),
              ].toRow(),

              const SizedBox(height: 40),

              ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  return ElevatedButton(
                    onPressed: _viewModel.isLoading ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        final success = await _viewModel.login(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                        
                        if (context.mounted) {
                          if (success) {
                            NotificationHelper.show(
                              context, 
                              message: 'Bienvenido ${_viewModel.user?.name}', 
                              type: NotificationType.success
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => HomeView(user: _viewModel.user!)),
                            );
                          } else {
                            NotificationHelper.show(
                              context, 
                              message: _viewModel.errorMessage ?? 'Error desconocido', 
                              type: NotificationType.danger
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _viewModel.isLoading 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('Ingresar')
                          .fontSize(16)
                          .fontWeight(FontWeight.bold),
                  ).width(double.infinity);
                }
              ),
            ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).padding(horizontal: 24),
          ),
        ),
      ),
    );
  }
}
