-- migrations/000007_create_gift_tags_table.down.sql
-- Drop junction table first (has foreign keys to both tables)
DROP TABLE IF EXISTS gift_tags;

-- Drop tags table
DROP TABLE IF EXISTS tags;