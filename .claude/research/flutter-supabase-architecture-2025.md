# Research: Flutter + Supabase Architecture 2025

## Executive Summary

Building a Flutter application with Supabase in 2025 requires a well-architected foundation to ensure testability, maintainability, and scalability. After comprehensive research, the recommended architecture combines **Clean Architecture principles** with **Riverpod 3** for state management, **GoRouter** (or AutoRoute as alternative) for routing, and a robust set of supporting packages.

**Key Recommendations:**
- **Architecture Pattern**: Feature-First Clean Architecture with clear layer separation (Presentation, Application, Domain, Data)
- **State Management**: Riverpod 3 (released September 2025) for its compile-time safety, testability, and modern @riverpod macro
- **Routing**: GoRouter for its official Flutter support and declarative approach, or AutoRoute for superior type safety
- **Core Packages**: Freezed for immutable models, Dio for HTTP, Talker for logging, and Mocktail for testing

This stack delivers exceptional testability through clear boundaries and dependency injection, maintainability through separation of concerns, and readability through consistent patterns and minimal boilerplate.

## Research Scope

### What Was Researched
- Modern Flutter architecture patterns (2025)
- State management solutions with emphasis on Riverpod
- Routing solutions (GoRouter vs AutoRoute)
- Supabase integration best practices
- Essential packages for production-ready architecture
- Testing strategies and tools
- Error handling and logging solutions

### What Was Explicitly Excluded
- Flutter web-specific optimizations (though architecture supports it)
- Platform-specific native integrations
- CI/CD pipeline details
- Specific UI/design system implementation
- Backend Supabase configuration details

### Research Methodology
- Official Flutter and Supabase documentation review
- Industry best practices from 2025 sources
- Package ecosystem analysis
- Architecture pattern comparison
- Developer community consensus evaluation

## Current State Analysis

### Existing Implementation
This is a greenfield project starting from scratch, allowing implementation of best practices from day one without technical debt constraints.

### Industry Standards (2025)

**Clean Architecture Adoption**: Clean Architecture has become the standard for Flutter apps requiring scale and maintainability. It provides independence from frameworks, testability, UI independence, database independence, and external agency independence.

**State Management Evolution**: Riverpod 3 (released September 2025) has emerged as the preferred solution for modern Flutter apps, offering compile-time safety, reduced boilerplate with @riverpod macro, and excellent testability.

**Feature-First Structure**: The Flutter community has shifted toward feature-first organization over layer-first, improving code locality and developer experience.

**Supabase as BaaS Leader**: Supabase has matured as a production-ready backend solution with strong Flutter SDK support (v2 with Dart 3 features), providing Auth, Realtime, Storage, Edge Functions, and pgvector out of the box.

## Technical Analysis

### Architecture Patterns

#### Approach 1: Clean Architecture (Four Layers)

**Description**: A formalized architecture composed of four layers: Presentation (UI), Application (State/Logic), Domain (Business Logic), and Data (External Services).

**Pros**:
- Clear separation of concerns enables independent testing of each layer
- Business logic is isolated from framework and infrastructure dependencies
- Highly maintainable - changes in one layer minimally impact others
- Excellent for scaling teams and codebase
- Makes onboarding new developers easier with clear structure
- Strongly recommended by Flutter community in 2025

**Cons**:
- Initial setup requires more boilerplate than simple architectures
- Steeper learning curve for developers unfamiliar with clean architecture
- Can feel over-engineered for very small applications
- Requires discipline to maintain layer boundaries

**Use Cases**:
- Mid to large applications expecting growth
- Applications requiring extensive testing
- Projects with multiple developers
- Apps with complex business logic
- Long-term maintained applications

**Architecture Structure**:
```
lib/
├── features/               # Feature-first organization
│   ├── authentication/
│   │   ├── presentation/   # UI Layer: Widgets, Pages, State
│   │   │   ├── pages/
│   │   │   ├── widgets/
│   │   │   └── providers/  # Riverpod providers for this feature
│   │   ├── application/    # Application Logic: Use cases
│   │   │   └── auth_service.dart
│   │   ├── domain/         # Business Logic: Entities, Interfaces
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   └── data/           # Data Layer: API, Database, DTOs
│   │       ├── repositories/
│   │       ├── data_sources/
│   │       └── dtos/
│   └── profile/
├── core/                   # Shared utilities
│   ├── network/
│   ├── errors/
│   ├── constants/
│   └── utils/
└── shared/                 # Shared domain models/providers
    ├── models/
    └── providers/
```

#### Approach 2: MVVM (Model-View-ViewModel)

**Description**: Architecture pattern separating UI (View) from business logic (ViewModel) with Models representing data.

**Pros**:
- Simpler than Clean Architecture with clear separation
- Good testability through ViewModel isolation
- Familiar pattern from other platforms (Android, iOS)
- Works well with Flutter's reactive widgets
- Less boilerplate than full Clean Architecture

**Cons**:
- Can lead to fat ViewModels without discipline
- Less clear boundaries than Clean Architecture
- ViewModels can become coupled to multiple concerns
- Doesn't enforce repository pattern
- Can accumulate technical debt as app grows

**Use Cases**:
- Small to medium applications
- Teams familiar with MVVM from other platforms
- Projects with simpler business logic requirements
- Faster initial development timeline priority

#### Approach 3: Feature-First (Simplified Layering)

**Description**: Organizing code by features with lightweight layering within each feature module.

**Pros**:
- Excellent code locality - related code stays together
- Easier to understand feature scope
- Simpler than full Clean Architecture
- Natural code splitting and lazy loading
- Better for parallel team development

**Cons**:
- Can lead to code duplication across features
- Shared logic extraction becomes challenging
- Less standardization than strict layered architecture
- Risk of inconsistent patterns across features

**Use Cases**:
- Medium applications with clear feature boundaries
- Rapid prototyping and MVP development
- Teams valuing development speed over strict architecture
- Applications with independent feature modules

**Recommended Approach**: **Clean Architecture with Feature-First organization** provides the best balance for a production Flutter + Supabase application, ensuring testability, maintainability, and scalability while maintaining code locality benefits.

## State Management Deep Dive

### Why Riverpod 3 in 2025?

Riverpod has evolved into the most robust state management solution for Flutter, with version 3.0 released in September 2025 bringing significant improvements.

#### Key Advantages

**1. Compile-Time Safety**
Riverpod enhances the compiler by having common mistakes be compilation errors rather than runtime errors. This catches bugs during development, not in production.

**2. Context-Free Design**
Unlike Provider, Riverpod does not rely on BuildContext to retrieve values. State can be accessed in pure Dart code (services, repositories), making it ideal for separating UI from business logic - essential for Clean Architecture.

**3. Modern @riverpod Macro (v3)**
The new @riverpod macro reduces boilerplate significantly while improving readability and maintainability:

```dart
// Old way (Riverpod 2.x)
final counterProvider = StateProvider<int>((ref) => 0);

// New way (Riverpod 3.x)
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
}
```

**4. Excellent Testing Support**
Providers can be easily overridden in tests, enabling true unit testing:

```dart
testWidgets('Counter increments', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        counterProvider.overrideWith(() => MockCounter()),
      ],
      child: MyApp(),
    ),
  );
  // Test assertions
});
```

**5. Reactive Caching and Data-Binding**
Riverpod 2.0+ borrows concepts from React Query, positioning itself as a reactive caching and data-binding framework beyond simple state management. This is perfect for Supabase real-time subscriptions.

**6. Native Async Support**
Built-in AsyncValue type handles loading, error, and data states elegantly:

```dart
@riverpod
Future<User> user(UserRef ref, String id) async {
  return await supabase.from('users').select().eq('id', id).single();
}

// In UI
final userAsync = ref.watch(userProvider(userId));
return userAsync.when(
  data: (user) => UserProfile(user),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => ErrorWidget(err),
);
```

### Riverpod vs Alternatives

**vs BLoC**:
- Riverpod: Better for teams valuing simplicity, compile-time safety, and reduced boilerplate
- BLoC: Better for enterprise apps requiring strict patterns and event-driven architecture
- Winner for this project: **Riverpod** - better DX, easier testing, less ceremony

**vs Provider**:
- Riverpod is Provider 2.0 - same author, addressing all Provider limitations
- Riverpod offers compile-time safety and context-free access
- Winner: **Riverpod** - modern evolution with no Provider drawbacks

**vs GetX**:
- GetX offers simplicity but couples your code to the framework
- Poor testability compared to Riverpod
- Winner: **Riverpod** - better architecture and testing

### Riverpod with Clean Architecture

Riverpod excels in Clean Architecture:

**Domain Layer**: Pure business logic, no Riverpod dependency
```dart
abstract class UserRepository {
  Future<User> getUser(String id);
}
```

**Data Layer**: Implement repositories
```dart
class SupabaseUserRepository implements UserRepository {
  final SupabaseClient client;

  @override
  Future<User> getUser(String id) async {
    final data = await client.from('users').select().eq('id', id).single();
    return User.fromJson(data);
  }
}
```

**Application Layer**: Riverpod providers expose use cases
```dart
@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  return SupabaseUserRepository(ref.watch(supabaseProvider));
}

@riverpod
Future<User> user(UserRef ref, String id) {
  return ref.watch(userRepositoryProvider).getUser(id);
}
```

**Presentation Layer**: Widgets consume providers
```dart
class UserProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider(userId));
    return userAsync.when(...);
  }
}
```

## Routing Solutions

### GoRouter vs AutoRoute

Both are excellent routing solutions; the choice depends on priorities.

#### Option 1: GoRouter (Official Recommendation)

**Purpose**: Declarative routing package officially supported by Flutter team

**Maturity**: Production-ready, feature-complete (maintenance mode as of 2025)

**License**: BSD-3-Clause

**Community**: Large community, extensive documentation

**Integration Effort**: Low - straightforward setup

**Key Features**:
- Declarative route definitions
- Deep linking and URL navigation (excellent for web)
- Nested navigation and shell routes
- Redirect and guard logic
- Query parameters and path parameters
- No code generation required

**Pros**:
- Official Flutter package - guaranteed compatibility
- Simple, declarative syntax
- Great web support (URL-based navigation)
- No build step required
- Extensive documentation and community support
- Works seamlessly with Riverpod for route guards

**Cons**:
- Maintenance mode (feature-complete, bug fixes only)
- Less type safety than AutoRoute
- Manual route path typing (string-based)
- Some IDE autocomplete limitations

**Example Setup**:
```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    redirect: (context, state) {
      if (!authState.isAuthenticated && state.location != '/login') {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomePage(),
      ),
      GoRoute(
        path: '/profile/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProfilePage(userId: id);
        },
      ),
    ],
  );
});
```

**Best For**:
- Projects prioritizing simplicity and official support
- Web applications requiring URL-based navigation
- Teams wanting minimal setup and maintenance
- Projects not requiring extensive type safety in routing

#### Option 2: AutoRoute

**Purpose**: Code-generation based routing with strong type safety

**Maturity**: Production-ready, actively maintained

**License**: MIT

**Community**: Strong community, good documentation

**Integration Effort**: Medium - requires code generation setup

**Key Features**:
- Full type safety with code generation
- Excellent IDE support and autocomplete
- Nested routing and tab-based navigation
- Route guards and middleware
- Path and query parameter type safety
- Deep linking support

**Pros**:
- Superior type safety - compile-time route verification
- Excellent IDE autocomplete and refactoring support
- No string-based paths (reduces runtime errors)
- Rich feature set for complex navigation
- Better for large apps with many routes
- Active development and feature additions

**Cons**:
- Requires code generation (build_runner)
- More initial setup complexity
- Build step adds to development cycle
- Slightly steeper learning curve

**Example Setup**:
```dart
@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, initial: true),
    AutoRoute(page: ProfileRoute.page),
    AutoRoute(
      page: AuthRoute.page,
      guards: [AuthGuard()],
    ),
  ];
}

// Usage
context.router.push(ProfileRoute(userId: '123'));
```

**Best For**:
- Large applications with complex routing
- Teams prioritizing type safety
- Projects already using code generation (Freezed, json_serializable)
- Native mobile apps where type safety > URL structure

### Recommendation

**Primary Choice: GoRouter**
- Official support and stability
- Simpler setup and maintenance
- Sufficient for most applications
- Better web support
- No code generation overhead

**Alternative: AutoRoute**
- Choose if type safety is critical
- Better for very large applications (50+ routes)
- Preferred when already using extensive code generation
- Better IDE experience for complex navigation flows

Both integrate well with Riverpod for authentication guards and state-based navigation logic.

## Supabase Integration Best Practices

### Architecture Patterns for Supabase

#### 1. Repository Pattern
Wrap all Supabase calls in repository classes to abstract data source:

```dart
abstract class UserRepository {
  Future<User> getUser(String id);
  Stream<User> watchUser(String id);
  Future<void> updateUser(User user);
}

class SupabaseUserRepository implements UserRepository {
  final SupabaseClient _client;

  SupabaseUserRepository(this._client);

  @override
  Future<User> getUser(String id) async {
    final data = await _client
        .from('users')
        .select()
        .eq('id', id)
        .single();
    return User.fromJson(data);
  }

  @override
  Stream<User> watchUser(String id) {
    return _client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((data) => User.fromJson(data.first));
  }
}
```

#### 2. State Management with Riverpod + Supabase

**Singleton Supabase Client**:
```dart
@riverpod
SupabaseClient supabase(SupabaseRef ref) {
  return Supabase.instance.client;
}
```

**Repository Providers**:
```dart
@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  return SupabaseUserRepository(ref.watch(supabaseProvider));
}
```

**Data Providers with Caching**:
```dart
@riverpod
Future<User> user(UserRef ref, String id) async {
  // Riverpod automatically caches this per id
  return ref.watch(userRepositoryProvider).getUser(id);
}

// Real-time stream provider
@riverpod
Stream<User> userStream(UserStreamRef ref, String id) {
  return ref.watch(userRepositoryProvider).watchUser(id);
}
```

#### 3. Optimized Query Patterns

**Select Only Needed Fields**:
```dart
// Bad
final data = await supabase.from('users').select();

// Good
final data = await supabase.from('users').select('id, name, email');
```

**Use Indexes**: Ensure frequently queried fields have database indexes to reduce query time from seconds to milliseconds.

**Batch Operations**: Use batch queries and transactions when possible:
```dart
await supabase.rpc('batch_update_users', params: {
  'user_ids': ids,
  'status': 'active',
});
```

#### 4. Real-Time Subscriptions

**Selective Real-Time**: Only use real-time where instant updates matter:
```dart
@riverpod
Stream<List<Message>> messageStream(MessageStreamRef ref, String channelId) {
  final supabase = ref.watch(supabaseProvider);

  // Only subscribe to messages for current channel
  return supabase
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('channel_id', channelId)
      .order('created_at')
      .map((data) => data.map((json) => Message.fromJson(json)).toList());
}
```

**Clean Up Subscriptions**: Riverpod automatically handles disposal when provider is no longer watched.

#### 5. Error Handling

```dart
@riverpod
Future<User> user(UserRef ref, String id) async {
  try {
    return await ref.watch(userRepositoryProvider).getUser(id);
  } on PostgrestException catch (e) {
    throw RepositoryException('Failed to fetch user: ${e.message}');
  } catch (e) {
    throw RepositoryException('Unexpected error: $e');
  }
}
```

#### 6. Offline-First Architecture

Implement caching for resilience:
```dart
@riverpod
Future<User> user(UserRef ref, String id) async {
  // Try cache first
  final cached = ref.read(userCacheProvider).get(id);
  if (cached != null) return cached;

  // Fetch from Supabase
  final user = await ref.watch(userRepositoryProvider).getUser(id);

  // Update cache
  ref.read(userCacheProvider).set(id, user);

  return user;
}
```

Consider using packages like:
- `hive` or `isar` for local database
- `dio_cache_interceptor` for HTTP caching

#### 7. Authentication Integration

```dart
@riverpod
Stream<AuthState> authState(AuthStateRef ref) {
  final supabase = ref.watch(supabaseProvider);

  return supabase.auth.onAuthStateChange.map((data) {
    final session = data.session;
    if (session != null) {
      return AuthState.authenticated(session.user);
    }
    return AuthState.unauthenticated();
  });
}

// Route guard with GoRouter
@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    redirect: (context, state) {
      final isAuth = authState.value?.isAuthenticated ?? false;
      if (!isAuth && state.location != '/login') {
        return '/login';
      }
      return null;
    },
    routes: [...],
  );
}
```

#### 8. Row Level Security (RLS)

Ensure RLS policies are set up in Supabase:
```sql
-- Example RLS policy
CREATE POLICY "Users can view their own data"
ON users FOR SELECT
USING (auth.uid() = id);
```

Handle RLS in repository layer:
```dart
@override
Future<User> getCurrentUser() async {
  final userId = _client.auth.currentUser?.id;
  if (userId == null) throw UnauthorizedException();

  // RLS automatically filters to user's own data
  final data = await _client
      .from('users')
      .select()
      .eq('id', userId)
      .single();
  return User.fromJson(data);
}
```

### Performance Optimization

**1. Minimize Payload**: Select only needed columns
**2. Database Indexing**: Index frequently queried fields
**3. Caching Strategy**: Cache static/semi-static data locally
**4. Debounce Real-Time**: Throttle real-time updates if needed
**5. Batch Operations**: Combine multiple updates into single RPC calls
**6. Connection Pooling**: Supabase handles this, but be mindful of concurrent operations

## Essential Packages for Architecture

### Core Architecture Packages

#### 1. Freezed
**Purpose**: Code generation for immutable data classes

**Maturity**: Production-ready, industry standard

**License**: MIT

**Community**: Very large, actively maintained

**Integration Effort**: Low (works via build_runner)

**Key Features**:
- Immutable classes with copyWith
- Union types (sealed classes)
- JSON serialization integration
- Pattern matching support

**Why Essential**:
- Eliminates boilerplate for data models
- Guarantees immutability for state management
- Type-safe pattern matching for handling different states
- Perfect companion to Riverpod and Clean Architecture

**Example**:
```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

// Union types for state
@freezed
class AuthState with _$AuthState {
  const factory AuthState.authenticated(User user) = Authenticated;
  const factory AuthState.unauthenticated() = Unauthenticated;
  const factory AuthState.loading() = Loading;
}
```

#### 2. json_serializable
**Purpose**: Automatic JSON serialization/deserialization

**Maturity**: Production-ready, Flutter official

**License**: BSD-3-Clause

**Community**: Large, well-documented

**Integration Effort**: Low (works with build_runner)

**Key Features**:
- Automatic fromJson/toJson generation
- Handles nested objects
- Custom converters support
- Field renaming and ignoring

**Why Essential**:
- Removes manual JSON parsing errors
- Type-safe JSON handling
- Required for Supabase API responses
- Works seamlessly with Freezed

#### 3. Dio
**Purpose**: Powerful HTTP client for API calls

**Maturity**: Production-ready, industry standard

**License**: MIT

**Community**: Very large, extensive ecosystem

**Integration Effort**: Low

**Key Features**:
- Interceptors (logging, auth, retry)
- Request cancellation
- File upload/download
- FormData support
- Global configuration
- Timeout handling

**Why Essential**:
- More powerful than Flutter's http package
- Interceptors perfect for auth token injection
- Better error handling
- Retry logic for network resilience
- Supabase uses REST APIs that Dio excels at

**Example**:
```dart
@riverpod
Dio dio(DioRef ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://your-project.supabase.co',
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 3),
  ));

  // Auth interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = ref.read(authTokenProvider);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
  ));

  // Logging interceptor
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  return dio;
}
```

#### 4. GetIt (Optional - if not using Riverpod's dependency injection)
**Purpose**: Service locator for dependency injection

**Note**: With Riverpod, GetIt becomes optional as Riverpod handles DI excellently. Only consider if you need service locator pattern outside widget tree.

### Testing Packages

#### 5. Mocktail
**Purpose**: Mocking library for tests

**Maturity**: Production-ready

**License**: MIT

**Community**: Growing, well-maintained by Felix Angelov (BLoC author)

**Integration Effort**: Low - zero code generation

**Key Features**:
- Null-safe mocking
- No code generation required
- Simple API similar to Mockito
- Works with any class
- Verify method calls
- Stub return values

**Why Choose Over Mockito**:
- No code generation step
- Simpler setup
- Null-safety by default
- Works great for integration tests

**Example**:
```dart
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockUserRepository();
    container = ProviderContainer(
      overrides: [
        userRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  test('user provider fetches user from repository', () async {
    final user = User(id: '1', name: 'John');
    when(() => mockRepo.getUser('1')).thenAnswer((_) async => user);

    final result = await container.read(userProvider('1').future);

    expect(result, user);
    verify(() => mockRepo.getUser('1')).called(1);
  });
}
```

#### 6. flutter_test (Built-in)
**Purpose**: Widget and unit testing framework

**Key Features**:
- Widget testing
- Golden file testing
- Test utilities (pumpWidget, etc.)
- Integration testing support

#### 7. patrol (Optional - Enhanced Integration Testing)
**Purpose**: Enhanced integration testing with native interactions

**Use Case**: When you need to test native dialogs, permissions, or complex gestures

### Error Handling & Logging

#### 8. Talker
**Purpose**: Advanced error handling and logging

**Maturity**: Production-ready, actively maintained

**License**: MIT

**Community**: Growing, comprehensive ecosystem

**Integration Effort**: Low

**Key Features**:
- Detailed error tracking with stack traces
- UI log viewer (talker_flutter)
- Multiple log levels (info, warning, error, etc.)
- Color-coded console output
- Filter and search logs
- Export and share logs
- Integration with crash reporting tools
- Specialized loggers for:
  - Dio HTTP calls (talker_dio_logger)
  - BLoC state (talker_bloc_logger)
  - Riverpod (talker_riverpod_logger)
  - HTTP (talker_http_logger)

**Why Essential**:
- Critical for debugging production issues
- In-app log viewer for QA testing
- Integrates with Sentry, Firebase Crashlytics
- Helps identify error sources quickly
- Beautiful, filterable logs

**Example Setup**:
```dart
final talker = TalkerFlutter.init(
  settings: TalkerSettings(
    colors: {
      TalkerLogType.error: Colors.red,
      TalkerLogType.info: Colors.blue,
    },
  ),
);

@riverpod
Dio dio(DioRef ref) {
  final dio = Dio();

  // Add Talker logger for all HTTP calls
  dio.interceptors.add(
    TalkerDioLogger(
      talker: talker,
      settings: const TalkerDioLoggerSettings(
        printRequestHeaders: true,
        printResponseData: true,
      ),
    ),
  );

  return dio;
}

// Riverpod error handling with Talker
@riverpod
Future<User> user(UserRef ref, String id) async {
  try {
    return await ref.watch(userRepositoryProvider).getUser(id);
  } catch (e, stack) {
    talker.handle(e, stack, 'Failed to fetch user');
    rethrow;
  }
}

// Show logs UI (development only)
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => TalkerScreen(talker: talker),
  ),
);
```

### Utility Packages

#### 9. envied (or flutter_dotenv)
**Purpose**: Environment variable management

**Why Essential**: Secure API keys and environment-specific config

**Example**:
```dart
@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'SUPABASE_URL')
  static const String supabaseUrl = _Env.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static const String supabaseAnonKey = _Env.supabaseAnonKey;
}
```

#### 10. intl
**Purpose**: Internationalization and localization

**Why Essential**: Date formatting, number formatting, multi-language support

#### 11. equatable (Optional)
**Purpose**: Value equality without code generation

**Note**: Freezed provides this, but Equatable is lightweight alternative for domain entities if avoiding code generation in domain layer

### Build Tools

#### 12. build_runner
**Purpose**: Code generation runner

**Why Essential**: Required for Freezed, json_serializable, AutoRoute

**Usage**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run build_runner watch # For development
```

### Package Summary Table

| Package | Category | Priority | Purpose |
|---------|----------|----------|---------|
| flutter_riverpod | State Management | Critical | Core state management |
| freezed | Data Models | Critical | Immutable models |
| json_serializable | Serialization | Critical | JSON handling |
| supabase_flutter | Backend | Critical | Supabase integration |
| go_router | Routing | Critical | Navigation |
| dio | Networking | High | HTTP client |
| talker_flutter | Logging | High | Error handling & logging |
| mocktail | Testing | High | Test mocking |
| envied | Config | High | Environment variables |
| build_runner | Dev Tools | High | Code generation |
| intl | i18n | Medium | Internationalization |
| patrol | Testing | Low | Enhanced integration tests |

## Implementation Considerations

### Technical Requirements

**Minimum Flutter Version**: 3.16+ (for latest Riverpod and Dart 3 features)

**Dart Version**: 3.0+ (required for modern features and packages)

**Dependencies Overview**:
```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # Supabase
  supabase_flutter: ^2.5.0

  # Routing
  go_router: ^14.0.0

  # Data Models
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0

  # Networking
  dio: ^5.4.0

  # Logging
  talker_flutter: ^4.0.0
  talker_dio_logger: ^4.0.0
  talker_riverpod_logger: ^4.0.0

  # Environment
  envied: ^0.5.0

  # Utilities
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.4.0
  riverpod_generator: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  envied_generator: ^0.5.0

  # Testing
  mocktail: ^1.0.0

  # Linting
  flutter_lints: ^4.0.0
```

### Performance Implications

**Build Times**: Code generation adds ~10-30s to initial build time, but hot reload remains fast

**Runtime Performance**:
- Riverpod: Minimal overhead, excellent performance
- Freezed: Zero runtime overhead (compile-time only)
- Clean Architecture: Slight indirection overhead, negligible in practice

**App Size**: Additional packages add ~2-3MB to release build

**Memory**: Proper provider disposal and architecture keeps memory usage optimal

### Scalability Considerations

**Team Scalability**:
- Clear architecture enables parallel development
- Feature-first structure reduces merge conflicts
- Consistent patterns ease onboarding

**Codebase Scalability**:
- Clean Architecture supports apps with 100k+ lines of code
- Feature modules can be 50+ without becoming unmanageable
- Repository pattern allows easy data source changes

**Performance Scalability**:
- Riverpod's fine-grained reactivity prevents unnecessary rebuilds
- Proper caching strategies handle large datasets
- Lazy loading and code splitting supported

### Security Aspects

**API Key Security**:
- Use envied with obfuscation for keys
- Never commit .env files
- Use Supabase RLS for backend security

**Authentication**:
- Implement proper JWT token refresh
- Secure token storage (flutter_secure_storage)
- Handle authentication state consistently

**Data Validation**:
- Validate at repository boundaries
- Use Freezed's type safety for compile-time guarantees
- Sanitize user inputs

**HTTPS**:
- Supabase enforces HTTPS by default
- Dio configured with HTTPS-only in production

## Integration Points

### How It Fits with Existing Architecture

As a greenfield project, the architecture is designed from the ground up with:

**1. Clear Layer Boundaries**:
- Presentation ↔ Application: Through Riverpod providers
- Application ↔ Domain: Through use cases and repository interfaces
- Domain ↔ Data: Through repository implementations

**2. Dependency Rules**:
- Domain layer has zero dependencies on outer layers
- Data layer depends only on domain interfaces
- Presentation depends on application and domain

**3. Data Flow**:
```
UI Widget → Riverpod Provider → Use Case/Service → Repository Interface → Repository Implementation → Supabase Client → Supabase Server
```

### Required Modifications

No modifications required for greenfield project. Initial setup includes:

1. Project structure creation
2. Package installation and configuration
3. Environment setup (.env files)
4. Supabase project initialization
5. Base classes and utilities creation

### API Changes Needed

**Supabase Setup**:
1. Create Supabase project
2. Set up database schema
3. Configure Row Level Security (RLS)
4. Set up authentication providers
5. Configure storage buckets if needed

**Flutter App Configuration**:
```dart
await Supabase.initialize(
  url: Env.supabaseUrl,
  anonKey: Env.supabaseAnonKey,
  authOptions: FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce,
  ),
);
```

### Database Impacts

**Schema Design Best Practices**:
- Normalize for data integrity
- Denormalize for performance where appropriate
- Use PostgreSQL indexes on foreign keys and frequently queried fields
- Leverage PostgreSQL features (JSONB, full-text search, etc.)

**Migration Strategy**:
- Use Supabase migrations for version control
- Keep migrations in version control
- Test migrations in staging environment

## Risks and Mitigation

### Potential Challenges

**1. Learning Curve**
- **Risk**: Team unfamiliar with Clean Architecture, Riverpod 3, or Supabase
- **Mitigation**:
  - Invest in training and documentation
  - Start with one feature to establish patterns
  - Pair programming during initial implementation
  - Reference official documentation and examples

**2. Code Generation Complexity**
- **Risk**: Build runner errors, confusion about generated files
- **Mitigation**:
  - Document build_runner commands clearly
  - Add VS Code/IntelliJ tasks for common commands
  - Use build_runner watch during development
  - .gitignore generated files properly

**3. Over-Engineering for Simple Features**
- **Risk**: Clean Architecture feels like overkill for simple CRUD
- **Mitigation**:
  - Simplify where appropriate (skip use case layer for simple repository calls)
  - Balance pragmatism with architecture
  - Evolve architecture as needs grow

**4. Supabase Rate Limits**
- **Risk**: Free tier rate limits in development or MVP
- **Mitigation**:
  - Implement caching early
  - Use local development database (Docker)
  - Plan for pro tier if expecting traffic

**5. Real-Time Performance**
- **Risk**: Too many real-time subscriptions causing performance issues
- **Mitigation**:
  - Use real-time selectively
  - Implement throttling/debouncing
  - Unsubscribe when widgets dispose

### Risk Mitigation Strategies

**Technical Debt Prevention**:
- Regular refactoring sessions
- Code review focus on architecture adherence
- Automated linting and formatting
- Documentation as you go

**Testing Strategy**:
- Unit tests for business logic (domain layer)
- Widget tests for UI components
- Integration tests for critical user flows
- Repository tests with mocked Supabase

**Monitoring and Debugging**:
- Talker for comprehensive logging
- Sentry or Firebase Crashlytics for production crash reporting
- Analytics for user behavior tracking
- Regular performance profiling

### Fallback Options

**If Riverpod Becomes Too Complex**:
- Fallback to BLoC (more structured, but more boilerplate)
- Unlikely needed - Riverpod is industry-proven

**If GoRouter Lacks Features**:
- Switch to AutoRoute for type safety
- Both have similar APIs, migration is straightforward

**If Supabase Limitations Hit**:
- Architecture supports swapping data sources
- Repository pattern allows migration to Firebase or custom backend

**If Code Generation Slows Development**:
- Can selectively reduce Freezed usage
- Use Equatable for value equality without codegen
- Keep json_serializable (essential for type-safe JSON)

## Recommendations

### Recommended Approach

**Architecture**: Feature-First Clean Architecture (4 layers)
- **Presentation**: UI components, pages, Riverpod providers
- **Application**: Business logic, use cases, services
- **Domain**: Core business models and repository interfaces
- **Data**: API clients, repository implementations, DTOs

**State Management**: Riverpod 3 with @riverpod macro
- Compile-time safety
- Excellent testability
- Context-free architecture
- Native async support

**Routing**: GoRouter
- Official Flutter support
- Simple, declarative API
- Great for web and mobile

**Core Stack**:
```
Flutter + Supabase + Riverpod 3 + GoRouter +
Freezed + Dio + Talker + Mocktail
```

### Alternative Approach (If Constraints Change)

**If Maximum Type Safety is Priority**:
- Switch GoRouter → AutoRoute
- All else remains the same

**If Enterprise-Level Structure Required**:
- Switch Riverpod → BLoC
- More ceremony, but stricter event-driven patterns

**If Rapid Prototyping Over Architecture**:
- Simplify to Feature-First with lightweight MVVM
- Still use Riverpod, but skip strict layer separation initially
- Can evolve to full Clean Architecture later

### Phased Implementation Strategy

**Phase 1: Foundation (Week 1)**
1. Set up Flutter project with recommended packages
2. Configure Supabase project and connection
3. Establish project structure (feature-first folders)
4. Set up build_runner and code generation
5. Create base classes (AppError, Result types)
6. Configure Talker logging
7. Set up environment variables

**Phase 2: Authentication Feature (Week 1-2)**
1. Implement authentication domain models
2. Create AuthRepository interface and implementation
3. Build authentication Riverpod providers
4. Create login/signup UI
5. Implement route guards with GoRouter
6. Write unit tests for auth logic

**Phase 3: Core Feature Implementation (Week 2-4)**
1. Implement first main feature following Clean Architecture
2. Establish data flow patterns (UI → Provider → Repository → Supabase)
3. Create reusable UI components
4. Implement error handling patterns
5. Add comprehensive tests

**Phase 4: Additional Features (Week 4+)**
1. Implement remaining features using established patterns
2. Refactor shared logic into core/shared
3. Optimize performance (caching, lazy loading)
4. Add integration tests
5. Set up CI/CD

**Phase 5: Polish & Production Prep (Ongoing)**
1. Error tracking integration (Sentry/Crashlytics)
2. Analytics implementation
3. Performance profiling and optimization
4. Security audit
5. Production deployment

### Success Metrics

**Code Quality**:
- Test coverage > 80%
- Zero critical linting errors
- Consistent architecture patterns across features

**Developer Experience**:
- New feature implementation follows established patterns
- Onboarding new developers < 1 week
- Hot reload remains fast (<2s)

**Performance**:
- App startup time < 3s
- UI responds within 16ms (60fps)
- API calls cached appropriately

**Maintainability**:
- Changes to data source don't require UI changes
- Adding new features doesn't break existing features
- Business logic easily testable in isolation

## References

### Official Documentation
- [Flutter App Architecture Guide](https://docs.flutter.dev/app-architecture/guide)
- [Riverpod Official Documentation](https://riverpod.dev/)
- [GoRouter Package](https://pub.dev/packages/go_router)
- [Supabase Flutter Documentation](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)

### Best Practices & Tutorials
- [Building Scalable Flutter Apps with Clean Architecture](https://medium.com/@survildhaduk/building-scalable-flutter-apps-with-clean-architecture-9395f0537d5b)
- [Flutter Riverpod: The Ultimate Guide](https://codewithandrea.com/articles/flutter-state-management-riverpod/)
- [Supabase × Flutter in 2025 — The Full‑Stack Guide](https://medium.com/@AlexCodeX/supabase-flutter-in-2025-the-full-stack-guide-b5e6728be2db)
- [Mastering Flutter Clean Architecture in 2025](https://medium.com/@notesapp555/mastering-flutter-clean-architecture-in-2025-a-beginner-to-pro-guide-for-scalable-app-development-d87a3995408e)

### Package Resources
- [Freezed Package](https://pub.dev/packages/freezed)
- [Dio Package](https://pub.dev/packages/dio)
- [Talker Flutter Package](https://pub.dev/packages/talker_flutter)
- [Mocktail Package](https://github.com/felangel/mocktail)
- [AutoRoute Package](https://pub.dev/packages/auto_route)

### Comparison Articles
- [Understanding the Difference Between Auto Router and Go Router](https://medium.com/@blup-tool/understanding-the-difference-between-auto-router-and-go-router-in-flutter-64eb7bbfb0a1)
- [Flutter State Management Tool 2025: Riverpod 3 vs. Bloc](https://www.creolestudios.com/flutter-state-management-tool-comparison/)
- [Testing REST API Integration with Mockito and Mocktail](https://vibe-studio.ai/insights/testing-rest-api-integration-in-flutter-with-mockito-and-mocktail)

### Performance & Optimization
- [FlutterFlow Supabase Best Practices: Ultimate 2025 Performance Tips](https://www.sidetool.co/post/flutterflow-supabase-2025-performance-tips/)
- [Flutter App Development: 8 Best Practices to Follow in 2025](https://www.miquido.com/blog/flutter-app-best-practices/)

## Appendix

### Additional Notes

**Code Generation Commands**:
```bash
# One-time build
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (during development)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean and rebuild
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

**VS Code Tasks** (add to .vscode/tasks.json):
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Build Runner - Build",
      "type": "shell",
      "command": "flutter pub run build_runner build --delete-conflicting-outputs"
    },
    {
      "label": "Build Runner - Watch",
      "type": "shell",
      "command": "flutter pub run build_runner watch --delete-conflicting-outputs",
      "isBackground": true
    }
  ]
}
```

**Recommended VS Code Extensions**:
- Flutter
- Dart
- Pubspec Assist
- Error Lens
- Better Comments

**Recommended Project Structure Example**:
```
lib/
├── main.dart
├── app/
│   ├── app.dart                    # Main app widget
│   └── router.dart                 # GoRouter configuration
├── core/
│   ├── constants/
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   └── supabase_client.dart
│   ├── utils/
│   └── theme/
├── shared/
│   ├── models/                     # Shared domain models
│   ├── widgets/                    # Reusable UI components
│   └── providers/                  # Global providers
└── features/
    ├── authentication/
    │   ├── presentation/
    │   │   ├── pages/
    │   │   │   ├── login_page.dart
    │   │   │   └── signup_page.dart
    │   │   ├── widgets/
    │   │   │   └── auth_form.dart
    │   │   └── providers/
    │   │       └── auth_provider.dart
    │   ├── application/
    │   │   └── auth_service.dart
    │   ├── domain/
    │   │   ├── models/
    │   │   │   ├── user.dart
    │   │   │   └── auth_state.dart
    │   │   └── repositories/
    │   │       └── auth_repository.dart
    │   └── data/
    │       ├── repositories/
    │       │   └── supabase_auth_repository.dart
    │       ├── data_sources/
    │       │   └── auth_remote_data_source.dart
    │       └── dtos/
    │           └── user_dto.dart
    └── profile/
        └── ... (similar structure)
```

### Questions for Further Investigation

1. **Offline-First Implementation**: Which local database (Hive, Isar, Drift) best complements Supabase for offline-first architecture?

2. **Code Push/OTA Updates**: Should we integrate code push solutions (Shorebird, CodePush) for faster bug fixes?

3. **Analytics Platform**: Which analytics solution (Firebase Analytics, Mixpanel, PostHog) best integrates with this stack?

4. **Monitoring**: Should we use Firebase Performance Monitoring, Sentry Performance, or custom solution?

5. **Feature Flags**: Is a feature flag system (LaunchDarkly, Firebase Remote Config) needed for gradual rollouts?

6. **Accessibility**: What additional packages or patterns should we establish for WCAG compliance?

### Related Topics Worth Exploring

- **GraphQL with Supabase**: Supabase supports GraphQL - evaluate if it simplifies data fetching
- **Microservices Architecture**: If the app grows very large, consider feature modules as microservices
- **Design System**: Establish comprehensive design system with theme, components, and guidelines
- **Animations**: Research animation packages (Rive, Lottie) for engaging UX
- **Localization**: Set up l10n early if multi-language support is planned
- **Push Notifications**: Supabase Edge Functions + FCM integration strategy
- **Deep Linking**: Advanced deep linking scenarios with GoRouter
- **Widgets Testing**: Golden file testing strategy for UI regression prevention

---

**Research Completed**: December 2, 2025

**Next Recommended Step**: Proceed to `/plan` command to create detailed implementation plan for project setup and first feature.
