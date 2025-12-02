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
}
