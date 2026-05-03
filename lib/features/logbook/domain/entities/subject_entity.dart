import 'chapter_entity.dart';
import 'topic_entity.dart';

class SubjectEntity {
  final String id;
  final String name;
  final String color;
  final String icon;
  final List<ChapterEntity> chapters;
  final String? batch;
  
  // Compatibility fields
  final List<TopicEntity>? topics;
  final int? totalTopics;
  final int? completedTopics;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SubjectEntity({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.chapters = const [],
    this.topics,
    this.totalTopics,
    this.completedTopics,
    this.createdAt,
    this.updatedAt,
    this.batch,
  });

  double get progress {
    if (chapters.isNotEmpty) {
      double total = 0;
      for (var chapter in chapters) {
        total += chapter.progress;
      }
      return total / chapters.length;
    }
    if (totalTopics != null && totalTopics! > 0) {
      return (completedTopics ?? 0) / totalTopics!;
    }
    return 0.0;
  }

  SubjectEntity copyWith({
    String? id,
    String? name,
    String? color,
    String? icon,
    List<ChapterEntity>? chapters,
    List<TopicEntity>? topics,
    int? totalTopics,
    int? completedTopics,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? batch,
  }) {
    return SubjectEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      chapters: chapters ?? this.chapters,
      topics: topics ?? this.topics,
      totalTopics: totalTopics ?? this.totalTopics,
      completedTopics: completedTopics ?? this.completedTopics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      batch: batch ?? this.batch,
    );
  }
}
