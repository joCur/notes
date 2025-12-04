/// Router Configuration
///
/// Configures GoRouter with authentication-aware routing and deep link handling.
///
/// Features:
/// - Authentication-based redirects (authenticated → /home, unauthenticated → /login)
/// - Route protection (protected routes require authentication)
/// - Deep link handling (voicenote:// scheme)
/// - Listens to authStateStreamProvider for automatic navigation
///
/// Route Structure:
/// - `/` - Splash screen (initial auth check)
/// - `/login` - Login screen (public)
/// - `/signup` - Signup screen (public)
/// - `/forgot-password` - Forgot password screen (public)
/// - `/reset-password` - Reset password screen (public, deep link target)
/// - `/home` - Home screen (protected, requires authentication)
///
/// Usage:
/// ```dart
/// final router = ref.watch(routerProvider);
/// MaterialApp.router(
///   routerConfig: router,
/// );
/// ```
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notes/core/routing/go_router_refresh_stream.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/domain/models/auth_state.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../presentation/screens/home_page.dart';
import '../presentation/screens/splash_screen.dart';
import 'router_redirect.dart';

part 'router.g.dart';

/// Creates and configures the app router
///
/// The router listens to authentication state changes and handles
/// redirects automatically based on the user's auth state.
@riverpod
GoRouter router(Ref ref) {
  // Create a stream controller to bridge Riverpod's stream to GoRouter
  final controller = StreamController<AuthState>.broadcast();

  // Listen to auth state changes and emit to the controller
  ref.listen<AsyncValue<AuthState>>(authStateStreamProvider, (previous, next) {
    next.whenData((state) => controller.add(state));
  });

  // Convert the stream to a Listenable for GoRouter
  final refreshStream = GoRouterRefreshStream(controller.stream);

  // Clean up when the provider is disposed
  ref.onDispose(() {
    refreshStream.dispose();
    controller.close();
  });

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshStream,
    redirect: (BuildContext context, GoRouterState state) {
      // Get current auth state
      final authStateAsync = ref.read(authStateStreamProvider);
      final authState = authStateAsync.value;

      // Delegate to testable redirect logic
      return getRedirectLocation(authState: authState, currentLocation: state.matchedLocation);
    },
    routes: [
      GoRoute(path: '/', name: 'splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', name: 'login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', name: 'signup', builder: (context, state) => const SignupScreen()),
      GoRoute(path: '/forgot-password', name: 'forgotPassword', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/reset-password', name: 'resetPassword', builder: (context, state) => const ResetPasswordScreen()),
      GoRoute(path: '/home', name: 'home', builder: (context, state) => const HomePage()),
    ],
    errorBuilder: (context, state) => Scaffold(body: Center(child: Text('Page not found: ${state.uri.path}'))),
  );
}
