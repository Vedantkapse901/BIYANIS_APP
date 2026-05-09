class TaskEntity {
  final String id;
  final String? chapterId;
  final String? chapterName;
  final String title;
  final bool isCompleted;
  final int orderIndex;

  TaskEntity({
    required this.id,
    this.chapterId,
    this.chapterName,
    required this.title,
    required this.isCompleted,
    this.orderIndex = 0,
  });

  TaskEntity copyWith({
    String? id,
    String? chapterId,
    String? chapterName,
    String? title,
    bool? isCompleted,
    int? orderIndex,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      chapterName: chapterName ?? this.chapterName,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}
