import 'package:flutter/material.dart';
import '../../domain/entities/topic_entity.dart';
import '../../../../core/theme/app_theme.dart';
import 'task_checkbox_item.dart';

class ChapterItem extends StatefulWidget {
  final String subjectId;
  final String chapterId;
  final String title;
  final double progress;
  final List<TopicEntity>? topics;

  const ChapterItem({
    super.key,
    required this.subjectId,
    required this.chapterId,
    required this.title,
    required this.progress,
    this.topics,
  });

  @override
  State<ChapterItem> createState() => _ChapterItemState();
}

class _ChapterItemState extends State<ChapterItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.bgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            title: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: widget.progress,
                  backgroundColor: AppTheme.bgGray,
                  valueColor: AlwaysStoppedAnimation(
                    widget.progress == 1.0 ? Colors.green : AppTheme.primary,
                  ),
                  minHeight: 6,
                ),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(widget.progress * 100).toInt()}%',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                if (widget.topics != null && widget.topics!.isNotEmpty)
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, size: 20),
              ],
            ),
          ),
          if (_isExpanded && widget.topics != null)
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
              child: Column(
                children: widget.topics!
                    .expand((topic) => topic.tasks.map((task) => TaskCheckboxItem(
                          key: ValueKey('task_${task.id}'),
                          subjectId: widget.subjectId,
                          chapterId: widget.chapterId,
                          topicId: topic.id,
                          taskId: task.id,
                          title: task.title,
                          isCompleted: task.isCompleted,
                        )))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
