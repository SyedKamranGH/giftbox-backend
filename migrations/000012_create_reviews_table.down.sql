-- migrations/000012_create_reviews_table.down.sql
DROP TABLE IF EXISTS reviews;

DROP TYPE IF EXISTS review_status;