# Research: Flutter Rich Text Editor with flutter_quill

## Executive Summary

For a voice-first note-taking application built with Flutter and Supabase, **flutter_quill** is the recommended rich text editor solution. This research document provides implementation guidance for integrating flutter_quill with a simple, mobile-optimized toolbar.

**Key Findings**:
1. **Editor Choice**: flutter_quill is mature, well-maintained, with excellent cross-platform support and proven Quill Delta format for Supabase storage
2. **Rich Text vs. Markdown**: WYSIWYG rich text editing is superior for voice-first apps - users shouldn't need to dictate markdown syntax
3. **Voice Integration**: Voice transcription inserts plain text into the editor; formatting is applied post-transcription through toolbar interactions
4. **Implementation Strategy**: Start with plain text MVP (Phase 1), add flutter_quill with simple toolbar in Phase 2
5. **Storage Pattern**: Quill Delta format stored as JSONB in Supabase provides optimal flexibility and cross-platform compatibility

## Research Scope

### What Was Researched
- flutter_quill package capabilities and integration
- Voice transcription integration with rich text editors
- Simple mobile toolbar design patterns
- Supabase storage patterns for rich text content (JSONB, Delta format)
- Cross-platform compatibility (iOS, Android)

### What Was Explicitly Excluded
- Alternative editor packages (super_editor, fleather)
- Advanced toolbar options (colors, code blocks, complex formatting)
- Collaborative editing features
- Backend rich text rendering (HTML generation)
- Export to other formats (deferred to later phases)

## Current State Analysis

### Existing Implementation
Based on previous research documents, the application architecture includes:
- **Frontend**: Flutter with Riverpod 3 state management, GoRouter navigation
- **Backend**: Supabase (PostgreSQL database, Auth, Storage, Real-time)
- **Speech-to-Text**: Native device APIs via `speech_to_text` package
- **Target Platforms**: iOS and Android (mobile-first)
- **Primary Use Case**: Quick voice note capture (dream journaling, on-the-go thoughts)

### Industry Standards (2025)

**Rich Text Editing in Flutter**:
- Quill Delta format is the de facto standard for rich text representation
- WYSIWYG editors preferred over markdown for consumer note-taking apps
- Mobile-first toolbar design with essential formatting options
- Simple, scrollable toolbars for mobile devices

**Voice-First Applications**:
- Voice transcription produces plain text
- Formatting applied post-transcription through manual interaction
- Users prefer editing transcriptions before applying formatting

**Storage Patterns**:
- JSONB in PostgreSQL (Supabase) for structured yet flexible content
- Delta format preferred over HTML for editability and cross-platform compatibility
- Separation of raw text (for search) and formatted content (for display)

## flutter_quill: Recommended Approach

### Overview

**Description**: flutter_quill is a rich text editor built for Android, iOS, Web, and desktop platforms. It's a WYSIWYG editor that uses Quill Delta format to represent document content.

**Maturity**: Production-ready, actively maintained (6+ years)

**License**: MIT

**Community**:
- 2,600+ likes on pub.dev (most popular Flutter rich text editor)
- Very active GitHub repository (singerdmx/flutter-quill)
- Extensive documentation and examples
- Large community providing support and plugins

**Integration Effort**: Medium (2-3 days)
- Easy initial setup
- Requires learning Quill Delta format
- Simple toolbar configuration for mobile

### Key Features

- **Rich Formatting**: Bold, italic, underline, headers, lists, quotes, links
- **Quill Delta Format**: JSON-based document representation, easy serialization/deserialization
- **Simple Toolbar**: Configurable toolbar with icon-based controls
- **Cross-Platform**: Same codebase works on iOS, Android, web
- **Cursor Control**: Programmatic text insertion with cursor positioning
- **Undo/Redo**: Built-in history management
- **Read-Only Mode**: Display formatted notes without editing

### Why flutter_quill?

1. **Most mature**: 6+ years, proven in production by thousands of apps
2. **Best community support**: Largest user base, extensive examples
3. **Standard Delta format**: Easy to work with, Supabase-friendly
4. **Cross-platform excellence**: Works on iOS, Android, web, desktop
5. **Active maintenance**: Regular updates and bug fixes
6. **Simple voice integration**: Straightforward API for text insertion

## Voice Transcription Integration

### Integration Pattern

**How it works**: Voice transcription produces plain text inserted into rich text editor. Users apply formatting after transcription using visual toolbar buttons.

**Implementation Flow**:
1. User speaks naturally: "Remember to buy milk and eggs"
2. Text appears in editor: "Remember to buy milk and eggs"
3. User selects text and uses toolbar to format (heading, list, bold, etc.)

### Voice Integration Code

**Basic Text Insertion**:
```dart
void insertVoiceTranscription(String text) {
  // Get current cursor position
  final selection = _controller.selection;
  final index = selection.baseOffset;

  // Insert transcribed text
  _controller.document.insert(index, text);

  // Move cursor to end of inserted text
  _controller.updateSelection(
    TextSelection.collapsed(offset: index + text.length),
    ChangeSource.local,
  );
}
```

**Append to End (Simpler Alternative)**:
```dart
void appendVoiceTranscription(String text) {
  final length = _controller.document.length;
  _controller.document.insert(length - 1, text);
}
```

**Real-Time Transcription with Partial Results**:
```dart
class VoiceNoteProvider extends StateNotifier<VoiceNoteState> {
  final QuillController _editorController;
  int? _transcriptionStartIndex;

  void onTranscriptionStart() {
    // Remember where transcription started
    _transcriptionStartIndex = _editorController.selection.baseOffset;
  }

  void onPartialTranscription(String partialText) {
    if (_transcriptionStartIndex == null) return;

    // Replace text from start index with new partial text
    final currentLength = _editorController.document.length;
    final lengthToReplace = currentLength - _transcriptionStartIndex!;

    _editorController.document.replace(
      _transcriptionStartIndex!,
      lengthToReplace,
      partialText,
    );
  }

  void onFinalTranscription(String finalText) {
    if (_transcriptionStartIndex == null) return;

    // Replace partial text with final transcription
    final currentLength = _editorController.document.length;
    final lengthToReplace = currentLength - _transcriptionStartIndex!;

    _editorController.document.replace(
      _transcriptionStartIndex!,
      lengthToReplace,
      '$finalText\n',
    );

    _transcriptionStartIndex = null;
  }
}
```

## Simple Mobile Toolbar Design

### Recommended Configuration

**Approach**: Single-row scrollable toolbar with essential formatting only

**Rationale**:
1. Simplest implementation (uses flutter_quill default)
2. Familiar pattern for users
3. Sufficient for most note formatting needs
4. Can be enhanced later based on user feedback

### Essential Buttons Only

**Include These Buttons**:
1. **Bold** (B)
2. **Italic** (I)
3. **Underline** (U)
4. **Heading** (H1/H2/H3)
5. **Bullet List** (•)
6. **Numbered List** (1.)

**Omit from Initial Implementation**:
- Colors (text/background) - adds complexity
- Strike-through - rarely used
- Code blocks - not needed for notes
- Quote - can add later if needed
- Link - can add later if needed
- Indent/outdent - lists handle automatically
- Font size - headers provide size variation
- Text alignment - default left align sufficient

### Implementation Code

```dart
QuillToolbar.simple(
  controller: _controller,
  configurations: QuillSimpleToolbarConfigurations(
    // Essential formatting only
    showBoldButton: true,
    showItalicButton: true,
    showUnderLineButton: true,
    showStrikeThrough: false,
    showColorButton: false,
    showBackgroundColorButton: false,
    showHeaderStyle: true,
    showListNumbers: true,
    showListBullets: true,
    showLink: false,
    showQuote: false,
    showIndent: false,
    showCodeBlock: false,
    showClearFormat: false,

    // Single row, scrollable
    multiRowsDisplay: false,

    // Styling
    toolbarIconAlignment: WrapAlignment.start,
    toolbarIconCrossAlignment: WrapCrossAlignment.center,
  ),
)
```

## Complete Implementation Example

### Basic Note Editor

```dart
import 'package:flutter_quill/flutter_quill.dart';

class NoteEditor extends StatefulWidget {
  @override
  _NoteEditorState createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final QuillController _controller = QuillController.basic();

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    // Fetch Delta JSON from Supabase
    final supabase = Supabase.instance.client;
    final data = await supabase
        .from('notes')
        .select('content')
        .eq('id', noteId)
        .single();

    // Load into editor
    final delta = Delta.fromJson(data['content']);
    _controller.document = Document.fromDelta(delta);
  }

  Future<void> _saveNote() async {
    // Get Delta from editor
    final delta = _controller.document.toDelta();
    final json = delta.toJson();

    // Save to Supabase (JSONB column)
    await supabase.from('notes').upsert({
      'id': noteId,
      'content': json, // Pass object, not stringified
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  void _insertVoiceTranscription(String text) {
    final selection = _controller.selection;
    final index = selection.baseOffset;
    _controller.document.insert(index, text);
    _controller.updateSelection(
      TextSelection.collapsed(offset: index + text.length),
      ChangeSource.local,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Simple Toolbar
        QuillToolbar.simple(
          controller: _controller,
          configurations: QuillSimpleToolbarConfigurations(
            showBoldButton: true,
            showItalicButton: true,
            showUnderLineButton: true,
            showHeaderStyle: true,
            showListNumbers: true,
            showListBullets: true,
            multiRowsDisplay: false,
          ),
        ),

        Divider(),

        // Editor
        Expanded(
          child: QuillEditor.basic(
            controller: _controller,
            configurations: QuillEditorConfigurations(
              placeholder: 'Start typing or use voice...',
              padding: EdgeInsets.all(16),
              autoFocus: false,
              expands: true,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

## Supabase Storage Implementation

### Database Schema

```sql
CREATE TABLE notes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Core content
  title text,
  content_delta jsonb NOT NULL, -- Quill Delta format for editing
  plain_text text, -- Extracted plain text for search

  -- Metadata
  tags text[],
  is_favorite boolean DEFAULT false,

  -- Timestamps
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Indexes
CREATE INDEX notes_user_id_idx ON notes(user_id);
CREATE INDEX notes_created_at_idx ON notes(created_at DESC);
CREATE INDEX notes_tags_idx ON notes USING gin(tags);

-- Full-text search index on plain_text
CREATE INDEX notes_plain_text_search_idx ON notes
  USING gin(to_tsvector('english', plain_text));

-- Row Level Security
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own notes"
  ON notes FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own notes"
  ON notes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own notes"
  ON notes FOR UPDATE
  USING (auth.uid() = user_id);
```

### Why JSONB for Delta Format?

**Advantages**:
1. **Native PostgreSQL support**: JSONB is optimized binary JSON storage
2. **Flexible**: No rigid schema, accommodates Delta format changes
3. **Efficient**: Faster to process than text JSON
4. **Queryable**: Can query into Delta structure if needed

**Delta Format Example**:
```json
{
  "ops": [
    { "insert": "Hello " },
    { "insert": "World", "attributes": { "bold": true } },
    { "insert": "\n" },
    { "insert": "This is a list item\n", "attributes": { "list": "bullet" } }
  ]
}
```

### Flutter Integration with Supabase

**Saving Note**:
```dart
Future<void> saveNote({
  required String noteId,
  required String title,
  required QuillController controller,
  required List<String> tags,
}) async {
  // Get Delta from editor
  final delta = controller.document.toDelta();
  final deltaJson = delta.toJson();

  // Extract plain text for search
  final plainText = controller.document.toPlainText();

  // Save to Supabase
  await supabase.from('notes').upsert({
    'id': noteId,
    'title': title,
    'content_delta': deltaJson, // Pass object, NOT JSON.stringify()
    'plain_text': plainText,
    'tags': tags,
    'updated_at': DateTime.now().toIso8601String(),
  });
}
```

**Loading Note**:
```dart
Future<void> loadNote(String noteId) async {
  // Fetch from Supabase
  final data = await supabase
      .from('notes')
      .select('id, title, content_delta, tags, created_at')
      .eq('id', noteId)
      .single();

  // Convert to Delta
  final deltaJson = data['content_delta'] as Map<String, dynamic>;
  final delta = Delta.fromJson(deltaJson['ops']);

  // Load into editor
  _controller.document = Document.fromDelta(delta);
}
```

**Important: Don't Stringify JSON**:
```dart
// ❌ WRONG - Do not stringify
await supabase.from('notes').insert({
  'content_delta': jsonEncode(deltaJson), // DON'T DO THIS
});

// ✅ CORRECT - Pass object directly
await supabase.from('notes').insert({
  'content_delta': deltaJson, // Supabase handles JSONB conversion
});
```

### Auto-Save Strategy

```dart
class NoteEditorProvider extends StateNotifier<NoteEditorState> {
  Timer? _autoSaveTimer;
  final Duration _autoSaveDelay = Duration(seconds: 2);

  void onContentChanged() {
    // Cancel existing timer
    _autoSaveTimer?.cancel();

    // Start new timer
    _autoSaveTimer = Timer(_autoSaveDelay, () {
      _autoSave();
    });

    // Update UI to show unsaved changes
    state = state.copyWith(hasUnsavedChanges: true);
  }

  Future<void> _autoSave() async {
    try {
      await saveNote(
        noteId: state.noteId,
        title: state.title,
        controller: state.controller,
        tags: state.tags,
      );

      state = state.copyWith(
        hasUnsavedChanges: false,
        lastSaved: DateTime.now(),
      );
    } catch (e) {
      // Handle error (show snackbar, retry, etc.)
      print('Auto-save failed: $e');
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}
```

### Full-Text Search

```dart
Future<List<Note>> searchNotes(String query) async {
  final response = await supabase
      .from('notes')
      .select('id, title, plain_text, content_delta, tags, created_at')
      .textSearch('plain_text', query, config: 'english')
      .order('created_at', ascending: false);

  return response.map((json) => Note.fromJson(json)).toList();
}
```

## Technical Requirements

### Minimum Versions

- **Flutter**: 3.16+
- **Dart**: 3.0+

### Required Packages

```yaml
dependencies:
  flutter_quill: ^10.0.0 # Latest version as of 2025
  supabase_flutter: ^2.5.0

  # Optional but recommended
  google_fonts: ^6.0.0 # Consistent fonts across platforms
```

### Platform Requirements

- **iOS**: iOS 12.0+
- **Android**: Android 5.0+ (API 21+)

## Implementation Roadmap

### Phase 1: MVP - Plain Text (Week 1-2)

**Focus**: Validate core voice capture value proposition

**Implementation**:
- Simple TextField for text editing
- Voice transcription integration
- Save plain text to Supabase
- Basic note list and search

**Deliverable**: MVP app where users can create voice notes and see transcriptions

### Phase 2: Add Simple Rich Text (Week 3-4)

**Focus**: Enhance with basic formatting capabilities

**Implementation**:
- Integrate flutter_quill with simple 6-button toolbar
- Migrate existing plain text notes to Delta format
- Update Supabase schema to add content_delta column
- Implement voice text insertion into Quill editor
- Auto-save with Delta format

**Code Example - Migration**:
```dart
// Migrate plain text notes to Delta format
Future<void> migrateNotesToRichText() async {
  final notes = await supabase.from('notes').select().is_('content_delta', null);

  for (final note in notes) {
    final plainText = note['content'] as String;

    // Convert plain text to Delta
    final delta = Delta()..insert(plainText);

    // Update note with Delta format
    await supabase.from('notes').update({
      'content_delta': delta.toJson(),
    }).eq('id', note['id']);
  }
}
```

**Deliverable**: App with simple rich text editing (bold, italic, underline, headings, lists)

### Phase 3: Polish & Optional Enhancements (Week 5+)

**Future Considerations** (implement based on user feedback):
- Add more toolbar buttons (quote, link, clear formatting)
- Markdown export functionality
- Images via flutter_quill_extensions
- Enhanced toolbar UX (contextual, bottom sheet)
- Undo/redo buttons in toolbar

## Performance Considerations

**Editor Performance**:
- flutter_quill handles documents up to 10,000+ characters efficiently
- Delta format is efficient for storing and loading

**Bundle Size Impact**:
- flutter_quill adds ~1-2MB to app size
- Minimal compared to overall Flutter app size (15-30MB typical)

**Storage Impact**:
- Plain text: ~1 byte per character
- Delta format: ~1.5-2x size due to JSON structure
- Example: 1000-char note = 1KB plain vs ~1.5-2KB Delta
- For 10,000 notes, difference is ~5-10MB total (negligible)

## Cross-Platform Compatibility

### Platform Support

| Platform | Support Level |
|----------|---------------|
| **iOS** | ✅ Full Support |
| **Android** | ✅ Full Support |
| **Web** | ⚠️ Mostly Supported |

### Platform-Specific Considerations

**iOS**:
- Native text selection handles
- System-wide undo/redo gestures
- Haptic feedback on selection

**Android**:
- Material Design selection handles
- Floating toolbar for text selection
- Share integration

## References

### Package Documentation
- [flutter_quill on pub.dev](https://pub.dev/packages/flutter_quill)
- [flutter_quill GitHub Repository](https://github.com/singerdmx/flutter-quill)

### Supabase Integration
- [Managing JSON and unstructured data | Supabase Docs](https://supabase.com/docs/guides/database/json)

### Quill Delta Format
- [Quill Delta Format Documentation](https://quilljs.com/docs/delta/)
- [Understanding Quill's Delta Format](https://github.com/quilljs/delta)

---

**Research Completed**: December 2, 2025
**Recommended Implementation**: Phase 1 (Plain Text MVP) → Phase 2 (Simple Rich Text with 6-button toolbar)
