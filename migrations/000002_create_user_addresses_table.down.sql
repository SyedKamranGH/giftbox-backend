-- migrations/000002_create_user_addresses_table.down.sql
-- Drop the trigger
DROP TRIGGER IF EXISTS update_user_addresses_updated_at ON user_addresses;

-- Drop the table (this will also drop all indexes associated with it)
DROP TABLE IF EXISTS user_addresses;

-- Drop the custom type
DROP TYPE IF EXISTS address_type;