# Fix Task-Chapter ID Mismatch - SQL Script

## Problem
- 2,114 tasks in database have **broken chapter_id** values
- These IDs don't exist in the chapters table
- CSV file has the **correct mapping**: Subject → Chapter → Tasks

## Solution
Update tasks to use correct chapter IDs by matching chapter names

---

## Step 1: Delete All Broken Tasks

```sql
-- BACKUP FIRST: Create backup table
CREATE TABLE tasks_backup_broken AS 
SELECT * FROM tasks 
WHERE chapter_id NOT IN (SELECT id FROM chapters);

-- Verify backup was created
SELECT COUNT(*) as backed_up_tasks FROM tasks_backup_broken;
-- Expected: 2114 tasks

-- DELETE broken tasks
DELETE FROM tasks 
WHERE chapter_id NOT IN (SELECT id FROM chapters);

-- Verify deletion
SELECT COUNT(*) FROM tasks;
-- Should now show 0 or much lower count
```

---

## Step 2: Re-Import Tasks Using CSV Data

The mapping has been extracted. Now we need to rebuild the task import by:

1. **Match chapters** by Subject + Chapter Name
2. **Insert tasks** with correct chapter_id

### Example for PHYSICS chapters:

```sql
-- INSERT PHYSICS - FORCE (Chapter 1)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT 
  gen_random_uuid(),
  c.id as chapter_id,
  task_name,
  row_number,
  NOW(),
  NOW()
FROM (
  VALUES 
    ('TEXTBOOK READING', 1),
    ('TEXTBOOK SOLVED EXAMPLES', 2),
    ('BOOK BACK QUESTIONS', 3),
    ('ALL LWS', 4),
    ('DREAM 90 MCQ AND AR', 5),
    ('DREAM 90 PP MCQ', 6),
    ('DREAM 90 PP SUBJECTIVE', 7),
    ('DREAM 90 SOLVED NUMERICALS', 8)
) as tasks_list(task_name, row_number)
CROSS JOIN chapters c
WHERE c.title = 'FORCE' 
  AND c.subject_id IN (SELECT id FROM subjects WHERE title = 'PHYSICS');
```

---

## Step 3: Verify Fix

```sql
-- Check task count by chapter
SELECT 
  c.id,
  c.title as chapter_name,
  COUNT(t.id) as task_count
FROM chapters c
LEFT JOIN tasks t ON c.id = t.chapter_id
GROUP BY c.id, c.title
HAVING COUNT(t.id) > 0
ORDER BY c.title;

-- Check for any remaining broken tasks
SELECT COUNT(*) as remaining_broken
FROM tasks t
LEFT JOIN chapters c ON t.chapter_id = c.id
WHERE c.id IS NULL;
-- Expected: 0
```

---

## Automated Fix Script

I've created a Python script that will:
1. Parse the CSV file
2. Match chapters by name
3. Generate proper INSERT SQL with correct chapter_id values
4. Ready to execute in Supabase

Run this to generate the complete fix:

```bash
python /sessions/nifty-epic-ride/mnt/outputs/generate_fix_sql.py
```

This will create: `tasks_insert_sql.sql` with all INSERT statements

---

## Next Steps

1. **Backup current tasks**:
   ```sql
   CREATE TABLE tasks_backup_all AS SELECT * FROM tasks;
   ```

2. **Delete broken tasks**:
   ```sql
   DELETE FROM tasks WHERE chapter_id NOT IN (SELECT id FROM chapters);
   ```

3. **Run generated SQL** from `tasks_insert_sql.sql`

4. **Verify**:
   - All chapters should now have tasks
   - No broken chapter_id references
   - Task count matches CSV (1,062 tasks)

---

## Safety Checks

Before running, verify:

```sql
-- Count chapters in database
SELECT COUNT(*) as chapter_count FROM chapters;

-- Count expected tasks from CSV
-- PHYSICS: 101 tasks
-- CHEMISTRY: 68 tasks  
-- MATHS: 252 tasks
-- BIOLOGY: 135 tasks
-- LANGUAGE: 96 tasks
-- HISTORY: 105 tasks
-- CIVICS: 35 tasks
-- GEOGRAPHY: 126 tasks
-- CS: 60 tasks
-- ECONOMIC: 84 tasks
-- TOTAL EXPECTED: 1,062 tasks
```

---

## Important Notes

⚠️ **Do NOT run until:**
- You've backed up all data
- You've verified the chapter names match between CSV and database
- You understand the impact (deleting 2,114 tasks and rebuilding with 1,062 new ones)

✅ **After running:**
- All 1,062 tasks will have correct chapter_id values
- App should now load data properly
- No more "tasks not found" errors
