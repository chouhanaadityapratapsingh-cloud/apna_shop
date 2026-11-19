import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Apna Shop'**
  String get appName;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your shop\'s stock.'**
  String get signInSubtitle;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account to get started.'**
  String get signUpSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpButton;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'New to Apna Shop?'**
  String get noAccountPrompt;

  /// No description provided for @createAccountLink.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccountLink;

  /// No description provided for @haveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccountPrompt;

  /// No description provided for @signInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInLink;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get emailInvalid;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {min} characters'**
  String passwordTooShort(int min);

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'That email address doesn\'t look right.'**
  String get errorInvalidEmail;

  /// No description provided for @errorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Try signing in.'**
  String get errorEmailInUse;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a stronger password.'**
  String get errorWeakPassword;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your connection and try again.'**
  String get errorNetwork;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get errorTooManyRequests;

  /// No description provided for @errorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get errorUserDisabled;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnknown;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get navProducts;

  /// No description provided for @navActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get navActivity;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @comingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Not available yet'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'This section is being built and will arrive in a later update.'**
  String get comingSoonBody;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String homeWelcome(String name);

  /// No description provided for @homeNextStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Next step: add your products'**
  String get homeNextStepTitle;

  /// No description provided for @homeNextStepBody.
  ///
  /// In en, this message translates to:
  /// **'Product management is not available yet. It will be added in the next update.'**
  String get homeNextStepBody;

  /// No description provided for @profileSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get profileSignedInAs;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to use Apna Shop.'**
  String get signOutConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @setupRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Firebase setup needed'**
  String get setupRequiredTitle;

  /// No description provided for @setupRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'This build is not connected to a Firebase project yet. Run \'flutterfire configure\' for your Apna Shop Firebase project, then restart the app.'**
  String get setupRequiredBody;

  /// No description provided for @createStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your store'**
  String get createStoreTitle;

  /// No description provided for @createStoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us a little about your shop. You can add products next.'**
  String get createStoreSubtitle;

  /// No description provided for @storeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Store name'**
  String get storeNameLabel;

  /// No description provided for @storeCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City (optional)'**
  String get storeCityLabel;

  /// No description provided for @storePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number (optional)'**
  String get storePhoneLabel;

  /// No description provided for @createStoreButton.
  ///
  /// In en, this message translates to:
  /// **'Create store'**
  String get createStoreButton;

  /// No description provided for @createStoreOnlineNote.
  ///
  /// In en, this message translates to:
  /// **'Creating a store needs an internet connection.'**
  String get createStoreOnlineNote;

  /// No description provided for @storeNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Store name must be at least {min} characters'**
  String storeNameTooShort(int min);

  /// No description provided for @storeNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Store name can be at most {max} characters'**
  String storeNameTooLong(int max);

  /// No description provided for @storeCityTooLong.
  ///
  /// In en, this message translates to:
  /// **'City can be at most {max} characters'**
  String storeCityTooLong(int max);

  /// No description provided for @storePhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit mobile number'**
  String get storePhoneInvalid;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to do this.'**
  String get errorPermissionDenied;

  /// No description provided for @errorStoreAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'You already have a store.'**
  String get errorStoreAlreadyExists;

  /// No description provided for @storeLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your store'**
  String get storeLoadErrorTitle;

  /// No description provided for @storeLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get storeLoadErrorBody;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get roleManager;

  /// No description provided for @roleStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get roleStaff;

  /// No description provided for @homeRole.
  ///
  /// In en, this message translates to:
  /// **'Your role: {role}'**
  String homeRole(String role);

  /// No description provided for @productsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, SKU or barcode'**
  String get productsSearchHint;

  /// No description provided for @productsLowStockFilter.
  ///
  /// In en, this message translates to:
  /// **'Low stock only'**
  String get productsLowStockFilter;

  /// No description provided for @productsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get productsEmptyTitle;

  /// No description provided for @productsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first product to start tracking stock.'**
  String get productsEmptyBody;

  /// No description provided for @productsNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching products'**
  String get productsNoMatchTitle;

  /// No description provided for @productsNoMatchBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different name, or clear the filters.'**
  String get productsNoMatchBody;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @productsLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load products'**
  String get productsLoadErrorTitle;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProduct;

  /// No description provided for @lowStockBadge.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get lowStockBadge;

  /// No description provided for @lowStockLine.
  ///
  /// In en, this message translates to:
  /// **'Only {quantity} left'**
  String lowStockLine(String quantity);

  /// No description provided for @detailsInStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get detailsInStock;

  /// No description provided for @detailsSellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Selling price'**
  String get detailsSellingPrice;

  /// No description provided for @detailsPurchasePrice.
  ///
  /// In en, this message translates to:
  /// **'Purchase price'**
  String get detailsPurchasePrice;

  /// No description provided for @detailsLowStockAt.
  ///
  /// In en, this message translates to:
  /// **'Low stock at'**
  String get detailsLowStockAt;

  /// No description provided for @detailsCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get detailsCategory;

  /// No description provided for @detailsBarcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get detailsBarcode;

  /// No description provided for @detailsSku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get detailsSku;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'This product no longer exists.'**
  String get productNotFound;

  /// No description provided for @productArchivedNote.
  ///
  /// In en, this message translates to:
  /// **'This product is archived.'**
  String get productArchivedNote;

  /// No description provided for @archiveProduct.
  ///
  /// In en, this message translates to:
  /// **'Archive product'**
  String get archiveProduct;

  /// No description provided for @archiveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive this product?'**
  String get archiveConfirmTitle;

  /// No description provided for @archiveConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'It will disappear from your list. Its history is kept, and its barcode can be used again.'**
  String get archiveConfirmBody;

  /// No description provided for @archiveAction.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveAction;

  /// No description provided for @productNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get productNameLabel;

  /// No description provided for @productBarcodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Barcode (optional)'**
  String get productBarcodeLabel;

  /// No description provided for @productSkuLabel.
  ///
  /// In en, this message translates to:
  /// **'SKU (optional)'**
  String get productSkuLabel;

  /// No description provided for @productCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category (optional)'**
  String get productCategoryLabel;

  /// No description provided for @productUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get productUnitLabel;

  /// No description provided for @purchasePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Purchase price in ₹ (optional)'**
  String get purchasePriceLabel;

  /// No description provided for @sellingPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Selling price in ₹'**
  String get sellingPriceLabel;

  /// No description provided for @openingQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Opening stock'**
  String get openingQuantityLabel;

  /// No description provided for @lowStockThresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'Warn me when stock is at or below'**
  String get lowStockThresholdLabel;

  /// No description provided for @saveProduct.
  ///
  /// In en, this message translates to:
  /// **'Save product'**
  String get saveProduct;

  /// No description provided for @productOnlineNote.
  ///
  /// In en, this message translates to:
  /// **'Saving needs an internet connection.'**
  String get productOnlineNote;

  /// No description provided for @quantityEditNote.
  ///
  /// In en, this message translates to:
  /// **'Stock quantity cannot be edited here. Use Stock in, Stock out or Adjust stock on the product page.'**
  String get quantityEditNote;

  /// No description provided for @productNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least {min} characters'**
  String productNameTooShort(int min);

  /// No description provided for @productNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name can be at most {max} characters'**
  String productNameTooLong(int max);

  /// No description provided for @productBarcodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use 4 to 32 letters, numbers or dashes'**
  String get productBarcodeInvalid;

  /// No description provided for @productSkuTooLong.
  ///
  /// In en, this message translates to:
  /// **'SKU can be at most {max} characters'**
  String productSkuTooLong(int max);

  /// No description provided for @productCategoryTooLong.
  ///
  /// In en, this message translates to:
  /// **'Category can be at most {max} characters'**
  String productCategoryTooLong(int max);

  /// No description provided for @priceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a price like 25 or 25.50'**
  String get priceInvalid;

  /// No description provided for @wholeNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number from 0 to {max}'**
  String wholeNumberInvalid(int max);

  /// No description provided for @errorDuplicateBarcode.
  ///
  /// In en, this message translates to:
  /// **'Another product in this store already uses this barcode.'**
  String get errorDuplicateBarcode;

  /// No description provided for @unitPiece.
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get unitPiece;

  /// No description provided for @unitPacket.
  ///
  /// In en, this message translates to:
  /// **'Packet'**
  String get unitPacket;

  /// No description provided for @unitBox.
  ///
  /// In en, this message translates to:
  /// **'Box'**
  String get unitBox;

  /// No description provided for @unitBottle.
  ///
  /// In en, this message translates to:
  /// **'Bottle'**
  String get unitBottle;

  /// No description provided for @unitPack.
  ///
  /// In en, this message translates to:
  /// **'Pack'**
  String get unitPack;

  /// No description provided for @quantityPiece.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 piece} other{{count} pieces}}'**
  String quantityPiece(int count);

  /// No description provided for @quantityPacket.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 packet} other{{count} packets}}'**
  String quantityPacket(int count);

  /// No description provided for @quantityBox.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 box} other{{count} boxes}}'**
  String quantityBox(int count);

  /// No description provided for @quantityBottle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bottle} other{{count} bottles}}'**
  String quantityBottle(int count);

  /// No description provided for @quantityPack.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pack} other{{count} packs}}'**
  String quantityPack(int count);

  /// No description provided for @stockIn.
  ///
  /// In en, this message translates to:
  /// **'Stock in'**
  String get stockIn;

  /// No description provided for @stockOut.
  ///
  /// In en, this message translates to:
  /// **'Stock out'**
  String get stockOut;

  /// No description provided for @stockAdjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust stock'**
  String get stockAdjust;

  /// No description provided for @stockHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock history'**
  String get stockHistoryTitle;

  /// No description provided for @stockHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No stock movements yet.'**
  String get stockHistoryEmpty;

  /// No description provided for @stockAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get stockAmountLabel;

  /// No description provided for @stockCountedLabel.
  ///
  /// In en, this message translates to:
  /// **'Counted quantity on the shelf'**
  String get stockCountedLabel;

  /// No description provided for @stockReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get stockReasonLabel;

  /// No description provided for @stockNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get stockNoteLabel;

  /// No description provided for @stockSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get stockSave;

  /// No description provided for @stockCurrentLine.
  ///
  /// In en, this message translates to:
  /// **'Currently in stock: {current}'**
  String stockCurrentLine(String current);

  /// No description provided for @stockSavedSnack.
  ///
  /// In en, this message translates to:
  /// **'Saved. Now in stock: {quantity}'**
  String stockSavedSnack(String quantity);

  /// No description provided for @stockAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number, like 12'**
  String get stockAmountInvalid;

  /// No description provided for @stockInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Only {current} in stock. You cannot take out more.'**
  String stockInsufficient(String current);

  /// No description provided for @stockTooMuch.
  ///
  /// In en, this message translates to:
  /// **'That would go over the maximum stock.'**
  String get stockTooMuch;

  /// No description provided for @stockNoChange.
  ///
  /// In en, this message translates to:
  /// **'This is the same as the recorded stock.'**
  String get stockNoChange;

  /// No description provided for @reasonPurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get reasonPurchase;

  /// No description provided for @reasonSale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get reasonSale;

  /// No description provided for @reasonReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get reasonReturned;

  /// No description provided for @reasonDamaged.
  ///
  /// In en, this message translates to:
  /// **'Damaged'**
  String get reasonDamaged;

  /// No description provided for @reasonExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get reasonExpired;

  /// No description provided for @reasonCorrection.
  ///
  /// In en, this message translates to:
  /// **'Correction'**
  String get reasonCorrection;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// No description provided for @errorInsufficientStock.
  ///
  /// In en, this message translates to:
  /// **'Stock changed or is not enough. Please check and try again.'**
  String get errorInsufficientStock;

  /// No description provided for @activityEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get activityEmptyTitle;

  /// No description provided for @activityEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Stock in, stock out and adjustments will appear here.'**
  String get activityEmptyBody;

  /// No description provided for @activityLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load activity'**
  String get activityLoadErrorTitle;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get scanBarcode;

  /// No description provided for @scannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan a barcode'**
  String get scannerTitle;

  /// No description provided for @scannerHint.
  ///
  /// In en, this message translates to:
  /// **'Hold the barcode inside the camera view. If the camera does not work, type the barcode.'**
  String get scannerHint;

  /// No description provided for @scannerTorch.
  ///
  /// In en, this message translates to:
  /// **'Flash'**
  String get scannerTorch;

  /// No description provided for @scannerManualEntry.
  ///
  /// In en, this message translates to:
  /// **'Type the barcode instead'**
  String get scannerManualEntry;

  /// No description provided for @scannerManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Type the barcode'**
  String get scannerManualTitle;

  /// No description provided for @scannerUseCode.
  ///
  /// In en, this message translates to:
  /// **'Use this barcode'**
  String get scannerUseCode;

  /// No description provided for @scannerUnusableCode.
  ///
  /// In en, this message translates to:
  /// **'This code cannot be used as a barcode here.'**
  String get scannerUnusableCode;

  /// No description provided for @scannerNoProductTitle.
  ///
  /// In en, this message translates to:
  /// **'No product with this barcode'**
  String get scannerNoProductTitle;

  /// No description provided for @scannerNoProductBody.
  ///
  /// In en, this message translates to:
  /// **'No product has the barcode {code} yet.'**
  String scannerNoProductBody(String code);

  /// No description provided for @lookupButton.
  ///
  /// In en, this message translates to:
  /// **'Look up details'**
  String get lookupButton;

  /// No description provided for @lookupLoading.
  ///
  /// In en, this message translates to:
  /// **'Looking up…'**
  String get lookupLoading;

  /// No description provided for @lookupFound.
  ///
  /// In en, this message translates to:
  /// **'Details filled from the Open Food Facts list. Please check them and add the price yourself.'**
  String get lookupFound;

  /// No description provided for @lookupNotFound.
  ///
  /// In en, this message translates to:
  /// **'This barcode is not in the online list. Type the details yourself.'**
  String get lookupNotFound;

  /// No description provided for @lookupFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not look up details. Check your internet and try again.'**
  String get lookupFailed;

  /// No description provided for @lookupNeedBarcode.
  ///
  /// In en, this message translates to:
  /// **'Enter or scan a valid barcode first.'**
  String get lookupNeedBarcode;

  /// No description provided for @productBrandLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand (optional)'**
  String get productBrandLabel;

  /// No description provided for @productBrandTooLong.
  ///
  /// In en, this message translates to:
  /// **'Brand can be at most {max} characters'**
  String productBrandTooLong(int max);

  /// No description provided for @imageCredit.
  ///
  /// In en, this message translates to:
  /// **'Picture: Open Food Facts (CC BY-SA)'**
  String get imageCredit;

  /// No description provided for @removePicture.
  ///
  /// In en, this message translates to:
  /// **'Remove picture'**
  String get removePicture;

  /// No description provided for @priceHint.
  ///
  /// In en, this message translates to:
  /// **'Others reported {price} (on {date}). It may be old or from another shop.'**
  String priceHint(String price, String date);

  /// No description provided for @priceHintUse.
  ///
  /// In en, this message translates to:
  /// **'Use as selling price'**
  String get priceHintUse;

  /// No description provided for @pickCommonItem.
  ///
  /// In en, this message translates to:
  /// **'Pick from common items'**
  String get pickCommonItem;

  /// No description provided for @starterTitle.
  ///
  /// In en, this message translates to:
  /// **'Common items'**
  String get starterTitle;

  /// No description provided for @starterNote.
  ///
  /// In en, this message translates to:
  /// **'Only names are filled. Scan the barcode and add price and stock yourself. Items are in packed sizes.'**
  String get starterNote;

  /// No description provided for @starterSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search items, brands or Hindi names'**
  String get starterSearchHint;

  /// No description provided for @starterNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No matching item. Add it yourself.'**
  String get starterNoMatch;

  /// No description provided for @navBill.
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get navBill;

  /// No description provided for @errorPriceChanged.
  ///
  /// In en, this message translates to:
  /// **'A price changed while you were billing. Please check the items and try again.'**
  String get errorPriceChanged;

  /// No description provided for @billTitle.
  ///
  /// In en, this message translates to:
  /// **'New bill'**
  String get billTitle;

  /// No description provided for @billClear.
  ///
  /// In en, this message translates to:
  /// **'Clear bill'**
  String get billClear;

  /// No description provided for @billHistory.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get billHistory;

  /// No description provided for @billScanItem.
  ///
  /// In en, this message translates to:
  /// **'Scan item'**
  String get billScanItem;

  /// No description provided for @billAddByName.
  ///
  /// In en, this message translates to:
  /// **'By name'**
  String get billAddByName;

  /// No description provided for @billEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get billEmptyTitle;

  /// No description provided for @billEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Scan an item\'s barcode to add it to the bill.'**
  String get billEmptyBody;

  /// No description provided for @billNotInInventory.
  ///
  /// In en, this message translates to:
  /// **'Barcode {code} is not in your inventory.'**
  String billNotInInventory(String code);

  /// No description provided for @billOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get billOutOfStock;

  /// No description provided for @billNotEnoughStock.
  ///
  /// In en, this message translates to:
  /// **'Not enough stock'**
  String get billNotEnoughStock;

  /// No description provided for @billProductArchived.
  ///
  /// In en, this message translates to:
  /// **'This item is archived'**
  String get billProductArchived;

  /// No description provided for @billCartFull.
  ///
  /// In en, this message translates to:
  /// **'A bill can have at most {max} different items.'**
  String billCartFull(int max);

  /// No description provided for @billInStock.
  ///
  /// In en, this message translates to:
  /// **'In stock: {quantity}'**
  String billInStock(String quantity);

  /// No description provided for @billDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get billDecrease;

  /// No description provided for @billIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get billIncrease;

  /// No description provided for @billItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String billItemsCount(int count);

  /// No description provided for @billDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get billDiscount;

  /// No description provided for @billDiscountHint.
  ///
  /// In en, this message translates to:
  /// **'Discount in rupees'**
  String get billDiscountHint;

  /// No description provided for @billApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get billApply;

  /// No description provided for @billTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get billTotal;

  /// No description provided for @billSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get billSubtotal;

  /// No description provided for @billMakeBill.
  ///
  /// In en, this message translates to:
  /// **'Make bill'**
  String get billMakeBill;

  /// No description provided for @billSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Bill saved'**
  String get billSavedTitle;

  /// No description provided for @billNotFound.
  ///
  /// In en, this message translates to:
  /// **'Bill not found'**
  String get billNotFound;

  /// No description provided for @billNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Bill no. {number}'**
  String billNumberLabel(int number);

  /// No description provided for @billNewBill.
  ///
  /// In en, this message translates to:
  /// **'New bill'**
  String get billNewBill;

  /// No description provided for @billHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bills yet.'**
  String get billHistoryEmpty;

  /// No description provided for @payTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payTitle;

  /// No description provided for @payFullCash.
  ///
  /// In en, this message translates to:
  /// **'Full cash'**
  String get payFullCash;

  /// No description provided for @payFullUpi.
  ///
  /// In en, this message translates to:
  /// **'Full UPI'**
  String get payFullUpi;

  /// No description provided for @payFullUdhar.
  ///
  /// In en, this message translates to:
  /// **'Full udhar'**
  String get payFullUdhar;

  /// No description provided for @payCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get payCash;

  /// No description provided for @payUpi.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get payUpi;

  /// No description provided for @payUdhar.
  ///
  /// In en, this message translates to:
  /// **'Udhar'**
  String get payUdhar;

  /// No description provided for @payUdharHint.
  ///
  /// In en, this message translates to:
  /// **'Whatever is not paid now'**
  String get payUdharHint;

  /// No description provided for @payTooMuch.
  ///
  /// In en, this message translates to:
  /// **'Cash + UPI is more than the total.'**
  String get payTooMuch;

  /// No description provided for @payNotBalanced.
  ///
  /// In en, this message translates to:
  /// **'Cash + UPI + udhar must equal the total.'**
  String get payNotBalanced;

  /// No description provided for @payCustomerPhone.
  ///
  /// In en, this message translates to:
  /// **'Customer mobile number'**
  String get payCustomerPhone;

  /// No description provided for @payCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Customer name'**
  String get payCustomerName;

  /// No description provided for @payCustomerNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the customer\'s name for udhar.'**
  String get payCustomerNameRequired;

  /// No description provided for @payCustomerPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit mobile number.'**
  String get payCustomerPhoneInvalid;

  /// No description provided for @payCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get payCustomer;

  /// No description provided for @payOldUdhar.
  ///
  /// In en, this message translates to:
  /// **'{name} already owes {amount}.'**
  String payOldUdhar(String name, String amount);

  /// No description provided for @payUseName.
  ///
  /// In en, this message translates to:
  /// **'Use \"{name}\"'**
  String payUseName(String name);

  /// No description provided for @payConfirm.
  ///
  /// In en, this message translates to:
  /// **'Save bill'**
  String get payConfirm;

  /// No description provided for @pdfOpen.
  ///
  /// In en, this message translates to:
  /// **'Bill PDF: print / share / download'**
  String get pdfOpen;

  /// No description provided for @pdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Bill PDF'**
  String get pdfTitle;

  /// No description provided for @pdfTemplateClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get pdfTemplateClassic;

  /// No description provided for @pdfTemplateModern.
  ///
  /// In en, this message translates to:
  /// **'Modern'**
  String get pdfTemplateModern;

  /// No description provided for @pdfTemplateThermal.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get pdfTemplateThermal;

  /// No description provided for @pdfTemplateMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get pdfTemplateMinimal;

  /// No description provided for @pdfPrint.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get pdfPrint;

  /// No description provided for @pdfShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get pdfShare;

  /// No description provided for @pdfDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get pdfDownload;

  /// No description provided for @pdfSaved.
  ///
  /// In en, this message translates to:
  /// **'PDF saved.'**
  String get pdfSaved;

  /// No description provided for @pdfActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete this. Please try again.'**
  String get pdfActionFailed;

  /// No description provided for @payCustomerOptionalTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer (optional - printed on the bill)'**
  String get payCustomerOptionalTitle;

  /// No description provided for @payCustomerNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Customer name (optional)'**
  String get payCustomerNameOptional;

  /// No description provided for @payCustomerPhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Customer mobile (optional)'**
  String get payCustomerPhoneOptional;

  /// No description provided for @billMakeNew.
  ///
  /// In en, this message translates to:
  /// **'Make a new bill'**
  String get billMakeNew;

  /// No description provided for @dashToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dashToday;

  /// No description provided for @dashYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dashYesterday;

  /// No description provided for @dashLast7Days.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get dashLast7Days;

  /// No description provided for @dashSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get dashSales;

  /// No description provided for @dashBillsItems.
  ///
  /// In en, this message translates to:
  /// **'{bills} bills • {items} items'**
  String dashBillsItems(int bills, int items);

  /// No description provided for @dashTruncated.
  ///
  /// In en, this message translates to:
  /// **'Showing the latest 500 bills only.'**
  String get dashTruncated;

  /// No description provided for @dashLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load sales.'**
  String get dashLoadError;

  /// No description provided for @dashOwnSalesNote.
  ///
  /// In en, this message translates to:
  /// **'You see only the bills you made.'**
  String get dashOwnSalesNote;

  /// No description provided for @dashUdharPending.
  ///
  /// In en, this message translates to:
  /// **'Udhar pending'**
  String get dashUdharPending;

  /// No description provided for @dashUdharCustomers.
  ///
  /// In en, this message translates to:
  /// **'{count} customers'**
  String dashUdharCustomers(int count);

  /// No description provided for @dashLowStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Low stock: {count} items'**
  String dashLowStockTitle(int count);

  /// No description provided for @dashOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'{count} out of stock'**
  String dashOutOfStock(int count);

  /// No description provided for @dashAllStocked.
  ///
  /// In en, this message translates to:
  /// **'Everything is above its low-stock level.'**
  String get dashAllStocked;

  /// No description provided for @dashViewAllProducts.
  ///
  /// In en, this message translates to:
  /// **'See all products'**
  String get dashViewAllProducts;

  /// No description provided for @navUdhar.
  ///
  /// In en, this message translates to:
  /// **'Udhar'**
  String get navUdhar;

  /// No description provided for @errorOverpayment.
  ///
  /// In en, this message translates to:
  /// **'That is more than the customer owes. Please check the amount.'**
  String get errorOverpayment;

  /// No description provided for @udharTitle.
  ///
  /// In en, this message translates to:
  /// **'Udhar'**
  String get udharTitle;

  /// No description provided for @udharTotal.
  ///
  /// In en, this message translates to:
  /// **'Total udhar'**
  String get udharTotal;

  /// No description provided for @udharSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search name or mobile number'**
  String get udharSearchHint;

  /// No description provided for @udharShowSettled.
  ///
  /// In en, this message translates to:
  /// **'Show settled'**
  String get udharShowSettled;

  /// No description provided for @udharSettled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get udharSettled;

  /// No description provided for @udharEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No udhar yet. When a bill has udhar, the customer appears here.'**
  String get udharEmptyBody;

  /// No description provided for @udharNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No matching customer.'**
  String get udharNoMatch;

  /// No description provided for @udharLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load udhar.'**
  String get udharLoadError;

  /// No description provided for @udharCustomerMissing.
  ///
  /// In en, this message translates to:
  /// **'Customer not found.'**
  String get udharCustomerMissing;

  /// No description provided for @udharBalance.
  ///
  /// In en, this message translates to:
  /// **'Udhar balance'**
  String get udharBalance;

  /// No description provided for @udharRecordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record payment received'**
  String get udharRecordPayment;

  /// No description provided for @udharLedger.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get udharLedger;

  /// No description provided for @udharEntryCredit.
  ///
  /// In en, this message translates to:
  /// **'Udhar (bill)'**
  String get udharEntryCredit;

  /// No description provided for @udharEntryPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment received ({method})'**
  String udharEntryPayment(String method);

  /// No description provided for @udharPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment received'**
  String get udharPaymentTitle;

  /// No description provided for @udharDueNow.
  ///
  /// In en, this message translates to:
  /// **'Udhar due: {amount}'**
  String udharDueNow(String amount);

  /// No description provided for @udharAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount received'**
  String get udharAmountLabel;

  /// No description provided for @udharFullAmount.
  ///
  /// In en, this message translates to:
  /// **'Full amount'**
  String get udharFullAmount;

  /// No description provided for @udharNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get udharNoteLabel;

  /// No description provided for @udharSavePayment.
  ///
  /// In en, this message translates to:
  /// **'Save payment'**
  String get udharSavePayment;

  /// No description provided for @udharOverpay.
  ///
  /// In en, this message translates to:
  /// **'More than the udhar of {amount}'**
  String udharOverpay(String amount);

  /// No description provided for @shopDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop details'**
  String get shopDetailsTitle;

  /// No description provided for @shopDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Name, address, phone and UPI printed on bills'**
  String get shopDetailsSubtitle;

  /// No description provided for @shopDetailsNote.
  ///
  /// In en, this message translates to:
  /// **'These details are printed at the top and bottom of every bill PDF. Only the owner can change them.'**
  String get shopDetailsNote;

  /// No description provided for @shopAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address (optional)'**
  String get shopAddressLabel;

  /// No description provided for @shopUpiLabel.
  ///
  /// In en, this message translates to:
  /// **'UPI ID (optional)'**
  String get shopUpiLabel;

  /// No description provided for @shopUpiHelper.
  ///
  /// In en, this message translates to:
  /// **'Example: yourshop@okhdfcbank'**
  String get shopUpiHelper;

  /// No description provided for @shopFooterLabel.
  ///
  /// In en, this message translates to:
  /// **'Bottom line on bill (optional)'**
  String get shopFooterLabel;

  /// No description provided for @shopFooterHelper.
  ///
  /// In en, this message translates to:
  /// **'Example: Thank you! Visit again.'**
  String get shopFooterHelper;

  /// No description provided for @shopSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get shopSave;

  /// No description provided for @shopSaved.
  ///
  /// In en, this message translates to:
  /// **'Shop details saved.'**
  String get shopSaved;

  /// No description provided for @storeAddressTooLong.
  ///
  /// In en, this message translates to:
  /// **'Address can be at most {max} characters'**
  String storeAddressTooLong(int max);

  /// No description provided for @storeFooterTooLong.
  ///
  /// In en, this message translates to:
  /// **'This line can be at most {max} characters'**
  String storeFooterTooLong(int max);

  /// No description provided for @storeUpiInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid UPI ID like name@bank'**
  String get storeUpiInvalid;

  /// No description provided for @reportsOpen.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsOpen;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales report'**
  String get reportsTitle;

  /// No description provided for @reportsLast30Days.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get reportsLast30Days;

  /// No description provided for @reportsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get reportsThisMonth;

  /// No description provided for @reportsCustom.
  ///
  /// In en, this message translates to:
  /// **'Pick dates'**
  String get reportsCustom;

  /// No description provided for @reportsExport.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get reportsExport;

  /// No description provided for @reportsExported.
  ///
  /// In en, this message translates to:
  /// **'CSV saved.'**
  String get reportsExported;

  /// No description provided for @reportsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bills in this period.'**
  String get reportsEmpty;

  /// No description provided for @reportsTruncated.
  ///
  /// In en, this message translates to:
  /// **'Showing the latest {limit} bills only.'**
  String reportsTruncated(int limit);

  /// No description provided for @reportsProfit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get reportsProfit;

  /// No description provided for @reportsNoProfit.
  ///
  /// In en, this message translates to:
  /// **'Profit shows for bills made after this update (older bills did not save purchase prices).'**
  String get reportsNoProfit;

  /// No description provided for @reportsProfitPartial.
  ///
  /// In en, this message translates to:
  /// **'Counts {counted} of {total} bills that have purchase prices.'**
  String reportsProfitPartial(int counted, int total);

  /// No description provided for @reportsDayByDay.
  ///
  /// In en, this message translates to:
  /// **'Day by day'**
  String get reportsDayByDay;

  /// No description provided for @reportsBillsCount.
  ///
  /// In en, this message translates to:
  /// **'{bills} bills'**
  String reportsBillsCount(int bills);

  /// No description provided for @reportsTopQuantity.
  ///
  /// In en, this message translates to:
  /// **'Most sold (quantity)'**
  String get reportsTopQuantity;

  /// No description provided for @reportsTopRevenue.
  ///
  /// In en, this message translates to:
  /// **'Most sold (amount)'**
  String get reportsTopRevenue;

  /// No description provided for @voiceOpen.
  ///
  /// In en, this message translates to:
  /// **'Add by voice'**
  String get voiceOpen;

  /// No description provided for @voiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Add items by voice'**
  String get voiceTitle;

  /// No description provided for @voiceExample.
  ///
  /// In en, this message translates to:
  /// **'Say it like: 2 atta, 1 sugar, 3 parle g. You can also type below.'**
  String get voiceExample;

  /// No description provided for @voiceTapToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap the mic and speak'**
  String get voiceTapToSpeak;

  /// No description provided for @voiceListening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get voiceListening;

  /// No description provided for @voiceTranscriptLabel.
  ///
  /// In en, this message translates to:
  /// **'What I heard (you can fix it)'**
  String get voiceTranscriptLabel;

  /// No description provided for @voiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Voice is not available on this phone. You can type here instead.'**
  String get voiceUnavailable;

  /// No description provided for @voiceMicError.
  ///
  /// In en, this message translates to:
  /// **'The microphone had a problem. Try again or type instead.'**
  String get voiceMicError;

  /// No description provided for @voiceLangEnglish.
  ///
  /// In en, this message translates to:
  /// **'English / Hinglish'**
  String get voiceLangEnglish;

  /// No description provided for @voiceLangHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get voiceLangHindi;

  /// No description provided for @voiceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found: {text}'**
  String voiceNotFound(String text);

  /// No description provided for @voiceCheckMatch.
  ///
  /// In en, this message translates to:
  /// **'Please check this match'**
  String get voiceCheckMatch;

  /// No description provided for @voiceAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to bill ({count})'**
  String voiceAdd(int count);

  /// No description provided for @voiceAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} items added.'**
  String voiceAdded(int count);

  /// No description provided for @voiceAddedWithProblems.
  ///
  /// In en, this message translates to:
  /// **'{added} added. Problem: {problems}'**
  String voiceAddedWithProblems(int added, String problems);

  /// No description provided for @voiceNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing understood yet.'**
  String get voiceNothing;

  /// No description provided for @orderOpen.
  ///
  /// In en, this message translates to:
  /// **'Make order list'**
  String get orderOpen;

  /// No description provided for @orderTitle.
  ///
  /// In en, this message translates to:
  /// **'Order list'**
  String get orderTitle;

  /// No description provided for @orderIntro.
  ///
  /// In en, this message translates to:
  /// **'Items running low. Change how many to order; set 0 to skip an item.'**
  String get orderIntro;

  /// No description provided for @orderEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing is low on stock right now.'**
  String get orderEmpty;

  /// No description provided for @orderInStock.
  ///
  /// In en, this message translates to:
  /// **'In stock: {stock}'**
  String orderInStock(String stock);

  /// No description provided for @orderCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get orderCopy;

  /// No description provided for @orderShare.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get orderShare;

  /// No description provided for @orderCopied.
  ///
  /// In en, this message translates to:
  /// **'Order list copied.'**
  String get orderCopied;

  /// No description provided for @orderLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get orderLess;

  /// No description provided for @orderMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get orderMore;

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'Kilogram (kg)'**
  String get unitKg;

  /// No description provided for @unitLitre.
  ///
  /// In en, this message translates to:
  /// **'Litre (L)'**
  String get unitLitre;

  /// No description provided for @quantityKg.
  ///
  /// In en, this message translates to:
  /// **'{amount} kg'**
  String quantityKg(String amount);

  /// No description provided for @quantityLitre.
  ///
  /// In en, this message translates to:
  /// **'{amount} L'**
  String quantityLitre(String amount);

  /// No description provided for @quantityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount like 12 or 1.5 (up to 3 decimals).'**
  String get quantityInvalid;

  /// No description provided for @billQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get billQuantityLabel;

  /// No description provided for @billQuantityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount, not more than the stock.'**
  String get billQuantityInvalid;

  /// No description provided for @importTitle.
  ///
  /// In en, this message translates to:
  /// **'Import products'**
  String get importTitle;

  /// No description provided for @importMenu.
  ///
  /// In en, this message translates to:
  /// **'Import from file'**
  String get importMenu;

  /// No description provided for @importIntro.
  ///
  /// In en, this message translates to:
  /// **'Add many products at once from an Excel (.xlsx) or CSV file. Columns can be in any order. Headings like Name, Item, Barcode, Unit, Rate, MRP, Qty, Stock are understood. Download the sample sheet to see the format.'**
  String get importIntro;

  /// No description provided for @importPick.
  ///
  /// In en, this message translates to:
  /// **'Choose Excel / CSV file'**
  String get importPick;

  /// No description provided for @importSample.
  ///
  /// In en, this message translates to:
  /// **'Download sample sheet'**
  String get importSample;

  /// No description provided for @importSampleSaved.
  ///
  /// In en, this message translates to:
  /// **'Sample sheet saved.'**
  String get importSampleSaved;

  /// No description provided for @importNoPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to add products.'**
  String get importNoPermission;

  /// No description provided for @importReading.
  ///
  /// In en, this message translates to:
  /// **'Reading file…'**
  String get importReading;

  /// No description provided for @importStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get importStop;

  /// No description provided for @importErrRead.
  ///
  /// In en, this message translates to:
  /// **'Could not read this file. Open it in Excel and save as CSV, then try again.'**
  String get importErrRead;

  /// No description provided for @importErrNoRows.
  ///
  /// In en, this message translates to:
  /// **'The file has no product rows.'**
  String get importErrNoRows;

  /// No description provided for @importErrNoColumns.
  ///
  /// In en, this message translates to:
  /// **'Could not find a Name or Barcode column in the first row.'**
  String get importErrNoColumns;

  /// No description provided for @importErrNetwork.
  ///
  /// In en, this message translates to:
  /// **'Internet problem. The import stopped; the rest were not added. Check your connection and try again.'**
  String get importErrNetwork;

  /// No description provided for @importErrUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get importErrUnknown;

  /// No description provided for @importAllowNoPrice.
  ///
  /// In en, this message translates to:
  /// **'Also add items with no selling price (price 0, set it later)'**
  String get importAllowNoPrice;

  /// No description provided for @importNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing to add'**
  String get importNothing;

  /// No description provided for @importAnother.
  ///
  /// In en, this message translates to:
  /// **'Choose another file'**
  String get importAnother;

  /// No description provided for @importDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Import finished'**
  String get importDoneTitle;

  /// No description provided for @importProblemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rows that need attention'**
  String get importProblemsTitle;

  /// No description provided for @importProblemNameMissing.
  ///
  /// In en, this message translates to:
  /// **'name missing'**
  String get importProblemNameMissing;

  /// No description provided for @importProblemNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'name is too long'**
  String get importProblemNameTooLong;

  /// No description provided for @importProblemBarcode.
  ///
  /// In en, this message translates to:
  /// **'barcode is not valid'**
  String get importProblemBarcode;

  /// No description provided for @importProblemUnit.
  ///
  /// In en, this message translates to:
  /// **'unit not recognised'**
  String get importProblemUnit;

  /// No description provided for @importProblemPrice.
  ///
  /// In en, this message translates to:
  /// **'price is not valid'**
  String get importProblemPrice;

  /// No description provided for @importProblemStock.
  ///
  /// In en, this message translates to:
  /// **'stock is not valid'**
  String get importProblemStock;

  /// No description provided for @importProblemThreshold.
  ///
  /// In en, this message translates to:
  /// **'low stock alert is not valid'**
  String get importProblemThreshold;

  /// No description provided for @importProblemTextLong.
  ///
  /// In en, this message translates to:
  /// **'brand, category or SKU is too long'**
  String get importProblemTextLong;

  /// No description provided for @importProblemExists.
  ///
  /// In en, this message translates to:
  /// **'already in your products'**
  String get importProblemExists;

  /// No description provided for @importProblemRepeated.
  ///
  /// In en, this message translates to:
  /// **'repeated in this file'**
  String get importProblemRepeated;

  /// No description provided for @importProblemNotFound.
  ///
  /// In en, this message translates to:
  /// **'barcode not found online, add a name'**
  String get importProblemNotFound;

  /// No description provided for @importProblemLookup.
  ///
  /// In en, this message translates to:
  /// **'could not look up the barcode'**
  String get importProblemLookup;

  /// No description provided for @importProblemWrite.
  ///
  /// In en, this message translates to:
  /// **'could not be saved'**
  String get importProblemWrite;

  /// No description provided for @importLookingUp.
  ///
  /// In en, this message translates to:
  /// **'Finding names from barcodes… {done}/{total}'**
  String importLookingUp(int done, int total);

  /// No description provided for @importProgress.
  ///
  /// In en, this message translates to:
  /// **'Adding… {done}/{total}'**
  String importProgress(int done, int total);

  /// No description provided for @importTruncated.
  ///
  /// In en, this message translates to:
  /// **'Only the first {max} rows are used.'**
  String importTruncated(int max);

  /// No description provided for @importStart.
  ///
  /// In en, this message translates to:
  /// **'Add {count} products'**
  String importStart(int count);

  /// No description provided for @importCountReady.
  ///
  /// In en, this message translates to:
  /// **'{count} ready'**
  String importCountReady(int count);

  /// No description provided for @importCountAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} added'**
  String importCountAdded(int count);

  /// No description provided for @importCountNoPrice.
  ///
  /// In en, this message translates to:
  /// **'{count} without price'**
  String importCountNoPrice(int count);

  /// No description provided for @importCountSkipped.
  ///
  /// In en, this message translates to:
  /// **'{count} skipped'**
  String importCountSkipped(int count);

  /// No description provided for @importCountInvalid.
  ///
  /// In en, this message translates to:
  /// **'{count} with problems'**
  String importCountInvalid(int count);

  /// No description provided for @importRowLine.
  ///
  /// In en, this message translates to:
  /// **'Row {line}: {reason}'**
  String importRowLine(int line, String reason);

  /// No description provided for @importMoreProblems.
  ///
  /// In en, this message translates to:
  /// **'…and {count} more'**
  String importMoreProblems(int count);

  /// No description provided for @scannerPhotoButton.
  ///
  /// In en, this message translates to:
  /// **'Read barcode from a photo'**
  String get scannerPhotoButton;

  /// No description provided for @scannerPhotoCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get scannerPhotoCamera;

  /// No description provided for @scannerPhotoGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get scannerPhotoGallery;

  /// No description provided for @scannerPhotoReading.
  ///
  /// In en, this message translates to:
  /// **'Reading photo…'**
  String get scannerPhotoReading;

  /// No description provided for @scannerPhotoNotFound.
  ///
  /// In en, this message translates to:
  /// **'No barcode found in this photo. Keep the barcode flat, sharp and close, then try again.'**
  String get scannerPhotoNotFound;

  /// No description provided for @scannerPhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the photo. Please try again.'**
  String get scannerPhotoFailed;

  /// No description provided for @importPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo of a bill or list'**
  String get importPhoto;

  /// No description provided for @photoImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Add from a photo'**
  String get photoImportTitle;

  /// No description provided for @photoImportIntro.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of a supplier bill or a stock list, or pick one from the gallery. The text is read on your phone, and you check every item before anything is added. Printed text works best; handwriting is often wrong.'**
  String get photoImportIntro;

  /// No description provided for @photoImportReading.
  ///
  /// In en, this message translates to:
  /// **'Reading photo…'**
  String get photoImportReading;

  /// No description provided for @photoImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the photo. Please try again.'**
  String get photoImportFailed;

  /// No description provided for @photoImportEmpty.
  ///
  /// In en, this message translates to:
  /// **'No text found in this photo. Use good light and keep the page flat.'**
  String get photoImportEmpty;

  /// No description provided for @photoImportNoItems.
  ///
  /// In en, this message translates to:
  /// **'Text was found, but no product rows. Try a closer, sharper photo.'**
  String get photoImportNoItems;

  /// No description provided for @photoImportCheck.
  ///
  /// In en, this message translates to:
  /// **'Check every item. Fix names and numbers, and untick what is not a product. Add a selling price, or those items wait on the next screen.'**
  String get photoImportCheck;

  /// No description provided for @photoImportRetake.
  ///
  /// In en, this message translates to:
  /// **'Another photo'**
  String get photoImportRetake;

  /// No description provided for @photoImportName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get photoImportName;

  /// No description provided for @photoImportStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get photoImportStock;

  /// No description provided for @photoImportCost.
  ///
  /// In en, this message translates to:
  /// **'Purchase price'**
  String get photoImportCost;

  /// No description provided for @photoImportSelling.
  ///
  /// In en, this message translates to:
  /// **'Selling price'**
  String get photoImportSelling;

  /// No description provided for @photoImportContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue with {count} items'**
  String photoImportContinue(int count);

  /// No description provided for @billPendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Bill (waiting to sync)'**
  String get billPendingLabel;

  /// No description provided for @billSavedOfflineNote.
  ///
  /// In en, this message translates to:
  /// **'No internet. This bill is saved on your phone. It will be added to your records, and the stock reduced, when the internet is back.'**
  String get billSavedOfflineNote;

  /// No description provided for @pendingScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Bills waiting to sync'**
  String get pendingScreenTitle;

  /// No description provided for @pendingEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing is waiting. All bills are saved.'**
  String get pendingEmpty;

  /// No description provided for @pendingSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Try now'**
  String get pendingSyncNow;

  /// No description provided for @pendingRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get pendingRetry;

  /// No description provided for @pendingDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get pendingDiscard;

  /// No description provided for @pendingDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this bill?'**
  String get pendingDiscardTitle;

  /// No description provided for @pendingDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'This bill was never saved to your records and the stock was not reduced. Discarding removes it for good.'**
  String get pendingDiscardBody;

  /// No description provided for @pendingWaitingLine.
  ///
  /// In en, this message translates to:
  /// **'Waiting for internet'**
  String get pendingWaitingLine;

  /// No description provided for @pendingReasonStock.
  ///
  /// In en, this message translates to:
  /// **'Not enough stock now. Add stock, then retry.'**
  String get pendingReasonStock;

  /// No description provided for @pendingReasonPrice.
  ///
  /// In en, this message translates to:
  /// **'A price changed after this bill was made. Set the old price back and retry, or discard.'**
  String get pendingReasonPrice;

  /// No description provided for @pendingReasonGone.
  ///
  /// In en, this message translates to:
  /// **'A product in this bill was archived. Discard it and make the bill again.'**
  String get pendingReasonGone;

  /// No description provided for @pendingReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Could not be saved. Try again.'**
  String get pendingReasonOther;

  /// No description provided for @pendingBannerWaiting.
  ///
  /// In en, this message translates to:
  /// **'Working offline – {count} bills will sync when internet returns'**
  String pendingBannerWaiting(int count);

  /// No description provided for @pendingBannerAttention.
  ///
  /// In en, this message translates to:
  /// **'{count} bills need your attention'**
  String pendingBannerAttention(int count);

  /// No description provided for @productsExport.
  ///
  /// In en, this message translates to:
  /// **'Download products (CSV backup)'**
  String get productsExport;

  /// No description provided for @productsExported.
  ///
  /// In en, this message translates to:
  /// **'Products saved. You can import this file again from Import.'**
  String get productsExported;

  /// No description provided for @navNewSale.
  ///
  /// In en, this message translates to:
  /// **'New sale'**
  String get navNewSale;

  /// No description provided for @dashKpiLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get dashKpiLowStock;

  /// No description provided for @dashRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent sales'**
  String get dashRecentTitle;

  /// No description provided for @dashRecentEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sales yet.\nTap the + button to make your first bill!'**
  String get dashRecentEmpty;

  /// No description provided for @dashTagReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get dashTagReceived;

  /// No description provided for @dashTagPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get dashTagPending;

  /// No description provided for @homeQuickAddProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get homeQuickAddProduct;

  /// No description provided for @homeQuickImport.
  ///
  /// In en, this message translates to:
  /// **'Import Excel'**
  String get homeQuickImport;

  /// No description provided for @homeQuickSync.
  ///
  /// In en, this message translates to:
  /// **'Sync offline'**
  String get homeQuickSync;

  /// No description provided for @homeQuickSetup.
  ///
  /// In en, this message translates to:
  /// **'Setup store'**
  String get homeQuickSetup;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGreetingEvening;

  /// No description provided for @ownerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner name'**
  String get ownerNameLabel;

  /// No description provided for @ownerNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Your name, shown in the greeting on the home screen'**
  String get ownerNameHelper;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile & settings'**
  String get profileTitle;

  /// No description provided for @profileSectionShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get profileSectionShop;

  /// No description provided for @profileSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profileSectionPreferences;

  /// No description provided for @profileSectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileSectionSupport;

  /// No description provided for @profileOwnerFallback.
  ///
  /// In en, this message translates to:
  /// **'Shop owner'**
  String get profileOwnerFallback;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'Phone default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'Phone default'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get settingsHelp;

  /// No description provided for @settingsHelpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Common questions and tips'**
  String get settingsHelpSubtitle;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About Apna Shop'**
  String get settingsAbout;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Simple stock, billing and udhar for your shop. Your data is saved safely online and bills can be made even without internet.'**
  String get aboutBody;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get helpTitle;

  /// No description provided for @helpQ1.
  ///
  /// In en, this message translates to:
  /// **'Internet is off. Can I still make a bill?'**
  String get helpQ1;

  /// No description provided for @helpA1.
  ///
  /// In en, this message translates to:
  /// **'Yes. The bill is saved on your phone and goes online by itself when internet returns. You can see waiting bills at the top of the screen.'**
  String get helpA1;

  /// No description provided for @helpQ2.
  ///
  /// In en, this message translates to:
  /// **'How do I add many products quickly?'**
  String get helpQ2;

  /// No description provided for @helpA2.
  ///
  /// In en, this message translates to:
  /// **'Open Products and use Import (Excel/CSV or a photo of a list). You can also scan a barcode while adding a product.'**
  String get helpA2;

  /// No description provided for @helpQ3.
  ///
  /// In en, this message translates to:
  /// **'A customer took goods on udhar. What now?'**
  String get helpQ3;

  /// No description provided for @helpA3.
  ///
  /// In en, this message translates to:
  /// **'While billing, choose Udhar and enter the customer\'s name and phone. Later open Udhar and tap Record payment when they pay.'**
  String get helpA3;

  /// No description provided for @helpQ4.
  ///
  /// In en, this message translates to:
  /// **'How do I change my name, shop name or UPI?'**
  String get helpQ4;

  /// No description provided for @helpA4.
  ///
  /// In en, this message translates to:
  /// **'Profile > Shop details. The owner name appears in the greeting on Home.'**
  String get helpA4;

  /// No description provided for @helpQ5.
  ///
  /// In en, this message translates to:
  /// **'How do I use Hindi or dark mode?'**
  String get helpQ5;

  /// No description provided for @helpA5.
  ///
  /// In en, this message translates to:
  /// **'Profile > Language and Appearance. The choice is remembered on this phone.'**
  String get helpA5;

  /// No description provided for @billSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search item by name'**
  String get billSearchHint;

  /// No description provided for @billRemoveItem.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get billRemoveItem;

  /// No description provided for @billPayAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String billPayAmount(String amount);

  /// No description provided for @productsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get productsFilterAll;

  /// No description provided for @productsFilterOut.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get productsFilterOut;

  /// No description provided for @productOutBadge.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get productOutBadge;

  /// No description provided for @productInBadge.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get productInBadge;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
