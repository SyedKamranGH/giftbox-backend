-- migrations/000017_create_notifications_table.up.sql

CREATE TYPE notification_type AS ENUM (
    'order_confirmed',
    'order_shipped',
    'order_delivered',
    'order_cancelled',
    'review_submitted',
    'gift_low_stock',
    'gift_out_of_stock',
    'new_sale',
    'price_drop',
    'back_in_stock',
    'system_announcement'
);

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type notification_type NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    link_url VARCHAR(500),
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);
CREATE INDEX idx_notifications_type ON notifications(type);