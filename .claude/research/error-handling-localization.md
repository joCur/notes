# Research: Error Handling and Localization for Flutter/Supabase

## Executive Summary

This research provides a comprehensive, type-safe approach to error handling and localization in Flutter applications using Supabase, integrating seamlessly with Clean Architecture, Riverpod, and modern Dart patterns.

**Key Recommendations:**
- **Localization**: Flutter's `intl` + `gen_l10n` with ARB files for type-safe translations
- **Error Handling**: Sealed classes with Freezed + Result<T> pattern for compile-time safety
- **Supabase Integration**: Enum-based error code mapping for all Supabase services
- **Error Display**: Tiered UI strategy (inline, SnackBar, dialog, error page)
- **Logging**: Talker for comprehensive error tracking with technical details

**Benefits**: Compile-time safety, no string matching, excellent IDE support, maintainable code, seamless architecture integration.

## Research Scope

**Researched:**
- Localization packages (intl, easy_localization)
- Error handling patterns (sealed classes, Either, exceptions)
- Supabase exception types and error code taxonomies
- Error display strategies and UI patterns
- Integration with Riverpod, Freezed, and Talker

**Excluded:**
- Platform-specific localization
- RTL language considerations
- Custom error reporting backends
- Automated translation services
- Retry logic and exponential backoff

## Architecture Overview

### Error Flow
```
Supabase Exception
    ↓
Extension Method (toAppFailure)
    ↓
Enum-Based Error Code Parser
    ↓
AppFailure Sealed Class + Localized Message
    ↓
Result<T> Returned to Provider
    ↓
AsyncValue.error in Riverpod
    ↓
ErrorDisplayService Shows UI
```

### Component Stack
```
┌─────────────────────────────────┐
│  Presentation Layer             │
│  - ErrorDisplayService          │
│  - Localized error messages     │
└──────────────┬──────────────────┘
               ↓
┌──────────────▼──────────────────┐
│  Application Layer              │
│  - Riverpod AsyncValue          │
│  - Error listeners              │
└──────────────┬──────────────────┘
               ↓
┌──────────────▼──────────────────┐
│  Domain Layer                   │
│  - AppFailure sealed classes    │
│  - Result<T> type               │
└──────────────┬──────────────────┘
               ↓
┌──────────────▼──────────────────┐
│  Data Layer                     │
│  - Exception → Enum → Failure   │
│  - Extension methods            │
└─────────────────────────────────┘
```

## Core Components

### 1. Localization Setup

**Configuration:**
```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

flutter:
  generate: true

# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
synthetic-package: false
```

**ARB File Structure:**
```json
{
  "@@locale": "en",
  "errorNetwork": "Check your internet connection and try again",
  "errorAuthInvalidCredentials": "Invalid email or password. Please try again.",
  "errorPgUniqueViolation": "This record already exists.",
  "errorStorageFileTooLarge": "File is too large.",
  "@errorNetwork": {
    "description": "Network connection error"
  }
}
```

**Provider:**
```dart
@riverpod
AppLocalizations appLocalizations(AppLocalizationsRef ref) {
  final locale = ref.watch(localeNotifierProvider);
  return lookupAppLocalizations(locale);
}
```

### 2. Error Types

**AppFailure Sealed Class:**
```dart
@freezed
sealed class AppFailure with _$AppFailure {
  const factory AppFailure.network({
    required String message,
    String? details,
  }) = NetworkFailure;

  const factory AppFailure.authentication({
    required String message,
    String? code,
  }) = AuthenticationFailure;

  const factory AppFailure.validation({
    required String message,
    required String field,
  }) = ValidationFailure;

  const factory AppFailure.permission({
    required String message,
    required String resource,
  }) = PermissionFailure;

  const factory AppFailure.server({
    required String message,
    int? statusCode,
  }) = ServerFailure;

  const factory AppFailure.unknown({
    required String message,
    Object? exception,
  }) = UnknownFailure;
}
```

**Result Type:**
```dart
@freezed
sealed class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(AppFailure failure) = Failure<T>;
}
```

### 3. Supabase Error Code Enums

**Error Code Categories:**
- **Auth**: 30+ codes (`invalid_credentials`, `session_expired`, `weak_password`)
- **PostgREST**: 40+ codes (`PGRST301` - JWT expired, `PGRST116` - not found)
- **PostgreSQL**: ~30 app-relevant codes (`23505` - unique violation, `42501` - insufficient privilege)
- **Storage**: 20+ codes (`NoSuchKey`, `EntityTooLarge`, `AccessDenied`)
- **Realtime**: 20+ codes (`Unauthorized`, `DatabaseConnectionIssue`)

**Example Enum Implementation:**
```dart
enum AuthErrorCode {
  invalidCredentials,
  sessionExpired,
  emailNotConfirmed,
  weakPassword,
  unknown;

  factory AuthErrorCode.parse(String? code) {
    if (code == null) return AuthErrorCode.unknown;
    return switch (code) {
      'invalid_credentials' => AuthErrorCode.invalidCredentials,
      'session_expired' => AuthErrorCode.sessionExpired,
      'email_not_confirmed' => AuthErrorCode.emailNotConfirmed,
      'weak_password' => AuthErrorCode.weakPassword,
      _ => AuthErrorCode.unknown,
    };
  }

  String getMessage(AppLocalizations l10n) {
    return switch (this) {
      AuthErrorCode.invalidCredentials => l10n.errorAuthInvalidCredentials,
      AuthErrorCode.sessionExpired => l10n.errorAuthSessionExpired,
      AuthErrorCode.emailNotConfirmed => l10n.errorAuthEmailNotConfirmed,
      AuthErrorCode.weakPassword => l10n.errorAuthWeakPassword,
      AuthErrorCode.unknown => l10n.errorAuthUnknown,
    };
  }

  AppFailure toFailure(AppLocalizations l10n) {
    return switch (this) {
      AuthErrorCode.invalidCredentials ||
      AuthErrorCode.sessionExpired =>
        AppFailure.authentication(message: getMessage(l10n)),

      AuthErrorCode.emailNotConfirmed ||
      AuthErrorCode.weakPassword =>
        AppFailure.validation(message: getMessage(l10n), field: 'auth'),

      _ => AppFailure.authentication(message: getMessage(l10n)),
    };
  }
}
```

### 4. Extension Methods

**Clean Exception Handling:**
```dart
extension AuthExceptionX on AuthException {
  AppFailure toAppFailure(AppLocalizations l10n, Talker talker) {
    talker.error('AuthException', {
      'message': message,
      'statusCode': statusCode,
      'code': code,
    });

    final errorCode = AuthErrorCode.parse(code);

    if (errorCode == AuthErrorCode.unknown && code != null) {
      talker.warning('Unknown auth error code: $code');
    }

    return errorCode.toFailure(l10n);
  }
}

extension PostgrestExceptionX on PostgrestException {
  AppFailure toAppFailure(AppLocalizations l10n, Talker talker) {
    talker.error('PostgrestException', {
      'message': message,
      'code': code,
      'details': details,
      'hint': hint,
    });

    // Try PostgREST codes (PGRST*)
    if (code != null && code!.startsWith('PGRST')) {
      return PostgrestErrorCode.parse(code).toFailure(l10n);
    }

    // Try PostgreSQL codes (numeric)
    if (code != null && RegExp(r'^\d{5}$').hasMatch(code!)) {
      return PostgresErrorCode.parse(code).toFailure(l10n);
    }

    return AppFailure.server(message: l10n.errorDatabaseGeneric);
  }
}

extension StorageExceptionX on StorageException {
  AppFailure toAppFailure(AppLocalizations l10n, Talker talker) {
    talker.error('StorageException', {
      'message': message,
      'statusCode': statusCode,
      'error': error,
    });

    return StorageErrorCode.parse(error).toFailure(l10n);
  }
}
```

### 5. Repository Integration

**Clean, Minimal Error Handling:**
```dart
class SupabaseNoteRepository implements NoteRepository {
  final SupabaseClient _client;
  final AppLocalizations _l10n;
  final Talker _talker;

  @override
  Future<Result<Note>> createNote(String content) async {
    try {
      final data = await _client.from('notes').insert({
        'user_id': _client.auth.currentUser!.id,
        'content': content,
      }).select().single();

      return Result.success(Note.fromJson(data));

    } on PostgrestException catch (e) {
      return Result.failure(e.toAppFailure(_l10n, _talker));

    } on AuthException catch (e) {
      return Result.failure(e.toAppFailure(_l10n, _talker));

    } on StorageException catch (e) {
      return Result.failure(e.toAppFailure(_l10n, _talker));

    } on SocketException catch (e, stack) {
      _talker.error('Network error', e, stack);
      return Result.failure(AppFailure.network(message: _l10n.errorNetwork));

    } catch (e, stack) {
      _talker.error('Unexpected error', e, stack);
      return Result.failure(AppFailure.unknown(message: _l10n.errorUnknown, exception: e));
    }
  }
}
```

### 6. Error Display Service

**Tiered UI Strategy:**
```dart
@riverpod
class ErrorDisplayService extends _$ErrorDisplayService {
  @override
  void build() {}

  void showError(BuildContext context, AppFailure failure, {VoidCallback? onRetry}) {
    failure.when(
      validation: (message, field) {
        // Inline - handled by form fields
      },
      network: (message, details) {
        // SnackBar with retry
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
            action: onRetry != null ? SnackBarAction(label: 'Retry', onPressed: onRetry) : null,
          ),
        );
      },
      authentication: (message, code) {
        // Dialog with navigation
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.error_outline, size: 48, color: Colors.red),
            title: const Text('Authentication Required'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/login');
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        );
      },
      permission: (message, resource) {
        // Dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.lock_outline, size: 48, color: Colors.orange),
            title: const Text('Permission Denied'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
      server: (message, statusCode) {
        // SnackBar with retry
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 7),
            action: onRetry != null ? SnackBarAction(label: 'Retry', onPressed: onRetry) : null,
          ),
        );
      },
      unknown: (message, exception) {
        // SnackBar + log
        _talker.error('Unknown error displayed', exception);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      },
    );
  }
}
```

**UI Component Mapping:**
| Error Type | UI Component | Duration | User Action |
|------------|-------------|----------|-------------|
| Validation | Inline text (red) | Persistent | Fix input |
| Network | SnackBar (orange) | 5 seconds | Retry |
| Authentication | Dialog (red) | User-controlled | Sign in |
| Permission | Dialog (orange) | User-controlled | Acknowledge |
| Server | SnackBar (red) | 7 seconds | Retry |
| Unknown | SnackBar (red) | 4 seconds | Auto-dismiss |

### 7. Riverpod Integration

**Provider Usage:**
```dart
@riverpod
class NotesNotifier extends _$NotesNotifier {
  @override
  Future<List<Note>> build() async {
    final result = await ref.read(noteRepositoryProvider).getNotes();
    return result.when(
      success: (notes) => notes,
      failure: (failure) => throw failure,
    );
  }

  Future<void> createNote(String content) async {
    state = const AsyncValue.loading();

    final result = await ref.read(noteRepositoryProvider).createNote(content);

    state = result.when(
      success: (note) {
        final current = state.value ?? [];
        return AsyncValue.data([note, ...current]);
      },
      failure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }
}
```

**UI Error Listener:**
```dart
class NotesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Auto-display errors
    ref.listen(notesNotifierProvider, (prev, next) {
      next.whenOrNull(
        error: (error, stack) {
          if (error is AppFailure) {
            ref.read(errorDisplayServiceProvider).showError(
              context,
              error,
              onRetry: () => ref.invalidate(notesNotifierProvider),
            );
          }
        },
      );
    });

    final state = ref.watch(notesNotifierProvider);

    return state.when(
      data: (notes) => NotesList(notes),
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(), // Handled by listener
    );
  }
}
```

## Implementation Strategy

### Phase 1: Foundation (4-6 hours)
1. Configure intl + gen_l10n
2. Create AppFailure sealed class
3. Create Result<T> type
4. Add ARB files with basic error messages
5. Set up locale provider

### Phase 2: Supabase Error Codes (4-6 hours)
1. Create error code enums for Auth, PostgREST, PostgreSQL, Storage
2. Implement parse() methods
3. Implement getMessage() and toFailure() methods
4. Add comprehensive ARB translations
5. Write unit tests

### Phase 3: Extension Methods (2-3 hours)
1. Create extension methods for each Supabase exception type
2. Integrate Talker logging
3. Write integration tests

### Phase 4: Repository Integration (3-4 hours)
1. Update repositories to use extension methods
2. Return Result<T> from all methods
3. Test error scenarios

### Phase 5: UI Error Display (3-4 hours)
1. Create ErrorDisplayService
2. Add Riverpod error listeners
3. Test all error display types

**Total: 16-23 hours (2-3 days)**

## Key Benefits

**Compile-Time Safety:**
- ✓ Exhaustive enum matching
- ✓ Type-safe localization keys
- ✓ No string-based error matching
- ✓ Build fails if translations missing

**Developer Experience:**
- ✓ Clean, minimal code in repositories
- ✓ Excellent IDE autocomplete
- ✓ Easy to add new error types
- ✓ Clear error handling patterns

**Maintainability:**
- ✓ Centralized error code definitions
- ✓ Consistent error handling
- ✓ Comprehensive logging
- ✓ User-friendly messages

**Integration:**
- ✓ Seamless with Clean Architecture
- ✓ Works with Riverpod AsyncValue
- ✓ Integrates with Talker logging
- ✓ No additional dependencies

## Common Error Code Reference

**Auth (Most Common):**
- `invalid_credentials` - Wrong email/password
- `session_expired` - JWT expired
- `email_not_confirmed` - Email verification required
- `weak_password` - Password too weak

**PostgREST (Most Common):**
- `PGRST301` - JWT expired
- `PGRST116` - No rows found
- `PGRST202` - Function not found
- `PGRST001` - Database unavailable

**PostgreSQL (Most Common):**
- `23505` - Unique violation
- `23502` - Not null violation
- `42501` - Insufficient privilege
- `22001` - String too long

**Storage (Most Common):**
- `NoSuchKey` - File not found
- `EntityTooLarge` - File too large
- `AccessDenied` - Permission denied
- `InvalidJWT` - Auth failed

## Project Structure

```
lib/
├── l10n/
│   ├── app_en.arb
│   ├── app_de.arb
│   └── generated/
├── core/
│   ├── errors/
│   │   ├── app_failure.dart              # Sealed class
│   │   ├── result.dart                   # Result<T> type
│   │   ├── supabase_error_codes.dart     # All enums
│   │   ├── supabase_error_extensions.dart # Extension methods
│   │   └── error_display_service.dart    # UI display logic
│   └── providers/
│       ├── locale_provider.dart
│       ├── l10n_provider.dart
│       └── talker_provider.dart
└── features/
    └── {feature}/
        └── data/
            └── repositories/
                └── *_repository.dart     # Uses extension methods
```

## Error Message Guidelines

**DO:**
- Be specific: "Check your internet connection" not "Network error"
- Be actionable: Suggest next steps
- Use friendly tone
- Keep concise (1-2 sentences)

**DON'T:**
- Show technical errors to users
- Blame users
- Use all caps
- Leave without guidance

**Examples:**
| ❌ Bad | ✅ Good |
|--------|---------|
| "Error 404" | "We couldn't find that item" |
| "PostgrestException: JWT expired" | "Your session has expired. Please sign in again" |
| "Invalid input" | "Please enter a valid email address" |

## Dependencies

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
  flutter_riverpod: ^2.5.0
  freezed_annotation: ^2.4.0
  talker_flutter: ^4.0.0
  supabase_flutter: ^2.5.0

dev_dependencies:
  build_runner: ^2.4.0
  freezed: ^2.5.0
  riverpod_generator: ^2.4.0
```

## References

**Official Documentation:**
- [Supabase Auth Error Codes](https://supabase.com/docs/guides/auth/debugging/error-codes)
- [PostgREST Error Codes](https://postgrest.org/en/latest/errors.html)
- [PostgreSQL Error Codes](https://www.postgresql.org/docs/current/errcodes-appendix.html)
- [Supabase Storage Error Codes](https://supabase.com/docs/guides/storage/debugging/error-codes)
- [Flutter Internationalization](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)

**Best Practices:**
- [Error Handling in Flutter Clean Architecture](https://medium.com/@sbezhuk/error-handling-in-flutter-clean-architecture-with-either-686e3863bc60)
- [Simple error handling with Sealed Classes](https://rafaelperezsolis.medium.com/simple-error-handling-in-flutter-with-sealed-classes-1cc3f5c0a34e)
- [How to Read Localized Strings Outside Widgets](https://codewithandrea.com/articles/app-localizations-outside-widgets-riverpod/)

---

**Research Completed**: December 2, 2025
**Next Step**: Implement Phase 1 (Foundation) to establish core error handling infrastructure.
