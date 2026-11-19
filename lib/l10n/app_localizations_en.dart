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

  @override
  String get productsSearchHint => 'Search by name, SKU or barcode';

  @override
  String get productsLowStockFilter => 'Low stock only';

  @override
  String get productsEmptyTitle => 'No products yet';

  @override
  String get productsEmptyBody =>
      'Add your first product to start tracking stock.';

  @override
  String get productsNoMatchTitle => 'No matching products';

  @override
  String get productsNoMatchBody =>
      'Try a different name, or clear the filters.';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get productsLoadErrorTitle => 'Couldn\'t load products';

  @override
  String get addProduct => 'Add product';

  @override
  String get editProduct => 'Edit product';

  @override
  String get lowStockBadge => 'Low stock';

  @override
  String lowStockLine(String quantity) {
    return 'Only $quantity left';
  }

  @override
  String get detailsInStock => 'In stock';

  @override
  String get detailsSellingPrice => 'Selling price';

  @override
  String get detailsPurchasePrice => 'Purchase price';

  @override
  String get detailsLowStockAt => 'Low stock at';

  @override
  String get detailsCategory => 'Category';

  @override
  String get detailsBarcode => 'Barcode';

  @override
  String get detailsSku => 'SKU';

  @override
  String get productNotFound => 'This product no longer exists.';

  @override
  String get productArchivedNote => 'This product is archived.';

  @override
  String get archiveProduct => 'Archive product';

  @override
  String get archiveConfirmTitle => 'Archive this product?';

  @override
  String get archiveConfirmBody =>
      'It will disappear from your list. Its history is kept, and its barcode can be used again.';

  @override
  String get archiveAction => 'Archive';

  @override
  String get productNameLabel => 'Product name';

  @override
  String get productBarcodeLabel => 'Barcode (optional)';

  @override
  String get productSkuLabel => 'SKU (optional)';

  @override
  String get productCategoryLabel => 'Category (optional)';

  @override
  String get productUnitLabel => 'Unit';

  @override
  String get purchasePriceLabel => 'Purchase price in ₹ (optional)';

  @override
  String get sellingPriceLabel => 'Selling price in ₹';

  @override
  String get openingQuantityLabel => 'Opening stock';

  @override
  String get lowStockThresholdLabel => 'Warn me when stock is at or below';

  @override
  String get saveProduct => 'Save product';

  @override
  String get productOnlineNote => 'Saving needs an internet connection.';

  @override
  String get quantityEditNote =>
      'Stock quantity cannot be edited here. Use Stock in, Stock out or Adjust stock on the product page.';

  @override
  String productNameTooShort(int min) {
    return 'Name must be at least $min characters';
  }

  @override
  String productNameTooLong(int max) {
    return 'Name can be at most $max characters';
  }

  @override
  String get productBarcodeInvalid => 'Use 4 to 32 letters, numbers or dashes';

  @override
  String productSkuTooLong(int max) {
    return 'SKU can be at most $max characters';
  }

  @override
  String productCategoryTooLong(int max) {
    return 'Category can be at most $max characters';
  }

  @override
  String get priceInvalid => 'Enter a price like 25 or 25.50';

  @override
  String wholeNumberInvalid(int max) {
    return 'Enter a whole number from 0 to $max';
  }

  @override
  String get errorDuplicateBarcode =>
      'Another product in this store already uses this barcode.';

  @override
  String get unitPiece => 'Piece';

  @override
  String get unitPacket => 'Packet';

  @override
  String get unitBox => 'Box';

  @override
  String get unitBottle => 'Bottle';

  @override
  String get unitPack => 'Pack';

  @override
  String quantityPiece(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces',
      one: '1 piece',
    );
    return '$_temp0';
  }

  @override
  String quantityPacket(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count packets',
      one: '1 packet',
    );
    return '$_temp0';
  }

  @override
  String quantityBox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count boxes',
      one: '1 box',
    );
    return '$_temp0';
  }

  @override
  String quantityBottle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bottles',
      one: '1 bottle',
    );
    return '$_temp0';
  }

  @override
  String quantityPack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count packs',
      one: '1 pack',
    );
    return '$_temp0';
  }

  @override
  String get stockIn => 'Stock in';

  @override
  String get stockOut => 'Stock out';

  @override
  String get stockAdjust => 'Adjust stock';

  @override
  String get stockHistoryTitle => 'Stock history';

  @override
  String get stockHistoryEmpty => 'No stock movements yet.';

  @override
  String get stockAmountLabel => 'Quantity';

  @override
  String get stockCountedLabel => 'Counted quantity on the shelf';

  @override
  String get stockReasonLabel => 'Reason';

  @override
  String get stockNoteLabel => 'Note (optional)';

  @override
  String get stockSave => 'Save';

  @override
  String stockCurrentLine(String current) {
    return 'Currently in stock: $current';
  }

  @override
  String stockSavedSnack(String quantity) {
    return 'Saved. Now in stock: $quantity';
  }

  @override
  String get stockAmountInvalid => 'Enter a whole number, like 12';

  @override
  String stockInsufficient(String current) {
    return 'Only $current in stock. You cannot take out more.';
  }

  @override
  String get stockTooMuch => 'That would go over the maximum stock.';

  @override
  String get stockNoChange => 'This is the same as the recorded stock.';

  @override
  String get reasonPurchase => 'Purchase';

  @override
  String get reasonSale => 'Sale';

  @override
  String get reasonReturned => 'Returned';

  @override
  String get reasonDamaged => 'Damaged';

  @override
  String get reasonExpired => 'Expired';

  @override
  String get reasonCorrection => 'Correction';

  @override
  String get reasonOther => 'Other';

  @override
  String get errorInsufficientStock =>
      'Stock changed or is not enough. Please check and try again.';

  @override
  String get activityEmptyTitle => 'No activity yet';

  @override
  String get activityEmptyBody =>
      'Stock in, stock out and adjustments will appear here.';

  @override
  String get activityLoadErrorTitle => 'Couldn\'t load activity';

  @override
  String get scanBarcode => 'Scan barcode';

  @override
  String get scannerTitle => 'Scan a barcode';

  @override
  String get scannerHint =>
      'Hold the barcode inside the camera view. If the camera does not work, type the barcode.';

  @override
  String get scannerTorch => 'Flash';

  @override
  String get scannerManualEntry => 'Type the barcode instead';

  @override
  String get scannerManualTitle => 'Type the barcode';

  @override
  String get scannerUseCode => 'Use this barcode';

  @override
  String get scannerUnusableCode =>
      'This code cannot be used as a barcode here.';

  @override
  String get scannerNoProductTitle => 'No product with this barcode';

  @override
  String scannerNoProductBody(String code) {
    return 'No product has the barcode $code yet.';
  }

  @override
  String get lookupButton => 'Look up details';

  @override
  String get lookupLoading => 'Looking up…';

  @override
  String get lookupFound =>
      'Details filled from the Open Food Facts list. Please check them and add the price yourself.';

  @override
  String get lookupNotFound =>
      'This barcode is not in the online list. Type the details yourself.';

  @override
  String get lookupFailed =>
      'Could not look up details. Check your internet and try again.';

  @override
  String get lookupNeedBarcode => 'Enter or scan a valid barcode first.';

  @override
  String get productBrandLabel => 'Brand (optional)';

  @override
  String productBrandTooLong(int max) {
    return 'Brand can be at most $max characters';
  }

  @override
  String get imageCredit => 'Picture: Open Food Facts (CC BY-SA)';

  @override
  String get removePicture => 'Remove picture';

  @override
  String priceHint(String price, String date) {
    return 'Others reported $price (on $date). It may be old or from another shop.';
  }

  @override
  String get priceHintUse => 'Use as selling price';

  @override
  String get pickCommonItem => 'Pick from common items';

  @override
  String get starterTitle => 'Common items';

  @override
  String get starterNote =>
      'Only names are filled. Scan the barcode and add price and stock yourself. Items are in packed sizes.';

  @override
  String get starterSearchHint => 'Search items, brands or Hindi names';

  @override
  String get starterNoMatch => 'No matching item. Add it yourself.';

  @override
  String get navBill => 'Bill';

  @override
  String get errorPriceChanged =>
      'A price changed while you were billing. Please check the items and try again.';

  @override
  String get billTitle => 'New bill';

  @override
  String get billClear => 'Clear bill';

  @override
  String get billHistory => 'Bills';

  @override
  String get billScanItem => 'Scan item';

  @override
  String get billAddByName => 'By name';

  @override
  String get billEmptyTitle => 'No items yet';

  @override
  String get billEmptyBody => 'Scan an item\'s barcode to add it to the bill.';

  @override
  String billNotInInventory(String code) {
    return 'Barcode $code is not in your inventory.';
  }

  @override
  String get billOutOfStock => 'Out of stock';

  @override
  String get billNotEnoughStock => 'Not enough stock';

  @override
  String get billProductArchived => 'This item is archived';

  @override
  String billCartFull(int max) {
    return 'A bill can have at most $max different items.';
  }

  @override
  String billInStock(String quantity) {
    return 'In stock: $quantity';
  }

  @override
  String get billDecrease => 'Decrease';

  @override
  String get billIncrease => 'Increase';

  @override
  String billItemsCount(int count) {
    return '$count items';
  }

  @override
  String get billDiscount => 'Discount';

  @override
  String get billDiscountHint => 'Discount in rupees';

  @override
  String get billApply => 'Apply';

  @override
  String get billTotal => 'Total';

  @override
  String get billSubtotal => 'Subtotal';

  @override
  String get billMakeBill => 'Make bill';

  @override
  String get billSavedTitle => 'Bill saved';

  @override
  String get billNotFound => 'Bill not found';

  @override
  String billNumberLabel(int number) {
    return 'Bill no. $number';
  }

  @override
  String get billNewBill => 'New bill';

  @override
  String get billHistoryEmpty => 'No bills yet.';

  @override
  String get payTitle => 'Payment';

  @override
  String get payFullCash => 'Full cash';

  @override
  String get payFullUpi => 'Full UPI';

  @override
  String get payFullUdhar => 'Full udhar';

  @override
  String get payCash => 'Cash';

  @override
  String get payUpi => 'UPI';

  @override
  String get payUdhar => 'Udhar';

  @override
  String get payUdharHint => 'Whatever is not paid now';

  @override
  String get payTooMuch => 'Cash + UPI is more than the total.';

  @override
  String get payNotBalanced => 'Cash + UPI + udhar must equal the total.';

  @override
  String get payCustomerPhone => 'Customer mobile number';

  @override
  String get payCustomerName => 'Customer name';

  @override
  String get payCustomerNameRequired => 'Enter the customer\'s name for udhar.';

  @override
  String get payCustomerPhoneInvalid => 'Enter a valid 10-digit mobile number.';

  @override
  String get payCustomer => 'Customer';

  @override
  String payOldUdhar(String name, String amount) {
    return '$name already owes $amount.';
  }

  @override
  String payUseName(String name) {
    return 'Use \"$name\"';
  }

  @override
  String get payConfirm => 'Save bill';

  @override
  String get pdfOpen => 'Bill PDF: print / share / download';

  @override
  String get pdfTitle => 'Bill PDF';

  @override
  String get pdfTemplateClassic => 'Classic';

  @override
  String get pdfTemplateModern => 'Modern';

  @override
  String get pdfTemplateThermal => 'Receipt';

  @override
  String get pdfTemplateMinimal => 'Minimal';

  @override
  String get pdfPrint => 'Print';

  @override
  String get pdfShare => 'Share';

  @override
  String get pdfDownload => 'Download';

  @override
  String get pdfSaved => 'PDF saved.';

  @override
  String get pdfActionFailed => 'Could not complete this. Please try again.';

  @override
  String get payCustomerOptionalTitle =>
      'Customer (optional - printed on the bill)';

  @override
  String get payCustomerNameOptional => 'Customer name (optional)';

  @override
  String get payCustomerPhoneOptional => 'Customer mobile (optional)';

  @override
  String get billMakeNew => 'Make a new bill';

  @override
  String get dashToday => 'Today';

  @override
  String get dashYesterday => 'Yesterday';

  @override
  String get dashLast7Days => '7 days';

  @override
  String get dashSales => 'Sales';

  @override
  String dashBillsItems(int bills, int items) {
    return '$bills bills • $items items';
  }

  @override
  String get dashTruncated => 'Showing the latest 500 bills only.';

  @override
  String get dashLoadError => 'Could not load sales.';

  @override
  String get dashOwnSalesNote => 'You see only the bills you made.';

  @override
  String get dashUdharPending => 'Udhar pending';

  @override
  String dashUdharCustomers(int count) {
    return '$count customers';
  }

  @override
  String dashLowStockTitle(int count) {
    return 'Low stock: $count items';
  }

  @override
  String dashOutOfStock(int count) {
    return '$count out of stock';
  }

  @override
  String get dashAllStocked => 'Everything is above its low-stock level.';

  @override
  String get dashViewAllProducts => 'See all products';

  @override
  String get navUdhar => 'Udhar';

  @override
  String get errorOverpayment =>
      'That is more than the customer owes. Please check the amount.';

  @override
  String get udharTitle => 'Udhar';

  @override
  String get udharTotal => 'Total udhar';

  @override
  String get udharSearchHint => 'Search name or mobile number';

  @override
  String get udharShowSettled => 'Show settled';

  @override
  String get udharSettled => 'Settled';

  @override
  String get udharEmptyBody =>
      'No udhar yet. When a bill has udhar, the customer appears here.';

  @override
  String get udharNoMatch => 'No matching customer.';

  @override
  String get udharLoadError => 'Could not load udhar.';

  @override
  String get udharCustomerMissing => 'Customer not found.';

  @override
  String get udharBalance => 'Udhar balance';

  @override
  String get udharRecordPayment => 'Record payment received';

  @override
  String get udharLedger => 'History';

  @override
  String get udharEntryCredit => 'Udhar (bill)';

  @override
  String udharEntryPayment(String method) {
    return 'Payment received ($method)';
  }

  @override
  String get udharPaymentTitle => 'Payment received';

  @override
  String udharDueNow(String amount) {
    return 'Udhar due: $amount';
  }

  @override
  String get udharAmountLabel => 'Amount received';

  @override
  String get udharFullAmount => 'Full amount';

  @override
  String get udharNoteLabel => 'Note (optional)';

  @override
  String get udharSavePayment => 'Save payment';

  @override
  String udharOverpay(String amount) {
    return 'More than the udhar of $amount';
  }

  @override
  String get shopDetailsTitle => 'Shop details';

  @override
  String get shopDetailsSubtitle =>
      'Name, address, phone and UPI printed on bills';

  @override
  String get shopDetailsNote =>
      'These details are printed at the top and bottom of every bill PDF. Only the owner can change them.';

  @override
  String get shopAddressLabel => 'Address (optional)';

  @override
  String get shopUpiLabel => 'UPI ID (optional)';

  @override
  String get shopUpiHelper => 'Example: yourshop@okhdfcbank';

  @override
  String get shopFooterLabel => 'Bottom line on bill (optional)';

  @override
  String get shopFooterHelper => 'Example: Thank you! Visit again.';

  @override
  String get shopSave => 'Save';

  @override
  String get shopSaved => 'Shop details saved.';

  @override
  String storeAddressTooLong(int max) {
    return 'Address can be at most $max characters';
  }

  @override
  String storeFooterTooLong(int max) {
    return 'This line can be at most $max characters';
  }

  @override
  String get storeUpiInvalid => 'Enter a valid UPI ID like name@bank';

  @override
  String get reportsOpen => 'Reports';

  @override
  String get reportsTitle => 'Sales report';

  @override
  String get reportsLast30Days => '30 days';

  @override
  String get reportsThisMonth => 'This month';

  @override
  String get reportsCustom => 'Pick dates';

  @override
  String get reportsExport => 'Export CSV';

  @override
  String get reportsExported => 'CSV saved.';

  @override
  String get reportsEmpty => 'No bills in this period.';

  @override
  String reportsTruncated(int limit) {
    return 'Showing the latest $limit bills only.';
  }

  @override
  String get reportsProfit => 'Profit';

  @override
  String get reportsNoProfit =>
      'Profit shows for bills made after this update (older bills did not save purchase prices).';

  @override
  String reportsProfitPartial(int counted, int total) {
    return 'Counts $counted of $total bills that have purchase prices.';
  }

  @override
  String get reportsDayByDay => 'Day by day';

  @override
  String reportsBillsCount(int bills) {
    return '$bills bills';
  }

  @override
  String get reportsTopQuantity => 'Most sold (quantity)';

  @override
  String get reportsTopRevenue => 'Most sold (amount)';

  @override
  String get voiceOpen => 'Add by voice';

  @override
  String get voiceTitle => 'Add items by voice';

  @override
  String get voiceExample =>
      'Say it like: 2 atta, 1 sugar, 3 parle g. You can also type below.';

  @override
  String get voiceTapToSpeak => 'Tap the mic and speak';

  @override
  String get voiceListening => 'Listening…';

  @override
  String get voiceTranscriptLabel => 'What I heard (you can fix it)';

  @override
  String get voiceUnavailable =>
      'Voice is not available on this phone. You can type here instead.';

  @override
  String get voiceMicError =>
      'The microphone had a problem. Try again or type instead.';

  @override
  String get voiceLangEnglish => 'English / Hinglish';

  @override
  String get voiceLangHindi => 'हिन्दी';

  @override
  String voiceNotFound(String text) {
    return 'Not found: $text';
  }

  @override
  String get voiceCheckMatch => 'Please check this match';

  @override
  String voiceAdd(int count) {
    return 'Add to bill ($count)';
  }

  @override
  String voiceAdded(int count) {
    return '$count items added.';
  }

  @override
  String voiceAddedWithProblems(int added, String problems) {
    return '$added added. Problem: $problems';
  }

  @override
  String get voiceNothing => 'Nothing understood yet.';

  @override
  String get orderOpen => 'Make order list';

  @override
  String get orderTitle => 'Order list';

  @override
  String get orderIntro =>
      'Items running low. Change how many to order; set 0 to skip an item.';

  @override
  String get orderEmpty => 'Nothing is low on stock right now.';

  @override
  String orderInStock(String stock) {
    return 'In stock: $stock';
  }

  @override
  String get orderCopy => 'Copy text';

  @override
  String get orderShare => 'Share PDF';

  @override
  String get orderCopied => 'Order list copied.';

  @override
  String get orderLess => 'Less';

  @override
  String get orderMore => 'More';

  @override
  String get unitKg => 'Kilogram (kg)';

  @override
  String get unitLitre => 'Litre (L)';

  @override
  String quantityKg(String amount) {
    return '$amount kg';
  }

  @override
  String quantityLitre(String amount) {
    return '$amount L';
  }

  @override
  String get quantityInvalid =>
      'Enter an amount like 12 or 1.5 (up to 3 decimals).';

  @override
  String get billQuantityLabel => 'Quantity';

  @override
  String get billQuantityInvalid =>
      'Enter a valid amount, not more than the stock.';

  @override
  String get importTitle => 'Import products';

  @override
  String get importMenu => 'Import from file';

  @override
  String get importIntro =>
      'Add many products at once from an Excel (.xlsx) or CSV file. Columns can be in any order. Headings like Name, Item, Barcode, Unit, Rate, MRP, Qty, Stock are understood. Download the sample sheet to see the format.';

  @override
  String get importPick => 'Choose Excel / CSV file';

  @override
  String get importSample => 'Download sample sheet';

  @override
  String get importSampleSaved => 'Sample sheet saved.';

  @override
  String get importNoPermission =>
      'You do not have permission to add products.';

  @override
  String get importReading => 'Reading file…';

  @override
  String get importStop => 'Stop';

  @override
  String get importErrRead =>
      'Could not read this file. Open it in Excel and save as CSV, then try again.';

  @override
  String get importErrNoRows => 'The file has no product rows.';

  @override
  String get importErrNoColumns =>
      'Could not find a Name or Barcode column in the first row.';

  @override
  String get importErrNetwork =>
      'Internet problem. The import stopped; the rest were not added. Check your connection and try again.';

  @override
  String get importErrUnknown => 'Something went wrong. Please try again.';

  @override
  String get importAllowNoPrice =>
      'Also add items with no selling price (price 0, set it later)';

  @override
  String get importNothing => 'Nothing to add';

  @override
  String get importAnother => 'Choose another file';

  @override
  String get importDoneTitle => 'Import finished';

  @override
  String get importProblemsTitle => 'Rows that need attention';

  @override
  String get importProblemNameMissing => 'name missing';

  @override
  String get importProblemNameTooLong => 'name is too long';

  @override
  String get importProblemBarcode => 'barcode is not valid';

  @override
  String get importProblemUnit => 'unit not recognised';

  @override
  String get importProblemPrice => 'price is not valid';

  @override
  String get importProblemStock => 'stock is not valid';

  @override
  String get importProblemThreshold => 'low stock alert is not valid';

  @override
  String get importProblemTextLong => 'brand, category or SKU is too long';

  @override
  String get importProblemExists => 'already in your products';

  @override
  String get importProblemRepeated => 'repeated in this file';

  @override
  String get importProblemNotFound => 'barcode not found online, add a name';

  @override
  String get importProblemLookup => 'could not look up the barcode';

  @override
  String get importProblemWrite => 'could not be saved';

  @override
  String importLookingUp(int done, int total) {
    return 'Finding names from barcodes… $done/$total';
  }

  @override
  String importProgress(int done, int total) {
    return 'Adding… $done/$total';
  }

  @override
  String importTruncated(int max) {
    return 'Only the first $max rows are used.';
  }

  @override
  String importStart(int count) {
    return 'Add $count products';
  }

  @override
  String importCountReady(int count) {
    return '$count ready';
  }

  @override
  String importCountAdded(int count) {
    return '$count added';
  }

  @override
  String importCountNoPrice(int count) {
    return '$count without price';
  }

  @override
  String importCountSkipped(int count) {
    return '$count skipped';
  }

  @override
  String importCountInvalid(int count) {
    return '$count with problems';
  }

  @override
  String importRowLine(int line, String reason) {
    return 'Row $line: $reason';
  }

  @override
  String importMoreProblems(int count) {
    return '…and $count more';
  }

  @override
  String get scannerPhotoButton => 'Read barcode from a photo';

  @override
  String get scannerPhotoCamera => 'Take a photo';

  @override
  String get scannerPhotoGallery => 'Choose from gallery';

  @override
  String get scannerPhotoReading => 'Reading photo…';

  @override
  String get scannerPhotoNotFound =>
      'No barcode found in this photo. Keep the barcode flat, sharp and close, then try again.';

  @override
  String get scannerPhotoFailed =>
      'Could not open the photo. Please try again.';

  @override
  String get importPhoto => 'Photo of a bill or list';

  @override
  String get photoImportTitle => 'Add from a photo';

  @override
  String get photoImportIntro =>
      'Take a photo of a supplier bill or a stock list, or pick one from the gallery. The text is read on your phone, and you check every item before anything is added. Printed text works best; handwriting is often wrong.';

  @override
  String get photoImportReading => 'Reading photo…';

  @override
  String get photoImportFailed => 'Could not read the photo. Please try again.';

  @override
  String get photoImportEmpty =>
      'No text found in this photo. Use good light and keep the page flat.';

  @override
  String get photoImportNoItems =>
      'Text was found, but no product rows. Try a closer, sharper photo.';

  @override
  String get photoImportCheck =>
      'Check every item. Fix names and numbers, and untick what is not a product. Add a selling price, or those items wait on the next screen.';

  @override
  String get photoImportRetake => 'Another photo';

  @override
  String get photoImportName => 'Name';

  @override
  String get photoImportStock => 'Stock';

  @override
  String get photoImportCost => 'Purchase price';

  @override
  String get photoImportSelling => 'Selling price';

  @override
  String photoImportContinue(int count) {
    return 'Continue with $count items';
  }

  @override
  String get billPendingLabel => 'Bill (waiting to sync)';

  @override
  String get billSavedOfflineNote =>
      'No internet. This bill is saved on your phone. It will be added to your records, and the stock reduced, when the internet is back.';

  @override
  String get pendingScreenTitle => 'Bills waiting to sync';

  @override
  String get pendingEmpty => 'Nothing is waiting. All bills are saved.';

  @override
  String get pendingSyncNow => 'Try now';

  @override
  String get pendingRetry => 'Retry';

  @override
  String get pendingDiscard => 'Discard';

  @override
  String get pendingDiscardTitle => 'Discard this bill?';

  @override
  String get pendingDiscardBody =>
      'This bill was never saved to your records and the stock was not reduced. Discarding removes it for good.';

  @override
  String get pendingWaitingLine => 'Waiting for internet';

  @override
  String get pendingReasonStock =>
      'Not enough stock now. Add stock, then retry.';

  @override
  String get pendingReasonPrice =>
      'A price changed after this bill was made. Set the old price back and retry, or discard.';

  @override
  String get pendingReasonGone =>
      'A product in this bill was archived. Discard it and make the bill again.';

  @override
  String get pendingReasonOther => 'Could not be saved. Try again.';

  @override
  String pendingBannerWaiting(int count) {
    return 'Working offline – $count bills will sync when internet returns';
  }

  @override
  String pendingBannerAttention(int count) {
    return '$count bills need your attention';
  }

  @override
  String get productsExport => 'Download products (CSV backup)';

  @override
  String get productsExported =>
      'Products saved. You can import this file again from Import.';

  @override
  String get navNewSale => 'New sale';

  @override
  String get dashKpiLowStock => 'Low stock';

  @override
  String get dashRecentTitle => 'Recent sales';

  @override
  String get dashRecentEmpty =>
      'No sales yet.\nTap the + button to make your first bill!';

  @override
  String get dashTagReceived => 'Received';

  @override
  String get dashTagPending => 'Pending';

  @override
  String get homeQuickAddProduct => 'Add product';

  @override
  String get homeQuickImport => 'Import Excel';

  @override
  String get homeQuickSync => 'Sync offline';

  @override
  String get homeQuickSetup => 'Setup store';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get ownerNameLabel => 'Owner name';

  @override
  String get ownerNameHelper =>
      'Your name, shown in the greeting on the home screen';

  @override
  String get profileTitle => 'Profile & settings';

  @override
  String get profileSectionShop => 'Shop';

  @override
  String get profileSectionPreferences => 'Preferences';

  @override
  String get profileSectionSupport => 'Support';

  @override
  String get profileOwnerFallback => 'Shop owner';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'Phone default';

  @override
  String get settingsTheme => 'Appearance';

  @override
  String get settingsThemeSystem => 'Phone default';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsHelp => 'Help & support';

  @override
  String get settingsHelpSubtitle => 'Common questions and tips';

  @override
  String get settingsAbout => 'About Apna Shop';

  @override
  String get aboutBody =>
      'Simple stock, billing and udhar for your shop. Your data is saved safely online and bills can be made even without internet.';

  @override
  String get helpTitle => 'Help & support';

  @override
  String get helpQ1 => 'Internet is off. Can I still make a bill?';

  @override
  String get helpA1 =>
      'Yes. The bill is saved on your phone and goes online by itself when internet returns. You can see waiting bills at the top of the screen.';

  @override
  String get helpQ2 => 'How do I add many products quickly?';

  @override
  String get helpA2 =>
      'Open Products and use Import (Excel/CSV or a photo of a list). You can also scan a barcode while adding a product.';

  @override
  String get helpQ3 => 'A customer took goods on udhar. What now?';

  @override
  String get helpA3 =>
      'While billing, choose Udhar and enter the customer\'s name and phone. Later open Udhar and tap Record payment when they pay.';

  @override
  String get helpQ4 => 'How do I change my name, shop name or UPI?';

  @override
  String get helpA4 =>
      'Profile > Shop details. The owner name appears in the greeting on Home.';

  @override
  String get helpQ5 => 'How do I use Hindi or dark mode?';

  @override
  String get helpA5 =>
      'Profile > Language and Appearance. The choice is remembered on this phone.';

  @override
  String get billSearchHint => 'Search item by name';

  @override
  String get billRemoveItem => 'Remove item';

  @override
  String billPayAmount(String amount) {
    return 'Pay $amount';
  }

  @override
  String get productsFilterAll => 'All';

  @override
  String get productsFilterOut => 'Out of stock';

  @override
  String get productOutBadge => 'Out of stock';

  @override
  String get productInBadge => 'In stock';
}
