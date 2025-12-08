/// Bauhaus Text Field Widget
///
/// A geometric text input field following Bauhaus design principles.
/// Features sharp corners and animated focus state with yellow accent.
///
/// Specifications:
/// - Sharp corners (BorderRadius.zero)
/// - 1px black border normally
/// - 4px yellow left border when focused (animated)
/// - Uses BauhausTypography for text styles
/// - Uses BauhausSpacing for padding
///
/// Usage:
/// ```dart
/// BauhausTextField(
///   label: 'Note Title',
///   controller: titleController,
///   onChanged: (value) => updateTitle(value),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_spacing.dart';

/// Bauhaus-style text field with geometric design and animated focus state
///
/// This text field follows Bauhaus principles:
/// - Sharp geometric forms
/// - Clear visual feedback (yellow accent on focus)
/// - Functional beauty through purposeful animation
/// - High contrast for accessibility
class BauhausTextField extends StatefulWidget {
  /// Label text displayed above or as placeholder
  final String? label;

  /// Placeholder text shown when field is empty
  final String? placeholder;

  /// Text editing controller
  final TextEditingController? controller;

  /// Callback when text changes
  final ValueChanged<String>? onChanged;

  /// Callback when user submits (presses enter/done)
  final ValueChanged<String>? onSubmitted;

  /// Initial value if controller is not provided
  final String? initialValue;

  /// Whether the field is enabled
  final bool enabled;

  /// Maximum number of lines (1 for single line, null for unlimited)
  final int? maxLines;

  /// Minimum number of lines
  final int minLines;

  /// Maximum length of text
  final int? maxLength;

  /// Text input type (email, number, etc.)
  final TextInputType? keyboardType;

  /// Text input action (next, done, etc.)
  final TextInputAction? textInputAction;

  /// Whether to obscure text (for passwords)
  final bool obscureText;

  /// Whether to autocorrect text
  final bool autocorrect;

  /// Whether to enable suggestions
  final bool enableSuggestions;

  /// Input formatters for validation
  final List<TextInputFormatter>? inputFormatters;

  /// Validator function for form validation
  final String? Function(String?)? validator;

  /// Focus node for managing focus
  final FocusNode? focusNode;

  /// Optional suffix icon
  final Widget? suffixIcon;

  /// Optional prefix icon
  final Widget? prefixIcon;

  /// Whether to show the border (default true)
  final bool showBorder;

  /// Custom text style (overrides theme default)
  final TextStyle? textStyle;

  const BauhausTextField({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.initialValue,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.inputFormatters,
    this.validator,
    this.focusNode,
    this.suffixIcon,
    this.prefixIcon,
    this.showBorder = true,
    this.textStyle,
  });

  @override
  State<BauhausTextField> createState() => _BauhausTextFieldState();
}

class _BauhausTextFieldState extends State<BauhausTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get theme colors for dark mode support
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Theme-aware colors
    final backgroundColor = widget.enabled
        ? colorScheme.surface
        : (isDark ? BauhausColors.darkBackground : BauhausColors.neutralGray);
    final borderColor = colorScheme.outline;
    final focusColor = isDark ? BauhausColors.darkYellow : BauhausColors.yellow;
    final labelColor = colorScheme.onSurface;
    final textColor = colorScheme.onSurface;
    final hintColor = colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: labelColor,
                ),
          ),
          const SizedBox(height: BauhausSpacing.small),
        ],

        // Text field with animated border
        Semantics(
          label: widget.label ?? widget.placeholder ?? 'Text input',
          textField: true,
          enabled: widget.enabled,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: widget.showBorder
                ? BoxDecoration(
                    color: backgroundColor,
                    border: Border(
                      // Animated yellow left border on focus
                      left: BorderSide(
                        color: _isFocused ? focusColor : borderColor,
                        width: _isFocused
                            ? BauhausSpacing.borderThick // 4px when focused
                            : BauhausSpacing.borderThin, // 1px normally
                      ),
                      top: BorderSide(
                        color: borderColor,
                        width: BauhausSpacing.borderThin,
                      ),
                      right: BorderSide(
                        color: borderColor,
                        width: BauhausSpacing.borderThin,
                      ),
                      bottom: BorderSide(
                        color: borderColor,
                        width: BauhausSpacing.borderThin,
                      ),
                    ),
                  )
                : BoxDecoration(
                    color: backgroundColor,
                  ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: BauhausSpacing.medium,
                vertical: BauhausSpacing.small,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                initialValue: widget.initialValue,
                enabled: widget.enabled,
                maxLines: widget.maxLines,
                minLines: widget.minLines,
                maxLength: widget.maxLength,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                obscureText: widget.obscureText,
                autocorrect: widget.autocorrect,
                enableSuggestions: widget.enableSuggestions,
                inputFormatters: widget.inputFormatters,
                validator: widget.validator,
                style: widget.textStyle ??
                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColor,
                        ),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: hintColor,
                      ),
                  // Explicitly disable ALL borders - we handle them in the outer Container
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  filled: false, // CRITICAL: Prevent theme's fillColor from overriding
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  // Remove counter text if maxLength is set
                  counterText: '',
                  suffixIcon: widget.suffixIcon,
                  prefixIcon: widget.prefixIcon,
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: BauhausSpacing.iconMedium,
                    minHeight: BauhausSpacing.iconMedium,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: BauhausSpacing.iconMedium,
                    minHeight: BauhausSpacing.iconMedium,
                  ),
                ),
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onSubmitted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
