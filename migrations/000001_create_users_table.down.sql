-- migrations/000001_create_users_table.down.sql
-- Drop the trigger first
DROP TRIGGER IF EXISTS update_users_updated_at ON users;

-- Drop the function
DROP FUNCTION IF EXISTS update_updated_at_column ();

-- Drop the table (this will also drop all indexes associated with it)
DROP TABLE IF EXISTS users;

-- Drop the custom types
DROP TYPE IF EXISTS account_status;

DROP TYPE IF EXISTS user_role;