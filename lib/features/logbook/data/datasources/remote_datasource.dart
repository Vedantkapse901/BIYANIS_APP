import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/b2_storage_service.dart';
import '../models/subject_model.dart';
import '../models/topic_model.dart';

class RemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;
  final B2StorageService _b2storage = B2StorageService();

  // Subjects with full hierarchy: Chapters -> Topics -> Tasks
  Future<List<SubjectModel>> getAllSubjects({String? batch}) async {
    final query = _client.from('subjects').select('''
      *,
      chapters (
        *,
        topics (
          *,
          tasks (
            *,
            student_progress (*)
          )
        )
      )
    ''');

    if (batch != null) {
      query.eq('batch', batch);
    }

    final response = await query;
    return (response as List).map((json) => SubjectModel.fromJson(json)).toList();
  }

  Future<void> createSubject(SubjectModel subject) async {
    await _client.from('subjects').insert(subject.toJson());
  }

  // Topics & Progress
  Future<List<TopicModel>> getTopicsBySubjectId(String subjectId) async {
    final response = await _client
        .from('topics')
        .select()
        .eq('subject_id', subjectId)
        .order('order_index');
    return (response as List).map((json) => TopicModel.fromJson(json)).toList();
  }

  Future<void> toggleTopicCompletion(String topicId, bool isCompleted) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('student_progress').upsert({
      'student_id': userId,
      'topic_id': topicId,
      'is_completed': isCompleted,
      'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
    });
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
