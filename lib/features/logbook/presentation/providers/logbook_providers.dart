import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/local_datasource.dart';
<<<<<<< HEAD
import '../../data/datasources/remote_datasource.dart';
=======
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
import '../../data/repositories/logbook_repository_impl.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/entities/topic_entity.dart';

<<<<<<< HEAD
// DataSource Providers
=======
// DataSource Provider
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSource();
});

<<<<<<< HEAD
final remoteDataSourceProvider = Provider<RemoteDataSource>((ref) {
  return RemoteDataSource();
});

// Repository Provider
final logbookRepositoryProvider = Provider<LogbookRepository>((ref) {
  final localDataSource = ref.watch(localDataSourceProvider);
  final remoteDataSource = ref.watch(remoteDataSourceProvider);
  return LogbookRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );
=======
// Repository Provider
final logbookRepositoryProvider = Provider<LogbookRepository>((ref) {
  final localDataSource = ref.watch(localDataSourceProvider);
  return LogbookRepositoryImpl(localDataSource: localDataSource);
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
});

// User Role Provider
final userRoleProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userRole')?.toLowerCase() ?? 'student';
});

// All Subjects Provider
final allSubjectsProvider = FutureProvider<List<SubjectEntity>>((ref) async {
  final repository = ref.watch(logbookRepositoryProvider);
  return repository.getAllSubjects();
});

// Subjects by Batch Provider
final subjectsByBatchProvider = FutureProvider.family<List<SubjectEntity>, String?>((ref, batch) async {
  final repository = ref.watch(logbookRepositoryProvider);
  return repository.getAllSubjects(batch: batch);
});

// Topics by Subject Provider
final topicsBySubjectProvider =
    FutureProvider.family<List<TopicEntity>, String>((ref, subjectId) async {
  final repository = ref.watch(logbookRepositoryProvider);
  return repository.getTopicsBySubjectId(subjectId);
});

// Toggle Topic Completion Notifier
class ToggleTopicNotifier extends StateNotifier<AsyncValue<void>> {
  final LogbookRepository repository;
  final Ref ref;

  ToggleTopicNotifier(this.repository, this.ref) : super(const AsyncValue.data(null));

  Future<void> toggleTopic(String topicId) async {
    try {
      await repository.toggleTopicCompletion(topicId);
      // Invalidate providers to force a UI refresh with new data
      ref.invalidate(allSubjectsProvider);
      ref.invalidate(overallProgressProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleTask({
    required String subjectId,
    required String chapterId,
    required String topicId,
    required String taskId,
  }) async {
    try {
      await repository.toggleTaskCompletion(subjectId, chapterId, topicId, taskId);
      ref.invalidate(allSubjectsProvider);
      ref.invalidate(overallProgressProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final toggleTopicProvider =
    StateNotifierProvider<ToggleTopicNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(logbookRepositoryProvider);
  return ToggleTopicNotifier(repository, ref);
});

// Overall Progress Provider - Calculated based on actual subject data
final overallProgressProvider = FutureProvider<double>((ref) async {
  final subjects = await ref.watch(allSubjectsProvider.future);

  if (subjects.isEmpty) return 0.0;

  double totalProgress = 0;
  for (var subject in subjects) {
    totalProgress += subject.progress;
  }
  
  return (totalProgress / subjects.length) * 100;
});

// Progress by Batch Provider
final progressByBatchProvider = FutureProvider.family<double, String?>((ref, batch) async {
  final subjects = await ref.watch(subjectsByBatchProvider(batch).future);

  if (subjects.isEmpty) return 0.0;

  double totalProgress = 0;
  for (var subject in subjects) {
    totalProgress += subject.progress;
  }
  
  return (totalProgress / subjects.length) * 100;
});
