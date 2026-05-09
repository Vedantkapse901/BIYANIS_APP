# Debugging Checklist - Frontend Data Display Issue

## Step 1: Verify Supabase Data Exists
Check in Supabase Dashboard:

- [ ] **Subjects Table**
  - Open `subjects` table
  - Filter by `batch = 'ICSE 10'` (or your batch)
  - Verify you see subject records
  - Check that `batch` column has values like 'ICSE 10', 'ICSE 9', 'CBSE 10'

- [ ] **Chapters Table**
  - Open `chapters` table
  - Verify there are chapter records
  - Check that `subject_id` column has values matching subject IDs from above
  - Verify `order_index` values are set

- [ ] **Tasks Table**
  - Open `tasks` table
  - Verify there are task records
  - Check that `chapter_id` column has values matching chapter IDs
  - Verify `order_index` values are set
  - ✅ Confirm NO `topic_id` field exists (or it's not being used)

## Step 2: Check Console Logs

Run the app and check Flutter console output for:

```
📚 Fetching subjects for batch: ICSE 10
✅ Subjects fetched: X
   - Subject Name: Y chapters
   - ...
```

If you see:
- ❌ "Subjects fetched: 0" → No subjects in DB with that batch
- ❌ Error message → Check the error details
- ✅ Subjects and chapter counts → Data is fetching correctly

## Step 3: Verify Model Parsing

Check if ChapterModel is correctly parsing tasks:

1. Open `lib/features/logbook/data/models/chapter_model.dart`
2. Look for: `tasks: json['tasks'] != null ? ... : []`
3. Verify TaskModel.fromJson is being called with task objects

## Step 4: Check Widget Rendering

In the UI:

1. [ ] Navigate to StudentDetailScreen
2. [ ] Verify you see subject cards with:
   - Subject name
   - Progress bar
   - Expand arrow
3. [ ] Click to expand a subject
4. [ ] Verify chapters appear below each subject:
   - Chapter title
   - Chapter progress bar
   - Expand arrow
5. [ ] Click to expand a chapter
6. [ ] Verify tasks appear:
   - Checkbox for each task
   - Task title (with strikethrough if completed)

## Step 5: Verify Database Schema

Run these queries in Supabase SQL Editor:

```sql
-- Check subjects structure
SELECT * FROM subjects WHERE batch = 'ICSE 10' LIMIT 1;

-- Check chapters for a subject
SELECT * FROM chapters WHERE subject_id = '(from above)' LIMIT 1;

-- Check tasks for a chapter
SELECT * FROM tasks WHERE chapter_id = '(from above)' LIMIT 5;

-- Check student_progress for a task
SELECT * FROM student_progress WHERE task_id = '(from above)' LIMIT 1;
```

Verify:
- ✅ `subjects.batch` = 'ICSE 10'
- ✅ `chapters.subject_id` matches subject.id
- ✅ `tasks.chapter_id` matches chapter.id (NOT topic_id)
- ✅ `student_progress.task_id` matches task.id

## Step 6: Test Task Toggle

1. [ ] Expand a subject → chapter → see tasks
2. [ ] Click checkbox on a task
3. [ ] Check console logs for toggle action
4. [ ] In Supabase `student_progress` table, verify new record is created
5. [ ] Refresh app and verify task shows as completed

## Step 7: Check for Common Errors

### Error: "NoSuchMethodError: The method 'map' was called on null"
- **Cause**: chapters is null or tasks is null
- **Fix**: Ensure `chapters` and `tasks` are initialized as empty lists in models

### Error: "RangeError: Invalid value: only 0 allowed for a list of length 0"
- **Cause**: Trying to access tasks[0] when tasks is empty
- **Fix**: Check if list is empty before accessing elements

### Error: "type 'Null' is not a subtype of type 'List<TaskModel>'"
- **Cause**: JSON doesn't have 'tasks' field
- **Fix**: Check Supabase data structure, verify nested query is correct

### Error: "is_completed is null"
- **Cause**: student_progress table has no records for this task
- **Fix**: Check if user is logged in, verify student_progress records exist

## Step 8: If Still Not Working

1. [ ] Clear app cache: In Flutter, hot restart (Shift+R)
2. [ ] Check if batch parameter matches your data:
   - In StudentDetailScreen, line 21: `batch ?? 'ICSE 10'`
   - Verify 'ICSE 10' exists in your subjects table
3. [ ] Check Supabase RLS (Row Level Security) policies:
   - Might be blocking data fetching
   - Temporarily disable RLS for testing
4. [ ] Verify Supabase client initialization:
   - Check if Supabase credentials are correct in main.dart
   - Verify internet connection

## Common Batch Values to Test
- `ICSE 10`
- `ICSE 9`
- `CBSE 10`
- `CBSE 9`
- `CBSE 8`

Make sure you use the exact batch value that exists in your database.
