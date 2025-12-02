# Voice-First Note-Taking App - MVP Implementation Plan

## CRITICAL: Design & Architecture Guidelines

**Before implementing ANY feature, read and follow these guides:**

1. **`.claude/docs/bauhaus-widget-design-guide.md`** - Complete Bauhaus design system specification
   - Color palette (Bauhaus Red #BE1E2D, Blue #21409A, Yellow #FFDE17)
   - Typography system (Jost font family with specific sizes)
   - Spacing system (8px grid)
   - All widget specifications with code examples
   - Animation guidelines
   - Accessibility requirements

2. **`.claude/docs/flutter-widget-splitting-guide.md`** - Widget architecture rules
   - Never create methods that return widgets - always use widget classes
   - Split screens into private widgets when build() > 50 lines
   - Use `const` constructors everywhere possible
   - Keep implementation details in same file as private widgets (`_WidgetName`)
   - Extract reusable components to separate files

**Violations of these guides will result in technical debt and inconsistent UX.**

## Objective and Scope

Build a fully-featured MVP of a revolutionary voice-first note-taking application using Flutter and Supabase. The app prioritizes speech-to-text as the primary input method, with a custom Bauhaus-inspired design system, flexible tag-based organization, and powerful search capabilities. This plan ensures solid architectural foundations using Feature-First Clean Architecture with Riverpod 3.0 state management.

**Target Platforms**: iOS and Android (with potential for web/desktop expansion)

**Core MVP Features**:
- Voice-first note capture with speech-to-text
- Email/password authentication with Supabase
- WYSIWYG rich text editor
- User-specific tag system with manual tagging
- Full-text search with multilingual support
- Bauhaus-inspired custom UI/UX
- Comprehensive error handling
- Localization (English and German)

## Technical Approach and Reasoning

**Architecture**: Feature-First Clean Architecture with 4 layers (Domain, Data, Application, Presentation) ensures separation of concerns, testability, and scalability.

**State Management**: Riverpod 3.0 with code generation provides type-safe, compile-time verified state management with excellent debugging capabilities.

**Backend**: Supabase offers integrated authentication, PostgreSQL database with Row Level Security, and real-time capabilities without managing infrastructure.

**Speech Recognition**: Native device APIs (iOS SFSpeech, Android SpeechRecognizer) provide zero-cost, low-latency transcription with excellent multilingual support and offline capability.

**Design Philosophy**: Bauhaus principles (form follows function, geometric precision, primary colors) create a distinctive, functional UI that breaks from traditional note-app conventions. **All UI implementation must follow `.claude/docs/bauhaus-widget-design-guide.md`**.

**Widget Architecture**: All screens and widgets must follow the splitting patterns defined in `.claude/docs/flutter-widget-splitting-guide.md` to maintain clean, performant, and maintainable code. No gigantic single-file screens allowed.

**No Offline-First**: Simplified MVP scope - app requires internet connection, avoiding complex sync logic.

## Implementation Phases

### Phase 1: Project Foundation & Core Infrastructure ✅ COMPLETED

**Goal**: Set up project structure, dependencies, and core infrastructure that all features will build upon.

- [x] Task 1.1: Initialize Flutter project and dependencies
  - ✅ Created Flutter project with Flutter SDK 3.10+
  - ✅ Added all required dependencies to pubspec.yaml (riverpod, supabase_flutter, go_router, freezed, speech_to_text, flutter_quill, etc.)
  - ✅ Configured minimum SDK versions (iOS 10+, Android 21+)
  - ✅ Set up dev_dependencies for code generation and testing
  - ✅ Ran `flutter pub get` successfully

- [x] Task 1.2: Configure platform-specific settings
  - ✅ **iOS**: Updated Info.plist with microphone and speech recognition permissions
  - ✅ **Android**: Updated AndroidManifest.xml with RECORD_AUDIO and INTERNET permissions
  - ✅ **Android**: Set minSdkVersion to 21 in build.gradle.kts
  - ✅ Configured deep link schemes for both platforms (custom scheme: `voicenote://`)

- [x] Task 1.3: Set up code generation infrastructure
  - ✅ Created build.yaml configuration for code generation
  - ✅ Configured freezed, json_serializable, riverpod_generator, and envied_generator
  - ✅ Added .gitignore entries for generated files (*.g.dart, *.freezed.dart, .env)

- [x] Task 1.4: Create core directory structure
  - ✅ Created `lib/core/` with subdirectories: domain/, data/, presentation/, utils/, env/, routing/
  - ✅ Created `lib/features/` with subdirectories for: auth/, notes/, voice/, tags/, editor/
  - ✅ Created `lib/l10n/` for localization files
  - ✅ analysis_options.yaml already configured with flutter_lints
  - ✅ Created comprehensive README.md with project setup instructions

- [x] Task 1.5: Implement environment configuration
  - ✅ Created `.env` file template for Supabase credentials (added to .gitignore)
  - ✅ Created `lib/core/env/env.dart` using envied package for obfuscated environment variables
  - ✅ Generated env.g.dart with `flutter pub run build_runner build`
  - ✅ Documented required environment variables in README

- [x] Task 1.6: Set up Supabase project and initialize client
  - ✅ Created `lib/core/data/supabase_client.dart` with initialization logic
  - ✅ Configured PKCE auth flow in FlutterAuthClientOptions
  - ✅ Added Supabase initialization to main.dart with proper async handling
  - ✅ Created supabaseClientProvider for Riverpod integration
  - ⚠️ Note: User needs to create Supabase project and configure credentials in .env

- [x] Task 1.7: Implement Result pattern and error handling foundation
  - ✅ Created `lib/core/domain/result.dart` with Result<T> sealed class (Success, Failure)
  - ✅ Created `lib/core/domain/failures/` directory
  - ✅ Implemented sealed failure classes: AppFailure with variants (AuthFailure, DatabaseFailure, NetworkFailure, VoiceInputFailure, ValidationFailure, UnknownFailure)
  - ✅ Created extension methods for common error transformations (PostgrestException → AppFailure, AuthException → AppFailure)
  - ✅ Set up Talker logger in main.dart for error tracking
  - ✅ Added FlutterError.onError handler

- [x] Task 1.8: Set up localization infrastructure
  - ✅ Created `l10n.yaml` with configuration (arb-dir, template-arb-file, output-localization-file)
  - ✅ Created `lib/l10n/app_en.arb` with initial English strings
  - ✅ Created `lib/l10n/app_de.arb` with initial German strings
  - ✅ Added flutter_localizations to MaterialApp in main.dart
  - ✅ Enabled `flutter: generate: true` in pubspec.yaml
  - ✅ Created provider for accessing L10n instance (lib/core/presentation/providers/localization_provider.dart)
  - ⚠️ Note: Localization files will be auto-generated on first build

### Phase 2: Bauhaus Design System Implementation

**Goal**: Implement the complete custom design system before building features, ensuring consistent UI/UX throughout the app.

**IMPORTANT**: Follow `.claude/docs/bauhaus-widget-design-guide.md` for all design decisions, color usage, typography, and widget specifications.

- [ ] Task 2.1: Define color palette
  - Create `lib/core/presentation/theme/bauhaus_colors.dart`
  - Define primary Bauhaus colors (red: #E63946, blue: #457B9D, yellow: #F1FAEE)
  - Define neutrals (black: #1D3557, white: #F1FAEE, gray: #A8DADC)
  - Define functional colors (success, warning, error, info)
  - Define light and dark mode background variations
  - Export color constants for use throughout app

- [ ] Task 2.2: Implement typography system
  - Create `lib/core/presentation/theme/bauhaus_typography.dart`
  - Define font family (Inter - geometric sans-serif)
  - Implement Material 3 text styles (displayLarge, displayMedium, headlineLarge, etc.)
  - Define custom text styles for note content, editor, and UI elements
  - Configure letter spacing, line height, and font weights according to Bauhaus principles
  - Add Inter font files to assets and configure in pubspec.yaml

- [ ] Task 2.3: Create theme configuration
  - Create `lib/core/presentation/theme/app_theme.dart`
  - Implement light theme with Bauhaus color palette and typography
  - Implement dark theme variant
  - Configure Material 3 ThemeData with custom color schemes
  - Define InputDecorationTheme, ButtonThemeData, CardTheme, etc.
  - Set up theme provider with Riverpod for theme switching

- [ ] Task 2.4: Design reusable geometric components
  - Create `lib/core/presentation/widgets/` directory
  - **Reference `.claude/docs/bauhaus-widget-design-guide.md` sections: Core Widgets, Color System, Layout Principles**
  - Implement BauhausButton with geometric styling and primary color variants (see VoiceRecordingButton example)
  - Implement BauhausCard with asymmetric layouts and shadow styling (see NoteCard example)
  - Implement BauhausTextField with geometric borders and focus states (see BauhausSearchBar example)
  - Implement BauhausChip for tag display with color customization (see TagChip example)
  - Create BauhausIconButton with circular/square geometric shapes
  - Use CustomPainter for geometric shapes (circles, triangles, squares)

- [ ] Task 2.5: Implement layout components
  - Create BauhausAppBar with custom geometric styling and asymmetric layouts
  - Implement BauhausBottomNavigationBar with Bauhaus color indicators
  - Create BauhausFloatingActionButton with primary color and geometric shape
  - Implement BauhausDialog for modals and confirmations
  - Create BauhausSnackbar for error/success messages with color coding

- [ ] Task 2.6: Create loading and empty state widgets
  - Implement BauhausLoadingIndicator with geometric animation
  - Create BauhausEmptyState with Bauhaus-styled illustrations (SVG)
  - Implement BauhausErrorWidget for displaying errors with retry actions
  - Create skeleton loaders with geometric shapes for list items
  - Design shimmer effect using Bauhaus colors

### Phase 3: Authentication System

**Goal**: Implement complete email/password authentication with Supabase, deep links, and route protection.

- [ ] Task 3.1: Create authentication domain layer
  - Create `lib/features/auth/domain/models/user.dart` with Freezed
  - Create `lib/features/auth/domain/models/auth_state.dart` (Authenticated, Unauthenticated, Loading)
  - Create `lib/features/auth/domain/repositories/auth_repository.dart` interface
  - Define methods: signInWithEmail, signUpWithEmail, signOut, resetPassword, authStateChanges, currentUser
  - Add JSON serialization support with json_serializable

- [ ] Task 3.2: Implement Supabase authentication repository
  - Create `lib/features/auth/data/repositories/supabase_auth_repository.dart`
  - Implement signInWithEmail with error handling and Result pattern
  - Implement signUpWithEmail with automatic profile creation
  - Implement signOut with session cleanup
  - Implement resetPassword with deep link handling
  - Implement authStateChanges stream mapping Supabase auth events to AuthState
  - Add comprehensive error logging with Talker

- [ ] Task 3.3: Create authentication Riverpod providers
  - Create `lib/features/auth/application/auth_providers.dart`
  - Implement authRepositoryProvider
  - Implement authStateProvider (stream of AuthState)
  - Implement authNotifierProvider (AsyncNotifier for auth actions)
  - Add methods: signIn, signUp, signOut, resetPassword
  - Set up provider listeners for state changes

- [ ] Task 3.4: Implement login screen
  - Create `lib/features/auth/presentation/screens/login_screen.dart`
  - **Split widgets following `.claude/docs/flutter-widget-splitting-guide.md`** - no single 200+ line screen file
  - Design Bauhaus-styled login form with email and password fields (see `.claude/docs/bauhaus-widget-design-guide.md`)
  - Create private widgets for form sections (`_LoginForm`, `_EmailField`, `_PasswordField`)
  - Add form validation (email format, password length)
  - Implement sign-in button with loading states using `BauhausElevatedButton`
  - Add "Forgot Password?" link
  - Add "Don't have an account? Sign up" navigation
  - Display error messages using BauhausSnackbar
  - Add localized strings for all UI text

- [ ] Task 3.5: Implement signup screen
  - Create `lib/features/auth/presentation/screens/signup_screen.dart`
  - Design signup form with email, password, and confirm password fields
  - Implement password strength indicator with Bauhaus colors
  - Add validation for password match and strength requirements
  - Implement sign-up button with loading states
  - Add "Already have an account? Log in" navigation
  - Show success message on account creation
  - Add localized strings for all UI text

- [ ] Task 3.6: Implement forgot password screen
  - Create `lib/features/auth/presentation/screens/forgot_password_screen.dart`
  - Design form with email input field
  - Implement "Send Reset Link" button
  - Show success message when email sent
  - Add instructions for checking email
  - Create reset password screen for handling deep link callback
  - Add localized strings for all UI text

- [ ] Task 3.7: Configure Supabase deep links
  - Configure redirect URLs in Supabase dashboard
  - Add custom scheme URL: `voicenote://auth-callback`
  - Add universal link: `https://[project].supabase.co/auth/v1/callback`
  - Test email verification flow
  - Test password reset flow
  - Create `lib/core/auth/deep_link_handler.dart` for processing auth callbacks

- [ ] Task 3.8: Implement routing with GoRouter
  - Create `lib/core/routing/router.dart`
  - Set up GoRouter with authentication-aware redirect logic
  - Define routes: /splash, /login, /signup, /forgot-password, /reset-password, /home, /notes/:id
  - Implement route protection (public vs. authenticated routes)
  - Add GoRouterRefreshStream to listen to auth state changes
  - Create splash screen for initial auth check
  - Add deep link handling integration

- [ ] Task 3.9: Create user profile in database
  - Write SQL migration for user_profiles table
  - Add trigger to create profile on user signup
  - Implement user profile repository interface in domain layer
  - Create Supabase implementation for fetching/updating profile
  - Add profile provider in application layer
  - Add RLS policies for user_profiles table

### Phase 4: Database Schema & Core Note Models

**Goal**: Set up complete PostgreSQL schema with RLS policies and create domain models for notes.

- [ ] Task 4.1: Create and execute database schema
  - Write complete SQL schema in `supabase/migrations/001_initial_schema.sql`
  - Create notes table with all columns (id, user_id, title, content, source, language, language_confidence, timestamps)
  - Create tags table with user isolation (id, user_id, name, color, icon, description, usage_count)
  - Create note_tags junction table for many-to-many relationship
  - Create user_profiles table
  - Add all necessary indexes for performance
  - Execute migration in Supabase dashboard

- [ ] Task 4.2: Set up full-text search infrastructure
  - Add search_vector column to notes table (TSVECTOR GENERATED ALWAYS)
  - Create GIN index on search_vector for fast full-text queries
  - Implement search_notes() PostgreSQL function with text + tag filtering
  - Configure 'simple' text search configuration for multilingual support
  - Test search function with sample data
  - Document search syntax for developers

- [ ] Task 4.3: Implement database triggers
  - Create update_updated_at_column() trigger function
  - Apply trigger to notes and user_profiles tables
  - Create update_tag_usage_count() trigger function
  - Apply trigger to note_tags table for INSERT and DELETE operations
  - Test triggers with manual SQL commands
  - Document trigger behavior for developers

- [ ] Task 4.4: Configure Row Level Security (RLS)
  - Enable RLS on notes, tags, note_tags, user_profiles tables
  - Create "Users can view own notes" policy for SELECT
  - Create INSERT, UPDATE, DELETE policies for notes
  - Create policies for tags ensuring user isolation
  - Create policies for note_tags verifying note ownership
  - Create policies for user_profiles
  - Test RLS policies with different authenticated users

- [ ] Task 4.5: Create note domain models
  - Create `lib/features/notes/domain/models/note.dart` with Freezed
  - Define fields: id, userId, title, content, source (voice/text/mixed), language, languageConfidence, timestamps
  - Add JSON serialization with json_serializable
  - Create `lib/features/notes/domain/models/note_filter.dart` for search/filter criteria
  - Generate code with build_runner

- [ ] Task 4.6: Create note repository interface
  - Create `lib/features/notes/domain/repositories/note_repository.dart`
  - Define methods: createNote, updateNote, deleteNote, getNote, getAllNotes, searchNotes
  - Use Result<T> pattern for all return types
  - Add comprehensive documentation for each method
  - Define parameter models for complex operations

### Phase 5: Speech-to-Text Implementation

**Goal**: Implement native device speech recognition with real-time transcription and language support.

- [ ] Task 5.1: Create voice domain layer
  - Create `lib/features/voice/domain/models/transcription.dart` with Freezed
  - Create `lib/features/voice/domain/models/supported_languages.dart` with language list
  - Define SupportedLanguage class with code, name, displayName
  - Create language list: German (de_DE, de_AT, de_CH), English (en_US, en_GB, en_AU, en_CA)
  - Create `lib/features/voice/domain/repositories/voice_repository.dart` interface
  - Define methods: initialize, getAvailableLanguages, startListening, stopListening, transcriptionStream, isListening

- [ ] Task 5.2: Implement native voice repository
  - Create `lib/features/voice/data/repositories/native_voice_repository.dart`
  - Initialize SpeechToText instance with error handling
  - Implement initialize() with availability check
  - Implement startListening() with locale parameter and partial results
  - Implement stopListening() with cleanup
  - Create broadcast stream controller for transcription updates
  - Add comprehensive error handling and logging with Talker

- [ ] Task 5.3: Create voice Riverpod providers
  - Create `lib/features/voice/application/voice_providers.dart`
  - Implement voiceRepositoryProvider
  - Implement voiceNotifierProvider (AsyncNotifier for voice state)
  - Implement selectedLanguageProvider (StateProvider for current language)
  - Add methods: startListening, stopListening
  - Listen to transcription stream and update state

- [ ] Task 5.4: Request microphone permissions
  - Use permission_handler package to request RECORD_AUDIO permission
  - Create permission request flow before first voice input
  - Handle permission denied scenarios with user guidance
  - Show permission rationale using Bauhaus-styled dialog
  - Add settings redirect if permission permanently denied
  - Test on both iOS and Android devices

- [ ] Task 5.5: Create voice input screen
  - Create `lib/features/voice/presentation/screens/voice_input_screen.dart`
  - **Follow widget splitting guide** - create private widgets for each section
  - **Design per Bauhaus guide** - large geometric shapes, primary colors, asymmetric layout
  - Design Bauhaus-styled voice recording interface (reference BauhausGeometricBackground)
  - Add large circular voice button with geometric animation (see VoiceRecordingButton specification)
  - Show real-time transcription as user speaks
  - Display language selector dropdown with supported languages
  - Add visual feedback for listening state (pulsing animation per Animation Guidelines)
  - Show error states (microphone not available, permission denied)
  - Add "Save Note" button when transcription complete using BauhausElevatedButton

- [ ] Task 5.6: Create voice button widget
  - Create `lib/features/voice/presentation/widgets/voice_button.dart`
  - Design large geometric button following Bauhaus principles
  - Implement pulsing animation when listening
  - Add press-and-hold vs. tap-to-toggle modes
  - Show microphone icon with color state (idle: blue, active: red)
  - Add haptic feedback on press
  - Display recording duration timer

- [ ] Task 5.7: Implement transcription display widget
  - Create `lib/features/voice/presentation/widgets/transcription_display.dart`
  - Show real-time transcription with scroll-to-bottom
  - Display confidence indicator for transcription quality
  - Add edit capability for correcting transcription errors
  - Style text display with Bauhaus typography
  - Add clear button to reset transcription
  - Show language detected badge

- [ ] Task 5.8: Integrate language detection
  - Install flutter_langdetect package
  - Initialize language detection in main.dart
  - Create `lib/core/services/language_detection_service.dart`
  - Implement detectLanguage() with text input
  - Implement getConfidence() for detection quality
  - Map ISO 639-1 codes to PostgreSQL configurations
  - Handle edge cases: short text, code snippets, mixed languages
  - Test with German and English sample text

### Phase 6: Note Creation & Management

**Goal**: Implement complete note CRUD operations with voice and text input integration.

- [ ] Task 6.1: Implement note repository with Supabase
  - Create `lib/features/notes/data/repositories/supabase_note_repository.dart`
  - Implement createNote() with language detection integration
  - Implement updateNote() with re-detection on content change
  - Implement deleteNote() with cascading deletes
  - Implement getNote() by ID with error handling
  - Implement getAllNotes() with pagination support
  - Implement searchNotes() calling PostgreSQL function
  - Add comprehensive logging and error transformation

- [ ] Task 6.2: Create note Riverpod providers
  - Create `lib/features/notes/application/note_providers.dart`
  - Implement noteRepositoryProvider
  - Implement allNotesProvider (StreamProvider for real-time updates)
  - Implement noteDetailProvider (FutureProvider for single note)
  - Implement noteNotifierProvider (AsyncNotifier for CRUD operations)
  - Add methods: createNote, updateNote, deleteNote, searchNotes
  - Set up provider dependencies and invalidation logic

- [ ] Task 6.3: Create notes list screen
  - Create `lib/features/notes/presentation/screens/notes_list_screen.dart`
  - **Split widgets per `.claude/docs/flutter-widget-splitting-guide.md`** - separate private widgets for sections
  - Design Bauhaus-styled list view with asymmetric card layouts (ref: `.claude/docs/bauhaus-widget-design-guide.md`)
  - Create private widgets: `_NotesList`, `_EmptyState`, `_LoadingState`, `_ErrorState`
  - Display note cards with title, preview, date, tags
  - Add pull-to-refresh functionality
  - Implement infinite scroll pagination
  - Add floating action button for creating new note (voice or text)
  - Show empty state when no notes exist
  - Add loading state with skeleton loaders
  - Add error state with retry button

- [ ] Task 6.4: Create note card widget
  - Create `lib/features/notes/presentation/widgets/note_card.dart`
  - Design geometric card following Bauhaus principles
  - Display note title (bold typography)
  - Show content preview (first 2-3 lines)
  - Display creation/update date
  - Show tag chips with colors
  - Add voice/text indicator icon
  - Implement tap to navigate to detail view
  - Add swipe-to-delete gesture with confirmation
  - Add long-press for context menu

- [ ] Task 6.5: Create note detail screen
  - Create `lib/features/notes/presentation/screens/note_detail_screen.dart`
  - Display full note content with rich text formatting
  - Show note metadata (creation date, last modified, word count)
  - Display all tags with color chips
  - Add edit button to navigate to editor
  - Add delete button with confirmation dialog
  - Show language detected badge
  - Add share functionality (text export)
  - Add back navigation to list

- [ ] Task 6.6: Implement note creation flow from voice
  - Create seamless flow from voice input → transcription → note creation
  - Pre-fill note editor with transcription
  - Auto-detect and set language field
  - Set source field to 'voice'
  - Allow editing before saving
  - Add "Save" and "Cancel" buttons
  - Show success message on save
  - Navigate to note detail or list after save

- [ ] Task 6.7: Implement note creation flow from text
  - Create floating action button menu with "Voice" and "Text" options
  - Navigate directly to editor for text input
  - Set source field to 'text'
  - Auto-detect language from typed content
  - Follow same save flow as voice notes

- [ ] Task 6.8: Add note editing capabilities
  - Allow editing title, content, and tags
  - Update source to 'mixed' if voice note edited with text
  - Re-detect language on significant content changes
  - Update updated_at timestamp
  - Show unsaved changes warning on navigation
  - Implement auto-save (debounced) as user types

### Phase 7: WYSIWYG Rich Text Editor

**Goal**: Integrate flutter_quill for rich text editing with custom Bauhaus-styled toolbar.

- [ ] Task 7.1: Create editor domain layer
  - Create `lib/features/editor/domain/models/editor_state.dart` with Freezed
  - Define editor state: controller, isEditing, noteId
  - Create `lib/features/editor/domain/repositories/editor_repository.dart` interface
  - Define methods for converting between Delta JSON and plain text

- [ ] Task 7.2: Implement editor Riverpod providers
  - Create `lib/features/editor/application/editor_providers.dart`
  - Implement editorControllerProvider (QuillController)
  - Implement editorStateProvider (StateNotifier for editor state)
  - Add methods: loadNote, saveNote, clearEditor
  - Manage controller lifecycle (initialization, disposal)

- [ ] Task 7.3: Create rich text editor widget
  - Create `lib/features/editor/presentation/widgets/rich_text_editor.dart`
  - Initialize QuillController with existing content or empty
  - Implement QuillEditor with custom configurations
  - Set up padding, placeholder text, auto-focus
  - Style editor with Bauhaus typography
  - Add listener for content changes
  - Convert Delta to JSON for saving

- [ ] Task 7.4: Design custom Bauhaus-styled toolbar
  - Create `lib/features/editor/presentation/widgets/editor_toolbar.dart`
  - Implement QuillToolbar with custom button styling
  - Apply Bauhaus colors to toolbar buttons (primary colors for active states)
  - Enable: bold, italic, underline, strikethrough
  - Enable: bullet lists, numbered lists, quotes
  - Enable: text alignment (left, center, right)
  - Enable: clear formatting button
  - Disable: background colors, links, code blocks (for MVP simplicity)

- [ ] Task 7.5: Create editor screen
  - Create `lib/features/editor/presentation/screens/editor_screen.dart`
  - Add custom BauhausAppBar with "Cancel" and "Save" buttons
  - Include title TextField at top (optional)
  - Embed rich text editor widget
  - Add editor toolbar above keyboard
  - Implement save logic (create or update note)
  - Show save confirmation
  - Handle back navigation with unsaved changes warning

- [ ] Task 7.6: Integrate editor with note creation flows
  - Update voice note flow to open editor with transcription
  - Update text note flow to open editor empty
  - Update note detail screen to open editor for editing
  - Pass initial content as Delta JSON
  - Handle editor result (saved or cancelled)
  - Refresh note list after save

- [ ] Task 7.7: Implement content persistence
  - Save Delta JSON format in notes.content column
  - Convert Delta to JSON on save
  - Convert JSON to Delta on load
  - Handle conversion errors gracefully
  - Add fallback for plain text content
  - Test with various formatting combinations

### Phase 8: Tag System Implementation

**Goal**: Build complete user-specific tag system with manual tagging, colors, and filtering.

- [ ] Task 8.1: Create tag domain layer
  - Create `lib/features/tags/domain/models/tag.dart` with Freezed
  - Define fields: id, userId, name, color, icon, description, usageCount, createdAt
  - Add JSON serialization with json_serializable
  - Create `lib/features/tags/domain/repositories/tag_repository.dart` interface
  - Define methods: getAllTags, createTag, updateTag, deleteTag, addTagToNote, removeTagFromNote, getTagsForNote, getNotesForTag

- [ ] Task 8.2: Implement tag repository with Supabase
  - Create `lib/features/tags/data/repositories/supabase_tag_repository.dart`
  - Implement getAllTags() sorted by usage_count DESC
  - Implement createTag() with duplicate name check
  - Implement updateTag() for name, color, icon, description
  - Implement deleteTag() with cascading note_tags cleanup
  - Implement addTagToNote() inserting into note_tags table
  - Implement removeTagFromNote() deleting from note_tags
  - Implement getTagsForNote() with JOIN query
  - Implement getNotesForTag() with JOIN query
  - Add comprehensive error handling and logging

- [ ] Task 8.3: Create tag Riverpod providers
  - Create `lib/features/tags/application/tag_providers.dart`
  - Implement tagRepositoryProvider
  - Implement allTagsProvider (StreamProvider for real-time tag updates)
  - Implement tagsForNoteProvider (FamilyProvider for specific note)
  - Implement tagNotifierProvider (AsyncNotifier for tag CRUD)
  - Add methods: createTag, updateTag, deleteTag, addTagToNote, removeTagFromNote

- [ ] Task 8.4: Create tag input widget (autocomplete)
  - Create `lib/features/tags/presentation/widgets/tag_input.dart`
  - Implement Autocomplete<Tag> widget with existing tags
  - Show filtered tags as user types
  - Allow selecting existing tags from dropdown
  - Allow creating new tag by pressing enter
  - Display selected tags as removable chips above input
  - Style with Bauhaus colors and typography
  - Add validation (no empty names, max length)

- [ ] Task 8.5: Create tag chip widget
  - Create `lib/features/tags/presentation/widgets/tag_chip.dart`
  - Design geometric chip with tag color background
  - Display tag name with contrasting text color
  - Add delete icon for removable chips
  - Implement tap action for filtering
  - Style according to Bauhaus principles
  - Add icon support (optional emoji/icon before name)

- [ ] Task 8.6: Create tag management screen
  - Create `lib/features/tags/presentation/screens/tag_management_screen.dart`
  - List all user tags sorted by usage count
  - Show tag name, color, usage count
  - Add "Create Tag" button
  - Implement edit tag dialog (name, color picker, icon picker, description)
  - Implement delete tag with confirmation
  - Show notes count per tag
  - Add tap to view notes with that tag
  - Add search/filter tags functionality

- [ ] Task 8.7: Integrate tagging into note editor
  - Add tag input widget to editor screen
  - Load existing tags when editing note
  - Allow adding/removing tags during note creation/editing
  - Save tag associations on note save
  - Update tag usage_count automatically via triggers
  - Show tag suggestions based on note content (optional enhancement)

- [ ] Task 8.8: Implement tag filtering in notes list
  - Create `lib/features/tags/presentation/widgets/tag_filter_bar.dart`
  - Display horizontal scrollable list of tags
  - Allow selecting multiple tags for filtering
  - Show selected state with Bauhaus colors
  - Update notes list provider to filter by selected tags
  - Add "Clear Filters" button
  - Show count of notes per tag in filter UI

### Phase 9: Full-Text Search Implementation

**Goal**: Implement powerful search combining full-text queries with tag filtering.

- [ ] Task 9.1: Create search domain models
  - Create `lib/features/notes/domain/models/search_query.dart` with Freezed
  - Define fields: text, tagIds, sortBy (enum: dateAscending, dateDescending, relevance)
  - Add methods for building search queries
  - Create SearchResult model with note and relevance rank

- [ ] Task 9.2: Implement search in note repository
  - Add searchNotes() method calling PostgreSQL search_notes() function
  - Pass search_query text parameter
  - Pass tag_ids array parameter
  - Handle null parameters (return all notes)
  - Map results including rank field
  - Sort by rank DESC when text query present, else by date
  - Add pagination support for large result sets

- [ ] Task 9.3: Create search Riverpod providers
  - Implement searchQueryProvider (StateProvider for current query)
  - Implement searchResultsProvider (StreamProvider watching query changes)
  - Implement debounced search (500ms delay after typing stops)
  - Auto-trigger search when query or tag filters change
  - Add loading state during search
  - Handle empty results and errors

- [ ] Task 9.4: Create search bar widget
  - Create `lib/features/notes/presentation/widgets/note_search_bar.dart`
  - Design Bauhaus-styled search field with search icon
  - Add clear button when text present
  - Implement debounced text input (update provider after 500ms)
  - Add search filters button (opens filter dialog)
  - Show active filters count badge
  - Add voice search button (optional enhancement)
  - Style with Bauhaus colors and rounded corners

- [ ] Task 9.5: Create search filters dialog
  - Create dialog for advanced search filters
  - Add tag multi-select using tag chips
  - Add sort order radio buttons (Date: Newest, Date: Oldest, Relevance)
  - Add date range filter (optional)
  - Add "Apply" and "Reset" buttons
  - Style with Bauhaus design system
  - Persist selected filters in searchQueryProvider

- [ ] Task 9.6: Integrate search into notes list screen
  - Add search bar at top of notes list screen
  - Show search results instead of all notes when query active
  - Display search result count
  - Highlight search terms in results (optional enhancement)
  - Show tag filter chips below search bar
  - Add "Clear Search" button to reset
  - Maintain scroll position during search

- [ ] Task 9.7: Test search functionality
  - Test text-only search with various queries
  - Test tag-only filtering with single and multiple tags
  - Test combined text + tag search
  - Test search across German and English notes
  - Test special characters and punctuation
  - Test empty results handling
  - Test search performance with large note sets

### Phase 10: Localization (English & German)

**Goal**: Implement comprehensive localization for English and German languages.

- [ ] Task 10.1: Define all English strings (app_en.arb)
  - Add authentication strings (login, signup, forgot password, errors)
  - Add navigation strings (screen titles, button labels)
  - Add note strings (create, edit, delete, search, empty states)
  - Add tag strings (create, edit, delete, filter)
  - Add voice strings (permissions, errors, recording states)
  - Add editor strings (toolbar buttons, placeholders)
  - Add error messages for all failure types
  - Add success messages and confirmations
  - Add settings strings
  - Add about and help strings

- [ ] Task 10.2: Translate all strings to German (app_de.arb)
  - Translate all authentication strings
  - Translate all navigation strings
  - Translate all note-related strings
  - Translate all tag-related strings
  - Translate all voice-related strings
  - Translate all editor strings
  - Translate all error messages (localized, user-friendly)
  - Translate all success messages
  - Translate settings and help content
  - Review for natural German phrasing (formal "Sie" vs informal "du")

- [ ] Task 10.3: Implement locale switching
  - Create `lib/core/presentation/providers/locale_provider.dart`
  - Implement StateNotifier for current locale
  - Persist selected locale using flutter_secure_storage
  - Load saved locale on app startup
  - Update MaterialApp.locale when changed
  - Create settings screen with language selector
  - Show current language with localized names (English/Deutsch)

- [ ] Task 10.4: Add locale to user profile
  - Update user_profiles table schema with preferred_language column
  - Save user's locale preference to Supabase
  - Load locale from user profile on login
  - Sync locale changes to backend
  - Handle new users (default to device locale or English)

- [ ] Task 10.5: Test localization thoroughly
  - Switch between English and German in app
  - Verify all screens display correct language
  - Test error messages in both languages
  - Test date/time formatting (locale-aware)
  - Test text overflow and layout with German (longer words)
  - Test pluralization rules (1 note vs. 2 notes)
  - Test RTL support if adding Arabic/Hebrew later

- [ ] Task 10.6: Add missing translation handling
  - Implement fallback to English for missing German strings
  - Add logging for missing translation keys
  - Create developer mode to highlight missing translations
  - Document translation process for future languages

### Phase 11: Comprehensive Error Handling

**Goal**: Implement robust error handling throughout the app with user-friendly messages.

- [ ] Task 11.1: Extend failure types with localized messages
  - Update all AppFailure subclasses with localized message keys
  - Create error message mapping in l10n files
  - Add context-specific error messages (auth errors, network errors, etc.)
  - Include error codes for debugging
  - Add user-actionable guidance in error messages

- [ ] Task 11.2: Implement global error boundary
  - Create error boundary widget wrapping MaterialApp
  - Catch and log all uncaught Flutter errors
  - Display user-friendly error screen with Bauhaus styling
  - Add "Restart App" and "Report Issue" buttons
  - Log full error details with Talker for debugging

- [ ] Task 11.3: Add error handling to all providers
  - Wrap all async operations in try-catch blocks
  - Transform exceptions to Result<T> Failure types
  - Log all errors with Talker (error level)
  - Display user-facing errors via BauhausSnackbar
  - Handle specific error types (network, auth, validation)

- [ ] Task 11.4: Implement retry mechanisms
  - Add retry button to error widgets
  - Implement exponential backoff for network errors
  - Add manual retry for failed operations
  - Show retry count to user (3 attempts)
  - Disable retry for non-retryable errors (validation)

- [ ] Task 11.5: Handle network connectivity
  - Add connectivity monitoring (connectivity_plus package)
  - Show "No Internet Connection" banner when offline
  - Queue operations for retry when online
  - Gracefully handle timeout errors
  - Test with airplane mode and slow connections

- [ ] Task 11.6: Implement validation errors
  - Create comprehensive field validators (email, password, note title)
  - Show inline validation errors in forms
  - Use localized error messages
  - Disable submit buttons until valid
  - Add real-time validation with debouncing

- [ ] Task 11.7: Add error reporting
  - Integrate Talker with error reporting service (optional: Sentry)
  - Capture error stack traces
  - Include device info and user context
  - Add privacy controls (no PII in reports)
  - Create debug screen showing recent errors

- [ ] Task 11.8: Test error scenarios
  - Test all auth errors (invalid credentials, weak password, etc.)
  - Test network errors (timeout, no connection, server errors)
  - Test validation errors (empty fields, invalid formats)
  - Test concurrent modification errors
  - Test permission denied scenarios
  - Test quota exceeded errors (Supabase limits)

### Phase 12: Navigation & App Structure

**Goal**: Finalize app navigation flow and create remaining screens.

- [ ] Task 12.1: Create home screen with bottom navigation
  - Create `lib/features/home/presentation/screens/home_screen.dart`
  - Implement bottom navigation with 3 tabs: Notes, Search, Settings
  - Use BauhausBottomNavigationBar widget
  - Show Notes tab by default
  - Handle tab switching with state preservation
  - Add badge for notification count (future feature)

- [ ] Task 12.2: Implement settings screen
  - Create `lib/features/settings/presentation/screens/settings_screen.dart`
  - Add language selector (English/German)
  - Add theme selector (Light/Dark/System)
  - Add account section (email, display name, logout)
  - Add about section (version, privacy policy, terms)
  - Add tag management navigation
  - Style with Bauhaus design system
  - Add localized strings for all content

- [ ] Task 12.3: Create splash screen
  - Create `lib/features/splash/presentation/screens/splash_screen.dart`
  - Show app logo with Bauhaus geometric design
  - Add loading indicator
  - Check authentication state on load
  - Navigate to home or login after check
  - Add minimum display time (1-2 seconds)
  - Animate logo with Bauhaus-inspired animation

- [ ] Task 12.4: Implement app drawer (optional alternative to bottom nav)
  - Create BauhausDrawer widget
  - Add navigation links: Notes, Tags, Settings, About
  - Show user profile at top (avatar, email)
  - Add logout button at bottom
  - Style with asymmetric Bauhaus layouts
  - Add localized labels

- [ ] Task 12.5: Add onboarding flow for new users
  - Create onboarding screen with 3-4 slides
  - Explain voice-first note-taking
  - Explain tagging system
  - Request microphone permission
  - Style with Bauhaus illustrations
  - Skip button to go directly to app
  - Show only on first launch

- [ ] Task 12.6: Implement deep link routing
  - Handle deep links for email verification
  - Handle deep links for password reset
  - Handle deep links for note sharing (future)
  - Test deep link navigation from email
  - Add logging for deep link events

### Phase 13: Polish & Optimization

**Goal**: Refine UI/UX, optimize performance, and fix bugs.

- [ ] Task 13.1: Optimize note list performance
  - Implement virtual scrolling for large lists
  - Add pagination (load 20 notes at a time)
  - Optimize note card rendering
  - Cache loaded notes in provider
  - Add pull-to-refresh indicator
  - Test with 1000+ notes

- [ ] Task 13.2: Add animations and transitions
  - Add page transition animations (slide, fade)
  - Animate voice button pulsing
  - Animate note card appearance
  - Add hero animations for note detail
  - Animate tag chip selection
  - Keep animations subtle and functional (Bauhaus principle)

- [ ] Task 13.3: Improve voice input UX
  - Add haptic feedback on recording start/stop
  - Add sound effects for voice actions (optional)
  - Show visual waveform while recording (optional)
  - Add timeout warning (approaching 1-minute limit)
  - Auto-save partial transcription on error
  - Test with various accents and speech rates

- [ ] Task 13.4: Refine Bauhaus design consistency
  - Audit all screens for design consistency
  - Ensure color palette used correctly
  - Check typography hierarchy throughout
  - Verify geometric shapes and asymmetric layouts
  - Fix any UI inconsistencies
  - Get design feedback from users

- [ ] Task 13.5: Optimize database queries
  - Add indexes for common query patterns
  - Analyze slow queries with Supabase dashboard
  - Optimize search function performance
  - Add query result caching where appropriate
  - Test query performance with large datasets

- [ ] Task 13.6: Handle edge cases
  - Test with very long note titles/content
  - Test with special characters in tags
  - Test with rapid voice input start/stop
  - Test with poor network conditions
  - Test with low storage space
  - Test with multiple devices (same account)

- [ ] Task 13.7: Improve accessibility
  - Add semantic labels for screen readers
  - Ensure sufficient color contrast (WCAG AA)
  - Add keyboard navigation support
  - Test with TalkBack (Android) and VoiceOver (iOS)
  - Add focus indicators for interactive elements
  - Support dynamic font sizes

- [ ] Task 13.8: Add user feedback mechanisms
  - Add success feedback for actions (snackbars, animations)
  - Add loading indicators for all async operations
  - Add progress indicators for long operations
  - Show confirmation dialogs for destructive actions
  - Add undo for accidental deletions (5-second window)

### Phase 14: Testing & Quality Assurance

**Goal**: Comprehensive testing to ensure app stability and reliability.

- [ ] Task 14.1: Write unit tests for domain layer
  - Test Result<T> pattern with success/failure cases
  - Test all failure types and error transformations
  - Test domain models (serialization, equality)
  - Test validation logic
  - Aim for 80%+ code coverage in domain layer

- [ ] Task 14.2: Write unit tests for repositories
  - Mock Supabase client with mocktail
  - Test all repository methods with success scenarios
  - Test error handling (network errors, auth errors)
  - Test data transformation (JSON ↔ models)
  - Test edge cases (empty results, null values)

- [ ] Task 14.3: Write widget tests for key components
  - Test authentication screens (login, signup)
  - Test note list screen with various states
  - Test note editor with formatting actions
  - Test voice input screen
  - Test search functionality
  - Test tag input and filtering

- [ ] Task 14.4: Write integration tests
  - Test end-to-end note creation flow (voice → transcription → save)
  - Test authentication flow (signup → login → logout)
  - Test search with filters
  - Test tag management (create → assign → filter)
  - Test navigation between screens
  - Mock backend with test Supabase instance

- [ ] Task 14.5: Perform manual testing on devices
  - Test on iOS device (iPhone 12+, latest iOS)
  - Test on Android device (Pixel, Samsung, latest Android)
  - Test voice recognition in quiet and noisy environments
  - Test with German and English system languages
  - Test with different screen sizes (small phone, tablet)
  - Test offline scenarios (no internet)

- [ ] Task 14.6: Test Supabase integration
  - Test RLS policies with different users
  - Test database triggers (updated_at, usage_count)
  - Test concurrent edits from multiple devices
  - Test data integrity with edge cases
  - Test Supabase rate limits and quotas

- [ ] Task 14.7: Performance testing
  - Test app launch time (cold start, warm start)
  - Test note list scrolling performance
  - Test search performance with large datasets
  - Test voice recognition latency
  - Profile memory usage
  - Profile battery consumption

- [ ] Task 14.8: Security testing
  - Verify RLS policies prevent unauthorized access
  - Test for SQL injection vulnerabilities
  - Test for XSS in note content
  - Verify secure storage of credentials
  - Test deep link security
  - Audit dependencies for known vulnerabilities

### Phase 15: Documentation & Deployment Preparation

**Goal**: Create comprehensive documentation and prepare for MVP release.

- [ ] Task 15.1: Write user documentation
  - Create user guide explaining voice input
  - Document tagging system and organization
  - Explain search functionality and filters
  - Add troubleshooting section (permissions, errors)
  - Create FAQ with common questions
  - Add screenshots and screen recordings

- [ ] Task 15.2: Write developer documentation
  - Document project architecture (Clean Architecture layers)
  - Explain folder structure and naming conventions
  - Document state management patterns (Riverpod providers)
  - Explain database schema and RLS policies
  - Document code generation workflow
  - Add setup instructions for new developers

- [ ] Task 15.3: Create README.md
  - Add project overview and features
  - List prerequisites (Flutter SDK, Supabase account)
  - Add setup instructions (clone, configure env, run)
  - Document available scripts (build_runner, tests)
  - Add contributing guidelines
  - Include license information

- [ ] Task 15.4: Prepare for iOS App Store
  - Create App Store Connect account
  - Design app icon (Bauhaus-inspired geometric design)
  - Create screenshots for all required device sizes
  - Write app description (English and German)
  - Add keywords for SEO
  - Set up privacy policy URL
  - Configure app permissions and usage descriptions

- [ ] Task 15.5: Prepare for Google Play Store
  - Create Google Play Console account
  - Design feature graphic and promotional images
  - Create screenshots for various device sizes
  - Write app description (English and German)
  - Add keywords and categorization
  - Set up privacy policy URL
  - Configure content rating

- [ ] Task 15.6: Set up CI/CD pipeline (optional for MVP)
  - Configure GitHub Actions or Codemagic
  - Automate tests on pull requests
  - Automate builds for iOS and Android
  - Set up code signing and provisioning
  - Automate deployment to TestFlight/Internal Testing
  - Add build status badges to README

- [ ] Task 15.7: Create app analytics setup
  - Integrate Firebase Analytics (optional)
  - Track key events (note created, voice used, search performed)
  - Track screen views and navigation patterns
  - Monitor error rates and crash reports
  - Set up user retention and engagement metrics
  - Add privacy controls and opt-out

- [ ] Task 15.8: Final MVP checklist
  - All core features implemented and tested
  - No critical bugs remaining
  - Performance meets targets (< 3s launch time)
  - UI/UX polished and consistent
  - Documentation complete
  - Privacy policy and terms published
  - App store assets ready
  - Beta testing completed with feedback incorporated

## Dependencies and Prerequisites

### MANDATORY READING

Before writing ANY code, developers MUST read:
1. **`.claude/docs/bauhaus-widget-design-guide.md`** - Complete design system (colors, typography, spacing, widget specs)
2. **`.claude/docs/flutter-widget-splitting-guide.md`** - Widget architecture patterns (no giant screens, proper const usage)

These guides are not optional - they define the architectural and design standards for the entire project.

### Development Environment
- Flutter SDK 3.29+ with Dart 3.7+
- Xcode 15+ (for iOS development)
- Android Studio with Android SDK (API 21+)
- VS Code or IntelliJ IDEA with Flutter/Dart plugins
- Git for version control

### Backend Services
- Supabase account (free tier sufficient for MVP)
- Supabase project created with PostgreSQL database
- Supabase anon key and project URL

### Packages (All Latest Stable Versions)
- **State Management**: flutter_riverpod ^3.0.3, riverpod_annotation ^3.0.3
- **Backend**: supabase_flutter ^2.10.3
- **Navigation**: go_router ^14.6.2
- **Data Models**: freezed ^2.6.1, json_annotation ^4.9.0
- **Speech**: speech_to_text ^7.3.0, permission_handler ^11.3.1
- **Editor**: flutter_quill ^10.9.5
- **Security**: flutter_secure_storage ^9.2.2, envied ^1.3.1
- **Logging**: talker_flutter ^5.0.2
- **Localization**: intl ^0.19.0, flutter_localizations (SDK)
- **Language Detection**: flutter_langdetect ^0.0.2
- **UI**: flutter_svg ^2.0.10+1

### Testing Packages
- mocktail ^1.0.4 for mocking
- flutter_test (SDK) for widget tests

### External Resources
- Inter font family (Google Fonts or local assets)
- SVG assets for Bauhaus illustrations
- App icon design (geometric, Bauhaus-inspired)

## Challenges and Considerations

### Technical Challenges
1. **Speech Recognition Limitations**: Native APIs stop after ~1 minute; need to handle gracefully
2. **Language Detection Accuracy**: Short notes may not detect language reliably; use 'simple' config as fallback
3. **Real-time Sync**: No offline-first means network errors must be handled gracefully
4. **RLS Policy Complexity**: Ensure note_tags policies correctly check note ownership
5. **Deep Link Configuration**: Testing deep links requires physical devices or complex simulator setup

### UX Challenges
1. **Voice Permission Friction**: Users may deny microphone access; need clear rationale
2. **Transcription Errors**: Speech-to-text isn't perfect; allow easy editing
3. **Tag Discovery**: Users might not understand tagging; need good onboarding
4. **Search Expectations**: Users expect Google-quality search; manage expectations

### Performance Challenges
1. **Large Note Lists**: Pagination and virtual scrolling critical for 1000+ notes
2. **Search Performance**: Full-text search can be slow; need proper indexing
3. **Rich Text Rendering**: Complex formatting can slow down editor; optimize QuillController

### Design Challenges
1. **Bauhaus Consistency**: Maintaining geometric, functional design across all screens requires discipline
2. **Accessibility vs. Aesthetics**: Bauhaus minimalism must not compromise accessibility
3. **Custom UI Components**: Building from scratch takes time; resist using pre-built material widgets

### Deployment Challenges
1. **App Store Review**: Voice recording apps may face extra scrutiny; ensure privacy policy clear
2. **Device Compatibility**: Testing on all device sizes and iOS/Android versions is time-consuming
3. **Supabase Limits**: Free tier has quotas; monitor usage and plan upgrades

### Future Considerations (Post-MVP)
- Offline-first with sync (major architectural change)
- Audio recording storage (requires significant storage and streaming logic)
- Multi-user collaboration (shared notes, team tags)
- Voice commands (e.g., "Create note about...")
- Note attachments (images, PDFs)
- Export/import functionality (Markdown, JSON)
- Desktop and web versions
- Premium tier with additional features

## Success Metrics for MVP

1. **Functional Completeness**: All core features working end-to-end
2. **Performance**: App launches in < 3 seconds, voice transcription starts in < 1 second
3. **Stability**: < 1% crash rate in production
4. **Usability**: Users can create, tag, search, and edit notes without assistance
5. **Design Quality**: UI follows Bauhaus principles consistently across all screens
6. **Localization**: All strings translated and tested in English and German
7. **Error Handling**: All error scenarios handled gracefully with user guidance
8. **Test Coverage**: > 70% code coverage for critical paths

## Post-MVP Roadmap Ideas

**Phase 16**: Advanced voice features (voice commands, continuous dictation)
**Phase 17**: Note organization enhancements (folders, nested tags, favorites)
**Phase 18**: Social features (share notes, collaborative editing)
**Phase 19**: Offline-first architecture with sync
**Phase 20**: Audio recording storage and playback
**Phase 21**: Desktop and web versions
**Phase 22**: Advanced export/import (Markdown, Evernote, Notion)
**Phase 23**: Premium features (unlimited storage, advanced search, custom themes)

---

## Quick Reference: Essential Documentation

### Design System
- **Color Palette**: `.claude/docs/bauhaus-widget-design-guide.md` → Color System section
  - Bauhaus Red: `#BE1E2D`, Blue: `#21409A`, Yellow: `#FFDE17`
  - Use `BauhausColors` constants, never hardcode hex values
- **Typography**: Jost font family, specific sizes for display/headline/body/label
- **Spacing**: 8px grid system - use `BauhausSpacing` constants (tight/small/medium/large)
- **Shapes**: Sharp corners (no rounded except circles), 2px black borders
- **Animations**: Minimal and purposeful - see Animation Guidelines section

### Widget Architecture
- **Splitting Rules**: `.claude/docs/flutter-widget-splitting-guide.md`
  - Build method > 50 lines? → Split into private widgets
  - Never use methods that return widgets → Use widget classes
  - Always use `const` constructors when possible
  - Private widgets (`_WidgetName`) in same file for implementation details
  - Public reusable components in separate files
- **Performance**: `const` everywhere, widget classes not methods, focused widgets

### Code Examples in Guides
- VoiceRecordingButton (circular, pulsing animation)
- NoteCard (asymmetric layout, geometric decorations)
- BauhausElevatedButton (sharp corners, 2px border, ALL CAPS labels)
- BauhausSearchBar (yellow focus indicator, geometric icon)
- TagChip (rectangular, colored background, optional shape icon)
- BauhausGeometricBackground (subtle 10% opacity shapes)

### When Building ANY Screen
1. Read the Bauhaus widget guide section for that component type
2. Read the widget splitting guide decision tree
3. Create screen structure with private widgets for sections
4. Use design system constants (BauhausColors, BauhausSpacing, BauhausTypography)
5. Follow accessibility requirements (48px touch targets, semantic labels, haptic feedback)
6. Test with screen reader (TalkBack/VoiceOver)
