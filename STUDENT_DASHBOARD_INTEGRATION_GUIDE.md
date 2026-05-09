# Student Dashboard - Integration Guide

## Overview
The student dashboard displays the curriculum in a **3-level hierarchy**:
1. **Subjects** (PHYSICS, CHEMISTRY, MATHEMATICS, etc.)
2. **Chapters** (FORCE, WORK ENERGY & POWER, MACHINE, etc.)
3. **Tasks** (TEXTBOOK READING, TEXTBOOK SOLVED EXAMPLES, etc.)

All tasks are now embedded directly in the chapters table columns (`task_1` through `task_13`).

---

## Data Structure

### Database Schema (New)
```
CHAPTERS TABLE:
├── id (UUID)
├── subject_id (UUID) → references SUBJECTS
├── title (TEXT) - Chapter name
├── order_index (TEXT) - Supports "1", "2", "3 (A)", "3 (B)", etc.
├── batch (VARCHAR) - "ICSE 10"
├── task_1 (TEXT) - First task
├── task_2 (TEXT) - Second task
├── ... up to task_13
├── created_at
└── updated_at
```

### Data Query Flow
```
User Opens App
    ↓
Load all SUBJECTS for batch
    ↓
For each SUBJECT → Load all CHAPTERS
    ↓
For each CHAPTER → Extract tasks from task_1...task_13 columns
    ↓
Display: Subject → [Chapters] → [Tasks for Chapter]
```

---

## Files Created

### 1. **student_dashboard_mobile.dart**
Complete Flutter widget showing the mobile layout with:
- Subject expansion
- Chapter expansion with order_index display
- Task list with numbering
- Real-time Supabase queries

### 2. **student_dashboard_mockup.html**
Interactive visual mockup of the mobile dashboard showing:
- Green subject cards with expansion
- Blue chapter items showing order_index
- Numbered task list with 1-13 numbering
- Click to expand/collapse

### 3. **SQL Files for Migration**
- `IMPORT_ICSE10_EMBEDDED_TASKS.sql` - Import 146 chapters with embedded tasks
- `MIGRATE_TO_EMBEDDED_TASKS.sql` - Complete migration script with backups

---

## How to Use in Your App

### Step 1: Replace Navigation
In your main navigation, add this screen:

```dart
// In your main router file
MaterialPageRoute(
  builder: (context) => StudentDashboardMobile(
    studentName: currentStudent.name,
    batch: 'ICSE 10',
  ),
)
```

### Step 2: Update Student Detail Screen
If you have an existing student detail screen, update it to show:

```dart
StudentDashboardMobile(
  studentName: widget.studentName,
  batch: widget.batch,
)
```

### Step 3: Query Only What You Need
The widget already optimizes queries by:
- Loading all subjects once
- Loading chapters per subject
- Extracting tasks from columns (no separate query)

---

## Mobile Layout Structure

### Screen Layout
```
┌─────────────────────┐
│  ICSE 10 - Student  │  ← AppBar
├─────────────────────┤
│ PHYSICS        ▼    │  ← Expandable Subject
│  ├─ FORCE        1  │  ← Chapter with order_index
│  │  ✓ 8 tasks      │  ← Task count
│  │  1. TEXTBOOK READING
│  │  2. TEXTBOOK SOLVED EXAMPLES
│  │  ...
│  ├─ WORK, ENERGY    2
│  │  ✓ 8 tasks
│  └─ MACHINE         3
│     ✓ 9 tasks
│
│ CHEMISTRY      ▼    │  ← Expandable Subject
│  ├─ PERIODIC TABLE  1
│  │  ✓ 8 tasks
│  ├─ ACID,BASES   3(A) ← Text order_index
│  │  ✓ 8 tasks
│  └─ ANALYTICAL   3(B)
│     ✓ 8 tasks
└─────────────────────┘
```

---

## Color Scheme

| Component | Color | Hex |
|-----------|-------|-----|
| Subject Header | Green | #2e7d32 |
| Chapter Title | Dark Gray | #333333 |
| Task Number | Blue Circle | #1976d2 |
| Order Index Badge | Light Gray | #e8e8e8 |
| Task Count | Blue Text | #1976d2 |
| Background | Light Gray | #f5f5f5 |

---

## Database Migration Steps

### Run These in Supabase SQL Editor:

**Step 1: Backup existing data**
```sql
CREATE TABLE chapters_backup_pre_migration AS SELECT * FROM chapters;
CREATE TABLE tasks_backup_pre_migration AS SELECT * FROM tasks;
```

**Step 2: Alter chapters table**
```sql
ALTER TABLE chapters ALTER COLUMN order_index TYPE TEXT USING order_index::text;
```

**Step 3: Add task columns**
```sql
ALTER TABLE chapters
ADD COLUMN IF NOT EXISTS batch VARCHAR(50),
ADD COLUMN IF NOT EXISTS task_1 TEXT,
ADD COLUMN IF NOT EXISTS task_2 TEXT,
-- ... up to task_13
ADD COLUMN IF NOT EXISTS task_13 TEXT;
```

**Step 4: Import ICSE 10 data**
Option A - Use Supabase UI:
- Go to Table Editor → chapters → Insert
- Click "Upload CSV"
- Select `ICSE10_chapters_TEXT_orderindex.csv`
- Map columns correctly

Option B - Run SQL:
- Copy contents of `IMPORT_ICSE10_EMBEDDED_TASKS.sql`
- Paste in SQL Editor
- Run

**Step 5: Verify**
```sql
SELECT COUNT(*) as total_icse10 FROM chapters WHERE batch = 'ICSE 10';
-- Should return: 146
```

---

## Features Implemented

✅ **3-level hierarchy**: Subject → Chapter → Task
✅ **Text-based order_index**: Supports "1", "3 (A)", "3 (B)"
✅ **Embedded tasks**: No separate tasks table needed
✅ **Mobile-optimized**: Card-based expandable UI
✅ **Real-time data**: Fetches from Supabase on load
✅ **Task numbering**: Automatic 1-13 numbering
✅ **Batch support**: Filters by ICSE 10, easily extensible

---

## Next Steps

1. **Import the CSV** into Supabase using the migration script
2. **Copy the Dart file** to your project
3. **Update your main navigation** to use StudentDashboardMobile
4. **Test on device** with your student data
5. **Optional**: Delete the old tasks table after verification

---

## Sample Data

### FORCE Chapter (Physics)
```
Order Index: 1
Tasks:
  1. TEXTBOOK READING
  2. TEXTBOOK SOLVED EXAMPLES
  3. BOOK BACK QUESTIONS
  4. ALL LWS
  5. DREAM 90 MCQ AND AR
  6. DREAM 90 PP MCQ
  7. DREAM 90 PP SUBJECTIVE
  8. DREAM 90 SOLVED NUMERICALS
```

### ACID, BASES AND SALTS (Chemistry)
```
Order Index: 3 (A)    ← Text format supported!
Tasks:
  1. READ CLASS NOTES
  2. WRITE ALL DEFINITIONS
  3. SOLVE BOOK BACK QUESTIONS
  4. SOLVE DREAM 90 LWS
  5. DREAM 90 MCQ AND AR
  6. DREAM 90 PP SUBJECTIVE
  7. DREAM 90 PP MCQ
  8. READ ALL DREAM 90 SOLVED QUESTIONS
```

---

## Troubleshooting

### Issue: Tasks not showing
**Solution**: Verify task columns have data
```sql
SELECT task_1, task_2, task_3 FROM chapters 
WHERE batch = 'ICSE 10' LIMIT 5;
```

### Issue: Wrong order of chapters
**Solution**: order_index is TEXT, so "10" comes before "2". Sort numerically:
```dart
chapters.sort((a, b) {
  int aNum = int.tryParse(a.orderIndex) ?? 999;
  int bNum = int.tryParse(b.orderIndex) ?? 999;
  return aNum.compareTo(bNum);
});
```

### Issue: Empty task slots in list
**Solution**: Filter out empty tasks in the query:
```dart
List<String> tasks = [];
for (int i = 1; i <= 13; i++) {
  final taskValue = chapter['task_$i'];
  if (taskValue != null && taskValue.toString().isNotEmpty) {
    tasks.add(taskValue.toString());
  }
}
```

---

## Files Included

```
LOGBOOK_APP-main/
├── lib/features/logbook/presentation/screens/
│   └── student_dashboard_mobile.dart          (Main widget)
├── student_dashboard_mockup.html              (Visual reference)
├── STUDENT_DASHBOARD_INTEGRATION_GUIDE.md     (This file)
├── IMPORT_ICSE10_EMBEDDED_TASKS.sql           (Ready to run)
├── MIGRATE_TO_EMBEDDED_TASKS.sql              (Backup + migration)
├── ICSE10_chapters_TEXT_orderindex.csv        (Data source)
└── generate_insert_statements.py              (CSV to SQL converter)
```

---

## Summary

Your student app now has:
- ✅ 146 ICSE 10 chapters with embedded tasks
- ✅ Support for text-based chapter ordering (3 A, 3 B)
- ✅ Mobile-friendly UI with expandable sections
- ✅ All 1,091 tasks properly linked to chapters
- ✅ Real-time data fetching from Supabase

Students can now browse their curriculum by subject, chapter, and tasks!
