-- ========================================================================
-- TEACHER SETUP SQL SCRIPT (FINAL - WITH UUIDs)
-- ========================================================================
-- Login: teacher_{batch_name}
-- Password: teacher@1234
-- ========================================================================

-- ========================================================================
-- STEP 1: Add missing columns to profiles table
-- ========================================================================

ALTER TABLE profiles ADD COLUMN IF NOT EXISTS username VARCHAR(255) UNIQUE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS batch VARCHAR(255);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS role VARCHAR(255);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;


-- ========================================================================
-- STEP 2: Insert 6 batch-level teacher logins with UUIDs
-- ========================================================================
-- Using generated UUIDs for each teacher

INSERT INTO profiles (id, username, name, email, role, batch, is_active, created_at, updated_at)
VALUES
  (gen_random_uuid(), 'teacher_icse8', 'ICSE 8', 'teacher.icse8@school.local', 'teacher', 'ICSE 8', true, NOW(), NOW()),
  (gen_random_uuid(), 'teacher_icse9', 'ICSE 9', 'teacher.icse9@school.local', 'teacher', 'ICSE 9', true, NOW(), NOW()),
  (gen_random_uuid(), 'teacher_icse10', 'ICSE 10', 'teacher.icse10@school.local', 'teacher', 'ICSE 10', true, NOW(), NOW()),
  (gen_random_uuid(), 'teacher_cbse8', 'CBSE 8', 'teacher.cbse8@school.local', 'teacher', 'CBSE 8', true, NOW(), NOW()),
  (gen_random_uuid(), 'teacher_cbse9', 'CBSE 9', 'teacher.cbse9@school.local', 'teacher', 'CBSE 9', true, NOW(), NOW()),
  (gen_random_uuid(), 'teacher_cbse10', 'CBSE 10', 'teacher.cbse10@school.local', 'teacher', 'CBSE 10', true, NOW(), NOW())
ON CONFLICT (username) DO NOTHING;


-- ========================================================================
-- STEP 3: Verify batch logins were created
-- ========================================================================
SELECT '✅ BATCH LOGINS CREATED:' AS status;
SELECT id, username, name, email, role, batch, is_active
FROM profiles
WHERE role = 'teacher'
ORDER BY batch;


-- ========================================================================
-- STEP 4: Enable Row Level Security (RLS)
-- ========================================================================

ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;


-- ========================================================================
-- STEP 5: Drop existing policies
-- ========================================================================

DROP POLICY IF EXISTS "Teachers can view students in their batch" ON students;
DROP POLICY IF EXISTS "Students can view only their own record" ON students;
DROP POLICY IF EXISTS "Teachers can view teacher profiles in their batch" ON profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;


-- ========================================================================
-- STEP 6: Create RLS policies
-- ========================================================================

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

CREATE POLICY "Students can view only their own record"
  ON students
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND profile_id = auth.uid()
  );

CREATE POLICY "Teachers can view teacher profiles in their batch"
  ON profiles
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND (role = 'teacher' OR id = auth.uid())
  );

CREATE POLICY "Users can view own profile"
  ON profiles
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND id = auth.uid()
  );


-- ========================================================================
-- STEP 7: Verify RLS setup
-- ========================================================================

SELECT '✅ RLS ENABLED:' AS check_type;
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE tablename IN ('students', 'profiles')
  AND schemaname = 'public';

SELECT '✅ POLICIES CREATED:' AS check_type;
SELECT tablename, policyname
FROM pg_policies
WHERE tablename IN ('students', 'profiles')
  AND schemaname = 'public'
ORDER BY tablename, policyname;


-- ========================================================================
-- STEP 8: FINAL - Show setup summary
-- ========================================================================

SELECT '
╔═══════════════════════════════════════════════════════════════╗
║           ✅ TEACHER LOGIN SETUP COMPLETE ✅                 ║
╚═══════════════════════════════════════════════════════════════╝

6 BATCH LOGINS CREATED IN DATABASE:
' AS summary;

SELECT username || ' / teacher@1234 → ' || batch AS login_info
FROM profiles
WHERE role = 'teacher'
ORDER BY batch;

SELECT '
═════════════════════════════════════════════════════════════════
NEXT: Create 6 Supabase Auth Users
═════════════════════════════════════════════════════════════════

Go to: Supabase Dashboard → Authentication → Users
Click "Add User" 6 times with these credentials:

1. Email: teacher.icse8@school.local   | Password: teacher@1234
2. Email: teacher.icse9@school.local   | Password: teacher@1234
3. Email: teacher.icse10@school.local  | Password: teacher@1234
4. Email: teacher.cbse8@school.local   | Password: teacher@1234
5. Email: teacher.cbse9@school.local   | Password: teacher@1234
6. Email: teacher.cbse10@school.local  | Password: teacher@1234

═════════════════════════════════════════════════════════════════
THEN: Test Login in Flutter App
═════════════════════════════════════════════════════════════════

1. Launch Flutter app
2. Select "Teacher" role
3. Login: teacher_icse8 / teacher@1234
4. Verify: See only ICSE 8 students
5. Logout & test another batch

═════════════════════════════════════════════════════════════════
' AS next_steps;
