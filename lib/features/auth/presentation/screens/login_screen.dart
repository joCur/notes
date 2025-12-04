/// Login Screen
///
/// Provides authentication interface for users to sign in with email and password.
/// Follows Bauhaus design principles with geometric forms and clear hierarchy.
///
/// Features:
/// - Email and password validation (inline feedback)
/// - Loading state during authentication
/// - Error handling via snackbars
/// - Navigation to signup and forgot password screens
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
import '../../../../core/presentation/theme/bauhaus_spacing.dart';
import '../../../../core/presentation/widgets/buttons/bauhaus_elevated_button.dart';
import '../../../../core/presentation/widgets/inputs/bauhaus_text_field.dart';
import '../../../../core/presentation/widgets/snackbars/bauhaus_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/auth_providers.dart';

/// Login screen for user authentication
///
/// This screen follows Bauhaus design principles:
/// - Sharp geometric forms (no rounded corners)
/// - Clear visual hierarchy
/// - Functional beauty through purposeful design
/// - Accessible touch targets and semantic labels
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Form controllers and keys
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Validation state
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    // Listen to all fields to update button state
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

  /// Handles form submission and sign in
  Future<void> _handleSignIn() async {
    final l10n = AppLocalizations.of(context);

    // Clear previous errors
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // Validate form
    final emailError = _validateEmail(_emailController.text, l10n);
    final passwordError = _validatePassword(_passwordController.text, l10n);

    if (emailError != null || passwordError != null) {
      setState(() {
        _emailError = emailError;
        _passwordError = passwordError;
      });
      return;
    }

    // Perform sign in
    final authNotifier = ref.read(authProvider.notifier);
    final result = await authNotifier.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    // Handle result
    if (!mounted) return;

    result.when(
      success: (_) {
        // Navigation handled automatically by GoRouter watching authStateStreamProvider
        // No manual navigation needed here
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
        _passwordController.text.length >= 6 &&
        _validateEmail(_emailController.text, l10n) == null &&
        _validatePassword(_passwordController.text, l10n) == null;
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
                _LoginHeader(l10n: l10n),
                SizedBox(height: BauhausSpacing.xxLarge),

                // Login Form
                _LoginForm(
                  l10n: l10n,
                  formKey: _formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  emailError: _emailError,
                  passwordError: _passwordError,
                  onEmailChanged: (_) {
                    setState(() {
                      if (_emailError != null) {
                        _emailError = null;
                      }
                    });
                  },
                  onPasswordChanged: (_) {
                    setState(() {
                      if (_passwordError != null) {
                        _passwordError = null;
                      }
                    });
                  },
                ),
                SizedBox(height: BauhausSpacing.large),

                // Sign In Button
                BauhausElevatedButton(
                  label: l10n.loginButton,
                  onPressed: _isFormValid(l10n) && !authState.isLoading
                      ? _handleSignIn
                      : null,
                  isLoading: authState.isLoading,
                  fullWidth: true,
                ),
                SizedBox(height: BauhausSpacing.medium),

                // Forgot Password Link
                _ForgotPasswordLink(l10n: l10n),
                SizedBox(height: BauhausSpacing.xLarge),

                // Sign Up Link
                _SignUpLink(l10n: l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Private widget for login header section
class _LoginHeader extends StatelessWidget {
  final AppLocalizations l10n;

  const _LoginHeader({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          l10n.loginTitle,
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

/// Private widget for login form fields
class _LoginForm extends StatelessWidget {
  final AppLocalizations l10n;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? emailError;
  final String? passwordError;
  final ValueChanged<String>? onEmailChanged;
  final ValueChanged<String>? onPasswordChanged;

  const _LoginForm({
    required this.l10n,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    this.emailError,
    this.passwordError,
    this.onEmailChanged,
    this.onPasswordChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          _EmailField(
            l10n: l10n,
            controller: emailController,
            error: emailError,
            onChanged: onEmailChanged,
          ),
          SizedBox(height: BauhausSpacing.medium),

          // Password Field
          _PasswordField(
            l10n: l10n,
            controller: passwordController,
            error: passwordError,
            onChanged: onPasswordChanged,
          ),
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

  const _EmailField({
    required this.l10n,
    required this.controller,
    this.error,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BauhausTextField(
          label: l10n.loginEmailLabel,
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: onChanged,
          enabled: true,
        ),
        if (error != null) ...[
          SizedBox(height: BauhausSpacing.small),
          Text(
            error!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
          ),
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

  const _PasswordField({
    required this.l10n,
    required this.controller,
    this.error,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BauhausTextField(
          label: l10n.loginPasswordLabel,
          controller: controller,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onChanged: onChanged,
          enabled: true,
        ),
        if (error != null) ...[
          SizedBox(height: BauhausSpacing.small),
          Text(
            error!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
          ),
        ],
      ],
    );
  }
}

/// Private widget for forgot password link
class _ForgotPasswordLink extends StatelessWidget {
  final AppLocalizations l10n;

  const _ForgotPasswordLink({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          context.go('/forgot-password');
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: BauhausSpacing.small,
            vertical: BauhausSpacing.small,
          ),
        ),
        child: Text(
          l10n.loginForgotPassword,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

/// Private widget for sign up link
class _SignUpLink extends StatelessWidget {
  final AppLocalizations l10n;

  const _SignUpLink({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.loginNoAccount,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: () {
            context.go('/signup');
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            l10n.loginSignUpLink,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
