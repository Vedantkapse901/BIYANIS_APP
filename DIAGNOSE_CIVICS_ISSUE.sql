-- ============================================
-- DIAGNOSE CIVICS SUBJECT_ID ISSUE
-- ============================================

-- Step 1: List all subjects with their IDs
SELECT id, subject_name, batch
FROM subjects
WHERE batch = 'ICSE 10'
ORDER BY subject_name;

-- Step 2: Show chapters that are labeled as CIVICS (chapter_name contains CIVICS)
SELECT id, subject_id, chapter_name, batch
FROM chapters
WHERE batch = 'ICSE 10' AND chapter_name LIKE '%CIVICS%'
ORDER BY chapter_name;

-- Step 3: Get the actual CIVICS subject ID
SELECT id as civics_subject_id, subject_name
FROM subjects
WHERE batch = 'ICSE 10' AND subject_name = 'CIVICS';

-- Step 4: Get the CS (Computer Applications) subject ID
SELECT id as cs_subject_id, subject_name
FROM subjects
WHERE batch = 'ICSE 10' AND (subject_name = 'COMPUTER APPLICATIONS' OR subject_name = 'COMPUTER SCIENCE');

-- Step 5: Check if CIVICS chapters have the wrong subject_id (are they assigned to CS?)
SELECT
  c.id,
  c.chapter_name,
  c.subject_id,
  s.subject_name,
  'NEEDS_FIX' as status
FROM chapters c
LEFT JOIN subjects s ON c.subject_id = s.id
WHERE c.batch = 'ICSE 10'
  AND c.chapter_name LIKE '%CIVICS%'
  AND s.subject_name != 'CIVICS';

-- Step 6: Count chapters by subject for ICSE 10
SELECT
  s.subject_name,
  COUNT(c.id) as chapter_count
FROM subjects s
LEFT JOIN chapters c ON s.id = c.subject_id AND c.batch = 'ICSE 10'
WHERE s.batch = 'ICSE 10'
GROUP BY s.id, s.subject_name
ORDER BY s.subject_name;
