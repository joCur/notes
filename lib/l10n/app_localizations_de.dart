// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Sprachnotizen';

  @override
  String get hello => 'Hallo';

  @override
  String get welcomeMessage => 'Willkommen bei Voice-First Notizen';

  @override
  String get errorOccurred => 'Ein Fehler ist aufgetreten';

  @override
  String get retry => 'Wiederholen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get ok => 'OK';

  @override
  String get errorNetwork =>
      'Überprüfen Sie Ihre Internetverbindung und versuchen Sie es erneut';

  @override
  String get errorUnknown =>
      'Ein unerwarteter Fehler ist aufgetreten. Bitte versuchen Sie es erneut';

  @override
  String get errorAuthInvalidCredentials =>
      'Ungültige E-Mail-Adresse oder Passwort. Bitte versuchen Sie es erneut';

  @override
  String get errorAuthSessionExpired =>
      'Ihre Sitzung ist abgelaufen. Bitte melden Sie sich erneut an';

  @override
  String get errorAuthEmailNotConfirmed =>
      'Bitte bestätigen Sie Ihre E-Mail-Adresse, um fortzufahren';

  @override
  String get errorAuthWeakPassword =>
      'Das Passwort muss mindestens 6 Zeichen lang sein';

  @override
  String get errorAuthUserNotFound =>
      'Kein Konto mit dieser E-Mail-Adresse gefunden';

  @override
  String get errorAuthEmailExists =>
      'Diese E-Mail-Adresse ist bereits registriert';

  @override
  String get errorAuthInvalidToken => 'Ungültiges Authentifizierungstoken';

  @override
  String get errorAuthTokenExpired => 'Authentifizierungstoken ist abgelaufen';

  @override
  String get errorAuthUnknown =>
      'Authentifizierungsfehler. Bitte versuchen Sie es erneut';

  @override
  String get errorPgUniqueViolation => 'Dieser Datensatz existiert bereits';

  @override
  String get errorPgNotNullViolation => 'Pflichtfeld fehlt';

  @override
  String get errorPgForeignKeyViolation =>
      'Referenzierter Datensatz nicht gefunden';

  @override
  String get errorPgInsufficientPrivilege =>
      'Sie haben keine Berechtigung für diese Aktion';

  @override
  String get errorPgStringTooLong => 'Eingabetext ist zu lang';

  @override
  String get errorDatabaseGeneric =>
      'Datenbankfehler. Bitte versuchen Sie es erneut';

  @override
  String get errorDatabaseNotFound => 'Datensatz nicht gefunden';

  @override
  String get errorDatabaseUnavailable =>
      'Datenbank ist vorübergehend nicht verfügbar';

  @override
  String get errorStorageFileNotFound => 'Datei nicht gefunden';

  @override
  String get errorStorageFileTooLarge => 'Datei ist zu groß';

  @override
  String get errorStorageAccessDenied =>
      'Sie haben keine Berechtigung, auf diese Datei zuzugreifen';

  @override
  String get errorStorageBucketNotFound => 'Speicher-Bucket nicht gefunden';

  @override
  String get errorStorageGeneric =>
      'Speicherfehler. Bitte versuchen Sie es erneut';

  @override
  String get loginTitle => 'Anmelden';

  @override
  String get loginEmailLabel => 'E-Mail';

  @override
  String get loginPasswordLabel => 'Passwort';

  @override
  String get loginButton => 'ANMELDEN';

  @override
  String get loginForgotPassword => 'Passwort vergessen?';

  @override
  String get loginNoAccount => 'Noch kein Konto?';

  @override
  String get loginSignUpLink => 'Registrieren';

  @override
  String get loginEmailError =>
      'Bitte geben Sie eine gültige E-Mail-Adresse ein';

  @override
  String get loginPasswordError =>
      'Das Passwort muss mindestens 6 Zeichen lang sein';

  @override
  String get signupTitle => 'Konto erstellen';

  @override
  String get signupEmailLabel => 'E-Mail';

  @override
  String get signupPasswordLabel => 'Passwort';

  @override
  String get signupConfirmPasswordLabel => 'Passwort bestätigen';

  @override
  String get signupButton => 'KONTO ERSTELLEN';

  @override
  String get signupHaveAccount => 'Bereits ein Konto?';

  @override
  String get signupLoginLink => 'Anmelden';

  @override
  String get signupPasswordMismatch => 'Passwörter stimmen nicht überein';

  @override
  String get signupPasswordWeak =>
      'Das Passwort ist zu schwach. Verwenden Sie mindestens 8 Zeichen';

  @override
  String get signupPasswordStrengthWeak => 'Schwach';

  @override
  String get signupPasswordStrengthMedium => 'Mittel';

  @override
  String get signupPasswordStrengthStrong => 'Stark';

  @override
  String get signupSuccess =>
      'Konto erstellt! Bitte überprüfen Sie Ihre E-Mails, um Ihr Konto zu verifizieren';

  @override
  String get forgotPasswordTitle => 'Passwort zurücksetzen';

  @override
  String get forgotPasswordEmailLabel => 'E-Mail';

  @override
  String get forgotPasswordButton => 'RESET-LINK SENDEN';

  @override
  String get forgotPasswordInstructions =>
      'Geben Sie Ihre E-Mail-Adresse ein und wir senden Ihnen einen Link zum Zurücksetzen Ihres Passworts';

  @override
  String get forgotPasswordSuccess =>
      'E-Mail zum Zurücksetzen des Passworts gesendet! Überprüfen Sie Ihren Posteingang';

  @override
  String get forgotPasswordBackToLogin => 'Zurück zur Anmeldung';

  @override
  String get resetPasswordTitle => 'Neues Passwort erstellen';

  @override
  String get resetPasswordNewLabel => 'Neues Passwort';

  @override
  String get resetPasswordConfirmLabel => 'Neues Passwort bestätigen';

  @override
  String get resetPasswordButton => 'PASSWORT ZURÜCKSETZEN';

  @override
  String get resetPasswordSuccess =>
      'Passwort erfolgreich zurückgesetzt! Sie können sich jetzt anmelden';

  @override
  String get signOut => 'ABMELDEN';

  @override
  String get welcome => 'Willkommen';

  @override
  String get noteListComingSoon => 'Notizenliste kommt bald';

  @override
  String get homePagePlaceholder =>
      'Dies ist eine Platzhalter-Startseite.\nDie Notizenliste wird in Phase 4 implementiert.';

  @override
  String get loading => 'Lädt...';

  @override
  String get voiceInputTitle => 'Spracheingabe';

  @override
  String get voiceInputPlaceholder =>
      'Tippen Sie auf die Schaltfläche und sprechen Sie los...';

  @override
  String get voiceInputListening => 'Ich höre zu...';

  @override
  String get voiceInputTranscribing => 'Transkribiere...';

  @override
  String get voiceInputSaveNote => 'NOTIZ SPEICHERN';

  @override
  String get voiceInputPermissionDenied =>
      'Mikrofonberechtigung ist für die Sprachaufnahme erforderlich';

  @override
  String get voiceInputPermissionSettings => 'Einstellungen öffnen';

  @override
  String get voiceInputPermissionTitle => 'Mikrofonberechtigung erforderlich';

  @override
  String get voiceInputPermissionMessage =>
      'Diese App benötigt Zugriff auf Ihr Mikrofon, um Sprachnotizen aufzunehmen';

  @override
  String get voiceInputNotAvailable =>
      'Spracherkennung ist auf diesem Gerät nicht verfügbar';

  @override
  String get voiceInputError =>
      'Bei der Sprachaufnahme ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut';

  @override
  String get transcriptionPlaceholder =>
      'Die Transkription wird hier erscheinen...';

  @override
  String get transcriptionConfidenceHigh => 'Hohe Sicherheit';

  @override
  String get transcriptionConfidenceMedium => 'Mittlere Sicherheit';

  @override
  String get transcriptionConfidenceLow => 'Niedrige Sicherheit';

  @override
  String get voiceInputEmptyWarning =>
      'Bitte nehmen Sie etwas Text auf, bevor Sie speichern';

  @override
  String get voiceInputSaveSuccess => 'Notiz erfolgreich gespeichert!';

  @override
  String get voiceInputSaveError =>
      'Speichern der Notiz fehlgeschlagen. Bitte versuchen Sie es erneut';

  @override
  String get voiceInputSaving => 'Speichere Notiz...';

  @override
  String get voiceButtonStartRecording => 'Aufnahme starten';

  @override
  String get voiceButtonStopRecording => 'Aufnahme stoppen';

  @override
  String get transcriptionClearButton => 'Transkription löschen';

  @override
  String get notesListTitle => 'Notizen';

  @override
  String get notesListEmptyTitle => 'Noch keine Notizen';

  @override
  String get notesListEmptySubtitle =>
      'Erstellen Sie Ihre erste Notiz mit Sprache oder Text';

  @override
  String get notesListEmptyActionVoice => 'Sprachnotiz Aufnehmen';

  @override
  String get notesListEmptyActionText => 'Textnotiz Erstellen';

  @override
  String get notesListErrorLoadingTitle => 'Laden der Notizen fehlgeschlagen';

  @override
  String get notesListErrorLoadingMessage =>
      'Ihre Notizen können nicht abgerufen werden. Bitte überprüfen Sie Ihre Verbindung und versuchen Sie es erneut';

  @override
  String get notesListLoadingMessage => 'Lade Ihre Notizen...';

  @override
  String get notesListSearchPlaceholder => 'Notizen durchsuchen...';

  @override
  String get notesListCreateVoiceNote => 'Sprachnotiz Erstellen';

  @override
  String get notesListCreateTextNote => 'Textnotiz Erstellen';

  @override
  String get notesListRefreshTooltip => 'Zum Aktualisieren nach unten ziehen';

  @override
  String get notesListUntitled => 'Unbenannte Notiz';

  @override
  String get notesListJustNow => 'Gerade eben';

  @override
  String notesListMinutesAgo(int count) {
    return 'Vor $count Min';
  }

  @override
  String notesListHoursAgo(int count) {
    return 'Vor ${count}h';
  }

  @override
  String notesListDaysAgo(int count) {
    return 'Vor ${count}T';
  }

  @override
  String get noteCardDeleteTitle => 'Notiz löschen?';

  @override
  String get noteCardDeleteMessage =>
      'Diese Notiz wird dauerhaft gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get noteCardContextEdit => 'Bearbeiten';

  @override
  String get noteCardContextDelete => 'Löschen';

  @override
  String get noteCardContextShare => 'Teilen';

  @override
  String get noteDetailTitle => 'Notizdetails';

  @override
  String get noteDetailBackButton => 'Zurück zu Notizen';

  @override
  String get noteDetailEdit => 'Bearbeiten';

  @override
  String get noteDetailShare => 'Teilen';

  @override
  String get noteDetailDelete => 'Löschen';

  @override
  String get noteDetailDeleteTitle => 'Notiz löschen?';

  @override
  String get noteDetailDeleteMessage =>
      'Diese Notiz wird dauerhaft gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get noteDetailDeleteSuccess => 'Notiz erfolgreich gelöscht';

  @override
  String get noteDetailDeleteError =>
      'Löschen der Notiz fehlgeschlagen. Bitte versuchen Sie es erneut';

  @override
  String get noteDetailMetadata => 'Notizinformationen';

  @override
  String get noteDetailCreated => 'Erstellt';

  @override
  String get noteDetailModified => 'Geändert';

  @override
  String get noteDetailWords => 'Wörter';

  @override
  String get noteDetailLanguageConfidence => 'Sicherheit';

  @override
  String get noteDetailContent => 'Inhalt';

  @override
  String get noteDetailEmptyContent => 'Diese Notiz hat keinen Inhalt';

  @override
  String get noteDetailCopyToClipboard => 'In Zwischenablage kopieren';

  @override
  String get noteDetailCopySuccess => 'In Zwischenablage kopiert';

  @override
  String get noteDetailTags => 'Tags';

  @override
  String get noteDetailTagsComingSoon =>
      'Tags werden in Phase 8 verfügbar sein';

  @override
  String get noteDetailEditComingSoon =>
      'Notizbearbeitung wird in Phase 7 verfügbar sein';

  @override
  String get noteDetailShareError =>
      'Teilen der Notiz fehlgeschlagen. Bitte versuchen Sie es erneut';

  @override
  String get noteDetailLoading => 'Lade Notiz...';

  @override
  String get noteDetailErrorTitle => 'Laden der Notiz fehlgeschlagen';

  @override
  String get noteDetailErrorMessage =>
      'Die Notiz kann nicht abgerufen werden. Bitte überprüfen Sie Ihre Verbindung und versuchen Sie es erneut';

  @override
  String get textEditorTitle => 'Neue Notiz';

  @override
  String get textEditorTitlePlaceholder => 'Titel (optional)';

  @override
  String get textEditorContentPlaceholder =>
      'Beginnen Sie mit dem Tippen Ihrer Notiz...';

  @override
  String get textEditorSaveButton => 'SPEICHERN';

  @override
  String get textEditorCancelButton => 'ABBRECHEN';

  @override
  String get textEditorEmptyContentError =>
      'Der Notizinhalt darf nicht leer sein';

  @override
  String get textEditorSaveSuccess => 'Textnotiz erfolgreich erstellt';

  @override
  String get textEditorSaveError =>
      'Speichern der Notiz fehlgeschlagen. Bitte versuchen Sie es erneut';

  @override
  String get textEditorSaving => 'Speichere Notiz...';

  @override
  String get textEditorUnsavedChangesTitle => 'Änderungen verwerfen?';

  @override
  String get textEditorUnsavedChangesMessage =>
      'Sie haben nicht gespeicherte Änderungen. Möchten Sie diese wirklich verwerfen?';

  @override
  String get textEditorDiscardButton => 'VERWERFEN';
}
