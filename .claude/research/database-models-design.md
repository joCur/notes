# Research: Database Models Design for Tag-Based Note-Taking App

## Executive Summary

This research document defines the complete database schema for a tag-based note-taking application built with Flutter and Supabase. The design incorporates best practices from research on tag systems and full-text search.

The recommended database architecture uses **PostgreSQL (via Supabase)** with the following key components:
- **Notes table** with full-text search support (tsvector)
- **Tags table** with usage tracking and color/icon support
- **Note-Tags junction table** for flexible many-to-many relationships
- **Folders table** for hierarchical organization
- **User Preferences table** for settings and configurations

The schema is designed with Row Level Security (RLS) for multi-tenant data isolation and includes language-aware full-text search supporting German and English.

## Database Schema Overview

### Core Tables

```
┌─────────────┐       ┌──────────────┐       ┌─────────────┐
│   users     │       │    notes     │       │    tags     │
│  (Supabase  │◄──────┤              │       │             │
│    Auth)    │       │              │       │             │
└─────────────┘       └──────┬───────┘       └──────┬──────┘
                             │                      │
                             │    ┌─────────────────┘
                             │    │
                             ▼    ▼
                        ┌──────────────┐
                        │  note_tags   │
                        │  (junction)  │
                        └──────────────┘

        ┌─────────────┐       ┌──────────────────┐
        │   folders   │       │ user_preferences │
        │             │       │                  │
        └──────┬──────┘       └──────────────────┘
               │
               │ (self-reference)
               ▼
        ┌─────────────┐
        │   folders   │
        └─────────────┘
```

## Table Definitions

### 1. Notes Table

The core table storing all note content with full-text search support.

```sql
CREATE TABLE notes (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Foreign Keys
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  folder_id UUID REFERENCES folders(id) ON DELETE SET NULL,

  -- Content Fields
  title TEXT,
  content TEXT NOT NULL,

  -- Language Support
  language TEXT DEFAULT 'en',

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  -- Soft Delete (for recovery)
  deleted_at TIMESTAMPTZ,

  -- Full-Text Search Vector (generated column)
  search_vector TSVECTOR GENERATED ALWAYS AS (
    setweight(to_tsvector(
      CASE
        WHEN language = 'de' THEN 'german'::regconfig
        WHEN language = 'en' THEN 'english'::regconfig
        ELSE 'simple'::regconfig
      END,
      coalesce(title, '')
    ), 'A') ||
    setweight(to_tsvector(
      CASE
        WHEN language = 'de' THEN 'german'::regconfig
        WHEN language = 'en' THEN 'english'::regconfig
        ELSE 'simple'::regconfig
      END,
      coalesce(content, '')
    ), 'B')
  ) STORED
);

-- Indexes
CREATE INDEX notes_user_id_idx ON notes(user_id);
CREATE INDEX notes_folder_id_idx ON notes(folder_id);
CREATE INDEX notes_created_at_idx ON notes(created_at DESC);
CREATE INDEX notes_updated_at_idx ON notes(updated_at DESC);
CREATE INDEX notes_search_idx ON notes USING GIN(search_vector);
CREATE INDEX notes_language_idx ON notes(language);

-- Partial index for non-deleted notes
CREATE INDEX notes_active_idx ON notes(user_id, created_at DESC)
  WHERE deleted_at IS NULL;

-- Update trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notes_updated_at
  BEFORE UPDATE ON notes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

**Key Design Decisions**:
- `search_vector` is a generated column that automatically updates when title/content changes
- Language-aware full-text search supports German and English with appropriate stemmers
- `soft delete` with `deleted_at` allows recovery
- Simple timestamp tracking without complex versioning

### 2. Tags Table

Stores reusable tags with metadata for organization and visual differentiation.

```sql
CREATE TABLE tags (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Foreign Key
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,

  -- Tag Information
  name TEXT NOT NULL,
  color TEXT DEFAULT '#2196F3' NOT NULL, -- Hex color code
  icon TEXT, -- Icon name (e.g., 'work', 'dream', 'idea')
  description TEXT,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  -- Performance Optimization (denormalized)
  usage_count INTEGER DEFAULT 0 NOT NULL,
  last_used_at TIMESTAMPTZ,

  -- Unique Constraint
  CONSTRAINT unique_tag_per_user UNIQUE(user_id, name)
);

-- Indexes
CREATE INDEX tags_user_id_idx ON tags(user_id);
CREATE INDEX tags_name_idx ON tags(name);
CREATE INDEX tags_usage_count_idx ON tags(usage_count DESC);
CREATE INDEX tags_last_used_idx ON tags(last_used_at DESC);

-- Full-text search on tag names
CREATE INDEX tags_name_trgm_idx ON tags USING GIN (name gin_trgm_ops);

-- Update trigger for updated_at
CREATE TRIGGER tags_updated_at
  BEFORE UPDATE ON tags
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

**Key Design Decisions**:
- Unique constraint ensures no duplicate tag names per user
- `usage_count` is denormalized for performance (updated via trigger)
- Trigram index enables fuzzy search for tag autocomplete
- Color stored as hex string for easy parsing in Flutter
- Icons stored as string identifiers (mapped to Material Icons in app)

### 3. Note-Tags Junction Table

Many-to-many relationship between notes and tags.

```sql
CREATE TABLE note_tags (
  -- Composite Primary Key
  note_id UUID REFERENCES notes(id) ON DELETE CASCADE NOT NULL,
  tag_id UUID REFERENCES tags(id) ON DELETE CASCADE NOT NULL,

  -- Metadata
  tagged_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  auto_tagged BOOLEAN DEFAULT FALSE NOT NULL, -- Was this auto-suggested by NLP?

  PRIMARY KEY (note_id, tag_id)
);

-- Indexes for efficient lookups
CREATE INDEX note_tags_note_id_idx ON note_tags(note_id);
CREATE INDEX note_tags_tag_id_idx ON note_tags(tag_id);
CREATE INDEX note_tags_tagged_at_idx ON note_tags(tagged_at DESC);

-- Trigger to update tag usage_count
CREATE OR REPLACE FUNCTION update_tag_usage_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE tags
    SET
      usage_count = usage_count + 1,
      last_used_at = NOW()
    WHERE id = NEW.tag_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE tags
    SET usage_count = GREATEST(usage_count - 1, 0)
    WHERE id = OLD.tag_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_tag_usage_count_trigger
  AFTER INSERT OR DELETE ON note_tags
  FOR EACH ROW
  EXECUTE FUNCTION update_tag_usage_count();
```

**Key Design Decisions**:
- Composite primary key prevents duplicate tag assignments
- `auto_tagged` flag tracks NLP-suggested vs manually-added tags
- CASCADE deletes ensure referential integrity
- Trigger automatically maintains `usage_count` denormalization

### 4. Folders Table

Hierarchical folder structure for organizing notes.

```sql
CREATE TABLE folders (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Foreign Keys
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  parent_folder_id UUID REFERENCES folders(id) ON DELETE CASCADE,

  -- Folder Information
  name TEXT NOT NULL,
  color TEXT DEFAULT '#757575', -- Grey default
  icon TEXT, -- Optional icon
  description TEXT,

  -- Display Order
  sort_order INTEGER DEFAULT 0,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  -- Unique Constraint (prevent duplicate names in same location)
  CONSTRAINT unique_folder_name UNIQUE(user_id, parent_folder_id, name)
);

-- Indexes
CREATE INDEX folders_user_id_idx ON folders(user_id);
CREATE INDEX folders_parent_folder_id_idx ON folders(parent_folder_id);
CREATE INDEX folders_sort_order_idx ON folders(sort_order);

-- Update trigger
CREATE TRIGGER folders_updated_at
  BEFORE UPDATE ON folders
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function to prevent circular references
CREATE OR REPLACE FUNCTION check_folder_parent_cycle()
RETURNS TRIGGER AS $$
DECLARE
  current_id UUID;
  depth INTEGER := 0;
  max_depth INTEGER := 10;
BEGIN
  current_id := NEW.parent_folder_id;

  WHILE current_id IS NOT NULL AND depth < max_depth LOOP
    IF current_id = NEW.id THEN
      RAISE EXCEPTION 'Circular folder reference detected';
    END IF;

    SELECT parent_folder_id INTO current_id
    FROM folders
    WHERE id = current_id;

    depth := depth + 1;
  END LOOP;

  IF depth >= max_depth THEN
    RAISE EXCEPTION 'Folder nesting too deep (max 10 levels)';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_folder_parent_cycle_trigger
  BEFORE INSERT OR UPDATE ON folders
  FOR EACH ROW
  EXECUTE FUNCTION check_folder_parent_cycle();
```

**Key Design Decisions**:
- Self-referencing foreign key enables unlimited folder nesting
- Unique constraint prevents duplicate folder names at same level
- `sort_order` allows manual ordering within a folder
- Trigger prevents circular references (folder as its own ancestor)
- Maximum depth limit (10 levels) prevents infinite recursion

### 5. User Preferences Table

Per-user settings and preferences.

```sql
CREATE TABLE user_preferences (
  -- Primary Key (one row per user)
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Language Preferences
  default_language TEXT DEFAULT 'en',
  preferred_languages TEXT[] DEFAULT ARRAY['en'],

  -- UI Preferences
  theme TEXT CHECK (theme IN ('light', 'dark', 'system')) DEFAULT 'system',
  default_note_view TEXT CHECK (
    default_note_view IN ('list', 'grid', 'compact')
  ) DEFAULT 'list',

  -- Organization Preferences
  default_folder_id UUID REFERENCES folders(id) ON DELETE SET NULL,
  auto_tag_enabled BOOLEAN DEFAULT TRUE,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Update trigger
CREATE TRIGGER user_preferences_updated_at
  BEFORE UPDATE ON user_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

**Key Design Decisions**:
- One row per user (enforced by primary key)
- Defaults align with research recommendations
- Simplified preferences without sync or storage management

## Row Level Security (RLS) Policies

All tables must have RLS enabled for multi-tenant security.

```sql
-- Enable RLS on all tables
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE note_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE folders ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

-- Notes Policies
CREATE POLICY "Users can view own notes"
  ON notes FOR SELECT
  USING (auth.uid() = user_id AND deleted_at IS NULL);

CREATE POLICY "Users can insert own notes"
  ON notes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own notes"
  ON notes FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can soft delete own notes"
  ON notes FOR UPDATE
  USING (auth.uid() = user_id);

-- Tags Policies
CREATE POLICY "Users can view own tags"
  ON tags FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own tags"
  ON tags FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own tags"
  ON tags FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own tags"
  ON tags FOR DELETE
  USING (auth.uid() = user_id);

-- Note-Tags Policies
CREATE POLICY "Users can view own note-tags"
  ON note_tags FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM notes
      WHERE notes.id = note_tags.note_id
      AND notes.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own note-tags"
  ON note_tags FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM notes
      WHERE notes.id = note_tags.note_id
      AND notes.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own note-tags"
  ON note_tags FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM notes
      WHERE notes.id = note_tags.note_id
      AND notes.user_id = auth.uid()
    )
  );

-- Folders Policies
CREATE POLICY "Users can view own folders"
  ON folders FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own folders"
  ON folders FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own folders"
  ON folders FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own folders"
  ON folders FOR DELETE
  USING (auth.uid() = user_id);

-- User Preferences Policies
CREATE POLICY "Users can view own preferences"
  ON user_preferences FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own preferences"
  ON user_preferences FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own preferences"
  ON user_preferences FOR UPDATE
  USING (auth.uid() = user_id);
```

## Database Functions

### 1. Full-Text Search Function

```sql
CREATE OR REPLACE FUNCTION search_notes(
  query_text TEXT,
  tag_filters UUID[] DEFAULT NULL,
  folder_filter UUID DEFAULT NULL,
  language_filter TEXT DEFAULT NULL,
  start_date TIMESTAMPTZ DEFAULT NULL,
  end_date TIMESTAMPTZ DEFAULT NULL,
  result_limit INTEGER DEFAULT 50
)
RETURNS TABLE(
  id UUID,
  title TEXT,
  content TEXT,
  created_at TIMESTAMPTZ,
  rank REAL,
  headline TEXT,
  tags JSONB
) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT
    n.id,
    n.title,
    n.content,
    n.created_at,
    ts_rank(n.search_vector, websearch_to_tsquery(
      CASE
        WHEN language_filter = 'de' THEN 'german'
        WHEN language_filter = 'en' THEN 'english'
        ELSE 'simple'
      END,
      query_text
    )) as rank,
    ts_headline(
      CASE
        WHEN language_filter = 'de' THEN 'german'
        WHEN language_filter = 'en' THEN 'english'
        ELSE 'simple'
      END,
      left(n.content, 500),
      websearch_to_tsquery(
        CASE
          WHEN language_filter = 'de' THEN 'german'
          WHEN language_filter = 'en' THEN 'english'
          ELSE 'simple'
        END,
        query_text
      ),
      'MaxFragments=3, MaxWords=20, MinWords=10'
    ) as headline,
    (
      SELECT jsonb_agg(jsonb_build_object(
        'id', t.id,
        'name', t.name,
        'color', t.color,
        'icon', t.icon
      ))
      FROM tags t
      JOIN note_tags nt ON t.id = nt.tag_id
      WHERE nt.note_id = n.id
    ) as tags
  FROM notes n
  LEFT JOIN note_tags nt ON n.id = nt.note_id
  WHERE
    n.user_id = auth.uid()
    AND n.deleted_at IS NULL
    AND n.search_vector @@ websearch_to_tsquery(
      CASE
        WHEN language_filter = 'de' THEN 'german'
        WHEN language_filter = 'en' THEN 'english'
        ELSE 'simple'
      END,
      query_text
    )
    AND (tag_filters IS NULL OR nt.tag_id = ANY(tag_filters))
    AND (folder_filter IS NULL OR n.folder_id = folder_filter)
    AND (language_filter IS NULL OR n.language = language_filter)
    AND (start_date IS NULL OR n.created_at >= start_date)
    AND (end_date IS NULL OR n.created_at <= end_date)
  ORDER BY rank DESC, n.created_at DESC
  LIMIT result_limit;
END;
$$ LANGUAGE plpgsql;
```

### 2. Tag Management Functions

```sql
-- Merge multiple tags into one
CREATE OR REPLACE FUNCTION merge_tags(
  source_tag_ids UUID[],
  target_tag_id UUID
)
RETURNS INTEGER AS $$
DECLARE
  affected_notes INTEGER;
BEGIN
  -- Verify ownership
  IF EXISTS (
    SELECT 1 FROM tags
    WHERE id = ANY(source_tag_ids || target_tag_id)
    AND user_id != auth.uid()
  ) THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  -- Add target tag to notes that have source tags but not target tag
  INSERT INTO note_tags (note_id, tag_id)
  SELECT DISTINCT nt.note_id, target_tag_id
  FROM note_tags nt
  WHERE nt.tag_id = ANY(source_tag_ids)
  AND NOT EXISTS (
    SELECT 1 FROM note_tags nt2
    WHERE nt2.note_id = nt.note_id
    AND nt2.tag_id = target_tag_id
  );

  -- Count affected notes
  SELECT COUNT(DISTINCT note_id) INTO affected_notes
  FROM note_tags
  WHERE tag_id = ANY(source_tag_ids);

  -- Delete old tag relationships
  DELETE FROM note_tags
  WHERE tag_id = ANY(source_tag_ids);

  -- Delete source tags
  DELETE FROM tags
  WHERE id = ANY(source_tag_ids);

  RETURN affected_notes;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Rename tag
CREATE OR REPLACE FUNCTION rename_tag(
  p_tag_id UUID,
  p_new_name TEXT
)
RETURNS VOID AS $$
BEGIN
  -- Check for duplicates
  IF EXISTS (
    SELECT 1 FROM tags
    WHERE user_id = auth.uid()
    AND name = p_new_name
    AND id != p_tag_id
  ) THEN
    RAISE EXCEPTION 'Tag with name % already exists', p_new_name;
  END IF;

  -- Update tag name
  UPDATE tags
  SET name = p_new_name
  WHERE id = p_tag_id
  AND user_id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 3. Cleanup Functions

```sql
-- Permanently delete soft-deleted notes older than 30 days
CREATE OR REPLACE FUNCTION purge_deleted_notes()
RETURNS INTEGER AS $$
DECLARE
  notes_count INTEGER;
BEGIN
  WITH deleted_notes AS (
    DELETE FROM notes
    WHERE deleted_at < NOW() - INTERVAL '30 days'
    RETURNING id
  )
  SELECT COUNT(*) INTO notes_count FROM deleted_notes;

  RETURN notes_count;
END;
$$ LANGUAGE plpgsql;
```

## Flutter/Dart Model Classes

### Note Model

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'note.freezed.dart';
part 'note.g.dart';

@freezed
class Note with _$Note {
  const factory Note({
    required String id,
    required String userId,
    String? folderId,
    String? title,
    required String content,
    @Default('en') String language,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    List<Tag>? tags,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}
```

### Tag Model

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';
part 'tag.g.dart';

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
    required DateTime updatedAt,
    @Default(0) int usageCount,
    DateTime? lastUsedAt,
  }) = _Tag;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}
```

### Folder Model

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'folder.freezed.dart';
part 'folder.g.dart';

@freezed
class Folder with _$Folder {
  const factory Folder({
    required String id,
    required String userId,
    String? parentFolderId,
    required String name,
    @Default('#757575') String color,
    String? icon,
    String? description,
    @Default(0) int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Folder;

  factory Folder.fromJson(Map<String, dynamic> json) => _$FolderFromJson(json);
}
```

### User Preferences Model

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_preferences.freezed.dart';
part 'user_preferences.g.dart';

enum Theme { light, dark, system }
enum DefaultNoteView { list, grid, compact }

@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    required String userId,
    @Default('en') String defaultLanguage,
    @Default(['en']) List<String> preferredLanguages,
    @Default(Theme.system) Theme theme,
    @Default(DefaultNoteView.list) DefaultNoteView defaultNoteView,
    String? defaultFolderId,
    @Default(true) bool autoTagEnabled,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
    _$UserPreferencesFromJson(json);
}
```

## Migration Strategy

### Phase 1: Core Tables

```sql
-- migrations/001_create_core_tables.sql
BEGIN;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Create update trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create notes table
CREATE TABLE notes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  folder_id UUID REFERENCES folders(id) ON DELETE SET NULL,
  title TEXT,
  content TEXT NOT NULL,
  language TEXT DEFAULT 'en',
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  deleted_at TIMESTAMPTZ,
  search_vector TSVECTOR GENERATED ALWAYS AS (
    setweight(to_tsvector(
      CASE
        WHEN language = 'de' THEN 'german'::regconfig
        WHEN language = 'en' THEN 'english'::regconfig
        ELSE 'simple'::regconfig
      END,
      coalesce(title, '')
    ), 'A') ||
    setweight(to_tsvector(
      CASE
        WHEN language = 'de' THEN 'german'::regconfig
        WHEN language = 'en' THEN 'english'::regconfig
        ELSE 'simple'::regconfig
      END,
      coalesce(content, '')
    ), 'B')
  ) STORED
);

-- Create tags table
CREATE TABLE tags (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  color TEXT DEFAULT '#2196F3' NOT NULL,
  icon TEXT,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  usage_count INTEGER DEFAULT 0 NOT NULL,
  last_used_at TIMESTAMPTZ,
  CONSTRAINT unique_tag_per_user UNIQUE(user_id, name)
);

-- Create note_tags junction table
CREATE TABLE note_tags (
  note_id UUID REFERENCES notes(id) ON DELETE CASCADE NOT NULL,
  tag_id UUID REFERENCES tags(id) ON DELETE CASCADE NOT NULL,
  tagged_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  auto_tagged BOOLEAN DEFAULT FALSE NOT NULL,
  PRIMARY KEY (note_id, tag_id)
);

-- Create indexes
CREATE INDEX notes_user_id_idx ON notes(user_id);
CREATE INDEX notes_folder_id_idx ON notes(folder_id);
CREATE INDEX notes_created_at_idx ON notes(created_at DESC);
CREATE INDEX notes_updated_at_idx ON notes(updated_at DESC);
CREATE INDEX notes_search_idx ON notes USING GIN(search_vector);
CREATE INDEX notes_language_idx ON notes(language);
CREATE INDEX notes_active_idx ON notes(user_id, created_at DESC) WHERE deleted_at IS NULL;

CREATE INDEX tags_user_id_idx ON tags(user_id);
CREATE INDEX tags_name_idx ON tags(name);
CREATE INDEX tags_usage_count_idx ON tags(usage_count DESC);
CREATE INDEX tags_last_used_idx ON tags(last_used_at DESC);
CREATE INDEX tags_name_trgm_idx ON tags USING GIN (name gin_trgm_ops);

CREATE INDEX note_tags_note_id_idx ON note_tags(note_id);
CREATE INDEX note_tags_tag_id_idx ON note_tags(tag_id);
CREATE INDEX note_tags_tagged_at_idx ON note_tags(tagged_at DESC);

-- Create triggers
CREATE TRIGGER notes_updated_at
  BEFORE UPDATE ON notes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tags_updated_at
  BEFORE UPDATE ON tags
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create tag usage count trigger
CREATE OR REPLACE FUNCTION update_tag_usage_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE tags
    SET usage_count = usage_count + 1, last_used_at = NOW()
    WHERE id = NEW.tag_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE tags
    SET usage_count = GREATEST(usage_count - 1, 0)
    WHERE id = OLD.tag_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_tag_usage_count_trigger
  AFTER INSERT OR DELETE ON note_tags
  FOR EACH ROW
  EXECUTE FUNCTION update_tag_usage_count();

-- Enable RLS (see RLS section for full policies)
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE note_tags ENABLE ROW LEVEL SECURITY;

COMMIT;
```

### Phase 2: Organization Tables

```sql
-- migrations/002_create_organization_tables.sql
BEGIN;

-- Create folders table
CREATE TABLE folders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  parent_folder_id UUID REFERENCES folders(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  color TEXT DEFAULT '#757575',
  icon TEXT,
  description TEXT,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  CONSTRAINT unique_folder_name UNIQUE(user_id, parent_folder_id, name)
);

-- Create user_preferences table
CREATE TABLE user_preferences (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  default_language TEXT DEFAULT 'en',
  preferred_languages TEXT[] DEFAULT ARRAY['en'],
  theme TEXT CHECK (theme IN ('light', 'dark', 'system')) DEFAULT 'system',
  default_note_view TEXT CHECK (default_note_view IN ('list', 'grid', 'compact')) DEFAULT 'list',
  default_folder_id UUID REFERENCES folders(id) ON DELETE SET NULL,
  auto_tag_enabled BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Create indexes
CREATE INDEX folders_user_id_idx ON folders(user_id);
CREATE INDEX folders_parent_folder_id_idx ON folders(parent_folder_id);
CREATE INDEX folders_sort_order_idx ON folders(sort_order);

-- Create triggers
CREATE TRIGGER folders_updated_at
  BEFORE UPDATE ON folders
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER user_preferences_updated_at
  BEFORE UPDATE ON user_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create folder cycle prevention function
CREATE OR REPLACE FUNCTION check_folder_parent_cycle()
RETURNS TRIGGER AS $$
DECLARE
  current_id UUID;
  depth INTEGER := 0;
  max_depth INTEGER := 10;
BEGIN
  current_id := NEW.parent_folder_id;

  WHILE current_id IS NOT NULL AND depth < max_depth LOOP
    IF current_id = NEW.id THEN
      RAISE EXCEPTION 'Circular folder reference detected';
    END IF;

    SELECT parent_folder_id INTO current_id FROM folders WHERE id = current_id;
    depth := depth + 1;
  END LOOP;

  IF depth >= max_depth THEN
    RAISE EXCEPTION 'Folder nesting too deep (max 10 levels)';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_folder_parent_cycle_trigger
  BEFORE INSERT OR UPDATE ON folders
  FOR EACH ROW
  EXECUTE FUNCTION check_folder_parent_cycle();

-- Enable RLS
ALTER TABLE folders ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

COMMIT;
```

### Phase 3: Functions

```sql
-- migrations/003_create_functions.sql
BEGIN;

-- Create all database functions (see Database Functions section)
-- - search_notes()
-- - merge_tags()
-- - rename_tag()
-- - purge_deleted_notes()

COMMIT;
```

## Performance Considerations

### Indexing Strategy

**Critical Indexes** (must have):
- Primary keys (automatic)
- Foreign keys for joins
- Full-text search GIN index on notes
- User ID indexes on all tables (for RLS performance)

**Performance Indexes** (high value):
- Timestamp indexes for sorting (created_at, updated_at)
- Partial indexes for filtered queries (non-deleted)
- Tag usage count for sorting popular tags

**Optional Indexes** (if needed):
- Trigram indexes for fuzzy search
- Composite indexes for common query patterns

### Query Optimization Tips

1. **Always filter by user_id first** (leverages RLS and partitioning)
2. **Use LIMIT on all queries** (prevent accidentally loading millions of rows)
3. **Avoid COUNT(*) on large tables** (use estimates or cache counts)
4. **Batch operations** (insert/update multiple rows at once)
5. **Use prepared statements** (Supabase client does this automatically)

### Caching Strategy

**Application-Level Caching**:
- Riverpod providers cache query results automatically
- Implement stale-while-revalidate pattern
- Cache frequently accessed tags and folders

**Database-Level Caching**:
- PostgreSQL query cache (automatic)
- Materialized views for expensive aggregations (if needed)

## Backup and Recovery

### Automated Backups (Supabase)

- Daily automated backups (included in Supabase)
- Point-in-time recovery (PITR) for last 7 days
- Manual snapshot creation before major changes

### Soft Delete Strategy

All deletions are soft deletes (set `deleted_at`):
- Notes: 30-day recovery window
- Tags/Folders: Immediate hard delete (or implement soft delete if needed)

### Export Functionality

Provide users ability to export all data:

```sql
-- Export all user data as JSON
CREATE OR REPLACE FUNCTION export_user_data()
RETURNS JSONB AS $$
DECLARE
  result JSONB;
BEGIN
  SELECT jsonb_build_object(
    'notes', (
      SELECT jsonb_agg(row_to_json(n.*))
      FROM notes n
      WHERE n.user_id = auth.uid() AND n.deleted_at IS NULL
    ),
    'tags', (
      SELECT jsonb_agg(row_to_json(t.*))
      FROM tags t
      WHERE t.user_id = auth.uid()
    ),
    'folders', (
      SELECT jsonb_agg(row_to_json(f.*))
      FROM folders f
      WHERE f.user_id = auth.uid()
    ),
    'preferences', (
      SELECT row_to_json(p.*)
      FROM user_preferences p
      WHERE p.user_id = auth.uid()
    )
  ) INTO result;

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Security Considerations

### Authentication

- Supabase Auth handles user authentication
- JWT tokens for API access
- Row Level Security enforces data isolation

### Data Privacy

- All tables have RLS enabled
- Users can only access their own data
- Soft deletes allow recovery but respect privacy

### GDPR Compliance

- Right to access: `export_user_data()` function
- Right to deletion: Permanent delete functions
- Data portability: JSON export format
- Consent tracking: `user_preferences` table

## Testing Strategy

### Unit Tests (Database Functions)

```sql
-- Test tag merge function
BEGIN;
  -- Setup test data
  INSERT INTO tags (id, user_id, name) VALUES
    ('tag1-uuid', auth.uid(), 'old-tag'),
    ('tag2-uuid', auth.uid(), 'target-tag');

  -- Run merge
  SELECT merge_tags(ARRAY['tag1-uuid'], 'tag2-uuid');

  -- Assert old tag deleted
  SELECT COUNT(*) FROM tags WHERE id = 'tag1-uuid'; -- Should be 0
ROLLBACK;
```

### Integration Tests (Flutter)

```dart
test('Create note with tags', () async {
  final note = await noteRepository.createNote(
    title: 'Test Note',
    content: 'Test content',
    tags: [tag1, tag2],
  );

  expect(note.tags, hasLength(2));
  expect(note.tags, contains(tag1));
});
```

### Performance Tests

- Benchmark search with 10k, 100k, 1M notes
- Test concurrent user operations
- Measure query performance with explain analyze

## Recommendations

### MVP Database Schema

**Include**:
- Notes table (with FTS)
- Tags table
- Note-tags junction table
- User preferences table (basic)
- Core RLS policies
- Search function

**Defer**:
- Folders (add in phase 2 if needed)
- Advanced functions (merge tags, etc.)
- Complex cleanup routines

### Production Considerations

1. **Enable Extensions**:
   ```sql
   CREATE EXTENSION IF NOT EXISTS pg_trgm;
   CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
   ```

2. **Configure Connection Pooling** (Supabase handles this)

3. **Monitor Query Performance**:
   - Use Supabase dashboard for slow query analysis
   - Set up alerts for long-running queries

4. **Regular Maintenance**:
   - Schedule cleanup functions (daily/weekly)
   - Monitor storage usage
   - Analyze query plans periodically

## References

### Supabase Documentation
- [Supabase Database](https://supabase.com/docs/guides/database)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Full-Text Search](https://supabase.com/docs/guides/database/full-text-search)

### PostgreSQL Documentation
- [Full-Text Search](https://www.postgresql.org/docs/current/textsearch.html)
- [Triggers](https://www.postgresql.org/docs/current/triggers.html)
- [Indexes](https://www.postgresql.org/docs/current/indexes.html)

### Related Research
- `.claude/research/tag-system-architecture.md`
- `.claude/research/full-text-search-supabase-voice.md`

---

**Research Completed**: December 2, 2025
**Next Step**: Proceed to implementation with Supabase migrations
