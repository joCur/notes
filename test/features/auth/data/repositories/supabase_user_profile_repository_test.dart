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
      expect(result.dataOrNull?.preferredLanguage, equals('en'));

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
      expect(result.errorOrNull, isA<AppFailure>());
      expect(result.errorOrNull, isA<DatabaseFailure>());
    });

    test('returns failure on PostgrestException', () async {
      // Arrange
      final mockTransformBuilder = MockPostgrestTransformBuilder();
      when<Future<dynamic>>(
        () => mockTransformBuilder.then<dynamic>(
          any(),
          onError: any(named: 'onError'),
        ),
      ).thenThrow(
        PostgrestException(
          message: 'Database error',
          code: 'PGRST000',
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
      verify(() => mockTalker.error(any(), any(), any())).called(1);
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

  group('updateProfile', () {
    const userId = 'test-user-id';

    test('returns success with updated profile when update succeeds', () async {
      // Arrange
      final updatedData = <String, dynamic>{
        'id': userId,
        'email': 'test@example.com',
        'displayName': 'Updated Name',
        'preferredLanguage': 'de',
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
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
        return onValue(updatedData);
      });

      when(() => mockSupabaseClient.from('user_profiles'))
          .thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.update(any()))
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', userId))
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.select())
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.single())
          .thenAnswer((_) => mockTransformBuilder);

      // Act
      final result = await repository.updateProfile(
        userId: userId,
        displayName: 'Updated Name',
        preferredLanguage: 'de',
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isNotNull);
      expect(result.dataOrNull?.displayName, equals('Updated Name'));
      expect(result.dataOrNull?.preferredLanguage, equals('de'));

      verify(() => mockSupabaseClient.from('user_profiles')).called(1);
      verify(() => mockQueryBuilder.update(any())).called(1);
      verify(() => mockFilterBuilder.eq('id', userId)).called(1);
      verify(() => mockFilterBuilder.select()).called(1);
      verify(() => mockFilterBuilder.single()).called(1);
    });

    test('updates only provided fields (partial update)', () async {
      // Arrange
      final updatedData = <String, dynamic>{
        'id': userId,
        'email': 'test@example.com',
        'displayName': 'New Name',
        'preferredLanguage': 'en',
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
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
        return onValue(updatedData);
      });

      when(() => mockSupabaseClient.from('user_profiles'))
          .thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.update(any()))
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', userId))
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.select())
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.single())
          .thenAnswer((_) => mockTransformBuilder);

      // Act
      final result = await repository.updateProfile(
        userId: userId,
        displayName: 'New Name',
        // Note: preferredLanguage not provided
      );

      // Assert
      expect(result.isSuccess, isTrue);

      // Verify update was called with only displayName
      final captured = verify(() => mockQueryBuilder.update(captureAny())).captured;
      final updateData = captured.first as Map<String, dynamic>;
      expect(updateData.containsKey('display_name'), isTrue);
      expect(updateData.containsKey('preferred_language'), isFalse);
    });

    test('returns current profile when no fields are provided', () async {
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
      final result = await repository.updateProfile(userId: userId);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.id, equals(userId));

      // Verify no update was called, only getProfile
      verifyNever(() => mockQueryBuilder.update(any()));
      verify(() => mockQueryBuilder.select()).called(1);
    });

    test('returns failure when user not found', () async {
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
      when(() => mockQueryBuilder.update(any()))
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', userId))
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.select())
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.single())
          .thenAnswer((_) => mockTransformBuilder);

      // Act
      final result = await repository.updateProfile(
        userId: userId,
        displayName: 'Test',
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<DatabaseFailure>());
    });

    test('returns failure on PostgrestException', () async {
      // Arrange
      final mockTransformBuilder = MockPostgrestTransformBuilder();
      when<Future<dynamic>>(
        () => mockTransformBuilder.then<dynamic>(
          any(),
          onError: any(named: 'onError'),
        ),
      ).thenThrow(
        PostgrestException(
          message: 'Database error',
          code: 'PGRST000',
        ),
      );

      when(() => mockSupabaseClient.from('user_profiles'))
          .thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.update(any()))
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', userId))
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.select())
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.single())
          .thenAnswer((_) => mockTransformBuilder);

      // Act
      final result = await repository.updateProfile(
        userId: userId,
        displayName: 'Test',
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<DatabaseFailure>());
    });
  });

  group('createProfile', () {
    const userId = 'test-user-id';
    const email = 'test@example.com';

    test('returns success with created profile when creation succeeds',
        () async {
      // Arrange
      final createdData = <String, dynamic>{
        'id': userId,
        'email': email,
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
        return onValue(createdData);
      });

      when(() => mockSupabaseClient.from('user_profiles'))
          .thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any()))
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.select())
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.single())
          .thenAnswer((_) => mockTransformBuilder);

      // Act
      final result = await repository.createProfile(
        userId: userId,
        email: email,
        displayName: 'Test User',
        preferredLanguage: 'en',
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isNotNull);
      expect(result.dataOrNull?.id, equals(userId));
      expect(result.dataOrNull?.email, equals(email));
      expect(result.dataOrNull?.displayName, equals('Test User'));

      verify(() => mockSupabaseClient.from('user_profiles')).called(1);
      verify(() => mockQueryBuilder.insert(any())).called(1);
      verify(() => mockFilterBuilder.select()).called(1);
      verify(() => mockFilterBuilder.single()).called(1);
    });

    test('creates profile with default language when not provided', () async {
      // Arrange
      final createdData = <String, dynamic>{
        'id': userId,
        'email': email,
        'displayName': null,
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
        return onValue(createdData);
      });

      when(() => mockSupabaseClient.from('user_profiles'))
          .thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any()))
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.select())
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.single())
          .thenAnswer((_) => mockTransformBuilder);

      // Act
      final result = await repository.createProfile(
        userId: userId,
        email: email,
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.preferredLanguage, equals('en'));

      // Verify insert data includes default language
      final captured = verify(() => mockQueryBuilder.insert(captureAny())).captured;
      final insertData = captured.first as Map<String, dynamic>;
      expect(insertData['preferred_language'], equals('en'));
    });

    test('returns failure on duplicate email (unique violation)', () async {
      // Arrange
      final mockTransformBuilder = MockPostgrestTransformBuilder();
      when<Future<dynamic>>(
        () => mockTransformBuilder.then<dynamic>(
          any(),
          onError: any(named: 'onError'),
        ),
      ).thenThrow(
        PostgrestException(
          message: 'Unique constraint violation',
          code: '23505', // PostgreSQL unique violation
        ),
      );

      when(() => mockSupabaseClient.from('user_profiles'))
          .thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any()))
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.select())
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.single())
          .thenAnswer((_) => mockTransformBuilder);

      // Act
      final result = await repository.createProfile(
        userId: userId,
        email: email,
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<DatabaseFailure>());
    });

    test('returns failure on invalid user ID (foreign key violation)',
        () async {
      // Arrange
      final mockTransformBuilder = MockPostgrestTransformBuilder();
      when<Future<dynamic>>(
        () => mockTransformBuilder.then<dynamic>(
          any(),
          onError: any(named: 'onError'),
        ),
      ).thenThrow(
        PostgrestException(
          message: 'Foreign key violation',
          code: '23503', // PostgreSQL foreign key violation
        ),
      );

      when(() => mockSupabaseClient.from('user_profiles'))
          .thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any()))
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.select())
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.single())
          .thenAnswer((_) => mockTransformBuilder);

      // Act
      final result = await repository.createProfile(
        userId: 'invalid-id',
        email: email,
      );

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
      when(() => mockQueryBuilder.insert(any()))
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.select())
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.single())
          .thenAnswer((_) => mockTransformBuilder);

      // Act
      final result = await repository.createProfile(
        userId: userId,
        email: email,
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnknownFailure>());
    });
  });
}
