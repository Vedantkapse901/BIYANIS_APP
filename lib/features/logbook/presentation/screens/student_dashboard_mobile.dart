import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentDashboardMobile extends StatefulWidget {
  final String studentName;
  final String batch;

  const StudentDashboardMobile({
    super.key,
    required this.studentName,
    required this.batch,
  });

  @override
  State<StudentDashboardMobile> createState() => _StudentDashboardMobileState();
}

class _StudentDashboardMobileState extends State<StudentDashboardMobile> {
  late Future<List<SubjectWithChapters>> subjectsFuture;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    subjectsFuture = _loadSubjectsWithChapters();
  }

  Future<List<SubjectWithChapters>> _loadSubjectsWithChapters() async {
    try {
      // Fetch all subjects
      final subjectsResponse = await supabase
          .from('subjects')
          .select('id, name')
          .eq('batch', widget.batch);

      List<SubjectWithChapters> subjects = [];

      for (var subject in subjectsResponse as List) {
        final subjectId = subject['id'];
        final subjectName = subject['name'];

        // Fetch chapters for this subject
        final chaptersResponse = await supabase
            .from('chapters')
            .select(
                'id, title, order_index, task_1, task_2, task_3, task_4, task_5, task_6, task_7, task_8, task_9, task_10, task_11, task_12, task_13')
            .eq('subject_id', subjectId)
            .eq('batch', widget.batch)
            .order('order_index', ascending: true);

        List<ChapterWithTasks> chapters = [];
        for (var chapter in chaptersResponse as List) {
          // Extract tasks from columns task_1 through task_13
          List<String> tasks = [];
          for (int i = 1; i <= 13; i++) {
            final taskKey = 'task_$i';
            final taskValue = chapter[taskKey];
            if (taskValue != null && taskValue.toString().isNotEmpty) {
              tasks.add(taskValue.toString());
            }
          }

          chapters.add(ChapterWithTasks(
            id: chapter['id'],
            title: chapter['title'],
            orderIndex: chapter['order_index'].toString(),
            tasks: tasks,
          ));
        }

        if (chapters.isNotEmpty) {
          subjects.add(SubjectWithChapters(
            id: subjectId,
            name: subjectName,
            chapters: chapters,
          ));
        }
      }

      return subjects;
    } catch (e) {
      print('Error loading subjects: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.batch} - ${widget.studentName}'),
        elevation: 0,
      ),
      body: FutureBuilder<List<SubjectWithChapters>>(
        future: subjectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No subjects found'));
          }

          final subjects = snapshot.data!;

          return ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, subjectIndex) {
              final subject = subjects[subjectIndex];
              return _buildSubjectCard(subject);
            },
          );
        },
      ),
    );
  }

  Widget _buildSubjectCard(SubjectWithChapters subject) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            subject.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subject.chapters.length,
              itemBuilder: (context, chapterIndex) {
                final chapter = subject.chapters[chapterIndex];
                return _buildChapterTile(chapter);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterTile(ChapterWithTasks chapter) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chapter.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Order: ${chapter.orderIndex}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${chapter.tasks.length} tasks',
          style: const TextStyle(fontSize: 12, color: Colors.blue),
        ),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                chapter.tasks.length,
                (taskIndex) => _buildTaskItem(taskIndex + 1, chapter.tasks[taskIndex]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(int taskNumber, String taskTitle) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue[100],
            ),
            child: Center(
              child: Text(
                '$taskNumber',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              taskTitle,
              style: const TextStyle(fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// Data models
class SubjectWithChapters {
  final String id;
  final String name;
  final List<ChapterWithTasks> chapters;

  SubjectWithChapters({
    required this.id,
    required this.name,
    required this.chapters,
  });
}

class ChapterWithTasks {
  final String id;
  final String title;
  final String orderIndex;
  final List<String> tasks;

  ChapterWithTasks({
    required this.id,
    required this.title,
    required this.orderIndex,
    required this.tasks,
  });
}
