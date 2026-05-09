-- ========================================================================
-- FINAL SETUP (FIXED) - Add batch to students, then link teachers
-- ========================================================================

-- STEP 1: Add batch column to students table (if missing)
ALTER TABLE students ADD COLUMN IF NOT EXISTS batch VARCHAR(255);

SELECT '✅ STEP 1: batch column added to students' AS status;

-- STEP 2: Add missing columns to profiles table
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS username VARCHAR(255) UNIQUE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS batch VARCHAR(255);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS role VARCHAR(255);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

SELECT '✅ STEP 2: columns added to profiles' AS status;

-- STEP 3: Link 6 auth users to profiles
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
  END,
  CASE au.email
    WHEN 'teacher.icse8@school.local' THEN 'ICSE 8'
    WHEN 'teacher.icse9@school.local' THEN 'ICSE 9'
    WHEN 'teacher.icse10@school.local' THEN 'ICSE 10'
    WHEN 'teacher.cbse8@school.local' THEN 'CBSE 8'
    WHEN 'teacher.cbse9@school.local' THEN 'CBSE 9'
    WHEN 'teacher.cbse10@school.local' THEN 'CBSE 10'
  END,
  au.email,
  'teacher',
  CASE au.email
    WHEN 'teacher.icse8@school.local' THEN 'ICSE 8'
    WHEN 'teacher.icse9@school.local' THEN 'ICSE 9'
    WHEN 'teacher.icse10@school.local' THEN 'ICSE 10'
    WHEN 'teacher.cbse8@school.local' THEN 'CBSE 8'
    WHEN 'teacher.cbse9@school.local' THEN 'CBSE 9'
    WHEN 'teacher.cbse10@school.local' THEN 'CBSE 10'
  END,
  true,
  NOW(),
  NOW()
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

SELECT '✅ STEP 3: 6 teachers linked' AS status;
SELECT username, batch FROM profiles WHERE role = 'teacher' ORDER BY batch;

-- STEP 4: Enable RLS
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

SELECT '✅ STEP 4: RLS enabled' AS status;

-- STEP 5: Drop old policies
DROP POLICY IF EXISTS "Teachers can view students in their batch" ON students;
DROP POLICY IF EXISTS "Students can view only their own record" ON students;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;

-- STEP 6: Create batch isolation policies
CREATE POLICY "Teachers can view students in their batch"
  ON students
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND (SELECT batch FROM profiles WHERE id = auth.uid() AND role = 'teacher') = batch
  );

CREATE POLICY "Students can view only their own record"
  ON students
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND profile_id = auth.uid()
  );

CREATE POLICY "Users can view own profile"
  ON profiles
  FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND id = auth.uid()
  );

SELECT '✅ STEP 6: RLS policies created' AS status;

-- FINAL VERIFICATION
SELECT '
╔════════════════════════════════════════════════════════════════╗
║              ✅ COMPLETE SETUP FINISHED                        ║
╚════════════════════════════════════════════════════════════════╝

6 TEACHER LOGINS READY:
teacher_icse8   / teacher@1234
teacher_icse9   / teacher@1234
teacher_icse10  / teacher@1234
teacher_cbse8   / teacher@1234
teacher_cbse9   / teacher@1234
teacher_cbse10  / teacher@1234

NEXT: TEST IN FLUTTER APP
1. Launch app
2. Select "Teacher"
3. Login: teacher_icse8 / teacher@1234
4. Should see only ICSE 8 students ✅
' AS complete;
