/// Signup Screen
///
/// Provides user registration interface for creating new accounts.
/// Follows Bauhaus design principles with geometric forms and clear hierarchy.
///
/// Features:
/// - Email, password, and confirm password validation (inline feedback)
/// - Real-time password strength indicator (weak/medium/strong)
/// - Loading state during account creation
/// - Error handling via snackbars
/// - Success message on account creation
/// - Navigation to login screen
/// - Form validation before submission
///
/// Architecture:
/// - Uses Riverpod for state management (authNotifierProvider)
/// - Uses `Result<T>` pattern for error handling
/// - Listens to authNotifierProvider AsyncValue states
/// - Navigation handled automatically by GoRouter watching authStateStreamProvider
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/presentation/theme/bauhaus_colors.dart';
import '../../../../core/presentation/theme/bauhaus_spacing.dart';
import '../../../../core/presentation/widgets/buttons/bauhaus_elevated_button.dart';
import '../../../../core/presentation/widgets/inputs/bauhaus_text_field.dart';
import '../../../../core/presentation/widgets/snackbars/bauhaus_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/auth_providers.dart';

/// Password strength enumeration
enum PasswordStrength { weak, medium, strong }

/// Signup screen for user registration
///
/// This screen follows Bauhaus design principles:
/// - Sharp geometric forms (no rounded corners)
/// - Clear visual hierarchy
/// - Functional beauty through purposeful design
/// - Accessible touch targets and semantic labels
/// - Real-time password strength feedback
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  // Form controllers and keys
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Validation state
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  // Password strength state
  PasswordStrength _passwordStrength = PasswordStrength.weak;

  @override
  void initState() {
    super.initState();
    // Listen to password changes to update strength indicator and button state
    _passwordController.addListener(_updatePasswordStrength);

    // Listen to all fields to update button state
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);
  }

  /// Updates button state when text changes
  void _updateButtonState() {
    setState(() {
      // Just trigger rebuild to update button enabled/disabled state
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Updates password strength indicator when password changes
  void _updatePasswordStrength() {
    setState(() {
      _passwordStrength = _calculatePasswordStrength(_passwordController.text);
    });
  }

  /// Calculates password strength based on length
  PasswordStrength _calculatePasswordStrength(String password) {
    if (password.length < 8) return PasswordStrength.weak;
    if (password.length < 12) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  /// Validates email format using RFC 5322 compliant regex
  String? _validateEmail(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.loginEmailError;
    }

    // RFC 5322 simplified regex for email validation
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(value.trim())) {
      return l10n.loginEmailError;
    }

    return null;
  }

  /// Validates password length (minimum 6 characters for Supabase)
  String? _validatePassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.loginPasswordError;
    }

    if (value.length < 6) {
      return l10n.loginPasswordError;
    }

    return null;
  }

  /// Validates confirm password matches password
  String? _validateConfirmPassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.loginPasswordError;
    }

    if (value != _passwordController.text) {
      return l10n.signupPasswordMismatch;
    }

    return null;
  }

  /// Handles form submission and sign up
  Future<void> _handleSignUp() async {
    final l10n = AppLocalizations.of(context);

    // Clear previous errors
    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    // Validate form
    final emailError = _validateEmail(_emailController.text, l10n);
    final passwordError = _validatePassword(_passwordController.text, l10n);
    final confirmPasswordError = _validateConfirmPassword(_confirmPasswordController.text, l10n);

    if (emailError != null || passwordError != null || confirmPasswordError != null) {
      setState(() {
        _emailError = emailError;
        _passwordError = passwordError;
        _confirmPasswordError = confirmPasswordError;
      });
      return;
    }

    // Perform sign up
    final authNotifier = ref.read(authProvider.notifier);
    final result = await authNotifier.signUp(email: _emailController.text.trim(), password: _passwordController.text);

    // Handle result
    if (!mounted) return;

    result.when(
      success: (_) {
        // Show success message
        BauhausSnackbar.success(context: context, message: l10n.signupSuccess);
        // Navigation handled automatically by GoRouter watching authStateStreamProvider
      },
      failure: (error) {
        // Show error snackbar
        BauhausSnackbar.error(context: context, message: error.message);
      },
    );
  }

  /// Checks if form is valid for enabling/disabling submit button
  bool _isFormValid(AppLocalizations l10n) {
    // Only enable button if all fields are filled and validation passes
    if (_emailController.text.trim().isEmpty) return false;
    if (_passwordController.text.isEmpty) return false;
    if (_confirmPasswordController.text.isEmpty) return false;

    // Check validation
    if (_validateEmail(_emailController.text, l10n) != null) return false;
    if (_validatePassword(_passwordController.text, l10n) != null) return false;
    if (_validateConfirmPassword(_confirmPasswordController.text, l10n) != null) return false;

    return true;
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
                _SignupHeader(l10n: l10n),
                SizedBox(height: BauhausSpacing.xxLarge),

                // Signup Form
                _SignupForm(
                  l10n: l10n,
                  formKey: _formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  emailError: _emailError,
                  passwordError: _passwordError,
                  confirmPasswordError: _confirmPasswordError,
                  passwordStrength: _passwordStrength,
                  onEmailChanged: (_) {
                    if (_emailError != null) {
                      setState(() {
                        _emailError = null;
                      });
                    }
                  },
                  onPasswordChanged: (_) {
                    if (_passwordError != null) {
                      setState(() {
                        _passwordError = null;
                      });
                    }
                  },
                  onConfirmPasswordChanged: (_) {
                    if (_confirmPasswordError != null) {
                      setState(() {
                        _confirmPasswordError = null;
                      });
                    }
                  },
                ),
                SizedBox(height: BauhausSpacing.large),

                // Sign Up Button
                BauhausElevatedButton(
                  label: l10n.signupButton,
                  onPressed: _isFormValid(l10n) && !authState.isLoading ? _handleSignUp : null,
                  isLoading: authState.isLoading,
                  fullWidth: true,
                ),
                SizedBox(height: BauhausSpacing.xLarge),

                // Login Link
                _LoginLink(l10n: l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Private widget for signup header section
class _SignupHeader extends StatelessWidget {
  final AppLocalizations l10n;

  const _SignupHeader({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          l10n.signupTitle,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w300),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: BauhausSpacing.small),
        Container(width: 60, height: 4, color: colorScheme.primary),
      ],
    );
  }
}

/// Private widget for signup form fields
class _SignupForm extends StatelessWidget {
  final AppLocalizations l10n;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final PasswordStrength passwordStrength;
  final ValueChanged<String>? onEmailChanged;
  final ValueChanged<String>? onPasswordChanged;
  final ValueChanged<String>? onConfirmPasswordChanged;

  const _SignupForm({
    required this.l10n,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    required this.passwordStrength,
    this.onEmailChanged,
    this.onPasswordChanged,
    this.onConfirmPasswordChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          _EmailField(l10n: l10n, controller: emailController, error: emailError, onChanged: onEmailChanged),
          SizedBox(height: BauhausSpacing.medium),

          // Password Field
          _PasswordField(l10n: l10n, controller: passwordController, error: passwordError, onChanged: onPasswordChanged),
          SizedBox(height: BauhausSpacing.small),

          // Password Strength Indicator
          _PasswordStrengthIndicator(l10n: l10n, strength: passwordStrength),
          SizedBox(height: BauhausSpacing.medium),

          // Confirm Password Field
          _ConfirmPasswordField(l10n: l10n, controller: confirmPasswordController, error: confirmPasswordError, onChanged: onConfirmPasswordChanged),
        ],
      ),
    );
  }
}

/// Private widget for email input field
class _EmailField extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController controller;
  final String? error;
  final ValueChanged<String>? onChanged;

  const _EmailField({required this.l10n, required this.controller, this.error, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BauhausTextField(
          key: const Key('signup_email_field'),
          label: l10n.signupEmailLabel,
          controller: controller,
          keyboardType: TextInputType.emailAddress,
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

/// Private widget for password input field
class _PasswordField extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController controller;
  final String? error;
  final ValueChanged<String>? onChanged;

  const _PasswordField({required this.l10n, required this.controller, this.error, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BauhausTextField(
          key: const Key('signup_password_field'),
          label: l10n.signupPasswordLabel,
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
          key: const Key('signup_confirm_password_field'),
          label: l10n.signupConfirmPasswordLabel,
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

/// Private widget for password strength indicator
///
/// Shows a colored bar and text label indicating password strength:
/// - Weak (Red): < 8 characters
/// - Medium (Yellow): 8-11 characters
/// - Strong (Blue): >= 12 characters
class _PasswordStrengthIndicator extends StatelessWidget {
  final AppLocalizations l10n;
  final PasswordStrength strength;

  const _PasswordStrengthIndicator({required this.l10n, required this.strength});

  /// Gets the color for the strength indicator bar
  Color _getStrengthColor(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    switch (strength) {
      case PasswordStrength.weak:
        return colorScheme.error; // Red
      case PasswordStrength.medium:
        return isDark ? BauhausColors.darkYellow : BauhausColors.yellow; // Yellow
      case PasswordStrength.strong:
        return colorScheme.primary; // Blue
    }
  }

  /// Gets the text label for the strength
  String _getStrengthLabel() {
    switch (strength) {
      case PasswordStrength.weak:
        return l10n.signupPasswordStrengthWeak;
      case PasswordStrength.medium:
        return l10n.signupPasswordStrengthMedium;
      case PasswordStrength.strong:
        return l10n.signupPasswordStrengthStrong;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength bar
        Container(
          height: 4,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _getStrengthColor(context),
            border: Border.all(color: colorScheme.outline, width: 1),
          ),
        ),
        SizedBox(height: BauhausSpacing.tight),
        // Strength label
        Text(
          _getStrengthLabel(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _getStrengthColor(context), fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Private widget for login link
class _LoginLink extends StatelessWidget {
  final AppLocalizations l10n;

  const _LoginLink({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${l10n.signupHaveAccount} ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        TextButton(
          onPressed: () {
            context.go('/login');
          },
          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          child: Text(
            l10n.signupLoginLink,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
