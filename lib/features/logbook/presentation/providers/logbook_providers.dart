import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote_datasource.dart';
import '../../data/models/subject_model.dart';
import '../../data/models/chapter_model.dart';
import '../../data/models/task_model.dart';

// ✅ Remote Data Source Provider
final remoteDataSourceProvider = Provider((ref) => RemoteDataSource());

// ✅ Get all subjects for a batch (e.g., 'ICSE 10', 'CBSE 10', 'ICSE 9')
final subjectsProvider =
    FutureProvider.family<List<SubjectModel>, String>((ref, batch) async {
  final dataSource = ref.watch(remoteDataSourceProvider);
  print('📚 Fetching subjects for batch: $batch');
  try {
    final subjects = await dataSource.getAllSubjects(batch: batch);
    print('✅ Subjects fetched: ${subjects.length}');
    for (var subject in subjects) {
      print('   - ${subject.name}: ${subject.chapters?.length ?? 0} chapters');
    }
    return subjects;
  } catch (e) {
    print('❌ Error fetching subjects: $e');
    rethrow;
  }
});

// ✅ Get chapters for a specific subject
final chaptersProvider =
    FutureProvider.family<List<ChapterModel>, String>((ref, subjectId) async {
  final dataSource = ref.watch(remoteDataSourceProvider);
  return dataSource.getChaptersBySubjectId(subjectId);
});

// ✅ Get tasks for a specific chapter
final tasksProvider =
    FutureProvider.family<List<TaskModel>, String>((ref, chapterId) async {
  final dataSource = ref.watch(remoteDataSourceProvider);
  return dataSource.getTasksByChapterId(chapterId);
});

// ✅ Get student progress for a chapter
final chapterProgressProvider = FutureProvider.family<Map<String, bool>, (String, String)>(
    (ref, params) async {
  final (chapterId, studentId) = params;
  final dataSource = ref.watch(remoteDataSourceProvider);
  return dataSource.getChapterProgress(chapterId, studentId);
});

// ✅ Toggle task completion (StateNotifier for reactive updates)
final taskCompletionProvider = StateNotifierProvider.family<
    TaskCompletionNotifier,
    bool,
    String>((ref, taskId) {
  final dataSource = ref.watch(remoteDataSourceProvider);
  return TaskCompletionNotifier(dataSource, taskId);
});

class TaskCompletionNotifier extends StateNotifier<bool> {
  final RemoteDataSource _dataSource;
  final String _taskId;

  TaskCompletionNotifier(this._dataSource, this._taskId) : super(false);

  Future<void> toggleCompletion(bool isCompleted) async {
    await _dataSource.toggleTaskCompletion(_taskId, isCompleted);
    state = isCompleted;
  }
}
