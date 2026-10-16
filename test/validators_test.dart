import 'package:flutter_test/flutter_test.dart';
import 'package:prestige_trust_bank/core/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    test('validateNames accepts valid alphabetic names with spaces and accents', () {
      expect(Validators.validateNames('Juan Marcelo'), isNull);
      expect(Validators.validateNames('María José'), isNull);
      expect(Validators.validateNames('Ñusta Cañizares'), isNull);
      expect(Validators.validateNames('Lois Becket'), isNull);
    });

    test('validateNames rejects numbers and special characters', () {
      expect(Validators.validateNames('Juan123'), isNotNull);
      expect(Validators.validateNames('Carlos@Perez'), isNotNull);
      expect(Validators.validateNames('María_99'), isNotNull);
      expect(Validators.validateNames('12345'), isNotNull);
      expect(Validators.validateNames(''), isNotNull);
      expect(Validators.validateNames('   '), isNotNull);
    });

    test('validateUsername accepts letters, numbers, underscore and hyphen', () {
      expect(Validators.validateUsername('juan_marcelo'), isNull);
      expect(Validators.validateUsername('carlos-99'), isNull);
      expect(Validators.validateUsername('User_01-test'), isNull);
      expect(Validators.validateUsername('admin'), isNull);
    });

    test('validateUsername rejects spaces and other special characters', () {
      expect(Validators.validateUsername('juan marcelo'), isNotNull); // spaces
      expect(Validators.validateUsername('user@domain'), isNotNull); // @
      expect(Validators.validateUsername('carlos!'), isNotNull); // !
      expect(Validators.validateUsername('ab'), isNotNull); // too short
      expect(Validators.validateUsername(''), isNotNull); // empty
    });

    test('validateEmail validates format correctly', () {
      expect(Validators.validateEmail('user@bank.com'), isNull);
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail(''), isNotNull);
    });

    test('validatePassword validates minimum 8 characters', () {
      expect(Validators.validatePassword('12345678'), isNull);
      expect(Validators.validatePassword('short'), isNotNull);
      expect(Validators.validatePassword(''), isNotNull);
    });

    test('validateConfirmPassword validates password match', () {
      expect(Validators.validateConfirmPassword('password123', 'password123'), isNull);
      expect(Validators.validateConfirmPassword('password123', 'different'), isNotNull);
    });
  });
}
