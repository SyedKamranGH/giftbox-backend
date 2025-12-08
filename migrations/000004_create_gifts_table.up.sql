-- migrations/000004_create_gifts_table.up.sql

CREATE TYPE gift_status AS ENUM ('active', 'inactive', 'out_of_stock', 'discontinued');
CREATE TYPE gift_condition AS ENUM ('new', 'refurbished', 'used');

CREATE TABLE gifts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    short_description VARCHAR(500),
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    compare_at_price DECIMAL(10, 2) CHECK (compare_at_price >= 0),
    cost_per_item DECIMAL(10, 2) CHECK (cost_per_item >= 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    low_stock_threshold INTEGER DEFAULT 10,
    sku VARCHAR(100) UNIQUE,
    barcode VARCHAR(100),
    weight DECIMAL(8, 2), -- in kg
    dimensions_length DECIMAL(8, 2), -- in cm
    dimensions_width DECIMAL(8, 2), -- in cm
    dimensions_height DECIMAL(8, 2), -- in cm
    status gift_status DEFAULT 'active',
    condition gift_condition DEFAULT 'new',
    is_featured BOOLEAN DEFAULT false,
    requires_shipping BOOLEAN DEFAULT true,
    taxable BOOLEAN DEFAULT true,
    view_count INTEGER DEFAULT 0,
    sales_count INTEGER DEFAULT 0,
    average_rating DECIMAL(3, 2) DEFAULT 0.00 CHECK (average_rating >= 0 AND average_rating <= 5),
    review_count INTEGER DEFAULT 0,
    meta_title VARCHAR(255),
    meta_description TEXT,
    meta_keywords TEXT,
    published_at TIMESTAMP WITH TIME ZONE,
    brand VARCHAR(100),
    warranty_info TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_gifts_seller_id ON gifts(seller_id);
CREATE INDEX idx_gifts_category_id ON gifts(category_id);
CREATE INDEX idx_gifts_slug ON gifts(slug);
CREATE INDEX idx_gifts_status ON gifts(status);
CREATE INDEX idx_gifts_price ON gifts(price);
CREATE INDEX idx_gifts_is_featured ON gifts(is_featured);
CREATE INDEX idx_gifts_average_rating ON gifts(average_rating);
CREATE INDEX idx_gifts_created_at ON gifts(created_at);
CREATE INDEX idx_gifts_deleted_at ON gifts(deleted_at);
CREATE INDEX idx_gifts_published_at ON gifts(published_at);
CREATE INDEX idx_gifts_brand ON gifts(brand);

-- Function to auto-update gift status based on stock quantity
CREATE OR REPLACE FUNCTION update_gift_stock_status()
RETURNS TRIGGER AS $$
BEGIN
    -- If stock goes from positive to zero, mark as out of stock
    IF NEW.stock_quantity = 0 AND OLD.stock_quantity > 0 THEN
        NEW.status := 'out_of_stock';
    -- If stock is replenished and status was out_of_stock, mark as active
    ELSIF NEW.stock_quantity > 0 AND OLD.status = 'out_of_stock' THEN
        NEW.status := 'active';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically manage stock status
CREATE TRIGGER manage_gift_stock_status
    BEFORE UPDATE OF stock_quantity ON gifts
    FOR EACH ROW
    EXECUTE FUNCTION update_gift_stock_status();

-- Trigger for updated_at
CREATE TRIGGER update_gifts_updated_at 
    BEFORE UPDATE ON gifts
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();