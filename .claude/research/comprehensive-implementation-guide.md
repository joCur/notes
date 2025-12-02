# Comprehensive Implementation Guide: Voice-First Note-Taking App

## Executive Summary

This document consolidates all research conducted for building a voice-first note-taking app using Flutter and Supabase. The app prioritizes speed-of-thought note capture through speech-to-text, flexible tag-based organization, and a custom Bauhaus-inspired design system.

**Core Technology Stack:**
- **Frontend**: Flutter 3.29+ with Dart 3.7+
- **Backend**: Supabase (PostgreSQL, Auth, Realtime, Storage)
- **Architecture**: Feature-First Clean Architecture with 4 layers
- **State Management**: Riverpod 3.0 with code generation
- **Navigation**: GoRouter for declarative routing
- **Speech Recognition**: Native device APIs via speech_to_text package
- **Design Philosophy**: Bauhaus-inspired minimalism with functional clarity

**Key Differentiators:**
1. Voice-first input as primary interaction method (not an afterthought)
2. Hands-free workflow for accessibility and multitasking
3. User-controlled tag system (no auto-tagging, no shared tags between users)
4. No offline-first implementation (requires internet connection)
5. No audio storage (voice used only for note creation)
6. Revolutionary custom design breaking traditional note-app conventions

## Research Scope

### What Was Researched
- Flutter/Supabase architecture patterns for 2025
- Clean Architecture implementation with Riverpod 3.0
- Speech-to-text solutions for real-time transcription
- Supabase authentication and Row Level Security (RLS)
- Tag system architecture with many-to-many relationships
- WYSIWYG rich text editors for Flutter
- Multilingual full-text search with PostgreSQL
- Widget structuring and state management patterns
- Error handling and localization strategies
- Bauhaus design principles for UI/UX
- Current package versions and compatibility

### What Was Explicitly Excluded
- **Offline-first implementation** - App requires internet connection
- **Auto-tagging system** - Users must manually tag all notes
- **Shared tags** - Users only see their own tags, no cross-user tagging
- **Audio recording storage** - Voice used only for transcription, not saved
- **Social features** - No sharing, collaboration, or multi-user scenarios
- **Voice assistant integration** - No Alexa/Google Assistant
- **Biometric authentication** - Email/password only
- **Multi-factor authentication (MFA)**
- **Hierarchical tag systems** - Flat tag structure only

## Application Architecture

### Feature-First Clean Architecture

The application follows a **Feature-First Clean Architecture** with 4 distinct layers:

```
lib/
├── core/                           # Shared infrastructure
│   ├── domain/
│   │   ├── entities/              # Core business objects
│   │   ├── failures/              # Error types (sealed classes)
│   │   └── result.dart            # Result<T> pattern
│   ├── data/
│   │   ├── supabase_client.dart   # Supabase instance
│   │   └── database/              # Shared database utilities
│   ├── presentation/
│   │   ├── theme/                 # Bauhaus design system
│   │   └── widgets/               # Reusable UI components
│   ├── utils/
│   │   ├── validators/            # Input validation
│   │   └── formatters/            # Data formatting
│   ├── env/
│   │   └── env.dart              # Environment variables (envied)
│   └── routing/
│       └── router.dart           # GoRouter configuration
│
├── features/                      # Feature modules
│   ├── auth/                     # Authentication
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── user.dart
│   │   │   │   └── auth_state.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── supabase_auth_repository.dart
│   │   ├── application/
│   │   │   └── auth_providers.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   ├── signup_screen.dart
│   │       │   └── forgot_password_screen.dart
│   │       └── widgets/
│   │           └── auth_form.dart
│   │
│   ├── notes/                    # Note management
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── note.dart
│   │   │   │   └── note_filter.dart
│   │   │   └── repositories/
│   │   │       └── note_repository.dart
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── supabase_note_repository.dart
│   │   ├── application/
│   │   │   └── note_providers.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── notes_list_screen.dart
│   │       │   ├── note_detail_screen.dart
│   │       │   └── note_editor_screen.dart
│   │       └── widgets/
│   │           ├── note_card.dart
│   │           └── note_search_bar.dart
│   │
│   ├── voice/                    # Voice input
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   └── transcription.dart
│   │   │   └── repositories/
│   │   │       └── voice_repository.dart
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── native_voice_repository.dart
│   │   ├── application/
│   │   │   └── voice_providers.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── voice_input_screen.dart
│   │       └── widgets/
│   │           ├── voice_button.dart
│   │           └── transcription_display.dart
│   │
│   ├── tags/                     # Tag management
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   └── tag.dart
│   │   │   └── repositories/
│   │   │       └── tag_repository.dart
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── supabase_tag_repository.dart
│   │   ├── application/
│   │   │   └── tag_providers.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── tag_management_screen.dart
│   │       └── widgets/
│   │           ├── tag_input.dart
│   │           ├── tag_chip.dart
│   │           └── tag_filter_bar.dart
│   │
│   └── editor/                   # Rich text editing
│       ├── domain/
│       │   ├── models/
│       │   │   └── editor_state.dart
│       │   └── repositories/
│       │       └── editor_repository.dart
│       ├── application/
│       │   └── editor_providers.dart
│       └── presentation/
│           ├── screens/
│           │   └── editor_screen.dart
│           └── widgets/
│               ├── editor_toolbar.dart
│               └── formatting_controls.dart
│
├── l10n/                         # Localization
│   ├── app_en.arb               # English strings
│   ├── app_de.arb               # German strings
│   └── l10n.yaml                # Localization config
│
└── main.dart                     # App entry point
```

### Layer Responsibilities

**1. Domain Layer (Business Logic)**
- Pure Dart code, no framework dependencies
- Contains business entities (models with Freezed)
- Defines repository interfaces (abstract classes)
- Error types using sealed classes
- Result<T> pattern for error handling
- No knowledge of data sources or UI

**2. Data Layer (External Interfaces)**
- Implements repository interfaces from domain
- Supabase client integration
- API calls and database operations
- Data transformation (JSON ↔ Domain models)
- External service integration
- Caching strategies

**3. Application Layer (State Management)**
- Riverpod providers and notifiers
- Business logic orchestration
- State management using Riverpod 3.0
- Use case implementations
- Reactive streams and computed values
- Provider dependencies

**4. Presentation Layer (UI)**
- Flutter widgets and screens
- User interaction handling
- Form validation
- Navigation
- UI state (loading, error, success)
- Localized strings

## Database Schema

### Complete PostgreSQL Schema

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Notes table
CREATE TABLE notes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT,
  content TEXT NOT NULL,
  source TEXT CHECK (source IN ('voice', 'text', 'mixed')) DEFAULT 'text',
  language TEXT DEFAULT 'simple',  -- PostgreSQL text search config name (detected by client)
  language_confidence REAL,        -- Confidence score from language detection (0.0 to 1.0)
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Full-text search support (multilingual)
  search_vector TSVECTOR GENERATED ALWAYS AS (
    setweight(to_tsvector('simple', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('simple', content), 'B')
  ) STORED
);

-- Tags table (user-specific, no sharing)
CREATE TABLE tags (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  color TEXT DEFAULT '#2196F3',
  icon TEXT,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  usage_count INTEGER DEFAULT 0,

  UNIQUE(user_id, name) -- Prevent duplicate tag names per user
);

-- Note-Tags junction table (many-to-many)
CREATE TABLE note_tags (
  note_id UUID REFERENCES notes(id) ON DELETE CASCADE NOT NULL,
  tag_id UUID REFERENCES tags(id) ON DELETE CASCADE NOT NULL,
  tagged_at TIMESTAMPTZ DEFAULT NOW(),

  PRIMARY KEY (note_id, tag_id)
);

-- User profiles (extended user data)
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  preferred_language TEXT DEFAULT 'en',
  theme_preference TEXT DEFAULT 'system',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Performance indexes
CREATE INDEX notes_user_id_idx ON notes(user_id);
CREATE INDEX notes_created_at_idx ON notes(created_at DESC);
CREATE INDEX notes_search_idx ON notes USING GIN(search_vector);
CREATE INDEX notes_user_created_idx ON notes(user_id, created_at DESC);

CREATE INDEX tags_user_id_idx ON tags(user_id);
CREATE INDEX tags_name_idx ON tags(LOWER(name));
CREATE INDEX tags_usage_count_idx ON tags(usage_count DESC);

CREATE INDEX note_tags_note_id_idx ON note_tags(note_id);
CREATE INDEX note_tags_tag_id_idx ON note_tags(tag_id);

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger
CREATE TRIGGER update_notes_updated_at
  BEFORE UPDATE ON notes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Tag usage count trigger
CREATE OR REPLACE FUNCTION update_tag_usage_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE tags SET usage_count = usage_count + 1 WHERE id = NEW.tag_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE tags SET usage_count = usage_count - 1 WHERE id = OLD.tag_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_tag_usage_count_trigger
  AFTER INSERT OR DELETE ON note_tags
  FOR EACH ROW
  EXECUTE FUNCTION update_tag_usage_count();

-- Row Level Security (RLS) policies
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE note_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Notes policies
CREATE POLICY "Users can view own notes" ON notes
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own notes" ON notes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own notes" ON notes
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own notes" ON notes
  FOR DELETE USING (auth.uid() = user_id);

-- Tags policies (user-specific, no cross-user visibility)
CREATE POLICY "Users can view own tags" ON tags
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own tags" ON tags
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own tags" ON tags
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own tags" ON tags
  FOR DELETE USING (auth.uid() = user_id);

-- Note-tags policies
CREATE POLICY "Users can view own note-tags" ON note_tags
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM notes
      WHERE notes.id = note_tags.note_id
      AND notes.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own note-tags" ON note_tags
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM notes
      WHERE notes.id = note_tags.note_id
      AND notes.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own note-tags" ON note_tags
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM notes
      WHERE notes.id = note_tags.note_id
      AND notes.user_id = auth.uid()
    )
  );

-- User profiles policies
CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = id);

-- Search function combining text search and tag filtering
CREATE OR REPLACE FUNCTION search_notes(
  search_query TEXT DEFAULT NULL,
  tag_ids UUID[] DEFAULT NULL,
  user_id_param UUID DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  title TEXT,
  content TEXT,
  source TEXT,
  created_at TIMESTAMPTZ,
  rank REAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT
    n.id,
    n.title,
    n.content,
    n.source,
    n.created_at,
    CASE
      WHEN search_query IS NOT NULL THEN
        ts_rank(n.search_vector, websearch_to_tsquery('simple', search_query))
      ELSE 0
    END AS rank
  FROM notes n
  LEFT JOIN note_tags nt ON n.id = nt.note_id
  WHERE
    n.user_id = COALESCE(user_id_param, auth.uid())
    AND (
      tag_ids IS NULL
      OR nt.tag_id = ANY(tag_ids)
    )
    AND (
      search_query IS NULL
      OR n.search_vector @@ websearch_to_tsquery('simple', search_query)
    )
  ORDER BY
    CASE WHEN search_query IS NOT NULL THEN rank ELSE 0 END DESC,
    n.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Technology Stack & Package Versions

### Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^3.0.3                    # Reactive state management
  riverpod_annotation: ^3.0.3                  # Code generation annotations

  # Backend & Database
  supabase_flutter: ^2.10.3                    # Supabase client with auth

  # Navigation
  go_router: ^14.6.2                           # Declarative routing

  # Data Models
  freezed: ^2.6.1                              # Immutable models
  freezed_annotation: ^2.4.4                   # Freezed annotations
  json_annotation: ^4.9.0                      # JSON serialization

  # Speech Recognition
  speech_to_text: ^7.3.0                       # Native device speech APIs
  permission_handler: ^11.3.1                  # Microphone permissions

  # Rich Text Editor
  flutter_quill: ^10.9.5                       # WYSIWYG editor
  flutter_quill_extensions: ^10.9.5            # Editor extensions

  # Security
  flutter_secure_storage: ^9.2.2               # Encrypted key-value storage
  envied: ^1.3.1                               # Environment variables with obfuscation

  # Logging & Error Handling
  talker_flutter: ^5.0.2                       # Advanced logging and error tracking

  # Localization
  intl: ^0.19.0                                # Internationalization
  flutter_localizations:
    sdk: flutter

  # Language Detection
  flutter_langdetect: ^0.0.2                   # Client-side language detection

  # UI Components
  flutter_svg: ^2.0.10+1                       # SVG rendering

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.4.13                        # Code generation runner
  riverpod_generator: ^3.0.3                   # Riverpod code generation
  freezed: ^2.6.1                              # Model generation
  json_serializable: ^6.8.0                    # JSON serialization generation
  envied_generator: ^1.3.1                     # Environment variable generation

  # Linting
  flutter_lints: ^5.0.0                        # Recommended lints

  # Testing
  mocktail: ^1.0.4                             # Mocking library
```

### Package Details

**State Management:**
- **flutter_riverpod 3.0.3** - Latest stable release with automatic retry, pause/resume support, and experimental offline persistence
- **riverpod_annotation 3.0.3** - Compile-time code generation for type-safe providers

**Backend:**
- **supabase_flutter 2.10.3** - Includes automatic session management, PKCE flow, and secure storage integration

**Navigation:**
- **go_router 14.6.2** - Declarative routing with deep linking, redirect logic, and type-safe route parameters

**Data Modeling:**
- **freezed 2.6.1** - Immutable data classes with sealed unions for state management
- **json_annotation 4.9.0** - JSON serialization support

**Speech Recognition:**
- **speech_to_text 7.3.0** - Native iOS (SFSpeech) and Android (SpeechRecognizer) APIs for zero-cost, low-latency transcription

**Rich Text:**
- **flutter_quill 10.9.5** - Production-ready WYSIWYG editor with extensive formatting options

**Security:**
- **flutter_secure_storage 9.2.2** - Platform-specific encrypted storage (iOS Keychain, Android KeyStore)
- **envied 1.3.1** - Obfuscated environment variables for API key security

**Logging:**
- **talker_flutter 5.0.2** - Comprehensive logging with UI, error tracking, and reporting

**Localization:**
- **intl 0.19.0** - Core internationalization package for Flutter

## Authentication Implementation

### Email/Password Authentication Only

**Why Email/Password Only:**
- Simplest authentication method with lowest friction
- No dependency on third-party OAuth providers
- Complete control over user experience
- Works on all platforms (iOS, Android, web, desktop)
- No platform-specific configuration required
- Privacy-friendly (no social account linking)

### Authentication Flow

```dart
// Domain Layer - Repository Interface
abstract class AuthRepository {
  Future<Result<User>> signInWithEmail(String email, String password);
  Future<Result<User>> signUpWithEmail(String email, String password);
  Future<Result<void>> signOut();
  Future<Result<void>> resetPassword(String email);
  Stream<AuthState> authStateChanges();
  User? get currentUser;
}

// Domain Layer - Models
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? displayName,
    required DateTime createdAt,
    DateTime? emailVerifiedAt,
  }) = _User;
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState.authenticated({
    required User user,
    required Session session,
  }) = Authenticated;
  const factory AuthState.unauthenticated() = Unauthenticated;
  const factory AuthState.loading() = Loading;
}

// Data Layer - Supabase Implementation
class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;
  final Talker _talker;

  @override
  Future<Result<User>> signInWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return Result.failure(
          AppFailure.authentication(message: 'Invalid credentials'),
        );
      }

      return Result.success(User.fromSupabase(response.user!));
    } on AuthException catch (e, stack) {
      _talker.error('Auth sign-in failed', e, stack);
      return Result.failure(
        AppFailure.authentication(message: e.message),
      );
    } catch (e, stack) {
      _talker.error('Unexpected auth error', e, stack);
      return Result.failure(
        AppFailure.unknown(message: 'An unexpected error occurred'),
      );
    }
  }

  @override
  Stream<AuthState> authStateChanges() {
    return _client.auth.onAuthStateChange.map((data) {
      if (data.session != null && data.session!.user != null) {
        return AuthState.authenticated(
          user: User.fromSupabase(data.session!.user),
          session: data.session!,
        );
      }
      return const AuthState.unauthenticated();
    });
  }
}

// Application Layer - Riverpod Providers
@riverpod
Stream<AuthState> authState(AuthStateRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<User?> build() {
    ref.listen(authStateProvider, (prev, next) {
      next.whenOrNull(
        data: (state) => state.when(
          authenticated: (user, _) => state = AsyncValue.data(user),
          unauthenticated: () => state = const AsyncValue.data(null),
          loading: () => state = const AsyncValue.loading(),
        ),
      );
    });

    return AsyncValue.data(ref.read(authRepositoryProvider).currentUser);
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await ref
        .read(authRepositoryProvider)
        .signInWithEmail(email, password);
    state = result.when(
      success: (user) => AsyncValue.data(user),
      failure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }
}
```

### Deep Link Configuration for Email Verification and Password Reset

**Why Deep Links Are Required:**
- Email verification links must redirect back to the app
- Password reset links must open the app to set new password
- Improves user experience (no copy/paste needed)
- Required for production authentication flows

#### iOS Deep Link Setup

**Update Info.plist:**

```xml
<!-- ios/Runner/Info.plist -->
<plist>
<dict>
  <!-- Existing keys... -->

  <!-- Deep link configuration -->
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleTypeRole</key>
      <string>Editor</string>
      <key>CFBundleURLName</key>
      <string>com.yourcompany.voicenote</string>
      <key>CFBundleURLSchemes</key>
      <array>
        <!-- Your app's custom URL scheme -->
        <string>voicenote</string>
      </array>
    </dict>
  </array>

  <!-- Universal Links (optional, for https:// deep links) -->
  <key>com.apple.developer.associated-domains</key>
  <array>
    <string>applinks:your-project.supabase.co</string>
  </array>
</dict>
</plist>
```

#### Android Deep Link Setup

**Update AndroidManifest.xml:**

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <activity
            android:name=".MainActivity"
            android:launchMode="singleTask">

            <!-- Existing intent filters... -->

            <!-- Deep link intent filter -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />

                <!-- Custom URL scheme -->
                <data
                    android:scheme="voicenote"
                    android:host="auth-callback" />

                <!-- HTTPS deep links (optional) -->
                <data
                    android:scheme="https"
                    android:host="your-project.supabase.co"
                    android:pathPrefix="/auth/v1/callback" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

#### Supabase Configuration

**Configure Redirect URLs in Supabase Dashboard:**

1. Go to Authentication > URL Configuration
2. Add redirect URLs:
   - `voicenote://auth-callback` (custom scheme)
   - `https://your-project.supabase.co/auth/v1/callback` (universal link)
3. Add to both "Redirect URLs" and "Site URL" settings

#### Deep Link Handler Implementation

```dart
// lib/core/auth/deep_link_handler.dart

class DeepLinkHandler {
  final Talker _talker;
  final GoRouter _router;

  Future<void> handleDeepLink(Uri uri) async {
    _talker.info('Deep link received', {'uri': uri.toString()});

    // Handle auth callback
    if (uri.scheme == 'voicenote' && uri.host == 'auth-callback') {
      await _handleAuthCallback(uri);
      return;
    }

    // Handle email verification
    if (uri.path.contains('/auth/v1/verify')) {
      await _handleEmailVerification(uri);
      return;
    }

    // Handle password reset
    if (uri.path.contains('/auth/v1/reset')) {
      await _handlePasswordReset(uri);
      return;
    }
  }

  Future<void> _handleAuthCallback(Uri uri) async {
    final accessToken = uri.queryParameters['access_token'];
    final refreshToken = uri.queryParameters['refresh_token'];

    if (accessToken != null) {
      // Session is already set by Supabase via deep link
      _talker.info('Auth callback successful');
      _router.go('/home');
    } else {
      _talker.error('Auth callback failed - no tokens');
      _router.go('/login');
    }
  }

  Future<void> _handleEmailVerification(Uri uri) async {
    final token = uri.queryParameters['token'];
    final type = uri.queryParameters['type'];

    if (token != null && type == 'email') {
      _talker.info('Email verification link clicked');
      // Supabase handles verification automatically
      _router.go('/home');
    }
  }

  Future<void> _handlePasswordReset(Uri uri) async {
    final token = uri.queryParameters['token'];

    if (token != null) {
      _talker.info('Password reset link clicked');
      // Navigate to reset password screen
      _router.go('/reset-password?token=$token');
    }
  }
}
```

#### Initialize Deep Link Listening in main.dart

```dart
// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final deepLinkHandler = ref.watch(deepLinkHandlerProvider);

    // Listen for incoming deep links
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        // User authenticated via deep link
        router.go('/home');
      }
    });

    return MaterialApp.router(
      routerConfig: router,
      title: 'VoiceNote',
    );
  }
}
```

### Route Protection with GoRouter

```dart
@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authState.maybeWhen(
        data: (authStateData) => authStateData.isAuthenticated,
        orElse: () => false,
      );

      final isLoading = authState.isLoading;
      final location = state.matchedLocation;

      if (isLoading && location != '/splash') return '/splash';

      final publicRoutes = ['/login', '/signup', '/forgot-password', '/splash'];
      final isPublicRoute = publicRoutes.contains(location);

      if (!isAuthenticated && !isPublicRoute) return '/login';
      if (isAuthenticated && (location == '/login' || location == '/signup')) {
        return '/home';
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(authState.asStream()),
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => ResetPasswordScreen(
          token: state.uri.queryParameters['token'],
        ),
      ),
      GoRoute(
        path: '/notes/:id',
        builder: (context, state) => NoteDetailScreen(
          noteId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
}
```

## Speech-to-Text Implementation

### Native Device APIs (Primary Approach)

**Why Native Device APIs:**
- Fastest latency (50-150ms, no network round-trip)
- Works offline (critical for any-time note capture)
- Zero API costs (uses free platform APIs)
- Excellent multilingual support (50+ languages)
- Privacy-friendly (audio doesn't leave device)
- Battery efficient (optimized by Apple/Google)

**No Audio Recording Storage:**
- Voice is used ONLY for transcription
- Audio data is not saved to device or cloud
- Transcribed text is immediately sent to Supabase
- No audio playback functionality needed
- Reduced storage requirements and privacy concerns

### Platform Configuration

**Minimum SDK Requirements:**
- **iOS**: iOS 10+ (SFSpeech framework)
- **Android**: Android 21+ (API level 21, SpeechRecognizer)

**Important Limitations:**
- Target use case: Commands and short phrases (not continuous transcription)
- Android/iOS stop recognition after ~1 minute of activity
- Designed for dictation-style note capture
- Best for notes under 500 words per recording session

#### iOS Configuration

**Info.plist Permissions:**

```xml
<!-- ios/Runner/Info.plist -->
<plist>
<dict>
  <!-- Microphone permission for speech recognition -->
  <key>NSMicrophoneUsageDescription</key>
  <string>This app needs access to your microphone to record voice notes</string>

  <!-- Speech recognition permission -->
  <key>NSSpeechRecognitionUsageDescription</key>
  <string>This app needs speech recognition to convert your voice to text</string>
</dict>
</plist>
```

#### Android Configuration

**AndroidManifest.xml Permissions:**

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Microphone permission -->
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>

    <!-- Internet permission (for Supabase) -->
    <uses-permission android:name="android.permission.INTERNET"/>

    <application>
        <!-- Your app configuration -->
    </application>
</manifest>
```

**Minimum SDK Version:**

```gradle
// android/app/build.gradle
android {
    defaultConfig {
        minSdkVersion 21  // Required for speech_to_text package
        targetSdkVersion 34
    }
}
```

### Language Support Configuration

**Supported Languages with Locale Codes:**

```dart
// lib/features/voice/domain/models/supported_languages.dart

class SupportedLanguage {
  final String code;
  final String name;
  final String displayName;

  const SupportedLanguage({
    required this.code,
    required this.name,
    required this.displayName,
  });
}

/// Supported languages for speech recognition
const supportedLanguages = [
  // German variants
  SupportedLanguage(
    code: 'de_DE',
    name: 'german',
    displayName: 'Deutsch (Deutschland)',
  ),
  SupportedLanguage(
    code: 'de_AT',
    name: 'german',
    displayName: 'Deutsch (Österreich)',
  ),
  SupportedLanguage(
    code: 'de_CH',
    name: 'german',
    displayName: 'Deutsch (Schweiz)',
  ),

  // English variants
  SupportedLanguage(
    code: 'en_US',
    name: 'english',
    displayName: 'English (United States)',
  ),
  SupportedLanguage(
    code: 'en_GB',
    name: 'english',
    displayName: 'English (United Kingdom)',
  ),
  SupportedLanguage(
    code: 'en_AU',
    name: 'english',
    displayName: 'English (Australia)',
  ),
  SupportedLanguage(
    code: 'en_CA',
    name: 'english',
    displayName: 'English (Canada)',
  ),
];
```

**Language-Specific Handling:**

```dart
// German umlauts are handled correctly by native APIs
// No special preprocessing required

// English dialects have minor vocabulary differences
// but all work seamlessly with the same codebase

// Language switching in UI
class VoiceInputScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLanguage = ref.watch(selectedLanguageProvider);

    return Column(
      children: [
        DropdownButton<String>(
          value: selectedLanguage,
          items: supportedLanguages.map((lang) {
            return DropdownMenuItem(
              value: lang.code,
              child: Text(lang.displayName),
            );
          }).toList(),
          onChanged: (code) {
            if (code != null) {
              ref.read(selectedLanguageProvider.notifier).state = code;
            }
          },
        ),
        VoiceRecordingButton(locale: selectedLanguage),
      ],
    );
  }
}
```

```dart
// Domain Layer - Repository Interface
abstract class VoiceRepository {
  Future<Result<void>> initialize();
  Future<Result<List<String>>> getAvailableLanguages();
  Future<Result<String>> startListening({required String locale});
  Future<Result<void>> stopListening();
  Stream<String> get transcriptionStream;
  bool get isListening;
}

// Data Layer - Native Implementation
class NativeVoiceRepository implements VoiceRepository {
  final SpeechToText _speech = SpeechToText();
  final _transcriptionController = StreamController<String>.broadcast();
  bool _isListening = false;

  @override
  Future<Result<void>> initialize() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) => _handleStatus(status),
        onError: (error) => _handleError(error),
      );

      if (!available) {
        return Result.failure(
          AppFailure.voiceInput(
            message: 'Speech recognition not available on this device',
          ),
        );
      }

      return const Result.success(null);
    } catch (e, stack) {
      return Result.failure(
        AppFailure.unknown(message: 'Failed to initialize speech recognition'),
      );
    }
  }

  @override
  Future<Result<String>> startListening({required String locale}) async {
    try {
      String transcription = '';

      await _speech.listen(
        onResult: (result) {
          transcription = result.recognizedWords;
          _transcriptionController.add(transcription);
        },
        localeId: locale, // 'de_DE' for German, 'en_US' for English
        listenMode: ListenMode.dictation,
        cancelOnError: true,
        partialResults: true, // Real-time updates
      );

      _isListening = true;
      return Result.success(transcription);
    } catch (e, stack) {
      return Result.failure(
        AppFailure.voiceInput(message: 'Failed to start listening'),
      );
    }
  }

  @override
  Stream<String> get transcriptionStream => _transcriptionController.stream;

  @override
  bool get isListening => _isListening;
}

// Application Layer - Riverpod Provider
@riverpod
class VoiceNotifier extends _$VoiceNotifier {
  @override
  FutureOr<String> build() async {
    await ref.read(voiceRepositoryProvider).initialize();
    return '';
  }

  Future<void> startListening(String locale) async {
    state = const AsyncValue.loading();
    final result = await ref
        .read(voiceRepositoryProvider)
        .startListening(locale: locale);

    result.when(
      success: (_) {
        // Listen to transcription stream
        ref.read(voiceRepositoryProvider).transcriptionStream.listen((text) {
          state = AsyncValue.data(text);
        });
      },
      failure: (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
    );
  }

  Future<void> stopListening() async {
    await ref.read(voiceRepositoryProvider).stopListening();
  }
}
```

## Tag System Architecture

### User-Specific Tag System (No Auto-Tagging, No Sharing)

**Key Requirements:**
- Users must manually tag every note
- Each user only sees their own tags (no cross-user visibility)
- No automatic tag suggestions or AI-powered tagging
- No shared tags between users (complete isolation)
- Tag colors for visual differentiation
- Full-text search combined with tag filtering

### Tag Data Models

```dart
// Domain Layer - Tag Model
@freezed
class Tag with _$Tag {
  const factory Tag({
    required String id,
    required String userId,
    required String name,
    @Default('#2196F3') String color,
    String? icon,
    String? description,
    required DateTime createdAt,
    @Default(0) int usageCount,
  }) = _Tag;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}

// Domain Layer - Tag Repository
abstract class TagRepository {
  Future<Result<List<Tag>>> getAllTags();
  Future<Result<Tag>> createTag({
    required String name,
    required String color,
    String? icon,
    String? description,
  });
  Future<Result<Tag>> updateTag(String id, {
    String? name,
    String? color,
    String? icon,
    String? description,
  });
  Future<Result<void>> deleteTag(String id);
  Future<Result<void>> addTagToNote(String noteId, String tagId);
  Future<Result<void>> removeTagFromNote(String noteId, String tagId);
  Future<Result<List<Tag>>> getTagsForNote(String noteId);
  Future<Result<List<Note>>> getNotesForTag(String tagId);
}
```

### Tag Input UI (Manual Only)

```dart
class TagInput extends ConsumerStatefulWidget {
  final List<Tag> selectedTags;
  final Function(List<Tag>) onTagsChanged;

  const TagInput({
    required this.selectedTags,
    required this.onTagsChanged,
  });

  @override
  ConsumerState<TagInput> createState() => _TagInputState();
}

class _TagInputState extends ConsumerState<TagInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final existingTags = ref.watch(allTagsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display selected tags as chips
        if (widget.selectedTags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedTags.map((tag) {
              return Chip(
                label: Text(tag.name),
                backgroundColor: Color(int.parse(
                  tag.color.replaceFirst('#', '0xff'),
                )),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeTag(tag),
              );
            }).toList(),
          ),

        const SizedBox(height: 8),

        // Autocomplete input for existing tags only
        existingTags.when(
          data: (tags) => Autocomplete<Tag>(
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return tags.where((tag) =>
                  !widget.selectedTags.contains(tag)
                ).take(10);
              }
              return tags.where((tag) {
                return tag.name.toLowerCase()
                    .contains(textEditingValue.text.toLowerCase()) &&
                    !widget.selectedTags.contains(tag);
              });
            },
            displayStringForOption: (Tag tag) => tag.name,
            onSelected: (Tag tag) => _addTag(tag),
            fieldViewBuilder: (context, controller, focusNode, _) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: 'Add tags',
                  hintText: 'Type to search existing tags',
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _createAndAddTag(value);
                    controller.clear();
                  }
                },
              );
            },
          ),
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const Text('Failed to load tags'),
        ),
      ],
    );
  }

  void _addTag(Tag tag) {
    final updated = List<Tag>.from(widget.selectedTags)..add(tag);
    widget.onTagsChanged(updated);
  }

  void _removeTag(Tag tag) {
    final updated = List<Tag>.from(widget.selectedTags)..remove(tag);
    widget.onTagsChanged(updated);
  }

  Future<void> _createAndAddTag(String name) async {
    // Check if tag exists
    final existingTags = await ref.read(allTagsProvider.future);
    final existing = existingTags.firstWhereOrNull(
      (t) => t.name.toLowerCase() == name.toLowerCase(),
    );

    if (existing != null) {
      _addTag(existing);
    } else {
      // Create new tag with default color
      final result = await ref.read(tagRepositoryProvider).createTag(
        name: name,
        color: '#2196F3', // Default blue
      );

      result.when(
        success: (newTag) => _addTag(newTag),
        failure: (failure) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create tag: ${failure.message}')),
          );
        },
      );
    }
  }
}
```

## Rich Text Editor Implementation

### flutter_quill (Recommended)

**Why flutter_quill:**
- Production-ready WYSIWYG editor
- Extensive formatting options (bold, italic, lists, headings, etc.)
- Clean, customizable toolbar
- Delta format for rich text representation
- Active maintenance and community support
- Excellent performance with large documents

```dart
// Domain Layer - Editor State
@freezed
class EditorState with _$EditorState {
  const factory EditorState({
    required QuillController controller,
    required bool isEditing,
    String? noteId,
  }) = _EditorState;
}

// Presentation Layer - Editor Widget
class RichTextEditor extends ConsumerStatefulWidget {
  final String? initialContent;
  final Function(String) onContentChanged;

  const RichTextEditor({
    this.initialContent,
    required this.onContentChanged,
  });

  @override
  ConsumerState<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends ConsumerState<RichTextEditor> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();

    if (widget.initialContent != null) {
      final document = Document.fromJson(
        jsonDecode(widget.initialContent!),
      );
      _controller = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    _controller.addListener(() {
      final json = jsonEncode(_controller.document.toDelta().toJson());
      widget.onContentChanged(json);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar
        QuillToolbar.simple(
          controller: _controller,
          configurations: const QuillSimpleToolbarConfigurations(
            multiRowsDisplay: false,
            showAlignmentButtons: true,
            showBoldButton: true,
            showItalicButton: true,
            showUnderLineButton: true,
            showStrikeThrough: true,
            showColorButton: false,
            showBackgroundColorButton: false,
            showListNumbers: true,
            showListBullets: true,
            showCodeBlock: false,
            showQuote: true,
            showIndent: true,
            showLink: false,
            showClearFormat: true,
          ),
        ),

        const Divider(height: 1),

        // Editor
        Expanded(
          child: QuillEditor.basic(
            controller: _controller,
            focusNode: _focusNode,
            configurations: const QuillEditorConfigurations(
              padding: EdgeInsets.all(16),
              placeholder: 'Start typing...',
              autoFocus: true,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
```

## Multilingual Full-Text Search

### Client-Side Language Detection

**Why Language Detection is Important:**
- Enables language-specific search optimization in PostgreSQL
- Improves search quality with proper stemming and stop words
- Allows filtering notes by language
- Provides user insights into their content language distribution

**Recommended Approach: flutter_langdetect**

```dart
// Add dependency
// pubspec.yaml
dependencies:
  flutter_langdetect: ^0.0.2
```

### Language Detection Implementation

**Initialize Once at App Startup:**

```dart
// main.dart
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize language detection (done once)
  await langdetect.initLangDetect();

  // Initialize Supabase
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  runApp(const MyApp());
}
```

**Language Detection Service:**

```dart
// lib/core/services/language_detection_service.dart

class LanguageDetectionService {
  /// Minimum text length for reliable detection
  static const int minTextLength = 20;

  /// Detect language from text and map to PostgreSQL configuration
  String detectLanguage(String text) {
    // Short text handling
    if (text.trim().length < minTextLength) {
      return 'simple'; // Use simple config for very short text
    }

    // Check if text is primarily code (heuristic)
    if (_isLikelyCode(text)) {
      return 'simple'; // Don't try to detect language for code
    }

    try {
      // Detect language using flutter_langdetect
      final language = langdetect.detect(text);

      // Map ISO 639-1 code to PostgreSQL configuration
      return _mapToPostgresConfig(language);
    } catch (e) {
      // Detection failed - fallback to simple
      return 'simple';
    }
  }

  /// Get detection confidence score (0.0 to 1.0)
  double getConfidence(String text) {
    if (text.trim().length < minTextLength) {
      return 0.0;
    }

    try {
      final probabilities = langdetect.getProbabilities(text);
      if (probabilities.isNotEmpty) {
        return probabilities.first.prob;
      }
    } catch (e) {
      return 0.0;
    }

    return 0.0;
  }

  /// Detect language with confidence score
  ({String language, double confidence}) detectWithConfidence(String text) {
    final language = detectLanguage(text);
    final confidence = getConfidence(text);
    return (language: language, confidence: confidence);
  }

  /// Heuristic to detect if text is likely code
  bool _isLikelyCode(String text) {
    // Simple heuristics for code detection
    final codePatterns = [
      RegExp(r'\b(function|class|const|let|var|if|else|return)\b'),
      RegExp(r'[{}();]'),
      RegExp(r'=>'),
      RegExp(r'\/\/|\/\*|\*\/'),
    ];

    int matches = 0;
    for (final pattern in codePatterns) {
      if (pattern.hasMatch(text)) matches++;
    }

    // If 3+ code patterns match, likely code
    return matches >= 3;
  }

  /// Map ISO 639-1 language codes to PostgreSQL text search configurations
  String _mapToPostgresConfig(String langCode) {
    const Map<String, String> langMap = {
      'ar': 'arabic',
      'hy': 'armenian',
      'eu': 'basque',
      'ca': 'catalan',
      'da': 'danish',
      'nl': 'dutch',
      'en': 'english',
      'fi': 'finnish',
      'fr': 'french',
      'de': 'german',
      'el': 'greek',
      'hi': 'hindi',
      'hu': 'hungarian',
      'id': 'indonesian',
      'ga': 'irish',
      'it': 'italian',
      'lt': 'lithuanian',
      'ne': 'nepali',
      'no': 'norwegian',
      'pt': 'portuguese',
      'ro': 'romanian',
      'ru': 'russian',
      'es': 'spanish',
      'sv': 'swedish',
      'ta': 'tamil',
      'tr': 'turkish',
      'yi': 'yiddish',
    };

    return langMap[langCode] ?? 'simple';
  }
}
```

**Integration with Note Repository:**

```dart
// lib/features/notes/data/repositories/supabase_note_repository.dart

class SupabaseNoteRepository implements NoteRepository {
  final SupabaseClient _client;
  final LanguageDetectionService _langDetect;

  @override
  Future<Result<Note>> createNote({
    required String title,
    required String content,
  }) async {
    try {
      // Detect language from combined title and content
      final text = '${title ?? ''} $content';
      final detection = _langDetect.detectWithConfidence(text);

      final data = await _client.from('notes').insert({
        'user_id': _client.auth.currentUser!.id,
        'title': title,
        'content': content,
        'language': detection.language,
        'language_confidence': detection.confidence,
      }).select().single();

      return Result.success(Note.fromJson(data));
    } on PostgrestException catch (e) {
      return Result.failure(e.toAppFailure(_l10n, _talker));
    }
  }

  @override
  Future<Result<Note>> updateNote({
    required String id,
    String? title,
    String? content,
  }) async {
    try {
      // Re-detect language if content changed
      String? detectedLanguage;
      double? confidence;

      if (title != null || content != null) {
        final text = '${title ?? ''} ${content ?? ''}';
        final detection = _langDetect.detectWithConfidence(text);
        detectedLanguage = detection.language;
        confidence = detection.confidence;
      }

      final data = await _client.from('notes').update({
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (detectedLanguage != null) 'language': detectedLanguage,
        if (confidence != null) 'language_confidence': confidence,
      }).eq('id', id).select().single();

      return Result.success(Note.fromJson(data));
    } on PostgrestException catch (e) {
      return Result.failure(e.toAppFailure(_l10n, _talker));
    }
  }
}
```

**Edge Cases Handling:**

```dart
/// Special cases for language detection
class LanguageDetectionEdgeCases {
  /// Handle very short notes (< 20 characters)
  /// - Use 'simple' configuration
  /// - Don't show language badge to user
  /// - Low confidence score

  /// Handle mixed-language notes
  /// - Detect primary language (most common)
  /// - Store primary language only
  /// - Note: PostgreSQL will use primary language for indexing

  /// Handle code snippets
  /// - Use heuristics to detect code
  /// - Use 'simple' configuration for code
  /// - Prevents misclassification as natural language

  /// Handle URLs and numbers
  /// - flutter_langdetect handles these well
  /// - These are treated as language-agnostic tokens

  /// Handle user corrections
  /// - Allow users to manually override detected language
  /// - Update language column and re-index
}
```

### PostgreSQL Database Schema with Language Support

**Updated Notes Table:**

```sql
-- Add language column to notes table
ALTER TABLE notes ADD COLUMN language TEXT DEFAULT 'simple';
ALTER TABLE notes ADD COLUMN language_confidence REAL;

-- Create index on language for filtering
CREATE INDEX notes_language_idx ON notes(language);
```

### PostgreSQL Search Configuration

**Dynamic Language-Specific Search:**

```sql
-- Updated search_vector with 'simple' configuration
ALTER TABLE notes
  ADD COLUMN search_vector TSVECTOR
  GENERATED ALWAYS AS (
    setweight(to_tsvector('simple', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('simple', content), 'B')
  ) STORED;

CREATE INDEX notes_search_idx ON notes USING GIN(search_vector);

-- Search function using 'simple'
CREATE OR REPLACE FUNCTION search_notes(
  search_query TEXT DEFAULT NULL,
  tag_ids UUID[] DEFAULT NULL,
  user_id_param UUID DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  title TEXT,
  content TEXT,
  rank REAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT
    n.id,
    n.title,
    n.content,
    CASE
      WHEN search_query IS NOT NULL THEN
        ts_rank(n.search_vector, websearch_to_tsquery('simple', search_query))
      ELSE 0
    END AS rank
  FROM notes n
  LEFT JOIN note_tags nt ON n.id = nt.note_id
  WHERE
    n.user_id = COALESCE(user_id_param, auth.uid())
    AND (tag_ids IS NULL OR nt.tag_id = ANY(tag_ids))
    AND (
      search_query IS NULL
      OR n.search_vector @@ websearch_to_tsquery('simple', search_query)
    )
  ORDER BY rank DESC, n.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Flutter Search Implementation

```dart
// Domain Layer - Search Models
@freezed
class SearchQuery with _$SearchQuery {
  const factory SearchQuery({
    String? text,
    List<String>? tagIds,
    @Default(SearchSort.dateDescending) SearchSort sortBy,
  }) = _SearchQuery;
}

enum SearchSort { dateAscending, dateDescending, relevance }

// Data Layer - Search Repository
class SupabaseNoteRepository implements NoteRepository {
  @override
  Future<Result<List<Note>>> searchNotes(SearchQuery query) async {
    try {
      final response = await _client.rpc('search_notes', {
        'search_query': query.text,
        'tag_ids': query.tagIds,
        'user_id_param': _client.auth.currentUser?.id,
      });

      final notes = (response as List)
          .map((json) => Note.fromJson(json))
          .toList();

      return Result.success(notes);
    } on PostgrestException catch (e, stack) {
      _talker.error('Search failed', e, stack);
      return Result.failure(
        AppFailure.database(message: 'Failed to search notes'),
      );
    }
  }
}

// Presentation Layer - Search Bar
class NoteSearchBar extends ConsumerStatefulWidget {
  @override
  ConsumerState<NoteSearchBar> createState() => _NoteSearchBarState();
}

class _NoteSearchBarState extends ConsumerState<NoteSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Search notes...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  _onSearchChanged('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: (value) {
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () {
          _onSearchChanged(value);
        });
      },
    );
  }

  void _onSearchChanged(String query) {
    ref.read(searchQueryProvider.notifier).update(
      (state) => state.copyWith(text: query.isEmpty ? null : query),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
```

## Bauhaus Design System

### Design Principles

**Core Bauhaus Philosophy:**
1. **Form follows function** - Every element serves a purpose
2. **Geometric precision** - Use of circles, squares, triangles
3. **Primary colors** - Red, blue, yellow + black, white, gray
4. **Typography as design** - Bold, sans-serif, hierarchical
5. **Asymmetric balance** - Dynamic layouts, not centered
6. **Grid-based structure** - Mathematical precision
7. **Negative space** - White space as design element

### Color Palette

```dart
// lib/core/presentation/theme/bauhaus_colors.dart

class BauhausColors {
  // Primary Bauhaus Colors
  static const bauhausRed = Color(0xFFE63946);
  static const bauhausBlue = Color(0xFF457B9D);
  static const bauhausYellow = Color(0xFFF1FA EE3);

  // Neutrals
  static const bauhausBlack = Color(0xFF1D3557);
  static const bauhausWhite = Color(0xFFF1FAEE);
  static const bauhausGray = Color(0xFFA8DADC);

  // Functional Colors
  static const success = Color(0xFF06D6A0);
  static const warning = bauhausYellow;
  static const error = bauhausRed;
  static const info = bauhausBlue;

  // Background Variations
  static const backgroundLight = Color(0xFFFDFDFD);
  static const backgroundDark = Color(0xFF0A1128);
  static const surface = bauhausWhite;
  static const surfaceDark = Color(0xFF1A2540);
}
```

### Typography System

```dart
// lib/core/presentation/theme/bauhaus_typography.dart

class BauhausTypography {
  static const String fontFamily = 'Inter'; // Modern geometric sans-serif

  static const displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w900,
    letterSpacing: 0,
    height: 1.16,
  );

  static const headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.25,
  );

  static const headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.29,
  );

  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );
}
```

### Theme Configuration

```dart
// lib/core/presentation/theme/bauhaus_theme.dart

ThemeData buildBauhausLightTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: BauhausColors.bauhausBlue,
      secondary: BauhausColors.bauhausRed,
      tertiary: BauhausColors.bauhausYellow,
      surface: BauhausColors.surface,
      background: BauhausColors.backgroundLight,
      error: BauhausColors.error,
      onPrimary: BauhausColors.bauhausWhite,
      onSecondary: BauhausColors.bauhausWhite,
      onSurface: BauhausColors.bauhausBlack,
      onBackground: BauhausColors.bauhausBlack,
    ),
    textTheme: TextTheme(
      displayLarge: BauhausTypography.displayLarge,
      displayMedium: BauhausTypography.displayMedium,
      headlineLarge: BauhausTypography.headlineLarge,
      headlineMedium: BauhausTypography.headlineMedium,
      bodyLarge: BauhausTypography.bodyLarge,
      bodyMedium: BauhausTypography.bodyMedium,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0), // Sharp corners
        side: BorderSide(color: BauhausColors.bauhausBlack, width: 2),
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: BauhausColors.backgroundLight,
      foregroundColor: BauhausColors.bauhausBlack,
      centerTitle: false, // Asymmetric
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0), // Sharp corners
        borderSide: BorderSide(color: BauhausColors.bauhausBlack, width: 2),
      ),
      filled: true,
      fillColor: BauhausColors.surface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Perfect squares/rectangles
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    ),
  );
}
```

## Error Handling & Localization

### Result<T> Pattern with Sealed Classes

```dart
// lib/core/domain/result.dart

@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(AppFailure failure) = Failure<T>;
}

extension ResultX<T> on Result<T> {
  R when<R>({
    required R Function(T data) success,
    required R Function(AppFailure failure) failure,
  }) {
    return map(
      success: (s) => success(s.data),
      failure: (f) => failure(f.failure),
    );
  }
}

// lib/core/domain/failures/app_failure.dart

@freezed
class AppFailure with _$AppFailure {
  const factory AppFailure.network({
    required String message,
    String? details,
  }) = NetworkFailure;

  const factory AppFailure.authentication({
    required String message,
    String? code,
  }) = AuthenticationFailure;

  const factory AppFailure.database({
    required String message,
    String? code,
  }) = DatabaseFailure;

  const factory AppFailure.voiceInput({
    required String message,
    String? code,
  }) = VoiceInputFailure;

  const factory AppFailure.validation({
    required String message,
    String? field,
  }) = ValidationFailure;

  const factory AppFailure.permission({
    required String message,
    String? resource,
  }) = PermissionFailure;

  const factory AppFailure.server({
    required String message,
    int? statusCode,
  }) = ServerFailure;

  const factory AppFailure.unknown({
    required String message,
    Object? exception,
  }) = UnknownFailure;
}
```

### Supabase Error Code Enums

**Why Enum-Based Error Handling:**
- Compile-time safety with exhaustive matching
- No string-based error matching
- Excellent IDE autocomplete support
- Centralized error code definitions
- Easy to maintain and extend

**Error Code Implementation:**

```dart
// lib/core/errors/supabase_error_codes.dart

/// Auth error codes from Supabase Auth
enum AuthErrorCode {
  invalidCredentials,
  sessionExpired,
  emailNotConfirmed,
  weakPassword,
  emailAlreadyExists,
  userNotFound,
  invalidToken,
  unknown;

  factory AuthErrorCode.parse(String? code) {
    if (code == null) return AuthErrorCode.unknown;
    return switch (code) {
      'invalid_credentials' => AuthErrorCode.invalidCredentials,
      'session_expired' => AuthErrorCode.sessionExpired,
      'email_not_confirmed' => AuthErrorCode.emailNotConfirmed,
      'weak_password' => AuthErrorCode.weakPassword,
      'user_already_exists' || 'email_already_exists' => AuthErrorCode.emailAlreadyExists,
      'user_not_found' => AuthErrorCode.userNotFound,
      'invalid_token' => AuthErrorCode.invalidToken,
      _ => AuthErrorCode.unknown,
    };
  }

  String getMessage(AppLocalizations l10n) {
    return switch (this) {
      AuthErrorCode.invalidCredentials => l10n.errorAuthInvalidCredentials,
      AuthErrorCode.sessionExpired => l10n.errorAuthSessionExpired,
      AuthErrorCode.emailNotConfirmed => l10n.errorAuthEmailNotConfirmed,
      AuthErrorCode.weakPassword => l10n.errorAuthWeakPassword,
      AuthErrorCode.emailAlreadyExists => l10n.errorAuthEmailExists,
      AuthErrorCode.userNotFound => l10n.errorAuthUserNotFound,
      AuthErrorCode.invalidToken => l10n.errorAuthInvalidToken,
      AuthErrorCode.unknown => l10n.errorAuthUnknown,
    };
  }

  AppFailure toFailure(AppLocalizations l10n) {
    return switch (this) {
      AuthErrorCode.invalidCredentials ||
      AuthErrorCode.sessionExpired ||
      AuthErrorCode.invalidToken =>
        AppFailure.authentication(message: getMessage(l10n), code: name),

      AuthErrorCode.weakPassword ||
      AuthErrorCode.emailNotConfirmed =>
        AppFailure.validation(message: getMessage(l10n), field: 'auth'),

      _ => AppFailure.authentication(message: getMessage(l10n), code: name),
    };
  }
}

/// PostgREST error codes (PGRST*)
enum PostgrestErrorCode {
  jwtExpired,          // PGRST301
  notFound,            // PGRST116
  functionNotFound,    // PGRST202
  databaseUnavailable, // PGRST001
  unknown;

  factory PostgrestErrorCode.parse(String? code) {
    if (code == null) return PostgrestErrorCode.unknown;
    return switch (code) {
      'PGRST301' => PostgrestErrorCode.jwtExpired,
      'PGRST116' => PostgrestErrorCode.notFound,
      'PGRST202' => PostgrestErrorCode.functionNotFound,
      'PGRST001' => PostgrestErrorCode.databaseUnavailable,
      _ => PostgrestErrorCode.unknown,
    };
  }

  String getMessage(AppLocalizations l10n) {
    return switch (this) {
      PostgrestErrorCode.jwtExpired => l10n.errorAuthSessionExpired,
      PostgrestErrorCode.notFound => l10n.errorDatabaseNotFound,
      PostgrestErrorCode.functionNotFound => l10n.errorDatabaseFunctionNotFound,
      PostgrestErrorCode.databaseUnavailable => l10n.errorDatabaseUnavailable,
      PostgrestErrorCode.unknown => l10n.errorDatabaseGeneric,
    };
  }

  AppFailure toFailure(AppLocalizations l10n) {
    return switch (this) {
      PostgrestErrorCode.jwtExpired =>
        AppFailure.authentication(message: getMessage(l10n), code: name),
      PostgrestErrorCode.databaseUnavailable =>
        AppFailure.server(message: getMessage(l10n)),
      _ =>
        AppFailure.database(message: getMessage(l10n), code: name),
    };
  }
}

/// PostgreSQL error codes (numeric)
enum PostgresErrorCode {
  uniqueViolation,      // 23505
  notNullViolation,     // 23502
  foreignKeyViolation,  // 23503
  insufficientPrivilege,// 42501
  stringTooLong,        // 22001
  unknown;

  factory PostgresErrorCode.parse(String? code) {
    if (code == null) return PostgresErrorCode.unknown;
    return switch (code) {
      '23505' => PostgresErrorCode.uniqueViolation,
      '23502' => PostgresErrorCode.notNullViolation,
      '23503' => PostgresErrorCode.foreignKeyViolation,
      '42501' => PostgresErrorCode.insufficientPrivilege,
      '22001' => PostgresErrorCode.stringTooLong,
      _ => PostgresErrorCode.unknown,
    };
  }

  String getMessage(AppLocalizations l10n) {
    return switch (this) {
      PostgresErrorCode.uniqueViolation => l10n.errorPgUniqueViolation,
      PostgresErrorCode.notNullViolation => l10n.errorPgNotNull,
      PostgresErrorCode.foreignKeyViolation => l10n.errorPgForeignKey,
      PostgresErrorCode.insufficientPrivilege => l10n.errorPgPermission,
      PostgresErrorCode.stringTooLong => l10n.errorPgStringTooLong,
      PostgresErrorCode.unknown => l10n.errorDatabaseGeneric,
    };
  }

  AppFailure toFailure(AppLocalizations l10n) {
    return switch (this) {
      PostgresErrorCode.uniqueViolation ||
      PostgresErrorCode.notNullViolation ||
      PostgresErrorCode.stringTooLong =>
        AppFailure.validation(message: getMessage(l10n)),

      PostgresErrorCode.insufficientPrivilege =>
        AppFailure.permission(message: getMessage(l10n)),

      _ =>
        AppFailure.database(message: getMessage(l10n), code: name),
    };
  }
}

/// Storage error codes
enum StorageErrorCode {
  noSuchKey,        // File not found
  entityTooLarge,   // File too large
  accessDenied,     // Permission denied
  invalidJWT,       // Auth failed
  unknown;

  factory StorageErrorCode.parse(String? code) {
    if (code == null) return StorageErrorCode.unknown;
    return switch (code) {
      'NoSuchKey' => StorageErrorCode.noSuchKey,
      'EntityTooLarge' => StorageErrorCode.entityTooLarge,
      'AccessDenied' => StorageErrorCode.accessDenied,
      'InvalidJWT' => StorageErrorCode.invalidJWT,
      _ => StorageErrorCode.unknown,
    };
  }

  String getMessage(AppLocalizations l10n) {
    return switch (this) {
      StorageErrorCode.noSuchKey => l10n.errorStorageNotFound,
      StorageErrorCode.entityTooLarge => l10n.errorStorageFileTooLarge,
      StorageErrorCode.accessDenied => l10n.errorStorageAccessDenied,
      StorageErrorCode.invalidJWT => l10n.errorAuthSessionExpired,
      StorageErrorCode.unknown => l10n.errorStorageGeneric,
    };
  }

  AppFailure toFailure(AppLocalizations l10n) {
    return switch (this) {
      StorageErrorCode.invalidJWT =>
        AppFailure.authentication(message: getMessage(l10n)),

      StorageErrorCode.accessDenied =>
        AppFailure.permission(message: getMessage(l10n)),

      StorageErrorCode.entityTooLarge =>
        AppFailure.validation(message: getMessage(l10n)),

      _ =>
        AppFailure.unknown(message: getMessage(l10n)),
    };
  }
}
```

### Supabase Exception Extensions

**Clean Exception Handling with Extension Methods:**

```dart
// lib/core/errors/supabase_error_extensions.dart

extension AuthExceptionX on AuthException {
  AppFailure toAppFailure(AppLocalizations l10n, Talker talker) {
    talker.error('AuthException', {
      'message': message,
      'statusCode': statusCode,
      'code': code,
    });

    final errorCode = AuthErrorCode.parse(code);

    if (errorCode == AuthErrorCode.unknown && code != null) {
      talker.warning('Unknown auth error code: $code');
    }

    return errorCode.toFailure(l10n);
  }
}

extension PostgrestExceptionX on PostgrestException {
  AppFailure toAppFailure(AppLocalizations l10n, Talker talker) {
    talker.error('PostgrestException', {
      'message': message,
      'code': code,
      'details': details,
      'hint': hint,
    });

    // Try PostgREST codes (PGRST*)
    if (code != null && code!.startsWith('PGRST')) {
      return PostgrestErrorCode.parse(code).toFailure(l10n);
    }

    // Try PostgreSQL codes (numeric)
    if (code != null && RegExp(r'^\d{5}$').hasMatch(code!)) {
      return PostgresErrorCode.parse(code).toFailure(l10n);
    }

    return AppFailure.server(message: l10n.errorDatabaseGeneric);
  }
}

extension StorageExceptionX on StorageException {
  AppFailure toAppFailure(AppLocalizations l10n, Talker talker) {
    talker.error('StorageException', {
      'message': message,
      'statusCode': statusCode,
      'error': error,
    });

    return StorageErrorCode.parse(error).toFailure(l10n);
  }
}
```

### Repository Error Handling Pattern

**Clean Repository Implementation:**

```dart
// Example: Note Repository with clean error handling
class SupabaseNoteRepository implements NoteRepository {
  final SupabaseClient _client;
  final AppLocalizations _l10n;
  final Talker _talker;

  @override
  Future<Result<Note>> createNote(String content) async {
    try {
      final data = await _client.from('notes').insert({
        'user_id': _client.auth.currentUser!.id,
        'content': content,
      }).select().single();

      return Result.success(Note.fromJson(data));

    } on PostgrestException catch (e) {
      return Result.failure(e.toAppFailure(_l10n, _talker));

    } on AuthException catch (e) {
      return Result.failure(e.toAppFailure(_l10n, _talker));

    } on StorageException catch (e) {
      return Result.failure(e.toAppFailure(_l10n, _talker));

    } on SocketException catch (e, stack) {
      _talker.error('Network error', e, stack);
      return Result.failure(
        AppFailure.network(message: _l10n.errorNetwork),
      );

    } catch (e, stack) {
      _talker.error('Unexpected error', e, stack);
      return Result.failure(
        AppFailure.unknown(message: _l10n.errorUnknown, exception: e),
      );
    }
  }
}
```

### Error Display Service

**Tiered UI Error Display Strategy:**

```dart
// lib/core/presentation/services/error_display_service.dart

@riverpod
class ErrorDisplayService extends _$ErrorDisplayService {
  @override
  void build() {}

  void showError(
    BuildContext context,
    AppFailure failure, {
    VoidCallback? onRetry,
  }) {
    failure.when(
      validation: (message, field) {
        // Inline validation errors - handled by form fields
        // No UI action needed here
      },
      network: (message, details) {
        // SnackBar with retry action
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
            action: onRetry != null
                ? SnackBarAction(
                    label: 'Retry',
                    onPressed: onRetry,
                    textColor: Colors.white,
                  )
                : null,
          ),
        );
      },
      authentication: (message, code) {
        // Dialog with navigation to login
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.error_outline, size: 48, color: Colors.red),
            title: const Text('Authentication Required'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/login');
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        );
      },
      permission: (message, resource) {
        // Permission denied dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.lock_outline, size: 48, color: Colors.orange),
            title: const Text('Permission Denied'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
      server: (message, statusCode) {
        // Server error SnackBar with retry
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 7),
            action: onRetry != null
                ? SnackBarAction(
                    label: 'Retry',
                    onPressed: onRetry,
                    textColor: Colors.white,
                  )
                : null,
          ),
        );
      },
      database: (message, code) {
        // Database error SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 5),
          ),
        );
      },
      voiceInput: (message, code) {
        // Voice input error SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.mic_off, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      },
      unknown: (message, exception) {
        // Generic error SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      },
    );
  }
}

/// UI Component Mapping:
/// - Validation: Inline text (red) - Persistent until fixed
/// - Network: SnackBar (orange) - 5 seconds with Retry
/// - Authentication: Dialog (red) - User-controlled with Sign In
/// - Permission: Dialog (orange) - User-controlled with OK
/// - Server: SnackBar (red) - 7 seconds with Retry
/// - Database: SnackBar (dark red) - 5 seconds
/// - VoiceInput: SnackBar (red) - 4 seconds
/// - Unknown: SnackBar (red) - 4 seconds
```

### Riverpod Error Listener Pattern

**Automatic Error Display in UI:**

```dart
// Example: Notes screen with automatic error display
class NotesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for errors and display them automatically
    ref.listen(notesNotifierProvider, (prev, next) {
      next.whenOrNull(
        error: (error, stack) {
          if (error is AppFailure) {
            ref.read(errorDisplayServiceProvider).showError(
              context,
              error,
              onRetry: () => ref.invalidate(notesNotifierProvider),
            );
          }
        },
      );
    });

    final state = ref.watch(notesNotifierProvider);

    return state.when(
      data: (notes) => NotesList(notes),
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(), // Handled by listener
    );
  }
}
```

### Localization Setup

```yaml
# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

```json
// lib/l10n/app_en.arb
{
  "@@locale": "en",

  "appTitle": "VoiceNote",

  "email": "Email",
  "password": "Password",
  "signIn": "Sign In",
  "signUp": "Sign Up",
  "signOut": "Sign Out",
  "forgotPassword": "Forgot password?",

  "errorValidationEmailRequired": "Email is required",
  "errorValidationEmail": "Please enter a valid email",
  "errorValidationPasswordRequired": "Password is required",
  "errorValidationPasswordLength": "Password must be at least 8 characters",

  "errorNetworkTitle": "Network Error",
  "errorNetworkMessage": "Please check your internet connection",
  "errorAuthenticationTitle": "Authentication Error",
  "errorAuthenticationMessage": "Invalid email or password",

  "notesTitle": "Notes",
  "notesEmpty": "No notes yet. Start by creating your first note!",
  "noteCreate": "Create Note",
  "noteEdit": "Edit Note",
  "noteDelete": "Delete Note",
  "noteDeleteConfirm": "Are you sure you want to delete this note?",

  "voiceInputStart": "Tap to speak",
  "voiceInputListening": "Listening...",
  "voiceInputProcessing": "Processing...",

  "tagsTitle": "Tags",
  "tagsAdd": "Add tags",
  "tagsCreate": "Create tag",
  "tagsEmpty": "No tags yet",

  "searchPlaceholder": "Search notes...",
  "searchNoResults": "No results found"
}
```

```json
// lib/l10n/app_de.arb
{
  "@@locale": "de",

  "appTitle": "VoiceNote",

  "email": "E-Mail",
  "password": "Passwort",
  "signIn": "Anmelden",
  "signUp": "Registrieren",
  "signOut": "Abmelden",
  "forgotPassword": "Passwort vergessen?",

  "errorValidationEmailRequired": "E-Mail ist erforderlich",
  "errorValidationEmail": "Bitte geben Sie eine gültige E-Mail ein",
  "errorValidationPasswordRequired": "Passwort ist erforderlich",
  "errorValidationPasswordLength": "Passwort muss mindestens 8 Zeichen lang sein",

  "errorNetworkTitle": "Netzwerkfehler",
  "errorNetworkMessage": "Bitte überprüfen Sie Ihre Internetverbindung",
  "errorAuthenticationTitle": "Authentifizierungsfehler",
  "errorAuthenticationMessage": "Ungültige E-Mail oder Passwort",

  "notesTitle": "Notizen",
  "notesEmpty": "Noch keine Notizen. Erstellen Sie Ihre erste Notiz!",
  "noteCreate": "Notiz erstellen",
  "noteEdit": "Notiz bearbeiten",
  "noteDelete": "Notiz löschen",
  "noteDeleteConfirm": "Möchten Sie diese Notiz wirklich löschen?",

  "voiceInputStart": "Zum Sprechen tippen",
  "voiceInputListening": "Hört zu...",
  "voiceInputProcessing": "Verarbeite...",

  "tagsTitle": "Tags",
  "tagsAdd": "Tags hinzufügen",
  "tagsCreate": "Tag erstellen",
  "tagsEmpty": "Noch keine Tags",

  "searchPlaceholder": "Notizen durchsuchen...",
  "searchNoResults": "Keine Ergebnisse gefunden"
}
```

## Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)

**Infrastructure Setup**
- Initialize Flutter project with Clean Architecture structure
- Configure Supabase project and database
- Set up environment variables with envied
- Configure build_runner for code generation
- Implement core error handling (Result<T>, AppFailure)
- Set up Talker logging
- Configure localization (English + German)

**Authentication**
- Implement email/password authentication
- Create auth domain models and repository
- Build Supabase auth integration
- Configure Row Level Security policies
- Implement GoRouter with auth redirect
- Build login, signup, forgot password screens

**Deliverables:**
- Working authentication flow
- Protected routes
- Error handling framework
- Logging system

### Phase 2: Core Note Features (Weeks 3-4)

**Note Management**
- Create notes database schema
- Implement note domain models
- Build note repository with CRUD operations
- Create notes list screen
- Build note detail/editor screen
- Integrate flutter_quill for rich text editing
- Implement full-text search

**Deliverables:**
- Create, read, update, delete notes
- Rich text editing with formatting
- Basic search functionality

### Phase 3: Voice Input (Weeks 5-6)

**Speech-to-Text Integration**
- Implement speech_to_text package
- Create voice input repository
- Build voice input UI with real-time transcription
- Handle microphone permissions
- Add language selection (English/German)
- Implement voice button widget
- Create voice-to-note flow

**Deliverables:**
- Working voice input
- Real-time transcription display
- Language switching
- Voice note creation

### Phase 4: Tag System (Weeks 7-8)

**Tag Implementation**
- Create tags database schema with RLS
- Implement tag domain models and repository
- Build tag input UI with autocomplete
- Create tag management screen
- Implement tag filtering
- Add color picker for tags
- Integrate tags with search

**Deliverables:**
- Manual tag creation and assignment
- Tag autocomplete
- Tag filtering
- Color-coded tags

### Phase 5: Bauhaus Design System (Weeks 9-10)

**Design Implementation**
- Define Bauhaus color palette
- Create typography system
- Build custom theme
- Design geometric UI components
- Implement asymmetric layouts
- Create custom app bar
- Design note cards with Bauhaus aesthetic
- Build custom buttons and inputs

**Deliverables:**
- Complete Bauhaus theme
- Redesigned UI components
- Consistent design language

### Phase 6: Polish & Testing (Weeks 11-12)

**Quality Assurance**
- Unit tests for repositories
- Widget tests for UI components
- Integration tests for critical flows
- Performance optimization
- Accessibility improvements
- Error message refinement
- User feedback implementation
- Bug fixes

**Deliverables:**
- Comprehensive test coverage
- Optimized performance
- Accessible UI
- Production-ready app

### Phase 7: Deployment (Week 13)

**Release Preparation**
- App store assets and screenshots
- App store descriptions
- Privacy policy and terms
- Beta testing (TestFlight/Internal Testing)
- Final bug fixes
- Production deployment
- App store submission

**Deliverables:**
- Published app on App Store and Google Play

## Security Best Practices

### API Key Management

```dart
// .env file (in .gitignore)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

// lib/core/env/env.dart
@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'SUPABASE_URL')
  static String supabaseUrl = _Env.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static String supabaseAnonKey = _Env.supabaseAnonKey;
}
```

### Row Level Security (RLS)

**Critical Security Rules:**
1. Enable RLS on ALL user-owned tables
2. NEVER expose service_role key in client apps
3. Use auth.uid() in all RLS policies
4. Add indexes on user_id columns for performance
5. Test policies with multiple users
6. Monitor RLS query performance

### Data Privacy

**User Data Isolation:**
- Each user's data completely isolated via RLS
- Tags are user-specific (no cross-user visibility)
- No audio recording storage (voice used only for transcription)
- All data encrypted in transit (HTTPS)
- Supabase encrypts data at rest

## Performance Optimization

### Database Indexes

```sql
-- Critical indexes for performance
CREATE INDEX notes_user_id_idx ON notes(user_id);
CREATE INDEX notes_created_at_idx ON notes(created_at DESC);
CREATE INDEX notes_search_idx ON notes USING GIN(search_vector);
CREATE INDEX notes_user_created_idx ON notes(user_id, created_at DESC);

CREATE INDEX tags_user_id_idx ON tags(user_id);
CREATE INDEX tags_name_idx ON tags(LOWER(name));
CREATE INDEX tags_usage_count_idx ON tags(usage_count DESC);

CREATE INDEX note_tags_note_id_idx ON note_tags(note_id);
CREATE INDEX note_tags_tag_id_idx ON note_tags(tag_id);
```

### Caching Strategy

```dart
// Simple in-memory cache for tags
class TagCache {
  static final Map<String, List<Tag>> _cache = {};
  static const cacheDuration = Duration(minutes: 5);

  static Future<List<Tag>> getUserTags(String userId) async {
    final cacheKey = 'tags_$userId';
    final cached = _cache[cacheKey];

    if (cached != null) return cached;

    // Fetch from database
    final tags = await _fetchFromDatabase(userId);
    _cache[cacheKey] = tags;

    // Invalidate after duration
    Future.delayed(cacheDuration, () => _cache.remove(cacheKey));

    return tags;
  }

  static void invalidate(String userId) {
    _cache.remove('tags_$userId');
  }
}
```

## Testing Strategy

### Unit Tests

```dart
// Repository tests
void main() {
  group('SupabaseAuthRepository', () {
    late SupabaseAuthRepository repository;
    late MockSupabaseClient mockClient;

    setUp(() {
      mockClient = MockSupabaseClient();
      repository = SupabaseAuthRepository(mockClient);
    });

    test('signInWithEmail returns user on success', () async {
      // Arrange
      when(() => mockClient.auth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => AuthResponse(
        user: MockUser(),
        session: MockSession(),
      ));

      // Act
      final result = await repository.signInWithEmail(
        'test@example.com',
        'password123',
      );

      // Assert
      expect(result, isA<Success<User>>());
    });
  });
}
```

### Widget Tests

```dart
void main() {
  testWidgets('LoginScreen shows email and password fields', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
```

## Accessibility Considerations

**Semantic Labels:**
- All interactive elements have semantic labels
- Screen reader support for voice input status
- Alternative text for icons and images

**Keyboard Navigation:**
- Full keyboard support for all interactions
- Logical tab order
- Keyboard shortcuts for common actions

**Visual:**
- High contrast Bauhaus colors meet WCAG AA standards
- Scalable text with TextScaler support
- Clear visual hierarchy

**Voice Input:**
- Core feature naturally supports hands-free operation
- Benefits users with motor impairments
- Alternative text input always available

## Monitoring & Analytics

### Talker Integration

```dart
// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Talker for logging
  final talker = TalkerFlutter.init(
    settings: TalkerSettings(
      useHistory: true,
      maxHistoryItems: 1000,
      useConsoleLogs: kDebugMode,
    ),
  );

  // Global error handling
  FlutterError.onError = (details) {
    talker.handle(details.exception, details.stack, 'Flutter Error');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    talker.handle(error, stack, 'Platform Error');
    return true;
  };

  // Initialize Supabase
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(
    ProviderScope(
      observers: [TalkerRiverpodObserver(talker: talker)],
      child: MyApp(talker: talker),
    ),
  );
}
```

## Key Success Metrics

**User Engagement:**
- Daily active users (DAU)
- Notes created per user per week
- Voice input usage rate (% of notes created via voice)
- Average session duration

**Performance:**
- App launch time < 2 seconds
- Voice transcription latency < 200ms
- Search results < 300ms
- 99.9% uptime

**Quality:**
- Crash-free rate > 99.5%
- User retention rate > 60% (30 days)
- App store rating > 4.5 stars
- Customer support ticket volume

## References & Resources

### Official Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [Riverpod 3.0 Documentation](https://riverpod.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)

### Package References
- [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)
- [supabase_flutter](https://pub.dev/packages/supabase_flutter)
- [speech_to_text](https://pub.dev/packages/speech_to_text)
- [flutter_quill](https://pub.dev/packages/flutter_quill)
- [freezed](https://pub.dev/packages/freezed)
- [go_router](https://pub.dev/packages/go_router)
- [envied](https://pub.dev/packages/envied)
- [talker_flutter](https://pub.dev/packages/talker_flutter)

### Design Resources
- [Bauhaus Movement Overview](https://www.britannica.com/topic/Bauhaus)
- [Material Design 3](https://m3.material.io/)
- [Flutter Theme Documentation](https://docs.flutter.dev/cookbook/design/themes)

### Architecture References
- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture Guide](https://resocoder.com/flutter-clean-architecture-tdd/)

---

**Document Version:** 1.0
**Last Updated:** December 2, 2025
**Research Compiled By:** Claude (AI Assistant)
**Target Audience:** Development team building voice-first note-taking app

## Next Steps

1. **Review this document** with the development team
2. **Set up development environment** (Flutter, Supabase, tools)
3. **Create Supabase project** and configure database schema
4. **Initialize Flutter project** with Clean Architecture structure
5. **Begin Phase 1 implementation** (Foundation)
6. **Schedule regular check-ins** to track progress against roadmap

---

## Appendix: Quick Start Commands

```bash
# Create Flutter project
flutter create voicenote_app
cd voicenote_app

# Add core dependencies
flutter pub add flutter_riverpod riverpod_annotation supabase_flutter go_router freezed freezed_annotation json_annotation speech_to_text flutter_quill flutter_secure_storage envied talker_flutter intl permission_handler

# Add dev dependencies
flutter pub add --dev build_runner riverpod_generator freezed json_serializable envied_generator flutter_lints mocktail

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run
```
