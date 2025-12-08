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

  /// Button text to close something
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

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

  /// Voice input screen title
  ///
  /// In en, this message translates to:
  /// **'Voice Input'**
  String get voiceInputTitle;

  /// Placeholder text for voice input
  ///
  /// In en, this message translates to:
  /// **'Tap the button and start speaking...'**
  String get voiceInputPlaceholder;

  /// Status text when listening to voice
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get voiceInputListening;

  /// Status text when transcribing voice
  ///
  /// In en, this message translates to:
  /// **'Transcribing...'**
  String get voiceInputTranscribing;

  /// Button text to save voice note
  ///
  /// In en, this message translates to:
  /// **'SAVE NOTE'**
  String get voiceInputSaveNote;

  /// Error when microphone permission denied
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required for voice recording'**
  String get voiceInputPermissionDenied;

  /// Button text to open app settings for permissions
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get voiceInputPermissionSettings;

  /// Permission dialog title
  ///
  /// In en, this message translates to:
  /// **'Microphone Permission Required'**
  String get voiceInputPermissionTitle;

  /// Permission dialog message
  ///
  /// In en, this message translates to:
  /// **'This app needs access to your microphone to record voice notes'**
  String get voiceInputPermissionMessage;

  /// Error when voice recognition not available
  ///
  /// In en, this message translates to:
  /// **'Voice recognition is not available on this device'**
  String get voiceInputNotAvailable;

  /// Generic voice input error
  ///
  /// In en, this message translates to:
  /// **'An error occurred during voice recording. Please try again'**
  String get voiceInputError;

  /// Placeholder for empty transcription
  ///
  /// In en, this message translates to:
  /// **'Transcription will appear here...'**
  String get transcriptionPlaceholder;

  /// High confidence indicator
  ///
  /// In en, this message translates to:
  /// **'High confidence'**
  String get transcriptionConfidenceHigh;

  /// Medium confidence indicator
  ///
  /// In en, this message translates to:
  /// **'Medium confidence'**
  String get transcriptionConfidenceMedium;

  /// Low confidence indicator
  ///
  /// In en, this message translates to:
  /// **'Low confidence'**
  String get transcriptionConfidenceLow;

  /// Warning when trying to save empty transcription
  ///
  /// In en, this message translates to:
  /// **'Please record some text before saving'**
  String get voiceInputEmptyWarning;

  /// Success message when note is saved
  ///
  /// In en, this message translates to:
  /// **'Note saved successfully!'**
  String get voiceInputSaveSuccess;

  /// Error message when note save fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save note. Please try again'**
  String get voiceInputSaveError;

  /// Loading message while saving note
  ///
  /// In en, this message translates to:
  /// **'Saving note...'**
  String get voiceInputSaving;

  /// Accessibility label for voice button when idle
  ///
  /// In en, this message translates to:
  /// **'Start recording'**
  String get voiceButtonStartRecording;

  /// Accessibility label for voice button when recording
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get voiceButtonStopRecording;

  /// Accessibility label for clear transcription button
  ///
  /// In en, this message translates to:
  /// **'Clear transcription'**
  String get transcriptionClearButton;

  /// Title for notes list screen
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesListTitle;

  /// Empty state title when no notes exist
  ///
  /// In en, this message translates to:
  /// **'No Notes Yet'**
  String get notesListEmptyTitle;

  /// Empty state subtitle message
  ///
  /// In en, this message translates to:
  /// **'Start creating your first note using voice or text'**
  String get notesListEmptySubtitle;

  /// Empty state button to create voice note
  ///
  /// In en, this message translates to:
  /// **'Record Voice Note'**
  String get notesListEmptyActionVoice;

  /// Empty state button to create text note
  ///
  /// In en, this message translates to:
  /// **'Create Text Note'**
  String get notesListEmptyActionText;

  /// Error title when notes fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Notes'**
  String get notesListErrorLoadingTitle;

  /// Error message when notes fail to load
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch your notes. Please check your connection and try again'**
  String get notesListErrorLoadingMessage;

  /// Loading message for notes list
  ///
  /// In en, this message translates to:
  /// **'Loading your notes...'**
  String get notesListLoadingMessage;

  /// Search bar placeholder text
  ///
  /// In en, this message translates to:
  /// **'Search notes...'**
  String get notesListSearchPlaceholder;

  /// Floating action button label for voice note
  ///
  /// In en, this message translates to:
  /// **'Create Voice Note'**
  String get notesListCreateVoiceNote;

  /// Floating action button label for text note
  ///
  /// In en, this message translates to:
  /// **'Create Text Note'**
  String get notesListCreateTextNote;

  /// Floating action button tooltip for creating a note
  ///
  /// In en, this message translates to:
  /// **'Create Note'**
  String get notesListCreateNote;

  /// Tooltip for pull-to-refresh
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh'**
  String get notesListRefreshTooltip;

  /// Default title for notes without a title
  ///
  /// In en, this message translates to:
  /// **'Untitled Note'**
  String get notesListUntitled;

  /// Timestamp for very recent notes
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get notesListJustNow;

  /// Timestamp for notes created minutes ago
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String notesListMinutesAgo(int count);

  /// Timestamp for notes created hours ago
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String notesListHoursAgo(int count);

  /// Timestamp for notes created days ago
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String notesListDaysAgo(int count);

  /// Title for delete note confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Note?'**
  String get noteCardDeleteTitle;

  /// Message for delete note confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'This note will be permanently deleted. This action cannot be undone.'**
  String get noteCardDeleteMessage;

  /// Context menu option to edit a note
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get noteCardContextEdit;

  /// Context menu option to delete a note
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get noteCardContextDelete;

  /// Context menu option to share a note
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get noteCardContextShare;

  /// Title for note detail screen
  ///
  /// In en, this message translates to:
  /// **'Note Details'**
  String get noteDetailTitle;

  /// Accessibility label for back button on note detail screen
  ///
  /// In en, this message translates to:
  /// **'Back to notes'**
  String get noteDetailBackButton;

  /// Edit button label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get noteDetailEdit;

  /// Share button label
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get noteDetailShare;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get noteDetailDelete;

  /// Delete confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Note?'**
  String get noteDetailDeleteTitle;

  /// Delete confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'This note will be permanently deleted. This action cannot be undone.'**
  String get noteDetailDeleteMessage;

  /// Success message after note deletion
  ///
  /// In en, this message translates to:
  /// **'Note deleted successfully'**
  String get noteDetailDeleteSuccess;

  /// Error message when note deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete note. Please try again'**
  String get noteDetailDeleteError;

  /// Metadata section header
  ///
  /// In en, this message translates to:
  /// **'Note Information'**
  String get noteDetailMetadata;

  /// Created date label
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get noteDetailCreated;

  /// Last modified date label
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get noteDetailModified;

  /// Word count label
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get noteDetailWords;

  /// Language detection confidence label
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get noteDetailLanguageConfidence;

  /// Content section header
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get noteDetailContent;

  /// Empty content placeholder message
  ///
  /// In en, this message translates to:
  /// **'This note has no content'**
  String get noteDetailEmptyContent;

  /// Copy content to clipboard button label
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get noteDetailCopyToClipboard;

  /// Success message after copying content
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get noteDetailCopySuccess;

  /// Tags section header
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get noteDetailTags;

  /// Placeholder message for tags feature
  ///
  /// In en, this message translates to:
  /// **'Tags will be available in Phase 8'**
  String get noteDetailTagsComingSoon;

  /// Placeholder message for edit feature
  ///
  /// In en, this message translates to:
  /// **'Note editing will be available in Phase 7'**
  String get noteDetailEditComingSoon;

  /// Error message when sharing fails
  ///
  /// In en, this message translates to:
  /// **'Failed to share note. Please try again'**
  String get noteDetailShareError;

  /// Loading message for note detail screen
  ///
  /// In en, this message translates to:
  /// **'Loading note...'**
  String get noteDetailLoading;

  /// Error title when note fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Note'**
  String get noteDetailErrorTitle;

  /// Error message when note fails to load
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch the note. Please check your connection and try again'**
  String get noteDetailErrorMessage;

  /// Title for text editor screen
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get textEditorTitle;

  /// Placeholder for note title field
  ///
  /// In en, this message translates to:
  /// **'Title (optional)'**
  String get textEditorTitlePlaceholder;

  /// Placeholder for note content field
  ///
  /// In en, this message translates to:
  /// **'Start typing your note...'**
  String get textEditorContentPlaceholder;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get textEditorSaveButton;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get textEditorCancelButton;

  /// Error when trying to save empty note
  ///
  /// In en, this message translates to:
  /// **'Note content cannot be empty'**
  String get textEditorEmptyContentError;

  /// Success message when text note is saved
  ///
  /// In en, this message translates to:
  /// **'Text note created successfully'**
  String get textEditorSaveSuccess;

  /// Error message when note save fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save note. Please try again'**
  String get textEditorSaveError;

  /// Loading message while saving note
  ///
  /// In en, this message translates to:
  /// **'Saving note...'**
  String get textEditorSaving;

  /// Dialog title when user tries to exit with unsaved changes
  ///
  /// In en, this message translates to:
  /// **'Discard Changes?'**
  String get textEditorUnsavedChangesTitle;

  /// Dialog message when user tries to exit with unsaved changes
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Are you sure you want to discard them?'**
  String get textEditorUnsavedChangesMessage;

  /// Button to discard unsaved changes
  ///
  /// In en, this message translates to:
  /// **'DISCARD'**
  String get textEditorDiscardButton;

  /// Placeholder text for rich text editor
  ///
  /// In en, this message translates to:
  /// **'Start typing...'**
  String get editorPlaceholder;

  /// Tooltip for bold formatting button
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get toolbarBold;

  /// Tooltip for italic formatting button
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get toolbarItalic;

  /// Tooltip for underline formatting button
  ///
  /// In en, this message translates to:
  /// **'Underline'**
  String get toolbarUnderline;

  /// Tooltip for strikethrough formatting button
  ///
  /// In en, this message translates to:
  /// **'Strikethrough'**
  String get toolbarStrikethrough;

  /// Tooltip for bullet list button
  ///
  /// In en, this message translates to:
  /// **'Bullet List'**
  String get toolbarBulletList;

  /// Tooltip for numbered list button
  ///
  /// In en, this message translates to:
  /// **'Numbered List'**
  String get toolbarNumberedList;

  /// Tooltip for block quote button
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get toolbarQuote;

  /// Tooltip for left alignment button
  ///
  /// In en, this message translates to:
  /// **'Align Left'**
  String get toolbarAlignLeft;

  /// Tooltip for center alignment button
  ///
  /// In en, this message translates to:
  /// **'Align Center'**
  String get toolbarAlignCenter;

  /// Tooltip for right alignment button
  ///
  /// In en, this message translates to:
  /// **'Align Right'**
  String get toolbarAlignRight;

  /// Tooltip for clear formatting button
  ///
  /// In en, this message translates to:
  /// **'Clear Formatting'**
  String get toolbarClearFormatting;

  /// Tooltip for voice input button in editor toolbar
  ///
  /// In en, this message translates to:
  /// **'Voice Input'**
  String get toolbarVoiceInput;

  /// Title for the editor screen
  ///
  /// In en, this message translates to:
  /// **'Editor'**
  String get editorScreenTitle;

  /// Title when editing an existing note
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get editorScreenEditNote;

  /// Title when creating a new note
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get editorScreenNewNote;

  /// Placeholder text for the note title field
  ///
  /// In en, this message translates to:
  /// **'Title (optional)'**
  String get editorTitlePlaceholder;

  /// Dialog title when user tries to exit with unsaved changes
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get editorUnsavedChangesTitle;

  /// Dialog message when user tries to exit with unsaved changes
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to discard them?'**
  String get editorUnsavedChangesMessage;

  /// Button to discard unsaved changes
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get editorDiscardChanges;

  /// Button to continue editing and not discard changes
  ///
  /// In en, this message translates to:
  /// **'Keep Editing'**
  String get editorKeepEditing;

  /// Success message when note is saved
  ///
  /// In en, this message translates to:
  /// **'Note saved successfully'**
  String get editorSaveSuccess;

  /// Error message when note save fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save note'**
  String get editorSaveError;

  /// Error message when note fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load note'**
  String get editorLoadError;

  /// Error message when trying to save empty note
  ///
  /// In en, this message translates to:
  /// **'Cannot save empty note'**
  String get editorEmptyContentError;
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
