-- ========================================================================
-- DIAGNOSTIC CHECK - See what columns exist
-- ========================================================================
-- Run this FIRST to check your profiles table structure
-- ========================================================================

-- CHECK 1: What columns exist in profiles table?
SELECT 'EXISTING COLUMNS IN PROFILES TABLE:' AS info;
SELECT
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'profiles'
  AND table_schema = 'public'
ORDER BY ordinal_position;


-- CHECK 2: Check if username column exists
SELECT 'DOES USERNAME COLUMN EXIST?' AS check;
SELECT
  CASE
    WHEN EXISTS(
      SELECT 1 FROM information_schema.columns
      WHERE table_name='profiles' AND column_name='username'
    ) THEN '✅ YES - username column exists'
    ELSE '❌ NO - username column missing'
  END as result;


-- CHECK 3: Check if batch column exists
SELECT 'DOES BATCH COLUMN EXIST?' AS check;
SELECT
  CASE
    WHEN EXISTS(
      SELECT 1 FROM information_schema.columns
      WHERE table_name='profiles' AND column_name='batch'
    ) THEN '✅ YES - batch column exists'
    ELSE '❌ NO - batch column missing'
  END as result;


-- CHECK 4: Check if role column exists
SELECT 'DOES ROLE COLUMN EXIST?' AS check;
SELECT
  CASE
    WHEN EXISTS(
      SELECT 1 FROM information_schema.columns
      WHERE table_name='profiles' AND column_name='role'
    ) THEN '✅ YES - role column exists'
    ELSE '❌ NO - role column missing'
  END as result;


-- CHECK 5: Check if is_active column exists
SELECT 'DOES IS_ACTIVE COLUMN EXIST?' AS check;
SELECT
  CASE
    WHEN EXISTS(
      SELECT 1 FROM information_schema.columns
      WHERE table_name='profiles' AND column_name='is_active'
    ) THEN '✅ YES - is_active column exists'
    ELSE '❌ NO - is_active column missing'
  END as result;


-- CHECK 6: Check if created_at column exists
SELECT 'DOES CREATED_AT COLUMN EXIST?' AS check;
SELECT
  CASE
    WHEN EXISTS(
      SELECT 1 FROM information_schema.columns
      WHERE table_name='profiles' AND column_name='created_at'
    ) THEN '✅ YES - created_at column exists'
    ELSE '❌ NO - created_at column missing'
  END as result;


-- CHECK 7: Check existing auth users
SELECT 'EXISTING AUTH USERS:' AS check;
SELECT COUNT(*) as total_auth_users FROM auth.users;
SELECT email FROM auth.users WHERE email LIKE '%teacher%' ORDER BY email;


-- CHECK 8: Show current profiles data
SELECT 'SAMPLE PROFILES DATA (first 3):' AS check;
SELECT * FROM profiles LIMIT 3;


SELECT '
════════════════════════════════════════════════════════════════
NEXT STEPS:
════════════════════════════════════════════════════════════════
1. Look at "EXISTING COLUMNS IN PROFILES TABLE" above
2. See which columns are missing (marked with ❌)
3. I will provide the correct SQL based on what you have
════════════════════════════════════════════════════════════════
' AS instruction;
