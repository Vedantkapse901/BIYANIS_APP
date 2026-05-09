-- ============================================
-- FIX CIVICS SUBJECT ASSIGNMENT ISSUE
-- ============================================

-- Step 1: Get all subject names and IDs to understand the data
SELECT id, name, subject_name, batch
FROM subjects
WHERE batch = 'ICSE 10'
ORDER BY name;

-- Step 2: Show CIVICS chapters (any chapter with CIVICS in name)
SELECT
  c.id,
  c.subject_id,
  c.chapter_name,
  s.name as current_subject_name
FROM chapters c
LEFT JOIN subjects s ON c.subject_id = s.id
WHERE c.batch = 'ICSE 10' AND c.chapter_name LIKE '%CIVICS%'
ORDER BY c.chapter_name;

-- Step 3: Find the correct CIVICS subject ID
SELECT id, name
FROM subjects
WHERE batch = 'ICSE 10'
  AND (name ILIKE '%CIVICS%' OR name = 'CIVICS');

-- Step 4: Find the CS (Computer Applications) subject ID
SELECT id, name
FROM subjects
WHERE batch = 'ICSE 10'
  AND (name ILIKE '%COMPUTER%' OR name ILIKE '%CS%');

-- Step 5: Show all chapters currently assigned to CS (Computer Applications)
-- to see if CIVICS chapters are mixed in
SELECT
  c.id,
  c.chapter_name,
  s.name as subject_name
FROM chapters c
LEFT JOIN subjects s ON c.subject_id = s.id
WHERE c.batch = 'ICSE 10'
  AND s.name ILIKE '%COMPUTER%'
ORDER BY c.chapter_name;

-- Step 6: Identify the problem - show chapters where name and subject_id don't match
SELECT
  c.id,
  c.chapter_name,
  c.subject_id,
  s.name as assigned_subject,
  CASE
    WHEN c.chapter_name LIKE '%CIVICS%' AND s.name NOT ILIKE '%CIVICS%' THEN 'MISMATCH: CIVICS chapter assigned to ' || s.name
    WHEN c.chapter_name LIKE '%COMPUTER%' AND s.name NOT ILIKE '%COMPUTER%' THEN 'MISMATCH: CS chapter assigned to ' || s.name
    ELSE 'OK'
  END as status
FROM chapters c
LEFT JOIN subjects s ON c.subject_id = s.id
WHERE c.batch = 'ICSE 10'
  AND (c.chapter_name LIKE '%CIVICS%' OR c.chapter_name LIKE '%COMPUTER%')
ORDER BY c.chapter_name;
