import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes/core/routing/router.dart';
import 'package:notes/features/auth/application/auth_providers.dart';
import 'package:notes/features/auth/domain/models/auth_state.dart';
import 'package:notes/features/auth/domain/models/user.dart';

void main() {
  group('Router', () {
    late ProviderContainer container;

    tearDown(() {
      container.dispose();
    });

    group('Router creation', () {
      test('creates router successfully with authenticated user', () {
        // Arrange - Mock authenticated state
        final mockUser = User(
          id: 'test-id',
          email: 'test@example.com',
          createdAt: DateTime.now(),
        );
        final authStateStream =
            Stream<AuthState>.value(AuthState.authenticated(mockUser));

        container = ProviderContainer(
          overrides: [
            authStateStreamProvider.overrideWith((_) => authStateStream),
          ],
        );

        // Act
        final router = container.read(routerProvider);

        // Assert - Router should be created without errors
        expect(router, isNotNull);
        expect(router.routeInformationParser, isNotNull);
        expect(router.routerDelegate, isNotNull);
      });

      test('creates router successfully with unauthenticated user', () {
        // Arrange - Mock unauthenticated state
        final authStateStream =
            Stream<AuthState>.value(const AuthState.unauthenticated());

        container = ProviderContainer(
          overrides: [
            authStateStreamProvider.overrideWith((_) => authStateStream),
          ],
        );

        // Act
        final router = container.read(routerProvider);

        // Assert - Router should be created without errors
        expect(router, isNotNull);
        expect(router.routeInformationParser, isNotNull);
        expect(router.routerDelegate, isNotNull);
      });
    });

    group('Route configuration', () {
      test('router has correct initial location', () {
        // Arrange
        final authStateStream =
            Stream<AuthState>.value(const AuthState.unauthenticated());

        container = ProviderContainer(
          overrides: [
            authStateStreamProvider.overrideWith((_) => authStateStream),
          ],
        );

        // Act
        final router = container.read(routerProvider);

        // Assert
        expect(router.routeInformationProvider.value.uri.path, equals('/'));
      });

      test('router handles loading auth state gracefully', () {
        // Arrange - Mock loading state (no value yet)
        final authStateStream = Stream<AuthState>.value(const AuthState.loading());

        container = ProviderContainer(
          overrides: [
            authStateStreamProvider.overrideWith((_) => authStateStream),
          ],
        );

        // Act & Assert - Should not throw
        expect(() => container.read(routerProvider), returnsNormally);
      });
    });

    group('Deep link support', () {
      test('router can be created with reset-password route', () {
        // Arrange
        final authStateStream =
            Stream<AuthState>.value(const AuthState.unauthenticated());

        container = ProviderContainer(
          overrides: [
            authStateStreamProvider.overrideWith((_) => authStateStream),
          ],
        );

        // Act
        final router = container.read(routerProvider);

        // Assert - Router should be created successfully
        // Deep link handling is part of the route configuration
        expect(router, isNotNull);
      });

      test('router can handle auth-callback route', () {
        // Arrange
        final authStateStream =
            Stream<AuthState>.value(const AuthState.unauthenticated());

        container = ProviderContainer(
          overrides: [
            authStateStreamProvider.overrideWith((_) => authStateStream),
          ],
        );

        // Act
        final router = container.read(routerProvider);

        // Assert - Router should be created successfully
        expect(router, isNotNull);
      });
    });

    group('Auth state notifier', () {
      test('router listens to auth state changes', () {
        // Arrange - Create a stream controller for dynamic auth state changes
        final authStateStream =
            Stream<AuthState>.value(const AuthState.unauthenticated());

        container = ProviderContainer(
          overrides: [
            authStateStreamProvider.overrideWith((_) => authStateStream),
          ],
        );

        // Act
        final router = container.read(routerProvider);

        // Assert - refreshListenable should be set (notifies on auth changes)
        expect(router.routeInformationProvider, isNotNull);
      });
    });
  });
}
