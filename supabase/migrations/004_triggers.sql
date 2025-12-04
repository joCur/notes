-- Voice-First Note-Taking App - Database Triggers
-- Migration: 003_triggers.sql
-- Description: Implements triggers for automatic timestamp updates and tag usage counting

-- =====================================================
-- Function: update_updated_at_column
-- Description: Generic function to update updated_at timestamp
-- Usage: Apply to any table that has an updated_at column
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- =====================================================
-- Trigger: Apply update_updated_at to notes table
-- Description: Automatically updates updated_at when note is modified
-- =====================================================
CREATE TRIGGER trigger_notes_updated_at
    BEFORE UPDATE ON notes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- Trigger: Apply update_updated_at to tags table
-- Description: Automatically updates updated_at when tag is modified
-- =====================================================
CREATE TRIGGER trigger_tags_updated_at
    BEFORE UPDATE ON tags
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- Trigger: Apply update_updated_at to user_profiles table
-- Description: Automatically updates updated_at when profile is modified
-- =====================================================
CREATE TRIGGER trigger_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- Function: update_tag_usage_count
-- Description: Updates usage_count when tags are added/removed from notes
-- Behavior:
--   - INSERT: Increments usage_count
--   - DELETE: Decrements usage_count
-- =====================================================
CREATE OR REPLACE FUNCTION update_tag_usage_count()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        -- Increment usage count when tag is added to a note
        UPDATE tags
        SET usage_count = usage_count + 1
        WHERE id = NEW.tag_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        -- Decrement usage count when tag is removed from a note
        UPDATE tags
        SET usage_count = GREATEST(usage_count - 1, 0)
        WHERE id = OLD.tag_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$;

-- =====================================================
-- Trigger: Update tag usage on note_tags INSERT
-- Description: Increments tag usage_count when tag is added to note
-- =====================================================
CREATE TRIGGER trigger_note_tags_insert_usage
    AFTER INSERT ON note_tags
    FOR EACH ROW
    EXECUTE FUNCTION update_tag_usage_count();

-- =====================================================
-- Trigger: Update tag usage on note_tags DELETE
-- Description: Decrements tag usage_count when tag is removed from note
-- =====================================================
CREATE TRIGGER trigger_note_tags_delete_usage
    AFTER DELETE ON note_tags
    FOR EACH ROW
    EXECUTE FUNCTION update_tag_usage_count();

-- =====================================================
-- Comments for documentation
-- =====================================================
COMMENT ON FUNCTION update_updated_at_column IS 'Generic trigger function to automatically update updated_at timestamp';
COMMENT ON FUNCTION update_tag_usage_count IS 'Updates tag usage_count when tags are added/removed from notes';

COMMENT ON TRIGGER trigger_notes_updated_at ON notes IS 'Automatically updates updated_at timestamp on note modification';
COMMENT ON TRIGGER trigger_tags_updated_at ON tags IS 'Automatically updates updated_at timestamp on tag modification';
COMMENT ON TRIGGER trigger_user_profiles_updated_at ON user_profiles IS 'Automatically updates updated_at timestamp on profile modification';
COMMENT ON TRIGGER trigger_note_tags_insert_usage ON note_tags IS 'Increments tag usage_count when tag is added to a note';
COMMENT ON TRIGGER trigger_note_tags_delete_usage ON note_tags IS 'Decrements tag usage_count when tag is removed from a note';

-- =====================================================
-- Testing Trigger Behavior (Manual SQL Commands)
-- =====================================================
-- Test updated_at trigger:
--   1. UPDATE notes SET title = 'New Title' WHERE id = 'note-uuid';
--   2. SELECT updated_at FROM notes WHERE id = 'note-uuid'; -- Should be NOW()

-- Test tag usage_count trigger:
--   1. INSERT INTO note_tags (note_id, tag_id) VALUES ('note-uuid', 'tag-uuid');
--   2. SELECT usage_count FROM tags WHERE id = 'tag-uuid'; -- Should increment by 1
--   3. DELETE FROM note_tags WHERE note_id = 'note-uuid' AND tag_id = 'tag-uuid';
--   4. SELECT usage_count FROM tags WHERE id = 'tag-uuid'; -- Should decrement by 1
