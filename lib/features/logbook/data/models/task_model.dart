import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/task_entity.dart';

part 'task_model.g.dart';

@HiveType(typeId: 3)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? chapterId;

  @HiveField(2)
  String title;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  int orderIndex;

  @HiveField(5)
  String? chapterName;

  TaskModel({
    required this.id,
    this.chapterId,
    this.chapterName,
    required this.title,
    required this.isCompleted,
    this.orderIndex = 0,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    // Check if student_progress exists and has a completion status
    bool completed = json['is_completed'] ?? false;

    if (json['student_progress'] != null && (json['student_progress'] as List).isNotEmpty) {
      completed = json['student_progress'][0]['is_completed'] ?? false;
    }

    return TaskModel(
      id: json['id'],
      chapterId: json['chapter_id'],
      chapterName: json['chapter_name'],
      title: json['title'],
      isCompleted: completed,
      orderIndex: json['order_index'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_id': chapterId,
      'chapter_name': chapterName,
      'title': title,
      'is_completed': isCompleted,
      'order_index': orderIndex,
    };
  }

  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      chapterId: chapterId,
      chapterName: chapterName,
      title: title,
      isCompleted: isCompleted,
      orderIndex: orderIndex,
    );
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      chapterId: entity.chapterId,
      chapterName: entity.chapterName,
      title: entity.title,
      isCompleted: entity.isCompleted,
      orderIndex: entity.orderIndex,
    );
  }
}
