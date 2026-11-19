// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Apna Shop';

  @override
  String get signInTitle => 'साइन इन करें';

  @override
  String get signInSubtitle =>
      'अपनी दुकान का स्टॉक सँभालने के लिए साइन इन करें।';

  @override
  String get signUpTitle => 'खाता बनाएँ';

  @override
  String get signUpSubtitle => 'शुरू करने के लिए खाता बनाएँ।';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get confirmPasswordLabel => 'पासवर्ड दोबारा लिखें';

  @override
  String get showPassword => 'पासवर्ड दिखाएँ';

  @override
  String get hidePassword => 'पासवर्ड छिपाएँ';

  @override
  String get signInButton => 'साइन इन';

  @override
  String get signUpButton => 'खाता बनाएँ';

  @override
  String get noAccountPrompt => 'Apna Shop पर नए हैं?';

  @override
  String get createAccountLink => 'खाता बनाएँ';

  @override
  String get haveAccountPrompt => 'पहले से खाता है?';

  @override
  String get signInLink => 'साइन इन करें';

  @override
  String get loading => 'लोड हो रहा है';

  @override
  String get fieldRequired => 'यह जानकारी ज़रूरी है';

  @override
  String get emailInvalid => 'सही ईमेल पता लिखें';

  @override
  String passwordTooShort(int min) {
    return 'पासवर्ड कम से कम $min अक्षरों का होना चाहिए';
  }

  @override
  String get passwordsDoNotMatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get errorInvalidCredentials => 'ईमेल या पासवर्ड गलत है।';

  @override
  String get errorInvalidEmail => 'यह ईमेल पता सही नहीं लग रहा।';

  @override
  String get errorEmailInUse =>
      'इस ईमेल से खाता पहले से मौजूद है। साइन इन करके देखें।';

  @override
  String get errorWeakPassword => 'ज़्यादा मज़बूत पासवर्ड चुनें।';

  @override
  String get errorNetwork => 'इंटरनेट नहीं है। कनेक्शन जाँचकर फिर कोशिश करें।';

  @override
  String get errorTooManyRequests =>
      'बहुत ज़्यादा कोशिशें हो गईं। थोड़ी देर रुककर फिर कोशिश करें।';

  @override
  String get errorUserDisabled => 'यह खाता बंद कर दिया गया है।';

  @override
  String get errorUnknown => 'कुछ गड़बड़ हो गई। कृपया फिर कोशिश करें।';

  @override
  String get navHome => 'होम';

  @override
  String get navProducts => 'प्रोडक्ट';

  @override
  String get navActivity => 'गतिविधि';

  @override
  String get navReports => 'रिपोर्ट';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get comingSoonTitle => 'अभी उपलब्ध नहीं';

  @override
  String get comingSoonBody => 'यह हिस्सा बन रहा है और आगे के अपडेट में आएगा।';

  @override
  String homeWelcome(String name) {
    return 'स्वागत है, $name';
  }

  @override
  String get homeNextStepTitle => 'अगला कदम: अपने प्रोडक्ट जोड़ें';

  @override
  String get homeNextStepBody =>
      'प्रोडक्ट मैनेजमेंट अभी उपलब्ध नहीं है। यह अगले अपडेट में जोड़ा जाएगा।';

  @override
  String get profileSignedInAs => 'इस खाते से साइन इन हैं';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get signOutConfirmTitle => 'साइन आउट करें?';

  @override
  String get signOutConfirmBody =>
      'Apna Shop इस्तेमाल करने के लिए आपको दोबारा साइन इन करना होगा।';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get setupRequiredTitle => 'Firebase सेटअप ज़रूरी है';

  @override
  String get setupRequiredBody =>
      'यह ऐप अभी किसी Firebase प्रोजेक्ट से जुड़ा नहीं है। अपने Apna Shop Firebase प्रोजेक्ट के लिए \'flutterfire configure\' चलाएँ, फिर ऐप दोबारा शुरू करें।';

  @override
  String get createStoreTitle => 'अपनी दुकान सेट करें';

  @override
  String get createStoreSubtitle =>
      'अपनी दुकान के बारे में थोड़ा बताएँ। इसके बाद आप प्रोडक्ट जोड़ सकते हैं।';

  @override
  String get storeNameLabel => 'दुकान का नाम';

  @override
  String get storeCityLabel => 'शहर (वैकल्पिक)';

  @override
  String get storePhoneLabel => 'फ़ोन नंबर (वैकल्पिक)';

  @override
  String get createStoreButton => 'दुकान बनाएँ';

  @override
  String get createStoreOnlineNote => 'दुकान बनाने के लिए इंटरनेट ज़रूरी है।';

  @override
  String storeNameTooShort(int min) {
    return 'दुकान का नाम कम से कम $min अक्षरों का होना चाहिए';
  }

  @override
  String storeNameTooLong(int max) {
    return 'दुकान का नाम ज़्यादा से ज़्यादा $max अक्षरों का हो सकता है';
  }

  @override
  String storeCityTooLong(int max) {
    return 'शहर का नाम ज़्यादा से ज़्यादा $max अक्षरों का हो सकता है';
  }

  @override
  String get storePhoneInvalid => 'सही 10 अंकों का मोबाइल नंबर लिखें';

  @override
  String get errorPermissionDenied => 'आपको यह करने की अनुमति नहीं है।';

  @override
  String get errorStoreAlreadyExists => 'आपकी दुकान पहले से बनी हुई है।';

  @override
  String get storeLoadErrorTitle => 'आपकी दुकान लोड नहीं हो पाई';

  @override
  String get storeLoadErrorBody => 'इंटरनेट कनेक्शन जाँचकर फिर कोशिश करें।';

  @override
  String get retry => 'फिर कोशिश करें';

  @override
  String get roleOwner => 'मालिक';

  @override
  String get roleManager => 'मैनेजर';

  @override
  String get roleStaff => 'स्टाफ़';

  @override
  String homeRole(String role) {
    return 'आपकी भूमिका: $role';
  }

  @override
  String get productsSearchHint => 'नाम, SKU या बारकोड से खोजें';

  @override
  String get productsLowStockFilter => 'सिर्फ़ कम स्टॉक';

  @override
  String get productsEmptyTitle => 'अभी कोई प्रोडक्ट नहीं';

  @override
  String get productsEmptyBody =>
      'स्टॉक ट्रैक करने के लिए अपना पहला प्रोडक्ट जोड़ें।';

  @override
  String get productsNoMatchTitle => 'कोई प्रोडक्ट नहीं मिला';

  @override
  String get productsNoMatchBody => 'दूसरा नाम आज़माएँ, या फ़िल्टर हटाएँ।';

  @override
  String get clearFilters => 'फ़िल्टर हटाएँ';

  @override
  String get productsLoadErrorTitle => 'प्रोडक्ट लोड नहीं हो सके';

  @override
  String get addProduct => 'प्रोडक्ट जोड़ें';

  @override
  String get editProduct => 'प्रोडक्ट बदलें';

  @override
  String get lowStockBadge => 'कम स्टॉक';

  @override
  String lowStockLine(String quantity) {
    return 'सिर्फ़ $quantity बचा है';
  }

  @override
  String get detailsInStock => 'स्टॉक में';

  @override
  String get detailsSellingPrice => 'बिक्री मूल्य';

  @override
  String get detailsPurchasePrice => 'खरीद मूल्य';

  @override
  String get detailsLowStockAt => 'कम स्टॉक की सीमा';

  @override
  String get detailsCategory => 'श्रेणी';

  @override
  String get detailsBarcode => 'बारकोड';

  @override
  String get detailsSku => 'SKU';

  @override
  String get productNotFound => 'यह प्रोडक्ट अब मौजूद नहीं है।';

  @override
  String get productArchivedNote => 'यह प्रोडक्ट आर्काइव है।';

  @override
  String get archiveProduct => 'प्रोडक्ट आर्काइव करें';

  @override
  String get archiveConfirmTitle => 'यह प्रोडक्ट आर्काइव करें?';

  @override
  String get archiveConfirmBody =>
      'यह आपकी सूची से हट जाएगा। इसका इतिहास सुरक्षित रहेगा और इसका बारकोड दोबारा इस्तेमाल हो सकेगा।';

  @override
  String get archiveAction => 'आर्काइव करें';

  @override
  String get productNameLabel => 'प्रोडक्ट का नाम';

  @override
  String get productBarcodeLabel => 'बारकोड (वैकल्पिक)';

  @override
  String get productSkuLabel => 'SKU (वैकल्पिक)';

  @override
  String get productCategoryLabel => 'श्रेणी (वैकल्पिक)';

  @override
  String get productUnitLabel => 'इकाई';

  @override
  String get purchasePriceLabel => 'खरीद मूल्य ₹ में (वैकल्पिक)';

  @override
  String get sellingPriceLabel => 'बिक्री मूल्य ₹ में';

  @override
  String get openingQuantityLabel => 'शुरुआती स्टॉक';

  @override
  String get lowStockThresholdLabel => 'स्टॉक इतना या कम होने पर बताएँ';

  @override
  String get saveProduct => 'प्रोडक्ट सेव करें';

  @override
  String get productOnlineNote => 'सेव करने के लिए इंटरनेट चाहिए।';

  @override
  String get quantityEditNote =>
      'स्टॉक की मात्रा यहाँ नहीं बदली जा सकती। प्रोडक्ट पेज पर स्टॉक आया, स्टॉक गया या स्टॉक सुधारें इस्तेमाल करें।';

  @override
  String productNameTooShort(int min) {
    return 'नाम कम से कम $min अक्षर का होना चाहिए';
  }

  @override
  String productNameTooLong(int max) {
    return 'नाम ज़्यादा से ज़्यादा $max अक्षर का हो सकता है';
  }

  @override
  String get productBarcodeInvalid => '4 से 32 अक्षर, अंक या डैश इस्तेमाल करें';

  @override
  String productSkuTooLong(int max) {
    return 'SKU ज़्यादा से ज़्यादा $max अक्षर का हो सकता है';
  }

  @override
  String productCategoryTooLong(int max) {
    return 'श्रेणी ज़्यादा से ज़्यादा $max अक्षर की हो सकती है';
  }

  @override
  String get priceInvalid => 'कीमत ऐसे लिखें: 25 या 25.50';

  @override
  String wholeNumberInvalid(int max) {
    return '0 से $max तक की पूरी संख्या लिखें';
  }

  @override
  String get errorDuplicateBarcode =>
      'इस दुकान के किसी दूसरे प्रोडक्ट में यही बारकोड है।';

  @override
  String get unitPiece => 'पीस';

  @override
  String get unitPacket => 'पैकेट';

  @override
  String get unitBox => 'डिब्बा';

  @override
  String get unitBottle => 'बोतल';

  @override
  String get unitPack => 'पैक';

  @override
  String quantityPiece(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पीस',
    );
    return '$_temp0';
  }

  @override
  String quantityPacket(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पैकेट',
    );
    return '$_temp0';
  }

  @override
  String quantityBox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count डिब्बा',
    );
    return '$_temp0';
  }

  @override
  String quantityBottle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बोतल',
    );
    return '$_temp0';
  }

  @override
  String quantityPack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पैक',
    );
    return '$_temp0';
  }

  @override
  String get stockIn => 'स्टॉक आया';

  @override
  String get stockOut => 'स्टॉक गया';

  @override
  String get stockAdjust => 'स्टॉक सुधारें';

  @override
  String get stockHistoryTitle => 'स्टॉक का इतिहास';

  @override
  String get stockHistoryEmpty => 'अभी कोई स्टॉक हलचल नहीं।';

  @override
  String get stockAmountLabel => 'मात्रा';

  @override
  String get stockCountedLabel => 'शेल्फ पर गिनी हुई मात्रा';

  @override
  String get stockReasonLabel => 'कारण';

  @override
  String get stockNoteLabel => 'नोट (वैकल्पिक)';

  @override
  String get stockSave => 'सेव करें';

  @override
  String stockCurrentLine(String current) {
    return 'अभी स्टॉक में: $current';
  }

  @override
  String stockSavedSnack(String quantity) {
    return 'सेव हो गया। अब स्टॉक में: $quantity';
  }

  @override
  String get stockAmountInvalid => 'पूरी संख्या लिखें, जैसे 12';

  @override
  String stockInsufficient(String current) {
    return 'स्टॉक में सिर्फ़ $current है। इससे ज़्यादा नहीं निकाल सकते।';
  }

  @override
  String get stockTooMuch => 'इससे स्टॉक की अधिकतम सीमा पार हो जाएगी।';

  @override
  String get stockNoChange => 'यह दर्ज स्टॉक के बराबर ही है।';

  @override
  String get reasonPurchase => 'खरीद';

  @override
  String get reasonSale => 'बिक्री';

  @override
  String get reasonReturned => 'वापसी';

  @override
  String get reasonDamaged => 'खराब';

  @override
  String get reasonExpired => 'एक्सपायर';

  @override
  String get reasonCorrection => 'सुधार';

  @override
  String get reasonOther => 'अन्य';

  @override
  String get errorInsufficientStock =>
      'स्टॉक बदल गया है या काफ़ी नहीं है। कृपया जाँचकर दोबारा कोशिश करें।';

  @override
  String get activityEmptyTitle => 'अभी कोई गतिविधि नहीं';

  @override
  String get activityEmptyBody => 'स्टॉक आना, जाना और सुधार यहाँ दिखेंगे।';

  @override
  String get activityLoadErrorTitle => 'गतिविधि लोड नहीं हो सकी';

  @override
  String get scanBarcode => 'बारकोड स्कैन करें';

  @override
  String get scannerTitle => 'बारकोड स्कैन करें';

  @override
  String get scannerHint =>
      'बारकोड को कैमरे के सामने रखें। कैमरा न चले तो बारकोड खुद लिखें।';

  @override
  String get scannerTorch => 'फ़्लैश';

  @override
  String get scannerManualEntry => 'बारकोड खुद लिखें';

  @override
  String get scannerManualTitle => 'बारकोड लिखें';

  @override
  String get scannerUseCode => 'यह बारकोड इस्तेमाल करें';

  @override
  String get scannerUnusableCode =>
      'यह कोड बारकोड की तरह इस्तेमाल नहीं हो सकता।';

  @override
  String get scannerNoProductTitle => 'इस बारकोड का कोई प्रोडक्ट नहीं';

  @override
  String scannerNoProductBody(String code) {
    return 'बारकोड $code वाला कोई प्रोडक्ट अभी नहीं है।';
  }

  @override
  String get lookupButton => 'डिटेल खोजें';

  @override
  String get lookupLoading => 'खोज रहे हैं…';

  @override
  String get lookupFound =>
      'डिटेल Open Food Facts सूची से भरी गई है। इन्हें जाँच लें और कीमत खुद डालें।';

  @override
  String get lookupNotFound =>
      'यह बारकोड ऑनलाइन सूची में नहीं है। डिटेल खुद लिखें।';

  @override
  String get lookupFailed =>
      'डिटेल नहीं मिल सकी। इंटरनेट जाँचकर दोबारा कोशिश करें।';

  @override
  String get lookupNeedBarcode => 'पहले सही बारकोड लिखें या स्कैन करें।';

  @override
  String get productBrandLabel => 'ब्रांड (वैकल्पिक)';

  @override
  String productBrandTooLong(int max) {
    return 'ब्रांड ज़्यादा से ज़्यादा $max अक्षर का हो सकता है';
  }

  @override
  String get imageCredit => 'तस्वीर: Open Food Facts (CC BY-SA)';

  @override
  String get removePicture => 'तस्वीर हटाएँ';

  @override
  String priceHint(String price, String date) {
    return 'दूसरों ने $price बताया है ($date)। यह पुराना या किसी और दुकान का हो सकता है।';
  }

  @override
  String get priceHintUse => 'बिक्री मूल्य में डालें';

  @override
  String get pickCommonItem => 'आम सामान की सूची से चुनें';

  @override
  String get starterTitle => 'आम सामान';

  @override
  String get starterNote =>
      'सिर्फ़ नाम भरा जाएगा। बारकोड स्कैन करें और कीमत व स्टॉक खुद डालें। सामान पैक साइज़ में है।';

  @override
  String get starterSearchHint => 'सामान, ब्रांड या हिंदी नाम खोजें';

  @override
  String get starterNoMatch => 'कोई सामान नहीं मिला। खुद जोड़ें।';

  @override
  String get navBill => 'बिल';

  @override
  String get errorPriceChanged =>
      'बिलिंग के दौरान किसी चीज़ का दाम बदल गया। कृपया जाँचकर दोबारा कोशिश करें।';

  @override
  String get billTitle => 'नया बिल';

  @override
  String get billClear => 'बिल खाली करें';

  @override
  String get billHistory => 'बिल';

  @override
  String get billScanItem => 'सामान स्कैन करें';

  @override
  String get billAddByName => 'नाम से';

  @override
  String get billEmptyTitle => 'अभी कोई सामान नहीं';

  @override
  String get billEmptyBody =>
      'बिल में जोड़ने के लिए सामान का बारकोड स्कैन करें।';

  @override
  String billNotInInventory(String code) {
    return 'बारकोड $code आपके स्टॉक में नहीं है।';
  }

  @override
  String get billOutOfStock => 'स्टॉक खत्म';

  @override
  String get billNotEnoughStock => 'स्टॉक काफ़ी नहीं है';

  @override
  String get billProductArchived => 'यह सामान आर्काइव है';

  @override
  String billCartFull(int max) {
    return 'एक बिल में ज़्यादा से ज़्यादा $max अलग सामान हो सकते हैं।';
  }

  @override
  String billInStock(String quantity) {
    return 'स्टॉक में: $quantity';
  }

  @override
  String get billDecrease => 'कम करें';

  @override
  String get billIncrease => 'बढ़ाएँ';

  @override
  String billItemsCount(int count) {
    return '$count सामान';
  }

  @override
  String get billDiscount => 'छूट';

  @override
  String get billDiscountHint => 'छूट (रुपये में)';

  @override
  String get billApply => 'लगाएँ';

  @override
  String get billTotal => 'कुल';

  @override
  String get billSubtotal => 'उप-योग';

  @override
  String get billMakeBill => 'बिल बनाएँ';

  @override
  String get billSavedTitle => 'बिल सेव हो गया';

  @override
  String get billNotFound => 'बिल नहीं मिला';

  @override
  String billNumberLabel(int number) {
    return 'बिल नं. $number';
  }

  @override
  String get billNewBill => 'नया बिल';

  @override
  String get billHistoryEmpty => 'अभी कोई बिल नहीं।';

  @override
  String get payTitle => 'भुगतान';

  @override
  String get payFullCash => 'पूरा कैश';

  @override
  String get payFullUpi => 'पूरा UPI';

  @override
  String get payFullUdhar => 'पूरा उधार';

  @override
  String get payCash => 'कैश';

  @override
  String get payUpi => 'UPI';

  @override
  String get payUdhar => 'उधार';

  @override
  String get payUdharHint => 'जो अभी नहीं दिया गया';

  @override
  String get payTooMuch => 'कैश + UPI कुल से ज़्यादा है।';

  @override
  String get payNotBalanced => 'कैश + UPI + उधार कुल के बराबर होना चाहिए।';

  @override
  String get payCustomerPhone => 'ग्राहक का मोबाइल नंबर';

  @override
  String get payCustomerName => 'ग्राहक का नाम';

  @override
  String get payCustomerNameRequired => 'उधार के लिए ग्राहक का नाम लिखें।';

  @override
  String get payCustomerPhoneInvalid => 'सही 10 अंकों का मोबाइल नंबर लिखें।';

  @override
  String get payCustomer => 'ग्राहक';

  @override
  String payOldUdhar(String name, String amount) {
    return '$name का पहले से $amount उधार है।';
  }

  @override
  String payUseName(String name) {
    return '\"$name\" इस्तेमाल करें';
  }

  @override
  String get payConfirm => 'बिल सेव करें';

  @override
  String get pdfOpen => 'बिल PDF: प्रिंट / शेयर / डाउनलोड';

  @override
  String get pdfTitle => 'बिल PDF';

  @override
  String get pdfTemplateClassic => 'क्लासिक';

  @override
  String get pdfTemplateModern => 'मॉडर्न';

  @override
  String get pdfTemplateThermal => 'रसीद';

  @override
  String get pdfTemplateMinimal => 'मिनिमल';

  @override
  String get pdfPrint => 'प्रिंट';

  @override
  String get pdfShare => 'शेयर';

  @override
  String get pdfDownload => 'डाउनलोड';

  @override
  String get pdfSaved => 'PDF सेव हो गई।';

  @override
  String get pdfActionFailed => 'यह नहीं हो पाया। कृपया फिर कोशिश करें।';

  @override
  String get payCustomerOptionalTitle => 'ग्राहक (वैकल्पिक - बिल पर छपेगा)';

  @override
  String get payCustomerNameOptional => 'ग्राहक का नाम (वैकल्पिक)';

  @override
  String get payCustomerPhoneOptional => 'ग्राहक का मोबाइल (वैकल्पिक)';

  @override
  String get billMakeNew => 'नया बिल बनाएँ';

  @override
  String get dashToday => 'आज';

  @override
  String get dashYesterday => 'कल';

  @override
  String get dashLast7Days => '7 दिन';

  @override
  String get dashSales => 'बिक्री';

  @override
  String dashBillsItems(int bills, int items) {
    return '$bills बिल • $items सामान';
  }

  @override
  String get dashTruncated => 'सिर्फ़ आख़िरी 500 बिल दिख रहे हैं।';

  @override
  String get dashLoadError => 'बिक्री लोड नहीं हो पाई।';

  @override
  String get dashOwnSalesNote => 'आपको सिर्फ़ अपने बनाए बिल दिखते हैं।';

  @override
  String get dashUdharPending => 'बाकी उधार';

  @override
  String dashUdharCustomers(int count) {
    return '$count ग्राहक';
  }

  @override
  String dashLowStockTitle(int count) {
    return 'कम स्टॉक: $count सामान';
  }

  @override
  String dashOutOfStock(int count) {
    return '$count का स्टॉक खत्म';
  }

  @override
  String get dashAllStocked => 'सब कुछ कम-स्टॉक सीमा से ऊपर है।';

  @override
  String get dashViewAllProducts => 'सारे सामान देखें';

  @override
  String get navUdhar => 'उधार';

  @override
  String get errorOverpayment =>
      'यह ग्राहक के उधार से ज़्यादा है। कृपया रकम जाँचें।';

  @override
  String get udharTitle => 'उधार';

  @override
  String get udharTotal => 'कुल उधार';

  @override
  String get udharSearchHint => 'नाम या मोबाइल नंबर खोजें';

  @override
  String get udharShowSettled => 'चुकता भी दिखाएँ';

  @override
  String get udharSettled => 'चुकता';

  @override
  String get udharEmptyBody =>
      'अभी कोई उधार नहीं। बिल में उधार होगा तो ग्राहक यहाँ दिखेगा।';

  @override
  String get udharNoMatch => 'कोई ग्राहक नहीं मिला।';

  @override
  String get udharLoadError => 'उधार लोड नहीं हो पाया।';

  @override
  String get udharCustomerMissing => 'ग्राहक नहीं मिला।';

  @override
  String get udharBalance => 'उधार बाकी';

  @override
  String get udharRecordPayment => 'मिला हुआ पैसा दर्ज करें';

  @override
  String get udharLedger => 'हिसाब';

  @override
  String get udharEntryCredit => 'उधार (बिल)';

  @override
  String udharEntryPayment(String method) {
    return 'पैसा मिला ($method)';
  }

  @override
  String get udharPaymentTitle => 'मिला हुआ पैसा';

  @override
  String udharDueNow(String amount) {
    return 'बाकी उधार: $amount';
  }

  @override
  String get udharAmountLabel => 'मिली रकम';

  @override
  String get udharFullAmount => 'पूरी रकम';

  @override
  String get udharNoteLabel => 'नोट (वैकल्पिक)';

  @override
  String get udharSavePayment => 'पेमेंट सेव करें';

  @override
  String udharOverpay(String amount) {
    return '$amount के उधार से ज़्यादा';
  }

  @override
  String get shopDetailsTitle => 'दुकान की जानकारी';

  @override
  String get shopDetailsSubtitle => 'बिल पर छपने वाला नाम, पता, फ़ोन और UPI';

  @override
  String get shopDetailsNote =>
      'ये जानकारी हर बिल PDF में ऊपर और नीचे छपती है। सिर्फ़ मालिक इसे बदल सकता है।';

  @override
  String get shopAddressLabel => 'पता (वैकल्पिक)';

  @override
  String get shopUpiLabel => 'UPI ID (वैकल्पिक)';

  @override
  String get shopUpiHelper => 'जैसे: yourshop@okhdfcbank';

  @override
  String get shopFooterLabel => 'बिल की आख़िरी लाइन (वैकल्पिक)';

  @override
  String get shopFooterHelper => 'जैसे: धन्यवाद! फिर पधारें।';

  @override
  String get shopSave => 'सेव करें';

  @override
  String get shopSaved => 'दुकान की जानकारी सेव हो गई।';

  @override
  String storeAddressTooLong(int max) {
    return 'पता ज़्यादा से ज़्यादा $max अक्षर का हो सकता है';
  }

  @override
  String storeFooterTooLong(int max) {
    return 'यह लाइन ज़्यादा से ज़्यादा $max अक्षर की हो सकती है';
  }

  @override
  String get storeUpiInvalid => 'सही UPI ID लिखें, जैसे name@bank';

  @override
  String get reportsOpen => 'रिपोर्ट';

  @override
  String get reportsTitle => 'बिक्री रिपोर्ट';

  @override
  String get reportsLast30Days => '30 दिन';

  @override
  String get reportsThisMonth => 'इस महीने';

  @override
  String get reportsCustom => 'तारीख चुनें';

  @override
  String get reportsExport => 'CSV एक्सपोर्ट';

  @override
  String get reportsExported => 'CSV सेव हो गई।';

  @override
  String get reportsEmpty => 'इस अवधि में कोई बिल नहीं।';

  @override
  String reportsTruncated(int limit) {
    return 'सिर्फ़ आख़िरी $limit बिल दिख रहे हैं।';
  }

  @override
  String get reportsProfit => 'मुनाफ़ा';

  @override
  String get reportsNoProfit =>
      'मुनाफ़ा इस अपडेट के बाद बने बिलों पर दिखेगा (पुराने बिलों में खरीद भाव सेव नहीं था)।';

  @override
  String reportsProfitPartial(int counted, int total) {
    return '$total में से $counted बिल गिने गए, जिनमें खरीद भाव है।';
  }

  @override
  String get reportsDayByDay => 'दिन-दर-दिन';

  @override
  String reportsBillsCount(int bills) {
    return '$bills बिल';
  }

  @override
  String get reportsTopQuantity => 'सबसे ज़्यादा बिके (मात्रा)';

  @override
  String get reportsTopRevenue => 'सबसे ज़्यादा बिके (रकम)';

  @override
  String get voiceOpen => 'बोलकर जोड़ें';

  @override
  String get voiceTitle => 'बोलकर सामान जोड़ें';

  @override
  String get voiceExample =>
      'ऐसे बोलें: 2 atta, 1 sugar, 3 parle g। नीचे टाइप भी कर सकते हैं।';

  @override
  String get voiceTapToSpeak => 'माइक दबाकर बोलें';

  @override
  String get voiceListening => 'सुन रहा हूँ…';

  @override
  String get voiceTranscriptLabel => 'जो सुना (आप सुधार सकते हैं)';

  @override
  String get voiceUnavailable =>
      'इस फ़ोन पर बोलकर जोड़ना उपलब्ध नहीं है। आप यहाँ टाइप कर सकते हैं।';

  @override
  String get voiceMicError =>
      'माइक में दिक्कत आई। फिर कोशिश करें या टाइप करें।';

  @override
  String get voiceLangEnglish => 'English / Hinglish';

  @override
  String get voiceLangHindi => 'हिन्दी';

  @override
  String voiceNotFound(String text) {
    return 'नहीं मिला: $text';
  }

  @override
  String get voiceCheckMatch => 'यह सही मिला है या नहीं, देख लें';

  @override
  String voiceAdd(int count) {
    return 'बिल में जोड़ें ($count)';
  }

  @override
  String voiceAdded(int count) {
    return '$count सामान जुड़ गया।';
  }

  @override
  String voiceAddedWithProblems(int added, String problems) {
    return '$added जुड़ा। दिक्कत: $problems';
  }

  @override
  String get voiceNothing => 'अभी कुछ समझ नहीं आया।';

  @override
  String get orderOpen => 'ऑर्डर लिस्ट बनाएं';

  @override
  String get orderTitle => 'ऑर्डर लिस्ट';

  @override
  String get orderIntro =>
      'कम स्टॉक वाला सामान। कितना मंगाना है बदलें; किसी को छोड़ना हो तो 0 रखें।';

  @override
  String get orderEmpty => 'अभी कुछ भी कम स्टॉक में नहीं है।';

  @override
  String orderInStock(String stock) {
    return 'स्टॉक में: $stock';
  }

  @override
  String get orderCopy => 'टेक्स्ट कॉपी करें';

  @override
  String get orderShare => 'PDF शेयर करें';

  @override
  String get orderCopied => 'ऑर्डर लिस्ट कॉपी हो गई।';

  @override
  String get orderLess => 'कम';

  @override
  String get orderMore => 'ज़्यादा';

  @override
  String get unitKg => 'किलो (kg)';

  @override
  String get unitLitre => 'लीटर (L)';

  @override
  String quantityKg(String amount) {
    return '$amount किलो';
  }

  @override
  String quantityLitre(String amount) {
    return '$amount लीटर';
  }

  @override
  String get quantityInvalid =>
      '12 या 1.5 जैसी मात्रा लिखें (दशमलव के बाद 3 अंक तक)।';

  @override
  String get billQuantityLabel => 'मात्रा';

  @override
  String get billQuantityInvalid => 'सही मात्रा लिखें, स्टॉक से ज़्यादा नहीं।';

  @override
  String get importTitle => 'प्रोडक्ट इम्पोर्ट';

  @override
  String get importMenu => 'फ़ाइल से इम्पोर्ट';

  @override
  String get importIntro =>
      'Excel (.xlsx) या CSV फ़ाइल से एक साथ कई प्रोडक्ट जोड़ें। कॉलम किसी भी क्रम में हो सकते हैं। Name, Item, Barcode, Unit, Rate, MRP, Qty, Stock जैसे हेडिंग समझे जाते हैं। फॉर्मैट देखने के लिए सैंपल शीट डाउनलोड करें।';

  @override
  String get importPick => 'Excel / CSV फ़ाइल चुनें';

  @override
  String get importSample => 'सैंपल शीट डाउनलोड करें';

  @override
  String get importSampleSaved => 'सैंपल शीट सेव हो गई।';

  @override
  String get importNoPermission => 'आपको प्रोडक्ट जोड़ने की अनुमति नहीं है।';

  @override
  String get importReading => 'फ़ाइल पढ़ रहे हैं…';

  @override
  String get importStop => 'रोकें';

  @override
  String get importErrRead =>
      'यह फ़ाइल पढ़ी नहीं जा सकी। इसे Excel में खोलकर CSV में सेव करें और फिर कोशिश करें।';

  @override
  String get importErrNoRows => 'फ़ाइल में कोई प्रोडक्ट पंक्ति नहीं है।';

  @override
  String get importErrNoColumns =>
      'पहली पंक्ति में Name या Barcode कॉलम नहीं मिला।';

  @override
  String get importErrNetwork =>
      'इंटरनेट की समस्या। इम्पोर्ट रुक गया; बाकी जोड़े नहीं गए। कनेक्शन देखकर फिर कोशिश करें।';

  @override
  String get importErrUnknown => 'कुछ गड़बड़ हो गई। कृपया फिर कोशिश करें।';

  @override
  String get importAllowNoPrice =>
      'बिना बिक्री कीमत वाले आइटम भी जोड़ें (कीमत 0, बाद में सेट करें)';

  @override
  String get importNothing => 'जोड़ने के लिए कुछ नहीं';

  @override
  String get importAnother => 'दूसरी फ़ाइल चुनें';

  @override
  String get importDoneTitle => 'इम्पोर्ट पूरा हुआ';

  @override
  String get importProblemsTitle => 'ध्यान देने वाली पंक्तियाँ';

  @override
  String get importProblemNameMissing => 'नाम नहीं है';

  @override
  String get importProblemNameTooLong => 'नाम बहुत लंबा है';

  @override
  String get importProblemBarcode => 'बारकोड सही नहीं है';

  @override
  String get importProblemUnit => 'यूनिट समझ नहीं आई';

  @override
  String get importProblemPrice => 'कीमत सही नहीं है';

  @override
  String get importProblemStock => 'स्टॉक सही नहीं है';

  @override
  String get importProblemThreshold => 'कम-स्टॉक अलर्ट सही नहीं है';

  @override
  String get importProblemTextLong => 'ब्रांड, कैटेगरी या SKU बहुत लंबा है';

  @override
  String get importProblemExists => 'पहले से आपके प्रोडक्ट में है';

  @override
  String get importProblemRepeated => 'फ़ाइल में दोहराया गया';

  @override
  String get importProblemNotFound => 'बारकोड ऑनलाइन नहीं मिला, नाम डालें';

  @override
  String get importProblemLookup => 'बारकोड खोजा नहीं जा सका';

  @override
  String get importProblemWrite => 'सेव नहीं हो सका';

  @override
  String importLookingUp(int done, int total) {
    return 'बारकोड से नाम खोज रहे हैं… $done/$total';
  }

  @override
  String importProgress(int done, int total) {
    return 'जोड़ रहे हैं… $done/$total';
  }

  @override
  String importTruncated(int max) {
    return 'सिर्फ़ पहली $max पंक्तियाँ ली गई हैं।';
  }

  @override
  String importStart(int count) {
    return '$count प्रोडक्ट जोड़ें';
  }

  @override
  String importCountReady(int count) {
    return '$count तैयार';
  }

  @override
  String importCountAdded(int count) {
    return '$count जुड़े';
  }

  @override
  String importCountNoPrice(int count) {
    return '$count बिना कीमत';
  }

  @override
  String importCountSkipped(int count) {
    return '$count छोड़े गए';
  }

  @override
  String importCountInvalid(int count) {
    return '$count में समस्या';
  }

  @override
  String importRowLine(int line, String reason) {
    return 'पंक्ति $line: $reason';
  }

  @override
  String importMoreProblems(int count) {
    return '…और $count और';
  }

  @override
  String get scannerPhotoButton => 'फ़ोटो से बारकोड पढ़ें';

  @override
  String get scannerPhotoCamera => 'फ़ोटो खींचें';

  @override
  String get scannerPhotoGallery => 'गैलरी से चुनें';

  @override
  String get scannerPhotoReading => 'फ़ोटो पढ़ रहे हैं…';

  @override
  String get scannerPhotoNotFound =>
      'इस फ़ोटो में बारकोड नहीं मिला। बारकोड सीधा, साफ़ और पास रखकर फिर कोशिश करें।';

  @override
  String get scannerPhotoFailed => 'फ़ोटो खुल नहीं सकी। कृपया फिर कोशिश करें।';

  @override
  String get importPhoto => 'बिल या लिस्ट की फ़ोटो';

  @override
  String get photoImportTitle => 'फ़ोटो से जोड़ें';

  @override
  String get photoImportIntro =>
      'सप्लायर बिल या स्टॉक लिस्ट की फ़ोटो खींचें, या गैलरी से चुनें। टेक्स्ट आपके फ़ोन पर ही पढ़ा जाता है, और कुछ भी जुड़ने से पहले आप हर आइटम जाँचते हैं। छपा हुआ टेक्स्ट सबसे अच्छा चलता है; हाथ की लिखाई अक्सर गलत पढ़ी जाती है।';

  @override
  String get photoImportReading => 'फ़ोटो पढ़ रहे हैं…';

  @override
  String get photoImportFailed =>
      'फ़ोटो पढ़ी नहीं जा सकी। कृपया फिर कोशिश करें।';

  @override
  String get photoImportEmpty =>
      'इस फ़ोटो में टेक्स्ट नहीं मिला। अच्छी रोशनी में, पन्ना सीधा रखकर फ़ोटो लें।';

  @override
  String get photoImportNoItems =>
      'टेक्स्ट मिला, पर कोई प्रोडक्ट पंक्ति नहीं। पास से, साफ़ फ़ोटो लें।';

  @override
  String get photoImportCheck =>
      'हर आइटम जाँचें। नाम और संख्या ठीक करें, और जो प्रोडक्ट नहीं है उसे अनटिक करें। बिक्री कीमत डालें, वरना वे आइटम अगली स्क्रीन पर रुके रहेंगे।';

  @override
  String get photoImportRetake => 'दूसरी फ़ोटो';

  @override
  String get photoImportName => 'नाम';

  @override
  String get photoImportStock => 'स्टॉक';

  @override
  String get photoImportCost => 'खरीद कीमत';

  @override
  String get photoImportSelling => 'बिक्री कीमत';

  @override
  String photoImportContinue(int count) {
    return '$count आइटम के साथ आगे बढ़ें';
  }

  @override
  String get billPendingLabel => 'बिल (सिंक होना बाकी)';

  @override
  String get billSavedOfflineNote =>
      'इंटरनेट नहीं है। यह बिल आपके फ़ोन में सेव है। इंटरनेट आते ही यह रिकॉर्ड में जुड़ जाएगा और स्टॉक घटेगा।';

  @override
  String get pendingScreenTitle => 'सिंक का इंतज़ार करते बिल';

  @override
  String get pendingEmpty => 'कुछ भी बाकी नहीं है। सभी बिल सेव हैं।';

  @override
  String get pendingSyncNow => 'अभी कोशिश करें';

  @override
  String get pendingRetry => 'फिर कोशिश करें';

  @override
  String get pendingDiscard => 'हटाएँ';

  @override
  String get pendingDiscardTitle => 'यह बिल हटाएँ?';

  @override
  String get pendingDiscardBody =>
      'यह बिल आपके रिकॉर्ड में कभी सेव नहीं हुआ और स्टॉक भी नहीं घटा। हटाने पर यह हमेशा के लिए चला जाएगा।';

  @override
  String get pendingWaitingLine => 'इंटरनेट का इंतज़ार';

  @override
  String get pendingReasonStock =>
      'अभी स्टॉक कम है। स्टॉक जोड़ें, फिर कोशिश करें।';

  @override
  String get pendingReasonPrice =>
      'यह बिल बनने के बाद किसी की कीमत बदल गई। पुरानी कीमत वापस रखकर कोशिश करें, या हटा दें।';

  @override
  String get pendingReasonGone =>
      'इस बिल का कोई प्रोडक्ट आर्काइव हो गया। इसे हटाकर बिल दोबारा बनाएँ।';

  @override
  String get pendingReasonOther => 'सेव नहीं हो सका। फिर कोशिश करें।';

  @override
  String pendingBannerWaiting(int count) {
    return 'ऑफ़लाइन चल रहा है – इंटरनेट आने पर $count बिल सिंक होंगे';
  }

  @override
  String pendingBannerAttention(int count) {
    return '$count बिलों पर आपका ध्यान चाहिए';
  }

  @override
  String get productsExport => 'प्रोडक्ट डाउनलोड करें (CSV बैकअप)';

  @override
  String get productsExported =>
      'प्रोडक्ट सेव हो गए। इस फ़ाइल को Import से दोबारा जोड़ा जा सकता है।';

  @override
  String get navNewSale => 'नया बिल';

  @override
  String get dashKpiLowStock => 'कम स्टॉक';

  @override
  String get dashRecentTitle => 'हाल के बिल';

  @override
  String get dashRecentEmpty =>
      'अभी कोई बिक्री नहीं।\n+ बटन दबाकर अपना पहला बिल बनाएँ!';

  @override
  String get dashTagReceived => 'मिल गया';

  @override
  String get dashTagPending => 'बाकी';

  @override
  String get homeQuickAddProduct => 'प्रोडक्ट जोड़ें';

  @override
  String get homeQuickImport => 'Excel इम्पोर्ट';

  @override
  String get homeQuickSync => 'ऑफ़लाइन सिंक';

  @override
  String get homeQuickSetup => 'दुकान सेटअप';

  @override
  String get homeGreetingMorning => 'सुप्रभात';

  @override
  String get homeGreetingAfternoon => 'नमस्कार';

  @override
  String get homeGreetingEvening => 'शुभ संध्या';

  @override
  String get ownerNameLabel => 'मालिक का नाम';

  @override
  String get ownerNameHelper => 'आपका नाम, होम स्क्रीन के अभिवादन में दिखेगा';

  @override
  String get profileTitle => 'प्रोफ़ाइल और सेटिंग्स';

  @override
  String get profileSectionShop => 'दुकान';

  @override
  String get profileSectionPreferences => 'पसंद';

  @override
  String get profileSectionSupport => 'सहायता';

  @override
  String get profileOwnerFallback => 'दुकान मालिक';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsLanguageSystem => 'फ़ोन की भाषा';

  @override
  String get settingsTheme => 'थीम';

  @override
  String get settingsThemeSystem => 'फ़ोन के अनुसार';

  @override
  String get settingsThemeLight => 'लाइट';

  @override
  String get settingsThemeDark => 'डार्क';

  @override
  String get settingsHelp => 'मदद और सहायता';

  @override
  String get settingsHelpSubtitle => 'आम सवाल और सुझाव';

  @override
  String get settingsAbout => 'Apna Shop के बारे में';

  @override
  String get aboutBody =>
      'आपकी दुकान के लिए आसान स्टॉक, बिलिंग और उधार। आपका डेटा ऑनलाइन सुरक्षित रहता है और इंटरनेट के बिना भी बिल बन सकते हैं।';

  @override
  String get helpTitle => 'मदद और सहायता';

  @override
  String get helpQ1 => 'इंटरनेट बंद है, क्या बिल बन सकता है?';

  @override
  String get helpA1 =>
      'हाँ। बिल फ़ोन में सेव हो जाता है और इंटरनेट आते ही अपने आप ऑनलाइन चला जाता है। इंतज़ार वाले बिल स्क्रीन के ऊपर दिखते हैं।';

  @override
  String get helpQ2 => 'बहुत सारे प्रोडक्ट जल्दी कैसे जोड़ें?';

  @override
  String get helpA2 =>
      'प्रोडक्ट खोलकर इम्पोर्ट (Excel/CSV या लिस्ट की फ़ोटो) चुनें। प्रोडक्ट जोड़ते समय बारकोड भी स्कैन कर सकते हैं।';

  @override
  String get helpQ3 => 'ग्राहक ने उधार लिया, अब क्या करें?';

  @override
  String get helpA3 =>
      'बिल बनाते समय उधार चुनें और ग्राहक का नाम व फ़ोन डालें। बाद में उधार खोलकर पैसे आने पर पेमेंट दर्ज करें।';

  @override
  String get helpQ4 => 'अपना नाम, दुकान का नाम या UPI कैसे बदलें?';

  @override
  String get helpA4 =>
      'प्रोफ़ाइल > दुकान की जानकारी। मालिक का नाम होम पर अभिवादन में दिखता है।';

  @override
  String get helpQ5 => 'हिंदी या डार्क मोड कैसे लगाएँ?';

  @override
  String get helpA5 =>
      'प्रोफ़ाइल > भाषा और थीम। चुनाव इसी फ़ोन में याद रहता है।';

  @override
  String get billSearchHint => 'नाम से आइटम खोजें';

  @override
  String get billRemoveItem => 'आइटम हटाएँ';

  @override
  String billPayAmount(String amount) {
    return '$amount चुकाएँ';
  }

  @override
  String get productsFilterAll => 'सभी';

  @override
  String get productsFilterOut => 'स्टॉक खत्म';

  @override
  String get productOutBadge => 'स्टॉक खत्म';

  @override
  String get productInBadge => 'स्टॉक में';
}
