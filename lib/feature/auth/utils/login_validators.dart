// Pure-Dart validation helpers for the admin sign-in form.
// Keeps email and password validation rules reusable and testable.

class LoginValidators {
  const LoginValidators._();

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty || !text.contains('@')) {
      return 'Enter a valid admin email address.';
    }
    return null;
  }

  static String? password(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Enter your password.';
    }
    return null;
  }
}
