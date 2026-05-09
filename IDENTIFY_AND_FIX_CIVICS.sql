-- ============================================
-- IDENTIFY AND FIX CIVICS ASSIGNMENT
-- ============================================

-- First, understand the current state:

-- STEP 1: Get all 12 subject IDs and names for ICSE 10
SELECT
  id,
  name,
  COUNT(ch.id) as chapter_count
FROM subjects s
LEFT JOIN chapters ch ON s.id = ch.subject_id AND ch.batch = 'ICSE 10'
WHERE s.batch = 'ICSE 10'
GROUP BY s.id, s.name
ORDER BY name;

-- STEP 2: Show the problem - CIVICS chapters and where they're assigned
SELECT
  c.id as chapter_id,
  c.chapter_name,
  c.subject_id,
  s.name as current_subject,
  CASE
    WHEN c.chapter_name ILIKE '%CIVICS%' THEN 'YES - WRONG ASSIGNMENT'
    ELSE 'NO'
  END as is_civics_chapter
FROM chapters c
LEFT JOIN subjects s ON c.subject_id = s.id
WHERE c.batch = 'ICSE 10' AND c.chapter_name ILIKE '%CIVICS%'
ORDER BY c.chapter_name;

-- STEP 3: Identify the correct subject IDs
-- Get CIVICS subject ID
SELECT id as civics_subject_id, name
FROM subjects
WHERE batch = 'ICSE 10' AND name ILIKE '%CIVICS%';

-- STEP 4: Identify CS subject ID
SELECT id as cs_subject_id, name
FROM subjects
WHERE batch = 'ICSE 10' AND name ILIKE '%COMPUTER%';

-- STEP 5: NOW FIX THE ASSIGNMENT
-- Get the subject IDs first:
-- For CIVICS: (replace with actual ID from query above)
-- For CS: (replace with actual ID from query above)

-- Uncomment and run after confirming the IDs from steps 3 and 4:
/*
UPDATE chapters
SET subject_id = (SELECT id FROM subjects WHERE batch = 'ICSE 10' AND name ILIKE '%CIVICS%')
WHERE batch = 'ICSE 10'
  AND chapter_name ILIKE '%CIVICS%'
  AND subject_id != (SELECT id FROM subjects WHERE batch = 'ICSE 10' AND name ILIKE '%CIVICS%');

-- Verify the fix
SELECT
  c.id,
  c.chapter_name,
  c.subject_id,
  s.name as subject_name
FROM chapters c
LEFT JOIN subjects s ON c.subject_id = s.id
WHERE c.batch = 'ICSE 10' AND c.chapter_name ILIKE '%CIVICS%'
ORDER BY c.chapter_name;
*/
