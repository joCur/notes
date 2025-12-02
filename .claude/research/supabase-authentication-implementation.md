# Research: Supabase Authentication Implementation for Voice-First Note-Taking App

## Executive Summary

Implementing authentication for a voice-first note-taking app built with Flutter, Supabase, Riverpod 3, and Clean Architecture requires a focused approach that balances security, user experience, and architectural integrity. This research explores the essential authentication strategy using email/password authentication, considering the existing architectural decisions (Clean Architecture, Riverpod 3, GoRouter, Freezed, Talker) and the product vision of a fast, hands-free note-taking experience.

**Key Recommendations:**

- **Authentication Method**: Email/password as the primary and only authentication method
- **State Management**: Use Riverpod 3's StreamProvider to listen to Supabase's `onAuthStateChange` for reactive authentication state management
- **Security**: Leverage Supabase Row Level Security (RLS) policies to secure user notes at the database level
- **Session Management**: Utilize Supabase's automatic token refresh with `flutter_secure_storage` for secure session persistence
- **Architecture Integration**: Implement authentication through Clean Architecture layers with Result<T> types for type-safe error handling
- **Route Protection**: Integrate authentication state with GoRouter for automatic route guards and navigation

This approach delivers production-ready authentication with minimal complexity while maintaining the security and architectural quality required for a professional application.

## Research Scope

### What Was Researched
- Supabase email/password authentication best practices (2025)
- Flutter + Supabase + Riverpod authentication patterns
- Row Level Security (RLS) policies and implementation
- Session management and automatic token refresh strategies
- API key security and environment variable management
- Secure token storage (flutter_secure_storage)
- Integration with existing Clean Architecture
- Route protection with GoRouter

### What Was Explicitly Excluded
- Social OAuth authentication (Google, Apple, etc.)
- Multi-factor authentication (MFA/TOTP)
- Biometric authentication (fingerprint/Face ID)
- Passwordless authentication (magic links, SMS OTP)
- Detailed error handling patterns (covered in separate document)
- Enterprise SSO and SAML integration
- Custom authentication backend implementation

### Research Methodology
- Analysis of official Supabase and Flutter documentation (2025)
- Review of Supabase authentication best practices
- Investigation of Riverpod authentication state management patterns
- Examination of RLS security implementation strategies
- Assessment of integration with existing Clean Architecture

## Current State Analysis

### Existing Implementation

Based on the architecture research documents, the application has:
- **Architecture**: Feature-First Clean Architecture with 4 layers (Presentation, Application, Domain, Data)
- **State Management**: Riverpod 3 with @riverpod macro for compile-time safety
- **Routing**: GoRouter for declarative navigation
- **Backend**: Supabase (PostgreSQL, Auth, Realtime, Storage)
- **Error Handling**: Sealed classes with Freezed + Result<T> pattern
- **Localization**: intl + gen_l10n with ARB files for type-safe translations
- **Logging**: Talker for comprehensive error tracking
- **Data Models**: Freezed for immutable models

**Current Authentication Gaps:**
- No authentication implementation yet (greenfield project)
- No user management or profile handling
- No RLS policies defined
- No route protection configured

### Industry Standards (2025)

**Supabase Auth Evolution:**
- PKCE flow is now the default for authentication involving deep links (enhanced security)
- Automatic session persistence via `flutter_secure_storage` (no manual storage needed)
- JWT tokens automatically refresh in background with `onAuthStateChange` events
- Email verification is handled automatically by Supabase
- Password reset flow built into Supabase Auth

**Flutter Authentication Best Practices:**
- Riverpod StreamProvider for reactive auth state management
- Clean Architecture with repository pattern for auth operations
- Secure token storage using platform-specific keystores
- Route guards integrated with state management

**Security Standards:**
- Row Level Security (RLS) mandatory for all public schema tables
- API keys stored in environment variables, never in source control
- Service role keys never exposed in client apps (backend only)
- JWT tokens with 1-hour expiration (standard)
- Encrypted storage for refresh tokens and credentials

## Technical Analysis

### Email/Password Authentication

**Description**: Traditional email and password sign-up and sign-in flow using Supabase Auth. Users create accounts with email and password, receive verification emails, and can reset passwords.

**Pros**:
- Familiar to all users, lowest friction for initial sign-up
- No dependency on third-party OAuth providers
- Complete control over user experience
- Works offline for credential storage (sign-in requires network)
- Email verification provides additional security layer
- Password reset flow well-established
- No platform-specific configuration required
- Works on all platforms (iOS, Android, web, desktop)
- Simple to implement and maintain

**Cons**:
- Users must remember another password
- Password strength enforcement required
- Email verification step adds slight friction
- Potential for password reuse across services
- Support requests for forgotten passwords

**Use Cases**:
- Primary authentication method for all users
- When user wants full control and simplicity
- Users prioritizing privacy and independence

### Implementation Architecture

The authentication implementation follows Clean Architecture principles with four distinct layers:

**Domain Layer (Core Business Logic)**:
- User entity model
- AuthRepository interface
- AuthState sealed union type
- No framework dependencies

**Data Layer (External Interfaces)**:
- SupabaseAuthRepository implementation
- Supabase client integration
- Session persistence handling

**Application Layer (Use Cases & State)**:
- Riverpod providers for auth state
- AuthNotifier for state management
- Auth state stream provider

**Presentation Layer (UI)**:
- Login/SignUp screens
- Form validation
- Error display
- Navigation handling

### Implementation Example

#### Domain Layer - Repository Interface

```dart
// lib/features/auth/domain/repositories/auth_repository.dart

abstract class AuthRepository {
  /// Sign in with email and password
  Future<Result<User>> signInWithEmail(String email, String password);

  /// Sign up with email and password
  Future<Result<User>> signUpWithEmail(String email, String password);

  /// Sign out current user
  Future<Result<void>> signOut();

  /// Send password reset email
  Future<Result<void>> resetPassword(String email);

  /// Stream of authentication state changes
  Stream<AuthState> authStateChanges();

  /// Get current authenticated user (if any)
  User? get currentUser;
}
```

#### Domain Layer - Models

```dart
// lib/features/auth/domain/models/user.dart

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? displayName,
    String? avatarUrl,
    required DateTime createdAt,
    DateTime? emailVerifiedAt,
  }) = _User;

  factory User.fromSupabase(supabase.User supabaseUser) {
    return User(
      id: supabaseUser.id,
      email: supabaseUser.email!,
      displayName: supabaseUser.userMetadata?['display_name'],
      avatarUrl: supabaseUser.userMetadata?['avatar_url'],
      createdAt: DateTime.parse(supabaseUser.createdAt),
      emailVerifiedAt: supabaseUser.emailConfirmedAt != null
          ? DateTime.parse(supabaseUser.emailConfirmedAt!)
          : null,
    );
  }
}

// lib/features/auth/domain/models/auth_state.dart

@freezed
class AuthState with _$AuthState {
  const factory AuthState.authenticated({
    required User user,
    required Session session,
  }) = Authenticated;

  const factory AuthState.unauthenticated() = Unauthenticated;

  const factory AuthState.loading() = Loading;
}

extension AuthStateX on AuthState {
  bool get isAuthenticated => this is Authenticated;

  User? get user => maybeWhen(
        authenticated: (user, session) => user,
        orElse: () => null,
      );
}
```

#### Data Layer - Supabase Implementation

```dart
// lib/features/auth/data/repositories/supabase_auth_repository.dart

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;
  final Talker _talker;

  SupabaseAuthRepository({
    required SupabaseClient client,
    required Talker talker,
  })  : _client = client,
        _talker = talker;

  @override
  Future<Result<User>> signInWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return Result.failure(
          AppFailure.authentication(
            message: 'Invalid credentials',
          ),
        );
      }

      return Result.success(User.fromSupabase(response.user!));
    } on AuthException catch (e, stack) {
      _talker.error('Auth sign-in failed', e, stack);
      return Result.failure(
        AppFailure.authentication(message: e.message),
      );
    } on SocketException catch (e, stack) {
      _talker.error('Network error during sign-in', e, stack);
      return Result.failure(
        AppFailure.network(message: 'Network connection failed'),
      );
    } catch (e, stack) {
      _talker.error('Unexpected auth error', e, stack);
      return Result.failure(
        AppFailure.unknown(message: 'An unexpected error occurred', exception: e),
      );
    }
  }

  @override
  Future<Result<User>> signUpWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return Result.failure(
          AppFailure.authentication(message: 'Sign up failed'),
        );
      }

      // User needs to verify email before full access
      return Result.success(User.fromSupabase(response.user!));
    } on AuthException catch (e, stack) {
      _talker.error('Auth sign-up failed', e, stack);
      return Result.failure(
        AppFailure.authentication(message: e.message),
      );
    } catch (e, stack) {
      _talker.error('Unexpected sign-up error', e, stack);
      return Result.failure(
        AppFailure.unknown(message: 'An unexpected error occurred', exception: e),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _client.auth.signOut();
      return const Result.success(null);
    } catch (e, stack) {
      _talker.error('Sign out failed', e, stack);
      return Result.failure(
        AppFailure.unknown(message: 'Sign out failed', exception: e),
      );
    }
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return const Result.success(null);
    } on AuthException catch (e, stack) {
      _talker.error('Password reset failed', e, stack);
      return Result.failure(
        AppFailure.authentication(message: e.message),
      );
    } catch (e, stack) {
      _talker.error('Unexpected error during password reset', e, stack);
      return Result.failure(
        AppFailure.unknown(message: 'Password reset failed', exception: e),
      );
    }
  }

  @override
  Stream<AuthState> authStateChanges() {
    return _client.auth.onAuthStateChange.map((data) {
      final event = data.event;
      final session = data.session;

      _talker.info('Auth event: $event');

      if (session != null && session.user != null) {
        return AuthState.authenticated(
          user: User.fromSupabase(session.user),
          session: session,
        );
      }

      return const AuthState.unauthenticated();
    });
  }

  @override
  User? get currentUser {
    final user = _client.auth.currentUser;
    return user != null ? User.fromSupabase(user) : null;
  }
}
```

#### Application Layer - Riverpod Providers

```dart
// lib/features/auth/application/auth_providers.dart

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return SupabaseAuthRepository(
    client: ref.watch(supabaseProvider),
    talker: ref.watch(talkerProvider),
  );
}

@riverpod
Stream<AuthState> authState(AuthStateRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<User?> build() {
    // Listen to auth state stream
    ref.listen(authStateProvider, (prev, next) {
      next.whenOrNull(
        data: (state) {
          state.when(
            authenticated: (user, session) {
              state = AsyncValue.data(user);
            },
            unauthenticated: () {
              state = const AsyncValue.data(null);
            },
            loading: () {
              state = const AsyncValue.loading();
            },
          );
        },
      );
    });

    // Return current user
    final currentUser = ref.read(authRepositoryProvider).currentUser;
    return AsyncValue.data(currentUser);
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

  Future<void> signUp(String email, String password) async {
    state = const AsyncValue.loading();

    final result = await ref
        .read(authRepositoryProvider)
        .signUpWithEmail(email, password);

    state = result.when(
      success: (user) => AsyncValue.data(user),
      failure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> resetPassword(String email) async {
    final result = await ref
        .read(authRepositoryProvider)
        .resetPassword(email);

    result.when(
      success: (_) {
        // Password reset email sent successfully
      },
      failure: (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
    );
  }
}
```

#### Presentation Layer - Login Screen

```dart
// lib/features/auth/presentation/screens/login_screen.dart

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);

    // Listen for auth state changes to navigate
    ref.listen(authNotifierProvider, (prev, next) {
      next.when(
        data: (user) {
          if (user != null) {
            context.go('/home');
          }
        },
        error: (error, stack) {
          // Error handling done separately
        },
        loading: () {},
      );
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App logo/title
                  Text(
                    l10n.appTitle,
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.errorValidationEmailRequired;
                      }
                      if (!value.contains('@')) {
                        return l10n.errorValidationEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleSignIn(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.errorValidationPasswordRequired;
                      }
                      if (value.length < 8) {
                        return l10n.errorValidationPasswordLength;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: Text(l10n.forgotPassword),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign in button
                  FilledButton(
                    onPressed: authState.isLoading ? null : _handleSignIn,
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.signIn),
                  ),
                  const SizedBox(height: 16),

                  // Sign up prompt
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.noAccount),
                      TextButton(
                        onPressed: () => context.push('/signup'),
                        child: Text(l10n.signUp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(authNotifierProvider.notifier).signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

## Session Management and Token Refresh

### Automatic Session Management with Supabase

**Description**: Leverage Supabase's built-in automatic session management, which handles token refresh, session persistence, and auth state broadcasting automatically via `flutter_secure_storage`.

**How It Works**:
1. Supabase automatically persists sessions to secure storage on sign-in
2. Background process monitors JWT expiration and refreshes tokens automatically
3. `onAuthStateChange` stream emits events when tokens are refreshed
4. Session is automatically restored on app restart via `Supabase.initialize()`
5. Refresh tokens are securely managed by Supabase

**Implementation**:

```dart
// main.dart - Initialize Supabase with automatic session management

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with PKCE flow
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce, // Enhanced security
    ),
  );

  // Setup global error handling
  final talker = TalkerFlutter.init();
  FlutterError.onError = (details) {
    talker.handle(details.exception, details.stack, 'Flutter Error');
  };

  runApp(
    ProviderScope(
      observers: [TalkerRiverpodObserver(talker: talker)],
      child: const MyApp(),
    ),
  );
}
```

**Benefits**:
- Zero manual session management code required
- Automatic token refresh in background
- Secure storage via platform keystores (iOS Keychain, Android KeyStore)
- Session restoration on app restart
- Real-time auth state updates via streams
- Refresh token rotation for security

**Session Expiration**:
- JWT tokens expire after 1 hour by default (configurable in Supabase dashboard)
- Refresh tokens are used automatically to get new JWT tokens
- `onAuthStateChange` emits `tokenRefreshed` event when tokens are updated

## Row Level Security (RLS) Implementation

**Description**: Secure user data at the database level using PostgreSQL Row Level Security policies. RLS ensures users can only access their own notes and data, even if API keys are compromised.

**Why RLS is Critical**:
- **Defense in Depth**: Even if anon API key is exposed, users can't access others' data
- **Zero Trust**: Never trust client-side security alone
- **Supabase Requirement**: Any table without RLS in public schema is fully accessible with anon key
- **Automatic Enforcement**: Database enforces policies, no client-side checks needed

### RLS Policy Examples for Voice Notes App

```sql
-- Enable RLS on notes table
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only view their own notes
CREATE POLICY "Users can view own notes"
ON notes FOR SELECT
USING (auth.uid() = user_id);

-- Policy: Users can insert their own notes
CREATE POLICY "Users can insert own notes"
ON notes FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own notes
CREATE POLICY "Users can update own notes"
ON notes FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own notes
CREATE POLICY "Users can delete own notes"
ON notes FOR DELETE
USING (auth.uid() = user_id);

-- Enable RLS on tags table
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own tags
CREATE POLICY "Users can view own tags"
ON tags FOR SELECT
USING (auth.uid() = user_id);

-- Policy: Users can create their own tags
CREATE POLICY "Users can insert own tags"
ON tags FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own tags
CREATE POLICY "Users can update own tags"
ON tags FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own tags
CREATE POLICY "Users can delete own tags"
ON tags FOR DELETE
USING (auth.uid() = user_id);

-- Enable RLS on note_tags junction table
ALTER TABLE note_tags ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view note-tag relationships for their notes
CREATE POLICY "Users can view own note_tags"
ON note_tags FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM notes
    WHERE notes.id = note_tags.note_id
    AND notes.user_id = auth.uid()
  )
);

-- Policy: Users can create note-tag relationships for their notes
CREATE POLICY "Users can insert own note_tags"
ON note_tags FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM notes
    WHERE notes.id = note_tags.note_id
    AND notes.user_id = auth.uid()
  )
);

-- Policy: Users can delete note-tag relationships for their notes
CREATE POLICY "Users can delete own note_tags"
ON note_tags FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM notes
    WHERE notes.id = note_tags.note_id
    AND notes.user_id = auth.uid()
  )
);

-- Enable RLS on user_profiles table
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own profile
CREATE POLICY "Users can view own profile"
ON user_profiles FOR SELECT
USING (auth.uid() = id);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile"
ON user_profiles FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);
```

### Performance Optimization - Add Indexes

```sql
-- Critical: Index user_id columns for RLS performance
CREATE INDEX idx_notes_user_id ON notes(user_id);
CREATE INDEX idx_tags_user_id ON tags(user_id);
CREATE INDEX idx_note_tags_note_id ON note_tags(note_id);
CREATE INDEX idx_user_profiles_id ON user_profiles(id);

-- Composite index for common queries
CREATE INDEX idx_notes_user_created ON notes(user_id, created_at DESC);
```

### Flutter Integration with RLS

```dart
// Repository layer - RLS is automatic
class SupabaseNoteRepository implements NoteRepository {
  final SupabaseClient _client;

  @override
  Future<Result<List<Note>>> getUserNotes() async {
    try {
      // RLS automatically filters to current user's notes
      // No need to add WHERE user_id = auth.uid() in query!
      final data = await _client
          .from('notes')
          .select()
          .order('created_at', ascending: false);

      final notes = data.map((json) => Note.fromJson(json)).toList();
      return Result.success(notes);
    } on PostgrestException catch (e, stack) {
      _talker.error('Failed to fetch notes', e, stack);
      return Result.failure(/* map error */);
    }
  }

  @override
  Future<Result<Note>> createNote(String content) async {
    try {
      // RLS automatically validates user_id matches auth.uid()
      final data = await _client.from('notes').insert({
        'user_id': _client.auth.currentUser!.id,
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      return Result.success(Note.fromJson(data));
    } on PostgrestException catch (e, stack) {
      _talker.error('Failed to create note', e, stack);
      return Result.failure(/* map error */);
    }
  }
}
```

### RLS Best Practices

1. **Enable RLS early** - Turn on RLS before adding data
2. **Add indexes** - Index all columns used in USING/WITH CHECK clauses
3. **Test thoroughly** - Test policies with multiple users
4. **Use auth.uid()** - Always reference `auth.uid()` for user identification
5. **Keep policies simple** - Complex joins in policies hurt performance
6. **Monitor performance** - Use EXPLAIN ANALYZE to check query plans with RLS

## Security Best Practices

### API Key Management

**Critical Security Rules**:

1. **Never expose service_role key in client apps** - Only use in backend/server
2. **Store keys in environment variables** - Never commit to source control
3. **Use obfuscation for keys in apps** - Use `envied` package with obfuscation
4. **Rotate keys if compromised** - Supabase allows key rotation
5. **Use different keys per environment** - Separate dev, staging, production keys

**Implementation with envied**:

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

// Generate with:
// dart run build_runner build
```

**.gitignore**:

```gitignore
# Environment files
.env
.env.local
.env.production
.env.staging

# Generated environment files
lib/core/env/env.g.dart
```

### Secure Token Storage

Supabase automatically uses `flutter_secure_storage` for session persistence. No manual token storage required.

**Platform Storage Mechanisms**:
- **iOS**: Keychain
- **Android**: EncryptedSharedPreferences with Android KeyStore
- **All platforms**: Encrypted at rest

## Route Protection with GoRouter

**Description**: Integrate authentication state with GoRouter to automatically protect routes and redirect unauthenticated users to login.

**Implementation**:

```dart
// lib/core/routing/router.dart

@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.maybeWhen(
        data: (authStateData) => authStateData.isAuthenticated,
        orElse: () => false,
      );

      final isLoading = authState.isLoading;
      final location = state.matchedLocation;

      // Show splash while loading auth state
      if (isLoading && location != '/splash') {
        return '/splash';
      }

      // Public routes
      final publicRoutes = ['/login', '/signup', '/forgot-password', '/splash'];
      final isPublicRoute = publicRoutes.contains(location);

      // Redirect to login if not authenticated and trying to access protected route
      if (!isAuthenticated && !isPublicRoute) {
        return '/login';
      }

      // Redirect to home if authenticated and on auth pages
      if (isAuthenticated && (location == '/login' || location == '/signup')) {
        return '/home';
      }

      return null; // No redirect needed
    },
    refreshListenable: GoRouterRefreshStream(
      authState.asStream(),
    ),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/notes/:id',
        builder: (context, state) {
          final noteId = state.pathParameters['id']!;
          return NoteDetailScreen(noteId: noteId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}

// Helper class to refresh GoRouter when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

## Tools and Libraries

### Core Authentication Packages

#### 1. supabase_flutter

- **Purpose**: Official Supabase client for Flutter with authentication support
- **Maturity**: Production-ready (v2.5.0+ in 2025)
- **License**: MIT
- **Community**: Very large, official support from Supabase
- **Integration Effort**: Low
- **Key Features**:
  - Complete Auth API (email/password authentication)
  - Automatic session management with `flutter_secure_storage`
  - Real-time auth state updates via `onAuthStateChange`
  - PKCE flow by default for enhanced security
  - Built-in token refresh
  - Password reset functionality

**Package**: `supabase_flutter: ^2.5.0`

**Recommendation**: Essential - core authentication package.

#### 2. flutter_secure_storage

- **Purpose**: Secure storage for sensitive data using platform keystores
- **Maturity**: Production-ready
- **License**: BSD-3-Clause
- **Community**: Very large, actively maintained
- **Integration Effort**: Low
- **Key Features**:
  - iOS Keychain integration
  - Android KeyStore integration
  - Encrypted storage on all platforms
  - Used automatically by Supabase for session storage

**Package**: `flutter_secure_storage: ^9.0.0`

**Recommendation**: Automatically used by Supabase; included as dependency.

#### 3. envied

- **Purpose**: Encrypted environment variables for API keys
- **Maturity**: Production-ready
- **License**: MIT
- **Community**: Growing, well-maintained
- **Integration Effort**: Low
- **Key Features**:
  - Code generation for environment variables
  - Obfuscation of sensitive values
  - Type-safe environment access
  - .env file support
  - Compile-time security

**Package**: `envied: ^0.5.0` (runtime), `envied_generator: ^0.5.0` (dev)

**Recommendation**: Essential for secure API key management.

## Implementation Considerations

### Technical Requirements

**Dependencies**:
- `supabase_flutter: ^2.5.0` - Core Supabase client
- `flutter_secure_storage: ^9.0.0` - Secure token storage (auto-included)
- `envied: ^0.5.0` - Environment variable management
- `envied_generator: ^0.5.0` (dev) - Code generation for envied
- `riverpod: ^3.0.0` - State management
- `riverpod_annotation: ^3.0.0` - Riverpod code generation
- `freezed: ^2.4.0` - Immutable models
- `freezed_annotation: ^2.4.0` - Freezed annotations
- `go_router: ^14.0.0` - Navigation and routing

**Performance Implications**:
- Session restoration adds ~100-200ms to app launch
- RLS policies require proper indexing for optimal performance
- Token refresh happens automatically in background

**Security Aspects**:
- PKCE flow enabled by default
- Tokens stored in platform-specific secure storage
- RLS enforces data isolation at database level
- API keys obfuscated in compiled app

### Integration Points

**How it fits with existing architecture**:
- Auth follows Clean Architecture with 4 layers
- Integrates with existing Riverpod state management
- Uses existing Result<T> pattern for error handling
- Leverages existing Talker logging
- Integrates with GoRouter for route protection

**Required modifications**:
- Add auth feature folder structure
- Create RLS policies in Supabase
- Add environment variables for API keys
- Configure GoRouter with auth redirect logic
- Add auth-related localization strings

**Database impacts**:
- Enable RLS on all user-owned tables
- Add user_id foreign key to tables
- Create indexes on user_id columns for performance
- Create user_profiles table for additional user data

### Risks and Mitigation

**Potential challenges**:
1. **Email verification friction** - Users must verify email before full access
   - Mitigation: Clear messaging about verification requirement

2. **Password reset complexity** - Users may struggle with password resets
   - Mitigation: Clear instructions, intuitive UI flow

3. **Session expiration** - Users may be logged out unexpectedly
   - Mitigation: Automatic token refresh handles this transparently

4. **RLS performance** - Complex RLS policies can slow queries
   - Mitigation: Add proper indexes on user_id columns

## Recommendations

### Recommended Approach

**Primary Recommendation**: Implement email/password authentication using Supabase Auth with automatic session management, RLS policies for data security, and GoRouter integration for route protection.

**Implementation Strategy**:

1. **Phase 1: Core Authentication (Week 1)**
   - Set up environment variables with envied
   - Implement domain layer (models, repository interface)
   - Implement data layer (Supabase repository)
   - Create basic login/signup UI

2. **Phase 2: State Management & Routing (Week 1)**
   - Implement Riverpod providers for auth state
   - Configure GoRouter with auth redirect logic
   - Add splash screen for auth loading state
   - Test authentication flow end-to-end

3. **Phase 3: Database Security (Week 2)**
   - Enable RLS on all tables
   - Create RLS policies for notes, tags, profiles
   - Add indexes for RLS performance
   - Test data isolation between users

4. **Phase 4: Polish & Edge Cases (Week 2)**
   - Implement password reset flow
   - Add email verification reminder UI
   - Handle session expiration gracefully
   - Add localized error messages
   - Complete testing and bug fixes

**Why This Approach**:
- Minimal complexity while maintaining security
- Leverages Supabase's automatic session management
- Follows existing Clean Architecture patterns
- No external dependencies on OAuth providers
- Easy to understand and maintain
- Production-ready security with RLS

## References

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/introduction)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [Envied Package](https://pub.dev/packages/envied)
- [Riverpod Documentation](https://riverpod.dev)
- [GoRouter Documentation](https://pub.dev/packages/go_router)

## Appendix

### Email Verification Flow

When users sign up, Supabase sends a verification email automatically. The app should:
1. Show a message after signup: "Please check your email to verify your account"
2. Allow users to request a new verification email if needed
3. Handle the deep link when user clicks verification link in email
4. Navigate to home screen after successful verification

### Password Reset Flow

1. User clicks "Forgot Password" on login screen
2. User enters email address
3. Supabase sends password reset email
4. User clicks link in email (opens app via deep link)
5. User enters new password
6. User is signed in automatically with new password

### Deep Link Configuration

**iOS (ios/Runner/Info.plist)**:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>com.yourapp.voicenotes</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.yourapp.voicenotes</string>
    </array>
  </dict>
</array>
```

**Android (android/app/src/main/AndroidManifest.xml)**:
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="com.yourapp.voicenotes" />
</intent-filter>
```
