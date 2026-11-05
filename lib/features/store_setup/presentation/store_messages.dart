import 'package:apna_shop/features/store_setup/domain/store_role.dart';
import 'package:apna_shop/features/store_setup/domain/store_validators.dart';
import 'package:apna_shop/l10n/app_localizations.dart';

String storeFieldErrorText(AppLocalizations l10n, StoreFieldError error) {
  return switch (error) {
    StoreFieldError.required => l10n.fieldRequired,
    StoreFieldError.nameTooShort => l10n.storeNameTooShort(
      StoreValidators.nameMinLength,
    ),
    StoreFieldError.nameTooLong => l10n.storeNameTooLong(
      StoreValidators.nameMaxLength,
    ),
    StoreFieldError.cityTooLong => l10n.storeCityTooLong(
      StoreValidators.cityMaxLength,
    ),
    StoreFieldError.invalidPhone => l10n.storePhoneInvalid,
  };
}

String roleLabel(AppLocalizations l10n, StoreRole role) {
  return switch (role) {
    StoreRole.owner => l10n.roleOwner,
    StoreRole.manager => l10n.roleManager,
    StoreRole.staff => l10n.roleStaff,
  };
}
