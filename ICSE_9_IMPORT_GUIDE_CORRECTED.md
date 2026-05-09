# SUPABASE IMPORT GUIDE - ICSE 9 CURRICULUM (CORRECTED)

## 📊 DATA SUMMARY

Your ICSE 9 Numbers file contains:
- **Subjects:** 12 (PHYSICS, CHEMISTRY, BIOLOGY, MATHS, LITERATURE, LANGUAGE, CIVICS, GEOGRAPHY, HINDI, CS, ECONOMIC, CA)
- **Chapters:** 240 (numbered within each subject)
- **Tasks:** 377 (with task data for 4 subjects: PHYSICS, CHEMISTRY, LITERATURE, LANGUAGE)

**Hierarchy (3-Level - Chapters = Topics):**
```
SUBJECT → CHAPTER → TASK (directly, no separate Topics level)

Example:
PHYSICS (Subject)
  ├─ 1: MEASUREMENT & EXPERIMENTATION (Chapter)
  │   ├─ READ TEXTBOOK (Task)
  │   ├─ MAKE NOTES OF FORMULAS AND UNIT TBLE (Task)
  │   ├─ SOLVED EXAMPLES FROM TEXTBOOK (Task)
  │   └─ ...7 total tasks
  ├─ 2: MOTION IN 1D (Chapter)
  │   ├─ MAKE FORMULA LIST
  │   └─ ...9 total tasks
  └─ ...10 total chapters
```

---

## 📁 CSV FILES LOCATION

All files are in your **workspace folder**:
```
/Users/bhushan/Desktop/PROJECTS/LOGBOOK_APP-main/supabase_import_ready/
```

**Files (3 CSV FILES):**
1. `1_subjects_icse9_for_import.csv` - 12 subjects
2. `2_chapters_icse9_for_import.csv` - 240 chapters
3. `3_tasks_icse9_for_import.csv` - 377 tasks (with `chapter_id`, NOT `topic_id`)

---

## ✅ STEP-BY-STEP IMPORT INSTRUCTIONS

### **PREREQUISITE: Setup ICSE 9 in Database**

Before importing CSVs, you need to set up ICSE 9 class and get its UUID.

**Option A: Create ICSE 9 Class (if it doesn't exist)**
```sql
INSERT INTO classes (name, created_by, created_at, updated_at)
VALUES ('ICSE 9', '[YOUR_TEACHER_UUID]', NOW(), NOW())
RETURNING id;
```

**Option B: Check Existing Classes**
```sql
SELECT id, name FROM classes WHERE name LIKE '%9%' OR name LIKE '%ICSE%';
```

**Copy the class UUID from the result** - you'll need it for Step 1.

---

### **Step 1: UPDATE CSV with Real Class UUID**

Before importing, update the CSV file with the actual class ID:

1. Open `1_subjects_icse9_for_import.csv` in a text editor
2. Replace all instances of: `1b2a4c3d-5e6f-7a8b-9c0d-1e2f3a4b5c6d`
3. With your actual ICSE 9 class UUID (from the query above)
4. Save the file

**Example:**
```
name,description,color,icon,class_id,created_by,is_active,...
PHYSICS,PHYSICS - ICSE 9 Curriculum,blue,book,YOUR-REAL-UUID,5a18bcb2-b11b-41a3-982f-df5102cac454,TRUE,...
```

---

### **Step 2: Import SUBJECTS**

1. **Go to Supabase Dashboard**
   - Open: https://app.supabase.com
   - Select your project
   - Go to **SQL Editor** → **Import Data**

2. **Upload CSV:**
   - Select file: `1_subjects_icse9_for_import.csv`
   - Choose table: `subjects`
   - Click: "Upload"

3. **Expected Result:**
   ```
   ✓ Imported 12 subjects
   - BIOLOGY
   - CA
   - CHEMISTRY
   - CIVICS
   - CS
   - ECONOMIC
   - GEOGRAPHY
   - HINDI
   - LANGUAGE
   - LITERATURE
   - MATHS
   - PHYSICS
   ```

---

### **Step 3: Import CHAPTERS**

⚠️ **IMPORTANT:** Make sure Step 2 (Subjects) is complete before doing this!

1. **Upload CSV:**
   - File: `2_chapters_icse9_for_import.csv`
   - Table: `chapters`

2. **Expected Result:**
   ```
   ✓ Imported 240 chapters
   - PHYSICS has 10 chapters (Chapter 1-10)
   - CHEMISTRY has 9 chapters (Chapter 1-9)
   - BIOLOGY has 18 chapters (Chapter 1-18)
   - MATHS has 29 chapters (Chapter 1-29)
   - ... and so on
   ```

---

### **Step 4: Import TASKS**

⚠️ **IMPORTANT:** Make sure Step 3 (Chapters) is complete before doing this!

1. **Upload CSV:**
   - File: `3_tasks_icse9_for_import.csv`
   - Table: `tasks`

2. **Key Points:**
   - Tasks have **`chapter_id`** (not `topic_id`)
   - Tasks link DIRECTLY to chapters
   - NO separate Topics table needed

3. **Expected Result:**
   ```
   ✓ Imported 377 tasks
   - PHYSICS: 76 tasks across 10 chapters
   - CHEMISTRY: 60 tasks across 9 chapters
   - LITERATURE: 85 tasks across 17 chapters
   - LANGUAGE: 156 tasks across 26 chapters
   - Other subjects: chapters only (no tasks yet)
   ```

---

## 🔍 VERIFICATION QUERIES

After importing, run these SQL queries to verify:

### **Verify Subjects:**
```sql
SELECT COUNT(*) as subject_count FROM subjects WHERE batch = 'ICSE 9';
-- Expected: 12
```

### **Verify Chapters:**
```sql
SELECT s.name, COUNT(c.id) as chapter_count
FROM chapters c
JOIN subjects s ON c.subject_id = s.id
WHERE s.batch = 'ICSE 9'
GROUP BY s.id, s.name
ORDER BY s.name;

-- Expected output example:
-- BIOLOGY, 18
-- CA, 16
-- CHEMISTRY, 9
-- CIVICS, 19
-- CS, 24
-- ECONOMIC, 13
-- GEOGRAPHY, 20
-- HINDI, 39
-- LANGUAGE, 26
-- LITERATURE, 17
-- MATHS, 29
-- PHYSICS, 10
```

### **Verify Tasks:**
```sql
SELECT COUNT(*) as task_count FROM tasks WHERE chapter_id IN (
  SELECT c.id FROM chapters c 
  JOIN subjects s ON c.subject_id = s.id 
  WHERE s.batch = 'ICSE 9'
);
-- Expected: 377
```

### **Verify Tasks Are Linked to Chapters (Not Topics):**
```sql
SELECT 
  s.name as subject,
  c.title as chapter,
  COUNT(t.id) as task_count
FROM chapters c
JOIN subjects s ON c.subject_id = s.id
LEFT JOIN tasks t ON t.chapter_id = c.id
WHERE s.batch = 'ICSE 9'
GROUP BY s.id, c.id, s.name, c.title
LIMIT 10;

-- Expected: Shows ICSE 9 chapters with their tasks linked via chapter_id
```

### **Sample Output from Verification:**
```
subject   | chapter                              | task_count
----------|--------------------------------------|----------
PHYSICS   | 1: MEASUREMENT & EXPERIMENTATION   | 7
PHYSICS   | 2: MOTION IN 1D                    | 9
CHEMISTRY | 1: THE LANGUAGE OF CHEMISTRY       | 7
CHEMISTRY | 2: CHEMICAL CHANGES & REACTIONS    | 7
LANGUAGE  | 1: EMAIL & NOTICE WRITING          | 6
LANGUAGE  | 2: FORMAL & INFORMAL LETTER WRITING | 6
...
```

---

## 🎓 UI FLOW (How Students Will Use This)

After import, when a student opens the app for ICSE 9:

1. **Student sees subjects:**
   ```
   [PHYSICS] [CHEMISTRY] [BIOLOGY] [MATHS] ... [CA]
   ```

2. **Clicks PHYSICS → See 10 chapters:**
   ```
   1: MEASUREMENT & EXPERIMENTATION
   2: MOTION IN 1D
   3: LAWS OF MOTION
   ... (up to 10)
   ```

3. **Clicks "1: MEASUREMENT & EXPERIMENTATION" → See its 7 tasks:**
   ```
   ☐ READ TEXTBOOK
   ☐ MAKE NOTES OF FORMULAS AND UNIT TBLE
   ☐ SOLVED EXAMPLES FROM TEXTBOOK
   ☐ ALL LWS
   ☐ DREAM 90 MCQ AND AR
   ☐ DREAM 90 PP MCQ
   ☐ DREAM 90 PP SUBJECTIVE
   ```

4. **Student checks tasks → Progress bar increases:**
   ```
   Progress: 2/7 (29%)
   ```

---

## ⚠️ IMPORTANT NOTES

### **Only 3 CSV Files**
- NO separate Topics table
- Tasks link DIRECTLY to chapters using `chapter_id`
- This matches your Excel structure exactly

### **4 Subjects Have Tasks, 8 Don't (Yet)**
- **With task data:** PHYSICS (76), CHEMISTRY (60), LITERATURE (85), LANGUAGE (156)
- **Chapters only (no tasks):** BIOLOGY, MATHS, CIVICS, GEOGRAPHY, HINDI, CS, ECONOMIC, CA
- Add tasks for these subjects later by updating the Numbers file

### **Foreign Keys:**
- `chapters.subject_id` → `subjects.id` ✓
- `tasks.chapter_id` → `chapters.id` ✓
- (NO `tasks.topic_id` anymore)

### **Import Order Still Matters:**
1. Subjects first
2. Chapters second (needs subject_id)
3. Tasks third (needs chapter_id)

---

## 🆘 TROUBLESHOOTING

### **Error: "Foreign key violation"**
- **Cause:** Parent table doesn't exist yet or foreign key doesn't match
- **Solution:** Make sure you imported in order (Subjects → Chapters → Tasks)

### **Error: "Column 'class_id' not found"**
- **Solution:** Your subjects table might have a different schema. Check table structure.

### **Error: "null value in column 'class_id'"**
- **Cause:** You didn't update the class_id in the CSV
- **Solution:** Replace placeholder UUID with real ICSE 9 class UUID before importing

### **Tasks not appearing for a chapter:**
- **Check:** Run verification query above
- **Verify:** Tasks have the correct `chapter_id` value

---

## 📝 CSV FILE DETAILS

### **1_subjects_icse9_for_import.csv**
```
Columns: name, description, color, icon, class_id, created_by, is_active, created_at, updated_at, batch
Rows: 12 subjects
Example:
  PHYSICS, PHYSICS - ICSE 9 Curriculum, blue, book, [UUID], [TEACHER_UUID], TRUE, ...
  CHEMISTRY, CHEMISTRY - ICSE 9 Curriculum, blue, book, [UUID], [TEACHER_UUID], TRUE, ...
Note: class_id and created_by must be valid UUIDs from your database
```

### **2_chapters_icse9_for_import.csv**
```
Columns: subject_id, title, order_index, created_at, updated_at
Rows: 240 chapters
Example:
  [uuid], 1: MEASUREMENT & EXPERIMENTATION, 1, ...
  [uuid], 2: MOTION IN 1D, 2, ...
  [uuid], 1: THE LANGUAGE OF CHEMISTRY, 1, ...
Note: subject_id references the subjects table (auto-populated after Step 2)
```

### **3_tasks_icse9_for_import.csv** (CORRECTED)
```
Columns: chapter_id, title, order_index, created_at, updated_at
Rows: 377 tasks
Example:
  [uuid], READ TEXTBOOK, 1, ...
  [uuid], MAKE NOTES OF FORMULAS AND UNIT TBLE, 2, ...
  [uuid], SOLVED EXAMPLES FROM TEXTBOOK, 3, ...
Note: chapter_id references the chapters table (NOT topic_id)
```

---

## ✨ NEXT STEPS AFTER IMPORT

1. **Test in your app:**
   - Create a student account with batch = 'ICSE 9'
   - Navigate to PHYSICS
   - Click on a chapter
   - Verify tasks display correctly

2. **Create student_progress records:**
   ```sql
   -- Link students to all tasks:
   INSERT INTO student_progress (student_id, task_id, is_completed, created_at)
   SELECT 
     p.id,
     t.id,
     FALSE,
     NOW()
   FROM profiles p
   CROSS JOIN tasks t
   JOIN chapters c ON t.chapter_id = c.id
   JOIN subjects s ON c.subject_id = s.id
   WHERE p.batch = 'ICSE 9' AND p.role = 'student' AND s.batch = 'ICSE 9'
   ON CONFLICT DO NOTHING;  -- Avoid duplicates
   ```

3. **Add tasks for remaining subjects:**
   - Update the ICSE 9.numbers file with task data for BIOLOGY, MATHS, etc.
   - Generate updated CSVs
   - Append tasks to the tasks table

4. **Add students to ICSE 9:**
   - Make sure students have `batch = 'ICSE 9'` in profiles table
   - They'll then see all these subjects and chapters

---

## 📞 SUPPORT

If you encounter any issues:
1. Use the verification queries to check the data
2. Make sure you imported in order (Subjects → Chapters → Tasks)
3. Verify the CSV has the correct class_id (not the placeholder UUID)
4. Check Supabase logs for foreign key errors
5. Ensure class_id and created_by are valid UUIDs in your database

---

**You're all set! Ready to import? 🚀**
