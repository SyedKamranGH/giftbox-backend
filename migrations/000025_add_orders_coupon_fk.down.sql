-- migrations/000025_add_orders_coupon_fk.down.sql
-- Remove foreign key constraint
ALTER TABLE orders
DROP CONSTRAINT IF EXISTS fk_orders_coupon_id;