-- ============================================================================
-- 05_seed_faqs.sql — Seed / Upsert FAQ questions for 4U Camera
-- Compatible with PostgreSQL / Supabase on self-hosted or cloud instances.
-- Automatically supports "4Ucamera" schema and "public" schema.
-- FAQs in English so the AI auto-translates to the customer's native language.
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

    RAISE NOTICE 'Seeding FAQs for user_id: %', v_user_id;

    -- 2. Upgrade plan limits on profile so FAQs aren't blocked by plan quota
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = '4Ucamera' AND table_name = 'profiles') THEN
        UPDATE "4Ucamera".profiles 
        SET max_faqs = 999, plan_tier = 'enterprise' 
        WHERE user_id = v_user_id;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'profiles') THEN
        UPDATE public.profiles 
        SET max_faqs = 999, plan_tier = 'enterprise' 
        WHERE user_id = v_user_id;
    END IF;

    -- Temporary table with FAQ seed data
    CREATE TEMP TABLE tmp_seed_faqs (
        question text,
        answer text,
        is_active boolean,
        is_tracked boolean
    ) ON COMMIT DROP;

    INSERT INTO tmp_seed_faqs (question, answer, is_active, is_tracked) VALUES
    (
        'Where is your shop located?',
        'We are located in Kottawa. Google Maps: https://maps.app.goo.gl/kLSJP55Z6osq2xRe7?g_st=ac',
        true,
        false
    ),
    (
        'What are your opening hours?',
        'We are open 24 hours every day.',
        true,
        false
    ),
    (
        'Do you offer delivery?',
        'We currently only deliver products within a 40KM range from our workshop in Kottawa. If your area is outside this 40KM range, we don''t currently deliver products to your area but you can visit our workshop in Kottawa and hire the products if you are interested: https://maps.app.goo.gl/kLSJP55Z6osq2xRe7?g_st=ac',
        true,
        false
    ),
    (
        'Do I need to register to rent a camera or equipment?',
        'Yes, registration is mandatory before renting. You must provide ID photos (both sides), Facebook profile & page links, 2 contact numbers, home/studio location, utility billing proof, a photo of your Bank Book''s 1st page, and a recent photograph.',
        true,
        false
    ),
    (
        'How do I book a camera or equipment?',
        'Mention the required date, the camera, and the accessories you need. You do not have to make an advance payment before booking; if an advance payment is required for any product, our staff members will inform you. Send the booking details to the 4U CAMERA RENT Facebook page: https://www.facebook.com/profile.php?id=61567584624069 or call 0777911189.',
        true,
        false
    ),
    (
        'Do I need to pay an advance payment before booking?',
        'No, you do not have to pay an advance payment before booking. If an advance payment is needed for any specific item, our staff members will inform you directly.',
        true,
        false
    );

    -- 3. Update any legacy booking FAQs that mentioned advance payment in 4Ucamera
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = '4Ucamera' AND table_name = 'faqs') THEN
        UPDATE "4Ucamera".faqs
        SET answer = 'Mention the required date, the camera, and the accessories you need. You do not have to make an advance payment before booking; if an advance payment is required for any product, our staff members will inform you. Send booking details to the 4U CAMERA RENT Facebook page: https://www.facebook.com/profile.php?id=61567584624069 or call 0777911189.',
            updated_at = now()
        WHERE user_id = v_user_id AND (question ILIKE '%book a camera%' OR question ILIKE '%කැමරාවක් book%');

        UPDATE "4Ucamera".faqs
        SET answer = 'We currently only deliver products within a 40KM range from our workshop in Kottawa. If your area is outside this 40KM range, we don''t currently deliver products to your area but you can visit our workshop in Kottawa and hire the products if you are interested: https://maps.app.goo.gl/kLSJP55Z6osq2xRe7?g_st=ac',
            updated_at = now()
        WHERE user_id = v_user_id AND question ILIKE '%deliver%';

        -- Update existing questions
        UPDATE "4Ucamera".faqs f
        SET answer = s.answer,
            is_active = s.is_active,
            updated_at = now()
        FROM tmp_seed_faqs s
        WHERE f.user_id = v_user_id AND lower(f.question) = lower(s.question);

        -- Insert new questions
        INSERT INTO "4Ucamera".faqs (
            user_id,
            question,
            answer,
            is_active,
            is_tracked,
            media_urls
        )
        SELECT 
            v_user_id,
            s.question,
            s.answer,
            s.is_active,
            s.is_tracked,
            '{}'::text[]
        FROM tmp_seed_faqs s
        WHERE NOT EXISTS (
            SELECT 1 FROM "4Ucamera".faqs existing 
            WHERE existing.user_id = v_user_id AND lower(existing.question) = lower(s.question)
        );
    END IF;

    -- 4. Update any legacy booking FAQs that mentioned advance payment in public
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'faqs') THEN
        UPDATE public.faqs
        SET answer = 'Mention the required date, the camera, and the accessories you need. You do not have to make an advance payment before booking; if an advance payment is required for any product, our staff members will inform you. Send booking details to the 4U CAMERA RENT Facebook page: https://www.facebook.com/profile.php?id=61567584624069 or call 0777911189.',
            updated_at = now()
        WHERE user_id = v_user_id AND (question ILIKE '%book a camera%' OR question ILIKE '%කැමරාවක් book%');

        UPDATE public.faqs
        SET answer = 'We currently only deliver products within a 40KM range from our workshop in Kottawa. If your area is outside this 40KM range, we don''t currently deliver products to your area but you can visit our workshop in Kottawa and hire the products if you are interested: https://maps.app.goo.gl/kLSJP55Z6osq2xRe7?g_st=ac',
            updated_at = now()
        WHERE user_id = v_user_id AND question ILIKE '%deliver%';

        -- Update existing questions
        UPDATE public.faqs f
        SET answer = s.answer,
            is_active = s.is_active,
            updated_at = now()
        FROM tmp_seed_faqs s
        WHERE f.user_id = v_user_id AND lower(f.question) = lower(s.question);

        -- Insert new questions
        INSERT INTO public.faqs (
            user_id,
            question,
            answer,
            is_active,
            is_tracked,
            media_urls
        )
        SELECT 
            v_user_id,
            s.question,
            s.answer,
            s.is_active,
            s.is_tracked,
            '{}'::text[]
        FROM tmp_seed_faqs s
        WHERE NOT EXISTS (
            SELECT 1 FROM public.faqs existing 
            WHERE existing.user_id = v_user_id AND lower(existing.question) = lower(s.question)
        );
    END IF;

END $$;
