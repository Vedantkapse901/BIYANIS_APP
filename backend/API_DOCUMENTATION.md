# 📡 API Documentation

Complete API reference for Student Logbook Backend.

**Base URL:** `http://localhost:8000/api/v1`

---

## 🔐 Authentication

All endpoints (except `/auth/login` and `/auth/register`) require JWT token in header:

```
Authorization: Bearer <jwt_token>
```

### Response Format

All responses follow this format:

**Success:**
```json
{
  "status": "success",
  "message": "Operation successful",
  "data": {},
  "timestamp": "2024-01-15 10:30:45"
}
```

**Error:**
```json
{
  "status": "error",
  "message": "Error description",
  "errors": {},
  "timestamp": "2024-01-15 10:30:45"
}
```

---

## 🔑 Authentication Endpoints

### Login

**Endpoint:** `POST /auth/login`

**Description:** Authenticate user and get JWT token

**Request:**
```json
{
  "email": "priya@school.com",
  "password": "password"
}
```

**Response (200):**
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
  }
}
```

**Errors:**
- `400` - Invalid email or password
- `401` - User not found or inactive

---

### Register

**Endpoint:** `POST /auth/register`

**Description:** Create new user account

**Request:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "secure_password123",
  "role": "student"  // or "teacher"
}
```

**Response (201):**
```json
{
  "status": "success",
  "message": "Registration successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 8,
      "uuid": "550e8400-e29b-41d4-a716-446655440008",
      "name": "John Doe",
      "email": "john@example.com",
      "role": "student"
    }
  }
}
```

**Errors:**
- `422` - Validation error (missing fields, password too short)
- `400` - Email already registered

---

### Get Current User

**Endpoint:** `GET /auth/me`

**Description:** Get currently logged-in user info

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "email": "priya@school.com",
    "role": "teacher"
  }
}
```

**Errors:**
- `401` - Unauthorized/Invalid token

---

## 📚 Subject Endpoints

### Get All Subjects

**Endpoint:** `GET /subjects`

**Description:** Get all subjects (with progress for current student)

**Query Parameters:**
- `classId` (optional) - Filter by class (default: 1)

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "status": "success",
  "message": "Subjects retrieved successfully",
  "data": [
    {
      "id": 1,
      "uuid": "550e8400-e29b-41d4-a716-446655440201",
      "name": "Mathematics",
      "description": "Basic Mathematics and Algebra",
      "color": "#5B5FDE",
      "icon": "🧮",
      "total_topics": 5,
      "completed_topics": 2
    },
    {
      "id": 2,
      "uuid": "550e8400-e29b-41d4-a716-446655440202",
      "name": "English",
      "description": "English Language and Literature",
      "color": "#00D4AA",
      "icon": "📚",
      "total_topics": 5,
      "completed_topics": 0
    }
  ]
}
```

**Errors:**
- `401` - Unauthorized

---

### Get Single Subject

**Endpoint:** `GET /subjects/{id}`

**Description:** Get subject details

**Parameters:**
- `id` - Subject ID (path parameter)

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "uuid": "550e8400-e29b-41d4-a716-446655440201",
    "name": "Mathematics",
    "description": "Basic Mathematics and Algebra",
    "color": "#5B5FDE",
    "icon": "🧮",
    "class_id": 1,
    "created_by": 1,
    "is_active": true
  }
}
```

**Errors:**
- `404` - Subject not found
- `401` - Unauthorized

---

### Create Subject

**Endpoint:** `POST /subjects`

**Description:** Create new subject (teacher only)

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "name": "History",
  "classId": 1,
  "description": "History and world events",
  "color": "#FF9500",
  "icon": "📖"
}
```

**Response (201):**
```json
{
  "status": "success",
  "message": "Subject created successfully",
  "data": {
    "id": 4,
    "uuid": "550e8400-e29b-41d4-a716-446655440204",
    "name": "History",
    "description": "History and world events",
    "color": "#FF9500",
    "icon": "📖"
  }
}
```

**Errors:**
- `403` - Forbidden (not a teacher)
- `422` - Validation error

---

## 📝 Topic Endpoints

### Get Topics by Subject

**Endpoint:** `GET /subjects/{subjectId}/topics`

**Description:** Get all topics for a subject with student progress

**Parameters:**
- `subjectId` - Subject ID (path parameter)

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "uuid": "550e8400-e29b-41d4-a716-446655440301",
      "subject_id": 1,
      "title": "Chapter 1: Numbers and Operations",
      "description": "Learn about basic numbers and arithmetic operations",
      "order_index": 1,
      "created_by": 1,
      "is_active": true,
      "is_completed": true,
      "completed_at": "2024-01-10 14:30:00"
    },
    {
      "id": 2,
      "uuid": "550e8400-e29b-41d4-a716-446655440302",
      "subject_id": 1,
      "title": "Chapter 2: Algebra Basics",
      "description": "Introduction to algebraic expressions",
      "order_index": 2,
      "created_by": 1,
      "is_active": true,
      "is_completed": false,
      "completed_at": null
    }
  ]
}
```

**Errors:**
- `401` - Unauthorized

---

### Create Topic

**Endpoint:** `POST /subjects/{subjectId}/topics`

**Description:** Create new topic in subject (teacher only)

**Parameters:**
- `subjectId` - Subject ID (path parameter)

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "title": "Chapter 6: Advanced Topics",
  "description": "Complex mathematical concepts",
  "orderIndex": 6
}
```

**Response (201):**
```json
{
  "status": "success",
  "message": "Topic created successfully",
  "data": {
    "id": 6,
    "uuid": "550e8400-e29b-41d4-a716-446655440316",
    "title": "Chapter 6: Advanced Topics",
    "description": "Complex mathematical concepts",
    "orderIndex": 6
  }
}
```

**Errors:**
- `403` - Forbidden (not a teacher)
- `422` - Validation error

---

## 📊 Progress Endpoints

### Get Student Progress

**Endpoint:** `GET /progress`

**Description:** Get all progress for current student across all topics

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "uuid": "550e8400-e29b-41d4-a716-446655440401",
      "student_id": 3,
      "topic_id": 1,
      "is_completed": true,
      "completed_at": "2024-01-10 14:30:00",
      "attempts": 1,
      "last_accessed": "2024-01-15 10:00:00",
      "topic_title": "Chapter 1: Numbers and Operations",
      "subject_name": "Mathematics",
      "color": "#5B5FDE",
      "icon": "🧮"
    }
  ]
}
```

**Errors:**
- `401` - Unauthorized

---

### Get Topic Progress

**Endpoint:** `GET /progress/{topicId}`

**Description:** Get progress for specific topic

**Parameters:**
- `topicId` - Topic ID (path parameter)

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "uuid": "550e8400-e29b-41d4-a716-446655440401",
    "student_id": 3,
    "topic_id": 1,
    "is_completed": true,
    "completed_at": "2024-01-10 14:30:00",
    "attempts": 1
  }
}
```

**Errors:**
- `401` - Unauthorized

---

### Update Topic Progress

**Endpoint:** `PUT /progress/{topicId}`

**Description:** Mark topic as completed/incomplete

**Parameters:**
- `topicId` - Topic ID (path parameter)

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "isCompleted": true
}
```

**Response (200):**
```json
{
  "status": "success",
  "message": "Progress updated",
  "data": {
    "isCompleted": true
  }
}
```

**Errors:**
- `401` - Unauthorized
- `403` - Forbidden (not a student)

---

### Get Overall Progress

**Endpoint:** `GET /progress/overall`

**Description:** Get overall completion percentage

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "completedTopics": 15,
    "totalTopics": 25,
    "percentage": 60
  }
}
```

**Errors:**
- `401` - Unauthorized

---

## 👥 Student Endpoints (Teacher Only)

### Get All Students

**Endpoint:** `GET /students`

**Description:** Get all students in class with progress summary

**Headers:**
```
Authorization: Bearer <token>
Role: teacher
```

**Response (200):**
```json
{
  "status": "success",
  "data": [
    {
      "id": 3,
      "uuid": "550e8400-e29b-41d4-a716-446655440010",
      "name": "Aarav Kumar",
      "email": "aarav@student.com",
      "topics_completed": 10,
      "total_topics": 25
    },
    {
      "id": 4,
      "uuid": "550e8400-e29b-41d4-a716-446655440011",
      "name": "Priya Singh",
      "email": "priya.singh@student.com",
      "topics_completed": 18,
      "total_topics": 25
    }
  ]
}
```

**Errors:**
- `401` - Unauthorized
- `403` - Forbidden (not a teacher)

---

### Get Student Progress Details

**Endpoint:** `GET /students/{studentId}/progress`

**Description:** Get detailed progress for specific student by subject

**Parameters:**
- `studentId` - Student ID (path parameter)

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "status": "success",
  "data": [
    {
      "subject_name": "Mathematics",
      "color": "#5B5FDE",
      "icon": "🧮",
      "total_topics": 5,
      "completed_topics": 3
    },
    {
      "subject_name": "English",
      "color": "#00D4AA",
      "icon": "📚",
      "total_topics": 5,
      "completed_topics": 2
    }
  ]
}
```

**Errors:**
- `401` - Unauthorized
- `403` - Forbidden (cannot view other teacher's students)

---

## 🔄 HTTP Status Codes

| Code | Meaning | When |
|------|---------|------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Invalid data provided |
| 401 | Unauthorized | Missing/invalid token |
| 403 | Forbidden | Don't have permission |
| 404 | Not Found | Resource doesn't exist |
| 422 | Validation Error | Field validation failed |
| 500 | Server Error | Internal server error |

---

## 💡 Usage Examples

### Example 1: Login and Get Subjects

```bash
# 1. Login
TOKEN=$(curl -s -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"priya@school.com","password":"password"}' \
  | jq -r '.data.token')

# 2. Get subjects with token
curl -X GET http://localhost:8000/api/v1/subjects \
  -H "Authorization: Bearer $TOKEN"
```

### Example 2: Student Marks Task Complete

```bash
# 1. Get JWT token (from login)
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# 2. Mark topic 1 as complete
curl -X PUT http://localhost:8000/api/v1/progress/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"isCompleted": true}'

# 3. Get updated overall progress
curl -X GET http://localhost:8000/api/v1/progress/overall \
  -H "Authorization: Bearer $TOKEN"
```

### Example 3: Teacher Creates Subject

```bash
# Get teacher token
TOKEN=$(curl -s -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"rajesh@school.com","password":"password"}' \
  | jq -r '.data.token')

# Create subject
curl -X POST http://localhost:8000/api/v1/subjects \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Physics",
    "classId": 1,
    "description": "Physics and mechanics",
    "color": "#FF6B6B",
    "icon": "⚡"
  }'
```

---

## 🛡️ Security Notes

1. **Always use HTTPS** in production
2. **Keep JWT_SECRET** safe
3. **Validate all inputs** (already done in API)
4. **Implement rate limiting** (optional)
5. **Use strong passwords** (min 8 chars)
6. **Regular backups** of database
7. **Monitor activity logs**

---

## 📞 Support

For API issues:
1. Check status code and error message
2. Verify token is valid
3. Check request format matches documentation
4. Review backend logs
5. Test with Postman/Insomnia

---

**API is ready for integration with Flutter app!** 🚀
