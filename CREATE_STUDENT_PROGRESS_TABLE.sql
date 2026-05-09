-- ========================================================================
-- CREATE STUDENT PROGRESS TABLE
-- ========================================================================
-- Tracks which tasks each student has completed
-- Saves progress persistently to database
-- ========================================================================

-- STEP 1: Create student_progress table
CREATE TABLE IF NOT EXISTS student_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL,
  subject_id INTEGER NOT NULL,
  chapter_id INTEGER NOT NULL,
  task_id INTEGER NOT NULL,
  is_completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  -- Foreign key to students table
  CONSTRAINT fk_student_progress_student
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,

  -- Unique constraint: one record per student per task
  CONSTRAINT uk_student_task_unique
    UNIQUE (student_id, chapter_id, task_id)
);

SELECT '✅ STEP 1: student_progress table created' AS status;


-- STEP 2: Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_student_progress_student_id
  ON student_progress(student_id);

CREATE INDEX IF NOT EXISTS idx_student_progress_chapter_id
  ON student_progress(chapter_id);

CREATE INDEX IF NOT EXISTS idx_student_progress_is_completed
  ON student_progress(is_completed);

SELECT '✅ STEP 2: Indexes created' AS status;


-- STEP 3: Enable RLS on student_progress table
ALTER TABLE student_progress ENABLE ROW LEVEL SECURITY;

SELECT '✅ STEP 3: RLS enabled' AS status;


-- STEP 4: Create RLS Policies

-- Drop old policies if they exist
DROP POLICY IF EXISTS "Students can view their own progress" ON student_progress;
DROP POLICY IF EXISTS "Students can update their own progress" ON student_progress;
DROP POLICY IF EXISTS "Teachers can view student progress in their batch" ON student_progress;

-- Policy 1: Students can view their own progress
CREATE POLICY "Students can view their own progress"
  ON student_progress
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND student_id = (
      SELECT id FROM students WHERE profile_id = auth.uid()
    )
  );

-- Policy 2: Students can insert/update their own progress
CREATE POLICY "Students can update their own progress"
  ON student_progress
  FOR INSERT
  WITH CHECK (
    student_id = (
      SELECT id FROM students WHERE profile_id = auth.uid()
    )
  );

-- Policy 3: Students can update their own progress
CREATE POLICY "Students can update own progress records"
  ON student_progress
  FOR UPDATE
  USING (
    student_id = (
      SELECT id FROM students WHERE profile_id = auth.uid()
    )
  );

-- Policy 4: Teachers can view progress of students in their batch
CREATE POLICY "Teachers can view student progress in their batch"
  ON student_progress
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND (SELECT batch FROM students WHERE id = student_id) = (
      SELECT batch FROM profiles WHERE id = auth.uid() AND role = 'teacher'
    )
  );

SELECT '✅ STEP 4: RLS Policies created' AS status;


-- STEP 5: Verify setup
SELECT '✅ FINAL VERIFICATION' AS check_type;

-- Check table exists
SELECT 'student_progress table' as table_name, COUNT(*) as row_count
FROM information_schema.tables
WHERE table_name = 'student_progress';

-- Check columns
SELECT 'Columns in student_progress:' AS info;
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'student_progress'
ORDER BY ordinal_position;

-- Check RLS is enabled
SELECT 'RLS Status:' AS check;
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE tablename = 'student_progress'
AND schemaname = 'public';

-- Check policies
SELECT 'RLS Policies:' AS check;
SELECT policyname
FROM pg_policies
WHERE tablename = 'student_progress'
AND schemaname = 'public'
ORDER BY policyname;

SELECT '
╔════════════════════════════════════════════════════════════════╗
║           ✅ STUDENT PROGRESS TABLE READY                      ║
╚════════════════════════════════════════════════════════════════╝

TABLE: student_progress
COLUMNS:
  - id (UUID primary key)
  - student_id (links to students)
  - subject_id, chapter_id, task_id (track which task)
  - is_completed (boolean - true when completed)
  - completed_at (timestamp when completed)
  - created_at, updated_at (timestamps)

PRIVACY:
  ✅ Students see only their own progress
  ✅ Students can update their own progress
  ✅ Teachers see progress of students in their batch
  ✅ Other students cannot see this data

USAGE:
  1. Student marks task complete → INSERT into student_progress
  2. Next app open → SELECT from student_progress → Show progress
  3. Teacher views student → SELECT progress → Show what completed

Next: Update StudentDashboard & TeacherDashboard code
' AS complete;
