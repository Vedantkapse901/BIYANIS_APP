<?php
/**
 * Student Logbook System - Configuration
 * Handles all database and API configuration
 */

// ==========================================
// DATABASE CONFIGURATION
// ==========================================

define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', ''); // Change this to your MySQL password
define('DB_NAME', 'student_logbook');
define('DB_PORT', 3306);

// ==========================================
// API CONFIGURATION
// ==========================================

define('API_VERSION', 'v1');
define('API_BASE_URL', 'http://localhost:8000/api/v1');
define('ALLOWED_ORIGINS', ['http://localhost:3000', 'http://localhost:8100']);

// ==========================================
// AUTHENTICATION CONFIGURATION
// ==========================================

define('JWT_SECRET', 'your-super-secret-jwt-key-change-this-in-production');
define('JWT_ALGORITHM', 'HS256');
define('JWT_EXPIRATION', 86400 * 7); // 7 days in seconds
define('REFRESH_TOKEN_EXPIRATION', 86400 * 30); // 30 days

// ==========================================
// APP CONFIGURATION
// ==========================================

define('APP_NAME', 'Student Logbook System');
define('APP_VERSION', '1.0.0');
define('TIMEZONE', 'Asia/Kolkata');
define('ENVIRONMENT', 'development'); // 'development' or 'production'

// ==========================================
// LOGGING CONFIGURATION
// ==========================================

define('LOG_LEVEL', 'info'); // 'debug', 'info', 'warning', 'error'
define('LOG_DIR', __DIR__ . '/logs');
define('LOG_FILE', LOG_DIR . '/app-' . date('Y-m-d') . '.log');

// ==========================================
// SECURITY CONFIGURATION
// ==========================================

define('PASSWORD_MIN_LENGTH', 8);
define('BCRYPT_COST', 10);
define('CORS_ENABLED', true);
define('RATE_LIMIT_ENABLED', false);
define('RATE_LIMIT_REQUESTS', 100);
define('RATE_LIMIT_WINDOW', 3600); // 1 hour

// ==========================================
// EMAIL CONFIGURATION (Optional)
// ==========================================

define('MAIL_HOST', 'smtp.gmail.com');
define('MAIL_PORT', 587);
define('MAIL_USER', 'your-email@gmail.com');
define('MAIL_PASS', 'your-app-password');
define('MAIL_FROM', 'noreply@studentlogbook.com');

// ==========================================
// ERROR HANDLING
// ==========================================

if (ENVIRONMENT === 'development') {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
} else {
    error_reporting(0);
    ini_set('display_errors', 0);
}

date_default_timezone_set(TIMEZONE);

// ==========================================
// SETUP LOGGING DIRECTORY
// ==========================================

if (!is_dir(LOG_DIR)) {
    mkdir(LOG_DIR, 0755, true);
}

// ==========================================
// LOAD AUTOLOADER (if using Composer)
// ==========================================

// if (file_exists(__DIR__ . '/vendor/autoload.php')) {
//     require_once __DIR__ . '/vendor/autoload.php';
// }
