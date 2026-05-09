-- ========================================================================
-- COMPLETE TEACHER SETUP - 6 BATCHES
-- ========================================================================
-- Step 1: Add missing columns
-- Step 2: Create 6 auth users (manually in dashboard)
-- Step 3: Link profiles to auth users
-- Step 4: Enable RLS
-- ========================================================================

-- ========================================================================
-- STEP 1: ADD MISSING COLUMNS TO PROFILES TABLE
-- ========================================================================

ALTER TABLE profiles ADD COLUMN IF NOT EXISTS username VARCHAR(255) UNIQUE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS batch VARCHAR(255);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS role VARCHAR(255);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT NOW();
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();

SELECT '✅ STEP 1: COLUMNS ADDED' AS status;


-- ========================================================================
-- STEP 2: INSERT 6 TEACHER PROFILES (from existing auth users)
-- ========================================================================
-- This assumes you already created the 6 auth users in Supabase dashboard

INSERT INTO profiles (id, username, name, email, role, batch, is_active, created_at, updated_at)
SELECT
  au.id,
  CASE au.email
    WHEN 'teacher.icse8@school.local' THEN 'teacher_icse8'
    WHEN 'teacher.icse9@school.local' THEN 'teacher_icse9'
    WHEN 'teacher.icse10@school.local' THEN 'teacher_icse10'
    WHEN 'teacher.cbse8@school.local' THEN 'teacher_cbse8'
    WHEN 'teacher.cbse9@school.local' THEN 'teacher_cbse9'
    WHEN 'teacher.cbse10@school.local' THEN 'teacher_cbse10'
  END as username,
  CASE au.email
    WHEN 'teacher.icse8@school.local' THEN 'ICSE 8'
    WHEN 'teacher.icse9@school.local' THEN 'ICSE 9'
    WHEN 'teacher.icse10@school.local' THEN 'ICSE 10'
    WHEN 'teacher.cbse8@school.local' THEN 'CBSE 8'
    WHEN 'teacher.cbse9@school.local' THEN 'CBSE 9'
    WHEN 'teacher.cbse10@school.local' THEN 'CBSE 10'
  END as name,
  au.email,
  'teacher' as role,
  CASE au.email
    WHEN 'teacher.icse8@school.local' THEN 'ICSE 8'
    WHEN 'teacher.icse9@school.local' THEN 'ICSE 9'
    WHEN 'teacher.icse10@school.local' THEN 'ICSE 10'
    WHEN 'teacher.cbse8@school.local' THEN 'CBSE 8'
    WHEN 'teacher.cbse9@school.local' THEN 'CBSE 9'
    WHEN 'teacher.cbse10@school.local' THEN 'CBSE 10'
  END as batch,
  true as is_active,
  NOW() as created_at,
  NOW() as updated_at
FROM auth.users au
WHERE au.email IN (
  'teacher.icse8@school.local',
  'teacher.icse9@school.local',
  'teacher.icse10@school.local',
  'teacher.cbse8@school.local',
  'teacher.cbse9@school.local',
  'teacher.cbse10@school.local'
)
ON CONFLICT (id) DO NOTHING;

SELECT '✅ STEP 2: 6 TEACHER PROFILES CREATED' AS status;
SELECT username, name, email, role, batch FROM profiles WHERE role = 'teacher' ORDER BY batch;


-- ========================================================================
-- STEP 3: ENABLE ROW LEVEL SECURITY
-- ========================================================================

ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

SELECT '✅ STEP 3: RLS ENABLED' AS status;


-- ========================================================================
-- STEP 4: DROP OLD POLICIES (CLEAN UP)
-- ========================================================================

DROP POLICY IF EXISTS "Teachers can view students in their batch" ON students;
DROP POLICY IF EXISTS "Students can view only their own record" ON students;
DROP POLICY IF EXISTS "Teachers can view teacher profiles" ON profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;

SELECT '✅ STEP 4: OLD POLICIES REMOVED' AS status;


-- ========================================================================
-- STEP 5: CREATE NEW RLS POLICIES FOR BATCH ISOLATION
-- ========================================================================

-- Policy 1: Teachers can only see students in their batch
CREATE POLICY "Teachers can view students in their batch"
  ON students
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND (SELECT batch FROM profiles WHERE id = auth.uid() AND role = 'teacher') = batch
  );

-- Policy 2: Students can only see their own record
CREATE POLICY "Students can view only their own record"
  ON students
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND profile_id = auth.uid()
  );

-- Policy 3: Users can view their own profile
CREATE POLICY "Users can view own profile"
  ON profiles
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND id = auth.uid()
  );

SELECT '✅ STEP 5: RLS POLICIES CREATED' AS status;


-- ========================================================================
-- STEP 6: FINAL VERIFICATION
-- ========================================================================

SELECT '
╔════════════════════════════════════════════════════════════════╗
║        ✅ TEACHER SETUP COMPLETE - 6 BATCHES READY            ║
╚════════════════════════════════════════════════════════════════╝
' AS complete;

SELECT 'LOGIN IDS CREATED:' AS info;
SELECT
  row_number() OVER (ORDER BY batch) as "#",
  username,
  'teacher@1234' as password,
  email,
  batch
FROM profiles
WHERE role = 'teacher'
ORDER BY batch;

SELECT '
════════════════════════════════════════════════════════════════
NEXT: TEST LOGIN IN FLUTTER APP
════════════════════════════════════════════════════════════════
1. Launch Flutter app
2. Select "Teacher" role
3. Login: teacher_icse8 / teacher@1234
4. Verify: See only ICSE 8 students
5. Logout & test another batch

════════════════════════════════════════════════════════════════
ALL 6 LOGINS:
teacher_icse8   / teacher@1234 → ICSE 8 students
teacher_icse9   / teacher@1234 → ICSE 9 students
teacher_icse10  / teacher@1234 → ICSE 10 students
teacher_cbse8   / teacher@1234 → CBSE 8 students
teacher_cbse9   / teacher@1234 → CBSE 9 students
teacher_cbse10  / teacher@1234 → CBSE 10 students
════════════════════════════════════════════════════════════════
' AS summary;
