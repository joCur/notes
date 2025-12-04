-- Voice-First Note-Taking App - Initial Database Schema
-- Migration: 001_initial_schema.sql
-- Description: Creates core tables for notes, tags, user profiles, and their relationships

-- Enable UUID extension (if not already enabled)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- Table: user_profiles
-- Description: Extended user profile information beyond Supabase auth.users
-- =====================================================
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    display_name TEXT,
    preferred_language TEXT DEFAULT 'en' CHECK (preferred_language IN ('en', 'de')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT user_profiles_email_key UNIQUE (email)
);

-- Index for faster lookups by email
CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON user_profiles(email);

-- =====================================================
-- Table: notes
-- Description: Core note storage with metadata and content
-- =====================================================
CREATE TABLE IF NOT EXISTS notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT,
    content JSONB NOT NULL, -- Stores Quill Delta JSON format
    language TEXT, -- ISO 639-1 language code (e.g., 'en', 'de')
    language_confidence REAL CHECK (language_confidence >= 0 AND language_confidence <= 1),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT notes_user_id_key FOREIGN KEY (user_id) REFERENCES auth.users(id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_notes_user_id ON notes(user_id);
CREATE INDEX IF NOT EXISTS idx_notes_created_at ON notes(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notes_updated_at ON notes(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_notes_language ON notes(language);

-- =====================================================
-- Table: tags
-- Description: User-specific tags with metadata
-- =====================================================
CREATE TABLE IF NOT EXISTS tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    color TEXT NOT NULL DEFAULT '#21409A', -- Bauhaus Blue default
    icon TEXT, -- Optional emoji or icon identifier
    description TEXT,
    usage_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT tags_user_id_name_key UNIQUE (user_id, name), -- Prevent duplicate tag names per user
    CONSTRAINT tags_usage_count_check CHECK (usage_count >= 0)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_tags_user_id ON tags(user_id);
CREATE INDEX IF NOT EXISTS idx_tags_name ON tags(name);
CREATE INDEX IF NOT EXISTS idx_tags_usage_count ON tags(usage_count DESC);

-- =====================================================
-- Table: note_tags
-- Description: Many-to-many junction table for notes and tags
-- =====================================================
CREATE TABLE IF NOT EXISTS note_tags (
    note_id UUID NOT NULL REFERENCES notes(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (note_id, tag_id)
);

-- Indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_note_tags_note_id ON note_tags(note_id);
CREATE INDEX IF NOT EXISTS idx_note_tags_tag_id ON note_tags(tag_id);

-- =====================================================
-- Comments for documentation
-- =====================================================
COMMENT ON TABLE user_profiles IS 'Extended user profile information linked to Supabase auth.users';
COMMENT ON TABLE notes IS 'Core note storage with rich text content (Quill Delta format) and metadata';
COMMENT ON TABLE tags IS 'User-specific tags for organizing notes';
COMMENT ON TABLE note_tags IS 'Many-to-many relationship between notes and tags';

COMMENT ON COLUMN notes.content IS 'Rich text content stored as Quill Delta JSON format';
COMMENT ON COLUMN notes.language IS 'Detected language ISO 639-1 code (en, de, etc.)';
COMMENT ON COLUMN notes.language_confidence IS 'Language detection confidence score (0.0 to 1.0)';
COMMENT ON COLUMN tags.color IS 'Hex color code for tag display (Bauhaus color palette)';
COMMENT ON COLUMN tags.usage_count IS 'Number of notes tagged with this tag (maintained by trigger)';
