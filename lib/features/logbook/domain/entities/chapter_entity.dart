import 'topic_entity.dart';
import 'task_entity.dart';

class ChapterEntity {
  final String id;
  final String subjectId;
  final String title;
  final List<TopicEntity> topics;
  final int orderIndex;
  final List<TaskEntity> tasks;

  ChapterEntity({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.topics,
    required this.orderIndex,
    this.tasks = const [],
  });

  double get progress {
    if (topics.isEmpty) return 0.0;
    double totalProgress = 0;
    for (var topic in topics) {
      totalProgress += topic.progress;
    }
    return totalProgress / topics.length;
  }

  ChapterEntity copyWith({
    String? id,
    String? subjectId,
    String? title,
    List<TopicEntity>? topics,
    int? orderIndex,
    List<TaskEntity>? tasks,
  }) {
    return ChapterEntity(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      topics: topics ?? this.topics,
      orderIndex: orderIndex ?? this.orderIndex,
      tasks: tasks ?? this.tasks,
    );
  }
}
