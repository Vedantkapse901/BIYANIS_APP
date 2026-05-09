# Student Not Showing in Teacher Login - Database Mismatch Issue

## Problem Summary
New students added to the database are not appearing in the teacher login view for their batch/class.

---

## Root Cause: Two Different Database Schemas in Use

Your project has **TWO incompatible database schemas** that are not synced:

### Schema 1: OLD Schema (database.sql - MySQL)
**Backend code is currently using this schema**

```
users (id, name, email, role, ...)
    ↓
class_enrollments (student_id, class_id)
    ↓
classes (id, name, teacher_id, ...)
```

**Key tables for fetching students:**
- `users` - stores user info
- `classes` - stores classes/batches, linked to teacher via `teacher_id`
- `class_enrollments` - many-to-many relationship between students and classes

### Schema 2: NEW Schema (supabase_schema.sql - PostgreSQL/Supabase)
**This is where you're adding new students**

```
profiles (id, name, batch, role, ...)
    ↓
student_progress (student_id, task_id)
```

**Key tables:**
- `profiles` - stores all user info with `batch` field (e.g., "ICSE 9", "ICSE 10")
- `student_progress` - tracks task completion
- NO `class_enrollments` or `classes` tables

---

## Why Student Isn't Showing

When you added a new student:
1. ✅ Student was inserted into `profiles` table (NEW schema)
2. ❌ Student was NOT inserted into `users` table (OLD schema)
3. ❌ Student was NOT added to `class_enrollments` table (OLD schema)

When teacher logs in:
```php
// FROM: backend/index.php - handleGetStudents()
$sql = "SELECT u.id, u.name, u.email ...
        FROM users u
        JOIN class_enrollments ce ON u.id = ce.student_id
        JOIN classes c ON ce.class_id = c.id
        WHERE c.teacher_id = {$teacher['sub']} AND u.role = 'student'";
```

**Result:** Query looks in `users` + `class_enrollments`, but your new student is only in `profiles` table → **Student doesn't appear**

---

## Tables Being Queried (Current Backend)

### For Teacher Login - Getting Students:
```sql
SELECT u.id, u.name, u.email, ...
FROM users u
JOIN class_enrollments ce ON u.id = ce.student_id
JOIN classes c ON ce.class_id = c.id
LEFT JOIN student_progress sp ON u.id = sp.student_id
LEFT JOIN topics t ON t.subject_id = (SELECT id FROM subjects WHERE class_id = c.id)
WHERE c.teacher_id = {teacher_id} AND u.role = 'student'
```

**Tables Required:**
1. ✅ `users` - student basic info
2. ✅ `class_enrollments` - links student to class
3. ✅ `classes` - batch/class info
4. ✅ `subjects` - subjects for the class
5. ✅ `topics` - topics/tasks (called "topics" not "tasks")
6. ✅ `student_progress` - task completion status

### For Student Tasks Display:
- `subjects` - list of subjects
- `topics` - individual tasks
- `student_progress` - what the student has completed

---

## What Tables Need What Data

For a complete student setup in the **OLD schema**:

| Table | Required Fields | Purpose |
|-------|-----------------|---------|
| `users` | id, uuid, name, email, password, role | Student account |
| `classes` | id, uuid, name, teacher_id | The batch/class |
| `class_enrollments` | student_id, class_id, is_active | Link student to batch |
| `subjects` | uuid, name, class_id, created_by | Subjects in the batch |
| `topics` | uuid, subject_id, title, created_by | Tasks/topics in each subject |
| `student_progress` | student_id, topic_id, is_completed | Track completion |

---

## Solutions

### Option 1: Update Backend to Use NEW Schema (Recommended)
Modify `backend/index.php` to query the `profiles` table instead:

```php
function handleGetStudents($auth, $db)
{
    // Get teacher's batch from their profile
    $teacher = $auth->getCurrentUser();
    
    // For Supabase/PostgreSQL schema
    $sql = "SELECT p.id, p.name, p.email,
                   COUNT(CASE WHEN sp.is_completed = TRUE THEN 1 END) as tasks_completed,
                   COUNT(t.id) as total_tasks
            FROM profiles p
            LEFT JOIN student_progress sp ON p.id = sp.student_id
            LEFT JOIN tasks t ON t.id = sp.task_id
            WHERE p.batch = (SELECT batch FROM profiles WHERE id = '{$teacher['sub']}')
            AND p.role = 'student'
            AND p.is_active = TRUE
            GROUP BY p.id
            ORDER BY p.name";
    
    $students = $db->fetchAll($sql);
    die(Response::success($students));
}
```

**Pros:** Simpler schema, batch-based instead of enrollment tables
**Cons:** Requires rewriting backend queries

### Option 2: Add New Student to OLD Schema (Quick Fix)
When adding a new student, insert into all required tables:

```sql
-- 1. Add to users table
INSERT INTO users (uuid, name, email, password, role, is_active)
VALUES ('uuid-here', 'Student Name', 'email@example.com', 'hashed-password', 'student', TRUE);

-- 2. Add to class_enrollments (assuming class_id = 1 for ICSE 9 batch)
INSERT INTO class_enrollments (student_id, class_id, is_active)
VALUES ((SELECT id FROM users WHERE email = 'email@example.com'), 1, TRUE);
```

**Pros:** Works with current backend code immediately
**Cons:** Have to manually sync both schemas

### Option 3: Merge/Migrate to Single Schema
- Choose ONE schema (recommend NEW - simpler)
- Migrate all data from old to new
- Update all backend code to use new schema
- Delete old tables

---

## Recommended Action

**Best Solution:** Option 1 - Update backend to use the NEW Supabase schema
- It's cleaner and simpler
- No need for enrollment tables
- Batch-based is easier to manage
- Backend code is the only thing that needs updating, not the schema

---

## Quick Checklist

To verify the issue, check your database:

```sql
-- Check if student is in NEW schema
SELECT * FROM profiles WHERE name = 'Student Name';

-- Check if student is in OLD schema  
SELECT * FROM users WHERE name = 'Student Name';

-- Check class enrollments
SELECT * FROM class_enrollments WHERE student_id = X;
```

If the student is in `profiles` but NOT in `users` → This confirms the diagnosis!
