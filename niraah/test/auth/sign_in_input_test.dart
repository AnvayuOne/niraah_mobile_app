import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/features/auth/domain/auth_repository.dart';

void main() {
  test('digits with +91, spaces or dashes are a mobile number', () {
    for (final String raw in <String>['9876543210', '+91 98765 43210', '98765-43210', '919876543210']) {
      final SignInInput i = SignInInput.parse(raw);
      expect(i, isA<PhoneInput>(), reason: raw);
      expect((i as PhoneInput).e164, '+919876543210', reason: raw);
      expect(i.isValid, isTrue);
    }
  });

  test('a number that is not an Indian mobile is not valid', () {
    expect((SignInInput.parse('12345') as PhoneInput).isValid, isFalse);
    expect((SignInInput.parse('5876543210') as PhoneInput).isValid, isFalse);
  });

  test('anything with @ is an email', () {
    expect(SignInInput.parse('dr.rao@example.com'), isA<EmailInput>());
  });

  test('anything else is not recognised', () {
    expect(SignInInput.parse('priya'), isA<UnrecognisedInput>());
    expect(SignInInput.parse(''), isA<UnrecognisedInput>());
  });
}
