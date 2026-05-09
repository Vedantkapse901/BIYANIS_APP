import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subject_model.dart';
import '../models/chapter_model.dart';
import '../models/topic_model.dart';
import '../models/task_model.dart';

class LocalDataSource {
  static final LocalDataSource _instance = LocalDataSource._internal();
  factory LocalDataSource() => _instance;
  LocalDataSource._internal();

  static const String _subjectsBoxName = 'subjects';
  static const String _topicsBoxName = 'topics';
  static const String _userBoxName = 'user';
  static const String _studentsBoxName = 'students'; // Pre-registered students from school
  static const String _profilesBoxName = 'profiles'; // Student login profiles
  static const String _usersBoxName = 'all_users'; // Teachers and other users

  Box<SubjectModel>? _subjectsBox;
  Box<TopicModel>? _topicsBox;
  Box? _userBox;
  Box<Map>? _studentsBox;
  Box<Map>? _profilesBox;
  Box<Map>? _allUsersBox;

  bool _isInitialized = false;

  // Initialize Hive and open boxes
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('LocalDataSource: Initializing Hive...');
      await Hive.initFlutter();

      // Register adapters safely
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(SubjectModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(TopicModelAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(ChapterModelAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(TaskModelAdapter());
      }

      debugPrint('LocalDataSource: Opening boxes...');
      try {
        _subjectsBox = await Hive.openBox<SubjectModel>(_subjectsBoxName);
        _topicsBox = await Hive.openBox<TopicModel>(_topicsBoxName);
        _userBox = await Hive.openBox(_userBoxName);
        _studentsBox = await Hive.openBox<Map>(_studentsBoxName);
        _profilesBox = await Hive.openBox<Map>(_profilesBoxName);
        _allUsersBox = await Hive.openBox<Map>(_usersBoxName);
      } catch (e) {
        debugPrint('LocalDataSource: Error opening boxes, likely data incompatibility. Clearing and retrying... $e');
        await Hive.deleteBoxFromDisk(_subjectsBoxName);
        await Hive.deleteBoxFromDisk(_topicsBoxName);
        await Hive.deleteBoxFromDisk(_userBoxName);
        await Hive.deleteBoxFromDisk(_studentsBoxName);
        await Hive.deleteBoxFromDisk(_profilesBoxName);
        await Hive.deleteBoxFromDisk(_usersBoxName);

        _subjectsBox = await Hive.openBox<SubjectModel>(_subjectsBoxName);
        _topicsBox = await Hive.openBox<TopicModel>(_topicsBoxName);
        _userBox = await Hive.openBox(_userBoxName);
        _studentsBox = await Hive.openBox<Map>(_studentsBoxName);
        _profilesBox = await Hive.openBox<Map>(_profilesBoxName);
        _allUsersBox = await Hive.openBox<Map>(_usersBoxName);
      }

      // Check for data integrity (migration check)
      try {
        if (_subjectsBox!.isNotEmpty) {
          // Accessing values will trigger the adapter to read data
          _subjectsBox!.values.take(1).toList();
        }
      } catch (e) {
        debugPrint('LocalDataSource: Data migration/incompatibility detected. Clearing boxes. Error: $e');
        await _subjectsBox!.clear();
        await _topicsBox!.clear();
      }

      _isInitialized = true;
      debugPrint('LocalDataSource: Initialization complete.');
    } catch (e) {
      debugPrint('LocalDataSource: Initialization failed: $e');
      rethrow;
    }
  }

  // ===== USER OPERATIONS =====
  Future<void> saveUser(Map user) async {
    _ensureInitialized();
    await _allUsersBox!.add(user);
  }

  Future<List<Map>> getAllUsers() async {
    _ensureInitialized();
    return _allUsersBox!.values.toList();
  }

  // ===== STUDENTS OPERATIONS (Pre-registered students from school) =====
  Future<void> addStudent(Map student) async {
    _ensureInitialized();
    await _studentsBox!.put(student['phone'], student);
  }

  Future<Map?> getStudent(String phone) async {
    _ensureInitialized();
    return _studentsBox!.get(phone);
  }

  Future<void> markStudentAsRegistered(String phone) async {
    _ensureInitialized();
    final student = _studentsBox!.get(phone);
    if (student != null) {
      final updatedStudent = Map<String, dynamic>.from(student);
      updatedStudent['is_registered'] = true;
      await _studentsBox!.put(phone, updatedStudent);
    }
  }

  Future<void> bulkAddStudents(List<Map> students) async {
    _ensureInitialized();
    final Map<String, Map> studentMap = {
      for (var s in students) s['phone'].toString(): s
    };
    await _studentsBox!.putAll(studentMap);
  }

  Future<void> clearStudents() async {
    _ensureInitialized();
    await _studentsBox!.clear();
  }

  // ===== PROFILES OPERATIONS (Student login profiles) =====
  Future<void> saveProfile(Map profile) async {
    _ensureInitialized();
    // Save with studentId as key for quick lookup during login
    await _profilesBox!.put(profile['studentId'], profile);
  }

  Future<Map?> getProfile(String studentId) async {
    _ensureInitialized();
    return _profilesBox!.get(studentId);
  }

  Future<List<Map>> getAllProfiles() async {
    _ensureInitialized();
    return _profilesBox!.values.toList();
  }

  // Helper to ensure initialized
  void _ensureInitialized() {
    if (!_isInitialized || _subjectsBox == null || _topicsBox == null || _userBox == null) {
      throw Exception('LocalDataSource not initialized. Call initialize() first.');
    }
  }

  // ===== SUBJECT OPERATIONS =====

  Future<List<SubjectModel>> getAllSubjects({String? batch}) async {
    _ensureInitialized();
    final allSubjects = _subjectsBox!.values.toList();
    
    // If batch is explicitly provided, use it
    if (batch != null) {
      return allSubjects.where((s) => s.batch == null || s.batch == batch).toList();
    }
    
    // Otherwise filter subjects by user's batch from prefs if logged in
    final prefs = await SharedPreferences.getInstance();
    final userBatch = prefs.getString('batch');
    
    if (userBatch != null) {
      return allSubjects.where((s) => s.batch == null || s.batch == userBatch).toList();
    }
    
    return allSubjects;
  }

  Future<SubjectModel?> getSubjectById(String id) async {
    _ensureInitialized();
    return _subjectsBox!.get(id);
  }

  Future<void> createSubject(SubjectModel subject) async {
    _ensureInitialized();
    await _subjectsBox!.put(subject.id, subject);
  }

  Future<void> updateSubject(SubjectModel subject) async {
    _ensureInitialized();
    await _subjectsBox!.put(subject.id, subject);
  }

  Future<void> deleteSubject(String id) async {
    _ensureInitialized();
    await _subjectsBox!.delete(id);
  }

  // ===== TOPIC OPERATIONS =====

  Future<List<TopicModel>> getTopicsBySubjectId(String subjectId) async {
    _ensureInitialized();
    final topics = _topicsBox!.values
        .where((topic) => topic.subjectId == subjectId)
        .toList();
    topics.sort((a, b) => (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0));
    return topics;
  }

  Future<TopicModel?> getTopicById(String id) async {
    _ensureInitialized();
    return _topicsBox!.get(id);
  }

  Future<void> createTopic(TopicModel topic) async {
    _ensureInitialized();
    await _topicsBox!.put(topic.id, topic);
    // Update subject completion count
    await _updateSubjectCompletion(topic.subjectId);
  }

  Future<void> updateTopic(TopicModel topic) async {
    _ensureInitialized();
    await _topicsBox!.put(topic.id, topic);
    // Update subject completion count
    await _updateSubjectCompletion(topic.subjectId);
  }

  Future<void> deleteTopic(String topicId) async {
    _ensureInitialized();
    final topic = _topicsBox!.get(topicId);
    if (topic != null) {
      await _topicsBox!.delete(topicId);
      await _updateSubjectCompletion(topic.subjectId);
    }
  }

  Future<void> toggleTopicCompletion(String topicId) async {
    _ensureInitialized();
    final topic = _topicsBox!.get(topicId);
    if (topic != null) {
      final updatedTopic = topic
        ..isCompleted = !(topic.isCompleted ?? false)
        ..completedAt = (topic.isCompleted ?? false) ? null : DateTime.now()
        ..updatedAt = DateTime.now();

      await _topicsBox!.put(topicId, updatedTopic);
      await _updateSubjectCompletion(topic.subjectId);
    }
  }

  Future<void> toggleTaskCompletion(String subjectId, String chapterId, String topicId, String taskId) async {
    _ensureInitialized();
    final subject = _subjectsBox!.get(subjectId);
    if (subject != null) {
      // Find chapter
      final chapters = subject.chapters;
      final cIndex = chapters.indexWhere((c) => c.id == chapterId);
      if (cIndex != -1) {
        // Find topic
        final topics = chapters[cIndex].topics;
        final tIndex = topics.indexWhere((t) => t.id == topicId);
        if (tIndex != -1) {
          // Find task
          final tasks = topics[tIndex].tasks;
          final kIndex = tasks.indexWhere((k) => k.id == taskId);
          if (kIndex != -1) {
            final task = tasks[kIndex];
            task.isCompleted = !task.isCompleted;
            
            // Re-save subject
            await _subjectsBox!.put(subjectId, subject);
          }
        }
      }
    }
  }

  // ===== HELPER METHODS =====

  Future<void> _updateSubjectCompletion(String subjectId) async {
    final subject = _subjectsBox!.get(subjectId);
    if (subject != null) {
      final topics = await getTopicsBySubjectId(subjectId);
      final completedCount = topics.where((t) => t.isCompleted ?? false).length;

      final updatedSubject = subject
        ..totalTopics = topics.length
        ..completedTopics = completedCount
        ..updatedAt = DateTime.now();

      await _subjectsBox!.put(subjectId, updatedSubject);
    }
  }

  // ===== USER PREFERENCES =====

  Future<void> saveUserRole(String role) async {
    _ensureInitialized();
    await _userBox!.put('role', role);
  }

  Future<String?> getUserRole() async {
    _ensureInitialized();
    return _userBox!.get('role');
  }

  Future<void> saveUserId(String userId) async {
    _ensureInitialized();
    await _userBox!.put('userId', userId);
  }

  Future<String?> getUserId() async {
    _ensureInitialized();
    return _userBox!.get('userId');
  }

  Future<void> clearAllData() async {
    _ensureInitialized();
    await _subjectsBox!.clear();
    await _topicsBox!.clear();
    await _userBox!.clear();
  }

  // ===== MOCK DATA SEEDING =====

  Future<void> seedMockData() async {
    _ensureInitialized();
    if (_subjectsBox!.isEmpty) {
      debugPrint('LocalDataSource: Seeding school-specific data...');
      const uuid = Uuid();
      final now = DateTime.now();

      final schoolsData = [
        {
          'batch': 'ICSE 9',
          'subjects': [
            {'name': 'Maths (ICSE)', 'color': '#5B5FDE', 'icon': '🧮'},
            {'name': 'Physics (ICSE)', 'color': '#FF9500', 'icon': '🔬'},
          ]
        },
        {
          'batch': 'CBSE 9',
          'subjects': [
            {'name': 'Maths (CBSE)', 'color': '#00D4AA', 'icon': '📚'},
            {'name': 'Science (CBSE)', 'color': '#FF2D55', 'icon': '🧪'},
          ]
        }
      ];

      for (var school in schoolsData) {
        final batch = school['batch'] as String;
        final subjects = school['subjects'] as List<Map<String, String>>;

        for (var sData in subjects) {
          final subjectId = uuid.v4();
          List<ChapterModel> chapters = [];

          // Create 2 Chapters for each
          for (int c = 1; c <= 2; c++) {
            final chapterId = uuid.v4();
            List<TaskModel> chapterTasks = [];

            // Create tasks directly for the chapter (no topics level)
            for (int t = 1; t <= 6; t++) {
              chapterTasks.add(TaskModel(
                id: uuid.v4(),
                chapterId: chapterId,
                title: '${sData['name']} - Ch $c Task $t',
                isCompleted: false,
                orderIndex: t,
              ));
            }

            chapters.add(ChapterModel(
              id: chapterId,
              subjectId: subjectId,
              title: 'Chapter $c for $batch',
              topics: [], // Keep for backward compatibility
              orderIndex: c,
              tasks: chapterTasks, // New structure: tasks directly in chapter
            ));
          }

          int totalTasksCount = chapters.fold(0, (sum, c) => sum + c.tasks.length);

          final subject = SubjectModel(
            id: subjectId,
            name: sData['name']!,
            color: sData['color']!,
            icon: sData['icon']!,
            batch: batch,
            totalTopics: totalTasksCount,
            completedTopics: 0,
            createdAt: now,
            updatedAt: now,
            chapters: chapters,
          );

          await _subjectsBox!.put(subject.id, subject);
        }
      }
      debugPrint('LocalDataSource: School-specific mock data seeded.');
    }

    // Seed students (pre-registered from school) if empty
    if (_studentsBox!.isEmpty) {
      debugPrint('LocalDataSource: Seeding students database...');
      await bulkAddStudents([
        {
          'id': '001',
          'name': 'John Doe',
          'phone': '1234567890',
          'email': 'john@example.com',
          'school_name': 'ABC School',
          'board': 'CBSE',
          'class_branch': '9A',
          'serial_id': 'STU001',
          'is_registered': false,
        },
        {
          'id': '002',
          'name': 'Jane Smith',
          'phone': '9876543210',
          'email': 'jane@example.com',
          'school_name': 'XYZ Institute',
          'board': 'ICSE',
          'class_branch': '10B',
          'serial_id': 'STU002',
          'is_registered': false,
        },
      ]);
    }
  }
}
