import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo oscuro general
      body: SafeArea(
        child: SingleChildScrollView(
          child:
              <Widget>[
                    const SizedBox(height: 80),

                    // Icono Central / Logo (Placeholder que se asemeja al diseño)
                    const Icon(
                          Icons.account_balance,
                          color: Color(0xFFA5E6D8),
                          size: 45,
                        )
                        .padding(all: 16)
                        .decorated(
                          color: const Color(0xFF1E2228),
                          borderRadius: BorderRadius.circular(16),
                        )
                        .alignment(Alignment.center),

                    const SizedBox(height: 30),

                    // Título Principal
                    const Text('Iniciar sesión')
                        .textColor(Colors.white)
                        .fontSize(28)
                        .fontWeight(FontWeight.bold)
                        .alignment(Alignment.center),

                    const SizedBox(height: 12),

                    // Subtítulo y Enlace de Registro
                    <Widget>[
                      const Text('No tienes una cuenta? ')
                          .textColor(Colors.grey[400]!)
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
                        child: const Text('Registrarse')
                            .textColor(const Color(0xFF8BA6FF))
                            .fontSize(16)
                            .fontWeight(FontWeight.bold),
                      ),
                    ].toRow(mainAxisAlignment: MainAxisAlignment.center),

                    const SizedBox(height: 40),

                    // Label del Correo Electrónico
                    const Text('Correo electrónico')
                        .textColor(Colors.grey[400]!)
                        .fontSize(14)
                        .padding(bottom: 8),

                    // Input de Correo Electrónico
                    TextField(
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Loisbecket@gmail.com',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Label de la Contraseña
                    const Text('Contraseña')
                        .textColor(Colors.grey[400]!)
                        .fontSize(14)
                        .padding(bottom: 8),

                    // Input de Contraseña
                    TextField(
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: '********',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey[600],
                            size: 20,
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
                          data: ThemeData(unselectedWidgetColor: Colors.grey),
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            checkColor: Colors.black,
                            activeColor: const Color(0xFFCBE4F9),
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
                            .textColor(Colors.grey[400]!)
                            .fontSize(14),
                      ].toRow().expanded(),

                      const Text('¿Olvidaste tu contraseña?')
                          .textColor(const Color(0xFF8BA6FF))
                          .fontSize(14)
                          .fontWeight(FontWeight.w500),
                    ].toRow(),

                    const SizedBox(height: 40),

                    // Botón Principal Ingresar
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeView(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCFE5FF),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Ingresar')
                          .fontSize(16)
                          .fontWeight(FontWeight.bold),
                    ).width(double.infinity),
                  ]
                  .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
                  .padding(horizontal: 24),
        ),
      ),
    );
  }
}
