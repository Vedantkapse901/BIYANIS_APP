-- ========================================================================
-- FINAL SETUP - Link auth users to profiles & enable RLS
-- ========================================================================

-- STEP 1: Add missing columns
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS username VARCHAR(255) UNIQUE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS batch VARCHAR(255);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS role VARCHAR(255);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

SELECT '✅ COLUMNS ADDED' AS step1;

-- STEP 2: Link 6 auth users to profiles
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

SELECT '✅ 6 TEACHERS LINKED TO PROFILES' AS step2;
SELECT username, name, batch FROM profiles WHERE role = 'teacher' ORDER BY batch;

-- STEP 3: Enable RLS
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

SELECT '✅ RLS ENABLED' AS step3;

-- STEP 4: Drop old policies
DROP POLICY IF EXISTS "Teachers can view students in their batch" ON students;
DROP POLICY IF EXISTS "Students can view only their own record" ON students;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;

-- STEP 5: Create batch isolation policies
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

SELECT '✅ RLS POLICIES CREATED' AS step5;

-- FINAL: Show success
SELECT '
╔════════════════════════════════════════════════════════════════╗
║              ✅ SETUP COMPLETE - 6 TEACHERS READY              ║
╚════════════════════════════════════════════════════════════════╝

6 LOGIN CREDENTIALS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
teacher_icse8   / teacher@1234 → ICSE 8 students
teacher_icse9   / teacher@1234 → ICSE 9 students
teacher_icse10  / teacher@1234 → ICSE 10 students
teacher_cbse8   / teacher@1234 → CBSE 8 students
teacher_cbse9   / teacher@1234 → CBSE 9 students
teacher_cbse10  / teacher@1234 → CBSE 10 students
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NEXT: TEST LOGIN IN FLUTTER APP
1. Launch Flutter app
2. Select "Teacher" role
3. Login: teacher_icse8 / teacher@1234
4. Verify: See only ICSE 8 students ✅

DONE! 🚀
' AS complete;
