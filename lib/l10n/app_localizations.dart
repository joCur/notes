import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

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
    Locale('de'),
    Locale('en'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Voice Notes'**
  String get appTitle;

  /// A simple greeting
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// Welcome message on the home screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to Voice-First Note Taking'**
  String get welcomeMessage;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// Button text to retry an operation
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Button text to cancel an operation
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button text to save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Button text to delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Button text for OK
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Network connection error
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again'**
  String get errorNetwork;

  /// Unknown error
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again'**
  String get errorUnknown;

  /// Invalid login credentials
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Please try again'**
  String get errorAuthInvalidCredentials;

  /// Auth session expired
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again'**
  String get errorAuthSessionExpired;

  /// Email not verified
  ///
  /// In en, this message translates to:
  /// **'Please confirm your email address to continue'**
  String get errorAuthEmailNotConfirmed;

  /// Password too weak
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get errorAuthWeakPassword;

  /// User doesn't exist
  ///
  /// In en, this message translates to:
  /// **'No account found with this email'**
  String get errorAuthUserNotFound;

  /// Email already in use
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get errorAuthEmailExists;

  /// Invalid auth token
  ///
  /// In en, this message translates to:
  /// **'Invalid authentication token'**
  String get errorAuthInvalidToken;

  /// Expired auth token
  ///
  /// In en, this message translates to:
  /// **'Authentication token has expired'**
  String get errorAuthTokenExpired;

  /// Unknown auth error
  ///
  /// In en, this message translates to:
  /// **'Authentication error. Please try again'**
  String get errorAuthUnknown;

  /// Database unique constraint violation
  ///
  /// In en, this message translates to:
  /// **'This record already exists'**
  String get errorPgUniqueViolation;

  /// Database not null violation
  ///
  /// In en, this message translates to:
  /// **'Required field is missing'**
  String get errorPgNotNullViolation;

  /// Database foreign key violation
  ///
  /// In en, this message translates to:
  /// **'Referenced record not found'**
  String get errorPgForeignKeyViolation;

  /// Database permission denied
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to perform this action'**
  String get errorPgInsufficientPrivilege;

  /// Text exceeds maximum length
  ///
  /// In en, this message translates to:
  /// **'Input text is too long'**
  String get errorPgStringTooLong;

  /// Generic database error
  ///
  /// In en, this message translates to:
  /// **'Database error. Please try again'**
  String get errorDatabaseGeneric;

  /// Database record not found
  ///
  /// In en, this message translates to:
  /// **'Record not found'**
  String get errorDatabaseNotFound;

  /// Database connection failed
  ///
  /// In en, this message translates to:
  /// **'Database is temporarily unavailable'**
  String get errorDatabaseUnavailable;

  /// Storage file doesn't exist
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get errorStorageFileNotFound;

  /// File exceeds size limit
  ///
  /// In en, this message translates to:
  /// **'File is too large'**
  String get errorStorageFileTooLarge;

  /// Storage permission denied
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to access this file'**
  String get errorStorageAccessDenied;

  /// Storage bucket doesn't exist
  ///
  /// In en, this message translates to:
  /// **'Storage bucket not found'**
  String get errorStorageBucketNotFound;

  /// Generic storage error
  ///
  /// In en, this message translates to:
  /// **'Storage error. Please try again'**
  String get errorStorageGeneric;

  /// Login screen title
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginTitle;

  /// Email input field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// Password input field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get loginButton;

  /// Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get loginForgotPassword;

  /// No account text
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// Sign up link text
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get loginSignUpLink;

  /// Invalid email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get loginEmailError;

  /// Short password validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get loginPasswordError;

  /// Signup screen title
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signupTitle;

  /// Email input field label on signup
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signupEmailLabel;

  /// Password input field label on signup
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signupPasswordLabel;

  /// Confirm password input field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get signupConfirmPasswordLabel;

  /// Create account button text
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get signupButton;

  /// Already have account text
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get signupHaveAccount;

  /// Login link text on signup
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get signupLoginLink;

  /// Password mismatch validation error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get signupPasswordMismatch;

  /// Weak password validation error
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Use at least 8 characters'**
  String get signupPasswordWeak;

  /// Weak password strength indicator
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get signupPasswordStrengthWeak;

  /// Medium password strength indicator
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get signupPasswordStrengthMedium;

  /// Strong password strength indicator
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get signupPasswordStrengthStrong;

  /// Account creation success message
  ///
  /// In en, this message translates to:
  /// **'Account created! Please check your email to verify your account'**
  String get signupSuccess;

  /// Forgot password screen title
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotPasswordTitle;

  /// Email input field label on forgot password
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get forgotPasswordEmailLabel;

  /// Send reset link button text
  ///
  /// In en, this message translates to:
  /// **'SEND RESET LINK'**
  String get forgotPasswordButton;

  /// Forgot password instructions
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password'**
  String get forgotPasswordInstructions;

  /// Password reset email sent success message
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent! Check your inbox'**
  String get forgotPasswordSuccess;

  /// Back to login link text
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get forgotPasswordBackToLogin;

  /// Reset password screen title
  ///
  /// In en, this message translates to:
  /// **'Create New Password'**
  String get resetPasswordTitle;

  /// New password input field label
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get resetPasswordNewLabel;

  /// Confirm new password input field label
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get resetPasswordConfirmLabel;

  /// Reset password button text
  ///
  /// In en, this message translates to:
  /// **'RESET PASSWORD'**
  String get resetPasswordButton;

  /// Password reset success message
  ///
  /// In en, this message translates to:
  /// **'Password reset successful! You can now sign in'**
  String get resetPasswordSuccess;

  /// Sign out button text
  ///
  /// In en, this message translates to:
  /// **'SIGN OUT'**
  String get signOut;

  /// Simple welcome greeting
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Placeholder message for note list feature
  ///
  /// In en, this message translates to:
  /// **'Note List Coming Soon'**
  String get noteListComingSoon;

  /// Placeholder description on home page
  ///
  /// In en, this message translates to:
  /// **'This is a placeholder home screen.\nThe note list will be implemented in Phase 4.'**
  String get homePagePlaceholder;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;
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
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
