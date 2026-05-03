import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/topic_entity.dart';
import 'task_model.dart';

part 'topic_model.g.dart';

@HiveType(typeId: 1)
class TopicModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String subjectId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String? description;

  @HiveField(4)
  bool? isCompleted;

  @HiveField(5)
  DateTime? createdAt;

  @HiveField(6)
  DateTime? completedAt;

  @HiveField(7)
  DateTime? updatedAt;

  @HiveField(8)
  int? orderIndex;

  @HiveField(9)
  List<TaskModel> tasks;

  TopicModel({
    required this.id,
    required this.subjectId,
    required this.title,
    this.description,
    this.isCompleted,
    this.createdAt,
    this.completedAt,
    this.updatedAt,
    this.orderIndex,
    this.tasks = const [],
  });

  // Convert to Entity
  TopicEntity toEntity() {
    return TopicEntity(
      id: id,
      subjectId: subjectId,
      title: title,
      description: description,
      isCompleted: isCompleted ?? false,
      createdAt: createdAt ?? DateTime.now(),
      completedAt: completedAt,
      updatedAt: updatedAt ?? DateTime.now(),
      orderIndex: orderIndex ?? 0,
      tasks: tasks.map((t) => t.toEntity()).toList(),
    );
  }

  // Convert from Entity
  factory TopicModel.fromEntity(TopicEntity entity) {
    return TopicModel(
      id: entity.id,
      subjectId: entity.subjectId ?? '',
      title: entity.title,
      description: entity.description,
      isCompleted: entity.isCompleted ?? false,
      createdAt: entity.createdAt ?? DateTime.now(),
      completedAt: entity.completedAt,
      updatedAt: entity.updatedAt ?? DateTime.now(),
      orderIndex: entity.orderIndex,
      tasks: entity.tasks.map((t) => TaskModel.fromEntity(t)).toList(),
    );
  }
}
