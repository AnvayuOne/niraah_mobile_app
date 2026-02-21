class ValidatorHelper {
  const ValidatorHelper._();

  static String? requiredField(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final RegExp regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }
}
