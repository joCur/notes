/// Bauhaus App Bar Widget
///
/// Custom app bar following Bauhaus design principles with sharp corners
/// and geometric accent elements.
///
/// Specifications:
/// - Sharp corners (no border radius)
/// - Geometric accent (yellow line at bottom by default)
/// - Uses BauhausTypography for title
/// - Optional actions list
/// - Leading icon/back button
/// - Minimum 56px height
/// - Theme-aware colors (automatically adapts to light/dark mode)
///
/// Theme Integration:
/// - Background: colorScheme.surface (can override with backgroundColor)
/// - Text: colorScheme.onSurface (can override with textColor)
/// - Bottom border: BauhausColors.yellow (can override with accentColor)
/// - Border (no accent): colorScheme.outline
///
/// Usage:
/// ```dart
/// // Default theme-aware colors
/// BauhausAppBar(
///   title: 'Voice Notes',
///   showBackButton: true,
///   actions: [
///     IconButton(icon: Icon(Icons.search), onPressed: () {}),
///   ],
/// )
///
/// // Override colors for custom styling
/// BauhausAppBar(
///   title: 'Settings',
///   backgroundColor: BauhausColors.lightGray,
///   textColor: BauhausColors.black,
///   accentColor: BauhausColors.red,
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_spacing.dart';
import '../../theme/bauhaus_typography.dart';
import 'bauhaus_app_bar_leading.dart';

/// Bauhaus-style app bar with geometric design
///
/// Features:
/// - 56px minimum height (recommended touch target)
/// - Yellow 4px bottom accent line
/// - Sharp corners and flat design
/// - Optional leading button and actions
/// - Semantic labels for accessibility
/// - Theme-aware colors (uses ColorScheme by default)
class BauhausAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title text displayed in the app bar
  final String title;

  /// Leading widget (typically back button or menu)
  final Widget? leading;

  /// Whether to show the default back button
  final bool showBackButton;

  /// Action widgets displayed at the end of the app bar
  final List<Widget>? actions;

  /// Background color of the app bar (defaults to colorScheme.surface)
  final Color? backgroundColor;

  /// Text color for the title (defaults to colorScheme.onSurface)
  final Color? textColor;

  /// Accent color for the bottom line (defaults to BauhausColors.yellow)
  final Color? accentColor;

  /// Whether to show the accent line at the bottom
  final bool showAccent;

  /// Semantic label for back button (MUST be localized if showBackButton is true)
  final String? backButtonLabel;

  const BauhausAppBar({
    super.key,
    required this.title,
    this.leading,
    this.showBackButton = false,
    this.actions,
    this.backgroundColor,
    this.textColor,
    this.accentColor,
    this.showAccent = true,
    this.backButtonLabel,
  });

  @override
  Size get preferredSize => const Size.fromHeight(BauhausSpacing.recommendedTouchTarget);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Use theme colors as defaults
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;
    final effectiveTextColor = textColor ?? colorScheme.onSurface;
    final effectiveAccentColor = accentColor ?? BauhausColors.yellow;

    return Semantics(
      header: true,
      child: Container(
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          border: Border(
            bottom: BorderSide(
              color: showAccent ? effectiveAccentColor : colorScheme.outline,
              width: showAccent ? BauhausSpacing.borderThick : BauhausSpacing.borderThin,
            ),
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0, // NO elevation - flat design
          shadowColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: effectiveBackgroundColor.computeLuminance() > 0.5
                ? Brightness.dark
                : Brightness.light,
          ),
          leading: BauhausAppBarLeading(
            customLeading: leading,
            showBackButton: showBackButton,
            textColor: effectiveTextColor,
            backButtonLabel: backButtonLabel,
          ),
          title: Text(
            title,
            style: BauhausTypography.screenTitle.copyWith(
              color: effectiveTextColor,
            ),
          ),
          actions: actions,
          centerTitle: false, // Left-aligned per Bauhaus asymmetry
          titleSpacing: BauhausSpacing.medium,
        ),
      ),
    );
  }
}
