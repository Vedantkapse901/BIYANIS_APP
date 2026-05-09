/*
QUICK FRESH IMPORT - Fast version
Deletes old data and imports everything fresh
*/

-- Drop old backups if they exist
DROP TABLE IF EXISTS tasks_backup_final;
DROP TABLE IF EXISTS chapters_backup_before_fresh_import;
DROP TABLE IF EXISTS complete_backup_before_fresh_import;

-- Step 1: Delete all old data (FAST)
DELETE FROM tasks;
DELETE FROM chapters;

SELECT COUNT(*) as tasks_remaining FROM tasks;
SELECT COUNT(*) as chapters_remaining FROM chapters;

-- Step 2: Import chapters from CSV file directly
-- (This is much faster than individual INSERTs)
COPY chapters (subject_id, title, order_index, created_at, updated_at)
FROM stdin WITH (FORMAT csv, HEADER true);

-- Step 3: Import tasks from CSV file directly
COPY tasks (chapter_id, title, order_index, created_at, updated_at)
FROM stdin WITH (FORMAT csv, HEADER true);

-- Verify
SELECT COUNT(*) as total_chapters FROM chapters;
SELECT COUNT(*) as total_tasks FROM tasks;
SELECT COUNT(*) as tasks_without_chapter FROM tasks WHERE chapter_id IS NULL;
