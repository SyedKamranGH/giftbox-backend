-- migrations/000015_create_wishlists_table.up.sql

CREATE TABLE wishlists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) DEFAULT 'My Wishlist',
    description TEXT,
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_wishlists_user_id ON wishlists(user_id);

CREATE TRIGGER update_wishlists_updated_at BEFORE UPDATE ON wishlists
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();