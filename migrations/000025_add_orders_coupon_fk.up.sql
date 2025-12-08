-- migrations/000025_add_orders_coupon_fk.up.sql
-- Add foreign key constraint for coupon_id now that coupons table exists
ALTER TABLE orders ADD CONSTRAINT fk_orders_coupon_id FOREIGN KEY (coupon_id) REFERENCES coupons (id) ON DELETE SET NULL;