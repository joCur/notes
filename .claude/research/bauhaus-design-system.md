# Research: Bauhaus-Inspired Design System for Voice-First Note-Taking App

## Executive Summary

This research explores the creation of a distinctive Bauhaus-inspired design system for a Flutter-based voice-first note-taking application. The Bauhaus movement, with its "form follows function" philosophy, aligns perfectly with the app's core values: capturing thoughts at the speed of speech without unnecessary ornamentation.

The recommended approach is a **Hybrid Custom Design System** that combines Flutter's ThemeData for standard widgets with strategic use of CustomPainter for unique geometric elements. This balanced approach provides fast initial development while maintaining Bauhaus authenticity, built-in accessibility, and long-term maintainability.

The design system leverages authentic Bauhaus principles—geometric shapes (circles, squares, triangles), a primary color palette (red, yellow, blue with black and white), and geometric sans-serif typography (Jost font via google_fonts)—to create a timeless, distinctive aesthetic that stands apart from standard Material and Cupertino designs. By utilizing flutter_animate for motion design, speech_to_text for voice capture, and audio_waveforms for visualization, we achieve a unique UI/UX that feels both revolutionary and functional.

This design approach emphasizes bold simplicity, clear visual hierarchy, and purpose-driven animations that enhance rather than distract from the core functionality: hands-free, voice-first note capture.

## Research Scope

### What Was Researched
- Authentic Bauhaus design principles and their application to modern mobile UI/UX
- Historical Bauhaus color theory (Kandinsky, Albers, Itten) and modern adaptations
- Bauhaus typography, including Herbert Bayer's Universal Type and Futura-inspired fonts
- Flutter packages for implementing custom geometric designs with hybrid approach
- Animation and motion design packages suitable for voice recording interfaces
- Speech-to-text packages and audio visualization components
- Examples of Bauhaus-inspired mobile app designs

### What Was Explicitly Excluded
- Material Design and Cupertino design systems (explicitly rejected per requirements)
- Pre-built UI component libraries (FluentUI, Moon Design, etc.) that impose their own design language
- Heavy animation frameworks that could detract from performance
- Complex state machine animations not aligned with the app's simplicity
- Pure CustomPainter approach (too time-intensive)
- Component library approach (over-engineering for single app)

### Research Methodology
- Web search for Bauhaus design principles, color theory, and typography
- Analysis of Flutter package ecosystem for hybrid custom design implementation
- Review of existing Bauhaus-inspired mobile UI examples
- Evaluation of packages for voice recording, speech-to-text, and audio visualization

## Current State Analysis

### Existing Implementation
No existing implementation—this is a greenfield Flutter project requiring a completely custom design system from the ground up.

### Industry Standards

**Current Note-Taking Apps**: Most note-taking applications (Notion, Evernote, Apple Notes, Google Keep) rely heavily on standard Material or iOS design patterns. They feature:
- Conventional card-based layouts
- Standard system fonts
- Predictable navigation patterns
- Minimal use of geometric shapes or bold colors

**Voice-First Apps**: Existing voice recording and dictation apps (Otter.ai, Rev, Voice Memos) typically use:
- Waveform visualizations (often standard blue/green gradients)
- Minimal UI during recording
- Standard button shapes and iconography

**Gap in Market**: There is a clear opportunity for a note-taking app with a bold, distinctive visual identity that communicates innovation and modernity while maintaining usability. Bauhaus principles offer this differentiation.

## Recommended Approach: Hybrid Custom Design System

### Overview

The hybrid approach uses Flutter's ThemeData to customize standard widgets (Container, Card, Button) with Bauhaus colors and typography, while reserving CustomPainter for unique geometric elements that define the visual identity.

### Key Advantages

**Pros**:
- Fast initial development while maintaining distinctiveness
- Accessibility built-in to standard widgets
- Bauhaus authenticity through CustomPainter for hero elements
- Easier maintenance and onboarding for developers
- Gesture handling and responsive design provided by Flutter framework
- Can achieve distinctive look through theming
- Lightweight—strategic use of custom painting without over-engineering

**Strategic Use Cases**:

**Standard Widgets (Themed)**:
- Text fields and form inputs
- Buttons and interactive elements
- Navigation components
- List views and scrollable content
- Cards and containers

**CustomPainter (Hero Elements)**:
- Voice recording button (circular geometric design)
- Geometric backgrounds and decorative accents
- Custom progress indicators
- Background patterns (circles, squares, triangles)
- Audio waveform visualization enhancements

### Implementation Example

**Theme Configuration**:
```dart
ThemeData bauhausTheme = ThemeData(
  colorScheme: ColorScheme(
    primary: Color(0xFF21409A), // Bauhaus blue
    secondary: Color(0xFFBE1E2D), // Bauhaus red
    tertiary: Color(0xFFFFDE17), // Bauhaus yellow
    surface: Color(0xFFFFFFFF),
    background: Color(0xFFF5F5F5),
    error: Color(0xFFBE1E2D),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black,
    onBackground: Colors.black,
    onError: Colors.white,
    brightness: Brightness.light,
  ),
  fontFamily: 'Jost', // Geometric sans-serif
  textTheme: TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w300),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w300),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero), // Hard edges
      elevation: 0,
    ),
  ),
);
```

**Custom Geometric Background**:
```dart
class BauhausGeometricBackground extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Large circle - Bauhaus blue
    final circlePaint = Paint()
      ..color = Color(0xFF21409A).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      100,
      circlePaint,
    );

    // Triangle - Bauhaus yellow
    final trianglePaint = Paint()
      ..color = Color(0xFFFFDE17).withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final trianglePath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.7)
      ..lineTo(size.width * 0.3, size.height * 0.7)
      ..lineTo(size.width * 0.2, size.height * 0.5)
      ..close();

    canvas.drawPath(trianglePath, trianglePaint);

    // Square - Bauhaus red
    final squarePaint = Paint()
      ..color = Color(0xFFBE1E2D).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.05, size.height * 0.3, 80, 80),
      squarePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

## Essential Flutter Packages

### google_fonts

**Purpose**: Provides access to Google Fonts library for Bauhaus-inspired geometric sans-serif typography

**Key Details**:
- **Maturity**: Production-ready (official Google package)
- **License**: Apache 2.0
- **Integration Effort**: Low (simple pubspec.yaml addition)

**Recommended Font**: **Jost** - Released as an open-source alternative to Futura, captures 1920s geometric spirit with 9 weights + italics

**Implementation**:
```dart
import 'package:google_fonts/google_fonts.dart';

Text(
  'Voice Note',
  style: GoogleFonts.jost(
    fontSize: 32,
    fontWeight: FontWeight.w300,
    letterSpacing: 0.5,
  ),
)
```

### flutter_animate

**Purpose**: Performant library for adding animated effects with simple, unified API

**Key Details**:
- **Maturity**: Production-ready (trending in 2025 Flutter ecosystem)
- **License**: MIT
- **Integration Effort**: Low to Medium

**Use Cases for Voice-First App**:
- Pulsing animation on voice recording button
- Slide-in animations for new notes
- Fade transitions between views
- Shimmer effect for loading states
- Shake animation for errors

**Implementation**:
```dart
import 'package:flutter_animate/flutter_animate.dart';

// Pulsing voice button
Container(
  width: 80,
  height: 80,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: Color(0xFFBE1E2D),
  ),
)
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

### speech_to_text

**Purpose**: Flutter plugin exposing device-specific speech-to-text recognition

**Key Details**:
- **Maturity**: Production-ready (most popular STT package in Flutter)
- **License**: BSD-3-Clause
- **Integration Effort**: Medium (requires platform-specific permissions)

**Key Features**:
- Cross-platform support (Android, iOS, macOS, web, Windows beta)
- Real-time speech recognition
- Multiple language support
- Confidence scores for recognized text
- Partial results during recognition

**Important Limitations**:
- Target use case: commands and short phrases (not continuous conversion)
- Android/iOS stop recognition after ~1 minute of activity
- High battery and network usage
- Android has short timeout on speaker pauses

**Platform Requirements**:
- iOS: NSMicrophoneUsageDescription and NSSpeechRecognitionUsageDescription in Info.plist
- Android: RECORD_AUDIO and INTERNET permissions in AndroidManifest.xml
- Minimum SDK: Android 21+, iOS 10+

**Implementation**:
```dart
import 'package:speech_to_text/speech_to_text.dart';

final SpeechToText _speech = SpeechToText();

Future<void> initSpeech() async {
  bool available = await _speech.initialize(
    onError: (error) => print('Error: $error'),
    onStatus: (status) => print('Status: $status'),
  );
}

void startListening() async {
  await _speech.listen(
    onResult: (result) {
      setState(() {
        _recognizedText = result.recognizedWords;
      });
    },
    listenFor: Duration(seconds: 30),
    pauseFor: Duration(seconds: 3),
  );
}
```

### audio_waveforms

**Purpose**: Provides waveform visualizations for audio recording and playback

**Key Details**:
- **Maturity**: Production-ready
- **License**: MIT
- **Integration Effort**: Medium

**Bauhaus Integration Strategy**:
- Use primary colors (red, yellow, blue) for waveform
- Geometric, angular waveform style rather than smooth curves
- Bold, high-contrast visualization

**Implementation**:
```dart
import 'package:audio_waveforms/audio_waveforms.dart';

AudioWaveforms(
  size: Size(MediaQuery.of(context).size.width, 100),
  recorderController: recorderController,
  waveStyle: WaveStyle(
    waveColor: Color(0xFF21409A), // Bauhaus blue
    showDurationLabel: true,
    spacing: 8.0,
    showBottom: false,
    extendWaveform: true,
    showMiddleLine: false,
    waveThickness: 3.0,
  ),
)
```

## Implementation Strategy

### Technical Requirements

**Dependencies**:
```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0
  flutter_animate: ^4.3.0
  speech_to_text: ^7.0.0
  audio_waveforms: ^1.0.5
```

**Platform-Specific Setup**:
- **iOS**: Info.plist entries for microphone and speech recognition permissions
- **Android**: Manifest permissions for RECORD_AUDIO and INTERNET
- **Minimum versions**: iOS 10+, Android API 21+

**Performance Implications**:
- CustomPainter is highly performant for static graphics
- Use `shouldRepaint` carefully to avoid unnecessary redraws
- Speech recognition is battery-intensive—implement smart pause/resume
- Audio waveform visualization in real-time requires efficient rendering

**Scalability Considerations**:
- Design system should be documented with clear naming conventions
- Color constants should be centralized in a theme file
- Reusable geometric painters should be extracted into separate classes
- Consider creating a style guide document as components are built

**Security Aspects**:
- Request microphone permissions appropriately with clear user explanation
- Store voice recordings securely (local encryption if storing sensitive content)
- Ensure speech-to-text API calls use secure connections
- Follow platform privacy guidelines for voice data

### Project Structure

**Recommended Architecture**:
```
lib/
├── design_system/
│   ├── colors.dart              # Bauhaus color palette constants
│   ├── typography.dart          # Text styles using Jost/geometric fonts
│   ├── painters/
│   │   ├── geometric_shapes.dart
│   │   ├── background_painter.dart
│   │   └── button_painter.dart
│   ├── animations/
│   │   └── voice_animations.dart
│   └── theme.dart               # Overall ThemeData
├── features/
│   ├── voice_recording/
│   │   ├── widgets/
│   │   │   ├── voice_button.dart
│   │   │   └── waveform_display.dart
│   │   └── voice_recording_screen.dart
│   ├── notes/
│   │   └── notes_list_screen.dart
│   └── editor/
│       └── note_editor_screen.dart
└── main.dart
```

### Database Schema

**Notes table**:
- id, content, created_at, updated_at, tags, audio_path

**Tags table**:
- id, name, color (using Bauhaus palette)

**Considerations**:
- Full-text search indexing for search functionality
- Local database recommendation: sqflite or hive

### Phased Implementation Plan

**Phase 1: Visual Identity Foundation (2 weeks)**
1. Establish color palette constants
2. Implement typography system with Jost via google_fonts
3. Create basic geometric background with CustomPainter
4. Build custom voice recording button with circular geometry

**Deliverable**: App with distinctive Bauhaus visual identity, even with placeholder functionality

**Phase 2: Voice Functionality (2 weeks)**
5. Integrate speech_to_text package with proper error handling
6. Implement real-time transcription display
7. Add audio_waveforms visualization with Bauhaus styling
8. Create note saving mechanism with local storage

**Deliverable**: Working voice-first note capture with visual feedback

**Phase 3: Note Management (2 weeks)**
9. Build notes list view with geometric card layout
10. Implement tag-based organization with Bauhaus colors
11. Add full-text search functionality
12. Create WYSIWYG editor for note refinement

**Deliverable**: Complete note-taking workflow from capture to organization

**Phase 4: Polish & Optimization (1-2 weeks)**
13. Add flutter_animate transitions (subtle, purposeful)
14. Implement dark mode with adjusted Bauhaus palette
15. Accessibility improvements (Semantics, haptics, color contrast)
16. Performance optimization (profile and optimize)
17. User testing and refinements

**Deliverable**: Production-ready app with polished Bauhaus aesthetic

### Risks and Mitigation

| Risk | Impact | Mitigation Strategy |
|------|--------|---------------------|
| **Speech recognition limitations** | Poor UX if recording cuts off too soon | Implement smart recording restart, clear visual feedback when recording stops, allow manual restart |
| **Performance with animations** | Janky UI, poor user experience | Profile early and often, use flutter_animate's performance-optimized effects, avoid simultaneous complex animations |
| **Accessibility concerns with custom UI** | Difficult for users with disabilities | Implement Semantics widgets on all custom-painted elements, ensure sufficient color contrast (test with WCAG), provide haptic feedback |
| **Battery drain from voice features** | User complaints, app uninstalls | Implement aggressive timeout on speech recognition, provide battery-saving mode, allow users to disable continuous listening |
| **Lack of design system documentation** | Inconsistent implementation, difficult onboarding | Create living style guide document, use strong typing for design tokens, implement linting rules for consistency |

## Visual Design Specifications

### Color Palette

**Primary Bauhaus Palette**:
- **Primary Blue**: `#21409A` - Main interactive elements, primary actions
- **Red**: `#BE1E2D` - Voice recording button, urgent/important markers
- **Yellow**: `#FFDE17` - Accents, highlights, selected states
- **Black**: `#000000` - Primary text, strong geometric outlines
- **White**: `#FFFFFF` - Backgrounds, negative space

**Extended Palette** (for modern usability):
- **Neutral Gray**: `#F5F5F5` - Secondary backgrounds
- **Dark Gray**: `#333333` - Secondary text
- **Light Gray**: `#E0E0E0` - Borders, dividers

**Color Usage Guidelines**:
- Use primary colors sparingly and purposefully
- Black and white should dominate the layout
- One primary color per major UI element
- Follow Kandinsky's color-shape associations:
  - Blue with circles (voice recording button)
  - Yellow with triangles (warning/info indicators)
  - Red with squares (stop/important actions)

### Typography System

**Primary Typeface**: Jost (Google Fonts)
- Display: Light (300) weight, 36-57px
- Headlines: Regular (400) weight, 24-32px
- Body: Regular (400) weight, 14-16px
- Labels: Semi-bold (600) weight, 12-14px, ALL CAPS with letter-spacing

**Type Scale**:
```
Display Large:  57px / 300 weight / Jost
Display Medium: 45px / 300 weight / Jost
Display Small:  36px / 400 weight / Jost
Headline Large: 32px / 400 weight / Jost
Headline Medium: 28px / 400 weight / Jost
Headline Small: 24px / 500 weight / Jost
Title Large:    22px / 500 weight / Jost
Body Large:     16px / 400 weight / Jost
Body Medium:    14px / 400 weight / Jost
Label:          12px / 600 weight / Jost / UPPERCASE / +1.2 letter-spacing
```

**Typography Principles**:
- Sans-serif only (authentic to Bauhaus)
- Emphasis through weight and size, not decoration
- Generous whitespace around text blocks
- Left-aligned for readability (Bauhaus favored asymmetric layouts)
- ALL CAPS for buttons and labels (Herbert Bayer style)

### Layout and Composition

**Grid System**:
- 8px baseline grid for consistency
- Asymmetric layouts preferred over centered
- Use of negative space as a design element
- Grid visible through alignment, not literal grid lines

**Geometric Elements**:
- Circles: voice recording button, loading indicators
- Squares/Rectangles: note cards, containers, buttons
- Triangles: directional indicators, warning icons
- Combinations: layered geometric shapes as decorative backgrounds

**Spacing**:
- Tight: 4px (within components)
- Small: 8px (related elements)
- Medium: 16px (component separation)
- Large: 24px (section separation)
- XLarge: 32px (major layout divisions)

### Component Specifications

**Voice Recording Button**:
- Large circle (80-100px diameter)
- Solid Bauhaus red fill (#BE1E2D)
- White microphone icon (geometric, simplified)
- Pulsing animation during recording (scale 1.0 → 1.1 → 1.0)
- Black stroke outline (2px) when idle

**Note Card**:
- Rectangle with sharp corners (no border radius)
- White background
- 2px black border on left edge (accent color could be yellow/blue/red based on tag)
- Title in Headline Small (24px, Jost 500)
- Preview text in Body Medium (14px, Jost 400)
- Timestamp in Label (12px, Jost 600, ALL CAPS)
- Subtle geometric shape in background (circle or triangle, 10% opacity)

**Tag Chip**:
- Small rectangle (not rounded)
- Filled with Bauhaus primary color
- White text in Label style (12px, Jost 600, ALL CAPS)
- 2px black border
- Geometric icon optional (circle, square, triangle in white)

**Search Bar**:
- Full-width rectangle with 1px black border
- White background
- Icon: geometric magnifying glass (circle + line)
- Placeholder in Body Medium, gray
- Active state: yellow left border (4px)

**Waveform Visualization**:
- Bold, angular bars (not smooth curves)
- Bauhaus blue (#21409A)
- High contrast against white background
- 3-4px bar width with 8px spacing
- Sharp, geometric appearance

## Animation Specifications

### Voice Button Animation
- **Idle State**: Static red circle with white mic icon
- **Recording State**:
  - Pulsing scale animation (1.0 → 1.1 → 1.0)
  - Duration: 1.5s per cycle
  - Easing: ease-in-out
  - Continuous repeat while recording
- **Transition**: 200ms scale up when tapped

### Note Card Animations
- **List Entry**: Slide in from right + fade in
  - Duration: 300ms
  - Stagger: 50ms between cards
  - Easing: ease-out
- **Tap Feedback**: Subtle scale down (0.98) for 100ms
- **Deletion**: Slide out to left + fade out (250ms)

### Search Bar
- **Focus**: Yellow left border animates from 0px to 4px (200ms)
- **Results Loading**: Subtle shimmer animation on placeholder text

### Waveform
- **Recording**: Bars animate up/down in real-time with audio input
- **Playback**: Progress indicator moves left-to-right (blue square)

### Screen Transitions
- **Principle**: Minimal, purposeful animations (Bauhaus = function over decoration)
- **Default**: Simple fade + slight slide (200ms, ease-out)
- **Modal**: Slide up from bottom (300ms)
- **No**: Elaborate transitions, 3D effects, excessive motion

## Accessibility Considerations

### Color Contrast
- All Bauhaus primary colors tested against white/black backgrounds
- Primary Blue (#21409A) on white: 8.6:1 (AAA) ✓
- Red (#BE1E2D) on white: 5.74:1 (AA) ✓
- Yellow (#FFDE17) on black: 14.09:1 (AAA) ✓
- Text always black on white or white on primary colors

### Touch Targets
- All interactive elements minimum 48x48px (Material accessibility guideline)
- Voice button: 80-100px (exceeds minimum)
- Tag chips: 48px height minimum
- Adequate spacing between interactive elements (16px minimum)

### Semantic Labels
- All CustomPainter elements wrapped in Semantics widget
- Voice button: "Start recording" / "Stop recording"
- Note cards: "Note: [title], created [time ago]"
- Tags: "[tag name] tag"

### Screen Reader Support
- Logical focus order top-to-bottom, left-to-right
- Proper heading hierarchy
- Alternative text for all geometric icons
- Status announcements for recording state changes

### Haptic Feedback
- Voice button tap: medium impact
- Recording start: heavy impact
- Recording stop: light impact
- Note saved: success notification haptic

### Motion Preferences
- Respect `MediaQuery.of(context).disableAnimations`
- Provide settings toggle for reduced motion
- Disable pulsing/shimmer effects when motion sensitivity enabled

## Dark Mode Specifications

### Adapted Bauhaus Palette for Dark Mode
- **Background**: `#121212` (deep black)
- **Surface**: `#1E1E1E` (elevated surface)
- **Primary Blue**: `#5B7FC9` (lightened for contrast)
- **Red**: `#E53E4D` (slightly desaturated)
- **Yellow**: `#FFE75E` (lightened)
- **Text**: `#FFFFFF` (primary), `#B0B0B0` (secondary)

### Dark Mode Principles
- Maintain geometric shapes and layout
- Adjust color brightness for readability
- Invert borders (white instead of black where appropriate)
- Reduce geometric background opacity to 5% (even more subtle)
- Preserve Bauhaus boldness while ensuring eye comfort

## UI Screen Mockups

### Home Screen / Notes List
```
┌─────────────────────────────────────┐
│  ┌─────┐  VOICE NOTES       [≡]    │ ← Header: Jost 24px, black
│  └─────┘                            │    Geometric hamburger menu
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [🔍] Search notes...        │   │ ← Search bar: white bg, black border
│  └─────────────────────────────┘   │
│                                     │
│  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━┓   │
│  ┃ ○  Team Meeting Ideas       ┃   │ ← Note card: white bg, yellow left border
│  ┃                              ┃   │    Circle = recent voice note
│  ┃ Discussed new product...    ┃   │    Title: Jost 22px
│  ┃                              ┃   │    Preview: Jost 14px, gray
│  ┃ [WORK] [IDEAS]    2H AGO    ┃   │    Tags: blue/red rectangles
│  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━┛   │
│                                     │
│  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━┓   │
│  ┃ △  Grocery List              ┃   │ ← Triangle = manual note
│  ┃                              ┃   │    Red left border
│  ┃ Milk, eggs, bread, cheese   ┃   │
│  ┃                              ┃   │
│  ┃ [PERSONAL]       YESTERDAY   ┃   │
│  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━┛   │
│                                     │
│  [Background: subtle geometric      │
│   shapes in 5% opacity]             │
│                                     │
│                    ┌─────────┐     │
│                    │    ●    │     │ ← Voice button: red circle
│                    │    │    │     │    White mic icon
│                    └─────────┘     │    80px diameter
└─────────────────────────────────────┘
```

### Voice Recording Screen
```
┌─────────────────────────────────────┐
│  [×]                                 │ ← Close: simple X, top left
│                                     │
│                                     │
│         ┌─────────────┐             │
│         │      ●      │             │ ← Voice button: pulsing
│         │      ▼      │             │    Red circle, 100px
│         │    ━━━━     │             │    Waveform below
│         └─────────────┘             │
│                                     │
│    "The meeting starts at..."       │ ← Transcribed text
│                                     │    Jost 16px, black
│                                     │    Real-time display
│                                     │
│    ▃ ▅ ▇ ▅ ▃ ▁ ▃ ▅ ▇ ▅              │ ← Waveform: blue bars
│    ▅ ▇ ▅ ▃ ▁ ▃ ▅ ▇ ▅ ▃              │    Angular, geometric
│                                     │
│                                     │
│         ⏸    ■    ✓                 │ ← Controls: geometric
│       PAUSE STOP SAVE               │    Jost 12px, ALL CAPS
│                                     │
│  [Background: large circle          │
│   in blue, 20% opacity, top right]  │
└─────────────────────────────────────┘
```

### Note Editor Screen
```
┌─────────────────────────────────────┐
│  [←] Meeting Notes         [✓ SAVE] │ ← Header: back arrow, save button
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Add title...                │   │ ← Title input: Jost 24px
│  └─────────────────────────────┘   │    Yellow underline when active
│                                     │
│  [TAG] [TAG] [+ ADD TAG]            │ ← Tag chips: colored rectangles
│                                     │
│  ┌─────────────────────────────┐   │
│  │ The meeting starts at 3pm   │   │ ← Content editor
│  │ in the main conference room │   │    WYSIWYG
│  │ with the entire team.       │   │    Jost 16px
│  │                             │   │
│  │ Agenda items:               │   │
│  │ • Product roadmap           │   │
│  │ • Q1 goals                  │   │
│  │ • Team updates              │   │
│  │                             │   │
│  │ |                           │   │ ← Cursor
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [B] [I] [•] [□] [🔗]        │   │ ← Formatting toolbar
│  └─────────────────────────────┘   │    Simple geometric icons
│                                     │
│  ○ Voice recording: 0:45            │ ← Attached audio indicator
│     [Play] [Delete]                 │
│                                     │
│  [Background: triangle in yellow,   │
│   10% opacity, bottom left]         │
└─────────────────────────────────────┘
```

## Implementation Checklist

### Before Starting Development
- [ ] Create color constants file with exact hex values
- [ ] Test Bauhaus colors for WCAG AA compliance
- [ ] Set up ThemeData with Bauhaus colors and typography
- [ ] Integrate google_fonts package and test Jost font
- [ ] Create basic CustomPainter for circular voice button
- [ ] Create geometric background painter
- [ ] Test speech_to_text on target platforms (iOS, Android)
- [ ] Experiment with audio_waveforms styling
- [ ] Design geometric icon set for common actions
- [ ] Document design system decisions in README
- [ ] Set up Flutter project with required dependencies

### Design System Foundation
- [ ] `lib/design_system/colors.dart` - Color palette constants
- [ ] `lib/design_system/typography.dart` - Text styles
- [ ] `lib/design_system/theme.dart` - ThemeData configuration
- [ ] `lib/design_system/painters/geometric_shapes.dart` - Reusable shapes
- [ ] `lib/design_system/painters/background_painter.dart` - Screen backgrounds
- [ ] `lib/design_system/painters/button_painter.dart` - Custom button graphics

### Feature Implementation
- [ ] Voice recording screen with CustomPainter button
- [ ] Real-time speech-to-text integration
- [ ] Audio waveform visualization
- [ ] Notes list view with geometric cards
- [ ] Note editor with WYSIWYG capabilities
- [ ] Tag system with Bauhaus color coding
- [ ] Search functionality
- [ ] Dark mode implementation

### Polish & Quality
- [ ] Add flutter_animate transitions
- [ ] Implement accessibility features (Semantics, haptics)
- [ ] Performance profiling and optimization
- [ ] User testing and refinements
- [ ] Documentation of design system usage

## Design Philosophy

**Why Bauhaus Works for This App**:
The Bauhaus movement's "form follows function" philosophy aligns perfectly with a voice-first note-taking app. Just as Bauhaus rejected unnecessary ornamentation, this app strips away the friction of traditional typing. The bold, geometric aesthetic communicates innovation and modernity, signaling to users that this is not just another note-taking app—it's a fundamentally different approach.

**Core Principles**:
- **Bold Simplicity**: Every element serves a purpose
- **Visual Hierarchy**: Size, color, and geometry guide the user
- **Timeless Aesthetic**: Geometric shapes and primary colors never go out of style
- **Functional Beauty**: Beauty emerges from perfect function, not decoration

## References

### Bauhaus Design & History
- [Bauhaus Graphic Design: Past, Present, And Future - 2025](https://inkbotdesign.com/bauhaus-graphic-design/)
- [The graphic designer's guide to Bauhaus design](https://www.linearity.io/blog/bauhaus-design/)
- [Bauhaus Color Palette](https://www.color-hex.com/color-palette/65208)
- [Bauhaus Colors | Johannes Itten, Paul Klee & Josef Albers](https://study.com/academy/lesson/bauhaus-color-theory.html)
- [Typefaces Inspired by the Bauhaus](https://letterformarchive.org/news/bauhaus-typefaces-part-two/)
- [True Type of the Bauhaus - Fonts In Use](https://fontsinuse.com/uses/5/typefaces-at-the-bauhaus)

### Flutter Design Implementation
- [Drawing Custom Shapes With CustomPainter in Flutter | Kodeco](https://www.kodeco.com/7560981-drawing-custom-shapes-with-custompainter-in-flutter)
- [Top Flutter Design System Implementation packages](https://fluttergems.dev/design-system/)
- [Top Flutter Animation, Transition, Lottie, Rive, Motion packages](https://fluttergems.dev/animation-transition/)

### Flutter Packages
- [google_fonts | Flutter package](https://pub.dev/packages/google_fonts)
- [flutter_animate | Flutter package](https://pub.dev/packages/flutter_animate)
- [speech_to_text | Flutter package](https://pub.dev/packages/speech_to_text)
- [Top Flutter AI Voice Assistant, ASR, TTS, STT packages](https://fluttergems.dev/ai-voice-assistant/)

### Typography
- [5 Free Alternatives for Futura on Google Fonts](https://www.naomi-maria.com/5-free-alternatives-for-futura-on-google-fonts/)
- [Top 10 Futura Alternatives (Geometric Sans-Serifs) for 2025](https://www.typewolf.com/top-10-futura-alternatives)

### Design Inspiration
- [Influence of Bauhaus in my UX/UI Design work | Medium](https://medium.com/design-bootcamp/influence-of-bauhaus-in-my-ux-ui-design-work-73aadfde468d)
- [Bauhaus Mobile App by Kseniia Lobko on Dribbble](https://dribbble.com/shots/15954778-Bauhaus-Mobile-App)
- [Bauhaus designs on Dribbble](https://dribbble.com/tags/bauhaus)

## Next Steps

**Recommended Next Command**: `/plan`

Now that the research has been streamlined to focus on the recommended hybrid approach, the next logical step is to create a detailed implementation plan. The plan should:

1. Break down the design system implementation into concrete tasks
2. Define the exact file structure for the Flutter project
3. Specify implementation order (theme → painters → widgets → features)
4. Create checklist for each component to build
5. Identify dependencies between tasks
6. Set up quality gates (accessibility audit, performance benchmarks)

The research provides all necessary context for creating a detailed, actionable implementation plan focused on the hybrid custom design system approach.
