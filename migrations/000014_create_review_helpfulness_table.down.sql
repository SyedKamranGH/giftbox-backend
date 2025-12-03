-- migrations/000014_create_review_helpfulness_table.down.sql
DROP TABLE IF EXISTS review_helpfulness;

DROP TYPE IF EXISTS helpfulness_type;