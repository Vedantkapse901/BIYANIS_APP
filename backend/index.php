<?php
/**
 * Student Logbook API - Main Router
 * Entry point for all API requests
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/Database.php';
require_once __DIR__ . '/Response.php';
require_once __DIR__ . '/Auth.php';

// Set CORS headers
Response::setCORS();

// Get request method and path
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$path = str_replace('/api/v1', '', $path);

// Remove trailing slash
$path = rtrim($path, '/');

// Parse request body
$input = json_decode(file_get_contents('php://input'), true) ?? [];

// Initialize auth and database
$auth = new Auth();
$db = Database::getInstance();

// ==========================================
// AUTHENTICATION ENDPOINTS
// ==========================================

// Login
if ($method === 'POST' && $path === '/auth/login') {
    handleLogin($input, $auth, $db);
}

// Register
else if ($method === 'POST' && $path === '/auth/register') {
    handleRegister($input, $auth, $db);
}

// Get current user
else if ($method === 'GET' && $path === '/auth/me') {
    $auth->requireAuth();
    $user = $auth->getCurrentUser();
    die(Response::success([
        'id' => $user['sub'],
        'email' => $user['email'],
        'role' => $user['role']
    ]));
}

// ==========================================
// SUBJECT ENDPOINTS
// ==========================================

// Get all subjects for class
else if ($method === 'GET' && preg_match('/^\/subjects$/', $path)) {
    $auth->requireAuth();
    handleGetSubjects($input, $auth, $db);
}

// Get single subject
else if ($method === 'GET' && preg_match('/^\/subjects\/(\d+)$/', $path, $matches)) {
    $auth->requireAuth();
    handleGetSubject($matches[1], $auth, $db);
}

// Create subject (teacher only)
else if ($method === 'POST' && $path === '/subjects') {
    $auth->requireTeacher();
    handleCreateSubject($input, $auth, $db);
}

// ==========================================
// TOPIC ENDPOINTS
// ==========================================

// Get topics by subject
else if ($method === 'GET' && preg_match('/^\/subjects\/(\d+)\/topics$/', $path, $matches)) {
    $auth->requireAuth();
    handleGetTopics($matches[1], $auth, $db);
}

// Create topic (teacher only)
else if ($method === 'POST' && preg_match('/^\/subjects\/(\d+)\/topics$/', $path, $matches)) {
    $auth->requireTeacher();
    handleCreateTopic($matches[1], $input, $auth, $db);
}

// ==========================================
// PROGRESS ENDPOINTS
// ==========================================

// Get student progress
else if ($method === 'GET' && $path === '/progress') {
    $auth->requireAuth();
    handleGetProgress($auth, $db);
}

// Get progress for specific topic
else if ($method === 'GET' && preg_match('/^\/progress\/(\d+)$/', $path, $matches)) {
    $auth->requireAuth();
    handleGetTopicProgress($matches[1], $auth, $db);
}

// Update topic progress (mark complete/incomplete)
else if ($method === 'PUT' && preg_match('/^\/progress\/(\d+)$/', $path, $matches)) {
    $auth->requireStudent();
    handleUpdateProgress($matches[1], $input, $auth, $db);
}

// ==========================================
// STUDENT ENDPOINTS (Teacher only)
// ==========================================

// Get all students in class
else if ($method === 'GET' && $path === '/students') {
    $auth->requireTeacher();
    handleGetStudents($auth, $db);
}

// Get student progress details
else if ($method === 'GET' && preg_match('/^\/students\/(\d+)\/progress$/', $path, $matches)) {
    $auth->requireTeacher();
    handleGetStudentProgress($matches[1], $auth, $db);
}

// Get overall progress
else if ($method === 'GET' && $path === '/progress/overall') {
    $auth->requireAuth();
    handleGetOverallProgress($auth, $db);
}

// ==========================================
// DEFAULT 404 RESPONSE
// ==========================================

else {
    die(Response::notFound('Endpoint not found'));
}

// ==========================================
// HANDLER FUNCTIONS
// ==========================================

function handleLogin($input, $auth, $db)
{
    // Validate input
    if (empty($input['email']) || empty($input['password'])) {
        die(Response::validation([
            'email' => 'Email is required',
            'password' => 'Password is required'
        ]));
    }

    $email = $input['email'];
    $password = $input['password'];

    // Find user
    $sql = "SELECT id, uuid, name, email, password, role FROM users WHERE email = '{$db->escape($email)}' AND is_active = TRUE";
    $user = $db->fetchOne($sql);

    if (!$user || !$auth->verifyPassword($password, $user['password'])) {
        die(Response::error('Invalid email or password', 401));
    }

    // Generate token
    $token = $auth->generateJWT($user['id'], $user['email'], $user['role']);

    die(Response::success([
        'token' => $token,
        'user' => [
            'id' => $user['id'],
            'uuid' => $user['uuid'],
            'name' => $user['name'],
            'email' => $user['email'],
            'role' => $user['role']
        ]
    ], 'Login successful'));
}

function handleRegister($input, $auth, $db)
{
    // Validate input
    $errors = [];
    if (empty($input['name'])) $errors['name'] = 'Name is required';
    if (empty($input['email'])) $errors['email'] = 'Email is required';
    if (empty($input['password'])) $errors['password'] = 'Password is required';
    if (strlen($input['password'] ?? '') < PASSWORD_MIN_LENGTH) {
        $errors['password'] = 'Password must be at least ' . PASSWORD_MIN_LENGTH . ' characters';
    }
    if (empty($input['role']) || !in_array($input['role'], ['student', 'teacher'])) {
        $errors['role'] = 'Role must be student or teacher';
    }

    if (!empty($errors)) {
        die(Response::validation($errors));
    }

    // Check if email exists
    $email = $input['email'];
    $sql = "SELECT id FROM users WHERE email = '{$db->escape($email)}'";
    if ($db->fetchOne($sql)) {
        die(Response::error('Email already registered', 400));
    }

    // Create user
    $uuid = bin2hex(random_bytes(18));
    $name = $db->escape($input['name']);
    $passwordHash = $auth->hashPassword($input['password']);
    $role = $db->escape($input['role']);

    $sql = "INSERT INTO users (uuid, name, email, password, role, is_active)
            VALUES ('$uuid', '$name', '{$db->escape($email)}', '$passwordHash', '$role', TRUE)";

    if ($db->execute($sql)) {
        $userId = $db->lastInsertId();
        $token = $auth->generateJWT($userId, $email, $input['role']);

        die(Response::success([
            'token' => $token,
            'user' => [
                'id' => $userId,
                'uuid' => $uuid,
                'name' => $input['name'],
                'email' => $email,
                'role' => $input['role']
            ]
        ], 'Registration successful', 201));
    } else {
        die(Response::error('Registration failed', 500));
    }
}

function handleGetSubjects($input, $auth, $db)
{
    $user = $auth->getCurrentUser();
    $classId = $input['classId'] ?? 1;

    $sql = "SELECT s.id, s.uuid, s.name, s.description, s.color, s.icon,
                   COUNT(t.id) as total_topics,
                   SUM(CASE WHEN sp.is_completed THEN 1 ELSE 0 END) as completed_topics
            FROM subjects s
            LEFT JOIN topics t ON s.id = t.subject_id
            LEFT JOIN student_progress sp ON t.id = sp.topic_id AND sp.student_id = {$user['sub']}
            WHERE s.class_id = {$classId} AND s.is_active = TRUE
            GROUP BY s.id
            ORDER BY s.id";

    $subjects = $db->fetchAll($sql);

    die(Response::success($subjects, 'Subjects retrieved successfully'));
}

function handleGetSubject($id, $auth, $db)
{
    $sql = "SELECT * FROM subjects WHERE id = {$id} AND is_active = TRUE";
    $subject = $db->fetchOne($sql);

    if (!$subject) {
        die(Response::notFound('Subject not found'));
    }

    die(Response::success($subject));
}

function handleCreateSubject($input, $auth, $db)
{
    $errors = [];
    if (empty($input['name'])) $errors['name'] = 'Name is required';
    if (empty($input['classId'])) $errors['classId'] = 'Class ID is required';

    if (!empty($errors)) {
        die(Response::validation($errors));
    }

    $user = $auth->getCurrentUser();
    $uuid = bin2hex(random_bytes(18));
    $name = $db->escape($input['name']);
    $description = $db->escape($input['description'] ?? '');
    $color = $db->escape($input['color'] ?? '#5B5FDE');
    $icon = $db->escape($input['icon'] ?? '📚');
    $classId = intval($input['classId']);

    $sql = "INSERT INTO subjects (uuid, name, description, color, icon, class_id, created_by, is_active)
            VALUES ('$uuid', '$name', '$description', '$color', '$icon', {$classId}, {$user['sub']}, TRUE)";

    if ($db->execute($sql)) {
        $id = $db->lastInsertId();
        die(Response::success([
            'id' => $id,
            'uuid' => $uuid,
            'name' => $input['name'],
            'description' => $input['description'] ?? '',
            'color' => $color,
            'icon' => $icon
        ], 'Subject created successfully', 201));
    } else {
        die(Response::error('Failed to create subject', 500));
    }
}

function handleGetTopics($subjectId, $auth, $db)
{
    $user = $auth->getCurrentUser();

    $sql = "SELECT t.*, sp.is_completed, sp.completed_at
            FROM topics t
            LEFT JOIN student_progress sp ON t.id = sp.topic_id AND sp.student_id = {$user['sub']}
            WHERE t.subject_id = {$subjectId} AND t.is_active = TRUE
            ORDER BY t.order_index";

    $topics = $db->fetchAll($sql);

    die(Response::success($topics));
}

function handleCreateTopic($subjectId, $input, $auth, $db)
{
    $errors = [];
    if (empty($input['title'])) $errors['title'] = 'Title is required';

    if (!empty($errors)) {
        die(Response::validation($errors));
    }

    $user = $auth->getCurrentUser();
    $uuid = bin2hex(random_bytes(18));
    $title = $db->escape($input['title']);
    $description = $db->escape($input['description'] ?? '');
    $orderIndex = intval($input['orderIndex'] ?? 0);

    $sql = "INSERT INTO topics (uuid, subject_id, title, description, order_index, created_by, is_active)
            VALUES ('$uuid', {$subjectId}, '$title', '$description', {$orderIndex}, {$user['sub']}, TRUE)";

    if ($db->execute($sql)) {
        $id = $db->lastInsertId();
        die(Response::success([
            'id' => $id,
            'uuid' => $uuid,
            'title' => $input['title'],
            'description' => $input['description'] ?? '',
            'orderIndex' => $orderIndex
        ], 'Topic created successfully', 201));
    } else {
        die(Response::error('Failed to create topic', 500));
    }
}

function handleGetProgress($auth, $db)
{
    $user = $auth->getCurrentUser();

    $sql = "SELECT sp.*, t.title as topic_title, s.name as subject_name, s.color, s.icon
            FROM student_progress sp
            JOIN topics t ON sp.topic_id = t.id
            JOIN subjects s ON t.subject_id = s.id
            WHERE sp.student_id = {$user['sub']}
            ORDER BY s.id, t.order_index";

    $progress = $db->fetchAll($sql);

    die(Response::success($progress));
}

function handleGetTopicProgress($topicId, $auth, $db)
{
    $user = $auth->getCurrentUser();

    $sql = "SELECT * FROM student_progress
            WHERE student_id = {$user['sub']} AND topic_id = {$topicId}";

    $progress = $db->fetchOne($sql);

    if (!$progress) {
        // Create progress entry if doesn't exist
        $uuid = bin2hex(random_bytes(18));
        $sql = "INSERT INTO student_progress (uuid, student_id, topic_id, is_completed)
                VALUES ('$uuid', {$user['sub']}, {$topicId}, FALSE)";
        $db->execute($sql);
        $progress = ['student_id' => $user['sub'], 'topic_id' => $topicId, 'is_completed' => 0];
    }

    die(Response::success($progress));
}

function handleUpdateProgress($topicId, $input, $auth, $db)
{
    $user = $auth->getCurrentUser();
    $isCompleted = isset($input['isCompleted']) ? (bool)$input['isCompleted'] : false;

    // Check if progress exists
    $sql = "SELECT id FROM student_progress WHERE student_id = {$user['sub']} AND topic_id = {$topicId}";
    $progress = $db->fetchOne($sql);

    if (!$progress) {
        // Create new progress entry
        $uuid = bin2hex(random_bytes(18));
        $sql = "INSERT INTO student_progress (uuid, student_id, topic_id, is_completed, completed_at)
                VALUES ('$uuid', {$user['sub']}, {$topicId}, {$isCompleted}, " . ($isCompleted ? 'NOW()' : 'NULL') . ")";
    } else {
        // Update existing
        $completedAt = $isCompleted ? 'NOW()' : 'NULL';
        $sql = "UPDATE student_progress SET is_completed = {$isCompleted}, completed_at = {$completedAt}, updated_at = NOW()
                WHERE student_id = {$user['sub']} AND topic_id = {$topicId}";
    }

    if ($db->execute($sql)) {
        die(Response::success(['isCompleted' => $isCompleted], 'Progress updated'));
    } else {
        die(Response::error('Failed to update progress', 500));
    }
}

function handleGetStudents($auth, $db)
{
    $teacher = $auth->getCurrentUser();

    $sql = "SELECT DISTINCT u.id, u.uuid, u.name, u.email,
                   COUNT(DISTINCT sp.id) as topics_completed,
                   COUNT(DISTINCT t.id) as total_topics
            FROM users u
            JOIN class_enrollments ce ON u.id = ce.student_id
            JOIN classes c ON ce.class_id = c.id
            LEFT JOIN student_progress sp ON u.id = sp.student_id AND sp.is_completed = TRUE
            LEFT JOIN topics t ON t.subject_id = (SELECT id FROM subjects WHERE class_id = c.id LIMIT 1)
            WHERE c.teacher_id = {$teacher['sub']} AND u.role = 'student' AND ce.is_active = TRUE
            GROUP BY u.id
            ORDER BY u.name";

    $students = $db->fetchAll($sql);

    die(Response::success($students));
}

function handleGetStudentProgress($studentId, $auth, $db)
{
    $teacher = $auth->getCurrentUser();

    // Verify teacher owns this student
    $sql = "SELECT COUNT(*) as count FROM class_enrollments ce
            JOIN classes c ON ce.class_id = c.id
            WHERE ce.student_id = {$studentId} AND c.teacher_id = {$teacher['sub']}";

    if ($db->fetchValue($sql) == 0) {
        die(Response::forbidden('Cannot view this students progress'));
    }

    // Get progress details
    $sql = "SELECT s.name as subject_name, s.color, s.icon,
                   COUNT(t.id) as total_topics,
                   SUM(CASE WHEN sp.is_completed THEN 1 ELSE 0 END) as completed_topics
            FROM subjects s
            LEFT JOIN topics t ON s.id = t.subject_id
            LEFT JOIN student_progress sp ON t.id = sp.topic_id AND sp.student_id = {$studentId}
            GROUP BY s.id
            ORDER BY s.id";

    $progress = $db->fetchAll($sql);

    die(Response::success($progress));
}

function handleGetOverallProgress($auth, $db)
{
    $user = $auth->getCurrentUser();

    $sql = "SELECT COUNT(DISTINCT t.id) as total_topics,
                   SUM(CASE WHEN sp.is_completed THEN 1 ELSE 0 END) as completed_topics
            FROM topics t
            LEFT JOIN student_progress sp ON t.id = sp.topic_id AND sp.student_id = {$user['sub']}
            WHERE t.is_active = TRUE";

    $overall = $db->fetchOne($sql);

    $percentage = $overall['total_topics'] > 0
        ? round(($overall['completed_topics'] / $overall['total_topics']) * 100)
        : 0;

    die(Response::success([
        'completedTopics' => (int)$overall['completed_topics'],
        'totalTopics' => (int)$overall['total_topics'],
        'percentage' => (int)$percentage
    ]));
}
