import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/chapter_entity.dart';
import 'topic_model.dart';

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

  ChapterModel({
    required this.id,
    required this.subjectId,
    required this.title,
    this.topics = const [],
    this.orderIndex,
  });

<<<<<<< HEAD
  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'],
      subjectId: json['subject_id'] ?? '',
      title: json['title'],
      orderIndex: json['order_index'],
      topics: json['topics'] != null
          ? (json['topics'] as List).map((t) => TopicModel.fromJson(t)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'title': title,
      'order_index': orderIndex,
    };
  }

=======
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
  ChapterEntity toEntity() {
    return ChapterEntity(
      id: id,
      subjectId: subjectId,
      title: title,
      topics: topics.map((t) => t.toEntity()).toList(),
      orderIndex: orderIndex ?? 0,
    );
  }

  factory ChapterModel.fromEntity(ChapterEntity entity) {
    return ChapterModel(
      id: entity.id,
      subjectId: entity.subjectId,
      title: entity.title,
      topics: entity.topics.map((t) => TopicModel.fromEntity(t)).toList(),
      orderIndex: entity.orderIndex,
    );
  }
}
