class TaskEntity {
  final String id;
  final String topicId;
  final String title;
  final bool isCompleted;
<<<<<<< HEAD
  final int orderIndex;
=======
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1

  TaskEntity({
    required this.id,
    required this.topicId,
    required this.title,
    required this.isCompleted,
<<<<<<< HEAD
    this.orderIndex = 0,
=======
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
  });

  TaskEntity copyWith({
    String? id,
    String? topicId,
    String? title,
    bool? isCompleted,
<<<<<<< HEAD
    int? orderIndex,
=======
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
  }) {
    return TaskEntity(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
<<<<<<< HEAD
      orderIndex: orderIndex ?? this.orderIndex,
=======
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
    );
  }
}
