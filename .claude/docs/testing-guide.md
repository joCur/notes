# Testing Guide for Notes App

## Quick Decision Tree: Should I Test This?

```
Is it code I wrote?
├─ NO → Don't test it (framework, packages, generated code)
└─ YES → Does it contain logic or transformations?
    ├─ NO → Don't test it (simple getters, data classes, constants)
    └─ YES → Test it! (business logic, validation, transformations)
```

## Testing Types Overview

### Unit Tests (Use Most Often)
**Purpose**: Test individual functions, methods, or classes in isolation
**Speed**: Very fast (milliseconds)
**Dependencies**: All external dependencies mocked
**Location**: `test/` directory, mirroring `lib/` structure

**When to use:**
- Business logic and calculations
- Data transformations
- Validation logic
- Error handling
- Repository implementations (with mocks)
- State management logic

**Example files to create:**
- `test/core/domain/result_test.dart`
- `test/features/auth/data/repositories/supabase_auth_repository_test.dart`
- `test/features/notes/domain/note_validator_test.dart`

### Widget Tests (Use Selectively)
**Purpose**: Test UI components and their interactions
**Speed**: Fast (seconds)
**Dependencies**: Widget tree rendered, but no real backend
**Location**: `test/` directory with `_test.dart` suffix

**When to use:**
- Custom interactive widgets (buttons, inputs)
- Form validation UI behavior
- State-dependent rendering
- Widget composition and layout logic
- Error state displays

**When NOT to use:**
- Testing framework widgets (Text, Container, etc.)
- Testing exact styling values
- Testing third-party widgets unchanged

**Example files to create:**
- `test/core/presentation/widgets/bauhaus_text_field_test.dart`
- `test/core/presentation/widgets/bauhaus_error_widget_test.dart`
- `test/features/notes/presentation/widgets/note_card_test.dart`

### Integration Tests (Use Sparingly)
**Purpose**: Test complete user flows end-to-end
**Speed**: Slow (minutes)
**Dependencies**: Real app running on device/emulator
**Location**: `integration_test/` directory

**When to use:**
- Critical user journeys (sign in → create note → save)
- Payment or security-critical flows
- Cross-feature interactions
- Performance validation

**Example scenarios:**
- User authentication flow
- Note creation and retrieval flow
- Offline sync behavior

## The Golden Rules

### ✅ DO Test

1. **Business Logic**
   ```dart
   // lib/features/notes/domain/note_validator.dart
   String? validateNoteTitle(String title) {
     if (title.trim().isEmpty) return 'Title cannot be empty';
     if (title.length > 200) return 'Title too long';
     return null;
   }
   ```

2. **Data Transformations**
   ```dart
   // lib/core/domain/result.dart
   Result<R> map<R>(R Function(T) mapper) {
     return when(
       success: (data) => Result.success(mapper(data)),
       failure: (error) => Result.failure(error),
     );
   }
   ```

3. **Error Handling**
   ```dart
   // lib/features/auth/data/repositories/supabase_auth_repository.dart
   Future<Result<User>> signInWithEmail(...) async {
     try {
       final response = await _supabaseClient.auth.signInWithPassword(...);
       return Result.success(_mapUser(response.user));
     } on AuthException catch (e) {
       return Result.failure(e.toAppFailure());
     }
   }
   ```

4. **State Management Logic**
   ```dart
   // Riverpod providers with business logic
   @riverpod
   class NotesNotifier extends _$NotesNotifier {
     @override
     AsyncValue<List<Note>> build() => const AsyncValue.loading();

     Future<void> loadNotes() async {
       // Test this logic
     }
   }
   ```

5. **Custom Algorithms**
   - Sorting logic
   - Filtering logic
   - Search algorithms
   - Date calculations

### ❌ DON'T Test

1. **Freezed-Generated Code**
   ```dart
   // DON'T test these - they're generated
   user.copyWith(name: 'New Name')
   user1 == user2
   user.toString()
   failure.when(auth: ..., database: ...)
   ```

2. **Simple Getters/Setters**
   ```dart
   // DON'T test this
   class User {
     final String email;
     User(this.email);
   }
   ```

3. **Framework Widgets**
   ```dart
   // DON'T test Flutter's widgets
   Text('Hello')
   Container(child: ...)
   Column(children: ...)
   ```

4. **Constants**
   ```dart
   // DON'T test these
   class BauhausColors {
     static const primary = Color(0xFFFF0000);
   }
   ```

5. **Third-Party Package Internals**
   ```dart
   // DON'T test Supabase, Riverpod, etc.
   Supabase.instance.client.auth.signIn(...)
   ref.watch(someProvider)
   ```

6. **Pure Data Classes Without Logic**
   ```dart
   // DON'T test this - no behavior
   @freezed
   class User with _$User {
     const factory User({
       required String id,
       required String email,
     }) = _User;
   }
   ```

## Project-Specific Guidelines

### Testing Result Pattern

Our app uses `Result<T>` extensively. Always test both success and failure paths:

```dart
// test/core/domain/result_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:notes/core/domain/result.dart';
import 'package:notes/core/domain/failures/app_failure.dart';

void main() {
  group('Result.map', () {
    test('transforms success value', () {
      // Arrange
      final result = Result<int>.success(5);

      // Act
      final mapped = result.map((value) => value * 2);

      // Assert
      expect(mapped.dataOrNull, equals(10));
      expect(mapped.isSuccess, isTrue);
    });

    test('preserves failure without calling mapper', () {
      // Arrange
      const failure = AppFailure.unknown(message: 'error');
      final result = Result<int>.failure(failure);

      // Act
      final mapped = result.map((value) => value * 2);

      // Assert
      expect(mapped.isFailure, isTrue);
      expect(mapped.errorOrNull, equals(failure));
    });
  });
}
```

### Testing Repositories with Mocktail

Use Mocktail to mock external dependencies like SupabaseClient:

```dart
// test/features/auth/data/repositories/supabase_auth_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

// Create mocks
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockTalker extends Mock implements Talker {}

void main() {
  late SupabaseAuthRepository repository;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockAuth;
  late MockTalker mockTalker;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockTalker = MockTalker();

    // Setup default behavior
    when(() => mockSupabaseClient.auth).thenReturn(mockAuth);
    when(() => mockTalker.info(any())).thenReturn(null);
    when(() => mockTalker.debug(any())).thenReturn(null);
    when(() => mockTalker.error(any(), any(), any())).thenReturn(null);

    repository = SupabaseAuthRepository(
      supabaseClient: mockSupabaseClient,
      talker: mockTalker,
    );
  });

  group('signInWithEmail', () {
    test('returns success with user when authentication succeeds', () async {
      // Arrange
      final authResponse = AuthResponse(
        user: User(
          id: '123',
          email: 'test@example.com',
          createdAt: DateTime.now().toIso8601String(),
        ),
        session: Session(accessToken: 'token', tokenType: 'bearer'),
      );

      when(() => mockAuth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => authResponse);

      // Act
      final result = await repository.signInWithEmail(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.email, equals('test@example.com'));
      verify(() => mockAuth.signInWithPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    test('returns failure when authentication fails', () async {
      // Arrange
      when(() => mockAuth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(AuthException('Invalid credentials'));

      // Act
      final result = await repository.signInWithEmail(
        email: 'test@example.com',
        password: 'wrong',
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<AppFailure>());
    });
  });
}
```

### Testing Riverpod Providers

Test providers using `ProviderContainer`:

```dart
// test/features/auth/application/auth_providers_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes/features/auth/application/auth_providers.dart';
import 'package:notes/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late ProviderContainer container;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    container = ProviderContainer(
      overrides: [
        // Override the repository provider with mock
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('authStateProvider', () {
    test('emits authenticated state when user signs in', () async {
      // Arrange
      final user = User(id: '123', email: 'test@example.com');
      when(() => mockAuthRepository.authStateChanges()).thenAnswer(
        (_) => Stream.value(AuthState.authenticated(user)),
      );

      // Act
      final state = await container.read(authStateProvider.future);

      // Assert
      expect(state, isA<Authenticated>());
      expect((state as Authenticated).user.email, equals('test@example.com'));
    });
  });
}
```

### Testing Widget Interactions

Test custom widgets that have interactive behavior:

```dart
// test/core/presentation/widgets/bauhaus_text_field_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes/core/presentation/widgets/inputs/bauhaus_text_field.dart';

void main() {
  group('BauhausTextField', () {
    testWidgets('displays error text when provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BauhausTextField(
              controller: TextEditingController(),
              errorText: 'Invalid input',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Invalid input'), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      // Arrange
      String? changedValue;
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BauhausTextField(
              controller: controller,
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'Hello');

      // Assert
      expect(changedValue, equals('Hello'));
    });

    testWidgets('does not display error when errorText is null', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BauhausTextField(
              controller: TextEditingController(),
              errorText: null,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Invalid input'), findsNothing);
    });
  });
}
```

## Test Structure and Organization

### Directory Structure

Mirror the `lib/` structure in `test/`:

```
test/
├── core/
│   ├── domain/
│   │   ├── result_test.dart
│   │   └── failures/
│   │       ├── app_failure_test.dart
│   │       └── failure_extensions_test.dart
│   └── presentation/
│       └── widgets/
│           ├── bauhaus_text_field_test.dart
│           └── bauhaus_error_widget_test.dart
└── features/
    ├── auth/
    │   ├── domain/
    │   │   └── models/
    │   │       └── auth_state_test.dart (only if custom logic)
    │   ├── data/
    │   │   └── repositories/
    │   │       └── supabase_auth_repository_test.dart
    │   └── application/
    │       └── auth_providers_test.dart
    └── notes/
        ├── domain/
        │   └── validators/
        │       └── note_validator_test.dart
        └── application/
            └── notes_provider_test.dart
```

### File Naming

- Test file: `{original_filename}_test.dart`
- Example: `result.dart` → `result_test.dart`

### Test Template

Use this template for all tests:

```dart
import 'package:flutter_test/flutter_test.dart';
// Import code under test
// Import mocks if needed

void main() {
  group('ClassName or FeatureName', () {
    // Shared test setup
    late DependencyType dependency;
    late ClassUnderTest sut; // sut = System Under Test

    setUp(() {
      // Initialize before each test
      dependency = MockDependency();
      sut = ClassUnderTest(dependency: dependency);
    });

    tearDown(() {
      // Clean up after each test (if needed)
    });

    group('methodName', () {
      test('should do X when Y happens', () {
        // Arrange - set up test data and expectations
        final input = 'test input';
        final expected = 'expected output';

        // Act - execute the code under test
        final result = sut.methodName(input);

        // Assert - verify the outcome
        expect(result, equals(expected));
      });

      test('should handle error case when Z occurs', () {
        // Arrange
        when(() => dependency.someMethod())
            .thenThrow(Exception('error'));

        // Act & Assert
        expect(
          () => sut.methodName('input'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
```

## Common Testing Patterns

### Pattern 1: Testing Async Operations

```dart
test('loads data asynchronously', () async {
  // Arrange
  when(() => mockRepo.fetchData())
      .thenAnswer((_) async => data);

  // Act
  final result = await service.loadData();

  // Assert
  expect(result, equals(data));
});
```

### Pattern 2: Testing Streams

```dart
test('emits values over time', () async {
  // Arrange
  final stream = Stream.fromIterable([1, 2, 3]);

  // Act & Assert
  await expectLater(
    stream,
    emitsInOrder([1, 2, 3]),
  );
});
```

### Pattern 3: Testing Error Cases

```dart
test('handles exception and returns failure', () async {
  // Arrange
  when(() => mockClient.request())
      .thenThrow(Exception('Network error'));

  // Act
  final result = await repository.fetchData();

  // Assert
  expect(result.isFailure, isTrue);
  expect(result.errorOrNull, isA<NetworkFailure>());
});
```

### Pattern 4: Testing Multiple Scenarios

```dart
group('validateEmail', () {
  final testCases = [
    ('valid@email.com', null),
    ('invalid', 'Invalid email format'),
    ('', 'Email cannot be empty'),
    ('no-at-sign.com', 'Invalid email format'),
  ];

  for (final (input, expected) in testCases) {
    test('returns "$expected" for input "$input"', () {
      final result = validateEmail(input);
      expect(result, equals(expected));
    });
  }
});
```

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/core/domain/result_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### Run Widget Tests Only
```bash
flutter test test/core/presentation/
```

### Run with Verbose Output
```bash
flutter test --reporter expanded
```

## Testing Checklist

Before committing code with tests:

- [ ] Test names are descriptive and explain what's being tested
- [ ] Tests follow Arrange-Act-Assert pattern
- [ ] Both success and failure paths are tested
- [ ] Edge cases are covered (null, empty, boundary values)
- [ ] No tests for generated code (`.freezed.dart`, `.g.dart`)
- [ ] No tests for simple getters/setters
- [ ] No tests for framework widgets
- [ ] All mocks are set up properly in `setUp()`
- [ ] Tests are independent (can run in any order)
- [ ] Tests run fast (< 1 second for unit tests)
- [ ] Verification calls match actual usage
- [ ] No hardcoded delays (`await Future.delayed()`)

## Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Testing Generated Code
```dart
// DON'T do this
test('copyWith updates name', () {
  final user = User(id: '1', name: 'John');
  final updated = user.copyWith(name: 'Jane');
  expect(updated.name, equals('Jane'));
});
```

### ❌ Anti-Pattern 2: Testing Framework Behavior
```dart
// DON'T do this
testWidgets('Text widget displays text', (tester) async {
  await tester.pumpWidget(Text('Hello'));
  expect(find.text('Hello'), findsOneWidget);
});
```

### ❌ Anti-Pattern 3: Over-Mocking
```dart
// DON'T do this - mocking everything you don't need
setUp(() {
  when(() => mock.method1()).thenReturn(value1);
  when(() => mock.method2()).thenReturn(value2);
  when(() => mock.method3()).thenReturn(value3);
  // Only mock what the specific test uses!
});
```

### ❌ Anti-Pattern 4: Testing Implementation Details
```dart
// DON'T test private methods or internal state
test('internal cache is updated', () {
  service.fetchData();
  expect(service._cache, isNotEmpty); // Testing private field
});

// DO test public behavior
test('returns cached data on second call', () {
  service.fetchData();
  final result = service.fetchData();
  expect(result, isNotNull);
  verify(() => mockRepo.fetch()).called(1); // Only called once
});
```

## Questions to Ask Before Writing a Test

1. **Is this my code?** If no → don't test it
2. **Does it have logic?** If no → don't test it
3. **Could this logic have bugs?** If no → don't test it
4. **Will this test catch real regressions?** If no → don't test it
5. **Is there a simpler way to verify this?** If yes → reconsider

## Getting Help

When unsure about testing:

1. Check this guide first
2. Look at existing tests in the project
3. Ask: "Would this test catch a real bug in my code?"
4. Refer to `../.claude/research/flutter-testing-best-practices-2025.md` for detailed rationale

## Priority Testing Targets

Start testing in this order:

**High Priority:**
1. `lib/core/domain/result.dart` - Extension methods
2. `lib/core/domain/failures/app_failure.dart` - Extension methods
3. `lib/features/auth/data/repositories/supabase_auth_repository.dart`
4. Any validation logic you add
5. Any state management providers with logic

**Medium Priority:**
6. Custom Bauhaus widgets with interactions
7. Form validation UI
8. Error state displays

**Low Priority:**
9. Integration tests for critical flows
10. Performance tests

---

Remember: **The goal is regression protection, not code coverage.** A few meaningful tests are worth more than hundreds of tests for trivial code.
