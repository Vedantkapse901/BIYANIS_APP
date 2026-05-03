import '../../domain/entities/subject_entity.dart';
import '../../domain/entities/topic_entity.dart';
import '../datasources/local_datasource.dart';
<<<<<<< HEAD
import '../datasources/remote_datasource.dart';
=======
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
import '../models/subject_model.dart';
import '../models/topic_model.dart';

abstract class LogbookRepository {
  // Subjects
  Future<List<SubjectEntity>> getAllSubjects({String? batch});
  Future<SubjectEntity?> getSubjectById(String id);
  Future<void> createSubject(SubjectEntity subject);
  Future<void> updateSubject(SubjectEntity subject);
  Future<void> deleteSubject(String id);

  // Topics
  Future<List<TopicEntity>> getTopicsBySubjectId(String subjectId);
  Future<TopicEntity?> getTopicById(String id);
  Future<void> createTopic(TopicEntity topic);
  Future<void> updateTopic(TopicEntity topic);
  Future<void> deleteTopic(String topicId);
  Future<void> toggleTopicCompletion(String topicId);
  Future<void> toggleTaskCompletion(String subjectId, String chapterId, String topicId, String taskId);

  // User
  Future<void> saveUserRole(String role);
  Future<String?> getUserRole();
  Future<void> saveUserId(String userId);
  Future<String?> getUserId();

  // Data management
  Future<void> seedMockData();
  Future<void> clearAllData();
<<<<<<< HEAD

  // Storage
  Future<String?> uploadProfileImage(String filePath, String fileName);
=======
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
}

class LogbookRepositoryImpl implements LogbookRepository {
  final LocalDataSource localDataSource;
<<<<<<< HEAD
  final RemoteDataSource remoteDataSource;

  LogbookRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<SubjectEntity>> getAllSubjects({String? batch}) async {
    try {
      // Try to fetch from remote and sync
      final remoteSubjects = await remoteDataSource.getAllSubjects(batch: batch);
      for (var model in remoteSubjects) {
        await localDataSource.updateSubject(model);
      }
    } catch (e) {
      // Fallback to local if offline
      print('LogbookRepository: Offline mode or error fetching subjects: $e');
    }

=======

  LogbookRepositoryImpl({required this.localDataSource});

  @override
  Future<List<SubjectEntity>> getAllSubjects({String? batch}) async {
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
    final models = await localDataSource.getAllSubjects(batch: batch);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<SubjectEntity?> getSubjectById(String id) async {
    final model = await localDataSource.getSubjectById(id);
    return model?.toEntity();
  }

  @override
  Future<void> createSubject(SubjectEntity subject) async {
    final model = SubjectModel.fromEntity(subject);
    await localDataSource.createSubject(model);
<<<<<<< HEAD
    try {
      await remoteDataSource.createSubject(model);
    } catch (e) {
      print('LogbookRepository: Error syncing created subject: $e');
    }
=======
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
  }

  @override
  Future<void> updateSubject(SubjectEntity subject) async {
    final model = SubjectModel.fromEntity(subject);
    await localDataSource.updateSubject(model);
<<<<<<< HEAD
    // Add remote update logic if needed
=======
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
  }

  @override
  Future<void> deleteSubject(String id) async {
    await localDataSource.deleteSubject(id);
<<<<<<< HEAD
    // Add remote delete logic if needed
=======
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
  }

  @override
  Future<List<TopicEntity>> getTopicsBySubjectId(String subjectId) async {
<<<<<<< HEAD
    try {
      final remoteTopics = await remoteDataSource.getTopicsBySubjectId(subjectId);
      for (var model in remoteTopics) {
        await localDataSource.updateTopic(model);
      }
    } catch (e) {
      print('LogbookRepository: Offline mode or error fetching topics: $e');
    }

=======
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
    final models = await localDataSource.getTopicsBySubjectId(subjectId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<TopicEntity?> getTopicById(String id) async {
    final model = await localDataSource.getTopicById(id);
    return model?.toEntity();
  }

  @override
  Future<void> createTopic(TopicEntity topic) async {
    final model = TopicModel.fromEntity(topic);
    await localDataSource.createTopic(model);
  }

  @override
  Future<void> updateTopic(TopicEntity topic) async {
    final model = TopicModel.fromEntity(topic);
    await localDataSource.updateTopic(model);
  }

  @override
  Future<void> deleteTopic(String topicId) async {
    await localDataSource.deleteTopic(topicId);
  }

  @override
  Future<void> toggleTopicCompletion(String topicId) async {
<<<<<<< HEAD
    final topic = await localDataSource.getTopicById(topicId);
    if (topic != null) {
      final newStatus = !(topic.isCompleted ?? false);
      await localDataSource.toggleTopicCompletion(topicId);
      try {
        await remoteDataSource.toggleTopicCompletion(topicId, newStatus);
      } catch (e) {
        print('LogbookRepository: Error syncing completion status: $e');
      }
    }
=======
    await localDataSource.toggleTopicCompletion(topicId);
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
  }

  @override
  Future<void> toggleTaskCompletion(String subjectId, String chapterId, String topicId, String taskId) async {
    await localDataSource.toggleTaskCompletion(subjectId, chapterId, topicId, taskId);
  }

  @override
  Future<void> saveUserRole(String role) async {
    await localDataSource.saveUserRole(role);
  }

  @override
  Future<String?> getUserRole() async {
    return await localDataSource.getUserRole();
  }

  @override
  Future<void> saveUserId(String userId) async {
    await localDataSource.saveUserId(userId);
  }

  @override
  Future<String?> getUserId() async {
    return await localDataSource.getUserId();
  }

  @override
  Future<void> seedMockData() async {
    await localDataSource.seedMockData();
  }

  @override
  Future<void> clearAllData() async {
    await localDataSource.clearAllData();
  }
<<<<<<< HEAD

  @override
  Future<String?> uploadProfileImage(String filePath, String fileName) async {
    return await remoteDataSource.uploadProfileImage(filePath, fileName);
  }
=======
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
}
