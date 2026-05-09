/*
COMPLETE MIGRATION: Tasks embedded in Chapters table
This script:
1. Alters chapters table schema to support TEXT order_index and task columns
2. Backups old data
3. Imports ICSE 10 chapters with embedded tasks
4. Verifies the migration
*/

-- Step 1: Create backup of existing chapters and tasks
CREATE TABLE IF NOT EXISTS chapters_backup_pre_migration AS
SELECT * FROM chapters;

CREATE TABLE IF NOT EXISTS tasks_backup_pre_migration AS
SELECT * FROM tasks;

SELECT COUNT(*) as chapters_backed_up FROM chapters_backup_pre_migration;
SELECT COUNT(*) as tasks_backed_up FROM tasks_backup_pre_migration;

-- Step 2: Alter chapters table to support new schema
-- Change order_index from INTEGER to TEXT to support values like "3A", "3B"
ALTER TABLE chapters
ALTER COLUMN order_index TYPE TEXT USING order_index::text;

-- Add new columns if they don't exist
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

-- Verify schema changes
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'chapters'
ORDER BY ordinal_position;

-- Step 3: Delete old ICSE 10 data if it exists (to avoid duplicates)
-- This removes all ICSE 10 chapters so we can import fresh
DELETE FROM chapters WHERE batch = 'ICSE 10';

SELECT COUNT(*) as remaining_icse10_chapters FROM chapters WHERE batch = 'ICSE 10';
SELECT COUNT(*) as total_chapters_after_delete FROM chapters;

-- Step 4: Import ICSE 10 chapters with embedded tasks
-- Copy from CSV (you'll paste the CSV data below or use Supabase UI)
-- Using INSERT with VALUES for manual import:

INSERT INTO chapters (subject_id, title, order_index, batch, task_1, task_2, task_3, task_4, task_5, task_6, task_7, task_8, task_9, task_10, task_11, task_12, task_13, created_at, updated_at)
VALUES
-- PHYSICS (12 chapters)
('42f06757-09d7-409b-9a3d-4ff7bdcc2ce9', 'FORCE', '1', 'ICSE 10', 'TEXTBOOK READING', 'TEXTBOOK SOLVED EXAMPLES', 'BOOK BACK QUESTIONS', 'ALL LWS', 'DREAM 90 MCQ AND AR', 'DREAM 90 PP MCQ', 'DREAM 90 PP SUBJECTIVE', 'DREAM 90 SOLVED NUMERICALS', '', '', '', '', '', NOW(), NOW()),
('42f06757-09d7-409b-9a3d-4ff7bdcc2ce9', 'WORK, ENERGY & POWER', '2', 'ICSE 10', 'TEXTBOOK READING', 'TEXTBOOK SOLVED EXAMPLES', 'BOOK BACK QUESTIONS', 'ALL LWS', 'DREAM 90 MCQ AND AR', 'DREAM 90 PP MCQ', 'DREAM 90 PP SUBJECTIVE', 'DREAM 90 SOLVED NUMERICALS', '', '', '', '', '', NOW(), NOW()),
('42f06757-09d7-409b-9a3d-4ff7bdcc2ce9', 'MACHINE', '3', 'ICSE 10', 'TEXTBOOK READING', 'TEXTBOOK SOLVED EXAMPLES', 'BOOK BACK QUESTIONS', 'PRACTISE PULLEY DIAGRAMS', 'ALL LWS', 'DREAM 90 MCQ AND AR', 'DREAM 90 PP MCQ', 'DREAM 90 PP SUBJECTIVE', 'DREAM 90 SOLVED NUMERICALS', '', '', '', '', NOW(), NOW()),
('42f06757-09d7-409b-9a3d-4ff7bdcc2ce9', 'REFRACTION OF LIGHT AT PLANE SURFACE', '4', 'ICSE 10', 'TEXTBOOK READING', 'WRITE ALL FACTORS', 'TEXTBOOK SOLVED EXAMPLES', 'BOOK BACK QUESTIONS', 'PRACTISE ALL DIAGRAMS', 'ALL LWS', 'DREAM 90 MCQ AND AR', 'DREAM 90 PP MCQ', 'DREAM 90 PP SUBJECTIVE', '', '', '', '', NOW(), NOW());

-- Step 5: For remaining chapters, use Supabase UI or continue with manual INSERT
-- Since there are 146 chapters total, the best approach is to:
-- 1. Use Supabase Dashboard → Table Editor → chapters → Insert
-- 2. Click "Upload CSV" button
-- 3. Select ICSE10_chapters_TEXT_orderindex.csv
-- 4. Map columns:
--    - subject_id → subject_id
--    - chapter_name → title
--    - order_index → order_index (TEXT)
--    - batch → batch
--    - task_1 to task_13 → task_1 to task_13

-- Alternative: If using SQL, paste the generated INSERT statements from the Python script

-- Step 6: Verification after import
SELECT
  COUNT(*) as total_icse10_chapters,
  COUNT(DISTINCT subject_id) as subjects_with_icse10,
  MIN(CAST(order_index AS INTEGER)) as min_order,
  MAX(CAST(order_index AS INTEGER)) as max_order
FROM chapters
WHERE batch = 'ICSE 10';

-- Show sample chapters with tasks
SELECT
  subject_id,
  title,
  order_index,
  batch,
  ARRAY[task_1, task_2, task_3, task_4, task_5, task_6, task_7, task_8, task_9, task_10, task_11, task_12, task_13] as tasks
FROM chapters
WHERE batch = 'ICSE 10'
LIMIT 5;

-- Verify all 13 task columns exist and have data
SELECT
  COUNT(*) FILTER (WHERE task_1 IS NOT NULL AND task_1 != '') as chapters_with_task_1,
  COUNT(*) FILTER (WHERE task_2 IS NOT NULL AND task_2 != '') as chapters_with_task_2,
  COUNT(*) FILTER (WHERE task_3 IS NOT NULL AND task_3 != '') as chapters_with_task_3,
  COUNT(*) FILTER (WHERE task_4 IS NOT NULL AND task_4 != '') as chapters_with_task_4,
  COUNT(*) FILTER (WHERE task_5 IS NOT NULL AND task_5 != '') as chapters_with_task_5,
  COUNT(*) FILTER (WHERE task_6 IS NOT NULL AND task_6 != '') as chapters_with_task_6,
  COUNT(*) FILTER (WHERE task_7 IS NOT NULL AND task_7 != '') as chapters_with_task_7,
  COUNT(*) FILTER (WHERE task_8 IS NOT NULL AND task_8 != '') as chapters_with_task_8,
  COUNT(*) FILTER (WHERE task_9 IS NOT NULL AND task_9 != '') as chapters_with_task_9,
  COUNT(*) FILTER (WHERE task_10 IS NOT NULL AND task_10 != '') as chapters_with_task_10,
  COUNT(*) FILTER (WHERE task_11 IS NOT NULL AND task_11 != '') as chapters_with_task_11,
  COUNT(*) FILTER (WHERE task_12 IS NOT NULL AND task_12 != '') as chapters_with_task_12,
  COUNT(*) FILTER (WHERE task_13 IS NOT NULL AND task_13 != '') as chapters_with_task_13
FROM chapters
WHERE batch = 'ICSE 10';

-- Step 7: Optional - Drop old tasks table after verification
-- DO NOT RUN YET - only after verifying import is successful
-- DROP TABLE IF EXISTS tasks CASCADE;

-- Final check
SELECT
  'Chapters' as table_name,
  COUNT(*) as row_count
FROM chapters
WHERE batch = 'ICSE 10'
UNION ALL
SELECT
  'Tasks (old table)',
  COUNT(*)
FROM tasks;
