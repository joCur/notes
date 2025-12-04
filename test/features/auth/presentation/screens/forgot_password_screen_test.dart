import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes/features/auth/presentation/screens/forgot_password_screen.dart';
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
      home: ForgotPasswordScreen(),
    ),
  );
}

void main() {
  // NOTE: These are simplified widget tests focusing on UI structure and interactions.
  // Following the same pattern as login_screen_test.dart - no mocking needed for basic UI tests.

  group('ForgotPasswordScreen Widget Tests', () {
    testWidgets('displays all required UI elements', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Get localization instance
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      // Assert - Check for all UI elements
      expect(find.text(l10n.forgotPasswordTitle), findsOneWidget);
      expect(find.text(l10n.forgotPasswordInstructions), findsOneWidget);
      expect(find.text(l10n.forgotPasswordEmailLabel), findsOneWidget);
      expect(find.text(l10n.forgotPasswordButton), findsOneWidget);
      expect(find.text(l10n.forgotPasswordBackToLogin), findsOneWidget);
    });

    testWidgets('button is disabled when email field is empty', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Get localization instance
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      // Assert - Button should be disabled when email is empty
      final elevatedButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text(l10n.forgotPasswordButton),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(elevatedButton.onPressed, isNull);
    });

    testWidgets('button is disabled when email format is invalid',
        (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Get localization instance
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      // Enter invalid email
      final emailField = find.byType(TextField);
      await tester.enterText(emailField, 'invalid-email');
      await tester.pumpAndSettle();

      // Assert - Button should be disabled with invalid email
      final elevatedButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text(l10n.forgotPasswordButton),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(elevatedButton.onPressed, isNull);
    });

    testWidgets('button is enabled when email format is valid', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Get localization instance
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      // Enter valid email
      final emailField = find.byType(TextField);
      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();

      // Assert - Button should be enabled with valid email
      final elevatedButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text(l10n.forgotPasswordButton),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(elevatedButton.onPressed, isNotNull);
    });

    testWidgets('back to login link is tappable', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Get localization instance
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      // Assert - Back to login link should be found
      final backLink = find.text(l10n.forgotPasswordBackToLogin);
      expect(backLink, findsOneWidget);

      // Verify it's wrapped in a TextButton (tappable)
      final textButton = find.ancestor(
        of: backLink,
        matching: find.byType(TextButton),
      );
      expect(textButton, findsOneWidget);
    });

    testWidgets('displays email input field', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('email field accepts text input', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter text in email field
      final emailField = find.byType(TextField);
      await tester.enterText(emailField, 'user@example.com');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('user@example.com'), findsOneWidget);
    });
  });
}
