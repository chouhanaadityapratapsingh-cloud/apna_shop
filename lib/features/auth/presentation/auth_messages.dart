import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/core/utils/validators.dart';
import 'package:apna_shop/l10n/app_localizations.dart';

String fieldErrorText(AppLocalizations l10n, FieldError error) {
  return switch (error) {
    FieldError.required => l10n.fieldRequired,
    FieldError.invalidEmail => l10n.emailInvalid,
    FieldError.passwordTooShort => l10n.passwordTooShort(
      Validators.minPasswordLength,
    ),
    FieldError.passwordsDoNotMatch => l10n.passwordsDoNotMatch,
  };
}

/// User-facing text for any error thrown by a repository.
String errorText(AppLocalizations l10n, Object error) {
  if (error is! AppException) return l10n.errorUnknown;
  return switch (error.type) {
    AppErrorType.invalidCredentials => l10n.errorInvalidCredentials,
    AppErrorType.invalidEmail => l10n.errorInvalidEmail,
    AppErrorType.emailInUse => l10n.errorEmailInUse,
    AppErrorType.weakPassword => l10n.errorWeakPassword,
    AppErrorType.network => l10n.errorNetwork,
    AppErrorType.tooManyRequests => l10n.errorTooManyRequests,
    AppErrorType.userDisabled => l10n.errorUserDisabled,
    AppErrorType.permissionDenied => l10n.errorPermissionDenied,
    AppErrorType.storeAlreadyExists => l10n.errorStoreAlreadyExists,
    AppErrorType.duplicateBarcode => l10n.errorDuplicateBarcode,
    AppErrorType.productNotFound => l10n.productNotFound,
    AppErrorType.insufficientStock => l10n.errorInsufficientStock,
    AppErrorType.priceChanged => l10n.errorPriceChanged,
    AppErrorType.overpayment => l10n.errorOverpayment,
    AppErrorType.unknown => l10n.errorUnknown,
  };
}
