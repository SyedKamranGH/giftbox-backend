-- migrations/000005_create_gift_images_table.up.sql
CREATE TABLE gift_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    gift_id UUID NOT NULL REFERENCES gifts (id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(255),
    is_primary BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP
    WITH
        TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_gift_images_gift_id ON gift_images (gift_id);

CREATE INDEX idx_gift_images_is_primary ON gift_images (is_primary);

CREATE INDEX idx_gift_images_sort_order ON gift_images (sort_order);

-- Ensure only ONE primary image per gift (prevents multiple primary images)
CREATE UNIQUE INDEX idx_gift_images_one_primary_per_gift ON gift_images (gift_id)
WHERE
    is_primary = true;