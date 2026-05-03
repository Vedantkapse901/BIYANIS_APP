import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/task_entity.dart';

part 'task_model.g.dart';

@HiveType(typeId: 3)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String topicId;

  @HiveField(2)
  String title;

  @HiveField(3)
  bool isCompleted;

<<<<<<< HEAD
  @HiveField(4)
  int orderIndex;

=======
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
  TaskModel({
    required this.id,
    required this.topicId,
    required this.title,
    required this.isCompleted,
<<<<<<< HEAD
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
      topicId: json['topic_id'] ?? '',
      title: json['title'],
      isCompleted: completed,
      orderIndex: json['order_index'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic_id': topicId,
      'title': title,
      'is_completed': isCompleted,
      'order_index': orderIndex,
    };
  }

=======
  });

>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      topicId: topicId,
      title: title,
      isCompleted: isCompleted,
<<<<<<< HEAD
      orderIndex: orderIndex,
=======
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
    );
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      topicId: entity.topicId,
      title: entity.title,
      isCompleted: entity.isCompleted,
<<<<<<< HEAD
      orderIndex: entity.orderIndex,
=======
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
    );
  }
}
