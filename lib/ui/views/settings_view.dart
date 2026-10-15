import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../core/constants/app_colors.dart';
import '../../core/helpers/notification_helper.dart';
import '../../core/utils/validators.dart';
import '../../data/models/user_model.dart';
import '../../data/datasources/remote/remote_user_datasource.dart';
import '../../data/datasources/remote/remote_auth_datasource.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/glass_container.dart';
import 'login_view.dart';

class SettingsView extends StatefulWidget {
  final UserModel user;

  const SettingsView({super.key, required this.user});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final userRemote = RemoteUserDataSource();
    final userRepo = UserRepository(userRemote);
    final authRemote = RemoteAuthDataSource();
    final authRepo = AuthRepository(authRemote);

    _viewModel = ProfileViewModel(
      userRepository: userRepo,
      authRepository: authRepo,
      initialUser: widget.user,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _showEditProfileDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: _viewModel.user.name);
    final emailController = TextEditingController(text: _viewModel.user.email);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogSetStateContext, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              title: const Row(
                children: [
                  Icon(Icons.edit_note, color: AppColors.primary, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Editar Datos Personales',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Modifica tus datos de contacto para mantener tu cuenta actualizada.',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Nombres Completos',
                        hint: 'Ej. Lois Becket',
                        controller: nameController,
                        validator: Validators.validateNames,
                        prefixIcon: Icons.person_outline,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
                          ),
                        ],
                      ),
                      CustomTextField(
                        label: 'Correo Electrónico',
                        hint: 'usuario@banco.com',
                        controller: emailController,
                        validator: Validators.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
                ElevatedButton(
                  onPressed: _viewModel.isSaving
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            final success = await _viewModel.updateProfile(
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                            );

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            if (mounted) {
                              if (success) {
                                NotificationHelper.show(
                                  context,
                                  message: 'Datos personales actualizados correctamente',
                                  type: NotificationType.success,
                                );
                              } else {
                                NotificationHelper.show(
                                  context,
                                  message:
                                      _viewModel.errorMessage ??
                                      'Error al actualizar los datos',
                                  type: NotificationType.danger,
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
                  ),
                  child: _viewModel.isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.background,
                          ),
                        )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return <Widget>[
      Icon(icon, color: AppColors.primary, size: 18),
      const SizedBox(width: 8),
      Text(title)
          .textColor(AppColors.primary)
          .fontSize(15)
          .bold()
          .letterSpacing(0.5),
    ].toRow().padding(top: 20.0, bottom: 12.0);
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: AppColors.accent, size: 20)
          .padding(all: 8)
          .decorated(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
      title: Text(title)
          .textColor(AppColors.textPrimary)
          .fontSize(15)
          .fontWeight(FontWeight.w500),
      subtitle: subtitle != null
          ? Text(subtitle).textColor(AppColors.textMuted).fontSize(12)
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textMuted,
                  size: 14,
                )
              : null),
      onTap: onTap,
    )
        .decorated(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        )
        .padding(bottom: 12);
  }

  Widget _buildDetailRow(String label, String value) {
    return <Widget>[
      Text(label)
          .textColor(AppColors.textMuted)
          .fontSize(13)
          .fontWeight(FontWeight.w600)
          .constrained(width: 70),
      Text(value)
          .textColor(AppColors.textPrimary)
          .fontSize(14)
          .fontWeight(FontWeight.w500)
          .expanded(),
    ].toRow(crossAxisAlignment: CrossAxisAlignment.start).padding(bottom: 10.0);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final currentUser = _viewModel.user;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Cabecera con CircleAvatar para la foto del usuario
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.surfaceLight,
                        child: const Icon(
                          Icons.person,
                          size: 64,
                          color: AppColors.accent,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showEditProfileDialog,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Nombre del usuario dinámico
                Text(currentUser.name)
                    .textColor(AppColors.textPrimary)
                    .fontSize(22)
                    .bold()
                    .textAlignment(TextAlign.center),

                if (currentUser.username != null && currentUser.username!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('@${currentUser.username}')
                      .textColor(AppColors.primary)
                      .fontSize(14)
                      .fontWeight(FontWeight.w600)
                      .textAlignment(TextAlign.center),
                ],

                const SizedBox(height: 4),

                Text(currentUser.email)
                    .textColor(AppColors.textMuted)
                    .fontSize(14)
                    .textAlignment(TextAlign.center),

                const SizedBox(height: 8),

                // Badge Cédula
                Text('C.I. ${currentUser.cedula.isNotEmpty ? currentUser.cedula : "No registrada"}')
                    .textColor(AppColors.accent)
                    .fontSize(12)
                    .bold()
                    .padding(horizontal: 10, vertical: 4)
                    .decorated(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.3),
                      ),
                    )
                    .alignment(Alignment.center),

                const SizedBox(height: 16),

                // ============================================
                // CATEGORÍA 1: DATOS
                // ============================================
                _buildSectionHeader('DATOS', Icons.account_box_outlined),

                _buildOptionTile(
                  icon: Icons.person_outline,
                  title: 'Información Personal',
                  subtitle: 'Consulta y edita tus datos básicos',
                  trailing: Icon(
                    _viewModel.showPersonalData
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.accent,
                  ),
                  onTap: _viewModel.togglePersonalData,
                ),

                if (_viewModel.showPersonalData)
                  GlassContainer(
                    borderRadius: BorderRadius.circular(14),
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Nombre:', currentUser.name),
                        if (currentUser.username != null && currentUser.username!.isNotEmpty)
                          _buildDetailRow('Usuario:', '@${currentUser.username}'),
                        _buildDetailRow(
                          'Cédula:',
                          currentUser.cedula.isNotEmpty
                              ? currentUser.cedula
                              : 'No registrada',
                        ),
                        _buildDetailRow('Correo:', currentUser.email),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _showEditProfileDialog,
                            icon: const Icon(
                              Icons.edit,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            label: const Text(
                              'Editar Datos',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                _buildOptionTile(
                  icon: Icons.description_outlined,
                  title: 'Documentos y Certificados',
                  subtitle: 'Certificados bancarios y estados de cuenta',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        title: const Text(
                          'Certificados',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        content: const Text(
                          'Tus certificados bancarios oficiales están disponibles para descarga en formato PDF.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c),
                            child: const Text('Entendido'),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // ============================================
                // CATEGORÍA 2: SEGURIDAD
                // ============================================
                _buildSectionHeader('SEGURIDAD', Icons.security_outlined),

                _buildOptionTile(
                  icon: Icons.lock_outline,
                  title: 'Cambiar Contraseña',
                  subtitle: 'Actualiza tu clave de acceso periódicamente',
                  onTap: () {
                    NotificationHelper.show(
                      context,
                      message:
                          'Esta opción requiere confirmación por SMS o correo',
                      type: NotificationType.alert,
                    );
                  },
                ),

                _buildOptionTile(
                  icon: Icons.fingerprint,
                  title: 'Autenticación y Biometría',
                  subtitle: 'Configura huella dactilar o reconocimiento facial',
                  onTap: () {
                    NotificationHelper.show(
                      context,
                      message: 'Biometría habilitada para este dispositivo',
                      type: NotificationType.success,
                    );
                  },
                ),
                SizedBox(height: 10),

                // ============================================
                // CATEGORÍA 3: CERRAR SESIÓN
                // ============================================
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          backgroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          title: const Text(
                            'Cerrar sesión',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                          content: const Text(
                            '¿Estás seguro que deseas salir? Deberás ingresar tus credenciales nuevamente.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(color: AppColors.textMuted),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final parentNavigator = Navigator.of(context);
                                Navigator.pop(dialogContext); // Cerrar dialog
                                await _viewModel.logout();
                                if (mounted) {
                                  parentNavigator.pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const LoginView(),
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'Salir',
                                style: TextStyle(color: AppColors.danger),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceLight,
                    foregroundColor: AppColors.danger,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: AppColors.danger.withValues(alpha: 0.4),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                const SizedBox(height: 32),

                // Versión actual
                const Center(
                  child: Text(
                    'Prestige Trust Bank • v2.0.0',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
