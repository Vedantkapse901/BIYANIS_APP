-- ========================================================================
-- CREATE STUDENT PROGRESS TABLE (FINAL - NO CONSTRAINTS)
-- ========================================================================

-- STEP 1: Create simple progress table
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

SELECT '✅ STEP 1: Table created' AS status;


-- STEP 2: Create indexes
CREATE INDEX IF NOT EXISTS idx_student_progress_student_id
  ON student_progress(student_id);

CREATE INDEX IF NOT EXISTS idx_student_progress_student_chapter_task
  ON student_progress(student_id, chapter_id, task_id);

SELECT '✅ STEP 2: Indexes created' AS status;


-- STEP 3: Enable RLS
ALTER TABLE student_progress ENABLE ROW LEVEL SECURITY;

SELECT '✅ STEP 3: RLS enabled' AS status;


-- STEP 4: Create RLS policies
DROP POLICY IF EXISTS "Students can view their own progress" ON student_progress;
DROP POLICY IF EXISTS "Students can insert own progress" ON student_progress;
DROP POLICY IF EXISTS "Students can update own progress" ON student_progress;
DROP POLICY IF EXISTS "Teachers can view student progress in their batch" ON student_progress;

-- Students can view their own progress
CREATE POLICY "Students can view their own progress"
  ON student_progress
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND student_id IN (
      SELECT id FROM students WHERE profile_id = auth.uid()
    )
  );

-- Students can insert progress
CREATE POLICY "Students can insert own progress"
  ON student_progress
  FOR INSERT
  WITH CHECK (
    student_id IN (
      SELECT id FROM students WHERE profile_id = auth.uid()
    )
  );

-- Students can update progress
CREATE POLICY "Students can update own progress"
  ON student_progress
  FOR UPDATE
  USING (
    student_id IN (
      SELECT id FROM students WHERE profile_id = auth.uid()
    )
  );

-- Teachers can view student progress
CREATE POLICY "Teachers can view student progress in their batch"
  ON student_progress
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND (SELECT batch FROM students WHERE id = student_id LIMIT 1) = (
      SELECT batch FROM profiles WHERE id = auth.uid() AND role = 'teacher' LIMIT 1
    )
  );

SELECT '✅ STEP 4: RLS policies created' AS status;


-- STEP 5: Verify
SELECT '
╔════════════════════════════════════════════════════════════════╗
║           ✅ PROGRESS TABLE READY                              ║
╚════════════════════════════════════════════════════════════════╝

Table: student_progress
Columns: id, student_id, subject_id, chapter_id, task_id, is_completed, completed_at, created_at, updated_at

RLS: ✅ Enabled
Policies: ✅ Student & Teacher access configured
Indexes: ✅ For fast queries

Ready to use!
' AS complete;
