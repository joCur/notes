# Supabase Database Mocking Guide

## Overview

This guide provides the **verified, working solution** for mocking Supabase Postgrest operations in Flutter unit tests using Mocktail. This approach allows you to test repository implementations without making actual database calls.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Core Concepts](#core-concepts)
- [Step-by-Step Setup](#step-by-step-setup)
- [Working Patterns](#working-patterns)
- [Common Mistakes](#common-mistakes)
- [Complete Examples](#complete-examples)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Packages

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.4
```

### Required Imports

```dart
import 'dart:async';  // CRITICAL: Required for FutureOr type

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
```

## Core Concepts

### The Challenge

Supabase Postgrest query builders create a chain of method calls:

```dart
await supabaseClient
    .from('table')      // Returns SupabaseQueryBuilder
    .select()           // Returns PostgrestFilterBuilder
    .eq('id', userId)   // Returns PostgrestFilterBuilder (chaining)
    .single();          // Returns PostgrestTransformBuilder (implements Future!)
```

The critical insight: **`PostgrestTransformBuilder<T>` implements `Future<T>`** by implementing the `.then()` method. This means you cannot simply mock it like a regular return value.

### Key Requirements

1. **Use `.thenAnswer()` not `.thenReturn()`** - For ALL methods in the query chain
2. **Mock the `.then()` method** - This is how PostgrestTransformBuilder becomes awaitable
3. **Create fresh mocks per test** - Each test needs its own PostgrestTransformBuilder instance
4. **Match JSON field naming** - Use camelCase or snake_case based on your model's `@JsonKey` annotations

## Step-by-Step Setup

### 1. Create Mock Classes

```dart
// Create mocks for all Supabase types you'll use
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<Map<String, dynamic>> {}

class MockTalker extends Mock implements Talker {}
```

**Important:** Notice `PostgrestFilterBuilder<List<Map<String, dynamic>>>` - this matches the type Supabase uses for query results.

### 2. Setup Test Fixtures

```dart
void main() {
  late YourRepository repository;
  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockTalker mockTalker;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockTalker = MockTalker();

    // Setup Talker mocks (if your repository uses Talker)
    when(() => mockTalker.info(any())).thenReturn(null);
    when(() => mockTalker.debug(any())).thenReturn(null);
    when(() => mockTalker.error(any(), any(), any())).thenReturn(null);

    // Create repository with mocked dependencies
    repository = YourRepository(
      supabaseClient: mockSupabaseClient,
      talker: mockTalker,
    );
  });
}
```

### 3. Create Test Data

**Match your model's JSON field naming:**

```dart
// ✅ If your model uses camelCase (Freezed default)
final testData = <String, dynamic>{
  'id': 'user-123',
  'email': 'test@example.com',
  'displayName': 'Test User',
  'createdAt': '2025-01-01T00:00:00.000Z',
  'updatedAt': '2025-01-01T00:00:00.000Z',
};

// ✅ If your model uses snake_case (with @JsonKey)
final testData = <String, dynamic>{
  'id': 'user-123',
  'email': 'test@example.com',
  'display_name': 'Test User',
  'created_at': '2025-01-01T00:00:00.000Z',
  'updated_at': '2025-01-01T00:00:00.000Z',
};
```

**Check your model to determine the correct naming:**

```dart
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    String? displayName,        // → JSON: "displayName"
    required DateTime createdAt, // → JSON: "createdAt"
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
```

## Working Patterns

### Pattern 1: Success Case (SELECT)

```dart
test('returns success when data exists', () async {
  // 1. Prepare test data
  final testData = <String, dynamic>{
    'id': 'user-123',
    'email': 'test@example.com',
    'displayName': 'Test User',
    'createdAt': '2025-01-01T00:00:00.000Z',
    'updatedAt': '2025-01-01T00:00:00.000Z',
  };

  // 2. Create and configure PostgrestTransformBuilder mock
  final mockTransformBuilder = MockPostgrestTransformBuilder();
  when<Future<dynamic>>(
    () => mockTransformBuilder.then<dynamic>(
      any(),
      onError: any(named: 'onError'),
    ),
  ).thenAnswer((invocation) async {
    // Extract the callback from the .then() call
    final onValue = invocation.positionalArguments[0]
        as FutureOr<dynamic> Function(Map<String, dynamic>);
    // Call it with our test data
    return onValue(testData);
  });

  // 3. Setup the query chain - USE .thenAnswer() for ALL methods
  when(() => mockSupabaseClient.from('user_profiles'))
      .thenAnswer((_) => mockQueryBuilder);
  when(() => mockQueryBuilder.select())
      .thenAnswer((_) => mockFilterBuilder);
  when(() => mockFilterBuilder.eq('id', 'user-123'))
      .thenAnswer((_) => mockFilterBuilder);
  when(() => mockFilterBuilder.single())
      .thenAnswer((_) => mockTransformBuilder);

  // 4. Act
  final result = await repository.getProfile('user-123');

  // 5. Assert
  expect(result.isSuccess, isTrue);
  expect(result.dataOrNull?.email, equals('test@example.com'));

  // 6. Verify interactions
  verify(() => mockSupabaseClient.from('user_profiles')).called(1);
  verify(() => mockQueryBuilder.select()).called(1);
  verify(() => mockFilterBuilder.eq('id', 'user-123')).called(1);
  verify(() => mockFilterBuilder.single()).called(1);
});
```

### Pattern 2: Error Case

```dart
test('returns failure when data not found', () async {
  // 1. Create transform builder that throws an error
  final mockTransformBuilder = MockPostgrestTransformBuilder();
  when<Future<dynamic>>(
    () => mockTransformBuilder.then<dynamic>(
      any(),
      onError: any(named: 'onError'),
    ),
  ).thenThrow(
    PostgrestException(
      message: 'No rows found',
      code: 'PGRST116',
    ),
  );

  // 2. Setup query chain
  when(() => mockSupabaseClient.from('user_profiles'))
      .thenAnswer((_) => mockQueryBuilder);
  when(() => mockQueryBuilder.select())
      .thenAnswer((_) => mockFilterBuilder);
  when(() => mockFilterBuilder.eq('id', 'user-123'))
      .thenAnswer((_) => mockFilterBuilder);
  when(() => mockFilterBuilder.single())
      .thenAnswer((_) => mockTransformBuilder);

  // 3. Act
  final result = await repository.getProfile('user-123');

  // 4. Assert
  expect(result.isFailure, isTrue);
  expect(result.errorOrNull, isA<DatabaseFailure>());
});
```

### Pattern 3: UPDATE Operation

```dart
test('updates profile successfully', () async {
  // 1. Prepare test data
  final updatedData = <String, dynamic>{
    'id': 'user-123',
    'email': 'test@example.com',
    'displayName': 'Updated Name',
    'preferredLanguage': 'de',
    'createdAt': '2025-01-01T00:00:00.000Z',
    'updatedAt': '2025-01-02T00:00:00.000Z',
  };

  // 2. Create transform builder
  final mockTransformBuilder = MockPostgrestTransformBuilder();
  when<Future<dynamic>>(
    () => mockTransformBuilder.then<dynamic>(
      any(),
      onError: any(named: 'onError'),
    ),
  ).thenAnswer((invocation) async {
    final onValue = invocation.positionalArguments[0]
        as FutureOr<dynamic> Function(Map<String, dynamic>);
    return onValue(updatedData);
  });

  // 3. Setup UPDATE query chain
  when(() => mockSupabaseClient.from('user_profiles'))
      .thenAnswer((_) => mockQueryBuilder);
  when(() => mockQueryBuilder.update(any()))
      .thenAnswer((_) => mockFilterBuilder);
  when(() => mockFilterBuilder.eq('id', 'user-123'))
      .thenAnswer((_) => mockFilterBuilder);
  when(() => mockFilterBuilder.select())
      .thenAnswer((_) => mockFilterBuilder);
  when(() => mockFilterBuilder.single())
      .thenAnswer((_) => mockTransformBuilder);

  // 4. Act
  final result = await repository.updateProfile(
    userId: 'user-123',
    displayName: 'Updated Name',
    preferredLanguage: 'de',
  );

  // 5. Assert
  expect(result.isSuccess, isTrue);
  expect(result.dataOrNull?.displayName, equals('Updated Name'));

  // 6. Verify update data
  final captured = verify(() => mockQueryBuilder.update(captureAny())).captured;
  final updateData = captured.first as Map<String, dynamic>;
  expect(updateData['display_name'], equals('Updated Name'));
  expect(updateData['preferred_language'], equals('de'));
});
```

### Pattern 4: INSERT Operation

```dart
test('creates profile successfully', () async {
  // 1. Prepare test data
  final createdData = <String, dynamic>{
    'id': 'user-123',
    'email': 'new@example.com',
    'displayName': 'New User',
    'preferredLanguage': 'en',
    'createdAt': '2025-01-01T00:00:00.000Z',
    'updatedAt': '2025-01-01T00:00:00.000Z',
  };

  // 2. Create transform builder
  final mockTransformBuilder = MockPostgrestTransformBuilder();
  when<Future<dynamic>>(
    () => mockTransformBuilder.then<dynamic>(
      any(),
      onError: any(named: 'onError'),
    ),
  ).thenAnswer((invocation) async {
    final onValue = invocation.positionalArguments[0]
        as FutureOr<dynamic> Function(Map<String, dynamic>);
    return onValue(createdData);
  });

  // 3. Setup INSERT query chain
  when(() => mockSupabaseClient.from('user_profiles'))
      .thenAnswer((_) => mockQueryBuilder);
  when(() => mockQueryBuilder.insert(any()))
      .thenAnswer((_) => mockFilterBuilder);
  when(() => mockFilterBuilder.select())
      .thenAnswer((_) => mockFilterBuilder);
  when(() => mockFilterBuilder.single())
      .thenAnswer((_) => mockTransformBuilder);

  // 4. Act
  final result = await repository.createProfile(
    userId: 'user-123',
    email: 'new@example.com',
    displayName: 'New User',
  );

  // 5. Assert
  expect(result.isSuccess, isTrue);
  expect(result.dataOrNull?.email, equals('new@example.com'));
});
```

## Common Mistakes

### ❌ Mistake 1: Using `.thenReturn()` Instead of `.thenAnswer()`

**Wrong:**
```dart
when(() => mockFilterBuilder.single())
    .thenReturn(mockTransformBuilder);  // ❌ ERROR!
```

**Error Message:**
```
Invalid argument(s): `thenReturn` should not be used to return a Future.
Instead, use `thenAnswer((_) => future)`.
```

**Correct:**
```dart
when(() => mockFilterBuilder.single())
    .thenAnswer((_) => mockTransformBuilder);  // ✅ Works!
```

**Why:** All methods in the Postgrest query chain return Future-like objects, so Mocktail requires `.thenAnswer()`.

### ❌ Mistake 2: Helper Functions with Nested `when()` Calls

**Wrong:**
```dart
// ❌ DON'T DO THIS
MockPostgrestTransformBuilder setupMockBuilder(Map<String, dynamic> data) {
  final mockBuilder = MockPostgrestTransformBuilder();
  when<Future<dynamic>>(() => mockBuilder.then(...))  // Nested when()
      .thenAnswer(...);
  return mockBuilder;
}

test('example', () {
  final mock = setupMockBuilder(data);  // ❌ ERROR!
  when(() => mockFilterBuilder.single()).thenAnswer((_) => mock);
});
```

**Error Message:**
```
Bad state: Cannot call `when` within a stub response
```

**Correct:**
```dart
// ✅ DO THIS - Inline mocking in each test
test('example', () {
  final mockTransformBuilder = MockPostgrestTransformBuilder();
  when<Future<dynamic>>(() => mockTransformBuilder.then(...))
      .thenAnswer(...);

  when(() => mockFilterBuilder.single())
      .thenAnswer((_) => mockTransformBuilder);
});
```

**Why:** Mocktail doesn't allow `when()` calls inside functions that are called during a stub setup. Always create and configure mocks inline within each test.

### ❌ Mistake 3: Wrong JSON Field Naming

**Wrong:**
```dart
final data = {
  'created_at': '2025-01-01',  // ❌ snake_case
  'updated_at': '2025-01-01',
};
```

**Error Message:**
```
CheckedFromJsonException
type 'Null' is not a subtype of type 'String' in type cast
```

**Correct:**
```dart
// Check your model's fromJson implementation!
final data = {
  'createdAt': '2025-01-01',  // ✅ camelCase
  'updatedAt': '2025-01-01',
};
```

**Why:** Freezed uses camelCase by default. Your test data must match exactly what `fromJson()` expects.

### ❌ Mistake 4: Forgetting `dart:async` Import

**Wrong:**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// Missing: import 'dart:async';
```

**Error Message:**
```
Error: 'FutureOr' isn't a type.
```

**Correct:**
```dart
import 'dart:async';  // ✅ Required!
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
```

## Complete Examples

### Example 1: Full Repository Test File

```dart
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes/core/domain/failures/app_failure.dart';
import 'package:notes/core/domain/result.dart';
import 'package:notes/features/auth/data/repositories/supabase_user_profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

// Mocks
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<Map<String, dynamic>> {}
class MockTalker extends Mock implements Talker {}

void main() {
  late SupabaseUserProfileRepository repository;
  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockTalker mockTalker;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockTalker = MockTalker();

    when(() => mockTalker.info(any())).thenReturn(null);
    when(() => mockTalker.debug(any())).thenReturn(null);
    when(() => mockTalker.error(any(), any(), any())).thenReturn(null);

    repository = SupabaseUserProfileRepository(
      supabaseClient: mockSupabaseClient,
      talker: mockTalker,
    );
  });

  group('getProfile', () {
    const userId = 'test-user-id';

    test('returns success with profile when profile exists', () async {
      // Arrange
      final profileData = <String, dynamic>{
        'id': userId,
        'email': 'test@example.com',
        'displayName': 'Test User',
        'preferredLanguage': 'en',
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-01T00:00:00.000Z',
      };

      final mockTransformBuilder = MockPostgrestTransformBuilder();
      when<Future<dynamic>>(
        () => mockTransformBuilder.then<dynamic>(
          any(),
          onError: any(named: 'onError'),
        ),
      ).thenAnswer((invocation) async {
        final onValue = invocation.positionalArguments[0]
            as FutureOr<dynamic> Function(Map<String, dynamic>);
        return onValue(profileData);
      });

      when(() => mockSupabaseClient.from('user_profiles'))
          .thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.select())
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', userId))
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.single())
          .thenAnswer((_) => mockTransformBuilder);

      // Act
      final result = await repository.getProfile(userId);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isNotNull);
      expect(result.dataOrNull?.id, equals(userId));
      expect(result.dataOrNull?.email, equals('test@example.com'));
      expect(result.dataOrNull?.displayName, equals('Test User'));

      verify(() => mockSupabaseClient.from('user_profiles')).called(1);
      verify(() => mockQueryBuilder.select()).called(1);
      verify(() => mockFilterBuilder.eq('id', userId)).called(1);
      verify(() => mockFilterBuilder.single()).called(1);
    });

    test('returns failure when profile not found', () async {
      // Arrange
      final mockTransformBuilder = MockPostgrestTransformBuilder();
      when<Future<dynamic>>(
        () => mockTransformBuilder.then<dynamic>(
          any(),
          onError: any(named: 'onError'),
        ),
      ).thenThrow(
        PostgrestException(
          message: 'No rows found',
          code: 'PGRST116',
        ),
      );

      when(() => mockSupabaseClient.from('user_profiles'))
          .thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.select())
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', userId))
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.single())
          .thenAnswer((_) => mockTransformBuilder);

      // Act
      final result = await repository.getProfile(userId);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<DatabaseFailure>());
    });

    test('returns failure on unexpected exception', () async {
      // Arrange
      final mockTransformBuilder = MockPostgrestTransformBuilder();
      when<Future<dynamic>>(
        () => mockTransformBuilder.then<dynamic>(
          any(),
          onError: any(named: 'onError'),
        ),
      ).thenThrow(Exception('Network error'));

      when(() => mockSupabaseClient.from('user_profiles'))
          .thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.select())
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', userId))
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.single())
          .thenAnswer((_) => mockTransformBuilder);

      // Act
      final result = await repository.getProfile(userId);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnknownFailure>());
    });
  });
}
```

## Troubleshooting

### Problem: Tests compile but fail with "type 'Null' is not a subtype"

**Diagnosis:** JSON field naming mismatch

**Solution:**
1. Check your model's `fromJson` implementation
2. Look at the generated `.g.dart` file to see expected field names
3. Update your test data to match exactly

### Problem: "Bad state: Cannot call `when` within a stub response"

**Diagnosis:** Attempting to use helper functions that contain `when()` calls

**Solution:**
- Remove helper functions
- Inline all mocking code directly in each test
- Create fresh `MockPostgrestTransformBuilder` instances in each test

### Problem: "Invalid argument(s): `thenReturn` should not be used"

**Diagnosis:** Using `.thenReturn()` instead of `.thenAnswer()`

**Solution:**
- Replace ALL `.thenReturn()` calls with `.thenAnswer((_) => ...)`
- This applies to every method in the query chain

### Problem: Tests hang or timeout

**Diagnosis:** Missing mock setup for a method in the chain

**Solution:**
- Verify you've mocked ALL methods:
  - `.from()` → `.thenAnswer()`
  - `.select()` → `.thenAnswer()`
  - `.eq()` or `.filter()` → `.thenAnswer()`
  - `.single()` or `.maybeSingle()` → `.thenAnswer()`

## Quick Reference

### Query Chain Template

```dart
// SUCCESS case
final mockTransformBuilder = MockPostgrestTransformBuilder();
when<Future<dynamic>>(
  () => mockTransformBuilder.then<dynamic>(any(), onError: any(named: 'onError')),
).thenAnswer((invocation) async {
  final onValue = invocation.positionalArguments[0]
      as FutureOr<dynamic> Function(Map<String, dynamic>);
  return onValue(testData);
});

when(() => mockSupabaseClient.from('table')).thenAnswer((_) => mockQueryBuilder);
when(() => mockQueryBuilder.select()).thenAnswer((_) => mockFilterBuilder);
when(() => mockFilterBuilder.eq('column', value)).thenAnswer((_) => mockFilterBuilder);
when(() => mockFilterBuilder.single()).thenAnswer((_) => mockTransformBuilder);
```

```dart
// ERROR case
final mockTransformBuilder = MockPostgrestTransformBuilder();
when<Future<dynamic>>(
  () => mockTransformBuilder.then<dynamic>(any(), onError: any(named: 'onError')),
).thenThrow(PostgrestException(message: 'Error', code: 'CODE'));

// ... rest of query chain setup
```

## Additional Resources

- [Mocktail Documentation](https://pub.dev/packages/mocktail)
- [Supabase Flutter Documentation](https://supabase.com/docs/reference/dart)
- [Flutter Testing Best Practices](https://docs.flutter.dev/cookbook/testing/unit/introduction)

## Changelog

- **2025-12-04**: Initial version - Complete working solution verified
- Pattern tested and confirmed working with Supabase Flutter v2.x
- All examples run successfully in test environment
