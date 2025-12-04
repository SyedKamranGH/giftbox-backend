# Database Schema Analysis & Issues Report

**Generated:** December 4, 2025  
**Database:** PostgreSQL  
**Total Tables:** 23

---

## 🚨 CRITICAL ISSUES FOUND

### ❌ Issue #1: DUPLICATE TAG STORAGE (HIGH PRIORITY)

**Location:** `gifts` table (Migration 000004)

**Problem:**

```sql
-- In gifts table (line 38):
tags TEXT[],  -- Array field storing tags

-- But we also have (Migration 000007):
CREATE TABLE tags (...);
CREATE TABLE gift_tags (...);  -- Junction table for many-to-many relationship
```

**Impact:**

- **Data Redundancy:** Tags are stored in TWO places
- **Data Inconsistency:** Updates to `gift_tags` won't sync with `gifts.tags` array
- **Normalization Violation:** Breaks 3NF (Third Normal Form)
- **Query Confusion:** Developers won't know which source is authoritative
- **Storage Waste:** Duplicate data increases database size
- **Maintenance Nightmare:** Must update both locations

**Recommendation:** 🔧 **REMOVE `tags TEXT[]` from gifts table**

```sql
-- Remove this line from 000004_create_gifts_table.up.sql:
tags TEXT[],  -- DELETE THIS

-- Keep only the normalized approach:
-- tags table + gift_tags junction table
```

---

### ⚠️ Issue #2: DENORMALIZED COUNTERS (MEDIUM PRIORITY)

**Location:** Multiple tables

**Problem:** Several aggregate counters are stored directly in tables:


#### A. `gifts` table

```sql
view_count INTEGER DEFAULT 0,        -- Duplicates product_views table
sales_count INTEGER DEFAULT 0,       -- Duplicates order_items table
average_rating DECIMAL(3, 2),        -- Duplicates reviews table
review_count INTEGER DEFAULT 0,      -- Duplicates reviews table
```

#### B. `reviews` table

```sql
helpful_count INTEGER DEFAULT 0,     -- Duplicates review_helpfulness table
unhelpful_count INTEGER DEFAULT 0,   -- Duplicates review_helpfulness table
```

#### C. `coupons` table

```sql
used_count INTEGER DEFAULT 0,        -- Duplicates coupon_usage table
```

#### D. `seller_profiles` table

```sql
total_sales INTEGER DEFAULT 0,       -- Duplicates order_items table
total_revenue DECIMAL(12, 2),        -- Duplicates order_items table
average_rating DECIMAL(3, 2),        -- Would need seller_reviews table
rating_count INTEGER DEFAULT 0,      -- Would need seller_reviews table
```

**Impact:**

- **Data Inconsistency Risk:** Counters can drift from actual data
- **Update Complexity:** Requires triggers or application logic to maintain
- **Race Conditions:** Concurrent updates may cause incorrect counts
- **Debugging Difficulty:** Hard to identify when counts become incorrect

**Analysis:**
This is **intentional denormalization** for performance optimization. While it violates normalization, it's a common pattern for:

- Avoiding expensive COUNT() queries on large tables
- Improving read performance for frequently accessed metrics
- Reducing JOIN complexity

**Recommendation:** ✅ **KEEP BUT ADD SAFEGUARDS**

**Required Actions:**

1. **Add database triggers** to auto-update counters
2. **Add reconciliation jobs** to periodically verify and fix counts
3. **Document** that these are cached values
4. **Add indexes** on the source tables for efficient counting

**Example Trigger for `gifts.view_count`:**

```sql
CREATE OR REPLACE FUNCTION update_gift_view_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE gifts 
    SET view_count = view_count + 1 
    WHERE id = NEW.gift_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER increment_gift_view_count
    AFTER INSERT ON product_views
    FOR EACH ROW
    EXECUTE FUNCTION update_gift_view_count();
```

---

### ⚠️ Issue #3: REDUNDANT ADDRESS STORAGE (MEDIUM PRIORITY)

**Location:** `orders` table (Migration 000010)

**Problem:**

```sql
-- Orders table has BOTH:
shipping_address_id UUID REFERENCES user_addresses(id),  -- FK reference
-- AND denormalized fields:
shipping_full_name VARCHAR(255),
shipping_phone VARCHAR(20),
shipping_street_address_1 VARCHAR(500),
shipping_street_address_2 VARCHAR(500),
shipping_city VARCHAR(100),
shipping_state VARCHAR(100),
shipping_zip_code VARCHAR(20),
shipping_country VARCHAR(100),

-- Same for billing address (8 more fields)
```

**Impact:**

- **Storage Overhead:** ~16 extra fields per order
- **Confusion:** Which is the source of truth?
- **Update Complexity:** Must copy data from user_addresses to orders

**Analysis:**
This is **intentional snapshot pattern** - CORRECT for orders because:

- ✅ Preserves address at time of order (user may change/delete address later)
- ✅ Historical accuracy for shipping labels and invoices
- ✅ Prevents broken orders if user deletes address

**Recommendation:** ✅ **KEEP AS IS**

**Improvement:**
Make `shipping_address_id` and `billing_address_id` **NULLABLE** and add comment:

```sql
-- Reference to original address (may be NULL if address deleted)
shipping_address_id UUID REFERENCES user_addresses(id) ON DELETE SET NULL,
```

---

### ⚠️ Issue #4: MISSING FOREIGN KEY VALIDATION

**Location:** `coupons` table (Migration 000018)

**Problem:**

```sql
applicable_category_ids UUID[],  -- No FK constraint!
applicable_gift_ids UUID[],      -- No FK constraint!
```

**Impact:**

- **Referential Integrity:** Can reference non-existent categories/gifts
- **Orphaned References:** If category/gift is deleted, coupon still references it
- **No CASCADE:** Can't auto-update when referenced items change

**Recommendation:** 🔧 **CREATE JUNCTION TABLES**

```sql
-- Replace arrays with proper junction tables:
CREATE TABLE coupon_categories (
    coupon_id UUID NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    PRIMARY KEY (coupon_id, category_id)
);

CREATE TABLE coupon_gifts (
    coupon_id UUID NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
    gift_id UUID NOT NULL REFERENCES gifts(id) ON DELETE CASCADE,
    PRIMARY KEY (coupon_id, gift_id)
);

-- Remove from coupons table:
-- applicable_category_ids UUID[],
-- applicable_gift_ids UUID[],
```

---

### ⚠️ Issue #5: POTENTIAL PERFORMANCE ISSUES

#### A. Missing Composite Indexes

**Problem:** Some common query patterns lack composite indexes:

```sql
-- Common query: Get active gifts in a category, sorted by price
-- Missing index on: (category_id, status, price)

-- Common query: Get user's unread notifications
-- Missing index on: (user_id, is_read, created_at)

-- Common query: Get seller's pending orders
-- Missing index on: (seller_id, status, created_at) in order_items
```

**Recommendation:** 🔧 **ADD COMPOSITE INDEXES**

#### B. Over-Indexing on Small Tables

**Problem:** Some small tables have excessive indexes:

```sql
-- gift_images table (likely < 10k rows)
CREATE INDEX idx_gift_images_sort_order ON gift_images(sort_order);  -- Probably unnecessary
```

**Recommendation:** ⚠️ **MONITOR AND REMOVE** if not used

---

### ⚠️ Issue #6: INCONSISTENT SOFT DELETE IMPLEMENTATION

**Problem:** Soft deletes (`deleted_at`) are inconsistent:

**Has soft delete:**

- ✅ users
- ✅ categories  
- ✅ gifts

**Missing soft delete:**

- ❌ user_addresses (should have it - users may want to restore)
- ❌ orders (should have it - important for audit trail)
- ❌ wishlists (should have it - accidental deletion recovery)
- ❌ seller_profiles (should have it - reactivation scenarios)

**Recommendation:** 🔧 **ADD SOFT DELETE WHERE NEEDED**

---

### ⚠️ Issue #7: MISSING COUPON VALIDATION

**Location:** `orders` table

**Problem:** No reference to which coupon was used (if any)

```sql
-- orders table has:
discount_amount DECIMAL(10, 2),  -- But no coupon_id!

-- coupon_usage table exists but isn't linked from orders
```

**Impact:**

- Can't easily see which coupon was applied to an order
- Must JOIN through coupon_usage to find coupon

**Recommendation:** 🔧 **ADD OPTIONAL COUPON REFERENCE**

```sql
-- Add to orders table:
coupon_id UUID REFERENCES coupons(id) ON DELETE SET NULL,
```

---

## 📊 DATABASE RELATIONSHIP DIAGRAM

### Core Entity Relationships

```
┌─────────────────────────────────────────────────────────────────────┐
│                          USERS (Central Hub)                         │
│  - id (PK)                                                           │
│  - email, password_hash, full_name                                   │
│  - role: customer | seller | admin                                   │
└────┬────────┬──────────┬──────────┬──────────┬──────────┬───────────┘
     │        │          │          │          │          │
     │        │          │          │          │          │
     ▼        ▼          ▼          ▼          ▼          ▼
┌─────────┐ ┌────────┐ ┌──────┐ ┌────────┐ ┌─────────┐ ┌──────────────┐
│ USER    │ │ CARTS  │ │ORDERS│ │REVIEWS │ │WISHLISTS│ │SELLER_PROFILES│
│ADDRESSES│ │        │ │      │ │        │ │         │ │              │
└─────────┘ └───┬────┘ └──┬───┘ └───┬────┘ └────┬────┘ └──────┬───────┘
                │         │         │           │              │
                │         │         │           │              │
                ▼         ▼         ▼           ▼              ▼
           ┌─────────┐ ┌──────────┐ ┌──────────────┐ ┌──────────────┐
           │  CART   │ │  ORDER   │ │   REVIEW     │ │  WISHLIST    │
           │  ITEMS  │ │  ITEMS   │ │   IMAGES     │ │   ITEMS      │
           └────┬────┘ └────┬─────┘ └──────────────┘ └──────┬───────┘
                │           │                               │
                │           │                               │
                └───────────┴───────────────────────────────┘
                                    │
                                    ▼
        ┌───────────────────────────────────────────────────┐
        │                    GIFTS (Products)                │
        │  - id (PK)                                         │
        │  - seller_id (FK → users)                          │
        │  - category_id (FK → categories)                   │
        │  - title, price, stock_quantity                    │
        │  - tags TEXT[] ⚠️ ISSUE: Duplicates gift_tags     │
        └───┬───────┬──────────┬──────────┬─────────────────┘
            │       │          │          │
            ▼       ▼          ▼          ▼
     ┌──────────┐ ┌────────┐ ┌────────┐ ┌─────────────┐
     │  GIFT    │ │  GIFT  │ │  TAGS  │ │  PRODUCT    │
     │  IMAGES  │ │  SPECS │ │   +    │ │   VIEWS     │
     │          │ │        │ │GIFT_   │ │             │
     │          │ │        │ │TAGS    │ │             │
     └──────────┘ └────────┘ └────────┘ └─────────────┘
                              ⚠️ ISSUE

┌────────────────────────────────────────────────────────────┐
│                    CATEGORIES (Hierarchy)                   │
│  - id (PK)                                                  │
│  - parent_category_id (FK → categories) [Self-referencing]  │
│  - depth (0-5 levels)                                       │
└─────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│                    COUPONS & USAGE                          │
│  coupons                                                    │
│  - applicable_category_ids UUID[] ⚠️ No FK constraint      │
│  - applicable_gift_ids UUID[] ⚠️ No FK constraint          │
│       │                                                     │
│       └──→ coupon_usage (tracks redemptions)               │
└─────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│              SUPPORTING TABLES                              │
│  - notifications (user alerts)                              │
│  - refresh_tokens (JWT auth)                                │
│  - audit_logs (activity tracking)                           │
│  - review_helpfulness (review voting)                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔗 DETAILED RELATIONSHIP MAP

### 1. USER-CENTRIC RELATIONSHIPS

| From Table | To Table | Relationship | Cascade | Notes |
|------------|----------|--------------|---------|-------|
| users | user_addresses | 1:N | CASCADE | User can have multiple addresses |
| users | carts | 1:1 | CASCADE | One cart per user (UNIQUE constraint) |
| users | orders | 1:N | RESTRICT | User's order history |
| users | reviews | 1:N | CASCADE | User's product reviews |
| users | wishlists | 1:N | CASCADE | User can have multiple wishlists |
| users | seller_profiles | 1:1 | CASCADE | Sellers have extended profile |
| users | gifts | 1:N | CASCADE | Seller's products (seller_id FK) |
| users | notifications | 1:N | CASCADE | User's notifications |
| users | refresh_tokens | 1:N | CASCADE | User's active sessions |
| users | product_views | 1:N | SET NULL | Anonymous views allowed |
| users | audit_logs | 1:N | SET NULL | Activity tracking |

### 2. PRODUCT (GIFTS) RELATIONSHIPS

| From Table | To Table | Relationship | Cascade | Notes |
|------------|----------|--------------|---------|-------|
| gifts | categories | N:1 | RESTRICT | Product categorization |
| gifts | users (seller) | N:1 | CASCADE | Product owner |
| gifts | gift_images | 1:N | CASCADE | Product gallery |
| gifts | gift_specifications | 1:N | CASCADE | Product specs (key-value) |
| gifts | gift_tags | N:M | CASCADE | Via junction table |
| gifts | cart_items | 1:N | CASCADE | In shopping carts |
| gifts | order_items | 1:N | RESTRICT | In orders (preserve history) |
| gifts | reviews | 1:N | CASCADE | Product reviews |
| gifts | wishlist_items | 1:N | CASCADE | In wishlists |
| gifts | product_views | 1:N | CASCADE | View analytics |

### 3. ORDER FLOW RELATIONSHIPS

| From Table | To Table | Relationship | Cascade | Notes |
|------------|----------|--------------|---------|-------|
| carts | cart_items | 1:N | CASCADE | Cart contents |
| cart_items | gifts | N:1 | CASCADE | Product reference |
| orders | order_items | 1:N | CASCADE | Order line items |
| order_items | gifts | N:1 | RESTRICT | Product snapshot |
| order_items | users (seller) | N:1 | RESTRICT | Seller reference |
| orders | user_addresses | N:1 | - | Address snapshot (denormalized) |
| orders | coupon_usage | 1:N | CASCADE | Coupon redemption |

### 4. REVIEW SYSTEM RELATIONSHIPS

| From Table | To Table | Relationship | Cascade | Notes |
|------------|----------|--------------|---------|-------|
| reviews | gifts | N:1 | CASCADE | Product being reviewed |
| reviews | users | N:1 | CASCADE | Reviewer |
| reviews | order_items | N:1 | SET NULL | Verified purchase link |
| reviews | review_images | 1:N | CASCADE | Review photos |
| reviews | review_helpfulness | 1:N | CASCADE | Voting system |
| review_helpfulness | users | N:1 | CASCADE | Voter |

### 5. COUPON SYSTEM RELATIONSHIPS

| From Table | To Table | Relationship | Cascade | Notes |
|------------|----------|--------------|---------|-------|
| coupons | coupon_usage | 1:N | CASCADE | Redemption tracking |
| coupon_usage | users | N:1 | CASCADE | Who used it |
| coupon_usage | orders | N:1 | CASCADE | Which order |
| coupons | categories | ❌ NONE | - | ⚠️ Array field, no FK |
| coupons | gifts | ❌ NONE | - | ⚠️ Array field, no FK |

### 6. WISHLIST RELATIONSHIPS

| From Table | To Table | Relationship | Cascade | Notes |
|------------|----------|--------------|---------|-------|
| wishlists | users | N:1 | CASCADE | Wishlist owner |
| wishlists | wishlist_items | 1:N | CASCADE | Wishlist contents |
| wishlist_items | gifts | N:1 | CASCADE | Saved products |

### 7. CATEGORY HIERARCHY

| From Table | To Table | Relationship | Cascade | Notes |
|------------|----------|--------------|---------|-------|
| categories | categories | N:1 | SET NULL | Self-referencing (parent) |
| categories | gifts | 1:N | RESTRICT | Products in category |

---

## 📏 NORMALIZATION ANALYSIS

### Third Normal Form (3NF) Violations

| Table | Violation | Severity | Action |
|-------|-----------|----------|--------|
| **gifts** | `tags TEXT[]` duplicates `gift_tags` table | 🔴 HIGH | **REMOVE** array field |
| **gifts** | Denormalized counters (view_count, sales_count, etc.) | 🟡 MEDIUM | **KEEP** (performance) + add triggers |
| **reviews** | Denormalized counters (helpful_count, unhelpful_count) | 🟡 MEDIUM | **KEEP** (performance) + add triggers |
| **coupons** | `used_count` duplicates `coupon_usage` | 🟡 MEDIUM | **KEEP** (performance) + add triggers |
| **coupons** | Array fields without FK constraints | 🟠 MEDIUM-HIGH | **REPLACE** with junction tables |
| **orders** | Denormalized address fields | 🟢 LOW | **KEEP** (snapshot pattern) |
| **seller_profiles** | Denormalized metrics | 🟡 MEDIUM | **KEEP** (performance) + add triggers |

### Normalization Score: 7.5/10

**Strengths:**

- ✅ Proper junction tables (gift_tags, cart_items, order_items, etc.)
- ✅ No repeating groups (except intentional arrays)
- ✅ Atomic values in most columns
- ✅ Proper foreign key constraints (mostly)

**Weaknesses:**

- ❌ Duplicate tag storage (critical issue)
- ❌ Array fields without FK validation
- ⚠️ Extensive denormalization (acceptable for performance)

---

## 🎯 PRIORITY FIXES

### 🔴 CRITICAL (Fix Immediately)

1. **Remove `tags TEXT[]` from gifts table**
   - Migration: 000004
   - Keep only `gift_tags` junction table
   - Estimated time: 15 minutes

### 🟠 HIGH (Fix Soon)

2. **Replace coupon array fields with junction tables**
   - Migration: 000018
   - Create `coupon_categories` and `coupon_gifts` tables
   - Estimated time: 30 minutes

3. **Add missing composite indexes**
   - For common query patterns
   - Estimated time: 20 minutes

### 🟡 MEDIUM (Plan for Next Sprint)

4. **Add database triggers for denormalized counters**
   - Gifts: view_count, sales_count, review_count, average_rating
   - Reviews: helpful_count, unhelpful_count
   - Coupons: used_count
   - Seller_profiles: metrics
   - Estimated time: 2-3 hours

5. **Add soft delete to missing tables**
   - user_addresses, orders, wishlists, seller_profiles
   - Estimated time: 1 hour

6. **Add coupon_id to orders table**
   - For easier coupon tracking
   - Estimated time: 15 minutes

### 🟢 LOW (Nice to Have)

7. **Review and optimize indexes**
   - Remove unused indexes
   - Add missing indexes based on query patterns
   - Estimated time: 1 hour

8. **Add reconciliation jobs**
   - Periodic jobs to verify denormalized counters
   - Estimated time: 2-3 hours

---

## 📈 DATABASE SIZE ESTIMATION

### Storage Projections (1 Year, 10K Users, 100K Products)

| Table | Est. Rows | Avg Row Size | Total Size | Notes |
|-------|-----------|--------------|------------|-------|
| users | 10,000 | 500 B | 5 MB | Small |
| user_addresses | 30,000 | 300 B | 9 MB | 3 addresses/user avg |
| categories | 500 | 400 B | 200 KB | Small, hierarchical |
| gifts | 100,000 | 800 B | 80 MB | Core table |
| gift_images | 400,000 | 200 B | 80 MB | 4 images/product avg |
| gift_specifications | 500,000 | 150 B | 75 MB | 5 specs/product avg |
| tags | 1,000 | 100 B | 100 KB | Small |
| gift_tags | 500,000 | 50 B | 25 MB | 5 tags/product avg |
| carts | 10,000 | 150 B | 1.5 MB | One per user |
| cart_items | 50,000 | 150 B | 7.5 MB | 5 items/cart avg |
| orders | 50,000 | 1 KB | 50 MB | 5 orders/user avg |
| order_items | 150,000 | 400 B | 60 MB | 3 items/order avg |
| reviews | 200,000 | 500 B | 100 MB | 2 reviews/product avg |
| review_images | 400,000 | 150 B | 60 MB | 2 images/review avg |
| review_helpfulness | 1,000,000 | 100 B | 100 MB | 5 votes/review avg |
| wishlists | 20,000 | 200 B | 4 MB | 2 wishlists/user avg |
| wishlist_items | 200,000 | 100 B | 20 MB | 10 items/wishlist avg |
| notifications | 500,000 | 300 B | 150 MB | 50 notifications/user |
| coupons | 1,000 | 400 B | 400 KB | Small |
| coupon_usage | 25,000 | 150 B | 3.75 MB | 50% orders use coupons |
| seller_profiles | 1,000 | 600 B | 600 KB | 10% users are sellers |
| audit_logs | 2,000,000 | 400 B | 800 MB | High volume |
| refresh_tokens | 20,000 | 300 B | 6 MB | 2 sessions/user avg |
| product_views | 5,000,000 | 200 B | 1 GB | High volume analytics |

**Total Estimated Size: ~2.7 GB** (data only, excluding indexes)
**With Indexes: ~4-5 GB**

### Growth Rate Projections

- **Year 1:** 2.7 GB
- **Year 2:** 6-8 GB (with 2x growth)
- **Year 3:** 12-15 GB (with continued growth)

**Recommendation:** Current schema is efficient. No immediate concerns for database size.

---

## ✅ WHAT'S DONE WELL

1. **✅ Comprehensive Foreign Keys:** Most relationships properly constrained
2. **✅ Proper Cascade Rules:** Thoughtful ON DELETE behavior
3. **✅ UUID Primary Keys:** Good for distributed systems
4. **✅ Timestamp Tracking:** created_at, updated_at on most tables
5. **✅ Soft Deletes:** Implemented on critical tables
6. **✅ Indexes:** Good coverage of common query patterns
7. **✅ ENUM Types:** Type safety for status fields
8. **✅ Check Constraints:** Data validation at DB level
9. **✅ Unique Constraints:** Prevent duplicate data
10. **✅ Triggers:** Auto-update timestamps, calculate depth
11. **✅ Junction Tables:** Proper many-to-many relationships
12. **✅ Snapshot Pattern:** Orders preserve address history
13. **✅ JSONB Fields:** Flexible metadata storage
14. **✅ Audit Trail:** Comprehensive logging

---

## 📝 SUMMARY

### Overall Assessment: **8/10** ⭐⭐⭐⭐⭐⭐⭐⭐

**Strengths:**

- Well-designed schema with proper normalization
- Comprehensive feature coverage
- Good use of PostgreSQL features
- Thoughtful cascade rules and constraints

**Critical Issues:**

- 1 critical redundancy (tags array vs gift_tags table)
- 1 high-priority issue (coupon array fields)

**Recommendations:**

1. Fix the tags duplication immediately
2. Replace coupon arrays with junction tables
3. Add triggers for denormalized counters
4. Add soft deletes to remaining tables
5. Monitor and optimize indexes based on actual query patterns

**Estimated Fix Time:** 4-6 hours for all priority fixes

---

**Next Steps:**

1. Review this analysis with the team
2. Create migration files for fixes
3. Test migrations on development database
4. Deploy fixes to production
