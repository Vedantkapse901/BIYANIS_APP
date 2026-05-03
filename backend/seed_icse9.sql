-- ==========================================
-- MASTER SEED SCRIPT FOR ICSE 9 ONLY
-- Focus: ICSE 9 Hierarchy with 13 Task Columns
-- ==========================================

-- Ensure batch and branch columns exist
ALTER TABLE public.subjects ADD COLUMN IF NOT EXISTS batch TEXT;
ALTER TABLE public.subjects ADD COLUMN IF NOT EXISTS branch TEXT;

-- STEP 2: DATA SEEDING FOR ICSE 9
DO $$
DECLARE
    subject_id UUID;
    chapter_id UUID;
    topic_id UUID;
    task_names TEXT[] := ARRAY[
        'TEXTBOOK READING', 'ALL LWS', 'EXERCISE Q/A', 'PYQ PRACTICE',
        'TASK 5', 'TASK 6', 'TASK 7', 'TASK 8', 'TASK 9', 'TASK 10',
        'TASK 11', 'TASK 12', 'REVISION'
    ];
    t_name TEXT;
    s_name TEXT;
    batch_val TEXT := 'ICSE 9';

    -- Chapter/Topic Lists for ICSE 9
    physics_9 TEXT[] := ARRAY['MEASUREMENTS AND EXPERIMENTATION', 'MOTION IN ONE DIMENSION', 'LAWS OF MOTION', 'FLUIDS', 'UPTHRUST IN FLUIDS', 'HEAT AND ENERGY', 'LIGHT', 'SOUND', 'ELECTRICITY', 'MAGNETISM'];
    chemistry_9 TEXT[] := ARRAY['THE LANGUAGE OF CHEMISTRY', 'CHEMICAL CHANGES AND REACTIONS', 'WATER', 'ATOMIC STRUCTURE AND CHEMICAL BONDING', 'THE PERIODIC TABLE', 'STUDY OF THE FIRST ELEMENT - HYDROGEN', 'STUDY OF GAS LAWS', 'ATMOSPHERIC POLLUTION'];
    maths_9 TEXT[] := ARRAY['RATIONAL AND IRRATIONAL NUMBERS', 'PROFIT AND LOSS', 'COMPOUND INTEREST', 'EXPANSIONS', 'FACTORISATION', 'SIMULTANEOUS EQUATIONS', 'INDICES', 'LOGARITHMS', 'TRIANGLES', 'ISOSCELES TRIANGLES', 'CONGRUENCY', 'PYTHAGORAS THEOREM', 'RECTILINEAR FIGURES', 'THEOREMS ON AREA', 'CIRCLE', 'STATISTICS', 'MENSURATION', 'TRIGONOMETRY', 'COORDINATE GEOMETRY'];
    biology_9 TEXT[] := ARRAY['INTRODUCING BIOLOGY', 'CELL: THE UNIT OF LIFE', 'TISSUES: PLANT AND ANIMAL TISSUES', 'THE FLOWER', 'POLLINATION AND FERTILIZATION', 'SEEDS: STRUCTURE AND GERMINATION', 'RESPIRATION IN PLANTS', 'FIVE KINGDOM CLASSIFICATION', 'ECONOMIC IMPORTANCE OF BACTERIA AND FUNGI', 'NUTRITION', 'DIGESTIVE SYSTEM', 'SKELETON - MOVEMENT AND LOCOMOTION', 'SKIN - THE JACK OF ALL TRADES', 'THE RESPIRATORY SYSTEM', 'HYGIENE', 'DISEASES: CAUSE AND CONTROL', 'AIDS TO HEALTH', 'HEALTH ORGANISATIONS', 'WASTE GENERATION AND MANAGEMENT'];

BEGIN
    -- Loop through the subjects
    FOR s_name IN SELECT unnest(ARRAY[
        'PHYSICS', 'CHEMISTRY', 'MATHS', 'BIOLOGY',
        'ENGLISH LITERATURE', 'ENGLISH LANGUAGE',
        'HISTORY', 'CIVICS', 'GEOGRAPHY',
        'HINDI', 'CS'
    ]) LOOP
        -- Insert or Get Subject for ICSE 9
        INSERT INTO public.subjects (name, batch, color, icon)
        VALUES (s_name, batch_val,
            CASE
                WHEN s_name = 'PHYSICS' THEN '#5B5FDE'
                WHEN s_name = 'CHEMISTRY' THEN '#E91E63'
                WHEN s_name = 'MATHS' THEN '#4CAF50'
                WHEN s_name = 'BIOLOGY' THEN '#00BCD4'
                WHEN s_name = 'HINDI' THEN '#FF9800'
                ELSE '#795548'
            END,
            CASE
                WHEN s_name = 'PHYSICS' THEN '⚛️'
                WHEN s_name = 'CHEMISTRY' THEN '🧪'
                WHEN s_name = 'MATHS' THEN '📐'
                WHEN s_name = 'BIOLOGY' THEN '🧬'
                ELSE '📚'
            END
        )
        ON CONFLICT (name, batch) DO UPDATE SET color = EXCLUDED.color, icon = EXCLUDED.icon
        RETURNING id INTO subject_id;

        -- HINDI: Nested Books Structure for ICSE 9 (Similar to ICSE 10 but maybe different topics)
        IF s_name = 'HINDI' THEN
            -- 1. SAHITYA SAGAR
            INSERT INTO public.chapters (subject_id, title, order_index) VALUES (subject_id, 'SAHITYA SAGAR', 1) RETURNING id INTO chapter_id;
            FOR t_name IN SELECT unnest(ARRAY['BAAT ATTHANI KI', 'KAKI', 'MAHAYAGYA KA PURASKAR', 'NETAJI KA CHASHMA']) LOOP
                INSERT INTO public.topics (chapter_id, title) VALUES (chapter_id, t_name) RETURNING id INTO topic_id;
                FOR i IN 1..13 LOOP INSERT INTO public.tasks (topic_id, title, order_index) VALUES (topic_id, task_names[i], i); END LOOP;
            END LOOP;
            -- 2. POEM
            INSERT INTO public.chapters (subject_id, title, order_index) VALUES (subject_id, 'POEM', 2) RETURNING id INTO chapter_id;
            FOR t_name IN SELECT unnest(ARRAY['SAKHI', 'GIRIDHAR KI KUNDALIYA', 'SWARG BANA SAKHTE HE']) LOOP
                INSERT INTO public.topics (chapter_id, title) VALUES (chapter_id, t_name) RETURNING id INTO topic_id;
                FOR i IN 1..13 LOOP INSERT INTO public.tasks (topic_id, title, order_index) VALUES (topic_id, task_names[i], i); END LOOP;
            END LOOP;

        ELSIF s_name = 'PHYSICS' THEN
            INSERT INTO public.chapters (subject_id, title, order_index) VALUES (subject_id, 'Physics Course', 1) RETURNING id INTO chapter_id;
            FOREACH t_name IN ARRAY physics_9 LOOP
                INSERT INTO public.topics (chapter_id, title) VALUES (chapter_id, t_name) RETURNING id INTO topic_id;
                FOR i IN 1..13 LOOP INSERT INTO public.tasks (topic_id, title, order_index) VALUES (topic_id, task_names[i], i); END LOOP;
            END LOOP;
        ELSIF s_name = 'CHEMISTRY' THEN
            INSERT INTO public.chapters (subject_id, title, order_index) VALUES (subject_id, 'Chemistry Course', 1) RETURNING id INTO chapter_id;
            FOREACH t_name IN ARRAY chemistry_9 LOOP
                INSERT INTO public.topics (chapter_id, title) VALUES (chapter_id, t_name) RETURNING id INTO topic_id;
                FOR i IN 1..13 LOOP INSERT INTO public.tasks (topic_id, title, order_index) VALUES (topic_id, task_names[i], i); END LOOP;
            END LOOP;
        ELSIF s_name = 'MATHS' THEN
            INSERT INTO public.chapters (subject_id, title, order_index) VALUES (subject_id, 'Maths Course', 1) RETURNING id INTO chapter_id;
            FOREACH t_name IN ARRAY maths_9 LOOP
                INSERT INTO public.topics (chapter_id, title) VALUES (chapter_id, t_name) RETURNING id INTO topic_id;
                FOR i IN 1..13 LOOP INSERT INTO public.tasks (topic_id, title, order_index) VALUES (topic_id, task_names[i], i); END LOOP;
            END LOOP;
        ELSIF s_name = 'BIOLOGY' THEN
            INSERT INTO public.chapters (subject_id, title, order_index) VALUES (subject_id, 'Biology Course', 1) RETURNING id INTO chapter_id;
            FOREACH t_name IN ARRAY biology_9 LOOP
                INSERT INTO public.topics (chapter_id, title) VALUES (chapter_id, t_name) RETURNING id INTO topic_id;
                FOR i IN 1..13 LOOP INSERT INTO public.tasks (topic_id, title, order_index) VALUES (topic_id, task_names[i], i); END LOOP;
            END LOOP;
        ELSE
            -- Default structure
            INSERT INTO public.chapters (subject_id, title, order_index) VALUES (subject_id, 'Syllabus', 1) RETURNING id INTO chapter_id;
            INSERT INTO public.topics (chapter_id, title) VALUES (chapter_id, 'General Topic') RETURNING id INTO topic_id;
            FOR i IN 1..13 LOOP INSERT INTO public.tasks (topic_id, title, order_index) VALUES (topic_id, task_names[i], i); END LOOP;
        END IF;

    END LOOP;
END $$;
