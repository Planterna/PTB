import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prestige_trust_bank/core/constants/app_assets.dart';
import 'package:prestige_trust_bank/ui/views/login_view.dart';
import 'package:prestige_trust_bank/ui/views/register_view.dart';

void main() {
  testWidgets('LoginView renders with logoSymbol and responsive layout', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginView(),
      ),
    );

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Usuario'), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);

    final svgFinder = find.byType(SvgPicture);
    final svgWidget = tester.widget<SvgPicture>(svgFinder);
    final pictureProvider = svgWidget.bytesLoader as SvgAssetLoader;
    expect(pictureProvider.assetName, equals(AppAssets.logoSymbol));
  });

  testWidgets('RegisterView renders with logoSymbol, responsive layout and username field', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RegisterView(),
      ),
    );

    expect(find.text('Regístrate'), findsOneWidget);
    expect(find.text('Usuario'), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);

    final svgFinder = find.byType(SvgPicture);
    final svgWidget = tester.widget<SvgPicture>(svgFinder);
    final pictureProvider = svgWidget.bytesLoader as SvgAssetLoader;
    expect(pictureProvider.assetName, equals(AppAssets.logoSymbol));
  });
}
