-- ========================================================================
-- TEACHER SETUP SQL SCRIPT (COMPLETE)
-- ========================================================================
-- This script adds missing columns and sets up teacher logins
-- Login: teacher_{batch_name}
-- Password: teacher@1234
-- ========================================================================

-- ========================================================================
-- STEP 1: Check existing columns in profiles table
-- ========================================================================
-- Run this first to see what columns exist
SELECT 'EXISTING COLUMNS IN PROFILES TABLE:' AS info;
SELECT column_name FROM information_schema.columns
WHERE table_name = 'profiles' AND table_schema = 'public'
ORDER BY ordinal_position;


-- ========================================================================
-- STEP 2: Add missing columns to profiles table
-- ========================================================================

-- Add username column (for teacher login)
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS username VARCHAR(255) UNIQUE;

-- Add batch column (for batch isolation)
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS batch VARCHAR(255);

-- Add role column (if missing)
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS role VARCHAR(255);

-- Add is_active column (if missing)
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- Add created_at column (if missing)
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT NOW();

-- Add updated_at column (if missing)
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();


-- ========================================================================
-- STEP 3: Verify columns were added
-- ========================================================================
SELECT 'COLUMNS AFTER UPDATE:' AS info;
SELECT column_name FROM information_schema.columns
WHERE table_name = 'profiles' AND table_schema = 'public'
ORDER BY ordinal_position;


-- ========================================================================
-- STEP 4: Insert 6 batch-level teacher logins
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
-- STEP 5: Verify batch logins were created
-- ========================================================================
SELECT '✅ BATCH LOGINS CREATED:' AS status;
SELECT username, name, email, role, batch, is_active
FROM profiles
WHERE role = 'teacher'
ORDER BY batch;


-- ========================================================================
-- STEP 6: Enable Row Level Security (RLS)
-- ========================================================================

ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;


-- ========================================================================
-- STEP 7: Drop existing policies (clean up)
-- ========================================================================

DROP POLICY IF EXISTS "Teachers can view students in their batch" ON students;
DROP POLICY IF EXISTS "Students can view only their own record" ON students;
DROP POLICY IF EXISTS "Teachers can view teacher profiles in their batch" ON profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;


-- ========================================================================
-- STEP 8: Create new RLS policies
-- ========================================================================

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

-- Policy 3: Teachers can view other teachers in their batch
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
-- STEP 9: Final Verification
-- ========================================================================

SELECT '✅ RLS ENABLED ON TABLES:' AS check_type;
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE tablename IN ('students', 'profiles')
  AND schemaname = 'public';

SELECT '✅ RLS POLICIES CREATED:' AS check_type;
SELECT tablename, policyname
FROM pg_policies
WHERE tablename IN ('students', 'profiles')
  AND schemaname = 'public'
ORDER BY tablename, policyname;

SELECT '✅ ALL BATCH LOGINS:' AS status;
SELECT
  username,
  name,
  email,
  role,
  batch
FROM profiles
WHERE role = 'teacher'
ORDER BY batch;

SELECT '✅✅✅ SETUP COMPLETE! ✅✅✅' AS result;
SELECT 'NEXT STEP: Create 6 Supabase Auth users (see below)' AS instruction;

SELECT '
===========================================
SUPABASE AUTH USERS TO CREATE:
===========================================
Email: teacher.icse8@school.local      | Password: teacher@1234
Email: teacher.icse9@school.local      | Password: teacher@1234
Email: teacher.icse10@school.local     | Password: teacher@1234
Email: teacher.cbse8@school.local      | Password: teacher@1234
Email: teacher.cbse9@school.local      | Password: teacher@1234
Email: teacher.cbse10@school.local     | Password: teacher@1234

Go to: Supabase Dashboard → Authentication → Users → Add User
Add each email/password pair above
===========================================
' AS next_steps;
