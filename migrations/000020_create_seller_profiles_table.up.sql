-- migrations/000020_create_seller_profiles_table.up.sql

CREATE TABLE seller_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    business_name VARCHAR(255) NOT NULL,
    business_description TEXT,
    business_logo_url VARCHAR(500),
    business_banner_url VARCHAR(500),
    
    -- Contact
    business_email VARCHAR(255),
    business_phone VARCHAR(20),
    business_website VARCHAR(255),
    
    -- Address
    business_address TEXT,
    business_city VARCHAR(100),
    business_state VARCHAR(100),
    business_zip_code VARCHAR(20),
    business_country VARCHAR(100),
    
    -- Tax & Legal
    tax_id VARCHAR(50),
    business_license VARCHAR(50),
    
    -- Performance metrics
    total_sales INTEGER DEFAULT 0,
    total_revenue DECIMAL(12, 2) DEFAULT 0.00,
    average_rating DECIMAL(3, 2) DEFAULT 0.00,
    rating_count INTEGER DEFAULT 0,
    
    -- Status
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMP WITH TIME ZONE,
    
    -- Social media
    social_facebook VARCHAR(255),
    social_instagram VARCHAR(255),
    social_twitter VARCHAR(255),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_seller_profiles_user_id ON seller_profiles(user_id);
CREATE INDEX idx_seller_profiles_is_verified ON seller_profiles(is_verified);
CREATE INDEX idx_seller_profiles_average_rating ON seller_profiles(average_rating);

CREATE TRIGGER update_seller_profiles_updated_at BEFORE UPDATE ON seller_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();