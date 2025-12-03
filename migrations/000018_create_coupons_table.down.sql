-- migrations/000018_create_coupons_table.down.sql
DROP TABLE IF EXISTS coupons;

DROP TYPE IF EXISTS coupon_status;

DROP TYPE IF EXISTS coupon_type;