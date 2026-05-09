-- ========================================================================
-- CREATE STUDENT PROGRESS TABLE (FIXED)
-- ========================================================================
-- Tracks which tasks each student has completed
-- Simplified version without strict foreign keys
-- ========================================================================

-- STEP 1: Create student_progress table (simplified)
CREATE TABLE IF NOT EXISTS student_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL,
  subject_id INTEGER NOT NULL,
  chapter_id INTEGER NOT NULL,
  task_id INTEGER NOT NULL,
  is_completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

SELECT '✅ STEP 1: student_progress table created' AS status;


-- STEP 2: Create unique constraint (one record per student per task)
ALTER TABLE student_progress
ADD CONSTRAINT uk_student_task_unique
  UNIQUE (student_id, chapter_id, task_id);

SELECT '✅ STEP 2: Unique constraint added' AS status;


-- STEP 3: Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_student_progress_student_id
  ON student_progress(student_id);

CREATE INDEX IF NOT EXISTS idx_student_progress_chapter_id
  ON student_progress(chapter_id);

CREATE INDEX IF NOT EXISTS idx_student_progress_is_completed
  ON student_progress(is_completed);

CREATE INDEX IF NOT EXISTS idx_student_progress_completed_at
  ON student_progress(completed_at);

SELECT '✅ STEP 3: Indexes created' AS status;


-- STEP 4: Enable RLS on student_progress table
ALTER TABLE student_progress ENABLE ROW LEVEL SECURITY;

SELECT '✅ STEP 4: RLS enabled' AS status;


-- STEP 5: Create RLS Policies

-- Drop old policies if they exist
DROP POLICY IF EXISTS "Students can view their own progress" ON student_progress;
DROP POLICY IF EXISTS "Students can update their own progress" ON student_progress;
DROP POLICY IF EXISTS "Students can insert own progress" ON student_progress;
DROP POLICY IF EXISTS "Teachers can view student progress in their batch" ON student_progress;

-- Policy 1: Students can view their own progress
CREATE POLICY "Students can view their own progress"
  ON student_progress
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND student_id = (
      SELECT id FROM students WHERE profile_id = auth.uid() LIMIT 1
    )
  );

-- Policy 2: Students can insert their own progress
CREATE POLICY "Students can insert own progress"
  ON student_progress
  FOR INSERT
  WITH CHECK (
    student_id = (
      SELECT id FROM students WHERE profile_id = auth.uid() LIMIT 1
    )
  );

-- Policy 3: Students can update their own progress
CREATE POLICY "Students can update own progress"
  ON student_progress
  FOR UPDATE
  USING (
    student_id = (
      SELECT id FROM students WHERE profile_id = auth.uid() LIMIT 1
    )
  );

-- Policy 4: Teachers can view progress of students in their batch
CREATE POLICY "Teachers can view student progress in their batch"
  ON student_progress
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND (SELECT batch FROM students WHERE id = student_id LIMIT 1) = (
      SELECT batch FROM profiles WHERE id = auth.uid() AND role = 'teacher' LIMIT 1
    )
  );

SELECT '✅ STEP 5: RLS Policies created' AS status;


-- STEP 6: Verify setup
SELECT '
╔════════════════════════════════════════════════════════════════╗
║           ✅ STUDENT PROGRESS TABLE READY                      ║
╚════════════════════════════════════════════════════════════════╝

TABLE: student_progress
COLUMNS:
  - id (UUID primary key)
  - student_id (UUID - links to students)
  - subject_id (INTEGER - subject number)
  - chapter_id (INTEGER - chapter number)
  - task_id (INTEGER - task number)
  - is_completed (boolean - true when completed)
  - completed_at (timestamp when completed)
  - created_at, updated_at (timestamps)

INDEXES:
  ✅ idx_student_progress_student_id
  ✅ idx_student_progress_chapter_id
  ✅ idx_student_progress_is_completed
  ✅ idx_student_progress_completed_at

PRIVACY (RLS):
  ✅ Students see only their own progress
  ✅ Students can update their own progress
  ✅ Teachers see progress of students in their batch
  ✅ Other students cannot see this data

USAGE:
  1. Student marks task complete
     → INSERT student_id, chapter_id, task_id, is_completed=true
  2. Load progress on app open
     → SELECT * FROM student_progress WHERE student_id = current_student
  3. Teacher views student
     → SELECT * FROM student_progress WHERE student_id = target_student
     → Show completed tasks

Ready to use!
' AS complete;
