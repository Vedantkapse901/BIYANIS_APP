-- ==========================================
-- Student Logbook System - MySQL Database Schema
-- ==========================================

CREATE DATABASE IF NOT EXISTS student_logbook;
USE student_logbook;

-- ==========================================
-- 1. USERS TABLE (Students & Teachers)
-- ==========================================
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('student', 'teacher') NOT NULL,
    phone VARCHAR(20),
    profile_image VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_uuid (uuid),
    INDEX idx_role (role)
);

-- ==========================================
-- 2. CLASSES TABLE (Groups/Batches)
-- ==========================================
CREATE TABLE classes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    teacher_id INT NOT NULL,
    max_students INT DEFAULT 100,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_teacher_id (teacher_id),
    INDEX idx_uuid (uuid)
);

-- ==========================================
-- 3. CLASS_ENROLLMENT TABLE (Students in Classes)
-- ==========================================
CREATE TABLE class_enrollments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    class_id INT NOT NULL,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
    UNIQUE KEY unique_enrollment (student_id, class_id),
    INDEX idx_student_id (student_id),
    INDEX idx_class_id (class_id)
);

-- ==========================================
-- 4. SUBJECTS TABLE
-- ==========================================
CREATE TABLE subjects (
    id INT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    color VARCHAR(7) NOT NULL DEFAULT '#5B5FDE',
    icon VARCHAR(50) DEFAULT '📚',
    class_id INT NOT NULL,
    created_by INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_class_id (class_id),
    INDEX idx_created_by (created_by),
    INDEX idx_uuid (uuid)
);

-- ==========================================
-- 5. TOPICS TABLE (Tasks/Lessons)
-- ==========================================
CREATE TABLE topics (
    id INT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL,
    subject_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    order_index INT DEFAULT 0,
    due_date DATE,
    created_by INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_subject_id (subject_id),
    INDEX idx_created_by (created_by),
    INDEX idx_uuid (uuid)
);

-- ==========================================
-- 6. STUDENT_PROGRESS TABLE
-- ==========================================
CREATE TABLE student_progress (
    id INT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL,
    student_id INT NOT NULL,
    topic_id INT NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP NULL,
    attempts INT DEFAULT 0,
    last_accessed TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE,
    UNIQUE KEY unique_progress (student_id, topic_id),
    INDEX idx_student_id (student_id),
    INDEX idx_topic_id (topic_id),
    INDEX idx_is_completed (is_completed),
    INDEX idx_uuid (uuid)
);

-- ==========================================
-- 7. AUTH_TOKENS TABLE (Session/Token Management)
-- ==========================================
CREATE TABLE auth_tokens (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    token VARCHAR(500) NOT NULL UNIQUE,
    device_info VARCHAR(255),
    ip_address VARCHAR(45),
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_token (token),
    INDEX idx_expires_at (expires_at)
);

-- ==========================================
-- 8. ACTIVITY_LOG TABLE
-- ==========================================
CREATE TABLE activity_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id INT,
    description TEXT,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_created_at (created_at)
);

-- ==========================================
-- INSERT SAMPLE DATA
-- ==========================================

-- Sample Teachers
INSERT INTO users (uuid, name, email, password, role, phone, is_active) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Ms. Priya Sharma', 'priya@school.com', '$2y$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcg7b3XeKeUuxWxsxW58PwZSt.e', 'teacher', '9876543210', TRUE),
('550e8400-e29b-41d4-a716-446655440002', 'Mr. Rajesh Kumar', 'rajesh@school.com', '$2y$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcg7b3XeKeUuxWxsxW58PwZSt.e', 'teacher', '9876543211', TRUE);

-- Sample Students
INSERT INTO users (uuid, name, email, password, role, phone, is_active) VALUES
('550e8400-e29b-41d4-a716-446655440010', 'Aarav Kumar', 'aarav@student.com', '$2y$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcg7b3XeKeUuxWxsxW58PwZSt.e', 'student', '9999999990', TRUE),
('550e8400-e29b-41d4-a716-446655440011', 'Priya Singh', 'priya.singh@student.com', '$2y$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcg7b3XeKeUuxWxsxW58PwZSt.e', 'student', '9999999991', TRUE),
('550e8400-e29b-41d4-a716-446655440012', 'Rohan Patel', 'rohan@student.com', '$2y$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcg7b3XeKeUuxWxsxW58PwZSt.e', 'student', '9999999992', TRUE),
('550e8400-e29b-41d4-a716-446655440013', 'Zara Khan', 'zara@student.com', '$2y$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcg7b3XeKeUuxWxsxW58PwZSt.e', 'student', '9999999993', TRUE),
('550e8400-e29b-41d4-a716-446655440014', 'Arjun Gupta', 'arjun@student.com', '$2y$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcg7b3XeKeUuxWxsxW58PwZSt.e', 'student', '9999999994', TRUE);

-- Sample Class
INSERT INTO classes (uuid, name, description, teacher_id, is_active) VALUES
('550e8400-e29b-41d4-a716-446655440101', 'Class 10-A', 'Science and Mathematics for Grade 10', 1, TRUE);

-- Enroll Students
INSERT INTO class_enrollments (student_id, class_id, is_active) VALUES
(3, 1, TRUE),
(4, 1, TRUE),
(5, 1, TRUE),
(6, 1, TRUE),
(7, 1, TRUE);

-- Sample Subjects
INSERT INTO subjects (uuid, name, description, color, icon, class_id, created_by, is_active) VALUES
('550e8400-e29b-41d4-a716-446655440201', 'Mathematics', 'Basic Mathematics and Algebra', '#5B5FDE', '🧮', 1, 1, TRUE),
('550e8400-e29b-41d4-a716-446655440202', 'English', 'English Language and Literature', '#00D4AA', '📚', 1, 1, TRUE),
('550e8400-e29b-41d4-a716-446655440203', 'Science', 'Physics, Chemistry, and Biology', '#FF9500', '🔬', 1, 1, TRUE);

-- Sample Topics
INSERT INTO topics (uuid, subject_id, title, description, order_index, created_by, is_active) VALUES
-- Math topics
('550e8400-e29b-41d4-a716-446655440301', 1, 'Chapter 1: Numbers and Operations', 'Learn about basic numbers and arithmetic operations', 1, 1, TRUE),
('550e8400-e29b-41d4-a716-446655440302', 1, 'Chapter 2: Algebra Basics', 'Introduction to algebraic expressions', 2, 1, TRUE),
('550e8400-e29b-41d4-a716-446655440303', 1, 'Chapter 3: Equations', 'Solving linear and quadratic equations', 3, 1, TRUE),
('550e8400-e29b-41d4-a716-446655440304', 1, 'Chapter 4: Geometry', 'Shapes, angles, and properties', 4, 1, TRUE),
('550e8400-e29b-41d4-a716-446655440305', 1, 'Practice Problems', 'Comprehensive practice exercises', 5, 1, TRUE),
-- English topics
('550e8400-e29b-41d4-a716-446655440306', 2, 'Chapter 1: Grammar Basics', 'Parts of speech and sentence structure', 1, 1, TRUE),
('550e8400-e29b-41d4-a716-446655440307', 2, 'Chapter 2: Comprehension', 'Reading and understanding texts', 2, 1, TRUE),
('550e8400-e29b-41d4-a716-446655440308', 2, 'Chapter 3: Writing Skills', 'Essay writing and composition', 3, 1, TRUE),
('550e8400-e29b-41d4-a716-446655440309', 2, 'Chapter 4: Literature', 'Poetry and prose analysis', 4, 1, TRUE),
('550e8400-e29b-41d4-a716-446655440310', 2, 'Chapter 5: Vocabulary', 'Word meanings and usage', 5, 1, TRUE),
-- Science topics
('550e8400-e29b-41d4-a716-446655440311', 3, 'Chapter 1: Matter and Energy', 'States of matter and energy transformations', 1, 1, TRUE),
('550e8400-e29b-41d4-a716-446655440312', 3, 'Chapter 2: Forces and Motion', 'Newtons laws and mechanics', 2, 1, TRUE),
('550e8400-e29b-41d4-a716-446655440313', 3, 'Chapter 3: Waves and Sound', 'Sound waves and light propagation', 3, 1, TRUE),
('550e8400-e29b-41d4-a716-446655440314', 3, 'Chapter 4: Chemistry Basics', 'Elements, compounds, and reactions', 4, 1, TRUE),
('550e8400-e29b-41d4-a716-446655440315', 3, 'Chapter 5: Biology', 'Life processes and ecosystems', 5, 1, TRUE);

-- Sample Student Progress (Some topics completed)
INSERT INTO student_progress (uuid, student_id, topic_id, is_completed, completed_at) VALUES
-- Aarav's progress
('550e8400-e29b-41d4-a716-446655440401', 3, 1, TRUE, NOW()),
('550e8400-e29b-41d4-a716-446655440402', 3, 2, TRUE, NOW()),
('550e8400-e29b-41d4-a716-446655440403', 3, 3, FALSE, NULL),
('550e8400-e29b-41d4-a716-446655440404', 3, 4, FALSE, NULL),
('550e8400-e29b-41d4-a716-446655440405', 3, 5, FALSE, NULL),
-- Priya's progress
('550e8400-e29b-41d4-a716-446655440406', 4, 1, TRUE, NOW()),
('550e8400-e29b-41d4-a716-446655440407', 4, 2, TRUE, NOW()),
('550e8400-e29b-41d4-a716-446655440408', 4, 3, TRUE, NOW()),
('550e8400-e29b-41d4-a716-446655440409', 4, 4, FALSE, NULL),
('550e8400-e29b-41d4-a716-446655440410', 4, 5, FALSE, NULL);

-- ==========================================
-- CREATE VIEWS FOR COMMON QUERIES
-- ==========================================

-- View: Student Progress Summary
CREATE VIEW student_progress_summary AS
SELECT
    sp.student_id,
    u.name AS student_name,
    s.id AS subject_id,
    s.name AS subject_name,
    COUNT(t.id) AS total_topics,
    SUM(CASE WHEN sp.is_completed THEN 1 ELSE 0 END) AS completed_topics,
    ROUND(SUM(CASE WHEN sp.is_completed THEN 1 ELSE 0 END) / COUNT(t.id) * 100, 2) AS completion_percentage
FROM student_progress sp
JOIN users u ON sp.student_id = u.id
JOIN topics t ON sp.topic_id = t.id
JOIN subjects s ON t.subject_id = s.id
GROUP BY sp.student_id, s.id;

-- View: Class Progress Summary
CREATE VIEW class_progress_summary AS
SELECT
    ce.class_id,
    c.name AS class_name,
    COUNT(DISTINCT ce.student_id) AS total_students,
    COUNT(DISTINCT sp.student_id) AS students_with_progress,
    ROUND(AVG(CASE WHEN sp.is_completed THEN 1 ELSE 0 END) * 100, 2) AS average_completion
FROM class_enrollments ce
JOIN classes c ON ce.class_id = c.id
LEFT JOIN student_progress sp ON ce.student_id = sp.student_id
WHERE ce.is_active = TRUE
GROUP BY ce.class_id;

-- ==========================================
-- CREATE INDEXES FOR PERFORMANCE
-- ==========================================

CREATE INDEX idx_student_progress_completion ON student_progress(student_id, is_completed);
CREATE INDEX idx_topics_subject_order ON topics(subject_id, order_index);
CREATE INDEX idx_subjects_class ON subjects(class_id, is_active);
CREATE INDEX idx_users_email_role ON users(email, role);

-- ==========================================
-- END OF SCHEMA
-- ==========================================
