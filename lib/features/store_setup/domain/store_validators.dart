enum StoreFieldError {
  required,
  nameTooShort,
  nameTooLong,
  cityTooLong,
  invalidPhone,
}

abstract final class StoreValidators {
  // These limits are also enforced by firestore.rules.
  static const int nameMinLength = 2;
  static const int nameMaxLength = 80;
  static const int cityMaxLength = 80;

  static final RegExp _whitespace = RegExp(r'\s+');
  static final RegExp _separators = RegExp(r'[\s\-()]');
  static final RegExp _indianMobile = RegExp(r'^[6-9]\d{9}$');

  /// Trims and collapses repeated spaces.
  static String normalizeText(String? value) {
    return (value ?? '').trim().replaceAll(_whitespace, ' ');
  }

  /// Returns the 10-digit national number, or null for empty input.
  /// Accepts a leading +91, 91 or 0. Does not check the digits themselves.
  static String? normalizePhone(String? value) {
    final cleaned = (value ?? '').replaceAll(_separators, '');
    if (cleaned.isEmpty) return null;
    if (cleaned.startsWith('+91') && cleaned.length == 13) {
      return cleaned.substring(3);
    }
    if (cleaned.startsWith('91') && cleaned.length == 12) {
      return cleaned.substring(2);
    }
    if (cleaned.startsWith('0') && cleaned.length == 11) {
      return cleaned.substring(1);
    }
    return cleaned;
  }

  static StoreFieldError? name(String? value) {
    final name = normalizeText(value);
    if (name.isEmpty) return StoreFieldError.required;
    if (name.length < nameMinLength) return StoreFieldError.nameTooShort;
    if (name.length > nameMaxLength) return StoreFieldError.nameTooLong;
    return null;
  }

  /// City is optional.
  static StoreFieldError? city(String? value) {
    return normalizeText(value).length > cityMaxLength
        ? StoreFieldError.cityTooLong
        : null;
  }

  /// Phone is optional; when present it must be a valid Indian mobile number.
  static StoreFieldError? phone(String? value) {
    final normalized = normalizePhone(value);
    if (normalized == null) return null;
    return _indianMobile.hasMatch(normalized)
        ? null
        : StoreFieldError.invalidPhone;
  }
}
