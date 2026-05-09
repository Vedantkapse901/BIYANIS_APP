import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/chapter_entity.dart';
import 'topic_model.dart';
import 'task_model.dart';

part 'chapter_model.g.dart';

@HiveType(typeId: 2)
class ChapterModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String subjectId;

  @HiveField(2)
  String title;

  @HiveField(3)
  List<TopicModel> topics;

  @HiveField(4)
  int? orderIndex;

  @HiveField(5)
  List<TaskModel> tasks;

  ChapterModel({
    required this.id,
    required this.subjectId,
    required this.title,
    this.topics = const [],
    this.orderIndex,
    this.tasks = const [],
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    final chapterId = json['id'] as String;
    final chapterTitle = json['title'] ?? json['chapter_name'] ?? '';

    // Parse tasks from columns task_1...task_13 if 'tasks' array is missing
    List<TaskModel> parsedTasks = [];
    if (json['tasks'] != null && (json['tasks'] as List).isNotEmpty) {
      parsedTasks = (json['tasks'] as List).map((t) => TaskModel.fromJson(t)).toList();
    } else {
      for (int i = 1; i <= 13; i++) {
        final taskTitle = json['task_$i'];
        if (taskTitle != null && taskTitle.toString().trim().isNotEmpty) {
          parsedTasks.add(TaskModel(
            id: '${chapterId}_$i',
            chapterId: chapterId,
            chapterName: chapterTitle,
            title: taskTitle.toString(),
            isCompleted: false,
            orderIndex: i,
          ));
        }
      }
    }

    return ChapterModel(
      id: chapterId,
      subjectId: json['subject_id'] ?? '',
      title: chapterTitle,
      orderIndex: json['order_index'] is int
          ? json['order_index']
          : int.tryParse(json['order_index']?.toString() ?? ''),
      topics: json['topics'] != null
          ? (json['topics'] as List).map((t) => TopicModel.fromJson(t)).toList()
          : [],
      tasks: parsedTasks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'title': title,
      'order_index': orderIndex,
      'tasks': tasks.map((t) => t.toJson()).toList(),
    };
  }

  ChapterEntity toEntity() {
    return ChapterEntity(
      id: id,
      subjectId: subjectId,
      title: title,
      topics: topics.map((t) => t.toEntity()).toList(),
      orderIndex: orderIndex ?? 0,
      tasks: tasks.map((t) => t.toEntity()).toList(),
    );
  }

  factory ChapterModel.fromEntity(ChapterEntity entity) {
    return ChapterModel(
      id: entity.id,
      subjectId: entity.subjectId,
      title: entity.title,
      topics: entity.topics.map((t) => TopicModel.fromEntity(t)).toList(),
      orderIndex: entity.orderIndex,
      tasks: entity.tasks.map((t) => TaskModel.fromEntity(t)).toList(),
    );
  }
}
