# Fix Chapter ID Mismatch - Step by Step Guide

## Problem
Tasks aren't fetching because `task.chapter_id` doesn't match the actual `chapter.id` in the database.

When the app tries to fetch tasks for chapters, it does:
```dart
final tasksResponse = await _client
    .from('tasks')
    .select('*')
    .inFilter('chapter_id', chapterIds)  // ❌ No match = No tasks returned
```

If `task.chapter_id` is wrong (e.g., "Chapter 1" instead of the actual UUID), the query returns nothing!

---

## Step 1: Diagnose the Problem

### Access Supabase Studio
1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Go to **SQL Editor** (bottom left)
4. Paste this query:

```sql
-- Find mismatched tasks
SELECT t.id, t.chapter_id, t.title, 
       (SELECT COUNT(*) FROM chapters WHERE id = t.chapter_id) as chapter_exists
FROM tasks t
LIMIT 20;
```

### What to Look For
✅ **Good**: `chapter_exists` shows `1` for all rows
❌ **Bad**: `chapter_exists` shows `0` for some rows (those are mismatched!)

### Quick Diagnosis
Run this simple check:
```sql
SELECT COUNT(*) as tasks_with_invalid_chapter_id
FROM tasks t
LEFT JOIN chapters c ON t.chapter_id = c.id
WHERE c.id IS NULL;
```

**Expected result:**
- `0` = Everything is fine, you don't need this fix
- `>0` = You have mismatched data that needs fixing

---

## Step 2: Identify the Mismatch Pattern

Run this query to see what's wrong:

```sql
SELECT 
  t.chapter_id as WRONG_VALUE,
  c.id as CORRECT_VALUE,
  t.title as task_title,
  c.title as chapter_title
FROM tasks t
LEFT JOIN chapters c ON t.subject_id = c.subject_id
  AND LOWER(t.chapter_name) = LOWER(c.title)
WHERE c.id IS NOT NULL
LIMIT 10;
```

This shows:
- What the tasks currently have (WRONG_VALUE)
- What they should have (CORRECT_VALUE)
- Whether we can match by subject + chapter name

---

## Step 3: Choose Your Fix Method

### Method A: Match by Chapter Name (if you have chapter_name field)

**When to use:** If tasks have a `chapter_name` field that matches chapter titles

**The Fix:**
```sql
UPDATE tasks t
SET chapter_id = c.id
FROM chapters c
WHERE t.subject_id = c.subject_id
  AND LOWER(t.chapter_name) = LOWER(c.title)
  AND t.chapter_id != c.id;
```

**Verify:**
```sql
SELECT * FROM tasks WHERE chapter_id IS NULL;
-- Should return 0 rows
```

---

### Method B: Manual Mapping (if mismatch is simple)

**When to use:** If you only have a few chapters and can manually identify the correct IDs

**Step 1:** Get all correct chapter IDs:
```sql
SELECT id, title, subject_id
FROM chapters
ORDER BY subject_id, order_index;
```

Copy the output and create a mapping:
```
Chapter Title        → Chapter ID (Copy this)
Chapter 1 - Intro   → 123e4567-e89b-12d3-a456-426614174000
Chapter 2 - Basics  → 456f7890-f89c-23e4-b567-537726285111
...
```

**Step 2:** Update tasks to use correct IDs

For each wrong chapter_id, run:
```sql
UPDATE tasks
SET chapter_id = '123e4567-e89b-12d3-a456-426614174000'
WHERE chapter_id = 'WRONG_ID_HERE'
  AND title LIKE '%keyword from task title%';
```

---

### Method C: Batch Fix from Excel/CSV

**When to use:** If you have data in Excel that you need to sync with database

**Step 1:** Get current state:
```sql
SELECT chapter_id, title, subject_id
FROM tasks
ORDER BY chapter_id
LIMIT 100;
```

**Step 2:** Export as CSV and open in Excel

**Step 3:** Create mapping column:
```
chapter_id (wrong)  | title              | Correct_ID (look up)
NULL or bad ID      | Chapter 1 - Intro  | <look up from chapters table>
```

**Step 4:** Import back using raw SQL:
```sql
UPDATE tasks
SET chapter_id = 'CORRECT_ID'
WHERE title = 'EXACT_TASK_TITLE'
  AND subject_id = 'CORRECT_SUBJECT_ID';
```

---

## Step 4: Run the Fix

### Before Making Changes
**ALWAYS backup your data first:**
```sql
-- Create a backup table
CREATE TABLE tasks_backup AS SELECT * FROM tasks;

-- Or export from Supabase Studio UI
-- Table menu → Export → Download as CSV
```

### Execute the Fix

**Choose the appropriate method from Step 3**, then run the UPDATE query.

**After running, verify:**
```sql
-- Check that update was successful
SELECT COUNT(*) as updated_count
FROM tasks
WHERE chapter_id IS NOT NULL
  AND chapter_id != '';

-- Check for any remaining orphaned tasks
SELECT COUNT(*) as orphaned_tasks
FROM tasks t
LEFT JOIN chapters c ON t.chapter_id = c.id
WHERE c.id IS NULL;
-- Expected: 0
```

---

## Step 5: Verify the Fix Works

Run the final verification query:

```sql
-- Get sample chapter with tasks
SELECT
  c.id,
  c.title as chapter_title,
  COUNT(t.id) as task_count,
  STRING_AGG(t.title, ', ') as task_titles
FROM chapters c
LEFT JOIN tasks t ON c.id = t.chapter_id
GROUP BY c.id, c.title
LIMIT 10;
```

**Expected output:**
```
id              | chapter_title        | task_count | task_titles
abc123...       | Chapter 1 - Intro    | 5          | Task 1, Task 2, ...
def456...       | Chapter 2 - Basics   | 8          | Task A, Task B, ...
```

If all chapters show `task_count > 0`, your fix worked!

---

## Step 6: Test in the App

### Clear App Cache
```bash
flutter clean
flutter pub get
```

### Run the App
```bash
flutter run
```

### Expected Results
✅ Should now see tasks loading
✅ Console should show:
```
✅ Found X tasks total
```

✅ Chapter expand should show task list
✅ No more "No tasks found" warnings

---

## Troubleshooting

### Problem: Still no tasks showing
**Check:**
1. Did the UPDATE query run successfully? (Check affected rows)
2. Run verification query again - do chapters show task_count > 0?
3. Is the batch name correct? ("ICSE 10" not "ICSE 10th")

**Solution:**
```sql
-- Check if tasks are linked at all
SELECT COUNT(*) FROM tasks WHERE chapter_id IS NULL OR chapter_id = '';
-- If > 0, you have orphaned tasks that need fixing
```

### Problem: Some chapters have tasks, some don't
**Check:**
```sql
-- Find chapters with NO tasks
SELECT c.id, c.title
FROM chapters c
LEFT JOIN tasks t ON c.id = t.chapter_id
WHERE t.id IS NULL;

-- Find tasks not linked to any chapter
SELECT id, title, chapter_id
FROM tasks
WHERE chapter_id NOT IN (SELECT id FROM chapters);
```

### Problem: UPDATE query failed
**Likely cause:** Table structure is different than expected

**Solution:**
```sql
-- Check actual column names
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'tasks'
ORDER BY ordinal_position;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'chapters'
ORDER BY ordinal_position;
```

Then adjust the fix queries based on actual column names.

---

## Prevention for Future

### When Importing New Data
Before inserting tasks, ensure:
1. All `chapter_id` values exist in chapters table
2. No NULL or empty chapter_id values
3. Task subject_id matches the chapter's subject_id

**Verification query before insert:**
```sql
-- This query will show if there would be mismatches
SELECT t.chapter_id, COUNT(*) as task_count
FROM tasks_to_import t
LEFT JOIN chapters c ON t.chapter_id = c.id
WHERE c.id IS NULL
GROUP BY t.chapter_id;

-- If this returns any rows with non-NULL chapter_id,
-- those tasks won't find their chapters!
```

---

## Detailed Diagnostic Query

If you need more information, run this comprehensive diagnostic:

```sql
-- Complete diagnostic report
WITH diagnostic AS (
  -- Check 1: Orphaned tasks
  SELECT 'Orphaned Tasks' as check_type, COUNT(*) as issue_count
  FROM tasks t
  WHERE t.chapter_id NOT IN (SELECT id FROM chapters)
  
  UNION ALL
  
  -- Check 2: NULL chapter_id
  SELECT 'NULL chapter_id' as check_type, COUNT(*) as issue_count
  FROM tasks
  WHERE chapter_id IS NULL
  
  UNION ALL
  
  -- Check 3: Empty chapter_id
  SELECT 'Empty chapter_id' as check_type, COUNT(*) as issue_count
  FROM tasks
  WHERE chapter_id = ''
  
  UNION ALL
  
  -- Check 4: Mismatched subject_id
  SELECT 'Subject ID Mismatch' as check_type, COUNT(*) as issue_count
  FROM tasks t
  LEFT JOIN chapters c ON t.chapter_id = c.id
  WHERE c.subject_id != t.subject_id
    AND c.id IS NOT NULL
)
SELECT * FROM diagnostic;
```

---

## Quick Reference

| Issue | Query | Fix |
|-------|-------|-----|
| Tasks won't fetch | `SELECT COUNT(*) FROM tasks WHERE chapter_id NOT IN (SELECT id FROM chapters)` | Run Method A/B/C fix |
| NULL chapter_id | `SELECT COUNT(*) FROM tasks WHERE chapter_id IS NULL` | Assign correct IDs |
| Wrong ID format | `SELECT DISTINCT chapter_id FROM tasks LIMIT 1` | Reformat or remap IDs |
| No tasks per chapter | `SELECT COUNT(t.id) FROM chapters c LEFT JOIN tasks t ON c.id = t.chapter_id GROUP BY c.id` | Verify IDs match |

---

## Next Steps After Fix

1. ✅ Run diagnostic queries
2. ✅ Identify the mismatch pattern
3. ✅ Choose and run appropriate fix method
4. ✅ Verify with SQL queries
5. ✅ Test in the app
6. ✅ Monitor console for success

**You should then see tasks loading correctly!**
