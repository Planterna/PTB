import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:prestige_trust_bank/core/errors/exceptions.dart';
import 'package:prestige_trust_bank/core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ApiClient Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({'jwt_token': 'fake_jwt_token'});
    });

    test('get() attaches Bearer token and returns decoded json', () async {
      final mockClient = MockClient((request) async {
        expect(request.headers['Authorization'], equals('Bearer fake_jwt_token'));
        expect(request.headers['Content-Type'], equals('application/json'));
        return http.Response('{"status": "ok", "items": [1, 2, 3]}', 200);
      });

      final client = ApiClient(client: mockClient);
      final result = await client.get('/test');

      expect(result, isA<Map<String, dynamic>>());
      expect(result['status'], equals('ok'));
      expect(result['items'], equals([1, 2, 3]));
    });

    test('post() sends body as json and parses response', () async {
      final mockClient = MockClient((request) async {
        expect(request.body, contains('"usuario":"lois_becket"'));
        return http.Response('{"token": "new_token", "message": "Login exitoso"}', 200);
      });

      final client = ApiClient(client: mockClient);
      final result = await client.post('/auth/login', body: {'usuario': 'lois_becket'}, requiresAuth: false);

      expect(result['token'], equals('new_token'));
      expect(result['message'], equals('Login exitoso'));
    });

    test('401 response throws UnauthorizedException', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error": "Credenciales inválidas"}', 401);
      });

      final client = ApiClient(client: mockClient);
      expect(
        () => client.post('/auth/login', body: {'usuario': 'bad'}),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('400 response throws ApiException with backend error message', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error": "Saldo insuficiente"}', 400);
      });

      final client = ApiClient(client: mockClient);
      expect(
        () => client.post('/cuentas/transferir', body: {'monto': 9999}),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', equals('Saldo insuficiente'))),
      );
    });
  });
}
