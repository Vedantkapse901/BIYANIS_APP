-- ========================================================================
-- TEACHER SETUP SQL SCRIPT
-- ========================================================================
-- Run these queries in your Supabase SQL Editor
-- Database: student_logbook
--
-- LOGIN CREDENTIALS (SIMPLIFIED):
-- Username: teacher_{batch_name}
-- Password: teacher@1234 (SAME FOR ALL)
-- ========================================================================

-- ========================================================================
-- STEP 1: Ensure 'username' column exists in profiles table
-- ========================================================================
-- Check if column exists, if not add it
-- Uncomment and run if you get "column username not found" error
-- ALTER TABLE profiles ADD COLUMN username VARCHAR(255) UNIQUE;


-- ========================================================================
-- STEP 2: Insert 6 batch-level teacher logins
-- ========================================================================
-- Each batch has ONE shared login that all teachers use
-- All use SAME PASSWORD: teacher@1234
-- For example: All 10 teachers in ICSE 8 use "teacher_icse8" + "teacher@1234"

INSERT INTO profiles (username, name, email, role, batch, is_active, created_at, updated_at)
VALUES
  ('teacher_icse8', 'ICSE 8', 'teacher.icse8@school.local', 'teacher', 'ICSE 8', true, NOW(), NOW()),
  ('teacher_icse9', 'ICSE 9', 'teacher.icse9@school.local', 'teacher', 'ICSE 9', true, NOW(), NOW()),
  ('teacher_icse10', 'ICSE 10', 'teacher.icse10@school.local', 'teacher', 'ICSE 10', true, NOW(), NOW()),
  ('teacher_cbse8', 'CBSE 8', 'teacher.cbse8@school.local', 'teacher', 'CBSE 8', true, NOW(), NOW()),
  ('teacher_cbse9', 'CBSE 9', 'teacher.cbse9@school.local', 'teacher', 'CBSE 9', true, NOW(), NOW()),
  ('teacher_cbse10', 'CBSE 10', 'teacher.cbse10@school.local', 'teacher', 'CBSE 10', true, NOW(), NOW())
ON CONFLICT (username) DO NOTHING;

-- Verify batch logins were inserted
SELECT * FROM profiles WHERE role = 'teacher' ORDER BY batch;


-- ========================================================================
-- STEP 3: Enable Row Level Security (RLS)
-- ========================================================================

-- Enable RLS on students table
ALTER TABLE students ENABLE ROW LEVEL SECURITY;

-- Enable RLS on profiles table
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;


-- ========================================================================
-- STEP 4: Create RLS Policies for Batch Isolation
-- ========================================================================

-- DROP existing policies if they exist (uncomment if needed)
-- DROP POLICY IF EXISTS "Teachers can view students in their batch" ON students;
-- DROP POLICY IF EXISTS "Students can view only their own record" ON students;
-- DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
-- DROP POLICY IF EXISTS "Teachers can view teacher profiles" ON profiles;


-- Policy 1: Teachers can only see students in their batch
CREATE POLICY "Teachers can view students in their batch"
  ON students
  FOR SELECT
  USING (
    -- Check if user is authenticated
    auth.uid() IS NOT NULL
    AND (
      -- Get the batch of the current teacher and compare with student batch
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

-- Policy 3: Teachers can view other teachers (for admin display)
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
-- STEP 5: Verify Setup
-- ========================================================================

-- Check that all 6 batch teachers were created
SELECT '✅ BATCH LOGINS CREATED:' AS check_type;
SELECT username, name, email, batch FROM profiles WHERE role = 'teacher' ORDER BY batch;

-- Check RLS is enabled
SELECT '✅ RLS STATUS:' AS check_type;
SELECT schemaname, tablename, rowsecurity FROM pg_tables
WHERE tablename IN ('students', 'profiles') AND schemaname = 'public';

-- Check policies are created
SELECT '✅ RLS POLICIES CREATED:' AS check_type;
SELECT tablename, policyname, permissive FROM pg_policies
WHERE tablename IN ('students', 'profiles') AND schemaname = 'public'
ORDER BY tablename, policyname;
