-- migrations/000003_create_categories_table.up.sql

CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url VARCHAR(500),
    parent_category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    depth INTEGER DEFAULT 0 NOT NULL CHECK (depth >= 0 AND depth <= 5),
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT no_self_reference CHECK (id != parent_category_id)
);

-- Indexes for common query patterns
CREATE INDEX idx_categories_slug ON categories(slug) WHERE deleted_at IS NULL;
CREATE INDEX idx_categories_parent_category_id ON categories(parent_category_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_categories_is_active ON categories(is_active) WHERE deleted_at IS NULL;
CREATE INDEX idx_categories_deleted_at ON categories(deleted_at);

-- Composite index for the most common query: active categories ordered by sort_order
CREATE INDEX idx_categories_active_sort ON categories(is_active, sort_order) 
    WHERE is_active = true AND deleted_at IS NULL;

-- Index for depth-based queries (e.g., get all top-level categories)
CREATE INDEX idx_categories_depth ON categories(depth) WHERE deleted_at IS NULL;

-- Function to calculate and set category depth
CREATE OR REPLACE FUNCTION calculate_category_depth()
RETURNS TRIGGER AS $$
DECLARE
    parent_depth INTEGER;
BEGIN
    -- If no parent, depth is 0 (top-level category)
    IF NEW.parent_category_id IS NULL THEN
        NEW.depth := 0;
    ELSE
        -- Get parent's depth
        SELECT depth INTO parent_depth
        FROM categories
        WHERE id = NEW.parent_category_id;
        
        -- Set depth to parent's depth + 1
        NEW.depth := parent_depth + 1;
        
        -- Enforce maximum depth of 5 levels (0-5 = 6 total levels)
        IF NEW.depth > 5 THEN
            RAISE EXCEPTION 'Category hierarchy cannot exceed 5 levels deep';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically calculate depth before insert or update
CREATE TRIGGER set_category_depth
    BEFORE INSERT OR UPDATE OF parent_category_id ON categories
    FOR EACH ROW
    EXECUTE FUNCTION calculate_category_depth();

-- Trigger for updated_at
CREATE TRIGGER update_categories_updated_at 
    BEFORE UPDATE ON categories
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();