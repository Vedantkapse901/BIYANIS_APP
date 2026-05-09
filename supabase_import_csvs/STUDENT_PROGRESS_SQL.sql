-- ============================================================================
-- STEP 1: Fix student batch (if not already done)
-- ============================================================================

UPDATE students
SET batch = CONCAT(UPPER(board), ' ', standard)
WHERE batch IS NULL;

-- ============================================================================
-- STEP 2: Create student_progress records linking all students to all tasks
-- ============================================================================
-- This creates a progress record for EVERY student-task combination where
-- the student batch matches the subject batch

INSERT INTO student_progress (id, student_id, task_id, is_completed, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,
    s.id as student_id,
    t.id as task_id,
    false as is_completed,
    NOW() as created_at,
    NOW() as updated_at
FROM students s
JOIN tasks t ON true
JOIN topics tp ON t.topic_id = tp.id
JOIN subjects subj ON tp.subject_id = subj.id
WHERE s.batch = subj.batch
  AND NOT EXISTS (
    SELECT 1 FROM student_progress sp 
    WHERE sp.student_id = s.id AND sp.task_id = t.id
  )
LIMIT 1000000;

-- ============================================================================
-- VERIFICATION QUERIES (Run these after import to verify everything worked)
-- ============================================================================

-- Check 1: How many subjects were imported?
SELECT COUNT(*) as total_subjects, batch FROM subjects GROUP BY batch;

-- Check 2: How many topics per subject?
SELECT 
    s.name as subject_name, 
    COUNT(t.id) as topic_count,
    s.batch
FROM subjects s
LEFT JOIN topics t ON s.id = t.subject_id
GROUP BY s.id, s.name, s.batch
ORDER BY s.name;

-- Check 3: How many tasks per topic (top 10)?
SELECT 
    tp.title as topic_name, 
    COUNT(t.id) as task_count
FROM topics tp
LEFT JOIN tasks t ON tp.id = t.topic_id
GROUP BY tp.id, tp.title
ORDER BY COUNT(t.id) DESC
LIMIT 10;

-- Check 4: Total number of student progress records created
SELECT COUNT(*) as total_progress_records FROM student_progress;

-- Check 5: How many tasks per student?
SELECT 
    s.name as student_name, 
    s.batch,
    COUNT(sp.id) as assigned_tasks
FROM students s
LEFT JOIN student_progress sp ON s.id = sp.student_id
GROUP BY s.id, s.name, s.batch
ORDER BY s.name;

-- Check 6: Task completion statistics
SELECT 
    COUNT(*) as total_tasks,
    SUM(CASE WHEN is_completed THEN 1 ELSE 0 END) as completed_tasks,
    SUM(CASE WHEN NOT is_completed THEN 1 ELSE 0 END) as pending_tasks
FROM student_progress;

