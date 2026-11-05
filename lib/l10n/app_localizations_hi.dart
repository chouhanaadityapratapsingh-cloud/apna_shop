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
}
