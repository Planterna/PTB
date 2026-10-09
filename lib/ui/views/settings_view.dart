import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

import 'package:styled_widget/styled_widget.dart';

import '../../data/models/user_model.dart';
import 'login_view.dart';

class SettingsView extends StatefulWidget {
  final UserModel user;

  const SettingsView({super.key, required this.user});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _showAccountDetails = false;

  Widget _buildSettingsButton(
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child:
          <Widget>[
                Icon(icon, color: AppColors.accent, size: 20),
                const SizedBox(width: 16),
                Text(title)
                    .textColor(AppColors.accent)
                    .fontSize(16)
                    .fontWeight(FontWeight.w500)
                    .expanded(),
                if (onTap != null)
                  Icon(
                    _showAccountDetails && title == 'Mi Cuenta'
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.accent,
                  ),
              ]
              .toRow()
              .padding(vertical: 16, horizontal: 24)
              .decorated(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(24),
              )
              .padding(bottom: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:
          <Widget>[
                const SizedBox(height: 40),

                // Avatar Circular (Icono por defecto)
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.surfaceLight,
                  child: Icon(Icons.person, size: 80, color: AppColors.accent),
                ).alignment(Alignment.center),

                const SizedBox(height: 20),

                // Nombre del Usuario dinámico
                Text(widget.user.name)
                    .textColor(AppColors.textPrimary)
                    .fontSize(24)
                    .fontWeight(FontWeight.bold)
                    .alignment(Alignment.center),

                const SizedBox(height: 50),

                // Botones de Configuración
                _buildSettingsButton(
                  Icons.person,
                  'Mi Cuenta',
                  onTap: () {
                    setState(() {
                      _showAccountDetails = !_showAccountDetails;
                    });
                  },
                ),

                // Panel desplegable de "Mi Cuenta"
                if (_showAccountDetails)
                  <Widget>[
                        _buildDetailRow('Nombre:', widget.user.name),
                        _buildDetailRow(
                          'Cédula:',
                          widget.user.cedula.isNotEmpty
                              ? widget.user.cedula
                              : 'No registrada',
                        ),
                        _buildDetailRow('Correo:', widget.user.email),
                      ]
                      .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
                      .padding(all: 20)
                      .decorated(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.accent.withOpacity(0.3),
                        ),
                      )
                      .padding(bottom: 24),

                _buildSettingsButton(Icons.help, 'Ayuda'),
                _buildSettingsButton(
                  Icons.insert_drive_file,
                  'Documentos y Certificados',
                ),
                _buildSettingsButton(Icons.security, 'Seguridad'),

                const SizedBox(height: 20),

                // Botón Cerrar sesión
                ElevatedButton(
                  onPressed: () {
                    // Volver al Login
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          title: const Text('Cerrar sesión').textColor(AppColors.textPrimary),
                          content: const Text('¿Estás seguro que deseas salir?').textColor(AppColors.textMuted),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar').textColor(AppColors.textMuted),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Cerrar dialog
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginView()),
                                );
                              },
                              child: const Text('Salir').textColor(AppColors.danger),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
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
                    .textColor(AppColors.textPrimary)
                    .fontSize(12)
                    .fontWeight(FontWeight.bold)
                    .alignment(Alignment.center),

                const SizedBox(height: 20),
              ]
              .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
              .padding(horizontal: 40),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label)
                .textColor(AppColors.textMuted)
                .fontSize(14)
                .fontWeight(FontWeight.bold),
          ),
          Expanded(child: Text(value).textColor(AppColors.textPrimary).fontSize(14)),
        ],
      ),
    );
  }
}
