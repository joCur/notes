-- Voice-First Note-Taking App - Full-Text Search Infrastructure
-- Migration: 002_full_text_search.sql
-- Description: Adds full-text search capabilities with multilingual support

-- =====================================================
-- Add search_vector column to notes table
-- Description: Generated column for full-text search indexing
-- =====================================================
-- Note: We use 'simple' text search configuration for multilingual support
-- This treats all languages uniformly and doesn't stem words aggressively
ALTER TABLE notes
ADD COLUMN search_vector TSVECTOR
GENERATED ALWAYS AS (
    setweight(to_tsvector('simple', COALESCE(title, '')), 'A') ||
    setweight(to_tsvector('simple', COALESCE(content::text, '')), 'B')
) STORED;

-- =====================================================
-- Create GIN index for fast full-text search
-- Description: Generalized Inverted Index for efficient text search
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_notes_search_vector
ON notes
USING GIN (search_vector);

-- =====================================================
-- Function: search_notes
-- Description: Searches notes by text query and/or tag filters
-- Parameters:
--   - search_query: Text to search for (optional, null returns all)
--   - tag_ids: Array of tag UUIDs to filter by (optional)
--   - user_id_param: User ID for filtering results
-- Returns: Notes matching criteria with relevance rank
-- =====================================================
CREATE OR REPLACE FUNCTION search_notes(
    search_query TEXT DEFAULT NULL,
    tag_ids UUID[] DEFAULT NULL,
    user_id_param UUID DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    title TEXT,
    content JSONB,
    language TEXT,
    language_confidence REAL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    rank REAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        n.id,
        n.user_id,
        n.title,
        n.content,
        n.language,
        n.language_confidence,
        n.created_at,
        n.updated_at,
        CASE
            WHEN search_query IS NOT NULL THEN
                ts_rank(n.search_vector, to_tsquery('simple', search_query))
            ELSE
                0.0
        END AS rank
    FROM notes n
    LEFT JOIN note_tags nt ON n.id = nt.note_id
    WHERE
        -- Filter by user
        (user_id_param IS NULL OR n.user_id = user_id_param)
        AND
        -- Filter by search query (if provided)
        (search_query IS NULL OR n.search_vector @@ to_tsquery('simple', search_query))
        AND
        -- Filter by tags (if provided)
        (tag_ids IS NULL OR nt.tag_id = ANY(tag_ids))
    ORDER BY
        -- Sort by relevance if search query present, otherwise by date
        CASE
            WHEN search_query IS NOT NULL THEN rank
            ELSE 0.0
        END DESC,
        n.updated_at DESC;
END;
$$;

-- =====================================================
-- Comments for documentation
-- =====================================================
COMMENT ON COLUMN notes.search_vector IS 'Generated tsvector for full-text search (title weighted A, content weighted B)';
COMMENT ON INDEX idx_notes_search_vector IS 'GIN index for fast full-text search queries';
COMMENT ON FUNCTION search_notes IS 'Searches notes by text query and/or tag filters with relevance ranking';

-- =====================================================
-- Example Queries for Testing
-- =====================================================
-- Full-text search: SELECT * FROM search_notes('meeting & notes', NULL, 'user-uuid');
-- Tag filter only: SELECT * FROM search_notes(NULL, ARRAY['tag-uuid-1', 'tag-uuid-2']::UUID[], 'user-uuid');
-- Combined search: SELECT * FROM search_notes('project', ARRAY['tag-uuid']::UUID[], 'user-uuid');
-- All notes: SELECT * FROM search_notes(NULL, NULL, 'user-uuid');
