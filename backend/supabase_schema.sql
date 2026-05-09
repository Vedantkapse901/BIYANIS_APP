-- ==========================================
-- Student Logbook System - Supabase (PostgreSQL) Schema
-- ==========================================

-- 1. PROFILES TABLE
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE, -- Linked after registration
    serial_id TEXT UNIQUE, -- e.g. '001', '002'
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    role TEXT CHECK (role IN ('student', 'teacher', 'super_admin')) NOT NULL,
    phone TEXT,
    pin TEXT,           -- 4-digit PIN for quick login
    is_registered BOOLEAN DEFAULT FALSE,
    profile_image TEXT,
    batch TEXT,
    branch TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Function to generate serial ID
CREATE OR REPLACE FUNCTION generate_serial_id()
RETURNS TRIGGER AS $$
DECLARE
    new_id TEXT;
BEGIN
    IF NEW.role = 'student' AND NEW.serial_id IS NULL THEN
        SELECT LPAD(COALESCE(MAX(CAST(serial_id AS INTEGER)), 0) + 1, 3, '0')
        INTO new_id
        FROM public.profiles
        WHERE role = 'student';

        NEW.serial_id := new_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_generate_serial_id ON public.profiles;
CREATE TRIGGER tr_generate_serial_id
BEFORE INSERT ON public.profiles
FOR EACH ROW EXECUTE FUNCTION generate_serial_id();

-- 2. SUBJECTS TABLE
CREATE TABLE IF NOT EXISTS public.subjects (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    color TEXT NOT NULL DEFAULT '#5B5FDE',
    icon TEXT DEFAULT '📚',
    batch TEXT NOT NULL, -- e.g. 'ICSE 9', 'ICSE 10'
    branch TEXT,         -- For B2B isolation
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 3. CHAPTERS TABLE (Groups or Books - e.g. 'EKANKI SANCHAY', 'SAHITYA SAGAR')
CREATE TABLE IF NOT EXISTS public.chapters (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    subject_id UUID REFERENCES public.subjects(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    order_index INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 4. TOPICS TABLE (The ROWS in your Excel sheet: e.g. 'SANSKAR AUR BHAVNA', 'FORCE')
CREATE TABLE IF NOT EXISTS public.topics (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    chapter_id UUID REFERENCES public.chapters(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    order_index INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 5. TASKS TABLE (Can be linked to Topics OR directly to Chapters)
CREATE TABLE IF NOT EXISTS public.tasks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    topic_id UUID REFERENCES public.topics(id) ON DELETE CASCADE, -- Optional if linked to chapter
    chapter_id UUID REFERENCES public.chapters(id) ON DELETE CASCADE, -- Direct link to chapter
    chapter_name TEXT, -- Helping for CSV imports and direct fetching
    title TEXT NOT NULL, -- e.g. 'TEXTBOOK READING', 'Task 13'
    order_index INT NOT NULL, -- 1 to 13
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 6. STUDENT_PROGRESS TABLE (Tracks completion of each task per student)
CREATE TABLE IF NOT EXISTS public.student_progress (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    task_id UUID REFERENCES public.tasks(id) ON DELETE CASCADE NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    UNIQUE(student_id, task_id)
);

-- ==========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chapters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_progress ENABLE ROW LEVEL SECURITY;

-- Helper to safely create policies
DO $$
BEGIN
    -- Profiles
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Public profiles are viewable by everyone.' AND tablename = 'profiles') THEN
        CREATE POLICY "Public profiles are viewable by everyone." ON public.profiles FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can update own profile.' AND tablename = 'profiles') THEN
        CREATE POLICY "Users can update own profile." ON public.profiles FOR UPDATE USING (auth.uid() = id);
    END IF;

    -- Curriculum
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Subjects are viewable by everyone' AND tablename = 'subjects') THEN
        CREATE POLICY "Subjects are viewable by everyone" ON public.subjects FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Chapters are viewable by everyone' AND tablename = 'chapters') THEN
        CREATE POLICY "Chapters are viewable by everyone" ON public.chapters FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Topics are viewable by everyone' AND tablename = 'topics') THEN
        CREATE POLICY "Topics are viewable by everyone" ON public.topics FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Tasks are viewable by everyone' AND tablename = 'tasks') THEN
        CREATE POLICY "Tasks are viewable by everyone" ON public.tasks FOR SELECT USING (true);
    END IF;

    -- Progress
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Students can manage their own progress.' AND tablename = 'student_progress') THEN
        CREATE POLICY "Students can manage their own progress." ON public.student_progress FOR ALL USING (auth.uid() = student_id);
    END IF;
END $$;

-- ==========================================
-- TRIGGERS FOR UPDATED_AT
-- ==========================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Drop and Recreate triggers to ensure they are up to date
DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_subjects_updated_at ON public.subjects;
CREATE TRIGGER update_subjects_updated_at BEFORE UPDATE ON public.subjects FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_chapters_updated_at ON public.chapters;
CREATE TRIGGER update_chapters_updated_at BEFORE UPDATE ON public.chapters FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_topics_updated_at ON public.topics;
CREATE TRIGGER update_topics_updated_at BEFORE UPDATE ON public.topics FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_tasks_updated_at ON public.tasks;
CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON public.tasks FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_student_progress_updated_at ON public.student_progress;
CREATE TRIGGER update_student_progress_updated_at BEFORE UPDATE ON public.student_progress FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
