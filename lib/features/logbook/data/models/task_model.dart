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

  TaskModel({
    required this.id,
    required this.topicId,
    required this.title,
    required this.isCompleted,
  });

  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      topicId: topicId,
      title: title,
      isCompleted: isCompleted,
    );
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      topicId: entity.topicId,
      title: entity.title,
      isCompleted: entity.isCompleted,
    );
  }
}
