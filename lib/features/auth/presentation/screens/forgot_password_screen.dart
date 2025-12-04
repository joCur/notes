/// Forgot Password Screen
///
/// Provides interface for users to request password reset emails.
/// Follows Bauhaus design principles with geometric forms and clear hierarchy.
///
/// Features:
/// - Email validation (inline feedback)
/// - Loading state during password reset request
/// - Success/error handling via snackbars
/// - Navigation back to login screen
/// - Form validation before submission
///
/// Architecture:
/// - Uses Riverpod for state management (authProvider)
/// - Uses `Result<T>` pattern for error handling
/// - Listens to authProvider AsyncValue states
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/presentation/theme/bauhaus_spacing.dart';
import '../../../../core/presentation/widgets/buttons/bauhaus_elevated_button.dart';
import '../../../../core/presentation/widgets/inputs/bauhaus_text_field.dart';
import '../../../../core/presentation/widgets/snackbars/bauhaus_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/auth_providers.dart';

/// Forgot Password screen for password reset requests
///
/// This screen follows Bauhaus design principles:
/// - Sharp geometric forms (no rounded corners)
/// - Clear visual hierarchy
/// - Functional beauty through purposeful design
/// - Accessible touch targets and semantic labels
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  // Form controller
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen to email field to update button state
    _emailController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Updates button state when text changes
  void _updateButtonState() {
    setState(() {
      // Just trigger rebuild to update button enabled/disabled state
    });
  }

  /// Validates email format using RFC 5322 compliant regex
  String? _validateEmail(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.loginEmailError;
    }

    // RFC 5322 simplified regex for email validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return l10n.loginEmailError;
    }

    return null;
  }

  /// Handles form submission and password reset request
  Future<void> _handleResetPassword() async {
    final l10n = AppLocalizations.of(context);

    // Validate email
    final emailError = _validateEmail(_emailController.text, l10n);
    if (emailError != null) {
      return;
    }

    // Perform password reset
    final authNotifier = ref.read(authProvider.notifier);
    final result =
        await authNotifier.resetPassword(email: _emailController.text.trim());

    // Handle result
    if (!mounted) return;

    result.when(
      success: (_) {
        // Show success snackbar
        BauhausSnackbar.success(
          context: context,
          message: l10n.forgotPasswordSuccess,
        );
      },
      failure: (error) {
        // Show error snackbar
        BauhausSnackbar.error(
          context: context,
          message: error.message,
        );
      },
    );
  }

  /// Checks if form is valid for enabling/disabling submit button
  bool _isFormValid(AppLocalizations l10n) {
    return _emailController.text.trim().isNotEmpty &&
        _validateEmail(_emailController.text, l10n) == null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Watch auth state for loading indicator
    final authState = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(BauhausSpacing.large),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title Section
                _ForgotPasswordHeader(l10n: l10n),
                SizedBox(height: BauhausSpacing.xLarge),

                // Instructions
                _InstructionsText(l10n: l10n),
                SizedBox(height: BauhausSpacing.large),

                // Email Field
                _EmailField(
                  l10n: l10n,
                  controller: _emailController,
                  onChanged: (_) {
                    setState(() {}); // Update button state
                  },
                ),
                SizedBox(height: BauhausSpacing.large),

                // Send Reset Link Button
                BauhausElevatedButton(
                  label: l10n.forgotPasswordButton,
                  onPressed:
                      _isFormValid(l10n) && !authState.isLoading ? _handleResetPassword : null,
                  isLoading: authState.isLoading,
                  fullWidth: true,
                ),
                SizedBox(height: BauhausSpacing.medium),

                // Back to Login Link
                _BackToLoginLink(l10n: l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Private widget for forgot password header section
class _ForgotPasswordHeader extends StatelessWidget {
  final AppLocalizations l10n;

  const _ForgotPasswordHeader({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          l10n.forgotPasswordTitle,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w300,
              ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: BauhausSpacing.small),
        Container(
          width: 60,
          height: 4,
          color: colorScheme.primary,
        ),
      ],
    );
  }
}

/// Private widget for instructions text
class _InstructionsText extends StatelessWidget {
  final AppLocalizations l10n;

  const _InstructionsText({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      l10n.forgotPasswordInstructions,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
      textAlign: TextAlign.center,
    );
  }
}

/// Private widget for email input field
class _EmailField extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const _EmailField({
    required this.l10n,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BauhausTextField(
      label: l10n.forgotPasswordEmailLabel,
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onChanged: onChanged,
      enabled: true,
    );
  }
}

/// Private widget for back to login link
class _BackToLoginLink extends StatelessWidget {
  final AppLocalizations l10n;

  const _BackToLoginLink({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: () {
          context.go('/login');
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: BauhausSpacing.small,
            vertical: BauhausSpacing.small,
          ),
        ),
        child: Text(
          l10n.forgotPasswordBackToLogin,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
