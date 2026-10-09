import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'core/theme/app_theme.dart';
import 'ui/views/login_view.dart';

void main() {
  runApp(const MyApp());
}

// Comportamiento global para permitir hacer scroll arrastrando el mouse en PC/Web
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prestige Trust Bank',
      debugShowCheckedModeBanner: false,
      scrollBehavior: AppScrollBehavior(),
      theme: AppTheme.darkTheme,
      home: const LoginView(),
    );
  }
}
