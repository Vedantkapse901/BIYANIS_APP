-- SIMPLE DIAGNOSTIC QUERIES
-- Copy and paste ONE QUERY AT A TIME into Supabase Studio SQL Editor

-- ============================================================
-- QUERY 1: Count how many tasks have BROKEN chapter_id
-- ============================================================
SELECT COUNT(*) as tasks_with_broken_chapter_id
FROM tasks t
LEFT JOIN chapters c ON t.chapter_id = c.id
WHERE c.id IS NULL;

-- Expected: 0 (if everything is fine)
-- If > 0: That's how many tasks are pointing to wrong chapter IDs

-- ============================================================
-- QUERY 2: Show what BROKEN tasks look like
-- ============================================================
SELECT
  t.id,
  t.chapter_id as WRONG_CHAPTER_ID,
  t.title as task_title,
  t.subject_id
FROM tasks t
LEFT JOIN chapters c ON t.chapter_id = c.id
WHERE c.id IS NULL
LIMIT 10;

-- This shows the tasks that are broken
-- Copy one of the WRONG_CHAPTER_ID values - you might need to fix these

-- ============================================================
-- QUERY 3: Show a sample of chapters (to see correct format)
-- ============================================================
SELECT
  id as CORRECT_CHAPTER_ID,
  title as chapter_title,
  subject_id
FROM chapters
LIMIT 10;

-- This shows what correct chapter IDs look like
-- Compare with the WRONG_CHAPTER_ID values from Query 2

-- ============================================================
-- QUERY 4: Count tasks per chapter (to see if tasks are linked)
-- ============================================================
SELECT
  c.id,
  c.title,
  COUNT(t.id) as task_count
FROM chapters c
LEFT JOIN tasks t ON c.id = t.chapter_id
GROUP BY c.id, c.title
ORDER BY c.id
LIMIT 20;

-- Expected: All chapters should show task_count > 0
-- If task_count = 0 for some chapters, those chapters have no linked tasks

-- ============================================================
-- QUERY 5: Check if chapter_id is NULL or empty
-- ============================================================
SELECT
  'NULL' as issue_type,
  COUNT(*) as count
FROM tasks
WHERE chapter_id IS NULL

UNION

SELECT
  'EMPTY' as issue_type,
  COUNT(*) as count
FROM tasks
WHERE chapter_id = '';

-- Shows if tasks have NULL or empty chapter_id values

-- ============================================================
-- QUERY 6: Show sample tasks and their chapter_id
-- ============================================================
SELECT
  id,
  chapter_id,
  title,
  subject_id
FROM tasks
ORDER BY id
LIMIT 20;

-- Shows raw task data - check what chapter_id values look like
