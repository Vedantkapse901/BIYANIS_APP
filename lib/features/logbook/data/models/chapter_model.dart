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
