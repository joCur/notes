/// Bauhaus Dialog Widget
///
/// Dialog widget following Bauhaus design principles with sharp corners
/// and bold borders.
///
/// Specifications:
/// - Sharp corners (BorderRadius.zero)
/// - 2px black border
/// - White background (dark mode: darkSurface)
/// - Title using sectionHeader style
/// - Content area
/// - Action buttons at bottom
/// - Optional close button
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => BauhausDialog(
///     title: 'Delete Note?',
///     content: Text('This action cannot be undone.'),
///     actions: [
///       BauhausElevatedButton(
///         label: 'Cancel',
///         onPressed: () => Navigator.pop(context),
///       ),
///       BauhausElevatedButton(
///         label: 'Delete',
///         backgroundColor: BauhausColors.red,
///         onPressed: () => deleteNote(),
///       ),
///     ],
///   ),
/// );
/// ```
library;

import 'package:flutter/material.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_spacing.dart';
import '../../theme/bauhaus_typography.dart';

/// Bauhaus-style dialog with geometric design
///
/// Features:
/// - Sharp corners and bold borders
/// - Flat design (no shadows)
/// - Clear visual hierarchy
/// - Flexible content and action areas
/// - Optional close button
class BauhausDialog extends StatelessWidget {
  /// Dialog title text
  final String title;

  /// Main content widget
  final Widget content;

  /// Action buttons displayed at the bottom
  final List<Widget>? actions;

  /// Whether to show a close button in the top-right
  final bool showCloseButton;

  /// Background color of the dialog
  final Color? backgroundColor;

  /// Border color of the dialog
  final Color borderColor;

  /// Title text color
  final Color? titleColor;

  /// Maximum width of the dialog
  final double maxWidth;

  const BauhausDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.showCloseButton = true,
    this.backgroundColor,
    this.borderColor = BauhausColors.black,
    this.titleColor,
    this.maxWidth = 400,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveBackgroundColor = backgroundColor ??
        (isDark ? BauhausColors.darkSurface : BauhausColors.white);
    final effectiveTitleColor = titleColor ??
        (isDark ? BauhausColors.darkTextPrimary : BauhausColors.black);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.all(BauhausSpacing.large),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          border: Border.all(
            color: borderColor,
            width: BauhausSpacing.borderStandard,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DialogHeader(
              title: title,
              titleColor: effectiveTitleColor,
              showCloseButton: showCloseButton,
            ),
            _DialogContent(content: content),
            if (actions != null && actions!.isNotEmpty)
              _DialogActions(actions: actions!),
          ],
        ),
      ),
    );
  }
}

/// Helper function to show a Bauhaus-styled dialog
///
/// Usage:
/// ```dart
/// await showBauhausDialog(
///   context: context,
///   title: 'Confirm',
///   content: Text('Are you sure?'),
///   actions: [
///     TextButton(
///       onPressed: () => Navigator.pop(context, false),
///       child: Text('NO'),
///     ),
///     TextButton(
///       onPressed: () => Navigator.pop(context, true),
///       child: Text('YES'),
///     ),
///   ],
/// );
/// ```
Future<T?> showBauhausDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  List<Widget>? actions,
  bool showCloseButton = true,
  bool barrierDismissible = true,
  Color? backgroundColor,
  Color borderColor = BauhausColors.black,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => BauhausDialog(
      title: title,
      content: content,
      actions: actions,
      showCloseButton: showCloseButton,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
    ),
  );
}

// Private widget classes

/// Dialog header widget
class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.title,
    required this.titleColor,
    required this.showCloseButton,
  });

  final String title;
  final Color titleColor;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(BauhausSpacing.large),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: BauhausColors.lightGray,
            width: BauhausSpacing.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: BauhausTypography.sectionHeader.copyWith(
                  color: titleColor,
                ),
              ),
            ),
          ),
          if (showCloseButton)
            Semantics(
              label: 'Close dialog',
              button: true,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: EdgeInsets.all(BauhausSpacing.tight),
                  child: Icon(
                    Icons.close,
                    size: BauhausSpacing.iconMedium,
                    color: titleColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Dialog content widget
class _DialogContent extends StatelessWidget {
  const _DialogContent({required this.content});

  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(BauhausSpacing.large),
      child: content,
    );
  }
}

/// Dialog actions widget
class _DialogActions extends StatelessWidget {
  const _DialogActions({required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(BauhausSpacing.large),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: BauhausColors.lightGray,
            width: BauhausSpacing.borderThin,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: _buildActionWidgets(),
      ),
    );
  }

  List<Widget> _buildActionWidgets() {
    final widgets = <Widget>[];
    for (var i = 0; i < actions.length; i++) {
      if (i > 0) {
        widgets.add(SizedBox(width: BauhausSpacing.medium));
      }
      widgets.add(actions[i]);
    }
    return widgets;
  }
}
