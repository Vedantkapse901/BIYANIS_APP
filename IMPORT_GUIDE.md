# Import Subjects & Tasks from CSV

## What Gets Imported

The script will:
1. ✅ Parse the ICSE curriculum CSV file
2. ✅ Extract subjects (Physics, Chemistry, Biology, English, etc.)
3. ✅ Extract topics for each subject
4. ✅ Extract all 13 tasks per topic
5. ✅ Create student_progress records linking all students to all tasks
6. ✅ Handle both ICSE 9 and ICSE 10 batches

## CSV Format Expected

```
STD - 10 ICSE
,PHYSICS,TASK 1,TASK 2,TASK 3,...,TASK 13
1,FORCE,TEXTBOOK READING,TEXTBOOK SOLVED EXAMPLES,...
2,WORK ENERGY POWER,TEXTBOOK READING,TEXTBOOK SOLVED EXAMPLES,...
...

,CHEMISTRY,TASK 1,TASK 2,...,TASK 13
1,PERIODIC TABLE,READ CLASS NOTES,MAKE LIST OF ALL TRENDS,...
...
```

## How to Run

### Option 1: Command Line (Recommended)
```bash
cd /path/to/project/backend
php import_subjects_tasks_CLI.php "/path/to/CSV file.csv"
```

### Option 2: Browser (If Backend API allows)
```
POST /api/v1/import/subjects
Body: { "csvFile": "filename.csv" }
```

### Option 3: Direct PHP
```bash
php import_subjects_tasks_CLI.php
```
(Uses default path from uploads folder)

## What Gets Created

### Database Tables Updated:
- **subjects**: One record per subject (PHYSICS, CHEMISTRY, etc.)
- **topics**: One record per topic/chapter (FORCE, WORK & ENERGY, etc.)
- **tasks**: 13 records per topic (one per task column)
- **student_progress**: Links students to tasks (one per student-task combination)

### Example Structure:
```
Subject: PHYSICS (ICSE 10)
├─ Topic 1: FORCE (order_index: 1)
│  ├─ Task 1: TEXTBOOK READING
│  ├─ Task 2: TEXTBOOK SOLVED EXAMPLES
│  ├─ Task 3: BOOK BACK QUESTIONS
│  └─ ... (up to 13 tasks)
├─ Topic 2: WORK ENERGY POWER
│  ├─ Task 1: TEXTBOOK READING
│  ├─ Task 2: TEXTBOOK SOLVED EXAMPLES
│  └─ ... (up to 13 tasks)
└─ Topic 3: MACHINE
   └─ ... (up to 13 tasks)

Subject: CHEMISTRY (ICSE 10)
├─ Topic 1: PERIODIC TABLE
│  └─ ... (up to 13 tasks)
└─ ...
```

## Batch Isolation

- Students in batch "ICSE 9" see only ICSE 9 subjects/topics/tasks
- Students in batch "ICSE 10" see only ICSE 10 subjects/topics/tasks
- The script automatically creates progress records only for matching batch combinations

## Error Handling

If a topic or task already exists:
- ✅ It won't be duplicated
- ✅ The import will skip it and continue
- ✅ No data loss occurs

## Verification After Import

```sql
-- Check subjects
SELECT COUNT(*), batch FROM subjects GROUP BY batch;

-- Check topics
SELECT COUNT(*), s.batch FROM topics t
JOIN subjects s ON t.subject_id = s.id
GROUP BY s.batch;

-- Check tasks
SELECT COUNT(*), s.batch FROM tasks t
JOIN topics tp ON t.topic_id = tp.id
JOIN subjects s ON tp.subject_id = s.id
GROUP BY s.batch;

-- Check student progress
SELECT COUNT(*), s.batch FROM student_progress sp
JOIN students s ON sp.student_id = s.id
GROUP BY s.batch;
```

## Troubleshooting

**Issue**: "CSV file not found"
- Solution: Make sure the CSV file path is correct
- The script looks in: `/uploads/ICSE 10TH & 9TH PORTION FILE FINAL( IC 10 ).csv` by default

**Issue**: "Permission denied"
- Solution: Make sure the backend has write permission to the database

**Issue**: "Subjects not appearing for students"
- Make sure students have `batch` set to match the subject batch
- Run: `UPDATE students SET batch = 'ICSE 10' WHERE standard = '10';`

---

**Next**: After import, students can see all their subjects and tasks in their dashboard!
