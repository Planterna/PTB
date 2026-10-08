import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'register_view.dart';
import 'home_view.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa tu correo electrónico';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un correo válido (ej. usuario@correo.com)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa tu contraseña';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    return null;
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
              const SizedBox(height: 80),

              // Logo de la Aplicación
              SvgPicture.asset(
                'assets/logos/logo-prestige-trust-bank-small-icon.svg',
                height: 48,
                width: 48,
              )
                  .padding(all: 16)
                  .decorated(
                    color: const Color(0xFF14171D), // Fondo del logo unificado
                    borderRadius: BorderRadius.circular(14), // Múltiplo de la guía
                  )
                  .alignment(Alignment.center),

              const SizedBox(height: 32),

              // Título Principal
              const Text('Iniciar sesión')
                  .textColor(const Color(0xFFFFFFFF))
                  .fontSize(28)
                  .fontWeight(FontWeight.bold)
                  .alignment(Alignment.center),

              const SizedBox(height: 16),

              // Subtítulo y Enlace de Registro
              <Widget>[
                const Text('¿No tienes una cuenta? ')
                    .textColor(const Color(0xFFA8AEB8))
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
                      .textColor(const Color(0xFFA4BCFC)) // Color de link
                      .fontSize(16)
                      .fontWeight(FontWeight.bold),
                ),
              ].toRow(mainAxisAlignment: MainAxisAlignment.center),

              const SizedBox(height: 40),

              // Label del Correo Electrónico
              const Text('Correo electrónico')
                  .textColor(const Color(0xFFA8AEB8))
                  .fontSize(14)
                  .padding(bottom: 8),

              // Input de Correo Electrónico
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'ejemplo@correo.com',
                  hintStyle: const TextStyle(color: Color(0xFFA8AEB8)),
                  filled: true,
                  fillColor: const Color(0xFF14171D), // Fondo de Inputs
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  errorStyle: const TextStyle(color: Color(0xFFFF8A8A)),
                ),
              ),

              const SizedBox(height: 24),

              // Label de la Contraseña
              const Text('Contraseña')
                  .textColor(const Color(0xFFA8AEB8))
                  .fontSize(14)
                  .padding(bottom: 8),

              // Input de Contraseña
              TextFormField(
                controller: _passwordController,
                validator: _validatePassword,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
                decoration: InputDecoration(
                  hintText: '********',
                  hintStyle: const TextStyle(color: Color(0xFFA8AEB8)),
                  filled: true,
                  fillColor: const Color(0xFF14171D),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  errorStyle: const TextStyle(color: Color(0xFFFF8A8A)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFFA8AEB8),
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

              // Recordarme y Olvidaste Contraseña
              <Widget>[
                <Widget>[
                  Theme(
                    data: ThemeData(unselectedWidgetColor: const Color(0xFFA8AEB8)),
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      checkColor: const Color(0xFF000000),
                      activeColor: const Color(0xFFA4BCFC), // Acento del checkbox
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: const VisualDensity(
                        horizontal: -4,
                        vertical: -4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Recuérdame')
                      .textColor(const Color(0xFFA8AEB8))
                      .fontSize(14),
                ].toRow().expanded(),

                const Text('¿Olvidaste tu contraseña?')
                    .textColor(const Color(0xFFA4BCFC))
                    .fontSize(14)
                    .fontWeight(FontWeight.w500),
              ].toRow(),

              const SizedBox(height: 40),

              // Botón Principal Ingresar
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeView()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCFEAFF), // Botón azul clarito
                  foregroundColor: const Color(0xFF000000), // Texto negro
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Ingresar')
                    .fontSize(16)
                    .fontWeight(FontWeight.bold),
              ).width(double.infinity),
            ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).padding(horizontal: 24),
          ),
        ),
      ),
    );
  }
}
