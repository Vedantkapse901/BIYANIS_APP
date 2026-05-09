# Teacher Login Setup Guide

This guide walks you through setting up teacher accounts in Supabase with proper batch isolation.

## Phase 1: Create 6 Shared Batch Logins in Supabase Database

Each batch has **ONE shared login** that all teachers in that batch use.

Example: All teachers in ICSE 8 batch (10 teachers) use the same username/password → same dashboard

Run the following SQL in your Supabase SQL Editor to add 6 batch logins:

```sql
-- Insert teacher accounts into profiles table
INSERT INTO profiles (id, username, name, email, role, batch, is_active, created_at, updated_at) VALUES
('teacher-icse8-001', 'teacher_icse8', 'ICSE 8 Teacher', 'teacher.icse8@school.local', 'teacher', 'ICSE 8', true, NOW(), NOW()),
('teacher-icse9-001', 'teacher_icse9', 'ICSE 9 Teacher', 'teacher.icse9@school.local', 'teacher', 'ICSE 9', true, NOW(), NOW()),
('teacher-icse10-001', 'teacher_icse10', 'ICSE 10 Teacher', 'teacher.icse10@school.local', 'teacher', 'ICSE 10', true, NOW(), NOW()),
('teacher-cbse8-001', 'teacher_cbse8', 'CBSE 8 Teacher', 'teacher.cbse8@school.local', 'teacher', 'CBSE 8', true, NOW(), NOW()),
('teacher-cbse9-001', 'teacher_cbse9', 'CBSE 9 Teacher', 'teacher.cbse9@school.local', 'teacher', 'CBSE 9', true, NOW(), NOW()),
('teacher-cbse10-001', 'teacher_cbse10', 'CBSE 10 Teacher', 'teacher.cbse10@school.local', 'teacher', 'CBSE 10', true, NOW(), NOW());
```

## Phase 2: Create Supabase Auth Users

You need to create authentication users for each teacher. Do this through the Supabase Dashboard:

1. Go to your Supabase Project Dashboard
2. Navigate to **Authentication → Users**
3. Click **Add User** for each teacher
4. Use the following credentials:

### Teacher Accounts to Create:

| Username | Email | Password | Batch |
|----------|-------|----------|-------|
| teacher_icse8 | teacher.icse8@school.local | teacher_icse8_pwd123 | ICSE 8 |
| teacher_icse9 | teacher.icse9@school.local | teacher_icse9_pwd123 | ICSE 9 |
| teacher_icse10 | teacher.icse10@school.local | teacher_icse10_pwd123 | ICSE 10 |
| teacher_cbse8 | teacher.cbse8@school.local | teacher_cbse8_pwd123 | CBSE 8 |
| teacher_cbse9 | teacher.cbse9@school.local | teacher_cbse9_pwd123 | CBSE 9 |
| teacher_cbse10 | teacher.cbse10@school.local | teacher_cbse10_pwd123 | CBSE 10 |

**For each teacher:**
1. Click **Add User**
2. Enter Email: `teacher.icseX@school.local` (replace X with batch number)
3. Enter Password: `teacher_icseX_pwd123` (or your preferred secure password)
4. Click **Create User**

## Phase 3: Set Up Row-Level Security (RLS) Policies

Run the following SQL in your Supabase SQL Editor to set up batch isolation:

```sql
-- Enable RLS on students table if not already enabled
ALTER TABLE students ENABLE ROW LEVEL SECURITY;

-- Policy: Teachers can only see students in their batch
CREATE POLICY "Teachers can view students in their batch"
  ON students
  FOR SELECT
  USING (
    auth.jwt() ->> 'role' = 'authenticated' 
    AND (
      SELECT batch FROM profiles WHERE id = auth.uid() AND role = 'teacher'
    ) = batch
  );

-- Policy: Students can only see their own records
CREATE POLICY "Students can view only their own record"
  ON students
  FOR SELECT
  USING (
    auth.jwt() ->> 'role' = 'authenticated'
    AND profile_id = auth.uid()
  );

-- Enable RLS on profiles table if not already enabled
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own profile
CREATE POLICY "Users can view own profile"
  ON profiles
  FOR SELECT
  USING (auth.uid() = id);

-- Policy: Teachers can view other teachers (for admin purposes)
CREATE POLICY "Teachers can view teacher profiles"
  ON profiles
  FOR SELECT
  USING (
    auth.jwt() ->> 'role' = 'authenticated'
    AND role = 'teacher'
  );
```

## Phase 4: Test Teacher Login

Once everything is set up, test the teacher login with the following steps:

1. **Start the Flutter app**
2. **Select "Teacher" from role selection**
3. **Enter credentials:**
   - Username: `teacher_icse8` (or any teacher username)
   - Password: `teacher_icse8_pwd123` (or the password you set)
   - Click Login

4. **Expected Result:**
   - Dashboard shows teacher name: "ICSE 8 Teacher"
   - Dashboard shows batch: "ICSE 8"
   - Only students with batch = "ICSE 8" are displayed
   - Other students are hidden due to RLS policies

## Phase 5: Verify Batch Isolation

To verify batch isolation is working:

1. **Login as teacher_icse8** → Should only see "ICSE 8" students
2. **Logout and login as teacher_cbse9** → Should only see "CBSE 9" students
3. **Ensure no teacher sees other batches**

## Troubleshooting

### Issue: "Column 'username' not found in profiles table"
**Solution:** Ensure your profiles table has a `username` column. If not, run:
```sql
ALTER TABLE profiles ADD COLUMN username VARCHAR(255) UNIQUE;
```

### Issue: "Teacher not found" error
**Solution:** Verify teacher was inserted correctly:
```sql
SELECT * FROM profiles WHERE role = 'teacher';
```

### Issue: "Incorrect email or password"
**Solution:** 
1. Verify auth user exists in Supabase → Authentication → Users
2. Ensure email matches exactly: `teacher.icseX@school.local`
3. Verify password is correct

### Issue: Students from other batches still visible
**Solution:** RLS policies may not be active. Check:
```sql
SELECT * FROM pg_policies WHERE tablename = 'students';
```

## Code Changes Made

### 1. AuthRepository.login() - Teacher Role Handler
Added teacher-specific login logic that:
- Searches for teacher by username
- Gets email from profiles table
- Authenticates via Supabase Auth with email + password
- Saves batch to SharedPreferences for batch-based queries

### 2. TeacherDashboardScreen
New screen that displays:
- Teacher name and batch information
- Count of students in the batch
- List of all students filtered by batch
- Student cards with ID, name, phone, and batch info

### 3. main.dart
- Updated import to use `/features/teacher/...` instead of `/features/logbook/...`
- Route `/teacher` points to TeacherDashboardScreen
- SplashScreen correctly redirects to `/teacher` route for teacher role

## Database Schema Requirements

Your database must have:

### profiles table columns:
- `id` (UUID, primary key)
- `username` (VARCHAR, unique) ← **Required for teacher login**
- `name` (VARCHAR)
- `email` (VARCHAR, unique)
- `role` (VARCHAR) - values: 'student', 'teacher', 'parent', 'super_admin'
- `batch` (VARCHAR) - for batch isolation
- `is_active` (BOOLEAN)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

### students table columns:
- `id` (UUID, primary key)
- `serial_id` (VARCHAR)
- `name` (VARCHAR)
- `email` (VARCHAR)
- `phone` (VARCHAR)
- `batch` (VARCHAR) ← **Used for batch isolation**
- `branch` (VARCHAR)
- `school_name` (VARCHAR)
- `board` (VARCHAR)
- `profile_id` (UUID, foreign key) - links to profiles table
- Other fields as needed

## Next Steps

1. Run the SQL queries above in your Supabase SQL Editor
2. Create the 6 auth users through Supabase Dashboard
3. Test teacher login with the app
4. Verify batch isolation is working
5. Fine-tune RLS policies if needed
