-- ==========================================
-- MASTER SEED SCRIPT FOR ICSE 10 ONLY
-- Focus: ICSE 10 Hierarchy with 13 Task Columns
-- ==========================================

-- STEP 1: SCHEMA ADJUSTMENTS
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='subjects' AND column_name='class_id') THEN
        ALTER TABLE public.subjects ALTER COLUMN class_id DROP NOT NULL;
    END IF;
END $$;

ALTER TABLE public.subjects ADD COLUMN IF NOT EXISTS batch TEXT;
ALTER TABLE public.subjects ADD COLUMN IF NOT EXISTS branch TEXT;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'subjects_name_batch_key') THEN
        ALTER TABLE public.subjects ADD CONSTRAINT subjects_name_batch_key UNIQUE (name, batch);
    END IF;
END $$;

-- STEP 2: DATA SEEDING
DO $$
DECLARE
    subject_id UUID;
    chapter_id UUID;
    topic_id UUID;
    task_names TEXT[] := ARRAY[
        'TEXTBOOK READING', 'ALL LWS', 'EXERCISE Q/A', 'PYQ PRACTICE',
        'VIVA/ORAL', 'TEST 1', 'TEST 2', 'REVISION 1', 'REVISION 2', 'MAP/DIAGRAM',
        'PRACTICAL/PROJECT', 'PRELIMS', 'BOARD PREP'
    ];
    t_name TEXT;
    s_name TEXT;
    batch_val TEXT := 'ICSE 10';

    -- Curriculum Lists
    physics_10 TEXT[] := ARRAY['FORCE', 'WORK, ENERGY & POWER', 'MACHINE', 'REFRACTION OF LIGHT AT PLANE SURFACE', 'REFRACTION THROUGH A LENS', 'SPECTRUM', 'SOUND', 'CURRENT ELECTRICITY', 'HOUSEHOLD CIRCUITS', 'ELECTRO-MAGNETISM', 'CALORIMETRY', 'RADIOACTIVITY'];
    chemistry_10 TEXT[] := ARRAY['PERIODIC TABLE', 'CHEMICAL BONDING', 'ACIDS, BASES AND SALTS', 'ANALYTICAL CHEMISTRY', 'MOLE CONCEPT', 'ELECTROLYSIS', 'METALLURGY', 'HYDROGEN CHLORIDE', 'AMMONIA', 'NITRIC ACID', 'SULPHURIC ACID', 'ORGANIC CHEMISTRY'];
    maths_10 TEXT[] := ARRAY['GST', 'BANKING', 'SHARES AND DIVIDENDS', 'LINEAR INEQUATIONS', 'QUADRATIC EQUATIONS', 'RATIO AND PROPORTION', 'MATRICES', 'ARITHMETIC PROGRESSION', 'GEOMETRIC PROGRESSION', 'SIMILARITY', 'CIRCLES', 'MENSURATION', 'TRIGONOMETRY', 'STATISTICS', 'PROBABILITY'];
    biology_10 TEXT[] := ARRAY['CELL CYCLE', 'GENETICS', 'ABSORPTION BY ROOTS', 'TRANSPIRATION', 'PHOTOSYNTHESIS', 'CHEMICAL COORDINATION', 'CIRCULATORY SYSTEM', 'EXCRETORY SYSTEM', 'NERVOUS SYSTEM', 'SENSE ORGANS', 'ENDOCRINE SYSTEM', 'REPRODUCTIVE SYSTEM', 'POPULATION', 'POLLUTION'];
    history_civics_10 TEXT[] := ARRAY['UNION PARLIAMENT', 'PRESIDENT & VICE-PRESIDENT', 'PRIME MINISTER', 'SUPREME COURT', 'HIGH COURT', 'WAR OF INDEPENDENCE 1857', 'GROWTH OF NATIONALISM', 'FIRST PHASE', 'SECOND PHASE', 'MUSLIM LEAGUE', 'MAHATMA GANDHI', 'FORWARD BLOC', 'INDEPENDENCE', 'FIRST WORLD WAR', 'DICTATORSHIPS', 'SECOND WORLD WAR', 'UNITED NATIONS', 'NAM'];
    geography_10 TEXT[] := ARRAY['TOPO MAPS', 'MAP OF INDIA', 'CLIMATE', 'SOIL RESOURCES', 'NATURAL VEGETATION', 'WATER RESOURCES', 'MINERAL & ENERGY', 'AGRICULTURE', 'MANUFACTURING', 'TRANSPORT', 'WASTE MANAGEMENT'];
    computer_10 TEXT[] := ARRAY['REVISION OF IX', 'CLASSES AS BASIS', 'USER DEFINED METHODS', 'CONSTRUCTORS', 'LIBRARY CLASSES', 'ENCAPSULATION', 'ARRAYS', 'STRING HANDLING'];
    economics_10 TEXT[] := ARRAY['THEORY OF DEMAND', 'SUPPLY', 'ELASTICITY', 'FACTORS OF PRODUCTION', 'LAND', 'LABOUR', 'CAPITAL', 'ENTREPRENEUR', 'MARKET FORMS', 'BANKING & RBI', 'INFLATION', 'CONSUMER AWARENESS'];
    ca_10 TEXT[] := ARRAY['MARKETING MIX', 'ADVERTISING', 'SALES & SELLING', 'GAAP', 'FINANCIAL ACCOUNTING', 'BANK TRANSACTIONS', 'LOGISTICS & INSURANCE', 'HUMAN RESOURCES', 'PUBLIC RELATIONS', 'ENVIRONMENTAL ISSUES'];

BEGIN
    FOR s_name IN SELECT unnest(ARRAY['PHYSICS', 'CHEMISTRY', 'MATHS', 'BIOLOGY', 'ENGLISH LIT', 'ENGLISH LANG', 'HISTORY', 'CIVICS', 'GEOGRAPHY', 'HINDI', 'CS', 'ECONOMIC', 'CA']) LOOP
        INSERT INTO public.subjects (name, batch, color, icon)
        VALUES (s_name, batch_val, '#5B5FDE', '📚')
        ON CONFLICT (name, batch) DO UPDATE SET color = EXCLUDED.color
        RETURNING id INTO subject_id;

        INSERT INTO public.chapters (subject_id, title, order_index) VALUES (subject_id, 'Course Syllabus', 1) RETURNING id INTO chapter_id;

        CASE s_name
            WHEN 'PHYSICS' THEN FOREACH t_name IN ARRAY physics_10 LOOP INSERT INTO public.topics (chapter_id, title) VALUES (chapter_id, t_name) RETURNING id INTO topic_id; FOR i IN 1..13 LOOP INSERT INTO public.tasks (topic_id, title, order_index) VALUES (topic_id, task_names[i], i); END LOOP; END LOOP;
            WHEN 'CHEMISTRY' THEN FOREACH t_name IN ARRAY chemistry_10 LOOP INSERT INTO public.topics (chapter_id, title) VALUES (chapter_id, t_name) RETURNING id INTO topic_id; FOR i IN 1..13 LOOP INSERT INTO public.tasks (topic_id, title, order_index) VALUES (topic_id, task_names[i], i); END LOOP; END LOOP;
            WHEN 'MATHS' THEN FOREACH t_name IN ARRAY maths_10 LOOP INSERT INTO public.topics (chapter_id, title) VALUES (chapter_id, t_name) RETURNING id INTO topic_id; FOR i IN 1..13 LOOP INSERT INTO public.tasks (topic_id, title, order_index) VALUES (topic_id, task_names[i], i); END LOOP; END LOOP;
            WHEN 'BIOLOGY' THEN FOREACH t_name IN ARRAY biology_10 LOOP INSERT INTO public.topics (chapter_id, title) VALUES (chapter_id, t_name) RETURNING id INTO topic_id; FOR i IN 1..13 LOOP INSERT INTO public.tasks (topic_id, title, order_index) VALUES (topic_id, task_names[i], i); END LOOP; END LOOP;
            WHEN 'HISTORY' THEN FOREACH t_name IN ARRAY history_civics_10 LOOP INSERT INTO public.topics (chapter_id, title) VALUES (chapter_id, t_name) RETURNING id INTO topic_id; FOR i IN 1..13 LOOP INSERT INTO public.tasks (topic_id, title, order_index) VALUES (topic_id, task_names[i], i); END LOOP; END LOOP;
            WHEN 'GEOGRAPHY' THEN FOREACH t_name IN ARRAY geography_10 LOOP INSERT INTO public.topics (chapter_id, title) VALUES (chapter_id, t_name) RETURNING id INTO topic_id; FOR i IN 1..13 LOOP INSERT INTO public.tasks (topic_id, title, order_index) VALUES (topic_id, task_names[i], i); END LOOP; END LOOP;
            WHEN 'CS' THEN FOREACH t_name IN ARRAY computer_10 LOOP INSERT INTO public.topics (chapter_id, title) VALUES (chapter_id, t_name) RETURNING id INTO topic_id; FOR i IN 1..13 LOOP INSERT INTO public.tasks (topic_id, title, order_index) VALUES (topic_id, task_names[i], i); END LOOP; END LOOP;
            WHEN 'ECONOMIC' THEN FOREACH t_name IN ARRAY economics_10 LOOP INSERT INTO public.topics (chapter_id, title) VALUES (chapter_id, t_name) RETURNING id INTO topic_id; FOR i IN 1..13 LOOP INSERT INTO public.tasks (topic_id, title, order_index) VALUES (topic_id, task_names[i], i); END LOOP; END LOOP;
            WHEN 'CA' THEN FOREACH t_name IN ARRAY ca_10 LOOP INSERT INTO public.topics (chapter_id, title) VALUES (chapter_id, t_name) RETURNING id INTO topic_id; FOR i IN 1..13 LOOP INSERT INTO public.tasks (topic_id, title, order_index) VALUES (topic_id, task_names[i], i); END LOOP; END LOOP;
            ELSE
                INSERT INTO public.topics (chapter_id, title) VALUES (chapter_id, 'General Topic') RETURNING id INTO topic_id;
                FOR i IN 1..13 LOOP INSERT INTO public.tasks (topic_id, title, order_index) VALUES (topic_id, task_names[i], i); END LOOP;
        END CASE;
    END LOOP;
END $$;
