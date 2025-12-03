-- migrations/000006_create_gift_specifications_table.up.sql

CREATE TABLE gift_specifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    gift_id UUID NOT NULL REFERENCES gifts(id) ON DELETE CASCADE,
    spec_key VARCHAR(100) NOT NULL,
    spec_value TEXT NOT NULL,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_gift_specifications_gift_id ON gift_specifications(gift_id);
CREATE INDEX idx_gift_specifications_sort_order ON gift_specifications(sort_order);

-- Unique constraint: one gift can't have duplicate spec keys
CREATE UNIQUE INDEX idx_gift_specifications_unique ON gift_specifications(gift_id, spec_key);