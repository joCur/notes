-- Voice-First Note-Taking App - Row Level Security (RLS) Policies
-- Migration: 004_row_level_security.sql
-- Description: Implements comprehensive RLS policies for data isolation and security

-- =====================================================
-- Enable Row Level Security on all tables
-- =====================================================
-- Note: user_profiles RLS and policies already created in migration 001
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE note_tags ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- RLS Policies: user_profiles
-- Description: Policies already created in migration 001_create_user_profiles.sql
-- Skipping to avoid conflicts
-- =====================================================

-- =====================================================
-- RLS Policies: notes
-- Description: Users can only access their own notes
-- =====================================================

-- SELECT: Users can view their own notes
CREATE POLICY "Users can view own notes"
    ON notes
    FOR SELECT
    USING (auth.uid() = user_id);

-- INSERT: Users can create notes for themselves
CREATE POLICY "Users can create own notes"
    ON notes
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- UPDATE: Users can update their own notes
CREATE POLICY "Users can update own notes"
    ON notes
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- DELETE: Users can delete their own notes
CREATE POLICY "Users can delete own notes"
    ON notes
    FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- RLS Policies: tags
-- Description: Users can only access their own tags
-- =====================================================

-- SELECT: Users can view their own tags
CREATE POLICY "Users can view own tags"
    ON tags
    FOR SELECT
    USING (auth.uid() = user_id);

-- INSERT: Users can create tags for themselves
CREATE POLICY "Users can create own tags"
    ON tags
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- UPDATE: Users can update their own tags
CREATE POLICY "Users can update own tags"
    ON tags
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- DELETE: Users can delete their own tags
CREATE POLICY "Users can delete own tags"
    ON tags
    FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- RLS Policies: note_tags
-- Description: Users can only manage tag associations for their own notes
-- Note: Must verify note ownership to prevent unauthorized tag associations
-- =====================================================

-- SELECT: Users can view tag associations for their own notes
CREATE POLICY "Users can view own note tags"
    ON note_tags
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM notes
            WHERE notes.id = note_tags.note_id
            AND notes.user_id = auth.uid()
        )
    );

-- INSERT: Users can add tags to their own notes with their own tags
CREATE POLICY "Users can add tags to own notes"
    ON note_tags
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM notes
            WHERE notes.id = note_tags.note_id
            AND notes.user_id = auth.uid()
        )
        AND
        EXISTS (
            SELECT 1 FROM tags
            WHERE tags.id = note_tags.tag_id
            AND tags.user_id = auth.uid()
        )
    );

-- DELETE: Users can remove tag associations from their own notes
CREATE POLICY "Users can remove tags from own notes"
    ON note_tags
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM notes
            WHERE notes.id = note_tags.note_id
            AND notes.user_id = auth.uid()
        )
    );

-- =====================================================
-- Comments for documentation
-- =====================================================
-- Note: user_profiles policy comments already exist in migration 001

COMMENT ON POLICY "Users can view own notes" ON notes IS 'RLS: Users can only SELECT notes they created';
COMMENT ON POLICY "Users can create own notes" ON notes IS 'RLS: Users can only INSERT notes for themselves';
COMMENT ON POLICY "Users can update own notes" ON notes IS 'RLS: Users can only UPDATE notes they own';
COMMENT ON POLICY "Users can delete own notes" ON notes IS 'RLS: Users can only DELETE notes they own';

COMMENT ON POLICY "Users can view own tags" ON tags IS 'RLS: Users can only SELECT tags they created';
COMMENT ON POLICY "Users can create own tags" ON tags IS 'RLS: Users can only INSERT tags for themselves';
COMMENT ON POLICY "Users can update own tags" ON tags IS 'RLS: Users can only UPDATE tags they own';
COMMENT ON POLICY "Users can delete own tags" ON tags IS 'RLS: Users can only DELETE tags they own';

COMMENT ON POLICY "Users can view own note tags" ON note_tags IS 'RLS: Users can only SELECT tag associations for their notes';
COMMENT ON POLICY "Users can add tags to own notes" ON note_tags IS 'RLS: Users can only INSERT tag associations for their own notes with their own tags';
COMMENT ON POLICY "Users can remove tags from own notes" ON note_tags IS 'RLS: Users can only DELETE tag associations from their notes';

-- =====================================================
-- Testing RLS Policies (Manual Testing with Different Users)
-- =====================================================
-- Test as User A:
--   1. Create note: INSERT INTO notes (user_id, title, content) VALUES (auth.uid(), 'Test', '{"ops":[{"insert":"Hello"}]}');
--   2. View notes: SELECT * FROM notes; -- Should only see User A's notes
--   3. Try to view User B's notes: SELECT * FROM notes WHERE user_id = 'user-b-uuid'; -- Should return empty

-- Test tag isolation:
--   1. User A creates tag: INSERT INTO tags (user_id, name) VALUES (auth.uid(), 'Personal');
--   2. User B tries to use User A's tag: INSERT INTO note_tags VALUES ('user-b-note-uuid', 'user-a-tag-uuid'); -- Should fail

-- Test note_tags ownership verification:
--   1. User A can add their tag to their note: INSERT INTO note_tags VALUES ('user-a-note-uuid', 'user-a-tag-uuid'); -- Success
--   2. User A cannot add their tag to User B's note: INSERT INTO note_tags VALUES ('user-b-note-uuid', 'user-a-tag-uuid'); -- Should fail
