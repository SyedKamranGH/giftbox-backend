-- migrations/000003_create_categories_table.down.sql
-- Drop triggers first
DROP TRIGGER IF EXISTS update_categories_updated_at ON categories;

DROP TRIGGER IF EXISTS set_category_depth ON categories;

-- Drop the depth calculation function
DROP FUNCTION IF EXISTS calculate_category_depth ();

-- Drop the table (this will also drop all indexes and constraints associated with it)
DROP TABLE IF EXISTS categories;