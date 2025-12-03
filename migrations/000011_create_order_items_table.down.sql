-- migrations/000011_create_order_items_table.down.sql
DROP TABLE IF EXISTS order_items;

DROP TYPE IF EXISTS order_item_status;