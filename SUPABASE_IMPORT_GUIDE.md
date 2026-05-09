# SUPABASE IMPORT GUIDE - ICSE 10 CURRICULUM

## 📊 DATA SUMMARY

Your CSV files contain:
- **Subjects:** 6 (PHYSICS, CHEMISTRY, CS, ECONOMICS, HINDI, CA)
- **Chapters:** 146 (numbered within each subject)
- **Topics:** 146 (one per chapter)
- **Tasks:** 1,126 (total learnings/activities)

**Hierarchy:**
```
PHYSICS (Subject)
  ├─ 1: FORCE (Chapter)
  │   └─ FORCE (Topic - same as chapter for simplicity)
  │       ├─ TEXTBOOK READING (Task)
  │       ├─ TEXTBOOK SOLVED EXAMPLES (Task)
  │       ├─ BOOK BACK QUESTIONS (Task)
  │       └─ ...9 total tasks
  ├─ 2: WORK, ENERGY & POWER (Chapter)
  │   └─ WORK, ENERGY & POWER (Topic)
  │       ├─ TEXTBOOK READING
  │       └─ ...9 total tasks
  └─ ...12 total chapters
```

---

## 📁 CSV FILES LOCATION

All files are in your **workspace folder**:
```
/Users/bhushan/Desktop/PROJECTS/LOGBOOK_APP-main/supabase_import_csvs/
```

**Files:**
1. `1_subjects_for_import.csv` - 6 subjects
2. `2_chapters_for_import.csv` - 146 chapters
3. `3_topics_for_import.csv` - 146 topics
4. `4_tasks_for_import.csv` - 1,126 tasks

---

## ✅ STEP-BY-STEP IMPORT INSTRUCTIONS

### **Step 1: Import SUBJECTS**

1. **Go to Supabase Dashboard**
   - Open: https://app.supabase.com
   - Select your project
   - Go to **SQL Editor**

2. **Click "Import Data" (or use the CSV import tool)**
   - Choose **Upload CSV** option
   - Select file: `1_subjects_for_import.csv`
   - **Choose table:** `subjects`
   - **Click:** "Upload"

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

### **Step 3: Import TOPICS**

⚠️ **IMPORTANT:** Make sure Step 2 (Chapters) is complete before doing this!

1. **Upload CSV:**
   - File: `3_topics_for_import.csv`
   - Table: `topics`

2. **Expected Result:**
   ```
   ✓ Imported 146 topics
   - One topic per chapter
   - Each topic title matches its chapter name
   ```

---

### **Step 4: Import TASKS**

⚠️ **IMPORTANT:** Make sure Step 3 (Topics) is complete before doing this!

1. **Upload CSV:**
   - File: `4_tasks_for_import.csv`
   - Table: `tasks`

2. **Expected Result:**
   ```
   ✓ Imported 1,126 tasks
   - PERIODIC TABLE topic has 8 tasks
   - FORCE topic has 8 tasks
   - ... varying tasks per chapter
   ```

---

## 🔍 VERIFICATION QUERIES

After importing, run these SQL queries to verify the data:

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

-- Expected output:
-- CA, 15
-- CHEMISTRY, 13
-- CS, 15
-- ECONOMIC, 14
-- HINDI, 0
-- PHYSICS, 12
```

### **Verify Topics:**
```sql
SELECT COUNT(*) as topic_count FROM topics;
-- Expected: 146
```

### **Verify Tasks:**
```sql
SELECT COUNT(*) as task_count FROM tasks;
-- Expected: 1,126
```

### **Verify Relationships (Sample):**
```sql
SELECT 
  s.name as subject,
  c.title as chapter,
  t.title as topic,
  COUNT(ta.id) as task_count
FROM subjects s
JOIN chapters c ON c.subject_id = s.id
JOIN topics t ON t.chapter_id = c.id
LEFT JOIN tasks ta ON ta.topic_id = t.id
WHERE s.name = 'PHYSICS'
GROUP BY s.id, c.id, t.id, s.name, c.title, t.title
LIMIT 5;

-- Expected: Shows PHYSICS chapters with their tasks
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

3. **Clicks "1: FORCE" → See its tasks:**
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

### **Foreign Keys Must Exist First**
- Always import in order: Subjects → Chapters → Topics → Tasks
- If you get a "foreign key violation" error, it means you skipped a step

### **Encoding Issues:**
- If you see strange characters, the CSV is fine - it's already UTF-8 encoded
- Supabase will handle the import correctly

### **Timestamps:**
- `created_at` and `updated_at` are set to the import time
- This is fine for initial setup

### **UUIDs:**
- The `subject_id`, `chapter_id`, and `topic_id` are properly linked
- Foreign keys should validate correctly

---

## 🆘 TROUBLESHOOTING

### **Error: "Invalid input syntax for type uuid"**
- **Cause:** CSV has empty id columns
- **Solution:** Our CSVs don't have id columns - let Supabase auto-generate them ✓

### **Error: "Foreign key violation"**
- **Cause:** Parent table doesn't exist yet
- **Solution:** Make sure you imported in order (Subjects first, then Chapters, etc.)

### **Error: "Column not found"**
- **Cause:** Table structure is different than expected
- **Solution:** Check your Supabase schema matches the expected structure

### **Data Looks Wrong After Import**
- **Verify:** Run the verification queries above
- **Check:** Make sure all 4 CSVs were imported in order

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
Note: subject_id is referenced from subjects table
```

### **3_topics_for_import.csv**
```
Columns: chapter_id, title, description, order_index, created_at, updated_at
Rows: 146 topics
Example:
  [uuid], FORCE, FORCE - Overview, 1, ...
  [uuid], WORK ENERGY & POWER, WORK ENERGY & POWER - Overview, 1, ...
Note: chapter_id is referenced from chapters table
```

### **4_tasks_for_import.csv**
```
Columns: topic_id, title, order_index, created_at, updated_at
Rows: 1,126 tasks
Example:
  [uuid], TEXTBOOK READING, 1, ...
  [uuid], TEXTBOOK SOLVED EXAMPLES, 2, ...
  [uuid], BOOK BACK QUESTIONS, 3, ...
Note: topic_id is referenced from topics table
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
   -- After students are added, link them to all tasks:
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
1. Check the verification queries first
2. Make sure all 4 CSVs were imported in order
3. Check for foreign key errors in Supabase logs
4. Verify the CSV files weren't corrupted during download

---

**You're all set! Ready to import? 🚀**
