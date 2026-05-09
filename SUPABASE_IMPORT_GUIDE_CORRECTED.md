# SUPABASE IMPORT GUIDE - ICSE 10 CURRICULUM (CORRECTED)

## 📊 DATA SUMMARY

Your CSV files contain:
- **Subjects:** 6 (PHYSICS, CHEMISTRY, CS, ECONOMICS, HINDI, CA)
- **Chapters:** 146 (numbered within each subject)
- **Tasks:** 1,126 (individual learnings/activities)

**Hierarchy (Option A - Topics = Chapters):**
```
SUBJECT → CHAPTER → TASK (directly, no separate Topics level)

Example:
PHYSICS (Subject)
  ├─ 1: FORCE (Chapter)
  │   ├─ TEXTBOOK READING (Task)
  │   ├─ TEXTBOOK SOLVED EXAMPLES (Task)
  │   ├─ BOOK BACK QUESTIONS (Task)
  │   └─ ...8 total tasks
  ├─ 2: WORK, ENERGY & POWER (Chapter)
  │   ├─ TEXTBOOK READING
  │   └─ ...9 total tasks
  └─ ...12 total chapters
```

---

## 📁 CSV FILES LOCATION

All files are in your **workspace folder**:
```
/Users/bhushan/Desktop/PROJECTS/LOGBOOK_APP-main/supabase_import_csvs_correct/
```

**Files (ONLY 3 NOW):**
1. `1_subjects_for_import.csv` - 6 subjects
2. `2_chapters_for_import.csv` - 146 chapters
3. `3_tasks_for_import.csv` - 1,126 tasks (with `chapter_id`, NOT `topic_id`)

---

## ✅ STEP-BY-STEP IMPORT INSTRUCTIONS

### **Step 1: Import SUBJECTS**

1. **Go to Supabase Dashboard**
   - Open: https://app.supabase.com
   - Select your project
   - Go to **SQL Editor** → **Import Data**

2. **Upload CSV:**
   - Select file: `1_subjects_for_import.csv`
   - Choose table: `subjects`
   - Click: "Upload"

3. **Expected Result:**
   ```
   ✓ Imported 6 subjects
   - CA
   - CHEMISTRY
   - CS
   - ECONOMIC
   - HINDI
   - PHYSICS
   ```

---

### **Step 2: Import CHAPTERS**

⚠️ **IMPORTANT:** Make sure Step 1 (Subjects) is complete before doing this!

1. **Upload CSV:**
   - File: `2_chapters_for_import.csv`
   - Table: `chapters`

2. **Expected Result:**
   ```
   ✓ Imported 146 chapters
   - PHYSICS has 12 chapters (Chapter 1-12)
   - CHEMISTRY has 13 chapters (Chapter 1-13)
   - MATHS has 23 chapters (Chapter 1-23)
   - ... and so on
   ```

---

### **Step 3: Import TASKS**

⚠️ **IMPORTANT:** Make sure Step 2 (Chapters) is complete before doing this!

1. **Upload CSV:**
   - File: `3_tasks_for_import.csv`
   - Table: `tasks`

2. **Key Difference:**
   - Tasks now have **`chapter_id`** (not `topic_id`)
   - Tasks link DIRECTLY to chapters
   - NO separate Topics table needed

3. **Expected Result:**
   ```
   ✓ Imported 1,126 tasks
   - FORCE chapter has 8 tasks
   - PERIODIC TABLE chapter has 8 tasks
   - ... varying tasks per chapter
   ```

---

## 🔍 VERIFICATION QUERIES

After importing, run these SQL queries to verify:

### **Verify Subjects:**
```sql
SELECT COUNT(*) as subject_count FROM subjects WHERE batch = 'ICSE 10';
-- Expected: 6
```

### **Verify Chapters:**
```sql
SELECT s.name, COUNT(c.id) as chapter_count
FROM chapters c
JOIN subjects s ON c.subject_id = s.id
GROUP BY s.id, s.name
ORDER BY s.name;

-- Expected output example:
-- CA, 15
-- CHEMISTRY, 13
-- CS, 15
-- ECONOMIC, 14
-- HINDI, 0
-- PHYSICS, 12
```

### **Verify Tasks:**
```sql
SELECT COUNT(*) as task_count FROM tasks;
-- Expected: 1,126
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
WHERE s.name = 'PHYSICS'
GROUP BY s.id, c.id, s.name, c.title
LIMIT 5;

-- Expected: Shows PHYSICS chapters with their tasks linked via chapter_id
```

### **Sample Output from Verification:**
```
subject   | chapter              | task_count
----------|----------------------|----------
PHYSICS   | 1: FORCE             | 8
PHYSICS   | 2: WORK, ENERGY...   | 9
PHYSICS   | 3: MACHINE           | 9
...
```

---

## 🎓 UI FLOW (How Students Will Use This)

After import, when a student opens the app:

1. **Student sees subjects:**
   ```
   [PHYSICS] [CHEMISTRY] [CS] [ECONOMICS] [HINDI] [CA]
   ```

2. **Clicks PHYSICS → See 12 chapters:**
   ```
   1: FORCE
   2: WORK, ENERGY & POWER
   3: MACHINE
   ... (up to 12)
   ```

3. **Clicks "1: FORCE" → See its 8 tasks:**
   ```
   ☐ TEXTBOOK READING
   ☐ TEXTBOOK SOLVED EXAMPLES
   ☐ BOOK BACK QUESTIONS
   ☐ ALL LWS
   ☐ DREAM 90 MCQ AND AR
   ☐ DREAM 90 PP MCQ
   ☐ DREAM 90 PP SUBJECTIVE
   ☐ DREAM 90 SOLVED NUMERICALS
   ```

4. **Student checks tasks → Progress bar increases:**
   ```
   Progress: 3/8 (37%)
   ```

---

## ⚠️ IMPORTANT NOTES

### **Only 3 CSV Files Now**
- NO separate Topics table
- Tasks link DIRECTLY to chapters using `chapter_id`
- This matches your Excel structure exactly

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

### **Error: Column "topic_id" not found**
- **Solution:** You're using the old 4-CSV version. Use the NEW `3_tasks_for_import.csv` that has `chapter_id`

### **Tasks not appearing for a chapter:**
- **Check:** Run verification query above
- **Verify:** Tasks have the correct `chapter_id` value

---

## 📝 CSV FILE DETAILS

### **1_subjects_for_import.csv**
```
Columns: name, batch, description, color, icon, is_active, created_at, updated_at
Rows: 6 subjects
Example:
  PHYSICS, ICSE 10, PHYSICS - ICSE 10 Curriculum, blue, book, True, ...
  CHEMISTRY, ICSE 10, CHEMISTRY - ICSE 10 Curriculum, blue, book, True, ...
```

### **2_chapters_for_import.csv**
```
Columns: subject_id, title, order_index, created_at, updated_at
Rows: 146 chapters
Example:
  [uuid], 1: FORCE, 1, ...
  [uuid], 2: WORK ENERGY & POWER, 2, ...
  [uuid], 3: MACHINE, 3, ...
Note: subject_id references the subjects table
```

### **3_tasks_for_import.csv** (CORRECTED)
```
Columns: chapter_id, title, order_index, created_at, updated_at
Rows: 1,126 tasks
Example:
  [uuid], TEXTBOOK READING, 1, ...
  [uuid], TEXTBOOK SOLVED EXAMPLES, 2, ...
  [uuid], BOOK BACK QUESTIONS, 3, ...
Note: chapter_id references the chapters table (NOT topic_id)
```

---

## ✨ NEXT STEPS AFTER IMPORT

1. **Test in your app:**
   - Create a student account
   - Navigate to a subject
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
   WHERE p.batch = 'ICSE 10' AND p.role = 'student'
   ON CONFLICT DO NOTHING;  -- Avoid duplicates
   ```

3. **Add students to the batch:**
   - Make sure students have `batch = 'ICSE 10'` in profiles table
   - They'll then see all these subjects and tasks

---

## 📞 SUPPORT

If you encounter any issues:
1. Use the verification queries to check the data
2. Make sure you imported in order (Subjects → Chapters → Tasks)
3. Verify the CSV has the correct columns (chapter_id, NOT topic_id)
4. Check Supabase logs for foreign key errors

---

**You're all set! Ready to import? 🚀**
