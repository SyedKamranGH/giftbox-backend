-- migrations/000010_create_orders_table.up.sql
CREATE TYPE order_status AS ENUM (
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
    'refunded',
    'failed'
);

CREATE TYPE payment_status AS ENUM (
    'pending',
    'completed',
    'failed',
    'refunded',
    'partially_refunded'
);

CREATE TYPE payment_method AS ENUM (
    'credit_card',
    'debit_card',
    'paypal',
    'stripe',
    'cash_on_delivery',
    'bank_transfer'
);

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id UUID NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    -- Order totals
    subtotal DECIMAL(10, 2) NOT NULL CHECK (subtotal >= 0),
    tax_amount DECIMAL(10, 2) DEFAULT 0.00 CHECK (tax_amount >= 0),
    shipping_fee DECIMAL(10, 2) DEFAULT 0.00 CHECK (shipping_fee >= 0),
    discount_amount DECIMAL(10, 2) DEFAULT 0.00 CHECK (discount_amount >= 0),
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    -- Status
    order_status order_status DEFAULT 'pending',
    payment_status payment_status DEFAULT 'pending',
    payment_method payment_method,
    -- Coupon applied (optional)
    coupon_id UUID REFERENCES coupons (id) ON DELETE SET NULL,
    -- Shipping information
    shipping_address_id UUID REFERENCES user_addresses (id),
    shipping_full_name VARCHAR(255),
    shipping_phone VARCHAR(20),
    shipping_street_address_1 VARCHAR(500),
    shipping_street_address_2 VARCHAR(500),
    shipping_city VARCHAR(100),
    shipping_state VARCHAR(100),
    shipping_zip_code VARCHAR(20),
    shipping_country VARCHAR(100),
    -- Billing information
    billing_address_id UUID REFERENCES user_addresses (id),
    billing_full_name VARCHAR(255),
    billing_street_address_1 VARCHAR(500),
    billing_street_address_2 VARCHAR(500),
    billing_city VARCHAR(100),
    billing_state VARCHAR(100),
    billing_zip_code VARCHAR(20),
    billing_country VARCHAR(100),
    -- Tracking
    tracking_number VARCHAR(100),
    carrier_name VARCHAR(100),
    -- Notes
    customer_notes TEXT,
    admin_notes TEXT,
    -- Payment details
    transaction_id VARCHAR(255),
    payment_gateway_response JSONB,
    -- Timestamps
    confirmed_at TIMESTAMP
    WITH
        TIME ZONE,
        shipped_at TIMESTAMP
    WITH
        TIME ZONE,
        delivered_at TIMESTAMP
    WITH
        TIME ZONE,
        cancelled_at TIMESTAMP
    WITH
        TIME ZONE,
        created_at TIMESTAMP
    WITH
        TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP
    WITH
        TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_orders_order_number ON orders (order_number);

CREATE INDEX idx_orders_customer_id ON orders (customer_id);

CREATE INDEX idx_orders_order_status ON orders (order_status);

CREATE INDEX idx_orders_payment_status ON orders (payment_status);

CREATE INDEX idx_orders_coupon_id ON orders (coupon_id);

CREATE INDEX idx_orders_created_at ON orders (created_at);

CREATE TRIGGER update_orders_updated_at BEFORE
UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column ();