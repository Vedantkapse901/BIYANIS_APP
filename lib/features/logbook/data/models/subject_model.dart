import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/subject_entity.dart';
import 'topic_model.dart';
import 'chapter_model.dart';

part 'subject_model.g.dart';

@HiveType(typeId: 0)
class SubjectModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String color;

  @HiveField(3)
  String icon;

  @HiveField(4)
  List<TopicModel> topics;

  @HiveField(5)
  int? totalTopics;

  @HiveField(6)
  int? completedTopics;

  @HiveField(7)
  DateTime? createdAt;

  @HiveField(8)
  DateTime? updatedAt;

  @HiveField(9)
  List<ChapterModel> chapters;

  @HiveField(10)
  String? batch; // e.g. 'ICSE 9', 'CBSE 10'

  SubjectModel({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.topics = const [],
    this.totalTopics,
    this.completedTopics,
    this.createdAt,
    this.updatedAt,
    this.chapters = const [],
    this.batch,
  });

  // Convert to Entity
  SubjectEntity toEntity() {
    return SubjectEntity(
      id: id,
      name: name,
      color: color,
      icon: icon,
      chapters: chapters.map((c) => c.toEntity()).toList(),
      topics: topics.map((t) => t.toEntity()).toList(),
      totalTopics: totalTopics ?? 0,
      completedTopics: completedTopics ?? 0,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      batch: batch,
    );
  }

  // Convert from Entity
  factory SubjectModel.fromEntity(SubjectEntity entity) {
    return SubjectModel(
      id: entity.id,
      name: entity.name,
      color: entity.color,
      icon: entity.icon,
      chapters: entity.chapters.map((c) => ChapterModel.fromEntity(c)).toList(),
      topics: entity.topics?.map((t) => TopicModel.fromEntity(t)).toList() ?? [],
      totalTopics: entity.totalTopics ?? 0,
      completedTopics: entity.completedTopics ?? 0,
      createdAt: entity.createdAt ?? DateTime.now(),
      updatedAt: entity.updatedAt ?? DateTime.now(),
      batch: entity.batch,
    );
  }
}
