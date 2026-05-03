class TaskEntity {
  final String id;
  final String topicId;
  final String title;
  final bool isCompleted;

  TaskEntity({
    required this.id,
    required this.topicId,
    required this.title,
    required this.isCompleted,
  });

  TaskEntity copyWith({
    String? id,
    String? topicId,
    String? title,
    bool? isCompleted,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
