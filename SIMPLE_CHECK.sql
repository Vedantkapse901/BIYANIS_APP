-- Simple check - see if tables exist

-- Check 1: Does profiles table exist?
SELECT 'Table: profiles exists' as info;
SELECT * FROM profiles LIMIT 1;

-- Check 2: Show all column names
SELECT column_name FROM information_schema.columns WHERE table_name = 'profiles';

-- Check 3: Count rows in profiles
SELECT COUNT(*) as total_profiles FROM profiles;

-- Check 4: Show all columns with data type
SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'profiles' ORDER BY ordinal_position;

-- Check 5: Do we have auth.users?
SELECT COUNT(*) as auth_users_count FROM auth.users;

-- Check 6: Show teacher auth users if they exist
SELECT email FROM auth.users WHERE email LIKE '%teacher%';
