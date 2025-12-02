# Voice-First Note-Taking App

A revolutionary voice-first note-taking application built with Flutter and Supabase, featuring a custom Bauhaus-inspired design system.

## Features

- **Voice-First Input**: Speech-to-text as the primary input method using native device APIs
- **Rich Text Editor**: WYSIWYG editor powered by flutter_quill
- **Tag System**: Flexible user-specific tagging with colors and icons
- **Full-Text Search**: Powerful search combining text queries with tag filtering
- **Multilingual Support**: English and German localization
- **Bauhaus Design**: Custom geometric UI following Bauhaus principles

## Prerequisites

- Flutter SDK 3.29+ with Dart 3.7+
- Xcode 15+ (for iOS development)
- Android Studio with Android SDK (API 21+)
- Docker Desktop (for local Supabase)
- Supabase CLI (install with: `brew install supabase/tap/supabase`)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd notes
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Start Local Supabase (for development)

```bash
# Start Supabase local dev server
supabase start

# This will output your local credentials
# The .env file is already configured with local development credentials
```

**Local Development URLs:**
- API URL: http://127.0.0.1:54321
- Studio URL: http://127.0.0.1:54323 (Database management UI)
- Mailpit URL: http://127.0.0.1:54324 (Email testing)

**Stop Supabase when done:**
```bash
supabase stop
```

### 4. Run Code Generation

```bash
# Run once
flutter pub run build_runner build

# Or watch for changes during development
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 5. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── core/                   # Core infrastructure
│   ├── domain/            # Domain models and failure types
│   ├── data/              # Supabase client and data infrastructure
│   ├── presentation/      # Theme, widgets, and UI components
│   ├── routing/           # App navigation (GoRouter)
│   ├── env/               # Environment configuration
│   └── utils/             # Utility functions
├── features/              # Feature modules
│   ├── auth/              # Authentication
│   ├── notes/             # Note management
│   ├── voice/             # Speech-to-text
│   ├── tags/              # Tag system
│   └── editor/            # Rich text editor
└── l10n/                  # Localization files
```

## Architecture

This project follows **Feature-First Clean Architecture** with 4 layers:
- **Domain**: Business logic and entities
- **Data**: Repository implementations and data sources
- **Application**: State management with Riverpod
- **Presentation**: UI components and screens

## Available Scripts

```bash
# Run code generation
flutter pub run build_runner build

# Watch for changes
flutter pub run build_runner watch --delete-conflicting-outputs

# Run tests
flutter test

# Run linting
flutter analyze

# Generate localization
flutter gen-l10n
```

## Required Environment Variables

- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Your Supabase anonymous key

## License

[Your license here]
