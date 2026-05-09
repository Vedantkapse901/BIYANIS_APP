-- ========================================================================
-- CREATE STUDENT_PROGRESS TABLE - SIMPLE & CLEAN
-- ========================================================================

-- Step 1: Create the table
CREATE TABLE student_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL,
  subject_id INTEGER,
  chapter_id INTEGER,
  task_id INTEGER,
  is_completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Step 2: Create indexes
CREATE INDEX idx_student_progress_student_id ON student_progress(student_id);
CREATE INDEX idx_student_progress_chapter ON student_progress(chapter_id);

-- Step 3: Enable RLS
ALTER TABLE student_progress ENABLE ROW LEVEL SECURITY;

-- Step 4: Create policies
CREATE POLICY "Students view own progress"
  ON student_progress FOR SELECT
  USING (student_id IN (SELECT id FROM students WHERE profile_id = auth.uid()));

CREATE POLICY "Students insert own progress"
  ON student_progress FOR INSERT
  WITH CHECK (student_id IN (SELECT id FROM students WHERE profile_id = auth.uid()));

CREATE POLICY "Students update own progress"
  ON student_progress FOR UPDATE
  USING (student_id IN (SELECT id FROM students WHERE profile_id = auth.uid()));

CREATE POLICY "Teachers view batch progress"
  ON student_progress FOR SELECT
  USING (
    (SELECT batch FROM students WHERE id = student_id) =
    (SELECT batch FROM profiles WHERE id = auth.uid() AND role = 'teacher')
  );

-- Verify
SELECT '✅ STUDENT_PROGRESS TABLE CREATED' AS status;
SELECT '✅ RLS ENABLED' AS security;
SELECT '✅ READY TO USE' AS result;
