import 'package:flutter_test/flutter_test.dart';
import 'package:notes/core/routing/router_redirect.dart';
import 'package:notes/features/auth/domain/models/auth_state.dart';
import 'package:notes/features/auth/domain/models/user.dart';

void main() {
  group('getRedirectLocation', () {
    // Test data
    final mockUser = User(
      id: 'test-id',
      email: 'test@example.com',
      createdAt: DateTime.now(),
    );
    final authenticatedState = AuthState.authenticated(mockUser);
    final passwordRecoveryState = AuthState.passwordRecovery(mockUser);
    const unauthenticatedState = AuthState.unauthenticated();

    group('Loading state', () {
      test('returns null when auth state is loading (null)', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: null,
          currentLocation: '/any-route',
        );

        // Assert
        expect(result, isNull);
      });

      test('stays on splash screen when loading', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: null,
          currentLocation: '/',
        );

        // Assert
        expect(result, isNull);
      });

      test('stays on login screen when loading', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: null,
          currentLocation: '/login',
        );

        // Assert
        expect(result, isNull);
      });
    });

    group('Splash screen redirects', () {
      test('redirects to /home when authenticated', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: authenticatedState,
          currentLocation: '/',
        );

        // Assert
        expect(result, equals('/home'));
      });

      test('redirects to /login when unauthenticated', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: unauthenticatedState,
          currentLocation: '/',
        );

        // Assert
        expect(result, equals('/login'));
      });
    });

    group('Public routes - /login', () {
      test('redirects authenticated user to /home', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: authenticatedState,
          currentLocation: '/login',
        );

        // Assert
        expect(result, equals('/home'));
      });

      test('allows unauthenticated user to access', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: unauthenticatedState,
          currentLocation: '/login',
        );

        // Assert
        expect(result, isNull);
      });
    });

    group('Public routes - /signup', () {
      test('redirects authenticated user to /home', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: authenticatedState,
          currentLocation: '/signup',
        );

        // Assert
        expect(result, equals('/home'));
      });

      test('allows unauthenticated user to access', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: unauthenticatedState,
          currentLocation: '/signup',
        );

        // Assert
        expect(result, isNull);
      });
    });

    group('Public routes - /forgot-password', () {
      test('redirects authenticated user to /home', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: authenticatedState,
          currentLocation: '/forgot-password',
        );

        // Assert
        expect(result, equals('/home'));
      });

      test('allows unauthenticated user to access', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: unauthenticatedState,
          currentLocation: '/forgot-password',
        );

        // Assert
        expect(result, isNull);
      });
    });

    group('Password recovery state', () {
      test('redirects to /reset-password when on splash screen', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: passwordRecoveryState,
          currentLocation: '/',
        );

        // Assert
        expect(result, equals('/reset-password'));
      });

      test('redirects to /reset-password when on login', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: passwordRecoveryState,
          currentLocation: '/login',
        );

        // Assert
        expect(result, equals('/reset-password'));
      });

      test('redirects to /reset-password when on home', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: passwordRecoveryState,
          currentLocation: '/home',
        );

        // Assert
        expect(result, equals('/reset-password'));
      });

      test('stays on /reset-password when already there', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: passwordRecoveryState,
          currentLocation: '/reset-password',
        );

        // Assert - Should stay on reset-password screen
        expect(result, isNull);
      });
    });

    group('Public route - /reset-password', () {
      test('redirects authenticated user to /home', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: authenticatedState,
          currentLocation: '/reset-password',
        );

        // Assert
        expect(result, equals('/home'));
      });

      test('allows unauthenticated user to access', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: unauthenticatedState,
          currentLocation: '/reset-password',
        );

        // Assert
        expect(result, isNull);
      });
    });

    group('Protected routes - /home', () {
      test('allows authenticated user to access', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: authenticatedState,
          currentLocation: '/home',
        );

        // Assert
        expect(result, isNull);
      });

      test('redirects unauthenticated user to /login', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: unauthenticatedState,
          currentLocation: '/home',
        );

        // Assert
        expect(result, equals('/login'));
      });
    });

    group('Protected routes - other routes', () {
      test('allows authenticated user to access /settings', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: authenticatedState,
          currentLocation: '/settings',
        );

        // Assert
        expect(result, isNull);
      });

      test('redirects unauthenticated user from /settings to /login', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: unauthenticatedState,
          currentLocation: '/settings',
        );

        // Assert
        expect(result, equals('/login'));
      });

      test('allows authenticated user to access /profile', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: authenticatedState,
          currentLocation: '/profile',
        );

        // Assert
        expect(result, isNull);
      });

      test('redirects unauthenticated user from /profile to /login', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: unauthenticatedState,
          currentLocation: '/profile',
        );

        // Assert
        expect(result, equals('/login'));
      });
    });

    group('Edge cases', () {
      test('treats unknown routes as protected', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: unauthenticatedState,
          currentLocation: '/unknown-route',
        );

        // Assert
        expect(result, equals('/login'));
      });

      test('allows authenticated users to access unknown routes', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: authenticatedState,
          currentLocation: '/unknown-route',
        );

        // Assert
        expect(result, isNull);
      });

      test('handles nested routes correctly for authenticated users', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: authenticatedState,
          currentLocation: '/home/notes/123',
        );

        // Assert
        expect(result, isNull);
      });

      test('redirects unauthenticated users from nested routes', () {
        // Arrange & Act
        final result = getRedirectLocation(
          authState: unauthenticatedState,
          currentLocation: '/home/notes/123',
        );

        // Assert
        expect(result, equals('/login'));
      });
    });
  });
}
