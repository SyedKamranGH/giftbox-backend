-- migrations/000024_create_coupon_junction_tables.up.sql
-- Junction table for coupon-category many-to-many relationship
-- This replaces the applicable_category_ids UUID[] array field
CREATE TABLE coupon_categories (
    coupon_id UUID NOT NULL REFERENCES coupons (id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories (id) ON DELETE CASCADE,
    created_at TIMESTAMP
    WITH
        TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (coupon_id, category_id)
);

-- Indexes for efficient queries
CREATE INDEX idx_coupon_categories_coupon_id ON coupon_categories (coupon_id);

CREATE INDEX idx_coupon_categories_category_id ON coupon_categories (category_id);

-- Documentation
COMMENT ON TABLE coupon_categories IS 'Junction table linking coupons to specific categories they apply to. If coupon.applicable_to_all_products is false, check this table for category-specific coupons.';

-- Junction table for coupon-gift many-to-many relationship
-- This replaces the applicable_gift_ids UUID[] array field
CREATE TABLE coupon_gifts (
    coupon_id UUID NOT NULL REFERENCES coupons (id) ON DELETE CASCADE,
    gift_id UUID NOT NULL REFERENCES gifts (id) ON DELETE CASCADE,
    created_at TIMESTAMP
    WITH
        TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (coupon_id, gift_id)
);

-- Indexes for efficient queries
CREATE INDEX idx_coupon_gifts_coupon_id ON coupon_gifts (coupon_id);

CREATE INDEX idx_coupon_gifts_gift_id ON coupon_gifts (gift_id);

-- Documentation
COMMENT ON TABLE coupon_gifts IS 'Junction table linking coupons to specific gifts/products they apply to. If coupon.applicable_to_all_products is false, check this table for product-specific coupons.';