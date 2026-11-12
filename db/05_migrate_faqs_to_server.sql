-- ============================================================================
-- 05_migrate_faqs_to_server.sql
-- Migration script to seed / sync 4U Camera FAQs to your server.
--
-- How to run on your server:
--   Option A: Supabase Studio -> SQL Editor -> Paste this script and click Run.
--   Option B: psql "$DATABASE_URL" -f db/05_migrate_faqs_to_server.sql
--   Option C: docker exec -i supabase-db psql -U postgres -d postgres < db/05_migrate_faqs_to_server.sql
-- ============================================================================

DO $$
DECLARE
    v_user_id uuid;
    -- Set this to your admin / business account email on the server:
    v_target_email text := 'qwe@buildstart.io';
BEGIN
    -- 1. Find user ID by email
    SELECT id INTO v_user_id FROM auth.users WHERE email = v_target_email;

    -- Fallback: If target email is not found, take the first registered user
    IF v_user_id IS NULL THEN
        SELECT id INTO v_user_id FROM auth.users ORDER BY created_at ASC LIMIT 1;
    END IF;

    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'No user found in auth.users. Please create a user first before running FAQ migration.';
    END IF;

    RAISE NOTICE 'Target User ID resolved: %', v_user_id;

    -- 2. Ensure user plan has sufficient quota for FAQs
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

    -- 3. Staging table for FAQ knowledge base
    CREATE TEMP TABLE tmp_faqs (
        question text,
        answer text,
        is_active boolean,
        is_tracked boolean
    ) ON COMMIT DROP;

    INSERT INTO tmp_faqs (question, answer, is_active, is_tracked) VALUES
    (
        'What gear and brands do you rent? (ඔයාලා ළඟ තියෙන කැමරා සහ gear මොනවද?)',
        'We rent Canon & Sony Cameras, Lenses (Sony, Canon, Sigma Art), Stabilizers, Lights & Accessories.',
        true,
        true
    ),
    (
        'Do you provide delivery? (Delivery පහසුකම් තියෙනවාද?)',
        'We currently only deliver products within a 40KM range from our workshop in Kottawa. If your area is outside this 40KM range, we don''t currently deliver products to your area but you can visit our workshop in Kottawa and hire the products if you are interested: https://maps.app.goo.gl/kLSJP55Z6osq2xRe7?g_st=ac',
        true,
        true
    ),
    (
        'Do you have wedding or event packages? (Wedding / Pre-shoot / Event packages තියෙනවාද?)',
        'දැනට අප සතුව ඇත්තේ Camera, Lens සහ Equipment Renting පමණි. Wedding හෝ Event packages දැනට ලබා නොදේ.',
        true,
        true
    ),
    (
        'What if an item is not in stock? (Item එකක් available නැතිනම් මොකද කරන්නේ?)',
        'මේ item එක දැනට available නෑ, ඔබට අපගේ සේවාදායකයෙක් හරහා මෙය ලබාදෙන්න පුලුවන් කරුණාකර අපව අමතන්න.',
        true,
        true
    ),
    (
        'Where is your shop located? (ඔයාලගේ shop එක තියෙන්නේ කොහේද?)',
        'We are located in Kottawa. Google Maps: https://maps.app.goo.gl/kLSJP55Z6osq2xRe7?g_st=ac',
        true,
        true
    ),
    (
        'What are your opening hours? (Shop එක open කරලා තියෙන වෙලාවල් මොනවද?)',
        'We are open 24 hours every day.',
        true,
        true
    ),
    (
        'What documents are required to register and rent? (කැමරා ගන්න Register වෙන්න ඕන documents මොනවද?)',
        'Cameras ganna aniwaryenma register wenna ona. Required Documents:' || E'\n' ||
        '- ID Photos: Clear photos of both sides.' || E'\n' ||
        '- Social Media: Facebook Profile & Page links.' || E'\n' ||
        '- Contact: Two active contact numbers.' || E'\n' ||
        '- Location: Home location (Google Maps link or Address) & Studio location.' || E'\n' ||
        '- Verification: Billing proof & a photo of your Bank Book 1st page.' || E'\n' ||
        '- Identification: A recent, clear photograph of yourself.' || E'\n\n' ||
        'Me page ekata documents send karanna: https://www.facebook.com/profile.php?id=61567584624069',
        true,
        true
    ),
    (
        'How to book a camera? (කැමරාවක් book කරගන්නේ කොහොමද?)',
        'Mention the required date, the camera, and the accessories you need. You do not have to make an advance payment before booking; if an advance payment is required for any product, our staff members will inform you. Send booking details to the 4U CAMERA RENT Facebook page: https://www.facebook.com/profile.php?id=61567584624069 or call 0777911189.',
        true,
        true
    ),
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

    -- 4. Apply to "4Ucamera" schema if it exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = '4Ucamera' AND table_name = 'faqs') THEN
        -- Update existing questions
        UPDATE "4Ucamera".faqs f
        SET answer = s.answer,
            is_active = s.is_active,
            is_tracked = s.is_tracked,
            updated_at = now()
        FROM tmp_faqs s
        WHERE f.user_id = v_user_id AND lower(trim(f.question)) = lower(trim(s.question));

        -- Insert new questions that do not exist yet
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
        FROM tmp_faqs s
        WHERE NOT EXISTS (
            SELECT 1 FROM "4Ucamera".faqs existing 
            WHERE existing.user_id = v_user_id AND lower(trim(existing.question)) = lower(trim(s.question))
        );

        RAISE NOTICE 'Successfully synchronized FAQs into "4Ucamera".faqs table.';
    END IF;

    -- 5. Apply to "public" schema if it exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'faqs') THEN
        -- Update existing questions
        UPDATE public.faqs f
        SET answer = s.answer,
            is_active = s.is_active,
            is_tracked = s.is_tracked,
            updated_at = now()
        FROM tmp_faqs s
        WHERE f.user_id = v_user_id AND lower(trim(f.question)) = lower(trim(s.question));

        -- Insert new questions that do not exist yet
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
        FROM tmp_faqs s
        WHERE NOT EXISTS (
            SELECT 1 FROM public.faqs existing 
            WHERE existing.user_id = v_user_id AND lower(trim(existing.question)) = lower(trim(s.question))
        );

        RAISE NOTICE 'Successfully synchronized FAQs into "public".faqs table.';
    END IF;

    RAISE NOTICE 'FAQ migration completed successfully.';
END $$;
