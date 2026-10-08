import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/notification_helper.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final _cedulaController = TextEditingController();
  final _namesController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _cedulaController.dispose();
    _namesController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- VALIDADORES ---

  String? _validateCedula(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa tu número de cédula';
    }
    if (value.trim().length != 10) {
      return 'La cédula debe contener exactamente 10 caracteres';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return 'La cédula debe contener solo números';
    }
    return null;
  }

  String? _validateNames(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa tus nombres';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa tu correo electrónico';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, ingresa un correo válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa tu contraseña';
    }
    if (value.length < 8 || value.length > 12) {
      return 'La contraseña debe tener entre 8 y 12 caracteres';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'Debe contener al menos una letra mayúscula';
    }
    if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
      return 'Debe contener al menos un número';
    }
    if (!RegExp(r'(?=.*[!@#\$&*~_.,-])').hasMatch(value)) {
      return 'Debe contener al menos un carácter especial';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirma tu contraseña';
    }
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  // Widget builder helper
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool isPassword = false,
    bool isConfirmPassword = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    bool obscureText = false;
    if (isPassword) obscureText = _obscurePassword;
    if (isConfirmPassword) obscureText = _obscureConfirmPassword;

    return <Widget>[
      Text(label)
          .textColor(const Color(0xFFA8AEB8))
          .fontSize(14)
          .padding(bottom: 8),
      TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFA8AEB8)),
          filled: true,
          fillColor: const Color(0xFF14171D),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          errorStyle: const TextStyle(color: Color(0xFFFF8A8A)),
          errorMaxLines: 2, 
          suffixIcon: (isPassword || isConfirmPassword)
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFFA8AEB8),
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
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: <Widget>[
              const SizedBox(height: 40),
              
              // Logo de la Aplicación
              SvgPicture.asset(
                'assets/logos/logo-prestige-trust-bank-small-icon.svg',
                height: 48,
                width: 48,
              )
                  .padding(all: 16)
                  .decorated(
                    color: const Color(0xFF14171D),
                    borderRadius: BorderRadius.circular(14),
                  )
                  .alignment(Alignment.center),
                  
              const SizedBox(height: 32),
              
              // Título Principal
              const Text('Regístrate')
                  .textColor(const Color(0xFFFFFFFF))
                  .fontSize(28)
                  .fontWeight(FontWeight.bold)
                  .alignment(Alignment.center),
                  
              const SizedBox(height: 16),
              
              // Subtítulo y Enlace de Login
              <Widget>[
                const Text('¿Tienes una cuenta? ')
                    .textColor(const Color(0xFFA8AEB8))
                    .fontSize(16),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text('Inicia Sesión')
                      .textColor(const Color(0xFFA4BCFC))
                      .fontSize(16)
                      .fontWeight(FontWeight.bold),
                ),
              ].toRow(mainAxisAlignment: MainAxisAlignment.center),
              
              const SizedBox(height: 40),
              
              // Campos de Formulario
              _buildTextField(
                label: 'N° Cédula',
                hint: '0912345678',
                controller: _cedulaController,
                validator: _validateCedula,
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
                validator: _validateNames,
              ),
              _buildTextField(
                label: 'Correo electrónico',
                hint: 'Loisbecket@gmail.com',
                controller: _emailController,
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                label: 'Contraseña',
                hint: '********',
                controller: _passwordController,
                validator: _validatePassword,
                isPassword: true,
              ),
              _buildTextField(
                label: 'Confirmar Contraseña',
                hint: '********',
                controller: _confirmPasswordController,
                validator: _validateConfirmPassword,
                isConfirmPassword: true,
              ),
              
              // Aceptar Términos
              <Widget>[
                Theme(
                  data: ThemeData(
                    unselectedWidgetColor: const Color(0xFFA8AEB8),
                  ),
                  child: Checkbox(
                    value: _acceptTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptTerms = value ?? false;
                      });
                    },
                    checkColor: const Color(0xFF000000),
                    activeColor: const Color(0xFFA4BCFC),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Acepto los Términos y Condiciones')
                    .textColor(const Color(0xFFA8AEB8))
                    .fontSize(14),
              ].toRow(),
              
              const SizedBox(height: 40),
              
              // Botón Principal Registrar
              ElevatedButton(
                onPressed: _isLoading ? null : () {
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

                  setState(() {
                    _isLoading = true;
                  });

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
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCFEAFF),
                  foregroundColor: const Color(0xFF000000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                  ? const SizedBox(
                      height: 24, 
                      width: 24, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)
                    )
                  : const Text('Registrar')
                      .fontSize(16)
                      .fontWeight(FontWeight.bold),
              ).width(double.infinity),
              
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
