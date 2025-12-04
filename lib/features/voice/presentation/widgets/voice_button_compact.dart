/// Compact Voice Recording Button Widget
///
/// Smaller 48x48 version of the voice recording button for use in app bars or toolbars.
///
/// Specifications:
/// - 48x48 touch target with 40x40 circular button
/// - Bauhaus Red background when active (dark mode variant in dark theme)
/// - Bauhaus Blue background when idle (dark mode variant in dark theme)
/// - 2px border (black in light mode, gray in dark mode)
/// - White microphone icon (20px)
/// - Subtle pulsing animation when recording
/// - Haptic feedback on press (light impact)
/// - Semantic labels for accessibility
///
/// Usage:
/// ```dart
/// VoiceRecordingButtonCompact(
///   isRecording: _isRecording,
///   onPressed: _toggleRecording,
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../l10n/app_localizations.dart';

/// Compact voice button for use in app bars or toolbars
///
/// Smaller 48x48 version of the voice recording button with
/// dark mode support and subtle animations.
class VoiceRecordingButtonCompact extends StatelessWidget {
  /// Whether the button is currently in recording state
  final bool isRecording;

  /// Callback when button is pressed
  final VoidCallback onPressed;

  /// Whether the button is enabled
  final bool enabled;

  const VoiceRecordingButtonCompact({
    super.key,
    required this.isRecording,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Use theme colors for automatic dark mode support
    final backgroundColor = enabled
        ? (isRecording
            ? colorScheme.secondary  // Red when recording
            : colorScheme.primary)   // Blue when idle
        : colorScheme.surfaceContainerHighest; // Gray when disabled

    final borderColor = colorScheme.outline;
    final iconColor = colorScheme.onPrimary;

    return Semantics(
      label: isRecording ? l10n.voiceButtonStopRecording : l10n.voiceButtonStartRecording,
      button: true,
      enabled: enabled,
      child: IconButton(
        onPressed: enabled
            ? () {
                HapticFeedback.lightImpact();
                onPressed();
              }
            : null,
        icon: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor,
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
          ),
          child: Icon(
            Icons.mic,
            size: 20,
            color: iconColor,
          ),
        ).animate(
          onPlay: (controller) {
            if (isRecording) {
              controller.repeat();
            }
          },
        ).scale(
          duration: 1500.ms,
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.05, 1.05),
          curve: Curves.easeInOut,
        ).then().scale(
          duration: 1500.ms,
          begin: const Offset(1.05, 1.05),
          end: const Offset(1.0, 1.0),
          curve: Curves.easeInOut,
        ),
      ),
    );
  }
}
