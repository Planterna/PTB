import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/helpers/notification_helper.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/utils/validators.dart';
import '../viewmodels/register_viewmodel.dart';
import '../../data/datasources/mock/mock_auth_datasource.dart';
import '../../data/repositories/auth_repository.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
    final mockDataSource = MockAuthDataSource();
    final repository = AuthRepository(mockDataSource);
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

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool isPassword = false,
    bool isConfirmPassword = false,
  }) {
    bool obscureText = false;
    if (isPassword) {
      obscureText = _obscurePassword;
    } else if (isConfirmPassword) {
      obscureText = _obscureConfirmPassword;
    }

    return <Widget>[
      Text(label)
          .textColor(AppColors.textMuted)
          .fontSize(14)
          .padding(bottom: 8),
      TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          errorStyle: const TextStyle(color: AppColors.error),
          errorMaxLines: 2, 
          suffixIcon: (isPassword || isConfirmPassword)
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textMuted,
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isPassword) {
                        _obscurePassword = !_obscurePassword;
                      }
                      if (isConfirmPassword) {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      }
                    });
                  },
                )
              : null,
        ),
      ),
      const SizedBox(height: 16),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.start);
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
              const SizedBox(height: 40),
              
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
              
              <Widget>[
                const Text('¿Tienes una cuenta? ')
                    .textColor(AppColors.textMuted)
                    .fontSize(16),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text('Inicia Sesión')
                      .textColor(AppColors.transfer)
                      .fontSize(16)
                      .fontWeight(FontWeight.bold),
                ),
              ].toRow(mainAxisAlignment: MainAxisAlignment.center),
              
              const SizedBox(height: 40),
              
              _buildTextField(
                label: 'N° Cédula',
                hint: '0912345678',
                controller: _cedulaController,
                validator: Validators.validateCedula,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
              _buildTextField(
                label: 'Nombres',
                hint: 'Pepe Tola',
                controller: _namesController,
                validator: Validators.validateNames,
              ),
              _buildTextField(
                label: 'Correo electrónico',
                hint: 'Loisbecket@gmail.com',
                controller: _emailController,
                validator: Validators.validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                label: 'Contraseña',
                hint: '********',
                controller: _passwordController,
                validator: Validators.validatePassword,
                isPassword: true,
              ),
              _buildTextField(
                label: 'Confirmar Contraseña',
                hint: '********',
                controller: _confirmPasswordController,
                validator: (value) => Validators.validateConfirmPassword(value, _passwordController.text),
                isConfirmPassword: true,
              ),
              
              <Widget>[
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
                    activeColor: AppColors.transfer,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Acepto los Términos y Condiciones')
                    .textColor(AppColors.textMuted)
                    .fontSize(14),
              ].toRow(),
              
              const SizedBox(height: 40),
              
              ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  return ElevatedButton(
                    onPressed: _viewModel.isLoading ? null : () async {
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

                          Future.delayed(const Duration(milliseconds: 2500), () {
                            if (context.mounted) {
                              Navigator.pop(context); 
                            }
                          });
                        } else {
                          NotificationHelper.show(
                            context,
                            message: _viewModel.errorMessage ?? 'Error desconocido',
                            type: NotificationType.danger,
                          );
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
                      ? const SizedBox(
                          height: 24, 
                          width: 24, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)
                        )
                      : const Text('Registrar')
                          .fontSize(16)
                          .fontWeight(FontWeight.bold),
                  ).width(double.infinity);
                }
              ),
              
              const SizedBox(height: 40),
            ]
                .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
                .padding(horizontal: 24),
          ),
        ),
      ),
    );
  }
}
