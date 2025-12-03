-- migrations/000018_create_coupons_table.up.sql

CREATE TYPE coupon_type AS ENUM ('percentage', 'fixed_amount', 'free_shipping');
CREATE TYPE coupon_status AS ENUM ('active', 'inactive', 'expired');

CREATE TABLE coupons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    type coupon_type NOT NULL,
    discount_value DECIMAL(10, 2) NOT NULL CHECK (discount_value >= 0),
    
    -- Constraints
    min_purchase_amount DECIMAL(10, 2),
    max_discount_amount DECIMAL(10, 2),
    usage_limit INTEGER, -- Total times it can be used
    usage_limit_per_user INTEGER DEFAULT 1,
    used_count INTEGER DEFAULT 0,
    
    -- Validity
    valid_from TIMESTAMP WITH TIME ZONE,
    valid_until TIMESTAMP WITH TIME ZONE,
    status coupon_status DEFAULT 'active',
    
    -- Applicable to
    applicable_to_all_products BOOLEAN DEFAULT true,
    applicable_category_ids UUID[], -- Array of category IDs
    applicable_gift_ids UUID[], -- Array of gift IDs
    
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_coupons_code ON coupons(code);
CREATE INDEX idx_coupons_status ON coupons(status);
CREATE INDEX idx_coupons_valid_from ON coupons(valid_from);
CREATE INDEX idx_coupons_valid_until ON coupons(valid_until);

CREATE TRIGGER update_coupons_updated_at BEFORE UPDATE ON coupons
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();