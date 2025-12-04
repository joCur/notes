/// Reset Password Screen
///
/// Provides interface for users to create a new password after clicking the
/// reset link from their email. This screen is accessed via deep link.
/// Follows Bauhaus design principles with geometric forms and clear hierarchy.
///
/// Features:
/// - New password and confirm password fields
/// - Password validation (match, minimum length)
/// - Loading state during password reset
/// - Success/error handling via snackbars
/// - Navigation to login on success
/// - Form validation before submission
///
/// Architecture:
/// - Uses Riverpod for state management (authProvider)
/// - Uses `Result<T>` pattern for error handling
/// - Listens to authProvider AsyncValue states
/// - Accessed via deep link (voicenote://reset-password)
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

/// Reset Password screen for creating new password
///
/// This screen follows Bauhaus design principles:
/// - Sharp geometric forms (no rounded corners)
/// - Clear visual hierarchy
/// - Functional beauty through purposeful design
/// - Accessible touch targets and semantic labels
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  // Form controllers
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Validation state
  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Validates password length (minimum 6 characters)
  String? _validatePassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.loginPasswordError;
    }

    if (value.length < 6) {
      return l10n.loginPasswordError;
    }

    return null;
  }

  /// Validates that passwords match
  String? _validateConfirmPassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.loginPasswordError;
    }

    if (value != _newPasswordController.text) {
      return l10n.signupPasswordMismatch;
    }

    return null;
  }

  /// Handles form submission and password reset
  Future<void> _handleResetPassword() async {
    final l10n = AppLocalizations.of(context);

    // Clear previous errors
    setState(() {
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    // Validate form
    final newPasswordError = _validatePassword(_newPasswordController.text, l10n);
    final confirmPasswordError = _validateConfirmPassword(_confirmPasswordController.text, l10n);

    if (newPasswordError != null || confirmPasswordError != null) {
      setState(() {
        _newPasswordError = newPasswordError;
        _confirmPasswordError = confirmPasswordError;
      });
      return;
    }

    // Update password via Supabase
    final authNotifier = ref.read(authProvider.notifier);
    final result = await authNotifier.updatePassword(newPassword: _newPasswordController.text);

    if (!mounted) return;

    // Handle result
    result.when(
      success: (_) async {
        // Show success message
        BauhausSnackbar.success(context: context, message: l10n.resetPasswordSuccess);

        // Sign out the user so they can log in with new password
        await authNotifier.signOut();

        // Navigate to login screen after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go('/login');
          }
        });
      },
      failure: (error) {
        // Show error message
        BauhausSnackbar.error(context: context, message: error.message);
      },
    );
  }

  /// Checks if form is valid for enabling/disabling submit button
  bool _isFormValid(AppLocalizations l10n) {
    return _newPasswordController.text.length >= 6 &&
        _confirmPasswordController.text.isNotEmpty &&
        _newPasswordController.text == _confirmPasswordController.text &&
        _validatePassword(_newPasswordController.text, l10n) == null &&
        _validateConfirmPassword(_confirmPasswordController.text, l10n) == null;
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
                _ResetPasswordHeader(l10n: l10n),
                SizedBox(height: BauhausSpacing.xLarge),

                // New Password Field
                _NewPasswordField(
                  l10n: l10n,
                  controller: _newPasswordController,
                  error: _newPasswordError,
                  onChanged: (_) {
                    if (_newPasswordError != null) {
                      setState(() {
                        _newPasswordError = null;
                      });
                    }
                    setState(() {}); // Update button state
                  },
                ),
                SizedBox(height: BauhausSpacing.medium),

                // Confirm Password Field
                _ConfirmPasswordField(
                  l10n: l10n,
                  controller: _confirmPasswordController,
                  error: _confirmPasswordError,
                  onChanged: (_) {
                    if (_confirmPasswordError != null) {
                      setState(() {
                        _confirmPasswordError = null;
                      });
                    }
                    setState(() {}); // Update button state
                  },
                ),
                SizedBox(height: BauhausSpacing.large),

                // Reset Password Button
                BauhausElevatedButton(
                  label: l10n.resetPasswordButton,
                  onPressed: _isFormValid(l10n) && !authState.isLoading ? _handleResetPassword : null,
                  isLoading: authState.isLoading,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Private widget for reset password header section
class _ResetPasswordHeader extends StatelessWidget {
  final AppLocalizations l10n;

  const _ResetPasswordHeader({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          l10n.resetPasswordTitle,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w300),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: BauhausSpacing.small),
        Container(width: 60, height: 4, color: colorScheme.primary),
      ],
    );
  }
}

/// Private widget for new password input field
class _NewPasswordField extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController controller;
  final String? error;
  final ValueChanged<String>? onChanged;

  const _NewPasswordField({required this.l10n, required this.controller, this.error, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BauhausTextField(
          label: l10n.resetPasswordNewLabel,
          controller: controller,
          obscureText: true,
          textInputAction: TextInputAction.next,
          onChanged: onChanged,
          enabled: true,
        ),
        if (error != null) ...[
          SizedBox(height: BauhausSpacing.small),
          Text(error!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.error)),
        ],
      ],
    );
  }
}

/// Private widget for confirm password input field
class _ConfirmPasswordField extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController controller;
  final String? error;
  final ValueChanged<String>? onChanged;

  const _ConfirmPasswordField({required this.l10n, required this.controller, this.error, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BauhausTextField(
          label: l10n.resetPasswordConfirmLabel,
          controller: controller,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onChanged: onChanged,
          enabled: true,
        ),
        if (error != null) ...[
          SizedBox(height: BauhausSpacing.small),
          Text(error!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.error)),
        ],
      ],
    );
  }
}
