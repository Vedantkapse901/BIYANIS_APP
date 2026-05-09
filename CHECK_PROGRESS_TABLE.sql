-- ========================================================================
-- CHECK STUDENT_PROGRESS TABLE STRUCTURE
-- ========================================================================
-- Run this FIRST to see what exists
-- ========================================================================

-- CHECK 1: Does student_progress table exist?
SELECT 'DOES student_progress TABLE EXIST?' AS check;
SELECT
  CASE
    WHEN EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'student_progress')
    THEN '✅ YES - Table exists'
    ELSE '❌ NO - Table does not exist (need to create)'
  END as result;


-- CHECK 2: If it exists, what columns does it have?
SELECT 'COLUMNS IN student_progress TABLE:' AS check;
SELECT
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'student_progress'
  AND table_schema = 'public'
ORDER BY ordinal_position;


-- CHECK 3: How many rows in student_progress?
SELECT 'ROW COUNT:' AS check;
SELECT COUNT(*) as total_rows FROM student_progress;


-- CHECK 4: Check RLS status
SELECT 'RLS STATUS:' AS check;
SELECT
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables
WHERE tablename = 'student_progress'
  AND schemaname = 'public';


-- CHECK 5: Check existing policies
SELECT 'EXISTING RLS POLICIES:' AS check;
SELECT
  policyname,
  permissive,
  cmd
FROM pg_policies
WHERE tablename = 'student_progress'
  AND schemaname = 'public'
ORDER BY policyname;


-- CHECK 6: Show sample data if exists
SELECT 'SAMPLE DATA (first 3 rows):' AS check;
SELECT * FROM student_progress LIMIT 3;


SELECT '
════════════════════════════════════════════════════════════════
NEXT: Based on above results, I will create the correct SQL
════════════════════════════════════════════════════════════════
' AS instruction;
