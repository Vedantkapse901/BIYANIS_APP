-- ============================================
-- MIGRATE: student_progress Table
-- From: topic_id based tracking
-- To: chapter_id + task_id based tracking
-- ============================================

-- Step 1: Backup existing progress
CREATE TABLE student_progress_backup AS
SELECT * FROM student_progress;

SELECT COUNT(*) as backup_rows FROM student_progress_backup;

-- Step 2: Add new columns
ALTER TABLE student_progress
ADD COLUMN IF NOT EXISTS chapter_id UUID,
ADD COLUMN IF NOT EXISTS task_id TEXT;

-- Step 3: Drop topic_id (optional - comment out if you want to keep it)
-- ALTER TABLE student_progress DROP COLUMN topic_id;

-- Step 4: Verify new structure
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'student_progress'
ORDER BY ordinal_position;

-- Step 5: Test inserting a record with new schema
INSERT INTO student_progress (
  student_id,
  chapter_id,
  task_id,
  is_completed,
  completed_at
) VALUES (
  (SELECT id FROM students LIMIT 1),
  (SELECT id FROM chapters WHERE batch = 'ICSE 10' LIMIT 1),
  'test_task_1',
  true,
  NOW()
)
ON CONFLICT DO NOTHING;

-- Step 6: Verify insert worked
SELECT * FROM student_progress WHERE task_id = 'test_task_1' LIMIT 1;

-- Step 7: Check progress tracking
SELECT
  student_id,
  chapter_id,
  COUNT(*) as completed_tasks
FROM student_progress
WHERE is_completed = true AND chapter_id IS NOT NULL
GROUP BY student_id, chapter_id
LIMIT 10;
