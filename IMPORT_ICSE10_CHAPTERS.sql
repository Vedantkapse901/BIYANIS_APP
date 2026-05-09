-- IMPORT ICSE 10 CHAPTERS WITH 13 TASKS
-- This script imports data from ICSE10_chapters_with_13_tasks.csv

-- Step 1: Add columns if they don't exist
ALTER TABLE chapters
ADD COLUMN IF NOT EXISTS batch VARCHAR(50),
ADD COLUMN IF NOT EXISTS task_1 TEXT,
ADD COLUMN IF NOT EXISTS task_2 TEXT,
ADD COLUMN IF NOT EXISTS task_3 TEXT,
ADD COLUMN IF NOT EXISTS task_4 TEXT,
ADD COLUMN IF NOT EXISTS task_5 TEXT,
ADD COLUMN IF NOT EXISTS task_6 TEXT,
ADD COLUMN IF NOT EXISTS task_7 TEXT,
ADD COLUMN IF NOT EXISTS task_8 TEXT,
ADD COLUMN IF NOT EXISTS task_9 TEXT,
ADD COLUMN IF NOT EXISTS task_10 TEXT,
ADD COLUMN IF NOT EXISTS task_11 TEXT,
ADD COLUMN IF NOT EXISTS task_12 TEXT,
ADD COLUMN IF NOT EXISTS task_13 TEXT;

-- Step 2: Import data using VALUES (direct insert)
-- You can copy the chapter data directly here

INSERT INTO chapters (subject_id, title, order_index, batch, task_1, task_2, task_3, task_4, task_5, task_6, task_7, task_8, task_9, task_10, task_11, task_12, task_13)
VALUES
-- PHYSICS (12 chapters)
('42f06757-09d7-409b-9a3d-4ff7bdcc2ce9', '1: FORCE', 1, 'ICSE 10', 'TEXTBOOK READING', 'TEXTBOOK SOLVED EXAMPLES', 'BOOK BACK QUESTIONS', 'ALL LWS', 'DREAM 90 MCQ AND AR', 'DREAM 90 PP MCQ', 'DREAM 90 PP SUBJECTIVE', 'DREAM 90 SOLVED NUMERICALS', '', '', '', '', ''),
('42f06757-09d7-409b-9a3d-4ff7bdcc2ce9', '2: WORK, ENERGY & POWER', 2, 'ICSE 10', 'TEXTBOOK READING', 'TEXTBOOK SOLVED EXAMPLES', 'BOOK BACK QUESTIONS', 'ALL LWS', 'DREAM 90 MCQ AND AR', 'DREAM 90 PP MCQ', 'DREAM 90 PP SUBJECTIVE', 'DREAM 90 SOLVED NUMERICALS', '', '', '', '', ''),
('42f06757-09d7-409b-9a3d-4ff7bdcc2ce9', '3: MACHINE', 3, 'ICSE 10', 'TEXTBOOK READING', 'TEXTBOOK SOLVED EXAMPLES', 'BOOK BACK QUESTIONS', 'PRACTISE PULLEY DIAGRAMS', 'ALL LWS', 'DREAM 90 MCQ AND AR', 'DREAM 90 PP MCQ', 'DREAM 90 PP SUBJECTIVE', 'DREAM 90 SOLVED NUMERICALS', '', '', '', '');

-- IMPORTANT: Due to SQL limits, you need to import via CSV file directly
-- Use Supabase UI: Table Editor → chapters → Insert → Upload CSV
-- CSV FILE: ICSE10_chapters_with_13_tasks.csv

-- After importing, verify the data:
SELECT
  subject_id,
  title as chapter_name,
  order_index,
  batch,
  task_1, task_2, task_3, task_4, task_5
FROM chapters
WHERE batch = 'ICSE 10'
LIMIT 10;
