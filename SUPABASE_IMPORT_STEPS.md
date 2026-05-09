# 📲 Import CSV Files into Supabase - Step by Step

## 📊 What Was Created

Your CSV has been split into **3 files** ready for Supabase:

| File | Size | Contains |
|------|------|----------|
| `subjects_for_import.csv` | 921 B | 6 subjects (MATHS, BIOLOGY, LANGUAGE, HISTORY, GEOGRAPHY, LITERATURE) |
| `topics_for_import.csv` | 32 KB | 696 topics across all subjects |
| `tasks_for_import.csv` | 137 KB | 2,679 tasks (up to 13 per topic) |

**Total for ICSE 10:** 6 subjects → 696 topics → 2,679 tasks

---

## 🚀 Step-by-Step Import Instructions

### **STEP 1: Download the CSV Files**

The 3 files are located in your project:
- `supabase_import_csvs/subjects_for_import.csv`
- `supabase_import_csvs/topics_for_import.csv`
- `supabase_import_csvs/tasks_for_import.csv`

Download them to your computer.

---

### **STEP 2: Log In to Supabase Dashboard**

1. Go to: **https://app.supabase.com**
2. Select your project
3. Click **"Table Editor"** (left sidebar)

---

### **STEP 3: Import SUBJECTS First**

**Why first?** Because topics reference subject IDs

1. In Table Editor, click on **`subjects`** table
2. Click the **"..."** (three dots) menu button in top right
3. Select **"Import data"** → **"CSV"**
4. Upload: **`subjects_for_import.csv`**
5. Preview should show columns: `id, name, batch, description, is_active, created_at, updated_at`
6. Click **"Import"**
7. ✅ Wait for completion (should show "Imported 6 rows")

**📌 Check:** You should see 6 subjects:
- MATHS
- BIOLOGY  
- LANGUAGE
- HISTORY
- GEOGRAPHY
- LITERATURE

---

### **STEP 4: Import TOPICS**

**Why now?** Topics reference the subject IDs we just created

1. Click on **`topics`** table
2. Click **"..."** menu → **"Import data"** → **"CSV"**
3. Upload: **`topics_for_import.csv`**
4. Preview should show columns: `id, subject_id, title, order_index, description, created_at, updated_at`
5. Click **"Import"**
6. ✅ Wait for completion (should show "Imported 696 rows")

**📌 Check:** Under MATHS subject, you should see:
- GOODS AND SERVICE TAX
- BANKING
- SHARES AND DIVIDENDS
- LINEAR INEQUALITIES
- etc. (23 topics total)

---

### **STEP 5: Import TASKS**

**Why now?** Tasks reference the topic IDs we just created

1. Click on **`tasks`** table
2. Click **"..."** menu → **"Import data"** → **"CSV"**
3. Upload: **`tasks_for_import.csv`**
4. Preview should show columns: `id, topic_id, title, order_index, created_at, updated_at`
5. Click **"Import"**
6. ✅ Wait for completion (should show "Imported 2679 rows")

**📌 Check:** Each topic should have 4-13 tasks:
- "MAKE SUMMARY OF CHAPTER"
- "SOLVED EXAMPLE FROM TEXTBOOK"
- "BOOK BACK QUESTIONS"
- etc.

---

### **STEP 6: Create Student Progress Records**

Now link all students to all tasks. Use Supabase SQL Editor:

1. Go to **"SQL Editor"** (left sidebar)
2. Create a **new query**
3. Paste this SQL:

```sql
-- Create student_progress records for all students
INSERT INTO student_progress (id, student_id, task_id, is_completed, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    s.id,
    t.id,
    false,
    NOW(),
    NOW()
FROM students s
JOIN tasks t ON true
JOIN topics tp ON t.topic_id = tp.id
JOIN subjects subj ON tp.subject_id = subj.id
WHERE s.batch = subj.batch
AND NOT EXISTS (
    SELECT 1 FROM student_progress 
    WHERE student_id = s.id AND task_id = t.id
)
LIMIT 100000;
```

4. Click **"Run"** button
5. ✅ Should show: "Inserted X rows"

**📌 Note:** This creates a task progress record for EVERY student-task combination matching the batch!
- Example: If you have 2 students in ICSE 10, and 500 tasks in ICSE 10
- It creates 1,000 progress records (2 × 500)

---

## ✅ Verification Checklist

After all imports, verify everything worked:

### In Supabase SQL Editor, run these queries:

**Check Subjects:**
```sql
SELECT COUNT(*), batch FROM subjects GROUP BY batch;
-- Should show: 6 subjects for ICSE 10
```

**Check Topics:**
```sql
SELECT s.name, COUNT(t.id) as topics
FROM subjects s
LEFT JOIN topics t ON s.id = t.subject_id
GROUP BY s.id, s.name
ORDER BY s.name;
-- Should show: MATHS=23, BIOLOGY=16, etc.
```

**Check Tasks:**
```sql
SELECT tp.title, COUNT(t.id) as tasks
FROM topics tp
LEFT JOIN tasks t ON tp.id = t.topic_id
GROUP BY tp.id, tp.title
ORDER BY COUNT(t.id) DESC
LIMIT 10;
-- Should show tasks grouped by topic
```

**Check Student Progress:**
```sql
SELECT s.name, COUNT(sp.id) as task_progress
FROM students s
LEFT JOIN student_progress sp ON s.id = sp.student_id
GROUP BY s.id, s.name;
-- Should show: Each student has hundreds of tasks to track
```

---

## 🎯 What Happens Next?

After successful import:

1. **Students log in** → See all 6 subjects
2. **Click a subject** → See all topics (23 for MATHS, 16 for BIOLOGY, etc.)
3. **Click a topic** → See up to 13 tasks for that topic
4. **Complete tasks** → Progress is tracked in `student_progress` table

---

## ❌ Troubleshooting

### Error: "Column not found"
- Make sure CSV column names match table columns exactly
- Example: Use `created_at`, not `CreatedAt`
- **Solution:** Re-export the CSV files

### Error: "Foreign key constraint failed"
- Means a topic references a subject_id that doesn't exist
- **Reason:** You imported TOPICS before SUBJECTS
- **Solution:** Delete the data and re-import in correct order:
  1. Import SUBJECTS first
  2. Then TOPICS
  3. Then TASKS

### Error: "Duplicate key value"
- A record with that ID already exists
- **Solution:** 
  - Delete existing data: `DELETE FROM subjects;`
  - Then re-import from CSV

### No tasks appearing in app
- Make sure `student_progress` records were created
- Check student batch matches subject batch
- **Verify:** Run the SQL query:
  ```sql
  SELECT COUNT(*) FROM student_progress;
  ```
  Should show thousands of records

---

## 📝 Quick Checklist

- [ ] Downloaded 3 CSV files
- [ ] Logged into Supabase
- [ ] Imported `subjects_for_import.csv` ✅
- [ ] Imported `topics_for_import.csv` ✅
- [ ] Imported `tasks_for_import.csv` ✅
- [ ] Ran SQL to create `student_progress` ✅
- [ ] Verified with SQL queries ✅
- [ ] Tested in app: Students see subjects & tasks ✅

---

## 🎉 Done!

Your curriculum is now in Supabase and students can track their work!

**Next:** 
- Students login → See all subjects and tasks
- Teachers see all student progress
- Track completion rates per student

