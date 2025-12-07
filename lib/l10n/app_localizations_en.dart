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

  @override
  String get voiceInputTitle => 'Voice Input';

  @override
  String get voiceInputPlaceholder => 'Tap the button and start speaking...';

  @override
  String get voiceInputListening => 'Listening...';

  @override
  String get voiceInputTranscribing => 'Transcribing...';

  @override
  String get voiceInputSaveNote => 'SAVE NOTE';

  @override
  String get voiceInputPermissionDenied =>
      'Microphone permission is required for voice recording';

  @override
  String get voiceInputPermissionSettings => 'Open Settings';

  @override
  String get voiceInputPermissionTitle => 'Microphone Permission Required';

  @override
  String get voiceInputPermissionMessage =>
      'This app needs access to your microphone to record voice notes';

  @override
  String get voiceInputNotAvailable =>
      'Voice recognition is not available on this device';

  @override
  String get voiceInputError =>
      'An error occurred during voice recording. Please try again';

  @override
  String get transcriptionPlaceholder => 'Transcription will appear here...';

  @override
  String get transcriptionConfidenceHigh => 'High confidence';

  @override
  String get transcriptionConfidenceMedium => 'Medium confidence';

  @override
  String get transcriptionConfidenceLow => 'Low confidence';

  @override
  String get voiceInputEmptyWarning => 'Please record some text before saving';

  @override
  String get voiceInputSaveSuccess => 'Note saved successfully!';

  @override
  String get voiceInputSaveError => 'Failed to save note. Please try again';

  @override
  String get voiceInputSaving => 'Saving note...';

  @override
  String get voiceButtonStartRecording => 'Start recording';

  @override
  String get voiceButtonStopRecording => 'Stop recording';

  @override
  String get transcriptionClearButton => 'Clear transcription';

  @override
  String get notesListTitle => 'Notes';

  @override
  String get notesListEmptyTitle => 'No Notes Yet';

  @override
  String get notesListEmptySubtitle =>
      'Start creating your first note using voice or text';

  @override
  String get notesListEmptyActionVoice => 'Record Voice Note';

  @override
  String get notesListEmptyActionText => 'Create Text Note';

  @override
  String get notesListErrorLoadingTitle => 'Failed to Load Notes';

  @override
  String get notesListErrorLoadingMessage =>
      'Unable to fetch your notes. Please check your connection and try again';

  @override
  String get notesListLoadingMessage => 'Loading your notes...';

  @override
  String get notesListSearchPlaceholder => 'Search notes...';

  @override
  String get notesListCreateVoiceNote => 'Create Voice Note';

  @override
  String get notesListCreateTextNote => 'Create Text Note';

  @override
  String get notesListRefreshTooltip => 'Pull down to refresh';

  @override
  String get notesListUntitled => 'Untitled Note';

  @override
  String get notesListJustNow => 'Just now';

  @override
  String notesListMinutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String notesListHoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String notesListDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get noteCardDeleteTitle => 'Delete Note?';

  @override
  String get noteCardDeleteMessage =>
      'This note will be permanently deleted. This action cannot be undone.';

  @override
  String get noteCardContextEdit => 'Edit';

  @override
  String get noteCardContextDelete => 'Delete';

  @override
  String get noteCardContextShare => 'Share';

  @override
  String get noteDetailTitle => 'Note Details';

  @override
  String get noteDetailBackButton => 'Back to notes';

  @override
  String get noteDetailEdit => 'Edit';

  @override
  String get noteDetailShare => 'Share';

  @override
  String get noteDetailDelete => 'Delete';

  @override
  String get noteDetailDeleteTitle => 'Delete Note?';

  @override
  String get noteDetailDeleteMessage =>
      'This note will be permanently deleted. This action cannot be undone.';

  @override
  String get noteDetailDeleteSuccess => 'Note deleted successfully';

  @override
  String get noteDetailDeleteError => 'Failed to delete note. Please try again';

  @override
  String get noteDetailMetadata => 'Note Information';

  @override
  String get noteDetailCreated => 'Created';

  @override
  String get noteDetailModified => 'Modified';

  @override
  String get noteDetailWords => 'Words';

  @override
  String get noteDetailLanguageConfidence => 'Confidence';

  @override
  String get noteDetailContent => 'Content';

  @override
  String get noteDetailEmptyContent => 'This note has no content';

  @override
  String get noteDetailCopyToClipboard => 'Copy to clipboard';

  @override
  String get noteDetailCopySuccess => 'Copied to clipboard';

  @override
  String get noteDetailTags => 'Tags';

  @override
  String get noteDetailTagsComingSoon => 'Tags will be available in Phase 8';

  @override
  String get noteDetailEditComingSoon =>
      'Note editing will be available in Phase 7';

  @override
  String get noteDetailShareError => 'Failed to share note. Please try again';

  @override
  String get noteDetailLoading => 'Loading note...';

  @override
  String get noteDetailErrorTitle => 'Failed to Load Note';

  @override
  String get noteDetailErrorMessage =>
      'Unable to fetch the note. Please check your connection and try again';

  @override
  String get textEditorTitle => 'New Note';

  @override
  String get textEditorTitlePlaceholder => 'Title (optional)';

  @override
  String get textEditorContentPlaceholder => 'Start typing your note...';

  @override
  String get textEditorSaveButton => 'SAVE';

  @override
  String get textEditorCancelButton => 'CANCEL';

  @override
  String get textEditorEmptyContentError => 'Note content cannot be empty';

  @override
  String get textEditorSaveSuccess => 'Text note created successfully';

  @override
  String get textEditorSaveError => 'Failed to save note. Please try again';

  @override
  String get textEditorSaving => 'Saving note...';

  @override
  String get textEditorUnsavedChangesTitle => 'Discard Changes?';

  @override
  String get textEditorUnsavedChangesMessage =>
      'You have unsaved changes. Are you sure you want to discard them?';

  @override
  String get textEditorDiscardButton => 'DISCARD';
}
