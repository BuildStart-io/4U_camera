-- ============================================================================
-- 04_seed_products.sql — Seed rental products for 4U Camera
-- Compatible with PostgreSQL / Supabase on self-hosted or cloud instances.
-- Automatically supports "4Ucamera" schema or "public" schema.
-- ============================================================================

DO $$
DECLARE
    v_user_id uuid;
    -- Change this email if your admin account on the real server uses another email:
    v_target_email text := 'qwe@buildstart.io';
BEGIN
    -- 1. Retrieve the target user's UUID from auth.users
    SELECT id INTO v_user_id FROM auth.users WHERE email = v_target_email;
    
    -- Fallback: if email not found, use the first registered user
    IF v_user_id IS NULL THEN
        SELECT id INTO v_user_id FROM auth.users ORDER BY created_at ASC LIMIT 1;
    END IF;

    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'No user found in auth.users. Please register/create an admin user first.';
    END IF;

    RAISE NOTICE 'Seeding products for user_id: %', v_user_id;

    -- 2. Upgrade plan limits on profile so all 43 products are visible
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = '4Ucamera' AND table_name = 'profiles') THEN
        UPDATE "4Ucamera".profiles 
        SET max_products = 999, plan_tier = 'enterprise' 
        WHERE user_id = v_user_id;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'profiles') THEN
        UPDATE public.profiles 
        SET max_products = 999, plan_tier = 'enterprise' 
        WHERE user_id = v_user_id;
    END IF;

    -- Temporary table to hold standard product seed data
    CREATE TEMP TABLE tmp_seed_products (
        name text,
        description text,
        price numeric(10,2),
        product_type text,
        delivery_price numeric,
        is_active boolean
    ) ON COMMIT DROP;

    INSERT INTO tmp_seed_products (name, description, price, product_type, delivery_price, is_active) VALUES
    -- Camera Bodies - Sony
    ('Sony A7 III', 'Camera Body - Sony A7 III daily rental (discount available)', 4500.00, 'physical', 0, true),
    ('Sony A7 IV', 'Camera Body - Sony A7 IV daily rental (discount available)', 5000.00, 'physical', 0, true),
    ('Sony A7S III', 'Camera Body - Sony A7S III daily rental (discount available)', 9000.00, 'physical', 0, true),
    ('Sony FX3', 'Cinema Camera - Sony FX3 daily rental (discount available)', 12000.00, 'physical', 0, true),

    -- Camera Bodies - Canon
    ('Canon 6D', 'Camera Body - Canon 6D daily rental (discount available)', 3000.00, 'physical', 0, true),
    ('Canon 6D Mark II', 'Camera Body - Canon 6D Mark II daily rental (discount available)', 4000.00, 'physical', 0, true),
    ('Canon 5D Mark III', 'Camera Body - Canon 5D Mark III daily rental (discount available)', 3500.00, 'physical', 0, true),
    ('Canon 5D Mark IV', 'Camera Body - Canon 5D Mark IV daily rental (discount available)', 4500.00, 'physical', 0, true),
    ('Canon EOS RP with Adapter', 'Mirrorless Camera - Canon EOS RP with Adapter daily rental', 4000.00, 'physical', 0, true),
    ('Canon EOS R with Adapter', 'Mirrorless Camera - Canon EOS R with Adapter daily rental', 4500.00, 'physical', 0, true),
    ('Canon EOS R6 with Adapter', 'Mirrorless Camera - Canon EOS R6 with Adapter daily rental', 5500.00, 'physical', 0, true),

    -- Lenses - Sony Lenses
    ('Sony 14mm F1.8 GM', 'Sony E-Mount Lens - 14mm F1.8 GM daily rental', 3500.00, 'physical', 0, true),
    ('Sony 16-35mm F4', 'Sony E-Mount Lens - 16-35mm F4 daily rental', 2500.00, 'physical', 0, true),
    ('Sony 16-35mm F2.8 GM', 'Sony E-Mount Lens - 16-35mm F2.8 GM daily rental', 3500.00, 'physical', 0, true),
    ('Sony 70-200mm F2.8 GM', 'Sony E-Mount Lens - 70-200mm F2.8 GM daily rental', 4500.00, 'physical', 0, true),
    ('Sony 24-105mm F4 G OSS', 'Sony E-Mount Lens - 24-105mm F4 G OSS daily rental', 2500.00, 'physical', 0, true),
    ('Sony 85mm F1.4 GM', 'Sony E-Mount Lens - 85mm F1.4 GM daily rental', 3500.00, 'physical', 0, true),
    ('Sony 50mm F1.4 GM', 'Sony E-Mount Lens - 50mm F1.4 GM daily rental', 3000.00, 'physical', 0, true),
    ('Sony 50mm F1.2 GM', 'Sony E-Mount Lens - 50mm F1.2 GM daily rental', 3500.00, 'physical', 0, true),
    ('Sony 50mm F1.8', 'Sony E-Mount Lens - 50mm F1.8 daily rental', 1500.00, 'physical', 0, true),
    ('Sony 85mm F1.8', 'Sony E-Mount Lens - 85mm F1.8 daily rental', 2000.00, 'physical', 0, true),
    ('Sony 24mm F1.4 GM', 'Sony E-Mount Lens - 24mm F1.4 GM daily rental', 4500.00, 'physical', 0, true),
    ('Sony 35mm F1.4 GM', 'Sony E-Mount Lens - 35mm F1.4 GM daily rental', 4500.00, 'physical', 0, true),

    -- Lenses - Sigma Art (Sony & Canon)
    ('Sigma 24-70mm F2.8 DG DN II (Sony/Canon)', 'Sigma Art Lens - 24-70mm F2.8 DG DN II daily rental', 4000.00, 'physical', 0, true),
    ('Sigma 35mm F1.4 DG DN (Sony/Canon)', 'Sigma Art Lens - 35mm F1.4 DG DN daily rental', 2500.00, 'physical', 0, true),
    ('Sigma 50mm F1.4 DG DN (Sony/Canon)', 'Sigma Art Lens - 50mm F1.4 DG DN daily rental', 2500.00, 'physical', 0, true),
    ('Sigma 85mm F1.4 DG DN (Sony/Canon)', 'Sigma Art Lens - 85mm F1.4 DG DN daily rental', 2500.00, 'physical', 0, true),

    -- Lenses - Canon Lenses
    ('Canon 24-105mm F4', 'Canon EF/RF Lens - 24-105mm F4 daily rental', 1500.00, 'physical', 0, true),
    ('Canon 24-70mm F4', 'Canon EF Lens - 24-70mm F4 daily rental', 1500.00, 'physical', 0, true),
    ('Canon 24-70mm F2.8', 'Canon EF Lens - 24-70mm F2.8 daily rental', 2500.00, 'physical', 0, true),
    ('Canon 40mm F2.8', 'Canon EF Lens - 40mm F2.8 pancake daily rental', 1500.00, 'physical', 0, true),
    ('Canon 50mm F1.8', 'Canon EF Lens - 50mm F1.8 daily rental', 1000.00, 'physical', 0, true),
    ('Canon 100mm F2.8 Macro', 'Canon EF Lens - 100mm F2.8 Macro daily rental', 2500.00, 'physical', 0, true),
    ('Canon 16-35mm F2.8', 'Canon EF Lens - 16-35mm F2.8 daily rental', 3000.00, 'physical', 0, true),
    ('Canon 70-200mm F2.8 II', 'Canon EF Lens - 70-200mm F2.8 II daily rental', 3000.00, 'physical', 0, true),
    ('Canon 135mm F2.0', 'Canon EF Lens - 135mm F2.0 daily rental', 1500.00, 'physical', 0, true),

    -- Stabilizers & Stands - Stands & Support
    ('Light Stand - Silver', 'Silver Light Stand rental', 500.00, 'physical', 0, true),
    ('C Stand', 'Heavy duty C-Stand rental', 750.00, 'physical', 0, true),
    ('Tripod', 'Professional Camera Tripod rental', 1000.00, 'physical', 0, true),
    ('Monopod', 'Camera Monopod rental', 1000.00, 'physical', 0, true),

    -- Stabilizers & Stands - Gimbals
    ('DJI Ronin RS 3', 'DJI Ronin RS 3 Gimbal Stabilizer rental', 4000.00, 'physical', 0, true),
    ('DJI Ronin RS 4 Pro', 'DJI Ronin RS 4 Pro Gimbal Stabilizer rental', 5000.00, 'physical', 0, true),
    ('Mobile Gimbal DJI SE 4', 'DJI Osmo Mobile SE 4 smartphone gimbal rental', 1000.00, 'physical', 0, true);

    -- 3. Insert into "4Ucamera".products if table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = '4Ucamera' AND table_name = 'products') THEN
        INSERT INTO "4Ucamera".products (
            user_id,
            name,
            description,
            price,
            product_type,
            delivery_price,
            is_active,
            variations,
            images
        )
        SELECT 
            v_user_id,
            s.name,
            s.description,
            s.price,
            s.product_type,
            s.delivery_price,
            s.is_active,
            '[]'::jsonb,
            '{}'::text[]
        FROM tmp_seed_products s
        WHERE NOT EXISTS (
            SELECT 1 FROM "4Ucamera".products existing 
            WHERE existing.user_id = v_user_id AND existing.name = s.name
        );
    END IF;

    -- 4. Insert into public.products if table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'products') THEN
        INSERT INTO public.products (
            user_id,
            name,
            description,
            price,
            product_type,
            delivery_price,
            is_active,
            variations,
            images
        )
        SELECT 
            v_user_id,
            s.name,
            s.description,
            s.price,
            s.product_type,
            s.delivery_price,
            s.is_active,
            '[]'::jsonb,
            '{}'::text[]
        FROM tmp_seed_products s
        WHERE NOT EXISTS (
            SELECT 1 FROM public.products existing 
            WHERE existing.user_id = v_user_id AND existing.name = s.name
        );
    END IF;

END $$;
