import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prestige_trust_bank/data/models/account_model.dart';
import 'package:prestige_trust_bank/ui/widgets/account_card_widget.dart';

void main() {
  testWidgets('AccountCardWidget toggles obscure balance blur without crashing',
      (WidgetTester tester) async {
    final account = AccountModel(
      idCuenta: '1',
      idUsuario: '1',
      tipoCuenta: 'ahorro',
      numeroCuenta: '1234567890',
      saldoCuenta: 1500.50,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountCardWidget(account: account),
        ),
      ),
    );

    // Initial state: not obscured, shows visibility icon
    expect(find.byIcon(Icons.visibility), findsOneWidget);
    expect(find.byType(ImageFiltered), findsNothing);

    // Tap the visibility button to hide/blur balance
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    // Now obscured: shows visibility_off icon and ImageFiltered widget
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    expect(find.byType(ImageFiltered), findsOneWidget);

    // Tap again to unhide
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility), findsOneWidget);
    expect(find.byType(ImageFiltered), findsNothing);
  });
}
