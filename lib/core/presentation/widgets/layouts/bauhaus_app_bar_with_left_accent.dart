/// Bauhaus App Bar with Left Accent Widget
///
/// Custom app bar variant with left accent border instead of bottom line.
///
/// Specifications:
/// - Sharp corners (no border radius)
/// - 4px colored left border accent
/// - Uses BauhausTypography for title
/// - Optional actions list
/// - Leading icon/back button with localized label
/// - Minimum 56px height
///
/// Usage:
/// ```dart
/// BauhausAppBarWithLeftAccent(
///   title: 'Settings',
///   accentColor: BauhausColors.red,
///   showBackButton: true,
///   backButtonLabel: l10n.navigateBack,
///   actions: [
///     IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
///   ],
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_spacing.dart';
import '../../theme/bauhaus_typography.dart';
import 'bauhaus_app_bar_leading.dart';

/// Bauhaus-style app bar with left accent bar instead of bottom line
///
/// This variant uses a colored left border instead of a bottom accent line,
/// following alternative Bauhaus layout patterns.
class BauhausAppBarWithLeftAccent extends StatelessWidget implements PreferredSizeWidget {
  /// Title text displayed in the app bar
  final String title;

  /// Leading widget (typically back button or menu)
  final Widget? leading;

  /// Whether to show the default back button
  final bool showBackButton;

  /// Action widgets displayed at the end of the app bar
  final List<Widget>? actions;

  /// Background color of the app bar
  final Color backgroundColor;

  /// Text color for the title
  final Color textColor;

  /// Accent color for the left border
  final Color accentColor;

  /// Semantic label for back button (MUST be localized if showBackButton is true)
  final String? backButtonLabel;

  const BauhausAppBarWithLeftAccent({
    super.key,
    required this.title,
    this.leading,
    this.showBackButton = false,
    this.actions,
    this.backgroundColor = BauhausColors.white,
    this.textColor = BauhausColors.black,
    this.accentColor = BauhausColors.yellow,
    this.backButtonLabel,
  });

  @override
  Size get preferredSize => const Size.fromHeight(BauhausSpacing.recommendedTouchTarget);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            left: BorderSide(
              color: accentColor,
              width: BauhausSpacing.borderThick,
            ),
            bottom: BorderSide(
              color: BauhausColors.lightGray,
              width: BauhausSpacing.borderThin,
            ),
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: backgroundColor.computeLuminance() > 0.5
                ? Brightness.dark
                : Brightness.light,
          ),
          leading: BauhausAppBarLeading(
            customLeading: leading,
            showBackButton: showBackButton,
            textColor: textColor,
            backButtonLabel: backButtonLabel,
          ),
          title: Text(
            title,
            style: BauhausTypography.screenTitle.copyWith(
              color: textColor,
            ),
          ),
          actions: actions,
          centerTitle: false,
          titleSpacing: BauhausSpacing.medium,
        ),
      ),
    );
  }
}
