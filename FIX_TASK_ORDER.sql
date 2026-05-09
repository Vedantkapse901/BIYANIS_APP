/*
FIX TASK ORDERING AND DUPLICATES
This script will:
1. Fix task order within each chapter (1 to N)
2. Remove any duplicate tasks
3. Ensure single section display
*/

-- Step 1: Check for duplicate tasks (same chapter + same title)
SELECT
  chapter_id,
  title,
  COUNT(*) as count,
  STRING_AGG(id::text, ', ') as task_ids
FROM tasks
GROUP BY chapter_id, title
HAVING COUNT(*) > 1;

-- Step 2: Delete duplicate tasks (keep only the first one)
DELETE FROM tasks t1
WHERE id NOT IN (
  SELECT DISTINCT ON (chapter_id, title) id
  FROM tasks t2
  ORDER BY chapter_id, title, created_at
);

-- Verify duplicates are removed
SELECT COUNT(*) as remaining_duplicates
FROM (
  SELECT chapter_id, title, COUNT(*) as cnt
  FROM tasks
  GROUP BY chapter_id, title
  HAVING COUNT(*) > 1
) sub;

-- Step 3: Re-assign order_index correctly (1 to N per chapter)
-- This ensures tasks appear in correct order and single section
UPDATE tasks
SET order_index = new_order.new_order_index
FROM (
  SELECT
    id,
    ROW_NUMBER() OVER (PARTITION BY chapter_id ORDER BY created_at, id) as new_order_index
  FROM tasks
) new_order
WHERE tasks.id = new_order.id;

-- Step 4: Verify the fix
SELECT
  c.title as chapter,
  COUNT(t.id) as task_count,
  MIN(t.order_index) as first_order,
  MAX(t.order_index) as last_order
FROM chapters c
LEFT JOIN tasks t ON c.id = t.chapter_id
WHERE t.id IS NOT NULL
GROUP BY c.id, c.title
HAVING COUNT(t.id) > 0
ORDER BY task_count DESC
LIMIT 20;

-- Step 5: Show a specific chapter with tasks in correct order
SELECT
  c.title as chapter,
  t.order_index,
  t.title as task_title
FROM chapters c
LEFT JOIN tasks t ON c.id = t.chapter_id
WHERE c.title LIKE '%HUMAN EVOLUTION%'
ORDER BY t.order_index;

-- Final verification
SELECT COUNT(*) as total_tasks FROM tasks;
SELECT COUNT(*) as total_chapters FROM chapters;
