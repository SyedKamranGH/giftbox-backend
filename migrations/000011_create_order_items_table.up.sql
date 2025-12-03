-- migrations/000011_create_order_items_table.up.sql

CREATE TYPE order_item_status AS ENUM (
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
    'refunded'
);

CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    gift_id UUID NOT NULL REFERENCES gifts(id) ON DELETE RESTRICT,
    seller_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    
    -- Product snapshot at time of order
    gift_title VARCHAR(255) NOT NULL,
    gift_sku VARCHAR(100),
    gift_image_url VARCHAR(500),
    
    -- Pricing
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    subtotal DECIMAL(10, 2) NOT NULL CHECK (subtotal >= 0),
    tax_amount DECIMAL(10, 2) DEFAULT 0.00 CHECK (tax_amount >= 0),
    discount_amount DECIMAL(10, 2) DEFAULT 0.00 CHECK (discount_amount >= 0),
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    
    -- Status
    status order_item_status DEFAULT 'pending',
    
    -- Commission for marketplace (optional)
    commission_rate DECIMAL(5, 2) DEFAULT 0.00,
    commission_amount DECIMAL(10, 2) DEFAULT 0.00,
    seller_payout_amount DECIMAL(10, 2),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_gift_id ON order_items(gift_id);
CREATE INDEX idx_order_items_seller_id ON order_items(seller_id);
CREATE INDEX idx_order_items_status ON order_items(status);

CREATE TRIGGER update_order_items_updated_at BEFORE UPDATE ON order_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();