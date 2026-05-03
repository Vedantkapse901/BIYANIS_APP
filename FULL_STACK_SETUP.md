# 🚀 Full Stack Setup - Flutter + PHP/MySQL

Complete guide to set up the **entire Student Logbook System** with Flutter frontend and PHP/MySQL backend.

---

## 📊 System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  STUDENT LOGBOOK SYSTEM                  │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────────┐           ┌──────────────────┐   │
│  │   FLUTTER APP    │◄──────────►│   PHP/MYSQL API  │   │
│  │  (Android/iOS)   │  REST API  │     Backend      │   │
│  │                  │            │                  │   │
│  │ • Dashboard      │ JWT Token  │ • Auth           │   │
│  │ • Progress UI    │ JSON Data  │ • Subjects       │   │
│  │ • Local Cache    │            │ • Topics         │   │
│  │ • Offline Mode   │            │ • Progress       │   │
│  └──────────────────┘            └────────┬─────────┘   │
│         │                                   │            │
│         ▼                                   ▼            │
│    ┌──────────────┐              ┌──────────────────┐  │
│    │ Hive (Cache) │              │ MySQL Database   │  │
│    │ Local Data   │              │ Persistent Data  │  │
│    └──────────────┘              └──────────────────┘  │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

---

## ⚙️ Setup Path

Choose based on your needs:

**Option A: Local Development**
- Flutter app with local Hive database
- PHP backend on localhost
- No internet required
- Great for testing

**Option B: Production Deployment**
- Flutter app with PHP backend
- MySQL on cloud server
- Real users and data
- HTTPS required

---

## 🔧 Phase 1: Backend Setup (PHP/MySQL)

### Step 1.1: Create MySQL Database

```bash
# Connect to MySQL
mysql -u root -p

# Run schema
source /path/to/backend/database.sql

# Verify
USE student_logbook;
SHOW TABLES;
```

### Step 1.2: Configure PHP

Edit `backend/config.php`:

```php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', 'your_mysql_password');
define('DB_NAME', 'student_logbook');
define('API_BASE_URL', 'http://localhost:8000/api/v1');
define('JWT_SECRET', 'change-this-to-random-string');
define('ENVIRONMENT', 'development');
```

### Step 1.3: Start PHP Server

```bash
cd /path/to/backend
php -S localhost:8000
```

### Step 1.4: Test Backend

```bash
# Test login
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"priya@school.com","password":"password"}'

# Expected response with token
```

✅ **Backend ready!**

---

## 📱 Phase 2: Flutter Frontend Setup

### Step 2.1: Install Flutter (if not done)

See `SETUP_GUIDE.md` for detailed instructions for your platform.

### Step 2.2: Update API Endpoint

Edit `lib/core/services/api_client.dart`:

```dart
class ApiClient {
  // For local development:
  static const String baseUrl = 'http://localhost:8000/api/v1';
  
  // For production (change when deploying):
  // static const String baseUrl = 'https://api.yourserver.com/api/v1';
}
```

### Step 2.3: Install Dependencies

```bash
cd /path/to/student-logbook
flutter pub get
flutter pub run build_runner build
```

### Step 2.4: Run Flutter App

**Option A: Use Local Database (Offline Mode)**
```bash
# Current setup - uses Hive locally
flutter run
```

**Option B: Connect to PHP Backend**

This requires modifications to switch from local Hive to API. Create new providers:

Edit `lib/features/logbook/presentation/providers/logbook_providers.dart`:

```dart
// BEFORE: Uses local Hive
final allSubjectsProvider = FutureProvider<List<SubjectEntity>>((ref) async {
  final repository = ref.watch(logbookRepositoryProvider);
  return repository.getAllSubjects();
});

// AFTER: Uses PHP API
final allSubjectsProvider = FutureProvider<List<SubjectEntity>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final data = await apiClient.getSubjects();
    return data.map((json) => SubjectEntity(
      id: json['id'].toString(),
      name: json['name'],
      color: json['color'],
      icon: json['icon'],
      topics: [],
      totalTopics: json['total_topics'],
      completedTopics: json['completed_topics'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    )).toList();
  } catch (e) {
    // Fallback to local cache
    final localRepo = ref.watch(logbookRepositoryProvider);
    return localRepo.getAllSubjects();
  }
});
```

✅ **Frontend ready!**

---

## 🔄 Phase 3: Integration & Sync

### Option A: Hybrid Approach (Recommended)

**Best of both worlds:**
- Data saved locally immediately (fast UX)
- Auto-sync to PHP backend when online
- Offline-first functionality

Implementation:

```dart
// In progress update:
Future<void> updateProgressHybrid(String topicId, bool isCompleted) async {
  // 1. Update local database first
  await localRepository.toggleTopicCompletion(topicId);
  
  // 2. Sync to server in background
  try {
    final apiClient = ref.watch(apiClientProvider);
    await apiClient.updateProgress(int.parse(topicId), 
      isCompleted: isCompleted);
  } catch (e) {
    // Fallback: will retry when online
    logError('Sync failed, will retry: $e');
  }
}
```

### Option B: API-Only (Production Ready)

Remove Hive, use only PHP backend:

1. Remove Hive dependencies from `pubspec.yaml`
2. Remove local database files
3. Use API for all data operations
4. Cache responses with Riverpod

---

## 🧪 Testing the Full System

### Test Scenario 1: Student Marks Task Complete

**Steps:**

1. **Start backend**
   ```bash
   cd backend
   php -S localhost:8000
   ```

2. **Start Flutter app**
   ```bash
   flutter run
   ```

3. **Login as student**
   - Email: `aarav@student.com`
   - Password: `password`

4. **Tap topic checkbox**
   - Should update locally immediately
   - Should sync to server

5. **Teacher checks progress**
   - Login as: `rajesh@school.com`
   - View students
   - See updated progress

### Test Scenario 2: Offline Mode

1. **Enable Airplane Mode**
2. **Mark topics complete**
3. **Verify data saved locally**
4. **Disable Airplane Mode**
5. **Data syncs automatically**

### Test Scenario 3: Multiple Devices

1. **Login on Device A**
2. **Mark topics complete**
3. **Login on Device B**
4. **See same progress**

---

## 🚀 Production Deployment

### Step 1: Choose Hosting

**PHP Backend Options:**
- **Heroku** (easiest for beginners)
- **DigitalOcean** (affordable, powerful)
- **AWS** (scalable)
- **Bluehost/Hostinger** (traditional shared hosting)

**Example: Heroku**

```bash
# 1. Install Heroku CLI
# 2. Create app
heroku create student-logbook-api

# 3. Add MySQL
heroku addons:create cleardb:ignite

# 4. Deploy
git push heroku main

# 5. Run migrations
heroku run php database.sql
```

### Step 2: Update Configuration

**On Production Server:**

```php
// config.php
define('ENVIRONMENT', 'production');
define('DB_HOST', 'production-db.com');
define('DB_USER', 'prod_user');
define('DB_PASS', 'secure_password');
define('API_BASE_URL', 'https://api.yourserver.com/api/v1');
define('JWT_SECRET', 'generate-random-secret-key');
define('CORS_ALLOWED', ['https://yourapp.com']);
```

### Step 3: Update Flutter App

**In `lib/core/services/api_client.dart`:**

```dart
class ApiClient {
  static const String baseUrl = 'https://api.yourserver.com/api/v1';
}
```

### Step 4: Build Release APK/IPA

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 🔐 Security Checklist

### Backend
- [ ] Change JWT_SECRET to random string
- [ ] Change database password
- [ ] Enable HTTPS/SSL
- [ ] Set ENVIRONMENT to 'production'
- [ ] Hide PHP version header
- [ ] Enable firewall
- [ ] Regular backups
- [ ] Monitor logs
- [ ] Update PHP to latest version
- [ ] Restrict database access

### Frontend
- [ ] No hardcoded credentials
- [ ] Validate all user inputs
- [ ] Secure token storage
- [ ] HTTPS only in production
- [ ] Update Flutter dependencies
- [ ] Obfuscate/minify code
- [ ] Test on real devices

### Database
- [ ] Regular backups
- [ ] Access control
- [ ] Encrypted passwords
- [ ] Monitor queries
- [ ] Optimize indexes

---

## 📊 Database Backup & Restore

### Backup

```bash
# Backup database
mysqldump -u root -p student_logbook > backup.sql

# Backup with timestamp
mysqldump -u root -p student_logbook > backup_$(date +%Y%m%d).sql
```

### Restore

```bash
# Restore from backup
mysql -u root -p student_logbook < backup.sql
```

---

## 🐛 Troubleshooting

### Issue: Flutter can't connect to PHP server

**Solution:**
```dart
// Check API endpoint is correct
static const String baseUrl = 'http://10.0.2.2:8000/api/v1';  // Android emulator
static const String baseUrl = 'http://localhost:8000/api/v1';  // iOS simulator
static const String baseUrl = 'http://192.168.1.x:8000/api/v1'; // Real device
```

### Issue: 401 Unauthorized on all requests

**Solution:**
```bash
# Check JWT secret matches
# Verify token format
# Check token expiration
# Test login endpoint
```

### Issue: Database connection error

**Solution:**
```bash
# Verify MySQL is running
mysql -u root -p -e "SELECT VERSION();"

# Check credentials in config.php
# Verify database exists
mysql -u root -p -e "SHOW DATABASES; USE student_logbook; SHOW TABLES;"
```

### Issue: CORS errors

**Solution:**
```php
// Already handled in Response.php
Response::setCORS();

// Or update CORS settings:
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
```

---

## 📈 Monitoring & Analytics

### Check API Logs

```bash
# View recent logs
tail -f backend/logs/app-*.log

# Search for errors
grep ERROR backend/logs/app-*.log

# Count requests
wc -l backend/logs/app-*.log
```

### Monitor Database

```sql
-- Check slow queries
SHOW PROCESSLIST;

-- Analyze table
ANALYZE TABLE student_progress;

-- Check indexes
SHOW INDEX FROM student_progress;
```

---

## ✅ Verification Checklist

### Backend
- [ ] MySQL database created
- [ ] config.php updated
- [ ] PHP server running
- [ ] Can login
- [ ] JWT tokens generated
- [ ] API endpoints working
- [ ] CORS enabled
- [ ] Error handling working
- [ ] Logs directory created
- [ ] Database views created

### Frontend
- [ ] Flutter installed
- [ ] Dependencies installed
- [ ] API endpoint configured
- [ ] Can run on emulator
- [ ] Can run on real device
- [ ] Offline mode works
- [ ] Sync logic works
- [ ] UI displays correctly
- [ ] Animations smooth

### Integration
- [ ] Frontend connects to backend
- [ ] Login works end-to-end
- [ ] Data syncs to server
- [ ] Teacher can see student progress
- [ ] Multiple devices can sync
- [ ] Offline → online transition works

---

## 🎉 You're Ready!

You now have a **complete full-stack application** with:

✅ Flutter frontend (Android + iOS)
✅ PHP REST API backend
✅ MySQL database
✅ Real-time progress tracking
✅ Offline-first functionality
✅ User authentication
✅ Role-based access
✅ Production-ready architecture

---

## 📚 Next Steps

1. **Test thoroughly** on emulator and real devices
2. **Load test** with 2000 students
3. **Deploy to production**
4. **Set up monitoring**
5. **Plan enhancements**:
   - Push notifications
   - Analytics dashboard
   - Parent portal
   - Advanced reporting

---

## 📞 Need Help?

1. **Backend issues**: See `backend/BACKEND_SETUP.md`
2. **API issues**: See `backend/API_DOCUMENTATION.md`
3. **Flutter issues**: See `SETUP_GUIDE.md`
4. **Integration issues**: See this file

---

**Your Student Logbook System is now live!** 🚀

For questions or issues, refer to the detailed documentation files included in the project.
