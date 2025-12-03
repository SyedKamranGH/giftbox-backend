-- migrations/000002_create_user_addresses_table.up.sql

CREATE TYPE address_type AS ENUM ('shipping', 'billing', 'both');

CREATE TABLE user_addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    address_type address_type NOT NULL DEFAULT 'shipping',
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    street_address_1 VARCHAR(500) NOT NULL,
    street_address_2 VARCHAR(500),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    zip_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'USA',
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_addresses_user_id ON user_addresses(user_id);
CREATE INDEX idx_user_addresses_is_default ON user_addresses(is_default);

CREATE TRIGGER update_user_addresses_updated_at BEFORE UPDATE ON user_addresses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();