import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    final AppLocalizations? localizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (localizations != null) {
      return localizations;
    }

    // Fallback to English if localizations aren't loaded yet
    final fallback = AppLocalizations(const Locale('en'));
    // Try to load English translations synchronously for fallback
    try {
      fallback._loadSync();
    } catch (e) {
      // If sync loading fails, use empty map
      fallback._localizedStrings = {};
    }
    return fallback;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  // Synchronous version for fallback
  void _loadSync() {
    try {
      // For synchronous loading, we'll use a simple approach
      // In a real app, you might want to preload these or use a different approach
      _localizedStrings = {
        'appName': 'Healer Map',
        'profile': 'Profile',
        'changeLanguage': 'Change Language',
        'selectLanguage': 'Select your preferred language',
        'languageRestartNote': 'The app will restart to apply the new language settings',
        'saveLanguage': 'Save Language',
        'languageChanged': 'Language changed to {language}',
        'editAccount': 'Edit Account',
        'yourFavorites': 'Your Favorites',
        'changePassword': 'Change Password',
        'privacyPolicy': 'Privacy Policy',
        'deleteAccount': 'Delete Account',
        'logout': 'LOGOUT',
        'cancel': 'Cancel',
        'yesLogout': 'Yes, log out',
        'deleteAccountTitle': 'Delete Account',
        'deleteAccountConfirm': 'Are you sure you want to delete your account?',
        'deleteAccountWarning': 'This action cannot be undone',
        'yesDelete': 'Delete',
        'changePasswordTitle': 'Change Password',
        'oldPassword': 'Old Password',
        'newPassword': 'New Password',
        'confirmNewPassword': 'Confirm New Password',
        'save': 'Save',
        'home': 'Home',
        'map': 'Map',
        'favorites': 'Favorites',
        'blog': 'Blog',
        'login': 'Login',
        'signup': 'Sign Up',
        'email': 'Email',
        'password': 'Password',
        'confirmPassword': 'Confirm Password',
        'forgotPassword': 'Forgot Password?',
        'dontHaveAccount': "Don't have an account?",
        'alreadyHaveAccount': 'Already have an account?',
        'resetPassword': 'Reset Password',
        'enterEmailReset': 'Enter your email to reset your password',
        'sendResetLink': 'Send Reset Link',
        'backToLogin': 'Back to Login',
        'createAccount': 'Create Account',
        'firstName': 'First Name',
        'lastName': 'Last Name',
        'username': 'Username',
        'displayName': 'Display Name',
        'welcomeBack': 'Welcome Back',
        'signInContinue': 'Sign in to continue',
        'createNewAccount': 'Create a new account',
        'verifyEmail': 'Verify Email',
        'enterVerificationCode': 'Enter the verification code sent to your email',
        'verify': 'Verify',
        'resendCode': 'Resend Code',
        'emailRequired': 'Email is required',
        'passwordRequired': 'Password is required',
        'nameRequired': 'Name is required',
        'phoneRequired': 'Phone number is required',
        'passwordMismatch': 'Passwords do not match',
        'passwordTooShort': 'Password must be at least 8 characters',
        'invalidEmail': 'Please enter a valid email address',
        'networkError': 'Network error occurred',
        'unknownError': 'An unknown error occurred',
        'success': 'Success',
        'error': 'Error',
        'loading': 'Loading...',
        'retry': 'Retry',
        'ok': 'OK',
        'settings': 'Settings',
        'notifications': 'Notifications',
        'help': 'Help',
        'about': 'About',
        'version': 'Version',
        'termsOfService': 'Terms of Service',
        'contactUs': 'Contact Us',
        'rateApp': 'Rate App',
        'shareApp': 'Share App',
        'logoutConfirm': 'Are you sure you want to log out?',
        'deleteAccountConfirmLong': 'Are you sure you want to delete your account? This action cannot be undone.',
        'passwordChanged': 'Password changed successfully',
        'profileUpdated': 'Profile updated successfully',
        'accountDeleted': 'Account deleted successfully',
        'loginSuccessful': 'Login successful',
        'signupSuccessful': 'Account created successfully',
        'verificationSent': 'Verification code sent',
        'resetLinkSent': 'Password reset link sent',
        'addBusiness': '+ Add Business',
        'findHealers': 'Find your Healers...',
        'healers': 'Healers',
        'seeAll': 'View All',
      };
    } catch (e) {
      _localizedStrings = {};
    }
  }

  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString('lib/l10n/app_${locale.languageCode}.arb');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
      return true;
    } catch (e) {
      // If loading fails, use empty map as fallback
      _localizedStrings = {};
      return false;
    }
  }

  String translate(String key, [Map<String, String>? arguments]) {
    String? value = _localizedStrings[key];
    if (value == null) return key;

    if (arguments != null) {
      arguments.forEach((argKey, argValue) {
        value = value!.replaceAll('{$argKey}', argValue);
      });
    }

    return value!;
  }

  // Common translations
  String get appName => translate('appName');
  String get profile => translate('profile');
  String get changeLanguage => translate('changeLanguage');
  String get selectLanguage => translate('selectLanguage');
  String get languageRestartNote => translate('languageRestartNote');
  String get saveLanguage => translate('saveLanguage');
  String languageChanged(String language) => translate('languageChanged', {'language': language});
  String get editAccount => translate('editAccount');
  String get yourFavorites => translate('yourFavorites');
  String get changePassword => translate('changePassword');
  String get privacyPolicy => translate('privacyPolicy');
  String get deleteAccount => translate('deleteAccount');
  String get logout => translate('logout');
  String get cancel => translate('cancel');
  String get yesLogout => translate('yesLogout');
  String get deleteAccountTitle => translate('deleteAccountTitle');
  String get deleteAccountConfirm => translate('deleteAccountConfirm');
  String get deleteAccountWarning => translate('deleteAccountWarning');
  String get yesDelete => translate('yesDelete');
  String get changePasswordTitle => translate('changePasswordTitle');
  String get oldPassword => translate('oldPassword');
  String get newPassword => translate('newPassword');
  String get confirmNewPassword => translate('confirmNewPassword');
  String get save => translate('save');
  String get home => translate('home');
  String get goodMorning => translate('goodMorning');
  String get goodAfternoon => translate('goodAfternoon');
  String get goodEvening => translate('goodEvening');
  String get goodNight => translate('goodNight');
  String get map => translate('map');
  String get favorites => translate('favorites');
  String get blog => translate('blog');
  String get login => translate('login');
  String get signup => translate('signup');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirmPassword');
  String get forgotPassword => translate('forgotPassword');
  String get dontHaveAccount => translate('dontHaveAccount');
  String get alreadyHaveAccount => translate('alreadyHaveAccount');
  String get resetPassword => translate('resetPassword');
  String get enterEmailReset => translate('enterEmailReset');
  String get sendResetLink => translate('sendResetLink');
  String get backToLogin => translate('backToLogin');
  String get createAccount => translate('createAccount');
  String get fullName => translate('fullName');
  String get firstName => translate('firstName');
  String get lastName => translate('lastName');
  String get username => translate('username');
  String get displayName => translate('displayName');
  String get welcomeBack => translate('welcomeBack');
  String get signInContinue => translate('signInContinue');
  String get createNewAccount => translate('createNewAccount');
  String get verifyEmail => translate('verifyEmail');
  String get enterVerificationCode => translate('enterVerificationCode');
  String get verify => translate('verify');
  String get resendCode => translate('resendCode');
  String get emailRequired => translate('emailRequired');
  String get passwordRequired => translate('passwordRequired');
  String get nameRequired => translate('nameRequired');
  String get phoneRequired => translate('phoneRequired');
  String get passwordMismatch => translate('passwordMismatch');
  String get passwordTooShort => translate('passwordTooShort');
  String get invalidEmail => translate('invalidEmail');
  String get networkError => translate('networkError');
  String get unknownError => translate('unknownError');
  String get success => translate('success');
  String get error => translate('error');
  String get loading => translate('loading');
  String get retry => translate('retry');
  String get ok => translate('ok');
  String get settings => translate('settings');
  String get notifications => translate('notifications');
  String get help => translate('help');
  String get about => translate('about');
  String get version => translate('version');
  String get termsOfService => translate('termsOfService');
  String get contactUs => translate('contactUs');
  String get rateApp => translate('rateApp');
  String get shareApp => translate('shareApp');
  String get logoutConfirm => translate('logoutConfirm');
  String get deleteAccountConfirmLong => translate('deleteAccountConfirmLong');
  String get passwordChanged => translate('passwordChanged');
  String get profileUpdated => translate('profileUpdated');
  String get accountDeleted => translate('accountDeleted');
  String get loginSuccessful => translate('loginSuccessful');
  String get signupSuccessful => translate('signupSuccessful');
  String get verificationSent => translate('verificationSent');
  String get resetLinkSent => translate('resetLinkSent');
  String get addBusiness => translate('addBusiness');
  String get findHealers => translate('findHealers');
  String get healers => translate('healers');
  String get seeAll => translate('seeAll');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'fr', 'de', 'it', 'pt'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => true; // Always reload when locale changes
}

class LocalizationProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  void setLocale(Locale locale) {
    if (_currentLocale != locale) {
      _currentLocale = locale;
      notifyListeners();
    }
  }

  void setLocaleFromLanguageCode(String languageCode) {
    setLocale(Locale(languageCode));
  }

  String get currentLanguageCode => _currentLocale.languageCode;
}

final localizationProvider = LocalizationProvider();
