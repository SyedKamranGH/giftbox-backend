-- migrations/000008_create_carts_table.up.sql
CREATE TABLE carts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    user_id UUID UNIQUE NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    session_id VARCHAR(255),
    created_at TIMESTAMP
    WITH
        TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP
    WITH
        TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_carts_user_id ON carts (user_id);

CREATE INDEX idx_carts_session_id ON carts (session_id);

CREATE TRIGGER update_carts_updated_at BEFORE
UPDATE ON carts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column ();