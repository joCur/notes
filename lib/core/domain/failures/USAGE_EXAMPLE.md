# Error Handling Usage Guide

This guide shows how to use the enum-based, type-safe error handling system.

## Overview

The error handling system has three layers:

1. **Domain Layer**: Error enums (`supabase_error_codes.dart`) and AppFailure types
2. **Extension Layer**: Automatic error conversion (`failure_extensions.dart`)
3. **Presentation Layer**: Localized error display (`localization_provider.dart`)

## 1. In Repositories (Data Layer)

Use extension methods to convert Supabase exceptions to AppFailure:

```dart
class SupabaseNoteRepository implements NoteRepository {
  final SupabaseClient _client;
  final Talker _logger;

  @override
  Future<Result<Note>> createNote(String content) async {
    try {
      final data = await _client.from('notes').insert({
        'user_id': _client.auth.currentUser!.id,
        'content': content,
      }).select().single();

      return Result.success(Note.fromJson(data));

    } on AuthException catch (e) {
      // ✅ Enum-based error parsing (no string matching!)
      return Result.failure(e.toAppFailure(_logger));

    } on PostgrestException catch (e) {
      // ✅ Enum-based error parsing (no string matching!)
      return Result.failure(e.toAppFailure(_logger));

    } on StorageException catch (e) {
      // ✅ Enum-based error parsing (no string matching!)
      return Result.failure(e.toAppFailure(_logger));

    } on SocketException catch (e) {
      return Result.failure(e.toAppFailure(_logger));

    } catch (e, stack) {
      _logger.error('Unexpected error', e, stack);
      return Result.failure(
        AppFailure.unknown(message: 'errorUnknown', exception: e),
      );
    }
  }
}
```

## 2. In Providers (Application Layer)

Handle Result types in Riverpod providers:

```dart
@riverpod
class NotesNotifier extends _$NotesNotifier {
  @override
  Future<List<Note>> build() async {
    final result = await ref.read(noteRepositoryProvider).getNotes();

    return result.when(
      success: (notes) => notes,
      failure: (failure) => throw failure,  // Will be caught by AsyncValue
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

## 3. In UI (Presentation Layer)

Display errors with automatic localization:

```dart
class NotesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Auto-display errors with localization
    ref.listen(notesNotifierProvider, (prev, next) {
      next.whenOrNull(
        error: (error, stack) {
          if (error is AppFailure) {
            // Show localized error message
            ref.showError(
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

## 4. Manual Error Display

For custom error display logic:

```dart
class CustomErrorWidget extends ConsumerWidget {
  final AppFailure failure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get localized message
    final l10n = ref.watch(localizationProvider(context));
    final message = failure.getLocalizedMessage(l10n);

    return Column(
      children: [
        Icon(Icons.error),
        Text(message),
        ElevatedButton(
          onPressed: () => retry(),
          child: Text(l10n.retry),
        ),
      ],
    );
  }
}
```

## 5. Adding New Error Codes

To add a new error code:

### Step 1: Add to enum in `supabase_error_codes.dart`

```dart
enum AuthErrorCode {
  invalidCredentials,
  sessionExpired,
  twoFactorRequired,  // ← New error code
  unknown;

  factory AuthErrorCode.parse(String? code) {
    return switch (code) {
      'invalid_credentials' => AuthErrorCode.invalidCredentials,
      'session_expired' => AuthErrorCode.sessionExpired,
      'two_factor_required' => AuthErrorCode.twoFactorRequired,  // ← Add here
      _ => AuthErrorCode.unknown,
    };
  }

  String get messageKey {
    return switch (this) {
      AuthErrorCode.invalidCredentials => 'errorAuthInvalidCredentials',
      AuthErrorCode.sessionExpired => 'errorAuthSessionExpired',
      AuthErrorCode.twoFactorRequired => 'errorAuthTwoFactorRequired',  // ← Add here
      AuthErrorCode.unknown => 'errorAuthUnknown',
    };
  }
}
```

### Step 2: Add to ARB files

**`lib/l10n/app_en.arb`:**
```json
{
  "errorAuthTwoFactorRequired": "Please enter your two-factor authentication code",
  "@errorAuthTwoFactorRequired": {
    "description": "Two-factor authentication required"
  }
}
```

**`lib/l10n/app_de.arb`:**
```json
{
  "errorAuthTwoFactorRequired": "Bitte geben Sie Ihren Zwei-Faktor-Authentifizierungscode ein",
  "@errorAuthTwoFactorRequired": {
    "description": "Zwei-Faktor-Authentifizierung erforderlich"
  }
}
```

### Step 3: Add to localization provider switch

**`lib/core/presentation/providers/localization_provider.dart`:**
```dart
String _getMessageForKey(AppLocalizations l10n, String key) {
  return switch (key) {
    // ... existing cases
    'errorAuthTwoFactorRequired' => l10n.errorAuthTwoFactorRequired,  // ← Add here
    _ => l10n.errorUnknown,
  };
}
```

### Step 4: Run code generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Done! The new error is now fully integrated with:
- ✅ Compile-time safety
- ✅ Type-safe enum
- ✅ Automatic localization
- ✅ Logging support

## Benefits Summary

### ✅ Compile-Time Safety
- Exhaustive enum matching
- Build fails if cases are missing
- No runtime string errors

### ✅ Type Safety
- Error codes are enums, not strings
- IDE autocomplete works perfectly
- Refactoring is safe

### ✅ Maintainability
- Centralized error code definitions
- Easy to add new error codes
- Clear mapping to user messages

### ✅ Localization
- Automatic message translation
- User-friendly error messages
- Consistent across the app

### ✅ Logging
- Unknown codes are logged automatically
- Full technical details captured
- Easy debugging

## Anti-Patterns to Avoid

### ❌ DON'T use string matching
```dart
// BAD - String matching!
if (error.message.contains('password')) {
  return 'Password error';
}
```

### ❌ DON'T hardcode messages
```dart
// BAD - Not localized!
return AppFailure.auth(
  message: 'Invalid email or password',  // ← Hardcoded English!
);
```

### ❌ DON'T skip error logging
```dart
// BAD - No logging!
} catch (e) {
  return Result.failure(AppFailure.unknown(message: 'errorUnknown'));
}
```

### ✅ DO use enum-based parsing
```dart
// GOOD - Enum-based!
final errorCode = AuthErrorCode.parse(statusCode);
return AppFailure.auth(message: errorCode.messageKey);
```

### ✅ DO use message keys
```dart
// GOOD - Localization key!
return AppFailure.auth(message: 'errorAuthInvalidCredentials');
```

### ✅ DO log errors
```dart
// GOOD - Full logging!
} catch (e, stack) {
  logger.error('Operation failed', e, stack);
  return Result.failure(e.toAppFailure(logger));
}
```
