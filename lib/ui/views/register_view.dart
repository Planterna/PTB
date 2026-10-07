import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import '../widgets/notification_helper.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Widget de ayuda para construir los campos de texto
  Widget _buildTextField(String label, String hint, {bool isPassword = false}) {
    return <Widget>[
      Text(label)
          .textColor(Colors.grey[400]!)
          .fontSize(14)
          .padding(bottom: 8),
      TextField(
        obscureText: isPassword ? _obscurePassword : false,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: <Widget>[
            const SizedBox(height: 40),
            
            // Icono Central / Logo
            const Icon(Icons.account_balance, color: Color(0xFFA5E6D8), size: 45)
                .padding(all: 16)
                .decorated(
                  color: const Color(0xFF1E2228),
                  borderRadius: BorderRadius.circular(16),
                )
                .alignment(Alignment.center),
                
            const SizedBox(height: 30),
            
            // Título Principal
            const Text('Registrate')
                .textColor(Colors.white)
                .fontSize(28)
                .fontWeight(FontWeight.bold)
                .alignment(Alignment.center),
                
            const SizedBox(height: 12),
            
            // Subtítulo y Enlace de Login
            <Widget>[
              const Text('Tienes una cuenta? ')
                  .textColor(Colors.grey[400]!)
                  .fontSize(16),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text('Inicia Sesión')
                    .textColor(const Color(0xFF8BA6FF))
                    .fontSize(16)
                    .fontWeight(FontWeight.bold),
              ),
            ].toRow(mainAxisAlignment: MainAxisAlignment.center),
            
            const SizedBox(height: 40),
            
            // Campos de Formulario
            _buildTextField('N° Cedula', '09123456789'),
            _buildTextField('Nombres', 'Pepe Tola'),
            _buildTextField('Correo electrónico', 'Loisbecket@gmail.com'),
            _buildTextField('Contraseña', '********', isPassword: true),
            
            // Aceptar Términos
            <Widget>[
              Theme(
                data: ThemeData(
                  unselectedWidgetColor: Colors.grey,
                ),
                child: Checkbox(
                  value: _acceptTerms,
                  onChanged: (value) {
                    setState(() {
                      _acceptTerms = value ?? false;
                    });
                  },
                  checkColor: Colors.black,
                  activeColor: const Color(0xFFCBE4F9),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Acepta los Terminos y Condiciones')
                  .textColor(Colors.grey[400]!)
                  .fontSize(14),
            ].toRow(),
            
            const SizedBox(height: 40),
            
            // Botón Principal Registrar
            ElevatedButton(
              onPressed: _isLoading ? null : () {
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

                // Mostrar notificación de éxito
                NotificationHelper.show(
                  context,
                  message: 'Se ha registrado el usuario correctamente',
                  type: NotificationType.success,
                );

                // Esperar 2.5 segundos y redirigir al login
                Future.delayed(const Duration(milliseconds: 2500), () {
                  if (context.mounted) {
                    Navigator.pop(context); // Regresa al LoginView
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCFE5FF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading 
                ? const SizedBox(
                    height: 20, 
                    width: 20, 
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
    );
  }
}
