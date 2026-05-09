-- ==============================================================
-- DIAGNOSTIC QUERIES FOR CHAPTER_ID MISMATCH
-- ==============================================================
-- Run these in Supabase Studio to find why tasks aren't fetching

-- Step 1: Check what chapter IDs we have
SELECT id, subject_id, title
FROM chapters
ORDER BY subject_id, order_index
LIMIT 10;

-- Expected output: List of actual chapter IDs (like 'ch_abc123', 'ch_xyz789', etc.)

---

-- Step 2: Check what chapter_id values tasks are pointing to
SELECT DISTINCT chapter_id, COUNT(*) as task_count
FROM tasks
GROUP BY chapter_id
ORDER BY chapter_id;

-- Expected: chapter_id values should match the IDs from Step 1

---

-- Step 3: Find MISMATCHED tasks (tasks pointing to non-existent chapters)
SELECT t.id, t.chapter_id, t.title, COUNT(*) as count
FROM tasks t
LEFT JOIN chapters c ON t.chapter_id = c.id
WHERE c.id IS NULL
GROUP BY t.id, t.chapter_id, t.title;

-- Expected: This should return EMPTY (no mismatches)
-- If it returns rows, those are your problem tasks!

---

-- Step 4: Sample data - Compare chapters vs tasks
-- This shows if the IDs are actually different
SELECT
  'CHAPTERS' as source,
  c.id,
  c.title as name,
  COUNT(t.id) as linked_tasks
FROM chapters c
LEFT JOIN tasks t ON c.id = t.chapter_id
GROUP BY c.id, c.title
LIMIT 5

UNION ALL

SELECT
  'TASKS' as source,
  t.chapter_id,
  t.title as name,
  COUNT(*) as count
FROM tasks t
GROUP BY t.chapter_id, t.title
LIMIT 5;

---

-- Step 5: Full mismatch report
-- Shows which chapters have no tasks and which tasks point to missing chapters
SELECT
  'Chapters with NO tasks' as issue_type,
  c.id,
  c.title,
  (SELECT COUNT(*) FROM tasks WHERE chapter_id = c.id) as task_count
FROM chapters c
WHERE (SELECT COUNT(*) FROM tasks WHERE chapter_id = c.id) = 0

UNION ALL

SELECT
  'Tasks with invalid chapter_id' as issue_type,
  t.chapter_id as id,
  t.title,
  COUNT(*) as task_count
FROM tasks t
LEFT JOIN chapters c ON t.chapter_id = c.id
WHERE c.id IS NULL
GROUP BY t.chapter_id, t.title;

---

-- ==============================================================
-- IF YOU FOUND MISMATCHES, USE THESE QUERIES TO FIX
-- ==============================================================

-- Option A: If tasks have wrong chapter_id format
-- (e.g., they say 'Chapter 1' instead of actual UUID)
-- First, PREVIEW the fix:
SELECT
  t.id,
  t.chapter_id as WRONG,
  c.id as CORRECT,
  t.title
FROM tasks t
LEFT JOIN chapters c ON t.subject_id = c.subject_id
  AND LOWER(t.chapter_name) = LOWER(c.title)
WHERE c.id IS NOT NULL
LIMIT 10;

-- If the preview looks good, run the UPDATE:
UPDATE tasks t
SET chapter_id = c.id
FROM chapters c
WHERE t.subject_id = c.subject_id
  AND LOWER(t.chapter_name) = LOWER(c.title)
  AND t.chapter_id != c.id;

---

-- Option B: If chapter_id is NULL or empty
-- Find all tasks with missing chapter_id:
SELECT id, title, chapter_id, subject_id
FROM tasks
WHERE chapter_id IS NULL OR chapter_id = '';

-- Fix them by matching to correct chapter:
UPDATE tasks t
SET chapter_id = c.id
FROM chapters c
WHERE t.subject_id = c.subject_id
  AND (t.chapter_id IS NULL OR t.chapter_id = '');

---

-- Option C: If you have duplicate chapters or tasks
-- Find duplicates:
SELECT title, COUNT(*) as count
FROM chapters
GROUP BY title
HAVING COUNT(*) > 1;

SELECT title, chapter_id, COUNT(*) as count
FROM tasks
GROUP BY title, chapter_id
HAVING COUNT(*) > 1;

---

-- ==============================================================
-- VERIFICATION AFTER FIX
-- ==============================================================

-- Make sure ALL tasks now have valid chapter_id:
SELECT COUNT(*) as invalid_tasks
FROM tasks t
LEFT JOIN chapters c ON t.chapter_id = c.id
WHERE c.id IS NULL;

-- Expected: 0 (zero invalid tasks)

-- Verify task count by chapter:
SELECT
  c.id,
  c.title,
  COUNT(t.id) as task_count
FROM chapters c
LEFT JOIN tasks t ON c.id = t.chapter_id
WHERE c.subject_id = 'YOUR_SUBJECT_ID'  -- Replace with actual subject ID
GROUP BY c.id, c.title
ORDER BY c.order_index;

-- Expected: All chapters should show their task counts

---

-- ==============================================================
-- FINAL CHECK - Run this to confirm getAllSubjects() will work
-- ==============================================================

-- Simulate what getAllSubjects() does:
WITH subject_data AS (
  SELECT id FROM subjects WHERE batch = 'ICSE 10' LIMIT 1
)
SELECT
  s.id as subject_id,
  c.id as chapter_id,
  COUNT(t.id) as task_count
FROM subjects s
LEFT JOIN chapters c ON s.id = c.subject_id
LEFT JOIN tasks t ON c.id = t.chapter_id
WHERE s.batch = 'ICSE 10'
GROUP BY s.id, c.id
ORDER BY c.order_index;

-- Expected: Should show proper counts for each chapter/task
-- If you see 0 tasks for chapters, there's still a mismatch!
