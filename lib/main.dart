import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
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
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(
          0xFF000000,
        ), // Background principal negro
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFCFEAFF),
          secondary: Color(0xFFA7DBCB),
          surface: Color(0xFF14171D), // Fondo de tarjetas/campos
          error: Color(0xFFFF8A8A),
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: GoogleFonts.notoSans().fontFamily,
          bodyColor: const Color(0xFFFFFFFF),
          displayColor: const Color(0xFFFFFFFF),
        ),
        useMaterial3: true,
      ),
      home: const LoginView(),
    );
  }
}
