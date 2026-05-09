# ✅ Teacher Setup - Correct Workflow

## 🔄 Two-Step Process

### STEP 1: Create Supabase Auth Users (FIRST)
### STEP 2: Link to Profiles in Database (SECOND)

---

## ⚡ STEP 1: Create Auth Users (in Supabase Dashboard)

**Go to:** Supabase Dashboard → Authentication → Users

**Click "Add User" 6 times:**

```
User 1:
  Email:    teacher.icse8@school.local
  Password: teacher@1234
  [Create User] ← Click

User 2:
  Email:    teacher.icse9@school.local
  Password: teacher@1234
  [Create User]

User 3:
  Email:    teacher.icse10@school.local
  Password: teacher@1234
  [Create User]

User 4:
  Email:    teacher.cbse8@school.local
  Password: teacher@1234
  [Create User]

User 5:
  Email:    teacher.cbse9@school.local
  Password: teacher@1234
  [Create User]

User 6:
  Email:    teacher.cbse10@school.local
  Password: teacher@1234
  [Create User]
```

**After creating each user, note the UUID shown (or you'll get it from next step)**

---

## ⚡ STEP 2: Run SQL to Link Profiles

**After creating the 6 auth users, run this SQL:**

Go to: **Supabase Dashboard → SQL Editor**

Paste and execute:

```sql
-- Link teacher auth users to profiles
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

-- Verify profiles were created
SELECT '✅ TEACHER PROFILES CREATED:' AS status;
SELECT id, username, name, email, role, batch FROM profiles WHERE role = 'teacher' ORDER BY batch;
```

---

## 🔒 Then Enable RLS (Optional - If Not Already Done)

```sql
-- Enable RLS
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Drop old policies
DROP POLICY IF EXISTS "Teachers can view students in their batch" ON students;
DROP POLICY IF EXISTS "Students can view only their own record" ON students;
DROP POLICY IF EXISTS "Teachers can view teacher profiles in their batch" ON profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;

-- Create new policies
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

-- Verify
SELECT '✅ RLS ENABLED' AS status;
```

---

## ✅ Final Checklist

- [ ] **STEP 1:** Created 6 Supabase Auth users in dashboard
- [ ] **STEP 2:** Ran SQL to link profiles
- [ ] **STEP 3:** Enabled RLS policies
- [ ] **STEP 4:** Test login with `teacher_icse8 / teacher@1234`
- [ ] **STEP 5:** Verify batch isolation (only ICSE 8 students visible)

---

## 🎯 Test Login

1. Launch Flutter app
2. Select "Teacher" role
3. Login: `teacher_icse8` / `teacher@1234`
4. Should see ICSE 8 students only ✅

Done! 🚀
