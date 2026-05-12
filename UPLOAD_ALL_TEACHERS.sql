-- MASTER TEACHER UPLOAD SCRIPT
-- This script uploads all teachers for CBSE 10, ICSE 10, and ICSE 9.
-- Run this in the Supabase SQL Editor to bypass RLS.

-- 1. CBSE 10 Teachers
INSERT INTO teachers (username, batch, subject, pin, name)
VALUES
  ('cbse10_economic', 'CBSE 10', 'ECONOMIC', 'teacher@1234', 'CBSE 10 ECONOMIC'),
  ('cbse10_eng_grammar', 'CBSE 10', 'ENGLISH GRAMMAR', 'teacher@1234', 'CBSE 10 ENGLISH GRAMMAR'),
  ('cbse10_history', 'CBSE 10', 'HISTORY', 'teacher@1234', 'CBSE 10 HISTORY'),
  ('cbse10_physics', 'CBSE 10', 'PHYSICS', 'teacher@1234', 'CBSE 10 PHYSICS'),
  ('cbse10_eng_literature', 'CBSE 10', 'ENGLISH LITERATURE', 'teacher@1234', 'CBSE 10 ENGLISH LITERATURE'),
  ('cbse10_geography', 'CBSE 10', 'GEOGRAPHY', 'teacher@1234', 'CBSE 10 GEOGRAPHY'),
  ('cbse10_sanskrit', 'CBSE 10', 'SANSKRIT', 'teacher@1234', 'CBSE 10 SANSKRIT'),
  ('cbse10_hindi', 'CBSE 10', 'HINDI', 'teacher@1234', 'CBSE 10 HINDI'),
  ('cbse10_biology', 'CBSE 10', 'BIOLOGY', 'teacher@1234', 'CBSE 10 BIOLOGY'),
  ('cbse10_maths', 'CBSE 10', 'MATHS', 'teacher@1234', 'CBSE 10 MATHS'),
  ('cbse10_civics', 'CBSE 10', 'CIVICS', 'teacher@1234', 'CBSE 10 CIVICS'),
  ('cbse10_chemistry', 'CBSE 10', 'CHEMISTRY', 'teacher@1234', 'CBSE 10 CHEMISTRY'),

-- 2. ICSE 10 Teachers
  ('icse10_ca', 'ICSE 10', 'CA', 'teacher@1234', 'ICSE 10 CA'),
  ('icse10_literature', 'ICSE 10', 'LITERATURE', 'teacher@1234', 'ICSE 10 LITERATURE'),
  ('icse10_biology', 'ICSE 10', 'BIOLOGY', 'teacher@1234', 'ICSE 10 BIOLOGY'),
  ('icse10_physics', 'ICSE 10', 'PHYSICS', 'teacher@1234', 'ICSE 10 PHYSICS'),
  ('icse10_maths', 'ICSE 10', 'MATHS', 'teacher@1234', 'ICSE 10 MATHS'),
  ('icse10_cs', 'ICSE 10', 'CS', 'teacher@1234', 'ICSE 10 CS'),
  ('icse10_civics', 'ICSE 10', 'CIVICS', 'teacher@1234', 'ICSE 10 CIVICS'),
  ('icse10_hindi', 'ICSE 10', 'HINDI', 'teacher@1234', 'ICSE 10 HINDI'),
  ('icse10_economic', 'ICSE 10', 'ECONOMIC', 'teacher@1234', 'ICSE 10 ECONOMIC'),
  ('icse10_language', 'ICSE 10', 'LANGUAGE', 'teacher@1234', 'ICSE 10 LANGUAGE'),
  ('icse10_geography', 'ICSE 10', 'GEOGRAPHY', 'teacher@1234', 'ICSE 10 GEOGRAPHY'),
  ('icse10_chemistry', 'ICSE 10', 'CHEMISTRY', 'teacher@1234', 'ICSE 10 CHEMISTRY'),
  ('icse10_history', 'ICSE 10', 'HISTORY', 'teacher@1234', 'ICSE 10 HISTORY'),

-- 3. ICSE 9 Teachers (Corrected list)
  ('icse9_cs', 'ICSE 9', 'CS', 'teacher@1234', 'ICSE 9 CS'),
  ('icse9_geography', 'ICSE 9', 'GEOGRAPHY', 'teacher@1234', 'ICSE 9 GEOGRAPHY'),
  ('icse9_physics', 'ICSE 9', 'PHYSICS', 'teacher@1234', 'ICSE 9 PHYSICS'),
  ('icse9_maths', 'ICSE 9', 'MATHS', 'teacher@1234', 'ICSE 9 MATHS'),
  ('icse9_hindi', 'ICSE 9', 'HINDI', 'teacher@1234', 'ICSE 9 HINDI'),
  ('icse9_economic', 'ICSE 9', 'ECONOMIC', 'teacher@1234', 'ICSE 9 ECONOMIC'),
  ('icse9_ca', 'ICSE 9', 'CA', 'teacher@1234', 'ICSE 9 CA'),
  ('icse9_language', 'ICSE 9', 'LANGUAGE', 'teacher@1234', 'ICSE 9 LANGUAGE'),
  ('icse9_chemistry', 'ICSE 9', 'CHEMISTRY', 'teacher@1234', 'ICSE 9 CHEMISTRY'),
  ('icse9_biology', 'ICSE 9', 'BIOLOGY', 'teacher@1234', 'ICSE 9 BIOLOGY'),
  ('icse9_literature', 'ICSE 9', 'LITERATURE', 'teacher@1234', 'ICSE 9 LITERATURE'),
  ('icse9_civics', 'ICSE 9', 'CIVICS', 'teacher@1234', 'ICSE 9 CIVICS'),
  ('icse9_history', 'ICSE 9', 'HISTORY', 'teacher@1234', 'ICSE 9 HISTORY')

ON CONFLICT (username) DO UPDATE SET
  name = EXCLUDED.name,
  pin = EXCLUDED.pin,
  batch = EXCLUDED.batch,
  subject = EXCLUDED.subject,
  updated_at = NOW();
