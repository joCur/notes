/// Voice Recording Button Widget
///
/// Large geometric button for voice recording following Bauhaus design principles.
///
/// Specifications:
/// - 100x100 circular button
/// - Bauhaus Red background when active (dark mode variant in dark theme)
/// - Bauhaus Blue background when idle (dark mode variant in dark theme)
/// - 2px border (black in light mode, gray in dark mode)
/// - White microphone icon (40px)
/// - Pulsing animation when recording
/// - Haptic feedback on press
/// - Semantic labels for accessibility
/// - 48x48 minimum touch target (exceeded by 100x100 size)
/// - Full dark mode support
///
/// Usage:
/// ```dart
/// VoiceRecordingButton(
///   isRecording: _isRecording,
///   onPressed: _toggleRecording,
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../l10n/app_localizations.dart';

/// Voice recording button with Bauhaus design and pulsing animation
///
/// Features:
/// - Circular geometric shape
/// - Color changes based on recording state (red = recording, blue = idle)
/// - Pulsing animation when recording
/// - Haptic feedback on press
/// - Accessibility support with semantic labels
class VoiceRecordingButton extends StatelessWidget {
  /// Whether the button is currently in recording state
  final bool isRecording;

  /// Callback when button is pressed
  final VoidCallback onPressed;

  /// Whether the button is enabled
  final bool enabled;

  const VoiceRecordingButton({super.key, required this.isRecording, required this.onPressed, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label: isRecording ? l10n.voiceButtonStopRecording : l10n.voiceButtonStartRecording,
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled
            ? () {
                HapticFeedback.mediumImpact();
                onPressed();
              }
            : null,
        child: _VoiceButtonCircle(isRecording: isRecording, enabled: enabled),
      ),
    );
  }
}

/// Private widget for the circular button with animation
class _VoiceButtonCircle extends StatelessWidget {
  const _VoiceButtonCircle({required this.isRecording, required this.enabled});

  final bool isRecording;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final backgroundColor = enabled
        ? (isRecording
              ? colorScheme
                    .secondary // Red when recording
              : colorScheme.primary) // Blue when idle
        : colorScheme.surfaceContainerHighest; // Gray when disabled

    final borderColor = colorScheme.outline;
    final iconColor = colorScheme.onPrimary;

    return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor,
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Icon(Icons.mic, size: 40, color: iconColor),
        )
        .animate(
          onPlay: (controller) {
            if (isRecording) {
              controller.repeat();
            }
          },
        )
        .scale(duration: 1500.ms, begin: const Offset(1.0, 1.0), end: const Offset(1.1, 1.1), curve: Curves.easeInOut)
        .then()
        .scale(duration: 1500.ms, begin: const Offset(1.1, 1.1), end: const Offset(1.0, 1.0), curve: Curves.easeInOut);
  }
}
