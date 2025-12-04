-- migrations/000024_create_coupon_junction_tables.down.sql
-- Drop junction tables in reverse order
DROP TABLE IF EXISTS coupon_gifts;

DROP TABLE IF EXISTS coupon_categories;