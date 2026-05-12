-- ========================================================================
-- FIX SUPER ADMIN RLS POLICIES
-- Allows Super Admins to view and manage all data
-- ========================================================================

-- 1. Enable RLS on all tables (just in case)
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE parents ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- 2. Drop existing Super Admin policies if they exist (to avoid duplicates)
DROP POLICY IF EXISTS "Super admins can do everything on students" ON students;
DROP POLICY IF EXISTS "Super admins can do everything on parents" ON parents;
DROP POLICY IF EXISTS "Super admins can do everything on profiles" ON profiles;

-- 3. Create Super Admin policies for 'students' table
CREATE POLICY "Super admins can do everything on students"
ON students
FOR ALL
TO authenticated
USING (
  (SELECT role FROM profiles WHERE id = auth.uid()) = 'super_admin'
)
WITH CHECK (
  (SELECT role FROM profiles WHERE id = auth.uid()) = 'super_admin'
);

-- 4. Create Super Admin policies for 'parents' table
CREATE POLICY "Super admins can do everything on parents"
ON parents
FOR ALL
TO authenticated
USING (
  (SELECT role FROM profiles WHERE id = auth.uid()) = 'super_admin'
)
WITH CHECK (
  (SELECT role FROM profiles WHERE id = auth.uid()) = 'super_admin'
);

-- 5. Create Super Admin policies for 'profiles' table
CREATE POLICY "Super admins can do everything on profiles"
ON profiles
FOR ALL
TO authenticated
USING (
  (SELECT role FROM profiles WHERE id = auth.uid()) = 'super_admin'
)
WITH CHECK (
  (SELECT role FROM profiles WHERE id = auth.uid()) = 'super_admin'
);

-- 6. Verify current role for the logged in user
-- Run this in Supabase SQL Editor to check your own role:
-- SELECT id, email, role FROM profiles WHERE id = auth.uid();

SELECT '✅ Super Admin RLS Policies Created' AS status;
