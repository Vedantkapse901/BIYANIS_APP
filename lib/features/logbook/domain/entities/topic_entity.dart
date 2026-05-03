import 'task_entity.dart';

class TopicEntity {
  final String id;
  final String title;
  final int orderIndex;
  final List<TaskEntity> tasks;
  
  // Compatibility fields
  final String? chapterId;
  final String? subjectId;
  final String? description;
  final bool? isCompleted;
  final DateTime? createdAt;
  final DateTime? completedAt;
  final DateTime? updatedAt;

  TopicEntity({
    required this.id,
    required this.title,
    required this.orderIndex,
    this.tasks = const [],
    this.chapterId,
    this.subjectId,
    this.description,
    this.isCompleted,
    this.createdAt,
    this.completedAt,
    this.updatedAt,
  });

  double get progress {
    if (tasks.isNotEmpty) {
      final completed = tasks.where((t) => t.isCompleted).length;
      return completed / tasks.length;
    }
    return (isCompleted ?? false) ? 1.0 : 0.0;
  }

  TopicEntity copyWith({
    String? id,
    String? title,
    int? orderIndex,
    List<TaskEntity>? tasks,
    String? chapterId,
    String? subjectId,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) {
    return TopicEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      orderIndex: orderIndex ?? this.orderIndex,
      tasks: tasks ?? this.tasks,
      chapterId: chapterId ?? this.chapterId,
      subjectId: subjectId ?? this.subjectId,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
