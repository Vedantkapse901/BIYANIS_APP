import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../../core/theme/app_theme.dart';
import '../../../logbook/data/models/subject_model.dart';
import '../../../logbook/data/models/task_model.dart';
import '../../../logbook/data/models/chapter_model.dart';
import '../../../logbook/data/datasources/remote_datasource.dart';
import 'task_detail_screen.dart';

class StudentDashboardScreen extends ConsumerStatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  ConsumerState<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends ConsumerState<StudentDashboardScreen> {
  int _selectedSubjectIndex = 0;
  final Map<String, bool> _expandedChapters = {}; // Track which chapters are expanded
  final Map<String, Set<String>> _completedTasks = {}; // Track completed tasks per chapter
  final Map<String, int> _chapterCompletedCount = {}; // Track completed tasks count per chapter
  final Map<String, String> _chapterOrderIndexMap = {}; // Store original order_index text (preserves "3 (A)")
  final ScrollController _scrollController = ScrollController();

  // Student details
  String? _studentId;
  String? _studentName;
  String? _studentBatch;
  String? _studentUUID;

  // Subjects from Supabase
  List<SubjectModel> _subjects = [];
  bool _isLoadingSubjects = true;

  @override
  void initState() {
    super.initState();
    _loadStudentDetails();
  }

  Future<void> _loadStudentDetails() async {
    print('🔄 Loading student details from SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    _studentId = prefs.getString('studentId');
    _studentName = prefs.getString('name');
    _studentUUID = prefs.getString('userId');

    print('✅ Student ID: $_studentId');
    print('✅ Student Name: $_studentName');
    print('✅ Student UUID: $_studentUUID');

    // For parents, studentId might be stored as childId
    if (_studentId == null) {
      _studentId = prefs.getString('childId');
      if (_studentId != null) {
        print('👨‍👩‍👧 Parent detected, using childId: $_studentId');
      }
    }

    setState(() {});

    // Load student details from database to get board + standard
    if (_studentUUID != null) {
      print('🔄 Fetching batch from database...');
      await _loadBatchFromDatabase();
    } else {
      print('❌ No UUID in SharedPreferences');
    }
  }

  Future<void> _loadBatchFromDatabase() async {
    final studentId = _studentId;
    if (studentId == null) {
      print('❌ No student ID found');
      if (mounted) {
        setState(() {
          _isLoadingSubjects = false;
        });
      }
      return;
    }

    try {
      print('🔍 Loading batch for student ID: $studentId');
      final supabase = Supabase.instance.client;

      // Get student record with board and standard using serial_id
      final response = await supabase
          .from('students')
          .select('id, board, standard, profile_id')
          .ilike('serial_id', studentId) // Case-insensitive, reverted to serial_id
          .maybeSingle();

      print('📊 Batch response: $response');

      if (response != null) {
        final board = response['board'] ?? '';
        final standard = response['standard'] ?? '';
        // Store the actual student database ID for progress queries
        final dbId = response['id'];

        // Normalize batch: "icse 10th" -> "ICSE 10" or try both formats
        String normalizedStandard = standard.replaceAll(RegExp(r'(st|nd|rd|th)$'), '');
        String normalizedBatch = '${board.toUpperCase()} $normalizedStandard';

        print('✅ Found batch: $board $standard');
        print('✅ Normalized batch: $normalizedBatch, DB ID: $dbId');

        if (mounted) {
          setState(() {
            _studentBatch = normalizedBatch; // e.g., "ICSE 10"
          });
        }

        // Load subjects from Supabase
        print('🔄 Loading subjects for batch: $normalizedBatch');
        await _loadSubjectsFromDatabase();

        // Now load progress
        print('🔄 Loading progress...');
        await _loadProgressFromDatabase();
      } else {
        print('❌ No student record found for student_id: $studentId');
        if (mounted) {
          setState(() {
            _isLoadingSubjects = false;
          });
        }
      }
    } catch (e) {
      print('❌ Error loading batch: $e');
      if (mounted) {
        setState(() {
          _isLoadingSubjects = false;
        });
      }
    }
  }

  Future<void> _loadSubjectsFromDatabase() async {
    try {
      // Check if batch is loaded
      if (_studentBatch == null) {
        print('❌ Student batch not loaded yet');
        return;
      }

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🎓 STUDENT: $_studentName (ID: $_studentId)');
      print('📚 BATCH: $_studentBatch');
      print('🔄 Loading subjects with embedded tasks...');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final supabase = Supabase.instance.client;
      final batch = _studentBatch!; // Now guaranteed non-null

      // Fetch all subjects for this batch
      final subjectsResponse = await supabase
          .from('subjects')
          .select('id, name, color, icon')
          .eq('batch', batch);

      List<SubjectModel> subjects = [];

      for (var subject in subjectsResponse as List) {
        final subjectId = subject['id'];
        final subjectName = subject['name'];
        final subjectColor = subject['color'] ?? '#5B5FDE';
        final subjectIcon = subject['icon'] ?? '📚';

        // Fetch chapters with embedded tasks for this subject
        final chaptersResponse = await supabase
            .from('chapters')
            .select('*')
            .eq('subject_id', subjectId)
            .order('order_index', ascending: true);

        // Create chapter models from the response with embedded tasks using model's fromJson
        final chapters = (chaptersResponse as List).map((chapterJson) {
          return ChapterModel.fromJson(chapterJson);
        }).toList();

        // Sort chapters numerically by orderIndex
        chapters.sort((a, b) => (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0));

        if (chapters.isNotEmpty) {
          subjects.add(
            SubjectModel(
              id: subjectId,
              name: subjectName,
              color: subjectColor,
              icon: subjectIcon,
              chapters: chapters,
              batch: batch,
            ),
          );
        }
      }

      // Pedagogical sorting for subjects
      final subjectOrder = [
        'PHYSICS', 'CHEMISTRY', 'MATHEMATICS', 'MATHS', 'BIOLOGY',
        'ENGLISH LITERATURE', 'LITERATURE', 'ENGLISH LANGUAGE', 'LANGUAGE',
        'HINDI', 'COMPUTER APPLICATIONS', 'CA', 'CS', 'CIVICS', 'HISTORY',
        'GEOGRAPHY', 'ECONOMICS', 'ECONOMIC'
      ];

      subjects.sort((a, b) {
        final indexA = subjectOrder.indexWhere((s) => a.name.toUpperCase().contains(s));
        final indexB = subjectOrder.indexWhere((s) => b.name.toUpperCase().contains(s));

        if (indexA == -1) return 1;
        if (indexB == -1) return -1;
        return indexA.compareTo(indexB);
      });

      print('✅ Loaded ${subjects.length} subjects (sorted)');
      for (var i = 0; i < subjects.length; i++) {
        print('   ${i + 1}. ${subjects[i].name} (${subjects[i].chapters?.length ?? 0} chapters)');
      }

      setState(() {
        _subjects = subjects;
        _isLoadingSubjects = false;
      });

      // Then load progress asynchronously
      unawaited(_loadProgressFromDatabase());
    } catch (e) {
      print('❌ Error loading subjects: $e');
      setState(() => _isLoadingSubjects = false);
    }
  }

  Future<void> _loadProgressFromDatabase() async {
    final studentId = _studentId;
    if (studentId == null) return;

    try {
      final supabase = Supabase.instance.client;

      print('🔄 Loading progress for student ID: $studentId');

      // Get student database ID from students table
      final studentResponse = await supabase
          .from('students')
          .select('id')
          .ilike('serial_id', studentId)
          .maybeSingle();

      print('📊 Student record: $studentResponse');

      if (studentResponse != null) {
        final studentDbId = studentResponse['id'];
        print('✅ Found student DB ID: $studentDbId');

        try {
          // Load all progress for this student (chapter_id and task_id based)
          final progressList = await supabase
              .from('student_progress')
              .select('chapter_id, task_id, is_completed')
              .eq('student_id', studentDbId)
              .eq('is_completed', true);

          print('📊 Loaded ${progressList.length} completed tasks');

          if (progressList.isEmpty) {
            print('⚠️ No progress records found for student: $studentDbId');
          }

          setState(() {
            _completedTasks.clear();
            _chapterCompletedCount.clear();

            for (var item in progressList) {
              final chapterId = item['chapter_id'] as String?;
              final taskId = item['task_id'] as String?;

              print('   📌 Raw item: $item');

              if (chapterId != null && taskId != null) {
                print('   ✓ Loading: Chapter=$chapterId, Task=$taskId');

                if (!_completedTasks.containsKey(chapterId)) {
                  _completedTasks[chapterId] = {};
                }
                _completedTasks[chapterId]!.add(taskId);

                _chapterCompletedCount[chapterId] =
                    (_chapterCompletedCount[chapterId] ?? 0) + 1;
              } else {
                print('   ❌ Null values: chapter=$chapterId, task=$taskId');
              }
            }

            print('✅ Progress loaded: ${_chapterCompletedCount.length} chapters with progress');
          });
        } catch (e) {
          print('❌ Error loading progress: $e');
        }
      } else {
        print('❌ No student record found for student_id: $studentId');
      }
    } catch (e) {
      print('❌ Error loading progress: $e');
    }
  }

  void _toggleTaskLocal(String chapterId, String taskId) {
    setState(() {
      if (!_completedTasks.containsKey(chapterId)) {
        _completedTasks[chapterId] = {};
      }

      if (_completedTasks[chapterId]!.contains(taskId)) {
        _completedTasks[chapterId]!.remove(taskId);
      } else {
        _completedTasks[chapterId]!.add(taskId);
      }

      // Note: We intentionally DO NOT update _chapterCompletedCount here
      // This ensures progress bars only update when "Submit" is clicked
    });
  }

  Future<void> _submitChapterProgress(String chapterId, List<TaskModel> chapterTasks) async {
    final studentId = _studentId;
    if (studentId == null) return;

    try {
      final supabase = Supabase.instance.client;
      final studentResponse = await supabase
          .from('students')
          .select('id, profile_id')
          .ilike('serial_id', studentId)
          .maybeSingle();

      if (studentResponse != null) {
        // Use profile_id if available, otherwise fallback to students table ID
        // Note: student_progress table usually references profiles.id (UUID)
        final studentProgressId = studentResponse['profile_id'] ?? studentResponse['id'];

        print('📝 Submitting progress for student: $studentProgressId, chapter: $chapterId');

        // Prepare batch upsert for ALL tasks in this chapter
        final List<Map<String, dynamic>> updates = chapterTasks.map((task) {
          final isCompleted = (_completedTasks[chapterId] ?? {}).contains(task.id);
          return {
            'student_id': studentProgressId,
            'chapter_id': chapterId,
            'task_id': task.id,
            'is_completed': isCompleted,
            'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
          };
        }).toList();

        await supabase.from('student_progress').upsert(
          updates,
          onConflict: 'student_id,task_id',
        );

        setState(() {
          _chapterCompletedCount[chapterId] = (_completedTasks[chapterId] ?? {}).length;
        });

        // Scroll to top to show updated overall progress
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_chapterCompletedCount[chapterId]}/${chapterTasks.length} tasks submitted! ✓'),
            duration: const Duration(seconds: 2),
            backgroundColor: _parseSubjectColor(_subjects[_selectedSubjectIndex].color),
          ),
        );
      }
    } catch (e) {
      print('❌ Error submitting progress: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to save: ${e.toString().contains('403') ? 'Permission denied (RLS)' : e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _getTotalBacklog() {
    int total = 0;
    for (var subject in _subjects) {
      final chapters = subject.chapters ?? [];
      for (var chapter in chapters) {
        final chapterId = chapter.id;
        final tasks = chapter.tasks ?? [];
        final completed = _chapterCompletedCount[chapterId] ?? 0;
        total += (tasks.length - completed);
      }
    }
    return total;
  }

  Color _parseSubjectColor(String colorValue) {
    if (colorValue.isEmpty) {
      return AppTheme.primary;
    }

    try {
      // Handle named colors
      final colorName = colorValue.toLowerCase().trim();

      switch (colorName) {
        case 'blue':
          return Colors.blue;
        case 'red':
          return Colors.red;
        case 'green':
          return Colors.green;
        case 'purple':
          return Colors.purple;
        case 'orange':
          return Colors.orange;
        case 'pink':
          return Colors.pink;
        case 'cyan':
          return Colors.cyan;
        case 'amber':
          return Colors.amber;
        case 'teal':
          return Colors.teal;
        case 'indigo':
          return Colors.indigo;
        case 'lime':
          return Colors.lime;
        case 'yellow':
          return Colors.yellow;
        case 'brown':
          return Colors.brown;
        case 'grey':
        case 'gray':
          return Colors.grey;
        default:
          // Try to parse as hex code
          if (colorValue.isNotEmpty && (colorValue.contains('#') || colorValue.replaceAll('#', '').length == 6)) {
            try {
              final hex = colorValue.replaceAll('#', '').replaceAll('0x', '').replaceAll('0X', '');
              if (hex.length == 6 && int.tryParse(hex, radix: 16) != null) {
                return Color(int.parse('0xFF$hex', radix: 16));
              }
            } catch (e) {
              // Silently ignore parsing errors
            }
          }
          return AppTheme.primary;
      }
    } catch (e) {
      print('⚠️ Failed to parse color "$colorValue": $e');
      return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading if subjects are still being fetched
    if (_isLoadingSubjects || _subjects.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('LOG BOOK'),
          backgroundColor: AppTheme.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Force Logout',
              onPressed: () async {
                final supabase = Supabase.instance.client;
                await supabase.auth.signOut();
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/role-selection');
                }
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_subjects.isEmpty && !_isLoadingSubjects)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'No subjects available for your batch.\nPlease check your profile or logout and try again.',
                    textAlign: TextAlign.center,
                  ),
                )
              else
                const CircularProgressIndicator(),
              const SizedBox(height: 20),
              if (_isLoadingSubjects)
                TextButton(
                  onPressed: () async {
                    final supabase = Supabase.instance.client;
                    await supabase.auth.signOut();
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/role-selection');
                    }
                  },
                  child: const Text('Cancel & Logout'),
                ),
            ],
          ),
        ),
      );
    }

    final selectedSubject = _subjects[_selectedSubjectIndex];
    final chapters = selectedSubject.chapters ?? [];

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('LOG BOOK'),
        elevation: 0,
        backgroundColor: AppTheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final supabase = Supabase.instance.client;
              await supabase.auth.signOut();
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/role-selection');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Details Card
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '👤 Student Profile',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _studentName ?? 'Loading...',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.badge,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ID: ${_studentId ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.book,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _studentBatch ?? 'N/A',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Subject Tabs
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemCount: _subjects.length,
                itemBuilder: (context, index) {
                  final subject = _subjects[index];
                  final isSelected = _selectedSubjectIndex == index;
                  final color = _parseSubjectColor(subject.color);
                  print('🎨 Subject ${subject.name} color: "${subject.color}" → $color');

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSubjectIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: color,
                            width: isSelected ? 0 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            subject.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Subject Info with Overall Progress
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ICSE Grade 10 • 2025-26',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subject name with overall progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${selectedSubject.name} Progress',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Calculate overall subject progress
                      Builder(
                        builder: (context) {
                          int totalTasks = 0;
                          int completedTasks = 0;
                          for (var chapter in chapters) {
                            final tasks = chapter.tasks ?? [];
                            totalTasks += tasks.length;
                            completedTasks += _chapterCompletedCount[chapter.id] ?? 0;
                          }
                          final percentage = totalTasks > 0 ? (completedTasks * 100 / totalTasks).round() : 0;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$completedTasks/$totalTasks tasks',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _parseSubjectColor(selectedSubject.color),
                                ),
                              ),
                              Text(
                                '$percentage%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _parseSubjectColor(selectedSubject.color),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Overall progress bar for subject
                  Builder(
                    builder: (context) {
                      int totalTasks = 0;
                      int completedTasks = 0;
                      for (var chapter in chapters) {
                        final tasks = chapter.tasks ?? [];
                        totalTasks += tasks.length;
                        completedTasks += _chapterCompletedCount[chapter.id] ?? 0;
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: totalTasks > 0 ? completedTasks / totalTasks : 0,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _parseSubjectColor(selectedSubject.color),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Chapters List
                  ...chapters.map((chapter) {
                    final chapterId = chapter.id;
                    final isExpanded = _expandedChapters[chapterId] ?? false;
                    final tasks = chapter.tasks ?? [];
                    final totalTasks = tasks.length;
                    final subjectColor = _parseSubjectColor(selectedSubject.color);

                    // Get the original order_index text (preserves "3 (A)", "3 (B)")
                    final orderIndexDisplay = _chapterOrderIndexMap[chapterId] ?? chapter.orderIndex?.toString() ?? '0';

                    // DEBUG: Log display value
                    if (orderIndexDisplay.contains('(')) {
                      print('🎯 DISPLAY: ${chapter.title} → "$orderIndexDisplay"');
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: subjectColor.withOpacity(0.2),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Chapter Header
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _expandedChapters[chapterId] = !isExpanded;
                                  });
                                },
                                child: Row(
                                  children: [
                                    // Order Index in a badge (preserves "3 (A)", "3 (B)" format)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: subjectColor.withOpacity(0.2),
                                        border: Border.all(
                                          color: subjectColor,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: Text(
                                          orderIndexDisplay,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: subjectColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        chapter.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${_chapterCompletedCount[chapterId] ?? 0}/$totalTasks',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: subjectColor,
                                          ),
                                        ),
                                        Text(
                                          '${totalTasks > 0 ? ((_chapterCompletedCount[chapterId] ?? 0) * 100 / totalTasks) .round() : 0}%',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: subjectColor.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      isExpanded ? Icons.expand_less : Icons.expand_more,
                                      color: subjectColor,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: totalTasks > 0 ? (_chapterCompletedCount[chapterId] ?? 0) / totalTasks : 0,
                                  minHeight: 6,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    subjectColor,
                                  ),
                                ),
                              ),

                              // Expanded Tasks Section
                              if (isExpanded) ...[
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 12),
                                const Text(
                                  'Tasks',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...tasks.map((task) {
                                  final taskId = task.id;
                                  final isCompleted = (_completedTasks[chapterId] ?? {}).contains(taskId);

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      onTap: () {
                                        // Toggle task locally
                                        _toggleTaskLocal(chapterId, taskId);
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isCompleted ? subjectColor : Colors.grey.shade400,
                                                width: 2,
                                              ),
                                              color: isCompleted ? subjectColor : Colors.transparent,
                                            ),
                                            child: isCompleted
                                                ? const Icon(
                                                    Icons.check,
                                                    size: 14,
                                                    color: Colors.white,
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              task.title,
                                              style: TextStyle(
                                                fontSize: 13,
                                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                                color: isCompleted ? Colors.grey : Colors.black,
                                                fontWeight: isCompleted ? FontWeight.w400 : FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _submitChapterProgress(chapterId, tasks),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: subjectColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Submit',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            // About Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'About LOG BOOK',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Track minimum tasks required to master each chapter. Mark tasks as complete to monitor your progress, analyze backlog, and plan your study schedule effectively.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

}
