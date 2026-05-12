-- ========================================================================
-- SETUP TEACHERS TABLE (SUBJECT-SPECIFIC & GENERAL)
-- ========================================================================

-- 1. Create the teachers table
CREATE TABLE IF NOT EXISTS teachers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username TEXT UNIQUE NOT NULL,
  pin TEXT NOT NULL DEFAULT 'teacher@1234',
  name TEXT,
  batch TEXT NOT NULL, -- e.g. 'ICSE 9', 'ICSE 10', 'CBSE 10'
  subject TEXT,        -- NULL for general teachers, specific subject for others
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Clear existing teachers to prevent duplicates during setup
DELETE FROM teachers;

-- 3. Insert all teachers from the provided list
INSERT INTO teachers (username, batch, subject, name)
VALUES
  -- CBSE 10

  ('cbse10_economic','CBSE 10','ECONOMIC','teacher@1234','CBSE 10 ECONOMIC'),
  ('cbse10_eng_grammar','CBSE 10','ENGLISH GRAMMAR','teacher@1234','CBSE 10 ENGLISH GRAMMAR'),
  ('cbse10_history','CBSE 10','HISTORY','teacher@1234','CBSE 10 HISTORY'),
  ('cbse10_physics','CBSE 10','PHYSICS','teacher@1234','CBSE 10 PHYSICS'),
  ('cbse10_eng_literature','CBSE 10','ENGLISH LITERATURE','teacher@1234','CBSE 10 ENGLISH LITERATURE'),
  ('cbse10_geography','CBSE 10','GEOGRAPHY','teacher@1234','CBSE 10 GEOGRAPHY'),
  ('cbse10_sanskrit','CBSE 10','SANSKRIT','teacher@1234','CBSE 10 SANSKRIT'),
  ('cbse10_hindi','CBSE 10','HINDI','teacher@1234','CBSE 10 HINDI'),
  ('cbse10_biology','CBSE 10','BIOLOGY','teacher@1234','CBSE 10 BIOLOGY'),
  ('cbse10_maths','CBSE 10','MATHS','teacher@1234','CBSE 10 MATHS'),
  ('cbse10_civics','CBSE 10','CIVICS','teacher@1234','CBSE 10 CIVICS'),
  ('cbse10_chemistry','CBSE 10','CHEMISTRY','teacher@1234','CBSE 10 CHEMISTRY'),


  -- ICSE 10
  ('icse10_biology', 'ICSE 10', 'BIOLOGY', 'ICSE 10 Biology Teacher'),
  ('icse10_chemistry', 'ICSE 10', 'CHEMISTRY', 'ICSE 10 Chemistry Teacher'),
  ('icse10_english', 'ICSE 10', 'ENGLISH', 'ICSE 10 English Teacher'),
  ('icse10_geography', 'ICSE 10', 'GEOGRAPHY', 'ICSE 10 Geography Teacher'),
  ('icse10_history', 'ICSE 10', 'HISTORY', 'ICSE 10 History Teacher'),
  ('icse10_maths', 'ICSE 10', 'MATHS', 'ICSE 10 Maths Teacher'),
  ('icse10_physics', 'ICSE 10', 'PHYSICS', 'ICSE 10 Physics Teacher'),
  ('teacher_icse10', 'ICSE 10', NULL, 'ICSE 10 General Teacher'),

  -- ICSE 9
  ('icse9_biology', 'ICSE 9', 'BIOLOGY', 'ICSE 9 Biology Teacher'),
  ('icse9_chemistry', 'ICSE 9', 'CHEMISTRY', 'ICSE 9 Chemistry Teacher'),
  ('icse9_english', 'ICSE 9', 'ENGLISH', 'ICSE 9 English Teacher'),
  ('icse9_geography', 'ICSE 9', 'GEOGRAPHY', 'ICSE 9 Geography Teacher'),
  ('icse9_history', 'ICSE 9', 'HISTORY', 'ICSE 9 History Teacher'),
  ('icse9_maths', 'ICSE 9', 'MATHS', 'ICSE 9 Maths Teacher'),
  ('icse9_physics', 'ICSE 9', 'PHYSICS', 'ICSE 9 Physics Teacher'),
  ('teacher_icse9', 'ICSE 9', NULL, 'ICSE 9 General Teacher');

-- 4. Enable RLS
ALTER TABLE teachers ENABLE ROW LEVEL SECURITY;

-- 5. Create RLS Policies
DROP POLICY IF EXISTS "Public teachers are viewable by everyone" ON teachers;
CREATE POLICY "Public teachers are viewable by everyone" ON teachers FOR SELECT USING (true);

DROP POLICY IF EXISTS "Super admins can manage teachers" ON teachers;
CREATE POLICY "Super admins can manage teachers" ON teachers FOR ALL
USING (
  (SELECT role FROM profiles WHERE id::text = auth.uid()::text) = 'super_admin'
);
-- 6. Verification
SELECT username, batch, subject FROM teachers ORDER BY batch, username;
