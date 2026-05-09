-- ============================================
-- FIX: Check and Update student_progress Table
-- ============================================

-- Step 1: Check current schema
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'student_progress'
ORDER BY ordinal_position;

-- Step 2: Check what columns exist
-- Run these one by one to see which exist:

-- Check if chapter_id exists
SELECT COUNT(*) as has_chapter_id FROM information_schema.columns
WHERE table_name = 'student_progress' AND column_name = 'chapter_id';

-- Check if task_id exists
SELECT COUNT(*) as has_task_id FROM information_schema.columns
WHERE table_name = 'student_progress' AND column_name = 'task_id';

-- Check all columns
SELECT * FROM student_progress LIMIT 1;

-- ============================================
-- OPTION A: If you want to keep chapter_id + task_id (Recommended)
-- ============================================

-- Make sure both columns exist:
ALTER TABLE student_progress
ADD COLUMN IF NOT EXISTS chapter_id UUID,
ADD COLUMN IF NOT EXISTS task_id TEXT;

-- Update RLS policy to allow student progress tracking
ALTER TABLE student_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can view their own progress"
  ON student_progress FOR SELECT
  USING (auth.uid()::text = (SELECT id FROM students WHERE id = student_id)::text);

CREATE POLICY "Students can insert their own progress"
  ON student_progress FOR INSERT
  WITH CHECK (auth.uid()::text = (SELECT id FROM students WHERE id = student_id)::text);

CREATE POLICY "Students can update their own progress"
  ON student_progress FOR UPDATE
  USING (auth.uid()::text = (SELECT id FROM students WHERE id = student_id)::text);

-- ============================================
-- OPTION B: If table only has task_id (Simpler)
-- ============================================

-- Run this to verify the simplified schema works:
INSERT INTO student_progress (student_id, task_id, is_completed, completed_at)
VALUES (
  '18ea2b88-2bce-44b3-a2d6-b6be8ff814ce'::uuid,
  'chapterId_task_1'::text,
  true,
  NOW()
)
ON CONFLICT (student_id, task_id) DO UPDATE
SET is_completed = true, completed_at = NOW();

-- ============================================
-- OPTION C: If you want chapter-based tracking
-- ============================================

-- Create a simpler table for chapter completion:
CREATE TABLE IF NOT EXISTS chapter_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id),
  chapter_id UUID NOT NULL REFERENCES chapters(id),
  completed_task_count INT DEFAULT 0,
  is_completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMP DEFAULT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(student_id, chapter_id)
);

-- ============================================
-- VERIFICATION
-- ============================================

-- Check current data
SELECT COUNT(*) as total_progress_records FROM student_progress;

-- Check student progress
SELECT student_id, COUNT(*) as completed_tasks
FROM student_progress
WHERE is_completed = true
GROUP BY student_id;

-- ============================================
-- RECOMMENDED STEPS
-- ============================================

-- 1. Run Step 1 to see current schema
-- 2. If chapter_id doesn't exist, run OPTION A
-- 3. If task_id doesn't exist, run OPTION B
-- 4. Test in app by marking a task complete
-- 5. Verify with final SELECT queries
