/// Reasons a form field can be invalid. The UI turns these into localized text.
enum FieldError {
  required,
  invalidEmail,
  passwordTooShort,
  passwordsDoNotMatch,
}

abstract final class Validators {
  /// Firebase Authentication rejects passwords shorter than 6 characters.
  static const int minPasswordLength = 6;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static FieldError? requiredText(String? value) {
    return (value == null || value.isEmpty) ? FieldError.required : null;
  }

  static FieldError? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return FieldError.required;
    if (!_emailPattern.hasMatch(trimmed)) return FieldError.invalidEmail;
    return null;
  }

  /// For creating a password (enforces the minimum length).
  static FieldError? newPassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return FieldError.required;
    if (password.length < minPasswordLength) return FieldError.passwordTooShort;
    return null;
  }

  static FieldError? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return FieldError.required;
    if (value != password) return FieldError.passwordsDoNotMatch;
    return null;
  }
}
