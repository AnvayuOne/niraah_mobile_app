import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/shared/helpers/validator_helper.dart';

void main() {
  test('required validator returns error for empty field', () {
    final String? result = ValidatorHelper.requiredField('', fieldName: 'Name');
    expect(result, 'Name is required');
  });

  test('email validator returns null for valid email', () {
    final String? result = ValidatorHelper.email('test@example.com');
    expect(result, isNull);
  });
}
