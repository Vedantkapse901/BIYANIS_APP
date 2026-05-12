import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../../core/theme/app_theme.dart';
import '../../../logbook/data/models/subject_model.dart';
import '../../../logbook/data/datasources/remote_datasource.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  Future<List<Map<String, dynamic>>>? _studentsFuture;
  String? _batch;
  String? _teacherName;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allStudents = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  int _currentPage = 0;
  final int _studentsPerPage = 10;
  bool _isParentMode = false;
  Map<String, dynamic>? _parentStudentData;
  bool _isLoadingParent = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole');

    if (role == 'parent') {
      setState(() {
        _isParentMode = true;
      });
      await _loadParentData();
    } else {
      await _loadTeacherInfo();
    }
  }

  Future<void> _loadParentData() async {
    final prefs = await SharedPreferences.getInstance();
    final childId = prefs.getString('childId');
    final name = prefs.getString('name');

    if (childId != null) {
      final supabase = Supabase.instance.client;
      final student = await supabase
          .from('students')
          .select()
          .ilike('serial_id', childId)
          .maybeSingle();

      if (student != null) {
        setState(() {
          _teacherName = name;
          _parentStudentData = student;
          _isLoadingParent = false;
        });
      } else {
        setState(() => _isLoadingParent = false);
      }
    } else {
      setState(() => _isLoadingParent = false);
    }
  }

  Future<void> _loadTeacherInfo() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final supabase = Supabase.instance.client;
      final userId = prefs.getString('userId');
      if (userId != null) {
        // Try fetching from teachers table first (new system)
        var teacherData = await supabase
            .from('teachers')
            .select('batch, name, subject')
            .eq('id', userId)
            .maybeSingle();

        // Fallback to profiles if not found (old system)
        if (teacherData == null) {
          teacherData = await supabase
              .from('profiles')
              .select('batch, branch, name')
              .eq('id', userId)
              .maybeSingle();
        }

        if (teacherData != null) {
          await prefs.setString('batch', teacherData['batch'] ?? '');
          await prefs.setString('name', teacherData['name'] ?? '');
          if (teacherData['subject'] != null) {
            await prefs.setString('teacherSubject', teacherData['subject']);
          }
        }
      }
    } catch (e) {
      print('Error refreshing teacher info: $e');
    }

    final batch = prefs.getString('batch');
    final name = prefs.getString('name');

    setState(() {
      _batch = batch;
      _teacherName = name;
      _studentsFuture = _fetchStudentsByBatch(batch);
    });
  }

  Future<List<Map<String, dynamic>>> _fetchStudentsByBatch(String? batch) async {
    if (batch == null || batch.isEmpty) {
      return [];
    }

    try {
      final parts = batch.split(RegExp(r'[\s\-_]+'));
      final board = parts[0].trim();
      final standard = parts.length > 1 ? parts[1].trim() : '';
      final standardNum = standard.replaceAll(RegExp(r'(st|nd|rd|th)$', caseSensitive: false), '');

      final prefs = await SharedPreferences.getInstance();
      final teacherBranch = prefs.getString('branch');

      final supabase = Supabase.instance.client;
      var query = supabase.from('students').select();

      query = query.ilike('board', board);

      if (standardNum.isNotEmpty) {
        query = query.or('standard.ilike.$standardNum,standard.ilike.${standardNum}th,standard.ilike.${standardNum}st,standard.ilike.${standardNum}nd,standard.ilike.${standardNum}rd');
      }

      if (teacherBranch != null && teacherBranch.isNotEmpty) {
        query = query.ilike('class_branch', '%$teacherBranch%');
      }

      final response = await query.order('serial_id', ascending: true);
      final students = List<Map<String, dynamic>>.from(response);

      print('📡 Fetched ${students.length} raw students for $board $standardNum');

      final filteredList = students.where((s) {
        final sBoard = (s['board'] ?? '').toString().toLowerCase().trim();
        final sStandard = (s['standard'] ?? '').toString().toLowerCase().trim();
        final sStandardNum = sStandard.replaceAll(RegExp(r'(st|nd|rd|th)$', caseSensitive: false), '');
        final sBranch = (s['class_branch'] ?? '').toString().toLowerCase();

        bool matchesBoard = sBoard == board.toLowerCase();
        bool matchesStandard = sStandardNum == standardNum;

        bool matchesBranch = true;
        if (teacherBranch != null && teacherBranch.isNotEmpty) {
           matchesBranch = sBranch.contains(teacherBranch.toLowerCase());
        }

        return matchesBoard && matchesStandard && matchesBranch;
      }).toList();

      print('🎯 Filtered to ${filteredList.length} students matching batch parameters');

      setState(() {
        _allStudents = filteredList;
        _filteredStudents = filteredList;
      });
      return filteredList;
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _currentPage = 0;
      if (query.isEmpty) {
        _filteredStudents = _allStudents;
      } else {
        _filteredStudents = _allStudents.where((student) {
          final name = (student['name'] ?? '').toString().toLowerCase();
          final serialId = (student['serial_id'] ?? '').toString().toLowerCase();
          return name.contains(query) || serialId.contains(query);
        }).toList();
      }
    });
  }

  int get _totalPages {
    return (_filteredStudents.length / _studentsPerPage).ceil();
  }

  List<Map<String, dynamic>> get _paginatedStudents {
    final start = _currentPage * _studentsPerPage;
    final end = start + _studentsPerPage;
    return _filteredStudents.sublist(
      start,
      end > _filteredStudents.length ? _filteredStudents.length : end,
    );
  }

  Future<void> _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/role-selection');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isParentMode) {
      if (_isLoadingParent) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (_parentStudentData == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Parent Dashboard'), backgroundColor: Colors.orange),
          body: const Center(child: Text('No student data found for this parent ID.')),
        );
      }
      return StudentFullScreenView(
        student: _parentStudentData!,
        isParentView: true,
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        elevation: 0,
        backgroundColor: AppTheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${_teacherName ?? 'Teacher'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Batch: $_batch',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Total Students: ${_allStudents.length}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name or student ID',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterStudents();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Students (${_filteredStudents.length} found)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (_studentsFuture == null)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
              else
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _studentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
                    }
                  if (snapshot.hasError) {
                    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red))));
                  }
                  if (_filteredStudents.isEmpty) {
                    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(children: [const Icon(Icons.group_off, size: 48, color: Colors.grey), const SizedBox(height: 16), Text('No students found', style: TextStyle(fontSize: 14, color: Colors.grey.shade600))])));
                  }

                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _paginatedStudents.length,
                        itemBuilder: (context, index) {
                          final student = _paginatedStudents[index];
                          return _buildStudentCard(student);
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_totalPages > 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                            ),
                            Text('Page ${_currentPage + 1} of $_totalPages', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: _currentPage < _totalPages - 1 ? () => setState(() => _currentPage++) : null,
                            ),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentFullScreenView(student: student),
          ),
        );
      },
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        student['serial_id']?.toString() ?? 'S',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(student['name'] ?? 'Unknown', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${(student['serial_id']?.toString().isEmpty ?? true) ? 'N/A' : student['serial_id']}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (student['phone'] != null) ...[
                    Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(student['phone'] ?? 'N/A', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(width: 16),
                  ],
                  Icon(Icons.book, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    '${student['board'] ?? ''} ${student['standard'] ?? ''}'.trim().isEmpty ? 'N/A' : '${student['board']} ${student['standard']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentFullScreenView extends ConsumerStatefulWidget {
  final Map<String, dynamic> student;
  final bool isParentView;

  const StudentFullScreenView({
    super.key,
    required this.student,
    this.isParentView = false,
  });

  @override
  ConsumerState<StudentFullScreenView> createState() => _StudentFullScreenViewState();
}

class _StudentFullScreenViewState extends ConsumerState<StudentFullScreenView> {
  int _selectedSubjectIndex = 0;
  final Map<String, bool> _expandedChapters = {};
  final Map<String, Set<String>> _completedTasks = {};
  final Map<String, int> _chapterCompletedCount = {};
  List<SubjectModel> _subjects = [];
  String? _assignedSubject; // Store the teacher's restricted subject
  bool _isLoading = true;
  late Timer _refreshTimer;
  int _lastRefreshSeconds = 0;

  @override
  void initState() {
    super.initState();
    _checkTeacherAssignment();
    _loadSubjectsOnce();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() {
          _lastRefreshSeconds = (_lastRefreshSeconds + 5) % 60;
        });
        _loadProgressOnly();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  Future<void> _checkTeacherAssignment() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _assignedSubject = prefs.getString('teacherSubject');
      if (_assignedSubject != null && _assignedSubject!.isEmpty) {
        _assignedSubject = null;
      }
      print('👨‍🏫 Teacher restricted to subject: ${_assignedSubject ?? "ALL"}');
    });
  }

  Future<void> _loadSubjectsOnce() async {
    try {
      final remoteDataSource = RemoteDataSource();
      final board = widget.student['board'] ?? '';
      final standard = widget.student['standard'] ?? '';
      final normalizedStandard = standard.replaceAll(RegExp(r'(st|nd|rd|th)$'), '');
      final batch = '${board.toUpperCase()} $normalizedStandard';

      final subjects = await remoteDataSource.getAllSubjects(batch: batch);

      // Filter subjects if teacher is assigned to a specific one
      List<SubjectModel> filteredSubjects = subjects;
      if (_assignedSubject != null) {
        final assignedName = _assignedSubject!.toUpperCase().trim();
        filteredSubjects = subjects.where((s) {
          final subjectName = s.name.toUpperCase().trim();
          // Use exact match instead of contains to prevent showing "PHYSICS" or "CIVICS" when "CS" is assigned
          return subjectName == assignedName;
        }).toList();

        // Fallback: If exact match failed, try careful substring match for common aliases
        if (filteredSubjects.isEmpty) {
          filteredSubjects = subjects.where((s) {
            final subjectName = s.name.toUpperCase().trim();
            if (assignedName == 'MATHS' || assignedName == 'MATHEMATICS') {
              return subjectName == 'MATHS' || subjectName == 'MATHEMATICS';
            }
            if (assignedName == 'CS' || assignedName == 'COMPUTER APPLICATIONS') {
              return subjectName == 'CS' || subjectName == 'COMPUTER APPLICATIONS';
            }
            if (assignedName == 'CA') {
              return subjectName == 'CA' || subjectName == 'COMPUTER APPLICATIONS';
            }
            return subjectName.contains(assignedName) || assignedName.contains(subjectName);
          }).toList();
        }
        print('✂️ Filtered to ${filteredSubjects.length} subjects for teacher ($_assignedSubject)');
      }

      // Pedagogical sorting for both ICSE and CBSE
      final subjectOrder = [
        'PHYSICS', 'CHEMISTRY', 'MATHEMATICS', 'MATHS', 'BIOLOGY', 'SCIENCE',
        'ENGLISH LITERATURE', 'ENGLISH LANGUAGE', 'ENGLISH', 'HINDI',
        'COMPUTER APPLICATIONS', 'CA', 'CS', 'INFORMATION TECHNOLOGY', 'IT',
        'CIVICS', 'HISTORY', 'GEOGRAPHY', 'SOCIAL SCIENCE', 'SST',
        'ECONOMICS', 'ECONOMIC', 'COMMERCIAL STUDIES'
      ];

      subjects.sort((a, b) {
        final nameA = a.name.toUpperCase();
        final nameB = b.name.toUpperCase();

        final indexA = subjectOrder.indexWhere((s) => nameA.contains(s));
        final indexB = subjectOrder.indexWhere((s) => nameB.contains(s));

        if (indexA == -1 && indexB == -1) return nameA.compareTo(nameB);
        if (indexA == -1) return 1;
        if (indexB == -1) return -1;
        return indexA.compareTo(indexB);
      });

      for (var subject in filteredSubjects) {
        if (subject.chapters != null) {
          subject.chapters.sort((a, b) {
            int cmp = (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0);
            if (cmp != 0) return cmp;
            return a.title.compareTo(b.title);
          });
        }
      }

      setState(() {
        _subjects = filteredSubjects;
      });
      await _loadProgressOnly();
    } catch (e) {
      print('Error loading subjects: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProgressOnly() async {
    try {
      final supabase = Supabase.instance.client;
      final studentDbId = widget.student['id'];
      final progressList = await supabase
          .from('student_progress')
          .select('chapter_id, task_id, is_completed')
          .eq('student_id', studentDbId);

      setState(() {
        _completedTasks.clear();
        _chapterCompletedCount.clear();
        for (var item in progressList) {
          if (item['is_completed'] == true) {
            final chapterId = item['chapter_id'] as String;
            final taskId = item['task_id'] as String;
            if (!_completedTasks.containsKey(chapterId)) {
              _completedTasks[chapterId] = {};
            }
            _completedTasks[chapterId]!.add(taskId);
            _chapterCompletedCount[chapterId] = (_chapterCompletedCount[chapterId] ?? 0) + 1;
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading progress: $e');
      setState(() => _isLoading = false);
    }
  }

  Color _parseSubjectColor(String colorValue) {
    try {
      final colorName = colorValue.toLowerCase().trim();
      switch (colorName) {
        case 'blue': return Colors.blue;
        case 'red': return Colors.red;
        case 'green': return Colors.green;
        case 'purple': return Colors.purple;
        case 'orange': return Colors.orange;
        case 'pink': return Colors.pink;
        case 'cyan': return Colors.cyan;
        case 'amber': return Colors.amber;
        case 'teal': return Colors.teal;
        case 'indigo': return Colors.indigo;
        case 'lime': return Colors.lime;
        case 'yellow': return Colors.yellow;
        case 'brown': return Colors.brown;
        case 'grey':
        case 'gray': return Colors.grey;
        default:
          if (colorValue.contains('#') || colorValue.length >= 6) {
            final hex = colorValue.replaceAll('#', '');
            return Color(int.parse('0xFF$hex'));
          }
          return AppTheme.primary;
      }
    } catch (e) {
      return AppTheme.primary;
    }
  }

  double _getOverallProgress(SubjectModel subject) {
    final chapters = subject.chapters ?? [];
    if (chapters.isEmpty) return 0.0;
    int totalTasks = 0;
    int completedTasks = 0;
    for (var chapter in chapters) {
      final tasks = chapter.tasks ?? [];
      totalTasks += tasks.length;
      completedTasks += _chapterCompletedCount[chapter.id] ?? 0;
    }
    return totalTasks > 0 ? completedTasks / totalTasks : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.student['name'] ?? 'Loading'),
          backgroundColor: AppTheme.primary,
          actions: [
            if (widget.isParentView)
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Force Logout',
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (context.mounted) Navigator.pushReplacementNamed(context, '/role-selection');
                },
              ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              if (widget.isParentView)
                const Text('Loading your ward\'s progress...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    if (_subjects.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.student['name'] ?? 'Unknown'), backgroundColor: AppTheme.primary),
        body: const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No subjects found for this batch'))),
      );
    }

    final selectedSubject = _subjects[_selectedSubjectIndex];
    final chapters = selectedSubject.chapters ?? [];
    final overallProgress = _getOverallProgress(selectedSubject);

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text(widget.isParentView ? 'Parent Dashboard' : 'Monitoring: ${widget.student['name']}'),
        backgroundColor: widget.isParentView ? Colors.orange : AppTheme.primary,
        elevation: 0,
        leading: widget.isParentView
          ? IconButton(icon: const Icon(Icons.logout), onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) Navigator.pushReplacementNamed(context, '/role-selection');
            })
          : null,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  Text(widget.isParentView ? 'CHILD LIVE' : 'LIVE', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(width: 4),
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (widget.isParentView ? Colors.orange : AppTheme.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: (widget.isParentView ? Colors.orange : AppTheme.primary).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.isParentView ? '🎓 Ward Profile' : '👤 Student Profile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                      const Text('VIEW ONLY', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(widget.student['name'] ?? 'Unknown', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.badge, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        'ID: ${(widget.student['serial_id']?.toString().isEmpty ?? true) ? 'N/A' : widget.student['serial_id']}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.book, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text('${widget.student['board']} ${widget.student['standard']}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedSubjectIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color, width: isSelected ? 0 : 1),
                        ),
                        child: Center(child: Text(subject.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : color))),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${widget.student['board']} Grade ${widget.student['standard']} • 2024-25', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  const SizedBox(height: 16),
                  Text('${selectedSubject.name} Overall Progress', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: overallProgress,
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(_parseSubjectColor(selectedSubject.color)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${(overallProgress * 100).round()}% Course Completed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _parseSubjectColor(selectedSubject.color))),
                  const SizedBox(height: 24),
                  ...chapters.asMap().entries.map((entry) {
                    final chapter = entry.value;
                    final chapterId = chapter.id;
                    final isExpanded = _expandedChapters[chapterId] ?? false;
                    final completed = _chapterCompletedCount[chapterId] ?? 0;
                    final tasks = chapter.tasks ?? [];
                    final total = tasks.length;
                    final subjectColor = _parseSubjectColor(selectedSubject.color);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: subjectColor.withOpacity(0.2))),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _expandedChapters[chapterId] = !isExpanded),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32, height: 32,
                                    decoration: BoxDecoration(color: subjectColor, borderRadius: BorderRadius.circular(6)),
                                    child: Center(child: Text('${chapter.orderIndex ?? entry.key + 1}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white))),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(chapter.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                                  Text('$completed/$total', style: TextStyle(fontSize: 13, color: subjectColor, fontWeight: FontWeight.w600)),
                                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: subjectColor),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: total > 0 ? completed / total : 0,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(subjectColor),
                              ),
                            ),
                            if (isExpanded) ...[
                              const SizedBox(height: 16),
                              const Divider(),
                              ...tasks.map((task) {
                                final isTaskCompleted = (_completedTasks[chapterId] ?? {}).contains(task.id);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Icon(isTaskCompleted ? Icons.check_circle : Icons.radio_button_unchecked, size: 18, color: isTaskCompleted ? subjectColor : Colors.grey),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(task.title, style: TextStyle(fontSize: 13, color: isTaskCompleted ? Colors.grey : Colors.black, decoration: isTaskCompleted ? TextDecoration.lineThrough : null))),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue.withOpacity(0.2))),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [Icon(Icons.info_outline, size: 16, color: Colors.blue), SizedBox(width: 8), Text('About Logbook Monitoring', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue))]),
                    SizedBox(height: 8),
                    Text('This view is synchronized with the student\'s device. You are seeing their live progress as they mark tasks complete.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
