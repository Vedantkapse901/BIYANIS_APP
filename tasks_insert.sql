-- AUTO-GENERATED SQL TO RE-IMPORT TASKS WITH CORRECT CHAPTER IDs

-- =============================================
-- SUBJECT: BIOLOGY
-- =============================================

-- STRUCTURE OF CHROMOSOMES,CELL CYCLE AND CELL DIVISION (9 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('textbook theory reading', 1),
  ('revision (shortcut notes)', 2),
  ('DIAGRAM PRACTICE', 3),
  ('TEXTBOOK QUESTIONS', 4),
  ('DREAM 90 LWS', 5),
  ('DREAM 90 MCQ''S, A&R, OBJECTIVES', 6),
  ('PYQ - OBJECTIVE & SUBJECTIVE', 7),
  ('DREAM 90 - SA - 20 MKS', 8),
  ('RECTIFY MISTAKES & FINAL REVISION', 9)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%STRUCTURE OF CHROMOSOMES,CELL CYCLE AND CELL DIVISION%')
LIMIT 1;

-- GENETICS (9 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('CLASS NOTES', 1),
  ('REVISE DEFINITIONS', 2),
  ('Practice Monohybrid & dihybrid cross', 3),
  ('PRACTICE WORD PROBLEMS (sex linked inheritence)', 4),
  ('DREAM 90 LWS', 5),
  ('DREAM 90 MCQ''S, A&R, OBJECTIVES', 6),
  ('PYQ - OBJECTIVE & SUBJECTIVE', 7),
  ('DREAM 90 - SA - 20 MKS', 8),
  ('RECTIFY MISTAKES & FINAL REVISION', 9)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%GENETICS%')
LIMIT 1;

-- ABSORPTION BY ROOTS (9 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('textbook theory reading', 1),
  ('revision (shortcut notes)', 2),
  ('SOLVE GIVE REASONS', 3),
  ('TEXTBOOK QUESTIONS', 4),
  ('DREAM 90 LWS', 5),
  ('DREAM 90 MCQ''S, A&R, OBJECTIVES', 6),
  ('PYQ - OBJECTIVE & SUBJECTIVE', 7),
  ('DREAM 90 - SA - 20 MKS', 8),
  ('RECTIFY MISTAKES & FINAL REVISION', 9)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%ABSORPTION BY ROOTS%')
LIMIT 1;

-- TRANSPIRATION (9 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('textbook theory reading', 1),
  ('REVISE EXPERIMENTS', 2),
  ('DIAGRAM PRACTICE', 3),
  ('TEXTBOOK QUESTIONS', 4),
  ('DREAM 90 LWS', 5),
  ('DREAM 90 MCQ''S, A&R, OBJECTIVES', 6),
  ('PYQ - OBJECTIVE & SUBJECTIVE', 7),
  ('DREAM 90 - SA - 20 MKS', 8),
  ('RECTIFY MISTAKES & FINAL REVISION', 9)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%TRANSPIRATION%')
LIMIT 1;

-- PHOTOSYNTHESIS (9 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('textbook theory reading', 1),
  ('REVISE EXPERIMENTS', 2),
  ('DIAGRAM PRACTICE', 3),
  ('TEXTBOOK QUESTIONS', 4),
  ('DREAM 90 LWS', 5),
  ('DREAM 90 MCQ''S, A&R, OBJECTIVES', 6),
  ('PYQ - OBJECTIVE & SUBJECTIVE', 7),
  ('DREAM 90 - SA - 20 MKS', 8),
  ('RECTIFY MISTAKES & FINAL REVISION', 9)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%PHOTOSYNTHESIS%')
LIMIT 1;

-- CHEMICAL COORDINATION IN PLANTS (9 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('textbook theory reading', 1),
  ('Revise activities', 2),
  ('revise textbook markings', 3),
  ('TEXTBOOK QUESTIONS', 4),
  ('DREAM 90 LWS', 5),
  ('DREAM 90 MCQ''S, A&R, OBJECTIVES', 6),
  ('PYQ - OBJECTIVE & SUBJECTIVE', 7),
  ('DREAM 90 - SA - 20 MKS', 8),
  ('RECTIFY MISTAKES & FINAL REVISION', 9)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%CHEMICAL COORDINATION IN PLANTS%')
LIMIT 1;

-- THE CIRCULATORY SYSTEM (9 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('textbook theory reading', 1),
  ('revision (shortcut notes)', 2),
  ('DIAGRAM PRACTICE', 3),
  ('TEXTBOOK QUESTIONS', 4),
  ('DREAM 90 LWS', 5),
  ('DREAM 90 MCQ''S, A&R, OBJECTIVES', 6),
  ('PYQ - OBJECTIVE & SUBJECTIVE', 7),
  ('DREAM 90 - SA - 20 MKS', 8),
  ('RECTIFY MISTAKES & FINAL REVISION', 9)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%THE CIRCULATORY SYSTEM%')
LIMIT 1;

-- THE EXCRETORY SYSTEM (9 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('textbook theory reading', 1),
  ('REVISE CLASS NOTES', 2),
  ('DIAGRAM PRACTICE', 3),
  ('TEXTBOOK QUESTIONS', 4),
  ('DREAM 90 LWS', 5),
  ('DREAM 90 MCQ''S, A&R, OBJECTIVES', 6),
  ('PYQ - OBJECTIVE & SUBJECTIVE', 7),
  ('DREAM 90 - SA - 20 MKS', 8),
  ('RECTIFY MISTAKES & FINAL REVISION', 9)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%THE EXCRETORY SYSTEM%')
LIMIT 1;

-- THE NERVOUS SYSTEM (9 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('textbook theory reading', 1),
  ('Textbook markings', 2),
  ('DIAGRAM PRACTICE', 3),
  ('TEXTBOOK QUESTIONS', 4),
  ('DREAM 90 LWS', 5),
  ('DREAM 90 MCQ''S, A&R, OBJECTIVES', 6),
  ('PYQ - OBJECTIVE & SUBJECTIVE', 7),
  ('DREAM 90 - SA - 20 MKS', 8),
  ('RECTIFY MISTAKES & FINAL REVISION', 9)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%THE NERVOUS SYSTEM%')
LIMIT 1;

-- SENSE ORGANS (9 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('textbook theory reading', 1),
  ('revision (shortcut notes)', 2),
  ('DIAGRAM PRACTICE', 3),
  ('TEXTBOOK QUESTIONS', 4),
  ('DREAM 90 LWS', 5),
  ('DREAM 90 MCQ''S, A&R, OBJECTIVES', 6),
  ('PYQ - OBJECTIVE & SUBJECTIVE', 7),
  ('DREAM 90 - SA - 20 MKS', 8),
  ('RECTIFY MISTAKES & FINAL REVISION', 9)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%SENSE ORGANS%')
LIMIT 1;

-- THE ENDOCRINE SYSTEM (9 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('textbook theory reading', 1),
  ('revision (shortcut notes)', 2),
  ('revise textbook markings', 3),
  ('TEXTBOOK QUESTIONS', 4),
  ('DREAM 90 LWS', 5),
  ('DREAM 90 MCQ''S, A&R, OBJECTIVES', 6),
  ('PYQ - OBJECTIVE & SUBJECTIVE', 7),
  ('DREAM 90 - SA - 20 MKS', 8),
  ('RECTIFY MISTAKES & FINAL REVISION', 9)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%THE ENDOCRINE SYSTEM%')
LIMIT 1;

-- THE REPRODUCTIVITY SYSTEM (9 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('textbook theory reading', 1),
  ('revise textbook markings', 2),
  ('Diagrams & process practice', 3),
  ('TEXTBOOK QUESTIONS', 4),
  ('DREAM 90 LWS', 5),
  ('DREAM 90 MCQ''S, A&R, OBJECTIVES', 6),
  ('PYQ - OBJECTIVE & SUBJECTIVE', 7),
  ('DREAM 90 - SA - 20 MKS', 8),
  ('RECTIFY MISTAKES & FINAL REVISION', 9)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%THE REPRODUCTIVITY SYSTEM%')
LIMIT 1;

-- HUMAN EVOLUTION (9 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('textbook theory reading', 1),
  ('revise textbook markings', 2),
  ('SOLVE PYQ', 3),
  ('TEXTBOOK QUESTIONS', 4),
  ('DREAM 90 LWS', 5),
  ('DREAM 90 MCQ''S, A&R, OBJECTIVES', 6),
  ('PYQ - OBJECTIVE & SUBJECTIVE', 7),
  ('DREAM 90 - SA - 20 MKS', 8),
  ('RECTIFY MISTAKES & FINAL REVISION', 9)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%HUMAN EVOLUTION%')
LIMIT 1;

-- POPULATION- THE INCREASING NUMBERS & RISING PROBLEMS (9 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('textbook theory reading', 1),
  ('revise textbook markings', 2),
  ('SOLVE PYQ', 3),
  ('TEXTBOOK QUESTIONS', 4),
  ('DREAM 90 LWS', 5),
  ('DREAM 90 MCQ''S, A&R, OBJECTIVES', 6),
  ('PYQ - OBJECTIVE & SUBJECTIVE', 7),
  ('DREAM 90 - SA - 20 MKS', 8),
  ('RECTIFY MISTAKES & FINAL REVISION', 9)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%POPULATION- THE INCREASING NUMBERS & RISING PROBLEMS%')
LIMIT 1;

-- POLLUTION - A RISING ENVIRONMENTAL PROBLEM (9 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('textbook theory reading', 1),
  ('revise textbook markings', 2),
  ('SOLVE PYQ', 3),
  ('TEXTBOOK QUESTIONS', 4),
  ('DREAM 90 LWS', 5),
  ('DREAM 90 MCQ''S, A&R, OBJECTIVES', 6),
  ('PYQ - OBJECTIVE & SUBJECTIVE', 7),
  ('DREAM 90 - SA - 20 MKS', 8),
  ('RECTIFY MISTAKES & FINAL REVISION', 9)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%POLLUTION - A RISING ENVIRONMENTAL PROBLEM%')
LIMIT 1;

-- =============================================
-- SUBJECT: CA
-- =============================================

-- =============================================
-- SUBJECT: CHEMISTRY
-- =============================================

-- PERIODIC TABLE (8 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('READ CLASS NOTES', 1),
  ('MAKE LIST OF ALL TRENDS AND EXCEPTIONS', 2),
  ('SOLVE BOOK BACK QUESTIONS', 3),
  ('SOLVE DREAM 90 LWS', 4),
  ('DREAM 90 MCQ AND AR', 5),
  ('DREAM 90 PP SUBJECTIVE', 6),
  ('DREAM 90 PP MCQ', 7),
  ('READ ALL DREAM 90 SOLVED QUESTIONS', 8)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%PERIODIC TABLE%')
LIMIT 1;

-- CHEMICAL BONDING (8 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('READ CLASS NOTES', 1),
  ('DRAW ALL 10 STRUCTURES 3 TIMES', 2),
  ('SOLVE BOOK BACK QUESTIONS', 3),
  ('SOLVE DREAM 90 LWS', 4),
  ('DREAM 90 MCQ AND AR', 5),
  ('DREAM 90 PP SUBJECTIVE', 6),
  ('DREAM 90 PP MCQ', 7),
  ('READ ALL DREAM 90 SOLVED QUESTIONS', 8)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%CHEMICAL BONDING%')
LIMIT 1;

-- ANALYTICAL CHEMISTRY (8 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('READ CLASS NOTES', 1),
  ('WRITE TEST FOR EVERY ION ONCE', 2),
  ('SOLVE BOOK BACK QUESTIONS', 3),
  ('SOLVE DREAM 90 LWS', 4),
  ('DREAM 90 MCQ AND AR', 5),
  ('DREAM 90 PP SUBJECTIVE', 6),
  ('DREAM 90 PP MCQ', 7),
  ('READ ALL DREAM 90 SOLVED QUESTIONS', 8)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%ANALYTICAL CHEMISTRY%')
LIMIT 1;

-- MOLE CONCEPT (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE FORMULA LIST', 1),
  ('SOLVE ALL TEXTBOOK SOLVED EXAMPLES', 2),
  ('SOLVE BOOK BACK QUESTIONS', 3),
  ('SOLVE DREAM 90 LWS', 4),
  ('DREAM 90 MCQ AND AR', 5),
  ('DREAM 90 PP SUBJECTIVE', 6),
  ('DREAM 90 PP MCQ', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%MOLE CONCEPT%')
LIMIT 1;

-- ELECTROLYSIS (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('READ CLASS NOTES', 1),
  ('MAKE LIST OF ALL ELECTROLYSIS PROCESS WITH OBSERVATION AT ELECTRODES', 2),
  ('SOLVE BOOK BACK QUESTIONS', 3),
  ('SOLVE DREAM 90 LWS', 4),
  ('DREAM 90 MCQ AND AR', 5),
  ('DREAM 90 PP SUBJECTIVE', 6),
  ('DREAM 90 PP MCQ', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%ELECTROLYSIS%')
LIMIT 1;

-- METALLURGY (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('READ CLASS NOTES', 1),
  ('PRACTISE REACTIONS OF BAYERS AND HALLS PROCESS', 2),
  ('SOLVE BOOK BACK QUESTIONS', 3),
  ('SOLVE DREAM 90 LWS', 4),
  ('DREAM 90 MCQ AND AR', 5),
  ('DREAM 90 PP SUBJECTIVE', 6),
  ('DREAM 90 PP MCQ', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%METALLURGY%')
LIMIT 1;

-- SULPHURIC ACID (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('READ CLASS NOTES', 1),
  ('PRACTISE ALL REACTIONS 3 TIMES', 2),
  ('SOLVE BOOK BACK QUESTIONS', 3),
  ('SOLVE DREAM 90 LWS', 4),
  ('DREAM 90 MCQ AND AR', 5),
  ('DREAM 90 PP SUBJECTIVE', 6),
  ('DREAM 90 PP MCQ', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%SULPHURIC ACID%')
LIMIT 1;

-- ORGANIC CHEMISTRY (8 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE LIST OF TRICIAL NAMES 3 TIMES', 1),
  ('READ CLASS NOTES', 2),
  ('PRACTISE ALL REACTIONS 3 TIMES', 3),
  ('SOLVE BOOK BACK QUESTIONS', 4),
  ('SOLVE DREAM 90 LWS', 5),
  ('DREAM 90 MCQ AND AR', 6),
  ('DREAM 90 PP SUBJECTIVE', 7),
  ('DREAM 90 PP MCQ', 8)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%ORGANIC CHEMISTRY%')
LIMIT 1;

-- PRACTICAL CHEMISTRY (8 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('WRITE  ALL TESTS THREE TIMES', 1),
  ('READ CLASS NOTES', 2),
  ('SOLVE BOOK BACK QUESTIONS', 3),
  ('SOLVE DREAM 90 LWS', 4),
  ('DREAM 90 MCQ AND AR', 5),
  ('DREAM 90 PP SUBJECTIVE', 6),
  ('DREAM 90 PP MCQ', 7),
  ('READ ALL DREAM 90 SOLVED QUESTIONS', 8)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%PRACTICAL CHEMISTRY%')
LIMIT 1;

-- =============================================
-- SUBJECT: CIVICS
-- =============================================

-- THE UNION PARLIAMENT (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 MCQ', 3),
  ('DREAM 90 2 MARK QUESTION', 4),
  ('DREAM 90 SOLVE 10 MARK BRIEF QUESTION', 5),
  ('DREAK 90 LW', 6),
  ('DREAM 90 TEST PAPER', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%THE UNION PARLIAMENT%')
LIMIT 1;

-- THE PRESIDENT AND VICE PRESIDENT (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 MCQ', 3),
  ('DREAM 90 2 MARK QUESTION', 4),
  ('DREAM 90 SOLVE 10 MARK BRIEF QUESTION', 5),
  ('DREAK 90 LW', 6),
  ('DREAM 90 TEST PAPER', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%THE PRESIDENT AND VICE PRESIDENT%')
LIMIT 1;

-- PRIME MINISTER AND COUNCIL OF MINISTERS (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 MCQ', 3),
  ('DREAM 90 2 MARK QUESTION', 4),
  ('DREAM 90 SOLVE 10 MARK BRIEF QUESTION', 5),
  ('DREAK 90 LW', 6),
  ('DREAM 90 TEST PAPER', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%PRIME MINISTER AND COUNCIL OF MINISTERS%')
LIMIT 1;

-- THE SUPREME COURT (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 MCQ', 3),
  ('DREAM 90 2 MARK QUESTION', 4),
  ('DREAM 90 SOLVE 10 MARK BRIEF QUESTION', 5),
  ('DREAK 90 LW', 6),
  ('DREAM 90 TEST PAPER', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%THE SUPREME COURT%')
LIMIT 1;

-- THE HIGH COURTS AND SUBORDINATE COURTS (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 MCQ', 3),
  ('DREAM 90 2 MARK QUESTION', 4),
  ('DREAM 90 SOLVE 10 MARK BRIEF QUESTION', 5),
  ('DREAK 90 LW', 6),
  ('DREAM 90 TEST PAPER', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%THE HIGH COURTS AND SUBORDINATE COURTS%')
LIMIT 1;

-- =============================================
-- SUBJECT: CS
-- =============================================

-- STAKEHOLDERS IN COMMERCIAL ORGANISATIONS (4 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Read textbook markings', 1),
  ('Revision for weekly test', 2),
  ('Revision for Class Prelim', 3),
  ('Revision for School test', 4)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%STAKEHOLDERS IN COMMERCIAL ORGANISATIONS%')
LIMIT 1;

-- MARKETING AND SALES (4 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Read textbook markings', 1),
  ('Revision for weekly test', 2),
  ('Revision for Class Prelim', 3),
  ('Revision for School test', 4)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%MARKETING AND SALES%')
LIMIT 1;

-- ADVERTISING AND SALES PROMOTION (4 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Read textbook markings', 1),
  ('Revision for weekly test', 2),
  ('Revision for Class Prelim', 3),
  ('Revision for School test', 4)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%ADVERTISING AND SALES PROMOTION%')
LIMIT 1;

-- CONSUMER PROTECTION (4 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Read textbook markings', 1),
  ('Revision for weekly test', 2),
  ('Revision for Class Prelim', 3),
  ('Revision for School test', 4)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%CONSUMER PROTECTION%')
LIMIT 1;

-- E-COMMERCE (4 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Read textbook markings', 1),
  ('Revision for weekly test', 2),
  ('Revision for Class Prelim', 3),
  ('Revision for School test', 4)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%E-COMMERCE%')
LIMIT 1;

-- CAPITAL AND REVENUE EXPENDITURE&INCOME (4 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Read textbook markings', 1),
  ('Revision for weekly test', 2),
  ('Revision for Class Prelim', 3),
  ('Revision for School test', 4)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%CAPITAL AND REVENUE EXPENDITURE&INCOME%')
LIMIT 1;

-- FINAL ACCOUNTS OF SOLE PROPRIETORSHIP (4 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Solve Classwork questions', 1),
  ('Solve Homework questions', 2),
  ('Solve Extra questions', 3),
  ('Revisit all the questions covered earlier', 4)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%FINAL ACCOUNTS OF SOLE PROPRIETORSHIP%')
LIMIT 1;

-- FUNDAMENTAL CONCEPTS OF COST (4 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Read textbook markings', 1),
  ('Revision for weekly test', 2),
  ('Revision for Class Prelim', 3),
  ('Revision for School test', 4)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%FUNDAMENTAL CONCEPTS OF COST%')
LIMIT 1;

-- BUDGETING (4 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Read textbook markings', 1),
  ('Revision for weekly test', 2),
  ('Revision for Class Prelim', 3),
  ('Revision for School test', 4)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%BUDGETING%')
LIMIT 1;

-- SOURCES OF FINANCE (4 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Read textbook markings', 1),
  ('Revision for weekly test', 2),
  ('Revision for Class Prelim', 3),
  ('Revision for School test', 4)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%SOURCES OF FINANCE%')
LIMIT 1;

-- RECRUITMENT SELECTION AND TRAINING (4 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Read textbook markings', 1),
  ('Revision for weekly test', 2),
  ('Revision for Class Prelim', 3),
  ('Revision for School test', 4)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%RECRUITMENT SELECTION AND TRAINING%')
LIMIT 1;

-- INDUSTRIAL RELATIONS, TRADE UNIONS AND SOCIAL SECURITY (4 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Read textbook markings', 1),
  ('Revision for weekly test', 2),
  ('Revision for Class Prelim', 3),
  ('Revision for School test', 4)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%INDUSTRIAL RELATIONS, TRADE UNIONS AND SOCIAL SECURITY%')
LIMIT 1;

-- LOGISTICS AND INSURANCE (4 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Read textbook markings', 1),
  ('Revision for weekly test', 2),
  ('Revision for Class Prelim', 3),
  ('Revision for School test', 4)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%LOGISTICS AND INSURANCE%')
LIMIT 1;

-- BANKING (4 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Read textbook markings', 1),
  ('Revision for weekly test', 2),
  ('Revision for Class Prelim', 3),
  ('Revision for School test', 4)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%BANKING%')
LIMIT 1;

-- STRIVING FOR BETTER ENVIRONMENT (4 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Read textbook markings', 1),
  ('Revision for weekly test', 2),
  ('Revision for Class Prelim', 3),
  ('Revision for School test', 4)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%STRIVING FOR BETTER ENVIRONMENT%')
LIMIT 1;

-- =============================================
-- SUBJECT: ECONOMIC
-- =============================================

-- FACTORS OF PRODUCTION (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('Refer to the Notes Given during the lectures', 2),
  ('Solve MCQ & Questions Given In Text Book', 3),
  ('Study all the questions for the chapter', 4),
  ('SOLVE WORKSHEET GIVEN IN CLASS', 5),
  ('Revise the chapter and provide orals to Parents', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%FACTORS OF PRODUCTION%')
LIMIT 1;

-- ELEMENTARY THEORY OF DEMAND (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('Refer to the Notes Given during the lectures', 2),
  ('Solve MCQ & Questions Given In Text Book', 3),
  ('Study all the questions for the chapter', 4),
  ('SOLVE WORKSHEET GIVEN IN CLASS', 5),
  ('Revise the chapter and provide orals to Parents', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%ELEMENTARY THEORY OF DEMAND%')
LIMIT 1;

-- ELASTICITY OF DEMAND (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('Refer to the Notes Given during the lectures', 2),
  ('Solve MCQ & Questions Given In Text Book', 3),
  ('Study all the questions for the chapter', 4),
  ('SOLVE WORKSHEET GIVEN IN CLASS', 5),
  ('Revise the chapter and provide orals to Parents', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%ELASTICITY OF DEMAND%')
LIMIT 1;

-- THEORY OF SUPPLY (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('Refer to the Notes Given during the lectures', 2),
  ('Solve MCQ & Questions Given In Text Book', 3),
  ('Study all the questions for the chapter', 4),
  ('SOLVE WORKSHEET GIVEN IN CLASS', 5),
  ('Revise the chapter and provide orals to Parents', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%THEORY OF SUPPLY%')
LIMIT 1;

-- MEANING AND TYPES OF MARKET (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('Refer to the Notes Given during the lectures', 2),
  ('Solve MCQ & Questions Given In Text Book', 3),
  ('Study all the questions for the chapter', 4),
  ('SOLVE WORKSHEET GIVEN IN CLASS', 5),
  ('Revise the chapter and provide orals to Parents', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%MEANING AND TYPES OF MARKET%')
LIMIT 1;

-- MEANING AND FUNCTION OF MONEY (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('Refer to the Notes Given during the lectures', 2),
  ('Solve MCQ & Questions Given In Text Book', 3),
  ('Study all the questions for the chapter', 4),
  ('SOLVE WORKSHEET GIVEN IN CLASS', 5),
  ('Revise the chapter and provide orals to Parents', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%MEANING AND FUNCTION OF MONEY%')
LIMIT 1;

-- COMMERCIAL BANK (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('Refer to the Notes Given during the lectures', 2),
  ('Solve MCQ & Questions Given In Text Book', 3),
  ('Study all the questions for the chapter', 4),
  ('SOLVE WORKSHEET GIVEN IN CLASS', 5),
  ('Revise the chapter and provide orals to Parents', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%COMMERCIAL BANK%')
LIMIT 1;

-- CENTRAL BANK (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('Refer to the Notes Given during the lectures', 2),
  ('Solve MCQ & Questions Given In Text Book', 3),
  ('Study all the questions for the chapter', 4),
  ('SOLVE WORKSHEET GIVEN IN CLASS', 5),
  ('Revise the chapter and provide orals to Parents', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%CENTRAL BANK%')
LIMIT 1;

-- INTRODUCTION TO PUBLIC FINANCE (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('Refer to the Notes Given during the lectures', 2),
  ('Solve MCQ & Questions Given In Text Book', 3),
  ('Study all the questions for the chapter', 4),
  ('SOLVE WORKSHEET GIVEN IN CLASS', 5),
  ('Revise the chapter and provide orals to Parents', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%INTRODUCTION TO PUBLIC FINANCE%')
LIMIT 1;

-- PUBLIC REVENUE (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('Refer to the Notes Given during the lectures', 2),
  ('Solve MCQ & Questions Given In Text Book', 3),
  ('Study all the questions for the chapter', 4),
  ('SOLVE WORKSHEET GIVEN IN CLASS', 5),
  ('Revise the chapter and provide orals to Parents', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%PUBLIC REVENUE%')
LIMIT 1;

-- PUBLIC EXPENDITURE (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('Refer to the Notes Given during the lectures', 2),
  ('Solve MCQ & Questions Given In Text Book', 3),
  ('Study all the questions for the chapter', 4),
  ('SOLVE WORKSHEET GIVEN IN CLASS', 5),
  ('Revise the chapter and provide orals to Parents', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%PUBLIC EXPENDITURE%')
LIMIT 1;

-- PUBLIC DEBT (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('Refer to the Notes Given during the lectures', 2),
  ('Solve MCQ & Questions Given In Text Book', 3),
  ('Study all the questions for the chapter', 4),
  ('SOLVE WORKSHEET GIVEN IN CLASS', 5),
  ('Revise the chapter and provide orals to Parents', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%PUBLIC DEBT%')
LIMIT 1;

-- INFLATION (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('Refer to the Notes Given during the lectures', 2),
  ('Solve MCQ & Questions Given In Text Book', 3),
  ('Study all the questions for the chapter', 4),
  ('SOLVE WORKSHEET GIVEN IN CLASS', 5),
  ('Revise the chapter and provide orals to Parents', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%INFLATION%')
LIMIT 1;

-- CONSUMER AWARENESS (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('Refer to the Notes Given during the lectures', 2),
  ('Solve MCQ & Questions Given In Text Book', 3),
  ('Study all the questions for the chapter', 4),
  ('SOLVE WORKSHEET GIVEN IN CLASS', 5),
  ('Revise the chapter and provide orals to Parents', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%CONSUMER AWARENESS%')
LIMIT 1;

-- =============================================
-- SUBJECT: GEOGRAPHY
-- =============================================

-- INTERPRETATION OF TOPOGRAPHICAL MAPS (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('ONLY PRACTISE', 1),
  ('ONLY PRACTISE', 2),
  ('ONLY PRACTISE', 3),
  ('ONLY PRACTISE', 4),
  ('ONLY PRACTISE', 5),
  ('ONLY PRACTISE', 6),
  ('ONLY PRACTISE', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%INTERPRETATION OF TOPOGRAPHICAL MAPS%')
LIMIT 1;

-- MAP OF INDIA (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('ONLY PRACTISE', 1),
  ('ONLY PRACTISE', 2),
  ('ONLY PRACTISE', 3),
  ('ONLY PRACTISE', 4),
  ('ONLY PRACTISE', 5),
  ('ONLY PRACTISE', 6),
  ('ONLY PRACTISE', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%MAP OF INDIA%')
LIMIT 1;

-- CLIMATE (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 GIVE REAOSNS + MCQ', 3),
  ('DREAM 90 ALL REMAINING QUESTIONS', 4),
  ('DREAK 90 LW', 5),
  ('DREAM 90 TEST PAPER', 6),
  ('PY QUESTIONS', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%CLIMATE%')
LIMIT 1;

-- SOIL RESOURCES (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 GIVE REAOSNS + MCQ', 3),
  ('DREAM 90 ALL REMAINING QUESTIONS', 4),
  ('DREAK 90 LW', 5),
  ('DREAM 90 TEST PAPER', 6),
  ('PY QUESTIONS', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%SOIL RESOURCES%')
LIMIT 1;

-- NATURAL VEGETATION (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 GIVE REAOSNS + MCQ', 3),
  ('DREAM 90 ALL REMAINING QUESTIONS', 4),
  ('DREAK 90 LW', 5),
  ('DREAM 90 TEST PAPER', 6),
  ('PY QUESTIONS', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%NATURAL VEGETATION%')
LIMIT 1;

-- WATER RESOURCES (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 GIVE REAOSNS + MCQ', 3),
  ('DREAM 90 ALL REMAINING QUESTIONS', 4),
  ('DREAK 90 LW', 5),
  ('DREAM 90 TEST PAPER', 6),
  ('PY QUESTIONS', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%WATER RESOURCES%')
LIMIT 1;

-- MINERAL RESOURCES (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 GIVE REAOSNS + MCQ', 3),
  ('DREAM 90 ALL REMAINING QUESTIONS', 4),
  ('DREAK 90 LW', 5),
  ('DREAM 90 TEST PAPER', 6),
  ('PY QUESTIONS', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%MINERAL RESOURCES%')
LIMIT 1;

-- CONVENTIONAL SOURCES OF ENERGY (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 GIVE REAOSNS + MCQ', 3),
  ('DREAM 90 ALL REMAINING QUESTIONS', 4),
  ('DREAK 90 LW', 5),
  ('DREAM 90 TEST PAPER', 6),
  ('PY QUESTIONS', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%CONVENTIONAL SOURCES OF ENERGY%')
LIMIT 1;

-- NON-CONVENTIONAL SOURCES OF ENERGY (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 GIVE REAOSNS + MCQ', 3),
  ('DREAM 90 ALL REMAINING QUESTIONS', 4),
  ('DREAK 90 LW', 5),
  ('DREAM 90 TEST PAPER', 6),
  ('PY QUESTIONS', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%NON-CONVENTIONAL SOURCES OF ENERGY%')
LIMIT 1;

-- AGRICULTURE-I (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 GIVE REAOSNS + MCQ', 3),
  ('DREAM 90 ALL REMAINING QUESTIONS', 4),
  ('DREAK 90 LW', 5),
  ('DREAM 90 TEST PAPER', 6),
  ('PY QUESTIONS', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%AGRICULTURE-I%')
LIMIT 1;

-- AGRICULTURE-II : FOOD CROPS (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 GIVE REAOSNS + MCQ', 3),
  ('DREAM 90 ALL REMAINING QUESTIONS', 4),
  ('DREAK 90 LW', 5),
  ('DREAM 90 TEST PAPER', 6),
  ('PY QUESTIONS', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%AGRICULTURE-II : FOOD CROPS%')
LIMIT 1;

-- AGRICULTURE-III : CASH CROPS (1) (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 GIVE REAOSNS + MCQ', 3),
  ('DREAM 90 ALL REMAINING QUESTIONS', 4),
  ('DREAK 90 LW', 5),
  ('DREAM 90 TEST PAPER', 6),
  ('PY QUESTIONS', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%AGRICULTURE-III : CASH CROPS (1)%')
LIMIT 1;

-- AGRICULTURE-IV : CASH CROPS (2) (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 GIVE REAOSNS + MCQ', 3),
  ('DREAM 90 ALL REMAINING QUESTIONS', 4),
  ('DREAK 90 LW', 5),
  ('DREAM 90 TEST PAPER', 6),
  ('PY QUESTIONS', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%AGRICULTURE-IV : CASH CROPS (2)%')
LIMIT 1;

-- MANUFACTURING INDUSTRIES AGRO- BASED (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 GIVE REAOSNS + MCQ', 3),
  ('DREAM 90 ALL REMAINING QUESTIONS', 4),
  ('DREAK 90 LW', 5),
  ('DREAM 90 TEST PAPER', 6),
  ('PY QUESTIONS', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%MANUFACTURING INDUSTRIES AGRO- BASED%')
LIMIT 1;

-- MINERAL BASED INDUSTRY (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 GIVE REAOSNS + MCQ', 3),
  ('DREAM 90 ALL REMAINING QUESTIONS', 4),
  ('DREAK 90 LW', 5),
  ('DREAM 90 TEST PAPER', 6),
  ('PY QUESTIONS', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%MINERAL BASED INDUSTRY%')
LIMIT 1;

-- TRANSPORT (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 GIVE REAOSNS + MCQ', 3),
  ('DREAM 90 ALL REMAINING QUESTIONS', 4),
  ('DREAK 90 LW', 5),
  ('DREAM 90 TEST PAPER', 6),
  ('PY QUESTIONS', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%TRANSPORT%')
LIMIT 1;

-- IMPACT OF WASTE ACCUMULATION (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 GIVE REAOSNS + MCQ', 3),
  ('DREAM 90 ALL REMAINING QUESTIONS', 4),
  ('DREAK 90 LW', 5),
  ('DREAM 90 TEST PAPER', 6),
  ('PY QUESTIONS', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%IMPACT OF WASTE ACCUMULATION%')
LIMIT 1;

-- NEED FOR WASTE MANAGEMENT (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 GIVE REAOSNS + MCQ', 3),
  ('DREAM 90 ALL REMAINING QUESTIONS', 4),
  ('DREAK 90 LW', 5),
  ('DREAM 90 TEST PAPER', 6),
  ('PY QUESTIONS', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%NEED FOR WASTE MANAGEMENT%')
LIMIT 1;

-- =============================================
-- SUBJECT: HINDI
-- =============================================

-- =============================================
-- SUBJECT: HISTORY
-- =============================================

-- THE FIRST WAR IF INDEPENDENCE,1857 (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 MCQ', 3),
  ('DREAM 90 2 MARK QUESTION', 4),
  ('DREAM 90 SOLVE 10 MARK BRIEF QUESTION', 5),
  ('DREAK 90 LW', 6),
  ('DREAM 90 TEST PAPER', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%THE FIRST WAR IF INDEPENDENCE,1857%')
LIMIT 1;

-- GROWTH OF NATIONALISM (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 MCQ', 3),
  ('DREAM 90 2 MARK QUESTION', 4),
  ('DREAM 90 SOLVE 10 MARK BRIEF QUESTION', 5),
  ('DREAK 90 LW', 6),
  ('DREAM 90 TEST PAPER', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%GROWTH OF NATIONALISM%')
LIMIT 1;

-- FIRST PHASE OF THE INDIAN NATIONAL MOVEMENT (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 MCQ', 3),
  ('DREAM 90 2 MARK QUESTION', 4),
  ('DREAM 90 SOLVE 10 MARK BRIEF QUESTION', 5),
  ('DREAK 90 LW', 6),
  ('DREAM 90 TEST PAPER', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%FIRST PHASE OF THE INDIAN NATIONAL MOVEMENT%')
LIMIT 1;

-- SECOND PHASE OF THE INDIAN NATIONAL MOVEMENT (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 MCQ', 3),
  ('DREAM 90 2 MARK QUESTION', 4),
  ('DREAM 90 SOLVE 10 MARK BRIEF QUESTION', 5),
  ('DREAK 90 LW', 6),
  ('DREAM 90 TEST PAPER', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%SECOND PHASE OF THE INDIAN NATIONAL MOVEMENT%')
LIMIT 1;

-- THE MUSLIM LEAGUE (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 MCQ', 3),
  ('DREAM 90 2 MARK QUESTION', 4),
  ('DREAM 90 SOLVE 10 MARK BRIEF QUESTION', 5),
  ('DREAK 90 LW', 6),
  ('DREAM 90 TEST PAPER', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%THE MUSLIM LEAGUE%')
LIMIT 1;

-- MAHATMA GANDHI (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 MCQ', 3),
  ('DREAM 90 2 MARK QUESTION', 4),
  ('DREAM 90 SOLVE 10 MARK BRIEF QUESTION', 5),
  ('DREAK 90 LW', 6),
  ('DREAM 90 TEST PAPER', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%MAHATMA GANDHI%')
LIMIT 1;

-- QUIT INDIA MOVEMENT (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 MCQ', 3),
  ('DREAM 90 2 MARK QUESTION', 4),
  ('DREAM 90 SOLVE 10 MARK BRIEF QUESTION', 5),
  ('DREAK 90 LW', 6),
  ('DREAM 90 TEST PAPER', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%QUIT INDIA MOVEMENT%')
LIMIT 1;

-- FORWARD BLOC AND THE INA (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 MCQ', 3),
  ('DREAM 90 2 MARK QUESTION', 4),
  ('DREAM 90 SOLVE 10 MARK BRIEF QUESTION', 5),
  ('DREAK 90 LW', 6),
  ('DREAM 90 TEST PAPER', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%FORWARD BLOC AND THE INA%')
LIMIT 1;

-- INDEPENDENCE AND PARTITION OF INDIA (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 MCQ', 3),
  ('DREAM 90 2 MARK QUESTION', 4),
  ('DREAM 90 SOLVE 10 MARK BRIEF QUESTION', 5),
  ('DREAK 90 LW', 6),
  ('DREAM 90 TEST PAPER', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%INDEPENDENCE AND PARTITION OF INDIA%')
LIMIT 1;

-- THE FIRST WORLD WAR (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 MCQ', 3),
  ('DREAM 90 2 MARK QUESTION', 4),
  ('DREAM 90 SOLVE 10 MARK BRIEF QUESTION', 5),
  ('DREAK 90 LW', 6),
  ('DREAM 90 TEST PAPER', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%THE FIRST WORLD WAR%')
LIMIT 1;

-- RISE OF DICTATORSHIP (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 MCQ', 3),
  ('DREAM 90 2 MARK QUESTION', 4),
  ('DREAM 90 SOLVE 10 MARK BRIEF QUESTION', 5),
  ('DREAK 90 LW', 6),
  ('DREAM 90 TEST PAPER', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%RISE OF DICTATORSHIP%')
LIMIT 1;

-- THE SECOND WORLD WAR (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 MCQ', 3),
  ('DREAM 90 2 MARK QUESTION', 4),
  ('DREAM 90 SOLVE 10 MARK BRIEF QUESTION', 5),
  ('DREAK 90 LW', 6),
  ('DREAM 90 TEST PAPER', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%THE SECOND WORLD WAR%')
LIMIT 1;

-- UNITED NATIONS (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 MCQ', 3),
  ('DREAM 90 2 MARK QUESTION', 4),
  ('DREAM 90 SOLVE 10 MARK BRIEF QUESTION', 5),
  ('DREAK 90 LW', 6),
  ('DREAM 90 TEST PAPER', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%UNITED NATIONS%')
LIMIT 1;

-- MAJOR AGENCIES OF THE UNITED NATIONS (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 MCQ', 3),
  ('DREAM 90 2 MARK QUESTION', 4),
  ('DREAM 90 SOLVE 10 MARK BRIEF QUESTION', 5),
  ('DREAK 90 LW', 6),
  ('DREAM 90 TEST PAPER', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%MAJOR AGENCIES OF THE UNITED NATIONS%')
LIMIT 1;

-- NON-ALIGNED MOVEMENT (7 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTUAL QUESTION', 2),
  ('DREAM 90 MCQ', 3),
  ('DREAM 90 2 MARK QUESTION', 4),
  ('DREAM 90 SOLVE 10 MARK BRIEF QUESTION', 5),
  ('DREAK 90 LW', 6),
  ('DREAM 90 TEST PAPER', 7)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%NON-ALIGNED MOVEMENT%')
LIMIT 1;

-- =============================================
-- SUBJECT: LANGUAGE
-- =============================================

-- EMAIL & NOTICE WRITING (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Write down Board Approved Format', 1),
  ('Write down 2 Specimens and get it checked', 2),
  ('Write 5 topics from Dream 90 to build confidence', 3),
  ('Solve the questions from Board Papers', 4),
  ('Solve similar questions from Total English', 5),
  ('Solve all worksheets given by teacher', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%EMAIL & NOTICE WRITING%')
LIMIT 1;

-- FORMAL & INFORMAL LETTER WRITING (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Write down Board Approved Format', 1),
  ('Write down 2 Specimens and get it checked', 2),
  ('Write 5 topics from Dream 90 to build confidence', 3),
  ('Solve the questions from Board Papers', 4),
  ('Solve similar questions from Total English', 5),
  ('Solve all worksheets given by teacher', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%FORMAL & INFORMAL LETTER WRITING%')
LIMIT 1;

-- SUBJECT VERB (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Understand the topic in class', 1),
  ('Solve worksheets given by the teacher on the topic', 2),
  ('Solve questions from Dream 90', 3),
  ('Solve similar questions from Board Papers', 4),
  ('Solve similar questions from Total English', 5),
  ('Solve a mixed bag question set from Prelim Papers', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%SUBJECT VERB%')
LIMIT 1;

-- PREPOSITION (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Understand the topic in class', 1),
  ('Solve worksheets given by the teacher on the topic', 2),
  ('Solve questions from Dream 90', 3),
  ('Solve similar questions from Board Papers', 4),
  ('Solve similar questions from Total English', 5),
  ('Solve a mixed bag question set from Prelim Papers', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%PREPOSITION%')
LIMIT 1;

-- SYNTHESIS (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Understand the topic in class', 1),
  ('Solve worksheets given by the teacher on the topic', 2),
  ('Solve questions from Dream 90', 3),
  ('Solve similar questions from Board Papers', 4),
  ('Solve similar questions from Total English', 5),
  ('Solve a mixed bag question set from Prelim Papers', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%SYNTHESIS%')
LIMIT 1;

-- TRANSFORMATION OF SENTENCES (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Understand the topic in class', 1),
  ('Solve worksheets given by the teacher on the topic', 2),
  ('Solve questions from Dream 90', 3),
  ('Solve similar questions from Board Papers', 4),
  ('Solve similar questions from Total English', 5),
  ('Solve a mixed bag question set from Prelim Papers', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%TRANSFORMATION OF SENTENCES%')
LIMIT 1;

-- COMPREHENSION (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Understand the topic in class', 1),
  ('Solve worksheets given by the teacher on the topic', 2),
  ('Solve questions from Dream 90', 3),
  ('Solve similar questions from Board Papers', 4),
  ('Solve similar questions from Total English', 5),
  ('Solve a mixed bag question set from Prelim Papers', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%COMPREHENSION%')
LIMIT 1;

-- DEGREES  OF COMPARISON (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Understand the topic in class', 1),
  ('Solve worksheets given by the teacher on the topic', 2),
  ('Solve questions from Dream 90', 3),
  ('Solve similar questions from Board Papers', 4),
  ('Solve similar questions from Total English', 5),
  ('Solve a mixed bag question set from Prelim Papers', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%DEGREES  OF COMPARISON%')
LIMIT 1;

-- STORY WRITING (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Write down Board Approved Format', 1),
  ('Write down 2 Specimens and get it checked', 2),
  ('Solve topics from Dream 90', 3),
  ('Solve similar questions from Board Papers', 4),
  ('Solve similar questions from Total English', 5),
  ('Solve Questions from Prelim Papers', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%STORY WRITING%')
LIMIT 1;

-- ARGUMENTATIVE ESSAY (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Write down Board Approved Format', 1),
  ('Write down 2 Specimens and get it checked', 2),
  ('Solve topics from Dream 90', 3),
  ('Solve similar questions from Board Papers', 4),
  ('Solve similar questions from Total English', 5),
  ('Solve Questions from Prelim Papers', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%ARGUMENTATIVE ESSAY%')
LIMIT 1;

-- DESCRIPTIVE ESSAY (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Write down Board Approved Format', 1),
  ('Write down 2 Specimens and get it checked', 2),
  ('Solve topics from Dream 90', 3),
  ('Solve similar questions from Board Papers', 4),
  ('Solve similar questions from Total English', 5),
  ('Solve Questions from Prelim Papers', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%DESCRIPTIVE ESSAY%')
LIMIT 1;

-- NARRATIVE ESSAY (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Write down Board Approved Format', 1),
  ('Write down 2 Specimens and get it checked', 2),
  ('Solve topics from Dream 90', 3),
  ('Solve similar questions from Board Papers', 4),
  ('Solve similar questions from Total English', 5),
  ('Solve Questions from Prelim Papers', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%NARRATIVE ESSAY%')
LIMIT 1;

-- PICTURE COMPOSTION (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Write down Board Approved Format', 1),
  ('Write down 2 Specimens and get it checked', 2),
  ('Solve topics from Dream 90', 3),
  ('Solve similar questions from Board Papers', 4),
  ('Solve similar questions from Total English', 5),
  ('Solve Questions from Prelim Papers', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%PICTURE COMPOSTION%')
LIMIT 1;

-- ARTICLES (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Understand the topic in class', 1),
  ('Solve worksheets given by the teacher on the topic', 2),
  ('Solve questions from Dream 90', 3),
  ('Solve similar questions from Board Papers', 4),
  ('Solve similar questions from Total English', 5),
  ('Solve Questions from Prelim Papers', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%ARTICLES%')
LIMIT 1;

-- TENSES (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Understand the topic in class', 1),
  ('Solve worksheets given by the teacher on the topic', 2),
  ('Solve questions from Dream 90', 3),
  ('Solve similar questions from Board Papers', 4),
  ('Solve similar questions from Total English', 5),
  ('Solve Questions from Prelim Papers', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%TENSES%')
LIMIT 1;

-- GRID WRITNG (6 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('Understand the topic in class', 1),
  ('Solve worksheets given by the teacher on the topic', 2),
  ('Solve questions from Dream 90', 3),
  ('Solve similar questions from Board Papers', 4),
  ('Solve similar questions from Total English', 5),
  ('Solve Questions from Prelim Papers', 6)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%GRID WRITNG%')
LIMIT 1;

-- =============================================
-- SUBJECT: LITERATURE
-- =============================================

-- =============================================
-- SUBJECT: MATHS
-- =============================================

-- GOODS AND SERVICE TAX (11 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE SUMMARY OF CHAPTER', 1),
  ('SOLVED EXAMPLE FROM TEXTBOOK', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 4),
  ('SOLVE TEST PAPER 1', 5),
  ('SOLVE TEST PAPER 2', 6),
  ('SOLVE TEST PAPER 3', 7),
  ('SOLVE TEST PAPER 4', 8),
  ('SOLVE TEST PAPER 5', 9),
  ('DO ALL MCQ AND AR FROM D90', 10),
  ('SOLVE MCQ PRACTISE PAPER', 11)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%GOODS AND SERVICE TAX%')
LIMIT 1;

-- BANKING (11 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE SUMMARY OF CHAPTER', 1),
  ('SOLVED EXAMPLE FROM TEXTBOOK', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 4),
  ('SOLVE TEST PAPER 1', 5),
  ('SOLVE TEST PAPER 2', 6),
  ('SOLVE TEST PAPER 3', 7),
  ('SOLVE TEST PAPER 4', 8),
  ('SOLVE TEST PAPER 5', 9),
  ('DO ALL MCQ AND AR FROM D90', 10),
  ('SOLVE MCQ PRACTISE PAPER', 11)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%BANKING%')
LIMIT 1;

-- SHARES AND DIVIDENDS (11 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE SUMMARY OF CHAPTER', 1),
  ('SOLVED EXAMPLE FROM TEXTBOOK', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 4),
  ('SOLVE TEST PAPER 1', 5),
  ('SOLVE TEST PAPER 2', 6),
  ('SOLVE TEST PAPER 3', 7),
  ('SOLVE TEST PAPER 4', 8),
  ('SOLVE TEST PAPER 5', 9),
  ('DO ALL MCQ AND AR FROM D90', 10),
  ('SOLVE MCQ PRACTISE PAPER', 11)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%SHARES AND DIVIDENDS%')
LIMIT 1;

-- LINEAR INEQUALITIES (11 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE SUMMARY OF CHAPTER', 1),
  ('SOLVED EXAMPLE FROM TEXTBOOK', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 4),
  ('SOLVE TEST PAPER 1', 5),
  ('SOLVE TEST PAPER 2', 6),
  ('SOLVE TEST PAPER 3', 7),
  ('SOLVE TEST PAPER 4', 8),
  ('SOLVE TEST PAPER 5', 9),
  ('DO ALL MCQ AND AR FROM D90', 10),
  ('SOLVE MCQ PRACTISE PAPER', 11)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%LINEAR INEQUALITIES%')
LIMIT 1;

-- QUADRATIC EQUATIONS (11 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE SUMMARY OF CHAPTER', 1),
  ('SOLVED EXAMPLE FROM TEXTBOOK', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 4),
  ('SOLVE TEST PAPER 1', 5),
  ('SOLVE TEST PAPER 2', 6),
  ('SOLVE TEST PAPER 3', 7),
  ('SOLVE TEST PAPER 4', 8),
  ('SOLVE TEST PAPER 5', 9),
  ('DO ALL MCQ AND AR FROM D90', 10),
  ('SOLVE MCQ PRACTISE PAPER', 11)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%QUADRATIC EQUATIONS%')
LIMIT 1;

-- SOLVING PROBLEM QUADRATIC EQUATIONS (11 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE SUMMARY OF CHAPTER', 1),
  ('SOLVED EXAMPLE FROM TEXTBOOK', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 4),
  ('SOLVE TEST PAPER 1', 5),
  ('SOLVE TEST PAPER 2', 6),
  ('SOLVE TEST PAPER 3', 7),
  ('SOLVE TEST PAPER 4', 8),
  ('SOLVE TEST PAPER 5', 9),
  ('DO ALL MCQ AND AR FROM D90', 10),
  ('SOLVE MCQ PRACTISE PAPER', 11)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%SOLVING PROBLEM QUADRATIC EQUATIONS%')
LIMIT 1;

-- RATIO AND PROPORTION (11 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE SUMMARY OF CHAPTER', 1),
  ('SOLVED EXAMPLE FROM TEXTBOOK', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 4),
  ('SOLVE TEST PAPER 1', 5),
  ('SOLVE TEST PAPER 2', 6),
  ('SOLVE TEST PAPER 3', 7),
  ('SOLVE TEST PAPER 4', 8),
  ('SOLVE TEST PAPER 5', 9),
  ('DO ALL MCQ AND AR FROM D90', 10),
  ('SOLVE MCQ PRACTISE PAPER', 11)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%RATIO AND PROPORTION%')
LIMIT 1;

-- REMAINDER AND FACTOR THEOREM (FACTORISATION  OF POLYNOMIAL) (11 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE SUMMARY OF CHAPTER', 1),
  ('SOLVED EXAMPLE FROM TEXTBOOK', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 4),
  ('SOLVE TEST PAPER 1', 5),
  ('SOLVE TEST PAPER 2', 6),
  ('SOLVE TEST PAPER 3', 7),
  ('SOLVE TEST PAPER 4', 8),
  ('SOLVE TEST PAPER 5', 9),
  ('DO ALL MCQ AND AR FROM D90', 10),
  ('SOLVE MCQ PRACTISE PAPER', 11)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%REMAINDER AND FACTOR THEOREM (FACTORISATION  OF POLYNOMIAL)%')
LIMIT 1;

-- MATRICES (11 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE SUMMARY OF CHAPTER', 1),
  ('SOLVED EXAMPLE FROM TEXTBOOK', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 4),
  ('SOLVE TEST PAPER 1', 5),
  ('SOLVE TEST PAPER 2', 6),
  ('SOLVE TEST PAPER 3', 7),
  ('SOLVE TEST PAPER 4', 8),
  ('SOLVE TEST PAPER 5', 9),
  ('DO ALL MCQ AND AR FROM D90', 10),
  ('SOLVE MCQ PRACTISE PAPER', 11)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%MATRICES%')
LIMIT 1;

-- ARITHMETIC  PROGRESSION (11 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE SUMMARY OF CHAPTER', 1),
  ('SOLVED EXAMPLE FROM TEXTBOOK', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 4),
  ('SOLVE TEST PAPER 1', 5),
  ('SOLVE TEST PAPER 2', 6),
  ('SOLVE TEST PAPER 3', 7),
  ('SOLVE TEST PAPER 4', 8),
  ('SOLVE TEST PAPER 5', 9),
  ('DO ALL MCQ AND AR FROM D90', 10),
  ('SOLVE MCQ PRACTISE PAPER', 11)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%ARITHMETIC  PROGRESSION%')
LIMIT 1;

-- GEOMETRIC PROGRESSION (11 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE SUMMARY OF CHAPTER', 1),
  ('SOLVED EXAMPLE FROM TEXTBOOK', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 4),
  ('SOLVE TEST PAPER 1', 5),
  ('SOLVE TEST PAPER 2', 6),
  ('SOLVE TEST PAPER 3', 7),
  ('SOLVE TEST PAPER 4', 8),
  ('SOLVE TEST PAPER 5', 9),
  ('DO ALL MCQ AND AR FROM D90', 10),
  ('SOLVE MCQ PRACTISE PAPER', 11)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%GEOMETRIC PROGRESSION%')
LIMIT 1;

-- REFLECTION (11 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE SUMMARY OF CHAPTER', 1),
  ('SOLVED EXAMPLE FROM TEXTBOOK', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 4),
  ('SOLVE TEST PAPER 1', 5),
  ('SOLVE TEST PAPER 2', 6),
  ('SOLVE TEST PAPER 3', 7),
  ('SOLVE TEST PAPER 4', 8),
  ('SOLVE TEST PAPER 5', 9),
  ('DO ALL MCQ AND AR FROM D90', 10),
  ('SOLVE MCQ PRACTISE PAPER', 11)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%REFLECTION%')
LIMIT 1;

-- SECTION  AND MID POINT FORMULA (11 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE SUMMARY OF CHAPTER', 1),
  ('SOLVED EXAMPLE FROM TEXTBOOK', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 4),
  ('SOLVE TEST PAPER 1', 5),
  ('SOLVE TEST PAPER 2', 6),
  ('SOLVE TEST PAPER 3', 7),
  ('SOLVE TEST PAPER 4', 8),
  ('SOLVE TEST PAPER 5', 9),
  ('DO ALL MCQ AND AR FROM D90', 10),
  ('SOLVE MCQ PRACTISE PAPER', 11)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%SECTION  AND MID POINT FORMULA%')
LIMIT 1;

-- EQUATION OF A STRAIGHT LINE (11 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE SUMMARY OF CHAPTER', 1),
  ('SOLVED EXAMPLE FROM TEXTBOOK', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 4),
  ('SOLVE TEST PAPER 1', 5),
  ('SOLVE TEST PAPER 2', 6),
  ('SOLVE TEST PAPER 3', 7),
  ('SOLVE TEST PAPER 4', 8),
  ('SOLVE TEST PAPER 5', 9),
  ('DO ALL MCQ AND AR FROM D90', 10),
  ('SOLVE MCQ PRACTISE PAPER', 11)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%EQUATION OF A STRAIGHT LINE%')
LIMIT 1;

-- SIMILARITY (11 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE SUMMARY OF CHAPTER', 1),
  ('SOLVED EXAMPLE FROM TEXTBOOK', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 4),
  ('SOLVE TEST PAPER 1', 5),
  ('SOLVE TEST PAPER 2', 6),
  ('SOLVE TEST PAPER 3', 7),
  ('SOLVE TEST PAPER 4', 8),
  ('SOLVE TEST PAPER 5', 9),
  ('DO ALL MCQ AND AR FROM D90', 10),
  ('SOLVE MCQ PRACTISE PAPER', 11)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%SIMILARITY%')
LIMIT 1;

-- LOCUS (11 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE SUMMARY OF CHAPTER', 1),
  ('SOLVED EXAMPLE FROM TEXTBOOK', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 4),
  ('SOLVE TEST PAPER 1', 5),
  ('SOLVE TEST PAPER 2', 6),
  ('SOLVE TEST PAPER 3', 7),
  ('SOLVE TEST PAPER 4', 8),
  ('SOLVE TEST PAPER 5', 9),
  ('DO ALL MCQ AND AR FROM D90', 10),
  ('SOLVE MCQ PRACTISE PAPER', 11)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%LOCUS%')
LIMIT 1;

-- CIRCLES (11 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE SUMMARY OF CHAPTER', 1),
  ('SOLVED EXAMPLE FROM TEXTBOOK', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 4),
  ('SOLVE TEST PAPER 1', 5),
  ('SOLVE TEST PAPER 2', 6),
  ('SOLVE TEST PAPER 3', 7),
  ('SOLVE TEST PAPER 4', 8),
  ('SOLVE TEST PAPER 5', 9),
  ('DO ALL MCQ AND AR FROM D90', 10),
  ('SOLVE MCQ PRACTISE PAPER', 11)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%CIRCLES%')
LIMIT 1;

-- CONSTRUCTIONS (10 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('SOLVED EXAMPLE FROM TEXTBOOK', 1),
  ('BOOK BACK QUESTIONS', 2),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 3),
  ('SOLVE TEST PAPER 1', 4),
  ('SOLVE TEST PAPER 2', 5),
  ('SOLVE TEST PAPER 3', 6),
  ('SOLVE TEST PAPER 4', 7),
  ('SOLVE TEST PAPER 5', 8),
  ('DO ALL MCQ AND AR FROM D90', 9),
  ('SOLVE MCQ PRACTISE PAPER', 10)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%CONSTRUCTIONS%')
LIMIT 1;

-- MENSURATION (11 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE SUMMARY OF CHAPTER', 1),
  ('SOLVED EXAMPLE FROM TEXTBOOK', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 4),
  ('SOLVE TEST PAPER 1', 5),
  ('SOLVE TEST PAPER 2', 6),
  ('SOLVE TEST PAPER 3', 7),
  ('SOLVE TEST PAPER 4', 8),
  ('SOLVE TEST PAPER 5', 9),
  ('DO ALL MCQ AND AR FROM D90', 10),
  ('SOLVE MCQ PRACTISE PAPER', 11)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%MENSURATION%')
LIMIT 1;

-- TRIGONOMETRY IDENTITIES (11 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE SUMMARY OF CHAPTER', 1),
  ('SOLVED EXAMPLE FROM TEXTBOOK', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 4),
  ('SOLVE TEST PAPER 1', 5),
  ('SOLVE TEST PAPER 2', 6),
  ('SOLVE TEST PAPER 3', 7),
  ('SOLVE TEST PAPER 4', 8),
  ('SOLVE TEST PAPER 5', 9),
  ('DO ALL MCQ AND AR FROM D90', 10),
  ('SOLVE MCQ PRACTISE PAPER', 11)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%TRIGONOMETRY IDENTITIES%')
LIMIT 1;

-- HIGHT & DISTANCE (11 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE SUMMARY OF CHAPTER', 1),
  ('SOLVED EXAMPLE FROM TEXTBOOK', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 4),
  ('SOLVE TEST PAPER 1', 5),
  ('SOLVE TEST PAPER 2', 6),
  ('SOLVE TEST PAPER 3', 7),
  ('SOLVE TEST PAPER 4', 8),
  ('SOLVE TEST PAPER 5', 9),
  ('DO ALL MCQ AND AR FROM D90', 10),
  ('SOLVE MCQ PRACTISE PAPER', 11)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%HIGHT & DISTANCE%')
LIMIT 1;

-- GRAPHICAL REPRESENTATION (11 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE SUMMARY OF CHAPTER', 1),
  ('SOLVED EXAMPLE FROM TEXTBOOK', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 4),
  ('SOLVE TEST PAPER 1', 5),
  ('SOLVE TEST PAPER 2', 6),
  ('SOLVE TEST PAPER 3', 7),
  ('SOLVE TEST PAPER 4', 8),
  ('SOLVE TEST PAPER 5', 9),
  ('DO ALL MCQ AND AR FROM D90', 10),
  ('SOLVE MCQ PRACTISE PAPER', 11)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%GRAPHICAL REPRESENTATION%')
LIMIT 1;

-- PROBABILITY (11 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('MAKE SUMMARY OF CHAPTER', 1),
  ('SOLVED EXAMPLE FROM TEXTBOOK', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('SOLVE MISCELLENOUS AND BOARD QUESTIONS', 4),
  ('SOLVE TEST PAPER 1', 5),
  ('SOLVE TEST PAPER 2', 6),
  ('SOLVE TEST PAPER 3', 7),
  ('SOLVE TEST PAPER 4', 8),
  ('SOLVE TEST PAPER 5', 9),
  ('DO ALL MCQ AND AR FROM D90', 10),
  ('SOLVE MCQ PRACTISE PAPER', 11)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%PROBABILITY%')
LIMIT 1;

-- =============================================
-- SUBJECT: PHYSICS
-- =============================================

-- FORCE (8 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTBOOK SOLVED EXAMPLES', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('ALL LWS', 4),
  ('DREAM 90 MCQ AND AR', 5),
  ('DREAM 90 PP MCQ', 6),
  ('DREAM 90 PP SUBJECTIVE', 7),
  ('DREAM 90 SOLVED NUMERICALS', 8)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%FORCE%')
LIMIT 1;

-- WORK, ENERGY & POWER (8 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTBOOK SOLVED EXAMPLES', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('ALL LWS', 4),
  ('DREAM 90 MCQ AND AR', 5),
  ('DREAM 90 PP MCQ', 6),
  ('DREAM 90 PP SUBJECTIVE', 7),
  ('DREAM 90 SOLVED NUMERICALS', 8)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%WORK, ENERGY & POWER%')
LIMIT 1;

-- MACHINE (9 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTBOOK SOLVED EXAMPLES', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('PRACTISE PULLEY DIAGRAMS', 4),
  ('ALL LWS', 5),
  ('DREAM 90 MCQ AND AR', 6),
  ('DREAM 90 PP MCQ', 7),
  ('DREAM 90 PP SUBJECTIVE', 8),
  ('DREAM 90 SOLVED NUMERICALS', 9)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%MACHINE%')
LIMIT 1;

-- REFRACTION OF LIGHT AT PLANE SURFACE (9 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('WRITE ALL FACTORS', 2),
  ('TEXTBOOK SOLVED EXAMPLES', 3),
  ('BOOK BACK QUESTIONS', 4),
  ('PRACTISE ALL DIAGRAMS', 5),
  ('ALL LWS', 6),
  ('DREAM 90 MCQ AND AR', 7),
  ('DREAM 90 PP MCQ', 8),
  ('DREAM 90 PP SUBJECTIVE', 9)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%REFRACTION OF LIGHT AT PLANE SURFACE%')
LIMIT 1;

-- REFRACTION THROUGH A LENS (10 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('WRITE ALL FACTORS', 2),
  ('TEXTBOOK SOLVED EXAMPLES', 3),
  ('BOOK BACK QUESTIONS', 4),
  ('PRACTISE ALL RAY DIAGRAMS', 5),
  ('ALL LWS', 6),
  ('DREAM 90 MCQ AND AR', 7),
  ('DREAM 90 PP MCQ', 8),
  ('DREAM 90 PP SUBJECTIVE', 9),
  ('DREAM 90 SOLVED NUMERICALS', 10)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%REFRACTION THROUGH A LENS%')
LIMIT 1;

-- SPECTRUM (8 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('DREAM 90 ALL GIVE REASONS', 2),
  ('TEXTBOOK SOLVED EXAMPLES', 3),
  ('BOOK BACK QUESTIONS', 4),
  ('ALL LWS', 5),
  ('DREAM 90 MCQ AND AR', 6),
  ('DREAM 90 PP MCQ', 7),
  ('DREAM 90 PP SUBJECTIVE', 8)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%SPECTRUM%')
LIMIT 1;

-- SOUND (8 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('DREAM 90 ALL GIVE REASONS', 2),
  ('TEXTBOOK SOLVED EXAMPLES', 3),
  ('BOOK BACK QUESTIONS', 4),
  ('ALL LWS', 5),
  ('DREAM 90 MCQ AND AR', 6),
  ('DREAM 90 PP MCQ', 7),
  ('DREAM 90 PP SUBJECTIVE', 8)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%SOUND%')
LIMIT 1;

-- CURRENT ELECTRICITY (9 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('WRITE ALL FACTORS', 2),
  ('TEXTBOOK SOLVED EXAMPLES', 3),
  ('BOOK BACK QUESTIONS', 4),
  ('ALL LWS', 5),
  ('DREAM 90 MCQ AND AR', 6),
  ('DREAM 90 PP MCQ', 7),
  ('DREAM 90 PP SUBJECTIVE', 8),
  ('DREAM 90 SOLVED NUMERICALS', 9)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%CURRENT ELECTRICITY%')
LIMIT 1;

-- HOUSEHOLD CIRCUITS (8 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('WRITE ALL COLOR CODE', 2),
  ('TEXTBOOK SOLVED EXAMPLES', 3),
  ('BOOK BACK QUESTIONS', 4),
  ('ALL LWS', 5),
  ('DREAM 90 MCQ AND AR', 6),
  ('DREAM 90 PP MCQ', 7),
  ('DREAM 90 PP SUBJECTIVE', 8)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%HOUSEHOLD CIRCUITS%')
LIMIT 1;

-- ELECTRO-MAGNETISM (8 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('WRITE ALL FACTORS', 2),
  ('TEXTBOOK SOLVED EXAMPLES', 3),
  ('BOOK BACK QUESTIONS', 4),
  ('ALL LWS', 5),
  ('DREAM 90 MCQ AND AR', 6),
  ('DREAM 90 PP MCQ', 7),
  ('DREAM 90 PP SUBJECTIVE', 8)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%ELECTRO-MAGNETISM%')
LIMIT 1;

-- CALORIMETRY (8 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('TEXTBOOK SOLVED EXAMPLES', 2),
  ('BOOK BACK QUESTIONS', 3),
  ('ALL LWS', 4),
  ('DREAM 90 MCQ AND AR', 5),
  ('DREAM 90 PP MCQ', 6),
  ('DREAM 90 PP SUBJECTIVE', 7),
  ('DREAM 90 SOLVED NUMERICALS', 8)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%CALORIMETRY%')
LIMIT 1;

-- RADIOACTIVITY (8 tasks)
INSERT INTO tasks (id, chapter_id, title, order_index, created_at, updated_at)
SELECT
  gen_random_uuid(),
  c.id,
  task_title,
  task_order,
  NOW(),
  NOW()
FROM (VALUES
  ('TEXTBOOK READING', 1),
  ('WRITE ALL DEFINITIONS', 2),
  ('TEXTBOOK SOLVED EXAMPLES', 3),
  ('BOOK BACK QUESTIONS', 4),
  ('ALL LWS', 5),
  ('DREAM 90 MCQ AND AR', 6),
  ('DREAM 90 PP MCQ', 7),
  ('DREAM 90 PP SUBJECTIVE', 8)
) AS tl(task_title, task_order)
CROSS JOIN chapters c
WHERE LOWER(c.title) LIKE LOWER('%RADIOACTIVITY%')
LIMIT 1;
