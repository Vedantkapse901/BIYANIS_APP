class TaskEntity {
  final String id;
  final String topicId;
  final String title;
  final bool isCompleted;
  final int orderIndex;

  TaskEntity({
    required this.id,
    required this.topicId,
    required this.title,
    required this.isCompleted,
    this.orderIndex = 0,
  });

  TaskEntity copyWith({
    String? id,
    String? topicId,
    String? title,
    bool? isCompleted,
    int? orderIndex,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}
