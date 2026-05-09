# ✅ Simple Teacher Setup - ONE Login Only

## 🎯 Single Teacher Login

```
Username: teacher_icse8
Password: teacher@1234
Batch:    ICSE 8
```

---

## ⚡ STEP 1: Create ONE Auth User

**Go to:** Supabase Dashboard → Authentication → Users

**Click "Add User":**
```
Email:    teacher.icse8@school.local
Password: teacher@1234
[Create User]
```

**Done with Step 1.**

---

## ⚡ STEP 2: Link Profile to Auth User

**Go to:** Supabase Dashboard → SQL Editor

**Paste and execute:**

```sql
-- Link teacher auth user to profile
INSERT INTO profiles (id, username, name, email, role, batch, is_active, created_at, updated_at)
SELECT 
  au.id,
  'teacher_icse8' as username,
  'ICSE 8' as name,
  au.email,
  'teacher' as role,
  'ICSE 8' as batch,
  true as is_active,
  NOW() as created_at,
  NOW() as updated_at
FROM auth.users au
WHERE au.email = 'teacher.icse8@school.local'
ON CONFLICT (id) DO NOTHING;

-- Verify
SELECT '✅ TEACHER PROFILE CREATED:' AS status;
SELECT id, username, name, email, role, batch FROM profiles WHERE username = 'teacher_icse8';
```

**Done with Step 2.**

---

## ⚡ STEP 3: Enable RLS (Batch Isolation)

**Same SQL Editor, paste and execute:**

```sql
-- Enable RLS
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Drop old policies
DROP POLICY IF EXISTS "Teachers can view students in their batch" ON students;
DROP POLICY IF EXISTS "Students can view only their own record" ON students;
DROP POLICY IF EXISTS "Teachers can view teacher profiles in their batch" ON profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;

-- Create batch isolation policies
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

-- Verify
SELECT '✅ RLS ENABLED AND POLICIES CREATED' AS status;
```

**Done with Step 3.**

---

## ⚡ STEP 4: Test Login

1. **Launch Flutter app**
2. **Select "Teacher" role**
3. **Login:**
   - Username: `teacher_icse8`
   - Password: `teacher@1234`
4. **Expected:**
   - Dashboard shows "ICSE 8" batch
   - Only ICSE 8 students visible
   - ✅ Success!

---

## 📋 Checklist

- [ ] Created auth user: teacher.icse8@school.local / teacher@1234
- [ ] Ran Step 2 SQL (link profile)
- [ ] Ran Step 3 SQL (enable RLS)
- [ ] Tested login in Flutter
- [ ] Verified only ICSE 8 students visible
- [ ] ✅ Done!

---

## 🚀 Next Steps (Optional)

- Want to add more batches? Just repeat steps 1-3 for other batches
- Want to change password? Edit in Supabase → Authentication → Users
- Want to add more teachers to ICSE 8? They all use same login: teacher_icse8 / teacher@1234
