import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes/core/domain/failures/app_failure.dart';
import 'package:notes/core/domain/result.dart';
import 'package:notes/features/auth/application/auth_providers.dart';
import 'package:notes/features/auth/domain/models/auth_state.dart';
import 'package:notes/features/auth/domain/models/user.dart';
import 'package:notes/features/auth/domain/repositories/auth_repository.dart';

// Create mock
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

  group('AuthNotifier', () {
    group('signIn', () {
      test('returns success and updates state when sign in succeeds', () async {
        // Arrange
        final user = User(
          id: '123',
          email: 'test@example.com',
          createdAt: DateTime.now(),
        );

        when(
          () => mockAuthRepository.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => Result.success(user));

        // Act
        final notifier = container.read(authProvider.notifier);
        final result = await notifier.signIn(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.email, equals('test@example.com'));

        // Verify state is updated to data (no longer loading)
        final state = container.read(authProvider);
        expect(state.hasValue, isTrue);
        expect(state.hasError, isFalse);

        // Verify repository method was called
        verify(
          () => mockAuthRepository.signInWithEmail(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).called(1);
      });

      test('returns failure and updates state when sign in fails', () async {
        // Arrange
        const failure = AppFailure.auth(
          message: 'Invalid credentials',
          code: '401',
        );

        when(
          () => mockAuthRepository.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => Result.failure(failure));

        // Act
        final notifier = container.read(authProvider.notifier);
        final result = await notifier.signIn(
          email: 'wrong@example.com',
          password: 'wrongpass',
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, equals(failure));

        // Verify state is updated to error
        final state = container.read(authProvider);
        expect(state.hasError, isTrue);
        expect(state.error, equals(failure));
      });
    });

    group('signUp', () {
      test('returns success and updates state when sign up succeeds', () async {
        // Arrange
        final user = User(
          id: '456',
          email: 'newuser@example.com',
          createdAt: DateTime.now(),
        );

        when(
          () => mockAuthRepository.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => Result.success(user));

        // Act
        final notifier = container.read(authProvider.notifier);
        final result = await notifier.signUp(
          email: 'newuser@example.com',
          password: 'securepass123',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.email, equals('newuser@example.com'));

        // Verify state is updated
        final state = container.read(authProvider);
        expect(state.hasValue, isTrue);
        expect(state.hasError, isFalse);

        // Verify repository method was called
        verify(
          () => mockAuthRepository.signUpWithEmail(
            email: 'newuser@example.com',
            password: 'securepass123',
          ),
        ).called(1);
      });

      test('returns failure and updates state when sign up fails', () async {
        // Arrange
        const failure = AppFailure.auth(
          message: 'Email already registered',
          code: 'email_exists',
        );

        when(
          () => mockAuthRepository.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => Result.failure(failure));

        // Act
        final notifier = container.read(authProvider.notifier);
        final result = await notifier.signUp(
          email: 'existing@example.com',
          password: 'password123',
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, equals(failure));

        // Verify state is updated to error
        final state = container.read(authProvider);
        expect(state.hasError, isTrue);
      });
    });

    group('signOut', () {
      test('returns success and updates state when sign out succeeds', () async {
        // Arrange
        when(() => mockAuthRepository.signOut())
            .thenAnswer((_) async => const Result.success(null));

        // Act
        final notifier = container.read(authProvider.notifier);
        final result = await notifier.signOut();

        // Assert
        expect(result.isSuccess, isTrue);

        // Verify state is updated
        final state = container.read(authProvider);
        expect(state.hasValue, isTrue);
        expect(state.hasError, isFalse);

        // Verify repository method was called
        verify(() => mockAuthRepository.signOut()).called(1);
      });

      test('returns failure and updates state when sign out fails', () async {
        // Arrange
        const failure = AppFailure.network(
          message: 'Network error during signout',
        );

        when(() => mockAuthRepository.signOut())
            .thenAnswer((_) async => Result.failure(failure));

        // Act
        final notifier = container.read(authProvider.notifier);
        final result = await notifier.signOut();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, equals(failure));

        // Verify state is updated to error
        final state = container.read(authProvider);
        expect(state.hasError, isTrue);
      });
    });

    group('resetPassword', () {
      test('returns success and updates state when password reset succeeds', () async {
        // Arrange
        when(
          () => mockAuthRepository.resetPassword(email: any(named: 'email')),
        ).thenAnswer((_) async => const Result.success(null));

        // Act
        final notifier = container.read(authProvider.notifier);
        final result = await notifier.resetPassword(
          email: 'user@example.com',
        );

        // Assert
        expect(result.isSuccess, isTrue);

        // Verify state is updated
        final state = container.read(authProvider);
        expect(state.hasValue, isTrue);
        expect(state.hasError, isFalse);

        // Verify repository method was called
        verify(
          () => mockAuthRepository.resetPassword(email: 'user@example.com'),
        ).called(1);
      });

      test('returns failure and updates state when password reset fails', () async {
        // Arrange
        const failure = AppFailure.auth(
          message: 'User not found',
          code: 'user_not_found',
        );

        when(
          () => mockAuthRepository.resetPassword(email: any(named: 'email')),
        ).thenAnswer((_) async => Result.failure(failure));

        // Act
        final notifier = container.read(authProvider.notifier);
        final result = await notifier.resetPassword(
          email: 'nonexistent@example.com',
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, equals(failure));

        // Verify state is updated to error
        final state = container.read(authProvider);
        expect(state.hasError, isTrue);
      });
    });
  });

  group('authStateStreamProvider', () {
    test('returns stream of auth state from repository', () {
      // Arrange
      final user = User(
        id: '789',
        email: 'stream@example.com',
        createdAt: DateTime.now(),
      );

      when(() => mockAuthRepository.authStateChanges()).thenAnswer(
        (_) => Stream.value(AuthState.authenticated(user)),
      );

      // Act
      final streamProvider = container.read(authStateStreamProvider);

      // Assert
      expect(streamProvider, isA<AsyncValue<AuthState>>());
    });
  });

  group('currentUserProvider', () {
    test('returns null when no user is authenticated', () {
      // Arrange
      when(() => mockAuthRepository.currentUser).thenReturn(null);

      // Act
      final user = container.read(currentUserProvider);

      // Assert
      expect(user, isNull);
    });

    test('returns user when authenticated', () {
      // Arrange
      final user = User(
        id: 'current-user',
        email: 'current@example.com',
        createdAt: DateTime.now(),
      );

      when(() => mockAuthRepository.currentUser).thenReturn(user);

      // Act
      final result = container.read(currentUserProvider);

      // Assert
      expect(result, isNotNull);
      expect(result?.email, equals('current@example.com'));
    });
  });
}
