import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'login_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  Widget _buildSettingsButton(IconData icon, String title) {
    return <Widget>[
      Icon(icon, color: const Color(0xFFA5E6D8), size: 20),
      const SizedBox(width: 16),
      Text(title)
          .textColor(const Color(0xFFA5E6D8))
          .fontSize(16)
          .fontWeight(FontWeight.w500),
    ]
        .toRow()
        .padding(vertical: 16, horizontal: 24)
        .decorated(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(24),
        )
        .padding(bottom: 16);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: <Widget>[
        const SizedBox(height: 40),
        
        // Avatar Circular
        const CircleAvatar(
          radius: 60,
          backgroundColor: Colors.green,
          backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=Pepe'), 
          // Usamos un avatar generado aleatorio similar al diseño.
        ).alignment(Alignment.center),
        
        const SizedBox(height: 20),
        
        // Nombre del Usuario
        const Text('Pepe Tola')
            .textColor(Colors.white)
            .fontSize(24)
            .fontWeight(FontWeight.bold)
            .alignment(Alignment.center),
            
        const SizedBox(height: 50),
        
        // Botones de Configuración
        _buildSettingsButton(Icons.person, 'Mi Cuenta'),
        _buildSettingsButton(Icons.help, 'Ayuda'),
        _buildSettingsButton(Icons.insert_drive_file, 'Documentos y Certificados'),
        _buildSettingsButton(Icons.security, 'Seguridad'),
        
        const SizedBox(height: 20),
        
        // Botón Cerrar sesión
        ElevatedButton(
          onPressed: () {
            // Volver al Login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginView()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCFE5FF),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Cerrar sesion')
              .fontSize(16)
              .fontWeight(FontWeight.bold),
        ).width(double.infinity),
        
        const Spacer(),
        
        // Versión Actual
        const Text('Version actual 1.0')
            .textColor(Colors.white)
            .fontSize(12)
            .fontWeight(FontWeight.bold)
            .alignment(Alignment.center),
            
        const SizedBox(height: 20),
      ]
          .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
          .padding(horizontal: 40),
    );
  }
}
