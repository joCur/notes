/// Router redirect logic
///
/// Handles authentication-based redirects in a testable way.
library;

import '../../features/auth/domain/models/auth_state.dart';

/// Determines where to redirect based on authentication state and current location
///
/// Returns the path to redirect to, or null if no redirect is needed.
///
/// Redirect rules:
/// - Splash screen (/) → /home if authenticated, /reset-password if recovery, /login if not
/// - Password recovery state → always /reset-password
/// - Public routes → /home if authenticated, null if not
/// - Protected routes → /login if not authenticated, null if authenticated
/// - Auth loading state → null (stay on current route)
String? getRedirectLocation({
  required AuthState? authState,
  required String currentLocation,
}) {
  // If auth state is still loading, stay on current route
  if (authState == null) {
    return null;
  }

  // Handle password recovery state - always redirect to reset-password screen
  if (authState is PasswordRecovery) {
    if (currentLocation != '/reset-password') {
      return '/reset-password';
    }
    return null; // Already on reset-password screen
  }

  final isAuthenticated = authState is Authenticated;

  // Define public routes (no authentication required)
  const publicRoutes = [
    '/login',
    '/signup',
    '/forgot-password',
    '/reset-password',
  ];

  final isPublicRoute = publicRoutes.contains(currentLocation);

  // If on splash screen
  if (currentLocation == '/') {
    return isAuthenticated ? '/home' : '/login';
  }

  // If on public route
  if (isPublicRoute) {
    // Redirect authenticated users to home
    return isAuthenticated ? '/home' : null;
  }

  // For all other routes (protected), require authentication
  if (!isAuthenticated) {
    return '/login';
  }

  // Allow access to protected route
  return null;
}
