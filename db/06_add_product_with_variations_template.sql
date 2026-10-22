-- ============================================================================
-- 06_add_product_with_variations_template.sql
-- Template for adding products with Variations and Sub-variations
-- Compatible with 4U CAMERA RENT (Sachindra Sanjaya Photography)
-- Works in Supabase SQL Editor and direct PostgreSQL psql connections
-- ============================================================================

DO $$
DECLARE
    v_user_id uuid;
    -- Change email if targeting a different admin user:
    v_target_email text := 'qwe@buildstart.io';
BEGIN
    -- 1. Identify User ID
    SELECT id INTO v_user_id FROM auth.users WHERE email = v_target_email;
    IF v_user_id IS NULL THEN
        SELECT id INTO v_user_id FROM auth.users ORDER BY created_at ASC LIMIT 1;
    END IF;

    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'No user found in auth.users.';
    END IF;

    RAISE NOTICE 'Managing products for user_id: %', v_user_id;

    -- ========================================================================
    -- TEMPLATE 1: INSERT A NEW PRODUCT WITH VARIATIONS & SUB-VARIATIONS
    -- ========================================================================
    -- JSON Structure Breakdown:
    -- variations = [
    --   {
    --     "name": "Variation Group Name (e.g., Package Option / Duration)",
    --     "options": [
    --       {
    --         "label": "Option Name (e.g., Body Only)",
    --         "price": 6000,
    --         "subVariants": [
    --           {
    --             "name": "Sub-variant Group (e.g., Memory Card)",
    --             "required": true,  -- Set true if customer MUST pick one
    --             "options": [
    --               {"label": "64GB V60 SD Card", "price": 500},
    --               {"label": "128GB V90 Tough Card", "price": 1000}
    --             ]
    --           },
    --           {
    --             "name": "Add-on Accessories",
    --             "required": false, -- Set false for optional add-ons
    --             "options": [
    --               {"label": "No add-on", "price": 0},
    --               {"label": "Extra Battery + Charger", "price": 800},
    --               {"label": "Heavy Duty Tripod", "price": 1200}
    --             ]
    --           }
    --         ]
    --       }
    --     ]
    --   }
    -- ]
    -- ========================================================================

    INSERT INTO "4Ucamera".products (
        user_id,
        name,
        description,
        price,
        product_type,
        delivery_price,
        is_active,
        images,
        variations
    ) VALUES (
        v_user_id,
        'Sony FX3 Cinema Rig Package',
        'Full Cinema Camera Rig with Cage, Audio Handle, and customizable accessories',
        10000.00,       -- Base daily rental price in LKR
        'physical',     -- 'physical' or 'digital'
        0,              -- Delivery fee (0 if covered or calculated separately)
        true,           -- Active status
        ARRAY[]::text[], -- Optional image URLs (e.g. ARRAY['https://...'])
        '[
          {
            "name": "Package Type",
            "options": [
              {
                "label": "Body + Top Audio Handle",
                "price": 10000,
                "subVariants": [
                  {
                    "name": "Media Card",
                    "required": true,
                    "options": [
                      {"label": "160GB CFexpress Type A", "price": 1500},
                      {"label": "128GB V90 SD Card", "price": 1000}
                    ]
                  },
                  {
                    "name": "Power Accessories",
                    "required": false,
                    "options": [
                      {"label": "1x Extra NP-FZ100 Battery", "price": 500},
                      {"label": "V-Mount Battery Kit (99Wh)", "price": 2000}
                    ]
                  }
                ]
              },
              {
                "label": "Full Production Rig (Cage + Monitor + Matte Box)",
                "price": 14000,
                "subVariants": [
                  {
                    "name": "Monitor Selection",
                    "required": true,
                    "options": [
                      {"label": "Atomos Ninja V 5 Inch HDR Monitor", "price": 2000},
                      {"label": "Portkeys BM5 III High Bright Monitor", "price": 2500}
                    ]
                  },
                  {
                    "name": "Follow Focus",
                    "required": false,
                    "options": [
                      {"label": "Tilta Nucleus-Nano II Wireless Follow Focus", "price": 1500}
                    ]
                  }
                ]
              }
            ]
          }
        ]'::jsonb
    )
    ON CONFLICT (id) DO NOTHING;

    -- ========================================================================
    -- TEMPLATE 2: UPDATE AN EXISTING PRODUCT WITH VARIATIONS & SUB-VARIATIONS
    -- Use this when the product already exists in your catalogue
    -- ========================================================================
    UPDATE "4Ucamera".products
    SET 
        variations = '[
          {
            "name": "Rental Package Option",
            "options": [
              {
                "label": "Body Only",
                "price": 6000,
                "subVariants": [
                  {
                    "name": "Memory Card Selection",
                    "required": true,
                    "options": [
                      {"label": "64GB SD Card", "price": 500},
                      {"label": "128GB SD Card", "price": 1000}
                    ]
                  },
                  {
                    "name": "Spare Battery Option",
                    "required": false,
                    "options": [
                      {"label": "1x Extra Battery", "price": 500},
                      {"label": "2x Extra Batteries + Dual Charger", "price": 900}
                    ]
                  }
                ]
              },
              {
                "label": "Combo with 24-70mm F2.8 Lens",
                "price": 9500,
                "subVariants": [
                  {
                    "name": "Lens Filter",
                    "required": false,
                    "options": [
                      {"label": "Variable ND Filter (82mm)", "price": 500},
                      {"label": "Black Mist 1/4 Filter", "price": 500}
                    ]
                  }
                ]
              }
            ]
          }
        ]'::jsonb,
        updated_at = now()
    WHERE user_id = v_user_id AND name = 'Sony A7 IV';

    RAISE NOTICE 'Product variations updated successfully!';

END $$;
