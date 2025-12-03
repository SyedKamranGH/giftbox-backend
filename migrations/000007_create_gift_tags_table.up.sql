-- migrations/000007_create_gift_tags_table.up.sql
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    name VARCHAR(50) UNIQUE NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP
    WITH
        TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE gift_tags (
    gift_id UUID NOT NULL REFERENCES gifts (id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES tags (id) ON DELETE CASCADE,
    created_at TIMESTAMP
    WITH
        TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (gift_id, tag_id)
);

CREATE INDEX idx_tags_slug ON tags (slug);

CREATE INDEX idx_gift_tags_gift_id ON gift_tags (gift_id);

CREATE INDEX idx_gift_tags_tag_id ON gift_tags (tag_id);