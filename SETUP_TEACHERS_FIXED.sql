-- ========================================================================
-- TEACHER SETUP SQL SCRIPT (FIXED)
-- ========================================================================
-- Login: teacher_{batch_name}
-- Password: teacher@1234 (SAME FOR ALL)
-- ========================================================================

-- ========================================================================
-- STEP 1: Add 'username' column to profiles table (if it doesn't exist)
-- ========================================================================
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS username VARCHAR(255) UNIQUE;


-- ========================================================================
-- STEP 2: Insert 6 batch-level teacher logins
-- ========================================================================
INSERT INTO profiles (username, name, email, role, batch, is_active, created_at, updated_at)
VALUES
  ('teacher_icse8', 'ICSE 8', 'teacher.icse8@school.local', 'teacher', 'ICSE 8', true, NOW(), NOW()),
  ('teacher_icse9', 'ICSE 9', 'teacher.icse9@school.local', 'teacher', 'ICSE 9', true, NOW(), NOW()),
  ('teacher_icse10', 'ICSE 10', 'teacher.icse10@school.local', 'teacher', 'ICSE 10', true, NOW(), NOW()),
  ('teacher_cbse8', 'CBSE 8', 'teacher.cbse8@school.local', 'teacher', 'CBSE 8', true, NOW(), NOW()),
  ('teacher_cbse9', 'CBSE 9', 'teacher.cbse9@school.local', 'teacher', 'CBSE 9', true, NOW(), NOW()),
  ('teacher_cbse10', 'CBSE 10', 'teacher.cbse10@school.local', 'teacher', 'CBSE 10', true, NOW(), NOW())
ON CONFLICT (username) DO NOTHING;


-- ========================================================================
-- STEP 3: Verify 6 batch logins were created
-- ========================================================================
SELECT '✅ BATCH LOGINS CREATED:' AS status;
SELECT username, name, email, batch FROM profiles WHERE role = 'teacher' ORDER BY batch;


-- ========================================================================
-- STEP 4: Enable Row Level Security (RLS)
-- ========================================================================

ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;


-- ========================================================================
-- STEP 5: Drop existing policies (if any) and create new ones
-- ========================================================================

DROP POLICY IF EXISTS "Teachers can view students in their batch" ON students;
DROP POLICY IF EXISTS "Students can view only their own record" ON students;
DROP POLICY IF EXISTS "Teachers can view teacher profiles in their batch" ON profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;

-- Policy 1: Teachers can only see students in their batch
CREATE POLICY "Teachers can view students in their batch"
  ON students
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND (
      SELECT batch FROM profiles
      WHERE id = auth.uid() AND role = 'teacher'
    ) = batch
  );

-- Policy 2: Students can only see their own record
CREATE POLICY "Students can view only their own record"
  ON students
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND profile_id = auth.uid()
  );

-- Policy 3: Teachers can view other teachers
CREATE POLICY "Teachers can view teacher profiles in their batch"
  ON profiles
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND (role = 'teacher' OR id = auth.uid())
  );

-- Policy 4: Users can view their own profile
CREATE POLICY "Users can view own profile"
  ON profiles
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND id = auth.uid()
  );


-- ========================================================================
-- STEP 6: Final Verification
-- ========================================================================

SELECT '✅ RLS STATUS:' AS check_type;
SELECT schemaname, tablename, rowsecurity FROM pg_tables
WHERE tablename IN ('students', 'profiles') AND schemaname = 'public';

SELECT '✅ RLS POLICIES CREATED:' AS check_type;
SELECT tablename, policyname FROM pg_policies
WHERE tablename IN ('students', 'profiles') AND schemaname = 'public'
ORDER BY tablename, policyname;

SELECT '✅ SETUP COMPLETE!' AS status;
SELECT 'Next: Create 6 Supabase Auth users with emails and password teacher@1234' AS instruction;
