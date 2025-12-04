import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes/features/auth/presentation/screens/signup_screen.dart';
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
      home: SignupScreen(),
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
  // 3. Password strength indicator updates correctly
  // 4. Password fields obscure text
  // 5. Button states change based on input
  // 6. Confirm password validation works

  group('SignupScreen Widget Tests', () {
    testWidgets('displays signup form with email, password, and confirm password fields',
        (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - Find key UI elements
      expect(find.byType(TextField), findsNWidgets(3)); // Email + Password + Confirm Password
      expect(find.byType(ElevatedButton), findsOneWidget); // Create Account button
    });

    testWidgets('displays all expected UI elements', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Get localization instance
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      // Assert - Check for text buttons (Login link)
      expect(find.byType(TextButton), findsAtLeastNWidgets(1)); // Login link

      // Check for title
      expect(find.text(l10n.signupTitle), findsOneWidget);

      // Check for button
      expect(find.text(l10n.signupButton), findsOneWidget);
    });

    group('Form Validation', () {
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
        final signupButton =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(signupButton.onPressed, isNull);
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

        // Assert - Button should be disabled
        final signupButton =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(signupButton.onPressed, isNull);
      });

      testWidgets('button is disabled when password is too short',
          (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Enter valid email but short password
        final emailField = find.byType(TextField).first;
        final passwordField = find.byType(TextField).at(1);

        await tester.enterText(emailField, 'test@example.com');
        await tester.enterText(passwordField, '12345'); // Only 5 characters
        await tester.pumpAndSettle();

        // Assert - Button should be disabled
        final signupButton =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(signupButton.onPressed, isNull);
      });

      testWidgets('button is disabled when passwords do not match', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Enter valid email and password but mismatched confirmation
        final emailField = find.byType(TextField).first;
        final passwordField = find.byType(TextField).at(1);
        final confirmPasswordField = find.byType(TextField).last;

        await tester.enterText(emailField, 'test@example.com');
        await tester.enterText(passwordField, 'password123');
        await tester.enterText(confirmPasswordField, 'password456');
        await tester.pumpAndSettle();

        // Assert - Button should be disabled
        final signupButton =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(signupButton.onPressed, isNull);
      });

      testWidgets('no validation errors when form is valid', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Enter all valid data
        final emailField = find.byType(TextField).first;
        final passwordField = find.byType(TextField).at(1);
        final confirmPasswordField = find.byType(TextField).last;

        await tester.enterText(emailField, 'test@example.com');
        await tester.pumpAndSettle();

        await tester.enterText(passwordField, 'password123');
        await tester.pumpAndSettle();

        await tester.enterText(confirmPasswordField, 'password123');
        await tester.pumpAndSettle();

        // Assert - Sign up button should be enabled (ElevatedButton with onPressed)
        final signupButton =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(signupButton.onPressed, isNotNull);
      });
    });

    group('Password Strength Indicator', () {
      testWidgets('shows weak indicator for password < 8 characters',
          (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Get localization instance
        final l10n = await AppLocalizations.delegate.load(const Locale('en'));

        // Enter short password
        final passwordField = find.byType(TextField).at(1);
        await tester.enterText(passwordField, 'pass12');
        await tester.pumpAndSettle();

        // Assert - Weak strength indicator should be visible
        expect(find.text(l10n.signupPasswordStrengthWeak), findsOneWidget);
      });

      testWidgets('shows medium indicator for password 8-11 characters',
          (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Get localization instance
        final l10n = await AppLocalizations.delegate.load(const Locale('en'));

        // Enter medium length password
        final passwordField = find.byType(TextField).at(1);
        await tester.enterText(passwordField, 'password1');
        await tester.pumpAndSettle();

        // Assert - Medium strength indicator should be visible
        expect(find.text(l10n.signupPasswordStrengthMedium), findsOneWidget);
      });

      testWidgets('shows strong indicator for password >= 12 characters',
          (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Get localization instance
        final l10n = await AppLocalizations.delegate.load(const Locale('en'));

        // Enter long password
        final passwordField = find.byType(TextField).at(1);
        await tester.enterText(passwordField, 'password12345');
        await tester.pumpAndSettle();

        // Assert - Strong strength indicator should be visible
        expect(find.text(l10n.signupPasswordStrengthStrong), findsOneWidget);
      });

      testWidgets('updates strength indicator when password changes',
          (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Get localization instance
        final l10n = await AppLocalizations.delegate.load(const Locale('en'));

        final passwordField = find.byType(TextField).at(1);

        // Start with weak password
        await tester.enterText(passwordField, 'pass');
        await tester.pumpAndSettle();
        expect(find.text(l10n.signupPasswordStrengthWeak), findsOneWidget);

        // Change to medium password
        await tester.enterText(passwordField, 'password1');
        await tester.pumpAndSettle();
        expect(find.text(l10n.signupPasswordStrengthMedium), findsOneWidget);

        // Change to strong password
        await tester.enterText(passwordField, 'password123456');
        await tester.pumpAndSettle();
        expect(find.text(l10n.signupPasswordStrengthStrong), findsOneWidget);
      });
    });

    group('Button States', () {
      testWidgets('signup button is disabled when form is empty', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - Sign up button should be disabled (onPressed is null)
        final signupButton =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(signupButton.onPressed, isNull);
      });

      testWidgets('signup button is disabled when email is invalid', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Enter invalid email but valid passwords
        final emailField = find.byType(TextField).first;
        final passwordField = find.byType(TextField).at(1);
        final confirmPasswordField = find.byType(TextField).last;

        await tester.enterText(emailField, 'invalid-email');
        await tester.enterText(passwordField, 'password123');
        await tester.enterText(confirmPasswordField, 'password123');
        await tester.pumpAndSettle();

        // Assert - Sign up button should be disabled
        final signupButton =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(signupButton.onPressed, isNull);
      });

      testWidgets('signup button is disabled when passwords do not match',
          (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Enter valid email but mismatched passwords
        final emailField = find.byType(TextField).first;
        final passwordField = find.byType(TextField).at(1);
        final confirmPasswordField = find.byType(TextField).last;

        await tester.enterText(emailField, 'test@example.com');
        await tester.enterText(passwordField, 'password123');
        await tester.enterText(confirmPasswordField, 'password456');
        await tester.pumpAndSettle();

        // Assert - Sign up button should be disabled
        final signupButton =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(signupButton.onPressed, isNull);
      });

      testWidgets('signup button is enabled when form is valid', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Enter all valid data
        final emailField = find.byType(TextField).first;
        final passwordField = find.byType(TextField).at(1);
        final confirmPasswordField = find.byType(TextField).last;

        await tester.enterText(emailField, 'test@example.com');
        await tester.enterText(passwordField, 'password123');
        await tester.enterText(confirmPasswordField, 'password123');
        await tester.pumpAndSettle();

        // Assert - Sign up button should be enabled
        final signupButton =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(signupButton.onPressed, isNotNull);
      });
    });

    group('Password Fields', () {
      testWidgets('password field obscures text', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find password field (second TextField)
        final passwordField = find.byType(TextField).at(1);
        final textFieldWidget = tester.widget<TextField>(passwordField);

        // Assert - Password field should have obscureText = true
        expect(textFieldWidget.obscureText, isTrue);
      });

      testWidgets('confirm password field obscures text', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find confirm password field (third TextField)
        final confirmPasswordField = find.byType(TextField).last;
        final textFieldWidget = tester.widget<TextField>(confirmPasswordField);

        // Assert - Confirm password field should have obscureText = true
        expect(textFieldWidget.obscureText, isTrue);
      });
    });

    group('Navigation Links', () {
      testWidgets('displays "Already have an account? Log in" link', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Get localization instance
        final l10n = await AppLocalizations.delegate.load(const Locale('en'));

        // Assert - Note: The UI adds a space after signupHaveAccount
        expect(find.text('${l10n.signupHaveAccount} '), findsOneWidget);
        expect(find.text(l10n.signupLoginLink), findsOneWidget);
      });
    });
  });
}
