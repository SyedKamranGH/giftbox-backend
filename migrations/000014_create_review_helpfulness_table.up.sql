-- migrations/000014_create_review_helpfulness_table.up.sql

CREATE TYPE helpfulness_type AS ENUM ('helpful', 'unhelpful');

CREATE TABLE review_helpfulness (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    helpfulness_type helpfulness_type NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- One vote per user per review
    UNIQUE(review_id, user_id)
);

CREATE INDEX idx_review_helpfulness_review_id ON review_helpfulness(review_id);
CREATE INDEX idx_review_helpfulness_user_id ON review_helpfulness(user_id);