import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes/features/auth/presentation/screens/login_screen.dart';
import 'package:notes/l10n/app_localizations.dart';

/// Helper to create a widget wrapped with ProviderScope for testing
Widget createTestWidget() {
  return const ProviderScope(
    child: MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en')],
      home: LoginScreen(),
    ),
  );
}

void main() {
  // NOTE: These are simplified widget tests focusing on UI structure and interactions.
  // For full integration testing with mocked providers, more complex setup would be needed
  // with Riverpod 3.0, which is beyond the scope of these basic widget tests.
  //
  // The key behaviors we're testing:
  // 1. UI elements are present and correctly structured
  // 2. Form validation works correctly
  // 3. Password field obscures text
  // 4. Button states change based on input

  group('LoginScreen Widget Tests', () {
    testWidgets('displays login form with email and password fields',
        (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - Find key UI elements
      expect(find.byType(TextField), findsNWidgets(2)); // Email + Password
      expect(find.byType(ElevatedButton), findsOneWidget); // Sign In button
    });

    testWidgets('displays all expected UI elements', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Get localization instance
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      // Assert - Check for text buttons (Forgot Password, Sign Up)
      expect(find.byType(TextButton),
          findsAtLeastNWidgets(2)); // Forgot Password + Sign Up link

      // Check for title
      expect(find.text(l10n.loginTitle), findsOneWidget);
    });

    testWidgets('button is disabled when email is empty', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find email field (first TextField)
      final emailField = find.byType(TextField).first;

      // Enter empty text
      await tester.tap(emailField);
      await tester.enterText(emailField, '');
      await tester.pumpAndSettle();

      // Assert - Button should be disabled
      final signInButton =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(signInButton.onPressed, isNull);
    });

    testWidgets('button is disabled when email format is invalid',
        (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter invalid email
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'invalid-email');
      await tester.pumpAndSettle();

      // Assert - Button should be disabled with invalid email
      final signInButton =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(signInButton.onPressed, isNull);
    });

    testWidgets('button is disabled when password is too short',
        (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter valid email but short password
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, '12345'); // Only 5 characters
      await tester.pumpAndSettle();

      // Assert - Button should be disabled with short password
      final signInButton =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(signInButton.onPressed, isNull);
    });

    testWidgets('button exists and can be found', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - Sign in button exists
      final signInButton = find.byType(ElevatedButton);
      expect(signInButton, findsOneWidget);
    });

    testWidgets('obscures password text', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find password field (second TextField)
      final passwordField = find.byType(TextField).last;
      final textFieldWidget = tester.widget<TextField>(passwordField);

      // Assert - Password field should have obscureText = true
      expect(textFieldWidget.obscureText, isTrue);
    });

    testWidgets('displays Forgot Password link', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Get localization instance
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      // Assert
      expect(find.text(l10n.loginForgotPassword), findsOneWidget);
    });

    testWidgets('displays Sign Up link', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Get localization instance
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      // Assert
      expect(find.text(l10n.loginNoAccount), findsOneWidget);
      expect(find.text(l10n.loginSignUpLink), findsOneWidget);
    });
  });
}
