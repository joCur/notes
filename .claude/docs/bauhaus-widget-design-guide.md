# Bauhaus Widget Design Guide

## Overview

This guide provides comprehensive specifications for implementing widgets in our voice-first note-taking application using Bauhaus design principles. Every widget follows the "form follows function" philosophy—bold, geometric, and purposeful.

## Table of Contents

1. [Design System Foundation](#design-system-foundation)
2. [Color System](#color-system)
3. [Typography System](#typography-system)
4. [Layout Principles](#layout-principles)
5. [Core Widgets](#core-widgets)
6. [Animation Guidelines](#animation-guidelines)
7. [Accessibility Requirements](#accessibility-requirements)
8. [Implementation Patterns](#implementation-patterns)

---

## Design System Foundation

### Philosophy

**Core Principles:**
- **Bold Simplicity**: Every element serves a purpose, no decoration
- **Geometric Purity**: Circles, squares, triangles as primary shapes
- **Visual Hierarchy**: Size, color, and geometry guide users
- **Functional Beauty**: Beauty emerges from perfect function

**What to Avoid:**
- Rounded corners (except circles)
- Gradients and shadows (use flat colors)
- Decorative elements without function
- Skeuomorphic design patterns
- Unnecessary animations

### File Structure

```
lib/
├── design_system/
│   ├── colors.dart              # Color constants
│   ├── typography.dart          # Text styles
│   ├── spacing.dart            # Spacing constants
│   ├── theme.dart              # ThemeData configuration
│   ├── painters/
│   │   ├── geometric_shapes.dart
│   │   ├── background_painter.dart
│   │   └── button_painter.dart
│   └── animations/
│       └── voice_animations.dart
├── widgets/
│   ├── buttons/
│   │   ├── voice_recording_button.dart
│   │   ├── bauhaus_elevated_button.dart
│   │   └── bauhaus_icon_button.dart
│   ├── cards/
│   │   └── note_card.dart
│   ├── inputs/
│   │   ├── bauhaus_search_bar.dart
│   │   └── bauhaus_text_field.dart
│   └── indicators/
│       └── waveform_display.dart
```

---

## Color System

### Primary Palette

```dart
// lib/design_system/colors.dart

import 'package:flutter/material.dart';

class BauhausColors {
  // Primary Bauhaus Colors
  static const Color primaryBlue = Color(0xFF21409A);
  static const Color red = Color(0xFFBE1E2D);
  static const Color yellow = Color(0xFFFFDE17);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Extended Palette
  static const Color neutralGray = Color(0xFFF5F5F5);
  static const Color darkGray = Color(0xFF333333);
  static const Color lightGray = Color(0xFFE0E0E0);

  // Dark Mode Variants
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkPrimaryBlue = Color(0xFF5B7FC9);
  static const Color darkRed = Color(0xFFE53E4D);
  static const Color darkYellow = Color(0xFFFFE75E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
}
```

### Color Usage Rules

**Kandinsky's Color-Shape Associations:**
- **Blue + Circle**: Voice recording button, loading indicators
- **Yellow + Triangle**: Warning indicators, directional cues
- **Red + Square**: Stop actions, important markers

**Usage Guidelines:**
```dart
// ✅ GOOD: Use theme colors for dark mode support
final colorScheme = Theme.of(context).colorScheme;
Container(
  decoration: BoxDecoration(
    color: colorScheme.primary,
    border: Border.all(color: colorScheme.outline, width: 2),
  ),
)

// ⚠️ ACCEPTABLE: Hardcoded colors only for specific design elements
Container(
  decoration: BoxDecoration(
    color: BauhausColors.primaryBlue, // Only if you want the same color in light & dark
    border: Border.all(color: BauhausColors.black, width: 2),
  ),
)

// ❌ BAD: Multiple primary colors on same element
Container(
  decoration: BoxDecoration(
    color: BauhausColors.primaryBlue,
    border: Border.all(color: BauhausColors.red, width: 2),
  ),
)
```

**Dark Mode Support:**
```dart
// Always use theme-aware colors for text, backgrounds, and borders
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;
final isDark = theme.brightness == Brightness.dark;

// Common mappings:
// - Background: colorScheme.surface or colorScheme.surfaceContainerHighest
// - Text: colorScheme.onSurface
// - Secondary text: colorScheme.onSurfaceVariant
// - Borders: colorScheme.outline
// - Primary accent: colorScheme.primary
// - Focus color: isDark ? BauhausColors.darkYellow : BauhausColors.yellow
```

### Accessibility Compliance

All color combinations meet WCAG AA standards:

| Foreground | Background | Contrast Ratio | Level |
|------------|------------|----------------|-------|
| Black | White | 21:1 | AAA |
| Primary Blue | White | 8.6:1 | AAA |
| Red | White | 5.74:1 | AA |
| Yellow | Black | 14.09:1 | AAA |

---

## Typography System

### Font Configuration

```dart
// lib/design_system/typography.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BauhausTypography {
  static TextTheme get textTheme => TextTheme(
    displayLarge: GoogleFonts.jost(
      fontSize: 57,
      fontWeight: FontWeight.w300,
      letterSpacing: 0,
      height: 1.12,
    ),
    displayMedium: GoogleFonts.jost(
      fontSize: 45,
      fontWeight: FontWeight.w300,
      letterSpacing: 0,
      height: 1.16,
    ),
    displaySmall: GoogleFonts.jost(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.22,
    ),
    headlineLarge: GoogleFonts.jost(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.25,
    ),
    headlineMedium: GoogleFonts.jost(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.29,
    ),
    headlineSmall: GoogleFonts.jost(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 1.33,
    ),
    titleLarge: GoogleFonts.jost(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 1.27,
    ),
    titleMedium: GoogleFonts.jost(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.5,
    ),
    titleSmall: GoogleFonts.jost(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.43,
    ),
    bodyLarge: GoogleFonts.jost(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.jost(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
    ),
    bodySmall: GoogleFonts.jost(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
    ),
    labelLarge: GoogleFonts.jost(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
      height: 1.43,
    ),
    labelMedium: GoogleFonts.jost(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
      height: 1.33,
    ),
    labelSmall: GoogleFonts.jost(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
      height: 1.45,
    ),
  );
}
```

### Typography Usage

```dart
// Display styles: Hero text, main titles
Text(
  'Voice Notes',
  style: Theme.of(context).textTheme.displaySmall,
)

// Headlines: Section headers
Text(
  'Recent Notes',
  style: Theme.of(context).textTheme.headlineSmall,
)

// Body: Main content
Text(
  'The meeting starts at 3pm...',
  style: Theme.of(context).textTheme.bodyLarge,
)

// Labels: Buttons, tags (use toUpperCase())
Text(
  'START RECORDING'.toUpperCase(),
  style: Theme.of(context).textTheme.labelMedium,
)
```

---

## Layout Principles

### Spacing System

```dart
// lib/design_system/spacing.dart

class BauhausSpacing {
  static const double tight = 4.0;    // Within components
  static const double small = 8.0;    // Related elements
  static const double medium = 16.0;  // Component separation
  static const double large = 24.0;   // Section separation
  static const double xLarge = 32.0;  // Major divisions
  static const double xxLarge = 48.0; // Screen margins
}
```

### Grid System

```dart
// 8px baseline grid
EdgeInsets.all(BauhausSpacing.small)
EdgeInsets.symmetric(
  horizontal: BauhausSpacing.medium,
  vertical: BauhausSpacing.large,
)

// Always use multiples of 8
SizedBox(height: 24) // ✅ Good
SizedBox(height: 20) // ❌ Bad
```

### Layout Patterns

**Asymmetric Layouts (Preferred):**
```dart
// Left-aligned with geometric accent
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Container(
      width: 4,
      height: 60,
      color: BauhausColors.yellow, // Accent bar
    ),
    SizedBox(width: BauhausSpacing.medium),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Title'),
          Text('Content'),
        ],
      ),
    ),
  ],
)
```

---

## Core Widgets

### 1. Voice Recording Button

**Specification:**
- Shape: Circle (80-100px diameter)
- Color: Bauhaus Red (#BE1E2D)
- Icon: White geometric microphone
- States: Idle, Recording, Processing
- Animation: Pulsing during recording

**Implementation:**

```dart
// lib/widgets/buttons/voice_recording_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../design_system/colors.dart';

class VoiceRecordingButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onPressed;

  const VoiceRecordingButton({
    super.key,
    required this.isRecording,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isRecording ? 'Stop recording' : 'Start recording',
      button: true,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: BauhausColors.red,
            border: Border.all(
              color: BauhausColors.black,
              width: 2,
            ),
          ),
          child: Icon(
            Icons.mic,
            size: 40,
            color: BauhausColors.white,
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
          end: const Offset(1.1, 1.1),
          curve: Curves.easeInOut,
        ).then().scale(
          duration: 1500.ms,
          begin: const Offset(1.1, 1.1),
          end: const Offset(1.0, 1.0),
          curve: Curves.easeInOut,
        ),
      ),
    );
  }
}
```

### 2. Note Card

**Specification:**
- Shape: Rectangle with sharp corners
- Background: White
- Border: 4px colored left edge (tag color)
- Content: Title, preview, tags, timestamp
- Decoration: Subtle geometric shape (10% opacity)

**Implementation:**

```dart
// lib/widgets/cards/note_card.dart

import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';

enum NoteType { voice, manual }

class NoteCard extends StatelessWidget {
  final String title;
  final String preview;
  final List<String> tags;
  final String timestamp;
  final NoteType type;
  final Color accentColor;
  final VoidCallback onTap;

  const NoteCard({
    super.key,
    required this.title,
    required this.preview,
    required this.tags,
    required this.timestamp,
    required this.type,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Note: $title, created $timestamp',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: BauhausSpacing.medium),
          decoration: BoxDecoration(
            color: BauhausColors.white,
            border: Border(
              left: BorderSide(
                color: accentColor,
                width: 4,
              ),
              top: BorderSide(color: BauhausColors.lightGray),
              right: BorderSide(color: BauhausColors.lightGray),
              bottom: BorderSide(color: BauhausColors.lightGray),
            ),
          ),
          child: Stack(
            children: [
              // Geometric background decoration
              Positioned(
                right: 16,
                top: 16,
                child: _buildGeometricShape(),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(BauhausSpacing.medium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildNoteTypeIcon(),
                        SizedBox(width: BauhausSpacing.small),
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: BauhausSpacing.small),
                    Text(
                      preview,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BauhausColors.darkGray,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: BauhausSpacing.medium),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: BauhausSpacing.small,
                            runSpacing: BauhausSpacing.small,
                            children: tags.map((tag) => _buildTagChip(tag, context)).toList(),
                          ),
                        ),
                        Text(
                          timestamp.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteTypeIcon() {
    return Container(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: type == NoteType.voice
            ? CircleIconPainter()
            : TriangleIconPainter(),
      ),
    );
  }

  Widget _buildGeometricShape() {
    return Opacity(
      opacity: 0.1,
      child: Container(
        width: 60,
        height: 60,
        child: CustomPaint(
          painter: type == NoteType.voice
              ? CircleShapePainter(color: accentColor)
              : TriangleShapePainter(color: accentColor),
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BauhausSpacing.small,
        vertical: BauhausSpacing.tight,
      ),
      decoration: BoxDecoration(
        color: BauhausColors.primaryBlue,
        border: Border.all(color: BauhausColors.black, width: 1),
      ),
      child: Text(
        tag.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: BauhausColors.white,
        ),
      ),
    );
  }
}

// Custom painters for geometric shapes
class CircleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = BauhausColors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TriangleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = BauhausColors.black
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CircleShapePainter extends CustomPainter {
  final Color color;

  CircleShapePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TriangleShapePainter extends CustomPainter {
  final Color color;

  TriangleShapePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

### 3. Bauhaus Elevated Button

**Specification:**
- Shape: Rectangle with sharp corners
- No elevation or shadows
- Border: 2px black border
- Label: ALL CAPS with letter spacing
- Minimum touch target: 48px height

**Implementation:**

```dart
// lib/widgets/buttons/bauhaus_elevated_button.dart

import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';

class BauhausElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color? textColor;
  final bool isLoading;

  const BauhausElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF21409A),
    this.textColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48, // Minimum touch target
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor ?? BauhausColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(
              color: BauhausColors.black,
              width: 2,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: BauhausSpacing.large,
            vertical: BauhausSpacing.medium,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? BauhausColors.white,
                  ),
                ),
              )
            : Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: textColor ?? BauhausColors.white,
                    ),
              ),
      ),
    );
  }
}
```

### 4. Search Bar

**Specification:**
- Shape: Rectangle with 1px black border
- Active state: 4px yellow left border
- Icon: Geometric magnifying glass
- Placeholder: Body medium gray text

**Implementation:**

```dart
// lib/widgets/inputs/bauhaus_search_bar.dart

import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';

class BauhausSearchBar extends StatefulWidget {
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  const BauhausSearchBar({
    super.key,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<BauhausSearchBar> createState() => _BauhausSearchBarState();
}

class _BauhausSearchBarState extends State<BauhausSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Search notes',
      textField: true,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: BauhausColors.white,
          border: Border(
            left: BorderSide(
              color: _isFocused ? BauhausColors.yellow : BauhausColors.black,
              width: _isFocused ? 4 : 1,
            ),
            top: BorderSide(color: BauhausColors.black),
            right: BorderSide(color: BauhausColors.black),
            bottom: BorderSide(color: BauhausColors.black),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: BauhausSpacing.medium,
            vertical: BauhausSpacing.small,
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: BauhausColors.darkGray,
                size: 20,
              ),
              SizedBox(width: BauhausSpacing.small),
              Expanded(
                child: TextField(
                  focusNode: _focusNode,
                  onChanged: widget.onChanged,
                  onSubmitted: (_) => widget.onSubmitted?.call(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: widget.placeholder ?? 'Search notes...',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: BauhausColors.darkGray,
                        ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 5. Tag Chip

**Specification:**
- Shape: Rectangle with sharp corners
- Border: 2px black
- Background: Primary Bauhaus color
- Text: ALL CAPS, white, label style
- Optional geometric icon

**Implementation:**

```dart
// lib/widgets/indicators/tag_chip.dart

import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';

enum TagShape { circle, square, triangle }

class TagChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final TagShape? shape;
  final VoidCallback? onTap;
  final bool showIcon;

  const TagChip({
    super.key,
    required this.label,
    this.backgroundColor = const Color(0xFF21409A),
    this.shape,
    this.onTap,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label tag',
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 32,
          padding: EdgeInsets.symmetric(
            horizontal: BauhausSpacing.small,
            vertical: BauhausSpacing.tight,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: BauhausColors.black,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcon && shape != null) ...[
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CustomPaint(
                    painter: _getShapePainter(shape!),
                  ),
                ),
                SizedBox(width: BauhausSpacing.tight),
              ],
              Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: BauhausColors.white,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  CustomPainter _getShapePainter(TagShape shape) {
    switch (shape) {
      case TagShape.circle:
        return CircleIconPainter(color: BauhausColors.white);
      case TagShape.square:
        return SquareIconPainter(color: BauhausColors.white);
      case TagShape.triangle:
        return TriangleIconPainter(color: BauhausColors.white);
    }
  }
}

class CircleIconPainter extends CustomPainter {
  final Color color;

  CircleIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SquareIconPainter extends CustomPainter {
  final Color color;

  SquareIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TriangleIconPainter extends CustomPainter {
  final Color color;

  TriangleIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

### 6. Geometric Background

**Specification:**
- Subtle geometric shapes in background
- 5-10% opacity
- Positioned strategically (not centered)
- Static, no animation

**Implementation:**

```dart
// lib/design_system/painters/background_painter.dart

import 'package:flutter/material.dart';
import '../colors.dart';

class BauhausGeometricBackground extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Large circle - top right
    final circlePaint = Paint()
      ..color = BauhausColors.primaryBlue.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      100,
      circlePaint,
    );

    // Triangle - bottom left
    final trianglePaint = Paint()
      ..color = BauhausColors.yellow.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final trianglePath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.75)
      ..lineTo(size.width * 0.25, size.height * 0.75)
      ..lineTo(size.width * 0.175, size.height * 0.6)
      ..close();

    canvas.drawPath(trianglePath, trianglePaint);

    // Square - left middle
    final squarePaint = Paint()
      ..color = BauhausColors.red.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.05, size.height * 0.35, 70, 70),
      squarePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Usage in screens:
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          CustomPaint(
            painter: BauhausGeometricBackground(),
            child: Container(),
          ),
          // Foreground content
          SafeArea(
            child: YourContent(),
          ),
        ],
      ),
    );
  }
}
```

---

## Animation Guidelines

### Principles

**Bauhaus Animation Philosophy:**
- Minimal and purposeful
- Enhance function, don't decorate
- Respect user motion preferences
- Performance is paramount

### Animation Patterns

#### 1. Voice Button Pulsing

```dart
import 'package:flutter_animate/flutter_animate.dart';

// Continuous pulsing during recording
widget
  .animate(onPlay: (controller) => controller.repeat())
  .scale(
    duration: 1500.ms,
    begin: Offset(1.0, 1.0),
    end: Offset(1.1, 1.1),
    curve: Curves.easeInOut,
  )
  .then()
  .scale(
    duration: 1500.ms,
    begin: Offset(1.1, 1.1),
    end: Offset(1.0, 1.0),
    curve: Curves.easeInOut,
  );
```

#### 2. Card List Entry

```dart
// Staggered slide-in + fade
ListView.builder(
  itemBuilder: (context, index) {
    return NoteCard(...)
      .animate()
      .fadeIn(duration: 300.ms, delay: (50 * index).ms)
      .slideX(
        begin: 0.2,
        end: 0,
        duration: 300.ms,
        delay: (50 * index).ms,
        curve: Curves.easeOut,
      );
  },
)
```

#### 3. Search Bar Focus

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  decoration: BoxDecoration(
    border: Border(
      left: BorderSide(
        color: isFocused ? BauhausColors.yellow : BauhausColors.black,
        width: isFocused ? 4 : 1,
      ),
    ),
  ),
)
```

#### 4. Button Tap Feedback

```dart
GestureDetector(
  onTap: onPressed,
  child: widget
    .animate(
      onPlay: (controller) => controller.forward(),
    )
    .scaleXY(
      begin: 1.0,
      end: 0.98,
      duration: 100.ms,
    )
    .then()
    .scaleXY(
      begin: 0.98,
      end: 1.0,
      duration: 100.ms,
    ),
)
```

### Motion Accessibility

```dart
// Always respect system preferences
class AnimatedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return widget.animate(
      // Skip animations if user prefers reduced motion
      effects: disableAnimations ? [] : [
        FadeEffect(duration: 300.ms),
        SlideEffect(duration: 300.ms),
      ],
    );
  }
}
```

---

## Accessibility Requirements

### Touch Targets

**Minimum sizes:**
- All interactive elements: 48x48px minimum
- Preferred: 56x56px for primary actions
- Voice button: 80-100px (well above minimum)

```dart
// Ensure minimum touch target
InkWell(
  onTap: onPressed,
  child: Container(
    constraints: BoxConstraints(
      minWidth: 48,
      minHeight: 48,
    ),
    child: Center(child: YourWidget()),
  ),
)
```

### Semantic Labels

**All custom painted elements need Semantics:**

```dart
Semantics(
  label: 'Voice recording button',
  hint: 'Double tap to start recording',
  button: true,
  enabled: true,
  child: CustomPaintedButton(),
)
```

### Haptic Feedback

```dart
import 'package:flutter/services.dart';

// Light impact - minor actions
HapticFeedback.lightImpact();

// Medium impact - button taps
HapticFeedback.mediumImpact();

// Heavy impact - important actions (start recording)
HapticFeedback.heavyImpact();

// Selection change - scrolling through options
HapticFeedback.selectionClick();
```

### Screen Reader Support

```dart
// Proper heading hierarchy
Semantics(
  header: true,
  child: Text('Voice Notes', style: displayLarge),
)

// Status announcements
Semantics(
  liveRegion: true,
  child: Text('Recording started'),
)
```

---

## Implementation Patterns

### Theme Setup

```dart
// lib/design_system/theme.dart

import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

class BauhausTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: BauhausColors.primaryBlue,
      onPrimary: BauhausColors.white,
      secondary: BauhausColors.red,
      onSecondary: BauhausColors.white,
      tertiary: BauhausColors.yellow,
      onTertiary: BauhausColors.black,
      error: BauhausColors.red,
      onError: BauhausColors.white,
      background: BauhausColors.white,
      onBackground: BauhausColors.black,
      surface: BauhausColors.white,
      onSurface: BauhausColors.black,
    ),
    textTheme: BauhausTypography.textTheme,
    scaffoldBackgroundColor: BauhausColors.neutralGray,

    // Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: BauhausColors.black, width: 2),
        ),
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: BauhausColors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: BauhausColors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: BauhausColors.yellow, width: 4),
      ),
    ),

    // Card theme
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: BauhausColors.lightGray),
      ),
      color: BauhausColors.white,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: BauhausColors.darkPrimaryBlue,
      onPrimary: BauhausColors.white,
      secondary: BauhausColors.darkRed,
      onSecondary: BauhausColors.white,
      tertiary: BauhausColors.darkYellow,
      onTertiary: BauhausColors.black,
      error: BauhausColors.darkRed,
      onError: BauhausColors.white,
      background: BauhausColors.darkBackground,
      onBackground: BauhausColors.darkTextPrimary,
      surface: BauhausColors.darkSurface,
      onSurface: BauhausColors.darkTextPrimary,
    ),
    textTheme: BauhausTypography.textTheme.apply(
      bodyColor: BauhausColors.darkTextPrimary,
      displayColor: BauhausColors.darkTextPrimary,
    ),
    scaffoldBackgroundColor: BauhausColors.darkBackground,

    // Same button/input/card themes with adjusted colors
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: BauhausColors.white, width: 2),
        ),
      ),
    ),
  );
}

// Usage in main.dart
void main() {
  runApp(
    MaterialApp(
      theme: BauhausTheme.lightTheme,
      darkTheme: BauhausTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: HomeScreen(),
    ),
  );
}
```

### Widget Composition Pattern

```dart
// Build complex widgets from simple geometric primitives

class ComplexNoteWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Layer 1: Background decoration
        Positioned.fill(
          child: CustomPaint(
            painter: BauhausGeometricBackground(),
          ),
        ),

        // Layer 2: Content container
        Container(
          decoration: BoxDecoration(
            color: BauhausColors.white,
            border: Border.all(color: BauhausColors.black, width: 2),
          ),
          child: Column(
            children: [
              // Geometric accent bar
              Container(
                height: 4,
                color: BauhausColors.yellow,
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(BauhausSpacing.medium),
                child: YourContent(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

---

## Common Mistakes to Avoid

### ❌ Don't Do This:

```dart
// Rounded corners
BorderRadius.circular(8)

// Shadows and elevation
elevation: 4

// Gradients
gradient: LinearGradient(...)

// Multiple primary colors together
color: BauhausColors.red,
border: Border.all(color: BauhausColors.yellow)

// Decorative animations
.shimmer().shake().spin()

// Inconsistent spacing
padding: EdgeInsets.all(13)
```

### ✅ Do This Instead:

```dart
// Sharp corners (or circles for specific elements)
BorderRadius.zero

// Flat design, no elevation
elevation: 0

// Solid colors only
color: BauhausColors.primaryBlue

// One primary color, black/white for accents
color: BauhausColors.red,
border: Border.all(color: BauhausColors.black)

// Purposeful, minimal animations
.fadeIn(duration: 300.ms)

// 8px grid system
padding: EdgeInsets.all(16)
```

---

## Testing Checklist

### Visual Testing
- [ ] All spacing uses 8px multiples
- [ ] No rounded corners except circles
- [ ] Color contrast meets WCAG AA
- [ ] Typography follows Jost font system
- [ ] Geometric shapes are sharp and clean

### Interaction Testing
- [ ] Touch targets minimum 48x48px
- [ ] Haptic feedback on all interactions
- [ ] Focus indicators clearly visible
- [ ] Animations respect motion preferences

### Accessibility Testing
- [ ] Screen reader announces all elements
- [ ] Semantic labels on custom painted widgets
- [ ] Keyboard navigation works
- [ ] High contrast mode supported

### Performance Testing
- [ ] CustomPainter uses shouldRepaint correctly
- [ ] Animations run at 60fps
- [ ] No jank during scrolling
- [ ] Battery usage acceptable during recording

---

## Quick Reference

### Color Constants
```dart
BauhausColors.primaryBlue  // #21409A
BauhausColors.red          // #BE1E2D
BauhausColors.yellow       // #FFDE17
BauhausColors.black        // #000000
BauhausColors.white        // #FFFFFF
```

### Spacing Values
```dart
BauhausSpacing.tight    // 4px
BauhausSpacing.small    // 8px
BauhausSpacing.medium   // 16px
BauhausSpacing.large    // 24px
BauhausSpacing.xLarge   // 32px
```

### Typography Quick Access
```dart
Theme.of(context).textTheme.displayLarge    // 57px/300
Theme.of(context).textTheme.headlineSmall   // 24px/500
Theme.of(context).textTheme.bodyLarge       // 16px/400
Theme.of(context).textTheme.labelMedium     // 12px/600 CAPS
```

### Animation Durations
```dart
100.ms   // Micro-interactions (button press)
200.ms   // UI state changes (focus)
300.ms   // Content transitions (fade in)
1500.ms  // Continuous animations (pulse)
```

---

## Resources

### Design System Files
- `/lib/design_system/colors.dart`
- `/lib/design_system/typography.dart`
- `/lib/design_system/spacing.dart`
- `/lib/design_system/theme.dart`

### Widget Library
- `/lib/widgets/buttons/`
- `/lib/widgets/cards/`
- `/lib/widgets/inputs/`
- `/lib/widgets/indicators/`

### References
- [Bauhaus Design System Research](./.claude/research/bauhaus-design-system.md)
- [Flutter CustomPainter Documentation](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html)
- [flutter_animate Package](https://pub.dev/packages/flutter_animate)
- [google_fonts Package](https://pub.dev/packages/google_fonts)

---

## Getting Help

**Questions to ask yourself:**
1. Does this element serve a clear function?
2. Is the geometry pure (circle, square, triangle, rectangle)?
3. Am I using only one primary color per major element?
4. Is spacing a multiple of 8px?
5. Would Herbert Bayer approve?

**When in doubt:**
- Simpler is better
- Geometric over organic
- Function over decoration
- Bold over subtle
- Black and white over color

Remember: **Form follows function**. Every pixel should have a purpose.
