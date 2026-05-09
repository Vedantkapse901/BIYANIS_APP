# 6 Teacher Logins - Simple Format

## 📋 Login Credentials

```
1. teacher_icse8   / teacher@1234
2. teacher_icse9   / teacher@1234
3. teacher_icse10  / teacher@1234
4. teacher_cbse8   / teacher@1234
5. teacher_cbse9   / teacher@1234
6. teacher_cbse10  / teacher@1234
```

---

## ⚡ STEP 1: Create 6 Auth Users

**Go to:** Supabase Dashboard → Authentication → Users

**Click "Add User" 6 times:**

```
1. teacher.icse8@school.local    / teacher@1234
2. teacher.icse9@school.local    / teacher@1234
3. teacher.icse10@school.local   / teacher@1234
4. teacher.cbse8@school.local    / teacher@1234
5. teacher.cbse9@school.local    / teacher@1234
6. teacher.cbse10@school.local   / teacher@1234
```

---

## ⚡ STEP 2: Link Profiles to Auth Users

**Go to:** Supabase Dashboard → SQL Editor

**Paste and execute:**

```sql
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

SELECT '✅ 6 TEACHER PROFILES CREATED' AS status;
SELECT username, name, email, batch FROM profiles WHERE role = 'teacher' ORDER BY batch;
```

---

## ⚡ STEP 3: Enable RLS & Batch Isolation

**Same SQL Editor, paste and execute:**

```sql
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Teachers can view students in their batch" ON students;
DROP POLICY IF EXISTS "Students can view only their own record" ON students;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;

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

SELECT '✅ RLS ENABLED & BATCH ISOLATION ACTIVE' AS status;
```

---

## ⚡ STEP 4: Test Each Login

1. **Launch Flutter app**
2. **Select "Teacher"**
3. **Test each login:**

```
Login: teacher_icse8 / teacher@1234 → See only ICSE 8 students ✅
Login: teacher_cbse9 / teacher@1234 → See only CBSE 9 students ✅
Login: teacher_icse10 / teacher@1234 → See only ICSE 10 students ✅
...
```

---

## ✅ Complete!

All 6 batches configured with batch isolation. Each login sees only their batch students.

```
teacher_icse8   → ICSE 8 students only
teacher_icse9   → ICSE 9 students only
teacher_icse10  → ICSE 10 students only
teacher_cbse8   → CBSE 8 students only
teacher_cbse9   → CBSE 9 students only
teacher_cbse10  → CBSE 10 students only
```

🚀 **Ready to deploy!**
