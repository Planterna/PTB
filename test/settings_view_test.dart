import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prestige_trust_bank/data/models/user_model.dart';
import 'package:prestige_trust_bank/ui/views/settings_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'user_id': 'd028675e-f209-4680-b22c-3d6fb2a9c66e',
      'user_cedula': '0912345678',
      'user_name': 'Lois Becket',
      'user_username': 'lois_becket',
      'user_email': 'loisbecket@gmail.com',
    });
  });

  testWidgets('SettingsView displays user cedula and username instead of default', (tester) async {
    final testUser = UserModel(
      id: 'd028675e-f209-4680-b22c-3d6fb2a9c66e',
      cedula: '0912345678',
      name: 'Lois Becket',
      email: 'loisbecket@gmail.com',
      username: 'lois_becket',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsView(user: testUser),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verifica que el nombre del usuario aparezca
    expect(find.text('Lois Becket'), findsWidgets);

    // Verifica que la cédula aparezca en el Badge
    expect(find.text('C.I. 0912345678'), findsOneWidget);

    // Verifica que el mensaje por defecto NO aparezca
    expect(find.text('C.I. No registrada'), findsNothing);

    // Verifica que aparezca el @username
    expect(find.text('@lois_becket'), findsWidgets);
  });
}
