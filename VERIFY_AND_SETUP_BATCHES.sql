-- ========================================================================
-- BATCH VERIFICATION & SETUP SQL
-- ========================================================================
-- This script verifies and confirms the 6 batch names in your database
-- Batches: ICSE 8, ICSE 9, ICSE 10, CBSE 8, CBSE 9, CBSE 10
-- ========================================================================

-- ========================================================================
-- STEP 1: Verify student batches in database
-- ========================================================================
-- Check what batches already exist in students table
SELECT 'CURRENT BATCHES IN STUDENTS TABLE:' AS info;
SELECT DISTINCT batch FROM students WHERE batch IS NOT NULL ORDER BY batch;

-- Count students per batch
SELECT 'STUDENT COUNT PER BATCH:' AS info;
SELECT batch, COUNT(*) as student_count FROM students GROUP BY batch ORDER BY batch;


-- ========================================================================
-- STEP 2: Confirm the 6 batches we will use
-- ========================================================================
-- These are the ONLY 6 batches that will have teacher logins
SELECT 'CONFIRMED 6 BATCHES FOR TEACHER LOGINS:' AS info;
SELECT 'ICSE 8' as batch UNION ALL
SELECT 'ICSE 9' UNION ALL
SELECT 'ICSE 10' UNION ALL
SELECT 'CBSE 8' UNION ALL
SELECT 'CBSE 9' UNION ALL
SELECT 'CBSE 10';


-- ========================================================================
-- STEP 3: Create/Verify the 6 batch login accounts in profiles table
-- ========================================================================
-- One login per batch - all teachers in that batch use this login

INSERT INTO profiles (username, name, email, role, batch, is_active, created_at, updated_at)
VALUES
  ('teacher_icse8', 'ICSE 8 (Batch Login)', 'teacher.icse8@school.local', 'teacher', 'ICSE 8', true, NOW(), NOW()),
  ('teacher_icse9', 'ICSE 9 (Batch Login)', 'teacher.icse9@school.local', 'teacher', 'ICSE 9', true, NOW(), NOW()),
  ('teacher_icse10', 'ICSE 10 (Batch Login)', 'teacher.icse10@school.local', 'teacher', 'ICSE 10', true, NOW(), NOW()),
  ('teacher_cbse8', 'CBSE 8 (Batch Login)', 'teacher.cbse8@school.local', 'teacher', 'CBSE 8', true, NOW(), NOW()),
  ('teacher_cbse9', 'CBSE 9 (Batch Login)', 'teacher.cbse9@school.local', 'teacher', 'CBSE 9', true, NOW(), NOW()),
  ('teacher_cbse10', 'CBSE 10 (Batch Login)', 'teacher.cbse10@school.local', 'teacher', 'CBSE 10', true, NOW(), NOW())
ON CONFLICT (username) DO UPDATE SET updated_at = NOW();


-- ========================================================================
-- STEP 4: Verify all 6 batch logins exist in database
-- ========================================================================
SELECT 'VERIFIED 6 BATCH LOGINS IN DATABASE:' AS info;
SELECT username, name, email, batch, is_active FROM profiles
WHERE role = 'teacher'
ORDER BY batch;


-- ========================================================================
-- STEP 5: Verify students exist for each batch
-- ========================================================================
SELECT 'STUDENTS PER BATCH (ALL MUST HAVE DATA):' AS info;
SELECT
  batch,
  COUNT(*) as total_students,
  COUNT(CASE WHEN name IS NOT NULL THEN 1 END) as with_names,
  COUNT(CASE WHEN profile_id IS NOT NULL THEN 1 END) as registered
FROM students
WHERE batch IN ('ICSE 8', 'ICSE 9', 'ICSE 10', 'CBSE 8', 'CBSE 9', 'CBSE 10')
GROUP BY batch
ORDER BY batch;


-- ========================================================================
-- STEP 6: Show the 6 login credentials for teachers
-- ========================================================================
SELECT 'LOGIN CREDENTIALS FOR TEACHERS - ONE PER BATCH:' AS info;
SELECT
  batch,
  username as login_username,
  'teacher_' || LOWER(REPLACE(batch, ' ', '')) || '_pwd123' as suggested_password,
  email as auth_email
FROM profiles
WHERE role = 'teacher'
ORDER BY batch;


-- ========================================================================
-- FINAL VERIFICATION
-- ========================================================================
SELECT '✅ SETUP COMPLETE - Next Steps:' AS status;
SELECT 'Step 1: Create 6 Supabase Auth users with emails and passwords from above' AS step1 UNION ALL
SELECT 'Step 2: Test login with each batch account' AS step2 UNION ALL
SELECT 'Step 3: Verify RLS policies are working (batch isolation)' AS step3 UNION ALL
SELECT 'Step 4: Give teachers their batch login credentials' AS step4;
