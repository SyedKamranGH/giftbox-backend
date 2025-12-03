-- migrations/000017_create_notifications_table.down.sql
DROP TABLE IF EXISTS notifications;

DROP TYPE IF EXISTS notification_type;