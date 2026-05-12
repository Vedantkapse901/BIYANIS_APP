-- CBSE 10 Teachers Upload Script
-- Run this in the Supabase SQL Editor

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
  ('cbse10_chemistry', 'CBSE 10', 'CHEMISTRY', 'teacher@1234', 'CBSE 10 CHEMISTRY')
ON CONFLICT (username) DO UPDATE SET
  name = EXCLUDED.name,
  pin = EXCLUDED.pin,
  batch = EXCLUDED.batch,
  subject = EXCLUDED.subject,
  updated_at = NOW();
