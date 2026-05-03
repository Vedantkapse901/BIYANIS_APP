import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'task_detail_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedSubjectIndex = 0;
  final Map<int, bool> _expandedChapters = {}; // Track which chapters are expanded
  final Map<int, Set<int>> _completedTasks = {}; // Track completed tasks per chapter
  final Map<int, int> _chapterCompletedCount = {}; // Track completed tasks count per chapter
  final ScrollController _scrollController = ScrollController();

  // Static subjects data
  final List<Map<String, dynamic>> subjects = [
    {
      'id': 1,
      'name': 'Mathematics',
      'icon': '📐',
      'color': Colors.blue,
    },
    {
      'id': 2,
      'name': 'Science',
      'icon': '🔬',
      'color': Colors.green,
    },
    {
      'id': 3,
      'name': 'English',
      'icon': '📚',
      'color': Colors.purple,
    },
    {
      'id': 4,
      'name': 'History',
      'icon': '📜',
      'color': Colors.orange,
    },
    {
      'id': 5,
      'name': 'Geography',
      'icon': '🌍',
      'color': Colors.teal,
    },
    {
      'id': 6,
      'name': 'Computer Science',
      'icon': '💻',
      'color': Colors.red,
    },
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getChaptersForSubject(int subjectId) {
    final allChapters = {
      1: [ // Mathematics
        {'id': 1, 'name': 'Chapter 1: Numbers', 'icon': '1️⃣', 'completed': 5, 'total': 8},
        {'id': 2, 'name': 'Chapter 2: Algebra', 'icon': '🔤', 'completed': 2, 'total': 6},
        {'id': 3, 'name': 'Chapter 3: Geometry', 'icon': '📐', 'completed': 0, 'total': 5},
        {'id': 4, 'name': 'Chapter 4: Trigonometry', 'icon': '📊', 'completed': 1, 'total': 7},
      ],
      2: [ // Science
        {'id': 5, 'name': 'Chapter 1: Physics', 'icon': '⚛️', 'completed': 3, 'total': 17},
        {'id': 6, 'name': 'Chapter 2: Chemistry', 'icon': '🧪', 'completed': 4, 'total': 15},
        {'id': 7, 'name': 'Chapter 3: Biology', 'icon': '🧬', 'completed': 2, 'total': 12},
      ],
      3: [ // English
        {'id': 8, 'name': 'Chapter 1: Grammar', 'icon': '📝', 'completed': 6, 'total': 10},
        {'id': 9, 'name': 'Chapter 2: Literature', 'icon': '📖', 'completed': 4, 'total': 8},
        {'id': 10, 'name': 'Chapter 3: Comprehension', 'icon': '🤔', 'completed': 3, 'total': 6},
      ],
      4: [ // History
        {'id': 11, 'name': 'Chapter 1: Ancient History', 'icon': '🏛️', 'completed': 7, 'total': 9},
        {'id': 12, 'name': 'Chapter 2: Medieval Period', 'icon': '🏰', 'completed': 5, 'total': 10},
        {'id': 13, 'name': 'Chapter 3: Modern Era', 'icon': '🌐', 'completed': 2, 'total': 8},
      ],
      5: [ // Geography
        {'id': 14, 'name': 'Chapter 1: World Maps', 'icon': '🗺️', 'completed': 8, 'total': 10},
        {'id': 15, 'name': 'Chapter 2: Continents', 'icon': '🌎', 'completed': 6, 'total': 9},
        {'id': 16, 'name': 'Chapter 3: Climate', 'icon': '🌤️', 'completed': 4, 'total': 7},
      ],
      6: [ // Computer Science
        {'id': 17, 'name': 'Chapter 1: Programming', 'icon': '💻', 'completed': 5, 'total': 11},
        {'id': 18, 'name': 'Chapter 2: Data Structures', 'icon': '📊', 'completed': 3, 'total': 9},
        {'id': 19, 'name': 'Chapter 3: Networks', 'icon': '🌐', 'completed': 1, 'total': 6},
      ],
    };
    return allChapters[subjectId] ?? [];
  }

  List<Map<String, dynamic>> _getTasksForChapter(int chapterId) {
    return [
      {
        'id': 1,
        'title': 'Task 1: Introduction',
        'description': 'Learn the basics of this chapter',
        'type': 'Reading',
        'icon': '📖',
        'content': 'This is the introduction to the chapter.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      },
      {
        'id': 2,
        'title': 'Task 2: Concepts',
        'description': 'Understand key concepts',
        'type': 'Learning',
        'icon': '💡',
        'content': 'Key concepts in this chapter:\n\n1. Concept A - Explanation\n2. Concept B - Explanation\n3. Concept C - Explanation',
      },
      {
        'id': 3,
        'title': 'Task 3: Practice Problems',
        'description': 'Solve practice problems',
        'type': 'Exercise',
        'icon': '✏️',
        'content': 'Practice Problems:\n\n1. Problem 1 - Solution A\n2. Problem 2 - Solution B\n3. Problem 3 - Solution C\n\nTry solving these problems to test your understanding.',
      },
    ];
  }

  int _getTotalBacklog() {
    int total = 0;
    for (var subject in subjects) {
      final chapters = _getChaptersForSubject(subject['id']);
      for (var chapter in chapters) {
        final chapterId = chapter['id'] as int;
        final tasks = _getTasksForChapter(chapterId);
        final completed = _chapterCompletedCount[chapterId] ?? 0;
        total += (tasks.length - completed); // Use actual task count
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final selectedSubject = subjects[_selectedSubjectIndex];
    final chapters = _getChaptersForSubject(selectedSubject['id']);

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('LOG BOOK'),
        elevation: 0,
        backgroundColor: AppTheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject Tabs
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  final isSelected = _selectedSubjectIndex == index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSubjectIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? subject['color'] : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: subject['color'],
                            width: isSelected ? 0 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            subject['name'],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : subject['color'],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Subject Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CSE Grade 10 • 2025-26',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Overall Progress
                  Text(
                    '${selectedSubject['name']} Progress',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Calculate overall progress for subject
                  _buildSubjectProgress(chapters),

                  const SizedBox(height: 24),

                  // Chapters List
                  ...chapters.asMap().entries.map((entry) {
                    final chapter = entry.value;
                    final chapterId = chapter['id'] as int;
                    final isExpanded = _expandedChapters[chapterId] ?? false;
                    final tasks = _getTasksForChapter(chapterId);
                    final totalTasks = tasks.length; // Actual tasks assigned

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: selectedSubject['color'].withOpacity(0.2),
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
                                    Text(
                                      chapter['icon'],
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        chapter['name'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${_chapterCompletedCount[chapterId] ?? 0}/$totalTasks',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: selectedSubject['color'],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      isExpanded ? Icons.expand_less : Icons.expand_more,
                                      color: selectedSubject['color'],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (_chapterCompletedCount[chapterId] ?? 0) / totalTasks,
                                  minHeight: 6,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    selectedSubject['color'],
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
                                ...tasks.asMap().entries.map((taskEntry) {
                                  final task = taskEntry.value;
                                  final taskId = taskEntry.key;
                                  final isCompleted = (_completedTasks[chapterId] ?? {}).contains(taskId);

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (_completedTasks[chapterId] == null) {
                                            _completedTasks[chapterId] = {};
                                          }
                                          if (isCompleted) {
                                            _completedTasks[chapterId]!.remove(taskId);
                                          } else {
                                            _completedTasks[chapterId]!.add(taskId);
                                          }
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isCompleted ? selectedSubject['color'] : Colors.grey.shade400,
                                                width: 2,
                                              ),
                                              color: isCompleted ? selectedSubject['color'] : Colors.transparent,
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
                                              task['title'],
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
                                    onPressed: () {
                                      final completed = (_completedTasks[chapterId] ?? {}).length;
                                      setState(() {
                                        _chapterCompletedCount[chapterId] = completed;
                                      });

                                      // Scroll to top to show updated progress
                                      _scrollController.animateTo(
                                        0,
                                        duration: const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('$completed/${tasks.length} tasks submitted! ✓'),
                                          duration: const Duration(seconds: 2),
                                          backgroundColor: selectedSubject['color'],
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: selectedSubject['color'],
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

  Widget _buildSubjectProgress(List<Map<String, dynamic>> chapters) {
    int totalCompleted = 0;
    int totalTasks = 0;

    for (var chapter in chapters) {
      final chapterId = chapter['id'] as int;
      final tasks = _getTasksForChapter(chapterId);
      totalCompleted += _chapterCompletedCount[chapterId] ?? 0;
      totalTasks += tasks.length; // Use actual task count, not chapter['total']
    }

    final percentage = totalTasks > 0 ? (totalCompleted / totalTasks * 100).toStringAsFixed(0) : 0;
    final selectedSubject = subjects[_selectedSubjectIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: selectedSubject['color'],
              ),
            ),
            Text(
              '$totalCompleted of $totalTasks tasks completed',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: totalCompleted / (totalTasks > 0 ? totalTasks : 1),
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              selectedSubject['color'],
            ),
          ),
        ),
      ],
    );
  }

  void _showChapterDetails(BuildContext context, Map<String, dynamic> chapter) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final tasks = _getTasksForChapter(chapter['id']);
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          chapter['icon'],
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chapter['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${chapter['completed']}/${chapter['total']} tasks completed',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Tasks',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...tasks.map((task) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TaskDetailScreen(task: task),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Text(
                                    task['icon'],
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task['title'],
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          task['type'],
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
