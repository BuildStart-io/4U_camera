-- ============================================================================
-- 04_seed_products.sql — Seed rental products for 4U Camera
-- Compatible with PostgreSQL / Supabase on self-hosted or cloud instances.
-- Automatically supports "4Ucamera" schema or "public" schema.
-- Updated with complete 97-product catalogue and current rental prices.
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

    -- 2. Upgrade plan limits on profile so all 97 products are visible
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

    -- Temporary table to hold complete product seed data
    CREATE TEMP TABLE tmp_seed_products (
        name text,
        description text,
        price numeric(10,2),
        product_type text,
        delivery_price numeric,
        is_active boolean
    ) ON COMMIT DROP;

    INSERT INTO tmp_seed_products (name, description, price, product_type, delivery_price, is_active) VALUES
    -- 1. Canon Cameras
    ('Canon 6D', 'Camera Body - Canon 6D daily rental', 2000.00, 'physical', 0, true),
    ('Canon 6D Mark II', 'Camera Body - Canon 6D Mark II daily rental', 3500.00, 'physical', 0, true),
    ('Canon R', 'Mirrorless Camera - Canon EOS R daily rental', 4000.00, 'physical', 0, true),
    ('Canon 5D Mark IV', 'Camera Body - Canon 5D Mark IV daily rental', 4000.00, 'physical', 0, true),
    ('Canon R6 Mark II', 'Mirrorless Camera - Canon EOS R6 Mark II daily rental', 6000.00, 'physical', 0, true),

    -- 2. Nikon Cameras
    ('Nikon D850', 'DSLR Camera - Nikon D850 daily rental', 4000.00, 'physical', 0, true),
    ('Z6 Mark III - With Adapter', 'Mirrorless Camera - Nikon Z6 Mark III with Adapter daily rental', 6000.00, 'physical', 0, true),

    -- 3. Sony Cameras
    ('Sony A7 III', 'Mirrorless Camera - Sony A7 III daily rental', 4000.00, 'physical', 0, true),
    ('Sony A7 IV', 'Mirrorless Camera - Sony A7 IV daily rental', 6000.00, 'physical', 0, true),
    ('Sony A7S III', 'Mirrorless Camera - Sony A7S III daily rental', 8000.00, 'physical', 0, true),
    ('Sony A7 V', 'Mirrorless Camera - Sony A7 V daily rental', 8000.00, 'physical', 0, true),
    ('Sony A7R V', 'Mirrorless Camera - Sony A7R V high resolution daily rental', 8000.00, 'physical', 0, true),
    ('Sony FX3', 'Cinema Line Camera - Sony FX3 daily rental', 10000.00, 'physical', 0, true),

    -- 4. Canon Lenses
    ('Canon 50mm F1.8', 'Canon EF/RF Lens - 50mm F1.8 daily rental', 750.00, 'physical', 0, true),
    ('Canon 24-105mm F4', 'Canon Lens - 24-105mm F4 IS daily rental', 1500.00, 'physical', 0, true),
    ('Canon 70-200 IS II F2.8', 'Canon Telephoto Lens - 70-200mm IS II F2.8 daily rental', 3000.00, 'physical', 0, true),
    ('Sigma Canon 24-70mm F2.8', 'Sigma Art Lens for Canon - 24-70mm F2.8 daily rental', 3500.00, 'physical', 0, true),
    ('Sigma 35mm F1.4 (Canon)', 'Sigma Art Lens for Canon - 35mm F1.4 daily rental', 2500.00, 'physical', 0, true),
    ('Sigma 85mm F1.4 (Canon)', 'Sigma Art Lens for Canon - 85mm F1.4 daily rental', 3000.00, 'physical', 0, true),
    ('Sigma 150-600mm F5.6', 'Sigma Telephoto Zoom Lens - 150-600mm F5.6 daily rental', 4500.00, 'physical', 0, true),
    ('Canon RF 24-70mm F2.8 IS USM', 'Canon RF Lens - 24-70mm F2.8 IS USM daily rental', 6500.00, 'physical', 0, true),

    -- 5. Sony Lenses
    ('Sony 28-70mm F3.5', 'Sony E-Mount Lens - 28-70mm F3.5 OSS daily rental', 1500.00, 'physical', 0, true),
    ('Sony 24-105mm F4', 'Sony E-Mount Lens - 24-105mm F4 G OSS daily rental', 2500.00, 'physical', 0, true),
    ('Sony 16-35mm F4', 'Sony E-Mount Lens - 16-35mm F4 Zeiss/G daily rental', 2000.00, 'physical', 0, true),
    ('Sony 50mm F1.8', 'Sony E-Mount Lens - 50mm F1.8 daily rental', 1500.00, 'physical', 0, true),
    ('Sony 90mm F2.8 Macro', 'Sony E-Mount Lens - 90mm F2.8 Macro G OSS daily rental', 3000.00, 'physical', 0, true),
    ('Sony 35mm F1.4 GM', 'Sony G Master Lens - 35mm F1.4 GM daily rental', 3000.00, 'physical', 0, true),
    ('Sony 50mm F1.4 GM', 'Sony G Master Lens - 50mm F1.4 GM daily rental', 3500.00, 'physical', 0, true),
    ('Sony 85mm F1.4 GM', 'Sony G Master Lens - 85mm F1.4 GM daily rental', 3500.00, 'physical', 0, true),
    ('Sony 50mm F1.2 GM', 'Sony G Master Lens - 50mm F1.2 GM daily rental', 5000.00, 'physical', 0, true),
    ('Sony 28-70mm GM F2', 'Sony G Master Lens - 28-70mm F2 GM daily rental', 8000.00, 'physical', 0, true),
    ('Sony 16-35mm F2.8 GM', 'Sony G Master Lens - 16-35mm F2.8 GM daily rental', 5000.00, 'physical', 0, true),
    ('Sony 200-600mm F5.6 GM', 'Sony G Master Lens - 200-600mm F5.6-6.3 G OSS daily rental', 4500.00, 'physical', 0, true),
    ('Sony 70-200mm F2.8 GM II', 'Sony G Master Lens - 70-200mm F2.8 GM OSS II daily rental', 5000.00, 'physical', 0, true),
    ('Sony 24-70mm GM II F2.8', 'Sony G Master Lens - 24-70mm F2.8 GM II daily rental', 5000.00, 'physical', 0, true),
    ('Sony 50-150mm GM F2', 'Sony G Master Lens - 50-150mm GM F2 daily rental', 8000.00, 'physical', 0, true),

    -- 6. Sony Lenses - Sigma Art
    ('Sigma Art 14-24mm F2.8 (Sony)', 'Sigma Art Lens for Sony E - 14-24mm F2.8 DG DN daily rental', 3000.00, 'physical', 0, true),
    ('Sigma Art 24-70mm F2.8 (Sony)', 'Sigma Art Lens for Sony E - 24-70mm F2.8 DG DN daily rental', 3500.00, 'physical', 0, true),
    ('Sigma Art 35mm F1.4 (Sony)', 'Sigma Art Lens for Sony E - 35mm F1.4 DG DN daily rental', 2500.00, 'physical', 0, true),
    ('Sigma Art 50mm F1.4 (Sony)', 'Sigma Art Lens for Sony E - 50mm F1.4 DG DN daily rental', 2500.00, 'physical', 0, true),
    ('Sigma Art 85mm F1.4 (Sony)', 'Sigma Art Lens for Sony E - 85mm F1.4 DG DN daily rental', 2500.00, 'physical', 0, true),

    -- 7. Nikon Lenses
    ('Nikon 16-35mm F4', 'Nikon FX Lens - 16-35mm F4 ED VR daily rental', 2000.00, 'physical', 0, true),
    ('Nikon 50mm F1.8', 'Nikon Lens - 50mm F1.8 daily rental', 1000.00, 'physical', 0, true),
    ('Sigma 24-70mm F2.8 (Nikon)', 'Sigma Art Lens for Nikon - 24-70mm F2.8 daily rental', 3500.00, 'physical', 0, true),
    ('Sigma 35mm Art F1.4 (Nikon)', 'Sigma Art Lens for Nikon - 35mm F1.4 daily rental', 2500.00, 'physical', 0, true),
    ('Sigma 50mm Art F1.4 (Nikon)', 'Sigma Art Lens for Nikon - 50mm F1.4 daily rental', 2500.00, 'physical', 0, true),
    ('Sigma 85mm Art F1.4 (Nikon)', 'Sigma Art Lens for Nikon - 85mm F1.4 daily rental', 2500.00, 'physical', 0, true),
    ('Nikon 70-200mm (Tamron) F2.8', 'Tamron SP 70-200mm F2.8 Di VC USD for Nikon daily rental', 3000.00, 'physical', 0, true),
    ('Nikon Z 35mm F1.4', 'Nikon Z-Mount Lens - 35mm F1.4 daily rental', 2500.00, 'physical', 0, true),
    ('Nikon Z 50mm F1.4', 'Nikon Z-Mount Lens - 50mm F1.4 daily rental', 2500.00, 'physical', 0, true),

    -- 8. Flash Light / Video Light
    ('Godox V860 II', 'Godox V860 II Speedlite Flash daily rental', 1000.00, 'physical', 0, true),
    ('Godox V1', 'Godox V1 Round Head Camera Flash daily rental', 1000.00, 'physical', 0, true),
    ('AD600 Full Set', 'Godox AD600 Outdoor Strobe Flash Full Set daily rental', 3000.00, 'physical', 0, true),
    ('Video Light 500K Battery', 'Continuous Video Light 500K with Battery daily rental', 1500.00, 'physical', 0, true),
    ('Video Light 2K Nice Photo', 'Nicefoto 2K Studio Continuous Video Light daily rental', 1500.00, 'physical', 0, true),
    ('300 Nanlite (Video) Full Set', 'Nanlite Forza 300 Continuous Video Light Full Set daily rental', 3000.00, 'physical', 0, true),
    ('500 Nanlite (Video) Full Set', 'Nanlite Forza 500 Continuous Video Light Full Set daily rental', 4000.00, 'physical', 0, true),
    ('Snoot', 'Studio Optical Snoot Cone Attachment daily rental', 500.00, 'physical', 0, true),
    ('ZSYB 80W COB Light / Spot Light', 'ZSYB 80W COB Video Spot Light daily rental', 1500.00, 'physical', 0, true),
    ('RGB Light', 'Handheld RGB LED Tube / Panel Light daily rental', 1500.00, 'physical', 0, true),
    ('Godox LC 500R RGB Light', 'Godox LC500R RGB LED Light Stick daily rental', 1500.00, 'physical', 0, true),
    ('Nanlite Pavo Tube Light', 'Nanlite Pavotube RGB LED Tube Light daily rental', 2000.00, 'physical', 0, true),
    ('Canon Trigger X2', 'Godox X2T Wireless Flash Trigger for Canon daily rental', 500.00, 'physical', 0, true),
    ('Nikon Trigger X2', 'Godox X2T Wireless Flash Trigger for Nikon daily rental', 500.00, 'physical', 0, true),
    ('Sony X2', 'Godox X2T Wireless Flash Trigger for Sony daily rental', 500.00, 'physical', 0, true),
    ('Sony Trigger X2 Pro', 'Godox XPro / X2 Pro Wireless Flash Trigger for Sony daily rental', 1000.00, 'physical', 0, true),
    ('Sony Trigger X3 Pro', 'Godox X3 Touchscreen Flash Trigger for Sony daily rental', 1000.00, 'physical', 0, true),

    -- 9. Gimbal Stabilizer & Tripods
    ('Osmo Mobile 7', 'DJI Osmo Mobile Smartphone Gimbal Stabilizer daily rental', 2000.00, 'physical', 0, true),
    ('Ronin RS4 Gimbal', 'DJI RS 4 Camera Gimbal Stabilizer daily rental', 4000.00, 'physical', 0, true),
    ('Ronin RS 5 Combo with AI Focus', 'DJI RS 5 Combo Camera Gimbal with AI Focus Module daily rental', 5000.00, 'physical', 0, true),
    ('Photo Tripod', 'Professional Heavy Duty Photo Tripod daily rental', 1000.00, 'physical', 0, true),
    ('Video Tripod', 'Professional Fluid Head Video Tripod daily rental', 1000.00, 'physical', 0, true),
    ('Monopod', 'Professional Camera Monopod daily rental', 500.00, 'physical', 0, true),

    -- 10. Microphones & Audio
    ('Rode GO II Wireless Mic', 'Rode Wireless GO II Dual Wireless Microphone System daily rental', 2500.00, 'physical', 0, true),
    ('Rode GO II Pro', 'Rode Wireless PRO / GO II Pro Wireless Microphone System daily rental', 2500.00, 'physical', 0, true),
    ('DJI Mic Mini / Mic Mini 2', 'DJI Mic Compact Wireless Microphone System daily rental', 2500.00, 'physical', 0, true),
    ('Shotgun Mic', 'Directional Shotgun Condenser Microphone daily rental', 1500.00, 'physical', 0, true),
    ('Zoom H5', 'Zoom H5 Handy Audio Recorder daily rental', 2000.00, 'physical', 0, true),
    ('Zoom H8', 'Zoom H8 Multi-Track Field Audio Recorder daily rental', 3000.00, 'physical', 0, true),
    ('Boom Mic', 'Boom Pole with Shock Mount & Shotgun Microphone daily rental', 2000.00, 'physical', 0, true),
    ('Podcast Mic with Arm', 'Broadcast Podcast Microphone with Boom Arm daily rental', 3000.00, 'physical', 0, true),
    ('Audio Mixer', 'Multi-channel Audio Mixer console daily rental', 3000.00, 'physical', 0, true),

    -- 11. Action Cameras
    ('GoPro 9', 'GoPro HERO 9 Black 5K Action Camera daily rental', 2500.00, 'physical', 0, true),
    ('GoPro 13', 'GoPro HERO 13 Black Action Camera daily rental', 3000.00, 'physical', 0, true),
    ('DJI Osmo Pocket 3', 'DJI Osmo Pocket 3 4K Gimbal Camera daily rental', 3500.00, 'physical', 0, true),
    ('DJI Osmo 360', 'DJI / Insta360 360 Action Camera daily rental', 3000.00, 'physical', 0, true),

    -- 12. Live Equipment
    ('Hollyland Cosmo C1 Video Transmitter', 'Hollyland Cosmo C1 SDI/HDMI Wireless Video Transmission System daily rental', 4500.00, 'physical', 0, true),
    ('Blackmagic ATEM Mini Pro Capture Card', 'Blackmagic ATEM Mini Pro HDMI Live Stream Switcher daily rental', 4500.00, 'physical', 0, true),
    ('Hollyland Solidcom SE Intercom 5 Pax', 'Hollyland Solidcom SE 5-Person Full-Duplex Wireless Intercom System daily rental', 6000.00, 'physical', 0, true),
    ('4K HDMI Cable 15 Meter', '15m High-Speed 4K Optical HDMI Cable daily rental', 2000.00, 'physical', 0, true),

    -- 13. Monitors & Accessories
    ('Monitors - 5 Inch', '5-inch On-Camera Field Monitor (Feelworld/Portkeys) daily rental', 1500.00, 'physical', 0, true),
    ('DP Monitors - 7 Inch', '7-inch High Bright On-Camera Director/Field Monitor daily rental', 2500.00, 'physical', 0, true),
    ('Seetec P173 Director Monitor 17 Inch', 'Seetec P173-9HSD 17.3-inch Broadcast Director Monitor daily rental', 4000.00, 'physical', 0, true),
    ('V-Mount Battery', 'High Capacity V-Mount Li-Ion Battery for lights/cameras daily rental', 2000.00, 'physical', 0, true),
    ('Camera Battery', 'Spare Camera Battery (Sony NP-FZ100 / Canon LP-E6N / Nikon) daily rental', 500.00, 'physical', 0, true),
    ('Camera Charger', 'Dual Camera Battery Charger daily rental', 500.00, 'physical', 0, true),
    ('SD Card', 'High-Speed 64GB/128GB V30/V60 Professional SD Card daily rental', 500.00, 'physical', 0, true);

    -- 3. Upsert into "4Ucamera".products if table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = '4Ucamera' AND table_name = 'products') THEN
        -- Update existing products with new pricing & descriptions
        UPDATE "4Ucamera".products p
        SET price = s.price,
            description = s.description,
            is_active = true
        FROM tmp_seed_products s
        WHERE p.user_id = v_user_id AND lower(p.name) = lower(s.name);

        -- Insert newly added products
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
            WHERE existing.user_id = v_user_id AND lower(existing.name) = lower(s.name)
        );
    END IF;

    -- 4. Upsert into public.products if table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'products') THEN
        UPDATE public.products p
        SET price = s.price,
            description = s.description,
            is_active = true
        FROM tmp_seed_products s
        WHERE p.user_id = v_user_id AND lower(p.name) = lower(s.name);

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
            WHERE existing.user_id = v_user_id AND lower(existing.name) = lower(s.name)
        );
    END IF;

    -- 5. Save catalog_pdf_url in settings
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = '4Ucamera' AND table_name = 'settings') THEN
        INSERT INTO "4Ucamera".settings (user_id, key, value)
        VALUES (
            v_user_id,
            'catalog_pdf_url',
            jsonb_build_object('url', 'http://supabase-minio:9000/biz-' || v_user_id || '/catalog/4U_Camera_Rent_Price_List.pdf')
        )
        ON CONFLICT (user_id, key) DO UPDATE SET value = EXCLUDED.value;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'settings') THEN
        INSERT INTO public.settings (user_id, key, value)
        VALUES (
            v_user_id,
            'catalog_pdf_url',
            jsonb_build_object('url', 'http://supabase-minio:9000/biz-' || v_user_id || '/catalog/4U_Camera_Rent_Price_List.pdf')
        )
        ON CONFLICT (user_id, key) DO UPDATE SET value = EXCLUDED.value;
    END IF;

END $$;
