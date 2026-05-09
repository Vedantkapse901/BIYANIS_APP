import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/b2_storage_service.dart';
import '../models/subject_model.dart';
import '../models/chapter_model.dart';
import '../models/task_model.dart';

class RemoteDataSource {
  late final SupabaseClient _client = Supabase.instance.client;
  final B2StorageService _b2storage = B2StorageService();

  // ✅ Subjects with full hierarchy: Chapters -> Tasks (no topics level)
  // OPTIMIZED: Only fetches specified batch data
  Future<List<SubjectModel>> getAllSubjects({String? batch}) async {
    try {
      if (batch == null || batch.isEmpty) {
        print('❌ Batch is required');
        return [];
      }

      print('⚡ Fetching ONLY $batch subjects...');

      // Step 1: Fetch subjects for this batch (Flexible matching)
      // Extracts parts like "ICSE" and "10" from "ICSE 10" or "ICSE-10"
      final parts = batch.split(RegExp(r'[\s\-_]+'));
      final board = parts[0];
      final standard = parts.length > 1 ? parts[1].replaceAll(RegExp(r'(st|nd|rd|th)$', caseSensitive: false), '') : '';

      var query = _client.from('subjects').select('*');

      if (standard.isNotEmpty) {
        // Match subjects where batch contains both board and standard number
        query = query.ilike('batch', '%$board%').ilike('batch', '%$standard%');
      } else {
        query = query.ilike('batch', '%$board%');
      }

      final subjectResponse = await query;

      final subjects = (subjectResponse as List).cast<Map<String, dynamic>>();
      print('✅ Found ${subjects.length} subjects for batch: $batch');

      if (subjects.isEmpty) {
        return [];
      }

      // Extract subject IDs
      final subjectIds = subjects.map((s) => s['id'] as String).toList();

      // Step 2: Fetch chapters ONLY for these subjects
      print('⚡ Fetching chapters for ${subjectIds.length} subjects...');
      final chaptersResponse = await _client
          .from('chapters')
          .select('*')
          .inFilter('subject_id', subjectIds)
          .order('order_index');

      final allChapters = (chaptersResponse as List).cast<Map<String, dynamic>>();
      print('✅ Found ${allChapters.length} chapters');

      // Group chapters by subject_id
      final chaptersBySubject = <String, List<Map<String, dynamic>>>{};
      for (var chapter in allChapters) {
        final subjectId = chapter['subject_id'] as String;
        chaptersBySubject.putIfAbsent(subjectId, () => []).add(chapter);
      }

      // Step 3: Assemble hierarchy (Tasks are now inside chapter columns task_1...task_13)
      for (var subject in subjects) {
        final subjectId = subject['id'] as String;
        final chaptersData = chaptersBySubject[subjectId] ?? [];
        subject['chapters'] = chaptersData;
      }

      print('✅ ⚡ FAST LOAD: ${subjects.length} subjects, ${allChapters.length} chapters');
      return subjects.map((json) => SubjectModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error in getAllSubjects: $e');
      rethrow;
    }
  }

  Future<void> createSubject(SubjectModel subject) async {
    await _client.from('subjects').insert(subject.toJson());
  }

  // ✅ Get chapters for a subject (with tasks)
  Future<List<ChapterModel>> getChaptersBySubjectId(String subjectId) async {
    final response = await _client
        .from('chapters')
        .select('*')
        .eq('subject_id', subjectId)
        .order('order_index');
    return (response as List).map((json) => ChapterModel.fromJson(json)).toList();
  }

  // ✅ Get tasks for a chapter
  Future<List<TaskModel>> getTasksByChapterId(String chapterId) async {
    final response = await _client
        .from('chapters')
        .select('*')
        .eq('id', chapterId)
        .single();

    final chapter = ChapterModel.fromJson(response);
    return chapter.tasks;
  }

  // ✅ Toggle task completion (updated for chapter_id)
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('student_progress').upsert({
      'student_id': userId,
      'task_id': taskId,
      'is_completed': isCompleted,
      'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
    });
  }

  // ✅ Get student progress for a chapter
  Future<Map<String, bool>> getChapterProgress(String chapterId, String studentId) async {
    final taskIds = await _client
        .from('tasks')
        .select('id')
        .eq('chapter_id', chapterId)
        .then((tasks) => (tasks as List).map((t) => t['id'] as String).toList());

    if (taskIds.isEmpty) return {};

    final response = await _client
        .from('student_progress')
        .select('task_id, is_completed')
        .eq('student_id', studentId)
        .inFilter('task_id', taskIds);

    final progressMap = <String, bool>{};
    for (final item in response as List) {
      progressMap[item['task_id']] = item['is_completed'] ?? false;
    }
    return progressMap;
  }

  // Backblaze B2 Storage (B2B/Tenant based path)
  Future<String?> uploadProfileImage(String filePath, String fileName) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    // Organize by user ID (tenant-like structure for B2B)
    final path = 'profiles/$userId/$fileName';

    try {
      final publicUrl = await _b2storage.uploadFile(
        path: path,
        filePath: filePath,
        contentType: 'image/jpeg',
      );

      if (publicUrl != null) {
        // Sync URL back to Supabase Profile for easy access
        await _client.from('profiles').update({'profile_image': publicUrl}).eq('id', userId);
      }

      return publicUrl;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadDocument(String filePath, String fileName, String category) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    // Organized by User and Category for B2B document management
    final path = 'documents/$userId/$category/$fileName';

    try {
      return await _b2storage.uploadFile(
        path: path,
        filePath: filePath,
      );
    } catch (e) {
      return null;
    }
  }
}
