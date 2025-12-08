-- migrations/000019_create_coupon_usage_table.up.sql
CREATE TABLE coupon_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    coupon_id UUID NOT NULL REFERENCES coupons (id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    order_id UUID NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
    discount_amount DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP
    WITH
        TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_coupon_usage_coupon_id ON coupon_usage (coupon_id);

CREATE INDEX idx_coupon_usage_user_id ON coupon_usage (user_id);

CREATE INDEX idx_coupon_usage_order_id ON coupon_usage (order_id);

CREATE INDEX idx_coupon_usage_coupon_user ON coupon_usage (coupon_id, user_id);