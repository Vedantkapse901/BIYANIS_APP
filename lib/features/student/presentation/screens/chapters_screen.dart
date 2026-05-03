import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'task_detail_screen.dart';

class ChaptersScreen extends StatefulWidget {
  final Map<String, dynamic> chapter;
  final Map<String, dynamic> subject;

  const ChaptersScreen({
    super.key,
    required this.chapter,
    required this.subject,
  });

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  // Static tasks data
  late List<Map<String, dynamic>> tasks;

  @override
  void initState() {
    super.initState();
    tasks = _getTasksForChapter(widget.chapter['id']);
  }

  List<Map<String, dynamic>> _getTasksForChapter(int chapterId) {
    return [
      {
        'id': 1,
        'title': 'Task 1: Introduction',
        'description': 'Learn the basics of this chapter',
        'type': 'Reading',
        'icon': '📖',
        'content': 'This is the introduction to ${widget.chapter['name']}.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text(widget.chapter['name']),
        elevation: 0,
        backgroundColor: AppTheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.subject['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.subject['color'].withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Text(widget.subject['icon'], style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.subject['name'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          widget.chapter['name'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tasks in this Chapter',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskDetailScreen(task: task),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.subject['color'].withOpacity(0.15),
                            widget.subject['color'].withOpacity(0.05),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                task['icon'],
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task['title'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      task['description'],
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
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: widget.subject['color'].withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              task['type'],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: widget.subject['color'],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
