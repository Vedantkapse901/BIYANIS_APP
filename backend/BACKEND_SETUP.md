# 🔧 PHP/MySQL Backend Setup Guide

Complete setup guide for the Student Logbook API backend.

---

## 📋 Prerequisites

- PHP 7.4+ (8.0+ recommended)
- MySQL 5.7+ or MariaDB 10.3+
- Apache with mod_rewrite enabled (or Nginx)
- Composer (optional, for dependency management)
- REST API client for testing (Postman, Insomnia, or cURL)

---

## 🚀 Quick Setup (5 minutes)

### Step 1: Create Database

```bash
# Connect to MySQL
mysql -u root -p

# Run the schema
source /path/to/backend/database.sql

# Verify database created
USE student_logbook;
SHOW TABLES;
```

### Step 2: Update Configuration

Edit `backend/config.php`:

```php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', 'your_password_here');  // Change this!
define('DB_NAME', 'student_logbook');
define('API_BASE_URL', 'http://localhost:8000/api/v1');
```

### Step 3: Start PHP Server

```bash
cd backend
php -S localhost:8000
```

### Step 4: Test API

Open in browser or use cURL:

```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "priya@school.com",
    "password": "password"
  }'
```

**Expected Response:**
```json
{
  "status": "success",
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "uuid": "550e8400-e29b-41d4-a716-446655440001",
      "name": "Ms. Priya Sharma",
      "email": "priya@school.com",
      "role": "teacher"
    }
  },
  "timestamp": "2024-01-15 10:30:45"
}
```

---

## 📁 Backend File Structure

```
backend/
├── index.php                 ← Main API router
├── config.php               ← Configuration file
├── Database.php             ← Database connection class
├── Response.php             ← API response handler
├── Auth.php                 ← Authentication & JWT
├── database.sql             ← MySQL schema
└── BACKEND_SETUP.md         ← This file
```

---

## 🗄️ Database Schema Overview

### 8 Main Tables:

1. **users** - Students and teachers
2. **classes** - Groups/batches
3. **class_enrollments** - Student enrollment
4. **subjects** - Courses/subjects
5. **topics** - Tasks/lessons
6. **student_progress** - Completion tracking
7. **auth_tokens** - Session management
8. **activity_logs** - Action logging

### Key Features:
- UUID for all entities (better for mobile)
- Soft deletes (is_active flag)
- Timestamps on all records
- Foreign key constraints
- Optimized indexes for queries

---

## 🔐 Authentication

### How It Works:

1. **Login** → POST `/auth/login`
   - Returns JWT token
   - Token valid for 7 days

2. **Include Token** → Add to all requests
   ```
   Authorization: Bearer <token>
   ```

3. **Verify Token** → JWT validated on each request
   - Check signature
   - Check expiration
   - Extract user info

### JWT Token Structure:

```
header.payload.signature

Payload contains:
{
  "iat": 1705318245,
  "exp": 1706008245,
  "iss": "http://localhost:8000/api/v1",
  "sub": 1,
  "email": "priya@school.com",
  "role": "teacher"
}
```

### Default Test Credentials:

**Teacher:**
- Email: `priya@school.com`
- Password: `password`
- Role: `teacher`

**Student:**
- Email: `aarav@student.com`
- Password: `password`
- Role: `student`

---

## 📡 API Endpoints Reference

### Authentication

```
POST   /auth/login              Login user, get JWT token
POST   /auth/register           Register new user
GET    /auth/me                 Get current user info
```

### Subjects

```
GET    /subjects                Get all subjects
GET    /subjects/{id}           Get single subject
POST   /subjects                Create subject (teacher only)
```

### Topics

```
GET    /subjects/{id}/topics    Get topics for subject
POST   /subjects/{id}/topics    Create topic (teacher only)
```

### Progress

```
GET    /progress                Get student progress
GET    /progress/{id}           Get topic progress
PUT    /progress/{id}           Update topic completion
GET    /progress/overall        Get overall progress percentage
```

### Students (Teacher Only)

```
GET    /students                Get all students
GET    /students/{id}/progress  Get student progress details
```

---

## 🧪 Testing API Endpoints

### 1. Login & Get Token

```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "priya@school.com",
    "password": "password"
  }'
```

Save the token from response.

### 2. Get Subjects (with token)

```bash
curl -X GET http://localhost:8000/api/v1/subjects \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 3. Get Topics

```bash
curl -X GET http://localhost:8000/api/v1/subjects/1/topics \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 4. Update Progress

```bash
curl -X PUT http://localhost:8000/api/v1/progress/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "isCompleted": true
  }'
```

---

## 🔧 Configuration Details

### `config.php` Options:

```php
// Database
DB_HOST              Database host (default: localhost)
DB_USER              Database user (default: root)
DB_PASS              Database password
DB_NAME              Database name (default: student_logbook)

// API
API_VERSION          Current version (default: v1)
API_BASE_URL         API base URL for CORS
ALLOWED_ORIGINS      Domains that can access API

// Auth
JWT_SECRET           Secret key for signing tokens
JWT_EXPIRATION       Token lifetime (default: 7 days)
JWT_ALGORITHM        Algorithm (HS256)

// Security
PASSWORD_MIN_LENGTH  Minimum password length (default: 8)
BCRYPT_COST          Password hashing cost (default: 10)
```

---

## 🚨 Common Issues & Solutions

### Error: "Database connection failed"

**Solution:**
```php
// Check credentials in config.php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', 'your_password');
define('DB_NAME', 'student_logbook');

// Verify MySQL is running
mysql -u root -p -e "SELECT VERSION();"
```

### Error: "404 Not Found"

**Solution:**
- Check endpoint URL is correct
- Verify PHP server is running
- Check request method (GET, POST, PUT, etc.)

### Error: "401 Unauthorized"

**Solution:**
```bash
# Token expired or invalid
# Login again to get new token
curl -X POST http://localhost:8000/api/v1/auth/login ...
```

### Error: "CORS blocked"

**Solution:**
```php
// Response.php already handles CORS
// Ensure setCORS() is called at start
Response::setCORS();
```

---

## 🔄 Integrating with Flutter App

The Flutter app connects to this backend via `lib/core/services/api_client.dart`.

### Change API URL (for production):

```dart
// File: lib/core/services/api_client.dart

class ApiClient {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  
  // Change to your server:
  // static const String baseUrl = 'https://api.yourserver.com/api/v1';
}
```

### Update Flutter providers:

```dart
// File: lib/features/logbook/presentation/providers/logbook_providers.dart

// Change from local Hive to API

final allSubjectsProvider = FutureProvider<List<SubjectEntity>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final data = await apiClient.getSubjects();
  return data.map((json) => SubjectEntity.fromJson(json)).toList();
});
```

---

## 🚀 Deployment

### For Production:

1. **Host Selection:**
   - AWS EC2
   - DigitalOcean
   - Heroku
   - Bluehost/Hostinger (shared hosting)

2. **Setup Steps:**
   ```bash
   # 1. Upload files via FTP/SFTP
   # 2. Create MySQL database
   # 3. Import schema: mysql student_logbook < database.sql
   # 4. Update config.php with production credentials
   # 5. Enable SSL/HTTPS
   # 6. Update CORS origins
   # 7. Set environment to 'production'
   ```

3. **Configuration Changes:**
   ```php
   // config.php
   define('ENVIRONMENT', 'production');
   define('API_BASE_URL', 'https://api.yourserver.com/api/v1');
   define('ALLOWED_ORIGINS', ['https://yourapp.com']);
   ```

4. **Security Checklist:**
   - [ ] Change JWT_SECRET
   - [ ] Change DB password
   - [ ] Enable SSL/HTTPS
   - [ ] Set error_reporting to 0
   - [ ] Hide PHP version
   - [ ] Regular backups
   - [ ] Monitor logs

---

## 📊 Database Views

Pre-built views for analytics:

### `student_progress_summary`
```sql
SELECT student_id, student_name, subject_id, subject_name,
       total_topics, completed_topics, completion_percentage
FROM student_progress_summary;
```

### `class_progress_summary`
```sql
SELECT class_id, class_name, total_students,
       students_with_progress, average_completion
FROM class_progress_summary;
```

---

## 🔄 Data Sync Between Local & Remote

The system supports both:

1. **Local-Only** (Current Flutter app with Hive)
   - Data stored on device
   - Works offline
   - No server needed

2. **Remote API** (PHP/MySQL)
   - Data synced to server
   - Access from multiple devices
   - Teacher insights

3. **Hybrid** (Local + Remote)
   - Save locally immediately
   - Sync to server when online
   - Offline-first UX

---

## 📚 Additional Resources

### PHP Documentation:
- https://www.php.net/manual/
- https://www.php.net/manual/en/mysqli.overview.php

### MySQL Documentation:
- https://dev.mysql.com/doc/
- https://dev.mysql.com/doc/refman/8.0/en/

### JWT in PHP:
- https://tools.ietf.org/html/rfc7519
- https://www.php.net/manual/en/function.json-encode.php

---

## ✅ Verification Checklist

- [ ] MySQL database created
- [ ] config.php updated with credentials
- [ ] PHP server running on localhost:8000
- [ ] Can login with test credentials
- [ ] JWT token generated successfully
- [ ] Can fetch subjects with token
- [ ] Can update progress
- [ ] CORS enabled
- [ ] Error handling working
- [ ] Logs directory writable

---

## 🆘 Getting Help

If you encounter issues:

1. Check error logs in `backend/logs/`
2. Run `php -S localhost:8000 -t .` in verbose mode
3. Use browser DevTools to inspect requests
4. Check MySQL error: `SHOW ENGINE INNODB STATUS;`
5. Verify credentials in config.php

---

**Backend ready to serve your Flutter app!** 🚀
