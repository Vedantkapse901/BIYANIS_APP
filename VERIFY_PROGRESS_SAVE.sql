-- ============================================
-- VERIFY PROGRESS DATA IN DATABASE
-- ============================================

-- Step 1: Check if student_progress table exists and has data
SELECT
  'student_progress' as table_name,
  COUNT(*) as total_records
FROM student_progress;

-- Step 2: Show table structure
SELECT
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'student_progress'
ORDER BY ordinal_position;

-- Step 3: Show recent records (all columns)
SELECT * FROM student_progress
ORDER BY created_at DESC
LIMIT 10;

-- Step 4: Show only completed tasks
SELECT
  student_id,
  chapter_id,
  task_id,
  is_completed,
  completed_at
FROM student_progress
WHERE is_completed = true
LIMIT 10;

-- Step 5: Group by student to see progress
SELECT
  student_id,
  COUNT(*) as completed_task_count,
  COUNT(DISTINCT chapter_id) as chapters_with_progress
FROM student_progress
WHERE is_completed = true
GROUP BY student_id;

-- Step 6: Show chapter_id values (debug)
SELECT DISTINCT chapter_id, data_type
FROM student_progress
LIMIT 1;

-- Step 7: Check if columns are NULL
SELECT
  COUNT(*) as total,
  COUNT(CASE WHEN student_id IS NULL THEN 1 END) as null_student_id,
  COUNT(CASE WHEN chapter_id IS NULL THEN 1 END) as null_chapter_id,
  COUNT(CASE WHEN task_id IS NULL THEN 1 END) as null_task_id
FROM student_progress;
