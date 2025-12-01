-- migrations/000004_create_gifts_table.down.sql
-- Drop triggers first
DROP TRIGGER IF EXISTS update_gifts_updated_at ON gifts;

DROP TRIGGER IF EXISTS manage_gift_stock_status ON gifts;

-- Drop the stock status management function
DROP FUNCTION IF EXISTS update_gift_stock_status ();

-- Drop the table (this will also drop all indexes and constraints associated with it)
DROP TABLE IF EXISTS gifts;

-- Drop the custom types
DROP TYPE IF EXISTS gift_condition;

DROP TYPE IF EXISTS gift_status;