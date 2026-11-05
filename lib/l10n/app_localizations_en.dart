// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Apna Shop';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signInSubtitle => 'Sign in to manage your shop\'s stock.';

  @override
  String get signUpTitle => 'Create account';

  @override
  String get signUpSubtitle => 'Create an account to get started.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get signInButton => 'Sign in';

  @override
  String get signUpButton => 'Create account';

  @override
  String get noAccountPrompt => 'New to Apna Shop?';

  @override
  String get createAccountLink => 'Create an account';

  @override
  String get haveAccountPrompt => 'Already have an account?';

  @override
  String get signInLink => 'Sign in';

  @override
  String get loading => 'Loading';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get emailInvalid => 'Enter a valid email address';

  @override
  String passwordTooShort(int min) {
    return 'Password must be at least $min characters';
  }

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get errorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get errorInvalidEmail => 'That email address doesn\'t look right.';

  @override
  String get errorEmailInUse =>
      'An account with this email already exists. Try signing in.';

  @override
  String get errorWeakPassword => 'Choose a stronger password.';

  @override
  String get errorNetwork =>
      'No internet connection. Check your connection and try again.';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String get errorUserDisabled => 'This account has been disabled.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get navHome => 'Home';

  @override
  String get navProducts => 'Products';

  @override
  String get navActivity => 'Activity';

  @override
  String get navReports => 'Reports';

  @override
  String get navProfile => 'Profile';

  @override
  String get comingSoonTitle => 'Not available yet';

  @override
  String get comingSoonBody =>
      'This section is being built and will arrive in a later update.';

  @override
  String homeWelcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String get homeNextStepTitle => 'Next step: add your products';

  @override
  String get homeNextStepBody =>
      'Product management is not available yet. It will be added in the next update.';

  @override
  String get profileSignedInAs => 'Signed in as';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutConfirmTitle => 'Sign out?';

  @override
  String get signOutConfirmBody =>
      'You will need to sign in again to use Apna Shop.';

  @override
  String get cancel => 'Cancel';

  @override
  String get setupRequiredTitle => 'Firebase setup needed';

  @override
  String get setupRequiredBody =>
      'This build is not connected to a Firebase project yet. Run \'flutterfire configure\' for your Apna Shop Firebase project, then restart the app.';

  @override
  String get createStoreTitle => 'Set up your store';

  @override
  String get createStoreSubtitle =>
      'Tell us a little about your shop. You can add products next.';

  @override
  String get storeNameLabel => 'Store name';

  @override
  String get storeCityLabel => 'City (optional)';

  @override
  String get storePhoneLabel => 'Phone number (optional)';

  @override
  String get createStoreButton => 'Create store';

  @override
  String get createStoreOnlineNote =>
      'Creating a store needs an internet connection.';

  @override
  String storeNameTooShort(int min) {
    return 'Store name must be at least $min characters';
  }

  @override
  String storeNameTooLong(int max) {
    return 'Store name can be at most $max characters';
  }

  @override
  String storeCityTooLong(int max) {
    return 'City can be at most $max characters';
  }

  @override
  String get storePhoneInvalid => 'Enter a valid 10-digit mobile number';

  @override
  String get errorPermissionDenied => 'You don\'t have permission to do this.';

  @override
  String get errorStoreAlreadyExists => 'You already have a store.';

  @override
  String get storeLoadErrorTitle => 'Couldn\'t load your store';

  @override
  String get storeLoadErrorBody =>
      'Check your internet connection and try again.';

  @override
  String get retry => 'Try again';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleStaff => 'Staff';

  @override
  String homeRole(String role) {
    return 'Your role: $role';
  }
}
