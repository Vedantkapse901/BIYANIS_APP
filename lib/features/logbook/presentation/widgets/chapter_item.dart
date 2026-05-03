import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/topic_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/logbook_providers.dart';
=======
import '../../domain/entities/topic_entity.dart';
import '../../../../core/theme/app_theme.dart';
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
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
<<<<<<< HEAD
            dense: true,
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            title: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
=======
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            title: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: widget.progress,
                  backgroundColor: AppTheme.bgGray,
                  valueColor: AlwaysStoppedAnimation(
                    widget.progress == 1.0 ? Colors.green : AppTheme.primary,
                  ),
<<<<<<< HEAD
                  minHeight: 4,
=======
                  minHeight: 6,
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
                ),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(widget.progress * 100).toInt()}%',
<<<<<<< HEAD
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, size: 18),
=======
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                if (widget.topics != null && widget.topics!.isNotEmpty)
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, size: 20),
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
              ],
            ),
          ),
          if (_isExpanded && widget.topics != null)
            Padding(
<<<<<<< HEAD
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Column(
                children: widget.topics!.map((topic) => _buildTopicRow(topic)).toList(),
=======
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
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
              ),
            ),
        ],
      ),
    );
  }
<<<<<<< HEAD

  Widget _buildTopicRow(TopicEntity topic) {
    // Sort tasks by orderIndex
    final sortedTasks = [...topic.tasks]..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Text(
            topic.title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: sortedTasks.map((task) {
              return Tooltip(
                message: task.title,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: CompactTaskCheckbox(
                    subjectId: widget.subjectId,
                    chapterId: widget.chapterId,
                    topicId: topic.id,
                    taskId: task.id,
                    isCompleted: task.isCompleted,
                    orderIndex: task.orderIndex,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 12, thickness: 0.5),
      ],
    );
  }
}

class CompactTaskCheckbox extends ConsumerWidget {
  final String subjectId;
  final String chapterId;
  final String topicId;
  final String taskId;
  final bool isCompleted;
  final int orderIndex;

  const CompactTaskCheckbox({
    super.key,
    required this.subjectId,
    required this.chapterId,
    required this.topicId,
    required this.taskId,
    required this.isCompleted,
    required this.orderIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        ref.read(toggleTopicProvider.notifier).toggleTask(
          subjectId: subjectId,
          chapterId: chapterId,
          topicId: topicId,
          taskId: taskId,
        );
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isCompleted ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isCompleted ? AppTheme.primary : AppTheme.borderColor,
            width: 1.5,
          ),
        ),
        child: isCompleted
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : Center(
                child: Text(
                  '$orderIndex',
                  style: TextStyle(fontSize: 9, color: AppTheme.textLight),
                ),
              ),
      ),
    );
  }
=======
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
}
