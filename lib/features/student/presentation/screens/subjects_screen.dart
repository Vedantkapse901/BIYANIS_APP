import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'chapters_screen.dart';

class SubjectsScreen extends StatefulWidget {
  final Map<String, dynamic> subject;

  const SubjectsScreen({super.key, required this.subject});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  // Static chapters data
  late List<Map<String, dynamic>> chapters;

  @override
  void initState() {
    super.initState();
    chapters = _getChaptersForSubject(widget.subject['id']);
  }

  List<Map<String, dynamic>> _getChaptersForSubject(int subjectId) {
    final allChapters = {
      1: [ // Mathematics
        {'id': 1, 'name': 'Chapter 1: Numbers', 'icon': '1️⃣'},
        {'id': 2, 'name': 'Chapter 2: Algebra', 'icon': '🔤'},
        {'id': 3, 'name': 'Chapter 3: Geometry', 'icon': '📐'},
        {'id': 4, 'name': 'Chapter 4: Trigonometry', 'icon': '📊'},
      ],
      2: [ // Science
        {'id': 5, 'name': 'Chapter 1: Physics', 'icon': '⚛️'},
        {'id': 6, 'name': 'Chapter 2: Chemistry', 'icon': '🧪'},
        {'id': 7, 'name': 'Chapter 3: Biology', 'icon': '🧬'},
      ],
      3: [ // English
        {'id': 8, 'name': 'Chapter 1: Grammar', 'icon': '📝'},
        {'id': 9, 'name': 'Chapter 2: Literature', 'icon': '📖'},
        {'id': 10, 'name': 'Chapter 3: Comprehension', 'icon': '🤔'},
      ],
      4: [ // History
        {'id': 11, 'name': 'Chapter 1: Ancient History', 'icon': '🏛️'},
        {'id': 12, 'name': 'Chapter 2: Medieval Period', 'icon': '🏰'},
        {'id': 13, 'name': 'Chapter 3: Modern Era', 'icon': '🌐'},
      ],
      5: [ // Geography
        {'id': 14, 'name': 'Chapter 1: World Maps', 'icon': '🗺️'},
        {'id': 15, 'name': 'Chapter 2: Continents', 'icon': '🌎'},
        {'id': 16, 'name': 'Chapter 3: Climate', 'icon': '🌤️'},
      ],
      6: [ // Computer Science
        {'id': 17, 'name': 'Chapter 1: Programming', 'icon': '💻'},
        {'id': 18, 'name': 'Chapter 2: Data Structures', 'icon': '📊'},
        {'id': 19, 'name': 'Chapter 3: Networks', 'icon': '🌐'},
      ],
    };

    return allChapters[subjectId] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text(widget.subject['name']),
        elevation: 0,
        backgroundColor: AppTheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              'Chapters in ${widget.subject['name']}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChaptersScreen(
                          chapter: chapter,
                          subject: widget.subject,
                        ),
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
                            widget.subject['color'].withOpacity(0.2),
                            widget.subject['color'].withOpacity(0.05),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            chapter['icon'],
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chapter['name'],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '3 tasks available',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey.shade600,
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
