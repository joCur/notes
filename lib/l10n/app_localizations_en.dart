// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Voice Notes';

  @override
  String get hello => 'Hello';

  @override
  String get welcomeMessage => 'Welcome to Voice-First Note Taking';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get ok => 'OK';

  @override
  String get errorNetwork => 'Check your internet connection and try again';

  @override
  String get errorUnknown => 'An unexpected error occurred. Please try again';

  @override
  String get errorAuthInvalidCredentials =>
      'Invalid email or password. Please try again';

  @override
  String get errorAuthSessionExpired =>
      'Your session has expired. Please sign in again';

  @override
  String get errorAuthEmailNotConfirmed =>
      'Please confirm your email address to continue';

  @override
  String get errorAuthWeakPassword => 'Password must be at least 6 characters';

  @override
  String get errorAuthUserNotFound => 'No account found with this email';

  @override
  String get errorAuthEmailExists => 'This email is already registered';

  @override
  String get errorAuthInvalidToken => 'Invalid authentication token';

  @override
  String get errorAuthTokenExpired => 'Authentication token has expired';

  @override
  String get errorAuthUnknown => 'Authentication error. Please try again';

  @override
  String get errorPgUniqueViolation => 'This record already exists';

  @override
  String get errorPgNotNullViolation => 'Required field is missing';

  @override
  String get errorPgForeignKeyViolation => 'Referenced record not found';

  @override
  String get errorPgInsufficientPrivilege =>
      'You don\'t have permission to perform this action';

  @override
  String get errorPgStringTooLong => 'Input text is too long';

  @override
  String get errorDatabaseGeneric => 'Database error. Please try again';

  @override
  String get errorDatabaseNotFound => 'Record not found';

  @override
  String get errorDatabaseUnavailable => 'Database is temporarily unavailable';

  @override
  String get errorStorageFileNotFound => 'File not found';

  @override
  String get errorStorageFileTooLarge => 'File is too large';

  @override
  String get errorStorageAccessDenied =>
      'You don\'t have permission to access this file';

  @override
  String get errorStorageBucketNotFound => 'Storage bucket not found';

  @override
  String get errorStorageGeneric => 'Storage error. Please try again';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginButton => 'SIGN IN';

  @override
  String get loginForgotPassword => 'Forgot Password?';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginSignUpLink => 'Sign up';

  @override
  String get loginEmailError => 'Please enter a valid email';

  @override
  String get loginPasswordError => 'Password must be at least 6 characters';

  @override
  String get signupTitle => 'Create Account';

  @override
  String get signupEmailLabel => 'Email';

  @override
  String get signupPasswordLabel => 'Password';

  @override
  String get signupConfirmPasswordLabel => 'Confirm Password';

  @override
  String get signupButton => 'CREATE ACCOUNT';

  @override
  String get signupHaveAccount => 'Already have an account?';

  @override
  String get signupLoginLink => 'Log in';

  @override
  String get signupPasswordMismatch => 'Passwords do not match';

  @override
  String get signupPasswordWeak =>
      'Password is too weak. Use at least 8 characters';

  @override
  String get signupPasswordStrengthWeak => 'Weak';

  @override
  String get signupPasswordStrengthMedium => 'Medium';

  @override
  String get signupPasswordStrengthStrong => 'Strong';

  @override
  String get signupSuccess =>
      'Account created! Please check your email to verify your account';

  @override
  String get forgotPasswordTitle => 'Reset Password';

  @override
  String get forgotPasswordEmailLabel => 'Email';

  @override
  String get forgotPasswordButton => 'SEND RESET LINK';

  @override
  String get forgotPasswordInstructions =>
      'Enter your email address and we\'ll send you a link to reset your password';

  @override
  String get forgotPasswordSuccess =>
      'Password reset email sent! Check your inbox';

  @override
  String get forgotPasswordBackToLogin => 'Back to login';

  @override
  String get resetPasswordTitle => 'Create New Password';

  @override
  String get resetPasswordNewLabel => 'New Password';

  @override
  String get resetPasswordConfirmLabel => 'Confirm New Password';

  @override
  String get resetPasswordButton => 'RESET PASSWORD';

  @override
  String get resetPasswordSuccess =>
      'Password reset successful! You can now sign in';

  @override
  String get signOut => 'SIGN OUT';

  @override
  String get welcome => 'Welcome';

  @override
  String get noteListComingSoon => 'Note List Coming Soon';

  @override
  String get homePagePlaceholder =>
      'This is a placeholder home screen.\nThe note list will be implemented in Phase 4.';

  @override
  String get loading => 'Loading...';
}
