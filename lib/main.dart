import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'core/theme/app_theme.dart';
import 'ui/views/login_view.dart';
import 'ui/views/not_found_view.dart';
import 'ui/views/register_view.dart';

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

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final rawName = settings.name ?? '/';
    final normalizedPath = Uri.tryParse(rawName)?.path ?? rawName;

    switch (normalizedPath) {
      case '':
      case '/':
      case '/login':
        return MaterialPageRoute(
          settings: const RouteSettings(name: '/'),
          builder: (_) => const LoginView(),
        );
      case '/register':
        return MaterialPageRoute(
          settings: const RouteSettings(name: '/register'),
          builder: (_) => const RegisterView(),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => NotFoundView(attemptedRoute: rawName),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prestige Trust Bank',
      debugShowCheckedModeBanner: false,
      scrollBehavior: AppScrollBehavior(),
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      onGenerateInitialRoutes: (String initialRouteName) {
        final normalizedPath =
            Uri.tryParse(initialRouteName)?.path ?? initialRouteName;
        if (normalizedPath == '/register') {
          return [
            generateRoute(const RouteSettings(name: '/')),
            generateRoute(const RouteSettings(name: '/register')),
          ];
        }
        return [generateRoute(RouteSettings(name: initialRouteName))];
      },
      onGenerateRoute: generateRoute,
      onUnknownRoute: (RouteSettings settings) => MaterialPageRoute(
        settings: settings,
        builder: (_) => NotFoundView(attemptedRoute: settings.name),
      ),
    );
  }
}
